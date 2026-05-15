// entscheidung_treffen.dart
// UseCase: Verarbeitet eine getroffene Entscheidung vollständig.
// Aktualisiert Karma, Konsequenzen, Gedanken, Beziehungen,
// die 14 Systeme, Doppelmoral-Tracking und erzeugt ggf. eine Erinnerung.

import 'dart:math';

import 'package:genesis_kreislauf_des_lebens/data/models/erinnerung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/entscheidung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/konsequenz_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/spieler_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';
import 'package:genesis_spiel/domain/repositories/spiel_repository.dart';
import 'package:uuid/uuid.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EntscheidungErgebnis – Rückgabeobjekt des UseCases
// ─────────────────────────────────────────────────────────────────────────────

/// Enthält alle Auswirkungen einer getroffenen Entscheidung.
class EntscheidungErgebnis {
  /// Der aktualisierte Lebenszyklus nach der Entscheidung.
  final ZyklusModel aktualisiertesZyklus;

  /// Das aktualisierte Spielerprofil nach der Entscheidung.
  final SpielerProfilModel aktualisiertesProfilModel;

  /// Konsequenzen, die sofort nach der Entscheidung eingetreten sind.
  final List<KonsequenzModel> sofortigeKonsequenzen;

  /// Neue Gedanken, die durch diese Entscheidung entstanden sind.
  final List<String> neueGedanken;

  /// Gibt an, ob eine neue Erinnerung automatisch erzeugt wurde.
  final bool neueErinnerungErstellt;

  /// Karma-Änderungen je Dimension: Schlüssel = Dimensionsname, Wert = Delta.
  final Map<String, double> karmaAenderungen;

  const EntscheidungErgebnis({
    required this.aktualisiertesZyklus,
    required this.aktualisiertesProfilModel,
    required this.sofortigeKonsequenzen,
    required this.neueGedanken,
    required this.neueErinnerungErstellt,
    required this.karmaAenderungen,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// EntscheidungTreffen UseCase
// ─────────────────────────────────────────────────────────────────────────────

/// UseCase: Verarbeitet eine Entscheidung und ihre Folgen vollständig.
///
/// Reihenfolge der Verarbeitung:
/// 1. Karma-Profil in allen 6 Dimensionen aktualisieren
/// 2. Konsequenzen berechnen (sofortige + verzögerte)
/// 3. Gedanken-Inventar aktualisieren (neue Gedanken einpflegen)
/// 4. Beziehungen stärken oder schwächen
/// 5. 14 gesellschaftliche Systeme auf die Entscheidung anwenden
/// 6. Doppelmoral tracken (Wort vs. Tat)
/// 7. Erinnerung erstellen, wenn die emotionale Intensität hoch genug ist
class EntscheidungTreffen {
  final SpielRepository _repository;
  final _uuid = const Uuid();
  final _zufall = Random();

  /// Schwellenwert für die emotionale Intensität, ab der eine Erinnerung
  /// automatisch angelegt wird (0.0–1.0).
  static const double _erinnerungsSchwelle = 0.65;

  /// Erstellt den UseCase mit dem benötigten [SpielRepository].
  const EntscheidungTreffen({required SpielRepository repository})
      : _repository = repository;

  // ───────────────────────────────────────────────────────────────────────────
  // Haupt-Methode: ausfuehren
  // ───────────────────────────────────────────────────────────────────────────

  /// Führt die Entscheidung vollständig aus und gibt das Ergebnis zurück.
  ///
  /// - [entscheidung]: Die Entscheidungssituation mit allen Optionen.
  /// - [gewaehltOptionIndex]: Index der gewählten Option (0-basiert).
  /// - [zyklus]: Der aktuelle Lebenszyklus des Charakters.
  /// - [profil]: Das übergeordnete Spielerprofil.
  Future<EntscheidungErgebnis> ausfuehren({
    required EntscheidungModel entscheidung,
    required int gewaehltOptionIndex,
    required ZyklusModel zyklus,
    required SpielerProfilModel profil,
  }) async {
    // Gewählte Option bestimmen
    final option = entscheidung.optionen[gewaehltOptionIndex];

    // ── Schritt 1: Karma-Profil aktualisieren ────────────────────────────────
    final karmaAenderungen = <String, double>{};
    var aktuellesKarma = zyklus.karmaAmEnde;

    for (final eintrag in option.karmaAuswirkung.entries) {
      final dimension = eintrag.key;
      // Karma-Multiplikator der aktuellen Phase einrechnen
      final multiplikator = zyklus.aktuellePhase.karmaMultiplikator;
      final delta = eintrag.value * multiplikator;

      // Alten Wert zwischenspeichern, Karma aktualisieren
      final alterWert = _karmaDimensionsWert(aktuellesKarma, dimension);
      aktuellesKarma =
          aktuellesKarma.dimensionAktualisieren(dimension, alterWert + delta);
      karmaAenderungen[dimension.name] = delta;
    }

    // Aktualisierter Zyklus mit neuem Karma
    var aktualisiertesZyklus = zyklus.copyWith(karmaAmEnde: aktuellesKarma);

    // ── Schritt 2: Konsequenzen berechnen ────────────────────────────────────
    final sofortigeKonsequenzen = <KonsequenzModel>[];
    final alleKonsequenzen = <KonsequenzModel>[];

    // Sofortige Konsequenzen aus der Optionsliste
    for (final beschreibung in option.sofortigeKonsequenzen) {
      final konsequenz = KonsequenzModel(
        id: _uuid.v4(),
        quelleEntscheidungId: entscheidung.id,
        beschreibung: beschreibung,
        typ: KonsequenzTyp.sofort,
        verzoegerungInJahren: 0,
        istEingetreten: true,
        attributAuswirkungen: const {},
        betroffeneBeziehungen: const [],
      );
      sofortigeKonsequenzen.add(konsequenz);
      alleKonsequenzen.add(konsequenz);
    }

    // Verzögerte Konsequenzen aus der Optionsliste
    for (int i = 0; i < option.verzoegerteKonsequenzen.length; i++) {
      final beschreibung = option.verzoegerteKonsequenzen[i];
      // Verzögerung: zufällig zwischen 2 und 15 Jahren
      final verzoegerung = 2 + _zufall.nextInt(14);
      final konsequenz = KonsequenzModel(
        id: _uuid.v4(),
        quelleEntscheidungId: entscheidung.id,
        beschreibung: beschreibung,
        typ: KonsequenzTyp.verzoegert,
        verzoegerungInJahren: verzoegerung,
        istEingetreten: false,
        attributAuswirkungen: const {},
        betroffeneBeziehungen: const [],
      );
      alleKonsequenzen.add(konsequenz);
    }

    // Alle Konsequenzen persistieren
    for (final konsequenz in alleKonsequenzen) {
      final json = konsequenz.toJson();
      json['zyklusId'] = zyklus.id;
      json['faelligAlter'] =
          zyklus.aktuellesAlter + konsequenz.verzoegerungInJahren;
      json['istAusgeloest'] = konsequenz.istEingetreten;
      await _repository.konsequenzHinzufuegen(konsequenz);
    }

    // Konsequenz-IDs im Zyklus aktualisieren
    final neueKonsequenzIds = List<String>.from(zyklus.konsequenzIds)
      ..addAll(alleKonsequenzen.map((k) => k.id));
    aktualisiertesZyklus =
        aktualisiertesZyklus.copyWith(konsequenzIds: neueKonsequenzIds);

    // ── Schritt 3: Gedanken-Inventar aktualisieren ───────────────────────────
    final neueGedankenTexte = <String>[];

    // Aus Karma-Auswirkungen relevante Gedanken ableiten
    for (final eintrag in option.karmaAuswirkung.entries) {
      if (eintrag.value.abs() >= 10.0) {
        // Signifikante Karma-Änderung → neuen Gedanken generieren
        final gedankeText = _gedankenTextAusKarma(
            eintrag.key, eintrag.value, option.text);
        final gedanke = GedankeModel(
          id: _uuid.v4(),
          inhalt: gedankeText,
          typ: eintrag.value > 0
              ? GedankenTyp.weisheit
              : GedankenTyp.ueberzeugung,
          intensitaet: (eintrag.value.abs() / 100.0).clamp(0.0, 1.0),
          istAbgeschlossen: false,
          istGiftig: eintrag.value < -15.0,
          herkunftZyklusId: zyklus.id,
          entstanden: DateTime.now(),
          ausloesende_themen: [eintrag.key.name],
          wirdMitgenommen: eintrag.value.abs() >= 20.0,
        );
        await _repository.gedankeSpeichern(gedanke);
        neueGedankenTexte.add(gedankeText);

        // Gedanken-ID im Zyklus vermerken
        final neueGedankenIds =
            List<String>.from(aktualisiertesZyklus.gedankenIds)
              ..add(gedanke.id);
        aktualisiertesZyklus =
            aktualisiertesZyklus.copyWith(gedankenIds: neueGedankenIds);
      }
    }

    // ── Schritt 4: Beziehungen aktualisieren ─────────────────────────────────
    // Altruistische Entscheidungen stärken Beziehungen, egoistische schwächen sie
    final beziehungsEinfluss = option.egoistischAltruistisch;
    if (beziehungsEinfluss.abs() > 0.3) {
      final beziehungen =
          await _repository.beziehungenLaden(zyklus.id);
      for (final beziehung in beziehungen) {
        // Nur direkt beteiligte Beziehungen (vereinfacht: alle aktiven)
        final vertrauensDelta = beziehungsEinfluss * 5.0;
        final aktualisiert = beziehung.copyWith(
          vertrauen:
              (beziehung.vertrauen + vertrauensDelta).clamp(0.0, 100.0),
        );
        await _repository.beziehungSpeichern(aktualisiert, zyklus.id);
      }
    }

    // ── Schritt 5: 14 Systeme anwenden ──────────────────────────────────────
    // Die 14 gesellschaftlichen Systeme beeinflussen das effektive Karma.
    // Systemeinflüsse sind bereits im entscheidungModel hinterlegt.
    aktualisiertesZyklus = _systemEinfluessAnwenden(
        aktualisiertesZyklus, entscheidung, option);

    // ── Schritt 6: Doppelmoral tracken ───────────────────────────────────────
    // Vergleicht, was gewählt wurde, mit den vorherigen Mustern des Spielers.
    aktualisiertesZyklus =
        _doppelmoralAktualisieren(aktualisiertesZyklus, option);

    // ── Schritt 7: Erinnerung erstellen ──────────────────────────────────────
    bool neueErinnerungErstellt = false;
    final emotionaleIntensitaet = _emotionaleIntensitaetBerechnen(option);

    if (emotionaleIntensitaet >= _erinnerungsSchwelle) {
      final erinnerung = ErinnerungModel(
        id: _uuid.v4(),
        titel: _erinnerungsTitelGenerieren(option, entscheidung),
        beschreibung:
            'In der Phase ${zyklus.aktuellePhase.anzeigeName} entschiedest du: '
            '"${option.text}"',
        alter: zyklus.aktuellesAlter,
        phase: zyklus.aktuellePhase,
        emotionaleIntensitaet: emotionaleIntensitaet,
        typ: _erinnerungsTypBestimmen(option),
        istKarmaGericht: false,
        istMitgenommen: emotionaleIntensitaet >= 0.85,
        beteiligte: const [],
      );

      await _repository.erinnerungSpeichern(erinnerung, zyklus.id);
      neueErinnerungErstellt = true;

      // Erinnerungs-ID im Zyklus vermerken
      final neueErinnerungsIds =
          List<String>.from(aktualisiertesZyklus.erinnerungsIds)
            ..add(erinnerung.id);
      aktualisiertesZyklus = aktualisiertesZyklus.copyWith(
          erinnerungsIds: neueErinnerungsIds);
    }

    // ── Entscheidung als getroffen markieren und persistieren ────────────────
    final getroffeneEntscheidung =
        entscheidung.copyWith(gewaehltOptionIndex: gewaehltOptionIndex);
    await _repository.entscheidungSpeichern(
        getroffeneEntscheidung, zyklus.id);

    // Entscheidungs-ID im Zyklus vermerken
    final neueEntscheidungsIds =
        List<String>.from(aktualisiertesZyklus.entscheidungsIds)
          ..add(entscheidung.id);
    aktualisiertesZyklus = aktualisiertesZyklus.copyWith(
        entscheidungsIds: neueEntscheidungsIds);

    // Aktualisierten Zyklus speichern
    await _repository.zyklusSpeichern(aktualisiertesZyklus);

    // ── Profil aktualisieren ─────────────────────────────────────────────────
    // Kumulatives Karma im Profil mit dem neuen Zyklus-Karma zusammenführen
    final aktualisiertesProfilModel = _profilKarmaAktualisieren(
        profil, aktualisiertesZyklus.karmaAmEnde);
    await _repository.profilSpeichern(aktualisiertesProfilModel);

    return EntscheidungErgebnis(
      aktualisiertesZyklus: aktualisiertesZyklus,
      aktualisiertesProfilModel: aktualisiertesProfilModel,
      sofortigeKonsequenzen: sofortigeKonsequenzen,
      neueGedanken: neueGedankenTexte,
      neueErinnerungErstellt: neueErinnerungErstellt,
      karmaAenderungen: karmaAenderungen,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Private Hilfsmethoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Liest den Rohwert einer Karma-Dimension aus einem KarmaProfilModel aus.
  double _karmaDimensionsWert(
      KarmaProfilModel karma, KarmaDimension dimension) {
    switch (dimension) {
      case KarmaDimension.mitgefuehl:
        return karma.mitgefuehl;
      case KarmaDimension.ehrlichkeit:
        return karma.ehrlichkeit;
      case KarmaDimension.mut:
        return karma.mut;
      case KarmaDimension.grosszuegigkeit:
        return karma.grosszuegigkeit;
      case KarmaDimension.weisheit:
        return karma.weisheit;
      case KarmaDimension.liebe:
        return karma.liebe;
    }
  }

  /// Generiert einen kurzen Gedankentext, der die Karma-Bewegung widerspiegelt.
  String _gedankenTextAusKarma(
      KarmaDimension dimension, double delta, String optionText) {
    final richtung = delta > 0 ? 'stärkt' : 'belastet';
    return 'Diese Wahl $richtung mein Gefühl für ${dimension.name}: "$optionText"';
  }

  /// Berechnet die emotionale Intensität einer Option für die Erinnerungsschwelle.
  double _emotionaleIntensitaetBerechnen(EntscheidungsOption option) {
    // Intensität = Durchschnitt der absoluten Karma-Auswirkungen, normiert auf 0–1
    if (option.karmaAuswirkung.isEmpty) return 0.0;
    final summe = option.karmaAuswirkung.values
        .fold<double>(0.0, (acc, v) => acc + v.abs());
    return (summe / (option.karmaAuswirkung.length * 25.0)).clamp(0.0, 1.0);
  }

  /// Bestimmt den passenden Erinnerungstyp anhand der dominanten Karma-Achse.
  ErinnerungsTyp _erinnerungsTypBestimmen(EntscheidungsOption option) {
    if (option.karmaAuswirkung.isEmpty) return ErinnerungsTyp.staunen;

    // Dominante Dimension mit dem größten absoluten Wert suchen
    final dominant = option.karmaAuswirkung.entries
        .reduce((a, b) => a.value.abs() >= b.value.abs() ? a : b);

    if (dominant.value > 0) {
      switch (dominant.key) {
        case KarmaDimension.liebe:
          return ErinnerungsTyp.liebe;
        case KarmaDimension.mut:
          return ErinnerungsTyp.triumph;
        case KarmaDimension.grosszuegigkeit:
          return ErinnerungsTyp.stolz;
        case KarmaDimension.mitgefuehl:
          return ErinnerungsTyp.freude;
        default:
          return ErinnerungsTyp.staunen;
      }
    } else {
      switch (dominant.key) {
        case KarmaDimension.ehrlichkeit:
          return ErinnerungsTyp.scham;
        case KarmaDimension.mut:
          return ErinnerungsTyp.angst;
        case KarmaDimension.liebe:
          return ErinnerungsTyp.verlust;
        default:
          return ErinnerungsTyp.trauer;
      }
    }
  }

  /// Generiert einen kurzen Erinnerungstitel aus Option und Entscheidung.
  String _erinnerungsTitelGenerieren(
      EntscheidungsOption option, EntscheidungModel entscheidung) {
    // Titel aus den ersten 40 Zeichen der Frage ableiten
    final kurztitel = entscheidung.frage.length > 40
        ? '${entscheidung.frage.substring(0, 40)}…'
        : entscheidung.frage;
    return kurztitel;
  }

  /// Wendet den Einfluss der 14 gesellschaftlichen Systeme auf den Zyklus an.
  ///
  /// Systeme: Indoktrination, Zeitgeist, Kulturelle Identität, Religion,
  /// Bildungssystem, Mediensystem, Wirtschaftssystem, Rechtssystem,
  /// Familienstruktur, Peergroup, Politisches System, Militär, Gesundheit,
  /// Technologie.
  ZyklusModel _systemEinfluessAnwenden(ZyklusModel zyklus,
      EntscheidungModel entscheidung, EntscheidungsOption option) {
    // Systemeinflüsse als Stressmodifikator interpretieren
    final systemEinfluesse = entscheidung.systemEinfluesse;

    // Indoktrination und Zeitgeist erhöhen Stress bei Gegenströmung
    final indoktrinationsEinfluss =
        systemEinfluesse['indoktrination'] ?? 0.0;
    final zeitgeistEinfluss = systemEinfluesse['zeitgeist'] ?? 0.0;

    // Wenn die Entscheidung gegen den Zeitgeist geht (egoistisch vs. altruistisch),
    // steigt der Stress leicht
    double stressDelta = 0.0;
    if (option.egoistischAltruistisch < 0 && zeitgeistEinfluss > 0.5) {
      // Egoistische Wahl in einer altruistisch geprägten Zeit → mehr Stress
      stressDelta += indoktrinationsEinfluss * 0.05;
    } else if (option.egoistischAltruistisch > 0 &&
        zeitgeistEinfluss < -0.5) {
      // Altruistische Wahl in einer egoistisch geprägten Zeit → mehr Stress
      stressDelta += indoktrinationsEinfluss * 0.03;
    }

    // Spiritualitätssystem (Religion): positive Entscheidungen erhöhen Spiritualität
    final religioeserEinfluss = systemEinfluesse['religion'] ?? 0.0;
    double spiritualitaetsDelta = 0.0;
    if (option.egoistischAltruistisch > 0.5 && religioeserEinfluss > 0.3) {
      spiritualitaetsDelta += religioeserEinfluss * 0.04;
    }

    // Angepasste Werte auf gültigen Bereich begrenzen
    final neuerStress =
        (zyklus.stress + stressDelta).clamp(0.0, 1.0);
    final neueSpiritualitaet =
        (zyklus.spiritualitaet + spiritualitaetsDelta).clamp(0.0, 1.0);

    return zyklus.copyWith(
      stress: neuerStress,
      spiritualitaet: neueSpiritualitaet,
    );
  }

  /// Aktualisiert den Doppelmoral-Tracker.
  ///
  /// Vergleicht die getroffene Wahl mit dem bisherigen Karma-Muster des Spielers.
  /// Wenn ein Muster von "sagen, aber nicht tun" erkennbar ist, wird es registriert.
  ZyklusModel _doppelmoralAktualisieren(
      ZyklusModel zyklus, EntscheidungsOption option) {
    final neuerTracker =
        Map<String, double>.from(zyklus.doppelmoralTracker);

    for (final eintrag in option.karmaAuswirkung.entries) {
      final dimensionsName = eintrag.key.name;
      final delta = eintrag.value;

      // Laufenden Doppelmoral-Wert aktualisieren:
      // Positive Wahl (+) reduziert den Wert Richtung 0 (weniger Doppelmoral),
      // negative Wahl (-) erhöht ihn.
      final aktuellerWert = neuerTracker[dimensionsName] ?? 0.0;
      final neuerWert = (aktuellerWert - delta * 0.01).clamp(-1.0, 1.0);
      neuerTracker[dimensionsName] = neuerWert;
    }

    return zyklus.copyWith(doppelmoralTracker: neuerTracker);
  }

  /// Führt das kumulative Karma des Profils mit dem neuen Zyklus-Karma zusammen.
  SpielerProfilModel _profilKarmaAktualisieren(
      SpielerProfilModel profil, KarmaProfilModel zyklusKarma) {
    // Gewichteter Durchschnitt: 70% altes Profil, 30% aktueller Zyklus
    final kumulativ = profil.kumulativesKarma;
    final neuesKarma = KarmaProfilModel(
      mitgefuehl:
          (kumulativ.mitgefuehl * 0.7 + zyklusKarma.mitgefuehl * 0.3)
              .clamp(-100.0, 100.0),
      ehrlichkeit:
          (kumulativ.ehrlichkeit * 0.7 + zyklusKarma.ehrlichkeit * 0.3)
              .clamp(-100.0, 100.0),
      mut: (kumulativ.mut * 0.7 + zyklusKarma.mut * 0.3)
          .clamp(-100.0, 100.0),
      grosszuegigkeit:
          (kumulativ.grosszuegigkeit * 0.7 +
                  zyklusKarma.grosszuegigkeit * 0.3)
              .clamp(-100.0, 100.0),
      weisheit:
          (kumulativ.weisheit * 0.7 + zyklusKarma.weisheit * 0.3)
              .clamp(-100.0, 100.0),
      liebe: (kumulativ.liebe * 0.7 + zyklusKarma.liebe * 0.3)
          .clamp(-100.0, 100.0),
    );

    return profil.copyWith(kumulativesKarma: neuesKarma);
  }
}
