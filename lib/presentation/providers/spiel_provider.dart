// spiel_provider.dart
// Haupt-Spielzustand-Provider für GENESIS: Der Kreislauf des Lebens.
// Der SpielNotifier verwaltet den gesamten Spielablauf: Laden, Speichern,
// Phasenwechsel, Entscheidungen und das Altern des Charakters.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/emotions_wetter_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/entscheidung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/spieler_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_zustand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hive-Box-Namen (aus main.dart)
// ─────────────────────────────────────────────────────────────────────────────

/// Box für Spielstand-Daten (Spielerprofil und Zyklus)
const String _kSpielstandBox = 'spielstand';

/// Box für Seelen-Zyklen-Metadaten
const String _kSeelenZyklenBox = 'seelen_zyklen';

// ─────────────────────────────────────────────────────────────────────────────
// SpielNotifier – verwaltet den Hauptspielzustand
// ─────────────────────────────────────────────────────────────────────────────

/// StateNotifier für den gesamten Spielablauf.
///
/// Alle Zustandsänderungen erfolgen über die öffentlichen Methoden dieser Klasse.
/// Direkter Zugriff auf [state] von außen ist nicht vorgesehen.
class SpielNotifier extends StateNotifier<SpielZustand> {
  SpielNotifier() : super(SpielZustand.initial());

  // Hive-Box-Referenz für den Spielstand
  Box<Map>? _spielstandBox;
  Box<int>? _seelenZyklenBox;

  // ───────────────────────────────────────────────────────────────────────────
  // Öffentliche Methoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Lädt ein bestehendes Spielerprofil und den zugehörigen Zyklus aus Hive.
  ///
  /// Setzt [istLadend] während des Ladevorgangs und fängt Fehler ab.
  Future<void> spielerLaden(String profilId) async {
    // Ladezustand aktivieren
    state = state.copyWith(istLadend: true, fehlerLoeschen: true);

    try {
      // Hive-Box öffnen (falls noch nicht geöffnet)
      _spielstandBox ??= await Hive.openBox<Map>(_kSpielstandBox);

      // Spielerprofil aus Hive laden
      final profilRoh = _spielstandBox!.get('profil_$profilId');
      if (profilRoh == null) {
        state = state.copyWith(
          istLadend: false,
          fehlerMeldung: 'Spielerprofil nicht gefunden: $profilId',
        );
        return;
      }

      final profil = SpielerProfilModel.fromJson(
        Map<String, dynamic>.from(profilRoh),
      );

      // Aktuellen Zyklus laden
      final zyklusRoh =
          _spielstandBox!.get('zyklus_${profil.aktuellerZyklusId}');
      ZyklusModel? zyklus;
      if (zyklusRoh != null) {
        zyklus = ZyklusModel.fromJson(
          Map<String, dynamic>.from(zyklusRoh),
        );
      }

      // Emotions-Wetter basierend auf geladenem Karma berechnen
      final emotionsWetter = _wetterAusKarma(profil.kumulativesKarma);

      state = state.copyWith(
        spielerProfil: profil,
        aktuellerZyklus: zyklus,
        aktuellePhase: zyklus?.aktuellePhase ?? GamePhase.entstehung,
        emotionsWetter: emotionsWetter,
        istLadend: false,
        spielLaeuft: zyklus != null && !zyklus.abgeschlossen,
        // Alter aus dem persistierten Zyklus übernehmen;
        // Fallback auf das Mindest-Alter der Phase, wenn noch nichts gespeichert wurde.
        aktuellesAlter: (zyklus != null && zyklus.aktuellesAlter > 0)
            ? zyklus.aktuellesAlter
            : (zyklus?.aktuellePhase.minAlter ?? 0),
      );
    } catch (fehler) {
      // Fehler protokollieren und im Zustand speichern
      state = state.copyWith(
        istLadend: false,
        fehlerMeldung: 'Fehler beim Laden: ${fehler.toString()}',
      );
    }
  }

  /// Startet ein komplett neues Spiel mit einem frischen Profil und Zyklus.
  ///
  /// Erstellt ein neues [SpielerProfilModel] mit der angegebenen [name] und
  /// einem ersten [ZyklusModel] im gewählten [zeitalter].
  Future<void> neuesSpielStarten(String name, Zeitalter zeitalter) async {
    state = state.copyWith(istLadend: true, fehlerLoeschen: true);

    try {
      // Neues Spielerprofil anlegen
      final neuProfil = SpielerProfilModel.neu(name);

      // Ersten Lebenszyklus erstellen
      final ersterZyklus = ZyklusModel.starten(
        profilId: neuProfil.id,
        zeitalter: zeitalter,
        zyklusNummer: 1,
      );

      // Profil mit korrekter Zyklus-ID aktualisieren
      final profilMitZyklus = neuProfil.copyWith(
        aktuellerZyklusId: ersterZyklus.id,
        zyklusIds: [ersterZyklus.id],
      );

      // Neutrales Anfangswetter
      final startWetter = EmotionsWetterModel.vonEmotion(
        glueck: 0.5,
        stress: 0.1,
        liebe: 0.4,
        spiritualitaet: 0.2,
      );

      state = state.copyWith(
        spielerProfil: profilMitZyklus,
        aktuellerZyklus: ersterZyklus,
        aktuellePhase: GamePhase.entstehung,
        emotionsWetter: startWetter,
        istLadend: false,
        spielLaeuft: true,
        aktuellesAlter: 0,
      );

      // Sofort in Hive speichern
      await spielSpeichern();
    } catch (fehler) {
      state = state.copyWith(
        istLadend: false,
        fehlerMeldung: 'Fehler beim Starten: ${fehler.toString()}',
      );
    }
  }

  /// Schließt den aktuellen Lebenszyklus ab und startet die nächste
  /// Inkarnation derselben Seele (Reinkarnation).
  /// [karmaErbeFaktor]: Anteil des Karmas, der ins neue Leben übergeht (0.0–1.0).
  Future<void> zyklusAbschliessenUndNeuStarten({
    double karmaErbeFaktor = 0.3,
  }) async {
    final profil = state.spielerProfil;
    final alterZyklus = state.aktuellerZyklus;

    // Guard: Ohne Profil und aktiven Zyklus keine Reinkarnation möglich
    if (profil == null || alterZyklus == null) {
      state = state.copyWith(
        fehlerMeldung: 'Kein aktives Profil oder Zyklus für die Reinkarnation.',
      );
      return;
    }

    try {
      _spielstandBox ??= await Hive.openBox<Map>(_kSpielstandBox);

      // 1. Alten Zyklus als abgeschlossen markieren und persistieren
      final abgeschlossenerZyklus = alterZyklus.copyWith(
        abgeschlossen: true,
        sterbealter: state.aktuellesAlter,
        karmaAmEnde: profil.kumulativesKarma,
      );
      await _spielstandBox!.put(
        'zyklus_${abgeschlossenerZyklus.id}',
        abgeschlossenerZyklus.toJson(),
      );

      // 2. Karma-Erbe berechnen: jede Dimension × karmaErbeFaktor
      final faktor = karmaErbeFaktor.clamp(0.0, 1.0);
      final altesKarma = profil.kumulativesKarma;
      final erbeKarma = KarmaProfilModel(
        mitgefuehl: altesKarma.mitgefuehl * faktor,
        ehrlichkeit: altesKarma.ehrlichkeit * faktor,
        mut: altesKarma.mut * faktor,
        grosszuegigkeit: altesKarma.grosszuegigkeit * faktor,
        weisheit: altesKarma.weisheit * faktor,
        liebe: altesKarma.liebe * faktor,
      );

      // 3. Neuen Zyklus (nächste Inkarnation) mit Erbe-Karma erzeugen
      final neuerZyklus = ZyklusModel.starten(
        profilId: profil.id,
        zeitalter: alterZyklus.zeitalter,
        zyklusNummer: profil.aktuellerZyklusNummer + 1,
      ).copyWith(karmaAmEnde: erbeKarma);

      // 4. Seelenprofil auf die neue Inkarnation umstellen
      final aktualisiertProfil = profil.copyWith(
        aktuellerZyklusId: neuerZyklus.id,
        zyklusIds: [...profil.zyklusIds, neuerZyklus.id],
        aktuellerZyklusNummer: profil.aktuellerZyklusNummer + 1,
        kumulativesKarma: erbeKarma,
        letzterSpieltag: DateTime.now(),
      );

      // 5. Spielzustand auf den Anfang des neuen Lebens setzen
      state = state.copyWith(
        spielerProfil: aktualisiertProfil,
        aktuellerZyklus: neuerZyklus,
        aktuellePhase: GamePhase.entstehung,
        emotionsWetter: _wetterAusKarma(erbeKarma),
        aktuellesAlter: 0,
        spielLaeuft: true,
        fehlerLoeschen: true,
      );

      // 6. Neuen Stand (Profil + neuer Zyklus) persistieren
      await spielSpeichern();
    } catch (fehler) {
      state = state.copyWith(
        fehlerMeldung: 'Fehler bei der Reinkarnation: ${fehler.toString()}',
      );
    }
  }

  /// Wechselt die Spielphase mit Validierungs-Guard-Logik.
  ///
  /// Prüft, ob der Phasenwechsel gültig ist (chronologisch, kein Rückschritt).
  /// Bei ungültigem Wechsel wird eine Fehlermeldung gesetzt.
  Future<void> phasWechseln(GamePhase neuPhase) async {
    final aktuell = state.aktuellePhase;

    // Guard: Nur Vorwärts-Phasenwechsel erlaubt
    if (neuPhase.nummer <= aktuell.nummer) {
      state = state.copyWith(
        fehlerMeldung:
            'Ungültiger Phasenwechsel: ${aktuell.name} → ${neuPhase.name}',
      );
      return;
    }

    // Guard: Kein Phasenwechsel ohne aktiven Zyklus
    if (state.aktuellerZyklus == null) {
      state = state.copyWith(
        fehlerMeldung: 'Kein aktiver Zyklus für Phasenwechsel.',
      );
      return;
    }

    // Alter auf Mindest-Alter der neuen Phase setzen (falls aktuelles Alter darunter)
    final neuesAlter = state.aktuellesAlter < neuPhase.minAlter
        ? neuPhase.minAlter
        : state.aktuellesAlter;

    // Zyklus mit neuer Phase und aktuellem Alter aktualisieren
    final aktualisiertZyklus = state.aktuellerZyklus!.copyWith(
      aktuellePhase: neuPhase,
      aktuellesAlter: neuesAlter,
    );

    // Emissions-Wetter bei Todphase dramatisch anpassen
    EmotionsWetterModel neuesWetter = state.emotionsWetter;
    if (neuPhase == GamePhase.jenseits) {
      neuesWetter = EmotionsWetterModel.vonEmotion(
        glueck: 0.2,
        stress: 0.3,
        liebe: 0.6,
        spiritualitaet: 0.8,
      );
    }

    state = state.copyWith(
      aktuellerZyklus: aktualisiertZyklus,
      aktuellePhase: neuPhase,
      aktuellesAlter: neuesAlter,
      emotionsWetter: neuesWetter,
      // Spiel läuft nicht mehr bei Tod
      spielLaeuft: neuPhase != GamePhase.jenseits,
      fehlerLoeschen: true,
    );

    // Zustand persistieren
    await spielSpeichern();
  }

  /// Verarbeitet eine getroffene Entscheidung und aktualisiert das Karma.
  ///
  /// Sucht die Entscheidung im aktuellen Zyklus, markiert die gewählte Option
  /// und wendet die Karma-Auswirkungen multipliziert mit dem Phasen-Multiplikator an.
  Future<void> entscheidungTreffen(
      String entscheidungId, int optionIndex) async {
    final zyklus = state.aktuellerZyklus;
    final profil = state.spielerProfil;

    if (zyklus == null || profil == null) {
      state = state.copyWith(
        fehlerMeldung: 'Kein aktiver Zyklus oder Profil für Entscheidung.',
      );
      return;
    }

    // Entscheidung im Zyklus finden
    final entscheidungIndex = zyklus.getroffeneEntscheidungen
        .indexWhere((e) => e.id == entscheidungId);

    if (entscheidungIndex < 0) {
      // Entscheidungen aus den JSON-Daten sind dem Zyklus anfangs unbekannt.
      // Statt (wie früher) mit einem Fehler abzubrechen – wodurch KEINE
      // Entscheidung je gespeichert wurde – wird die Wahl als neuer Eintrag
      // protokolliert. Die Karma-Wirkung übernimmt der KarmaNotifier, der
      // sie über karmaUebernehmen() ins Profil spiegelt.
      final protokollEintrag = EntscheidungModel(
        id: entscheidungId,
        frage: entscheidungId,
        kontext: '',
        optionen: const [],
        gewaehltOptionIndex: optionIndex,
        istMikroEntscheidung: false,
        hatParallelvorschau: false,
        systemEinfluesse: const {},
      );

      final aktualisiertZyklus = zyklus.copyWith(
        getroffeneEntscheidungen: [
          ...zyklus.getroffeneEntscheidungen,
          protokollEintrag,
        ],
      );
      final aktualisiertProfil =
          profil.copyWith(letzterSpieltag: DateTime.now());

      state = state.copyWith(
        aktuellerZyklus: aktualisiertZyklus,
        spielerProfil: aktualisiertProfil,
        fehlerLoeschen: true,
      );
      await spielSpeichern();
      return;
    }

    final entscheidung = zyklus.getroffeneEntscheidungen[entscheidungIndex];

    // Optionsindex validieren
    if (optionIndex < 0 || optionIndex >= entscheidung.optionen.length) {
      state = state.copyWith(
        fehlerMeldung: 'Ungültiger Options-Index: $optionIndex',
      );
      return;
    }

    final gewaehltOption = entscheidung.optionen[optionIndex];
    final multiplikator = state.aktuellePhase.karmaMultiplikator;

    // Entscheidung als getroffen markieren
    final aktualisiertEntscheidung = entscheidung.copyWith(
      gewaehltOptionIndex: optionIndex,
    );

    // Aktuelle Karma-Werte aus Profil
    var aktuellesKarma = profil.kumulativesKarma;

    // Karma-Auswirkungen der gewählten Option anwenden (mit Phasen-Multiplikator)
    for (final eintrag in gewaehltOption.karmaAuswirkung.entries) {
      final aktuellWert = switch (eintrag.key) {
        KarmaDimension.mitgefuehl => aktuellesKarma.mitgefuehl,
        KarmaDimension.ehrlichkeit => aktuellesKarma.ehrlichkeit,
        KarmaDimension.mut => aktuellesKarma.mut,
        KarmaDimension.grosszuegigkeit => aktuellesKarma.grosszuegigkeit,
        KarmaDimension.weisheit => aktuellesKarma.weisheit,
        KarmaDimension.liebe => aktuellesKarma.liebe,
      };
      final neuerWert = (aktuellWert + eintrag.value * multiplikator)
          .clamp(-100.0, 100.0);
      aktuellesKarma = aktuellesKarma.dimensionAktualisieren(eintrag.key, neuerWert);
    }

    // Getroffene Entscheidungen im Zyklus aktualisieren
    final aktualisiertEntscheidungen =
        List<EntscheidungModel>.from(zyklus.getroffeneEntscheidungen);
    aktualisiertEntscheidungen[entscheidungIndex] = aktualisiertEntscheidung;

    final aktualisiertZyklus = zyklus.copyWith(
      getroffeneEntscheidungen: aktualisiertEntscheidungen,
      karmaAmEnde: aktuellesKarma,
    );

    // Spielerprofil mit neuem kumulativen Karma aktualisieren
    final aktualisiertProfil = profil.copyWith(
      kumulativesKarma: aktuellesKarma,
      letzterSpieltag: DateTime.now(),
    );

    // Emotions-Wetter basierend auf neuem Karma aktualisieren
    final neuesWetter = _wetterAusKarma(aktuellesKarma);

    state = state.copyWith(
      aktuellerZyklus: aktualisiertZyklus,
      spielerProfil: aktualisiertProfil,
      emotionsWetter: neuesWetter,
      fehlerLoeschen: true,
    );

    // Persistieren
    await spielSpeichern();
  }

  /// Erhöht das Alter des Charakters um ein Jahr und passt ggf. die Phase an.
  ///
  /// Wenn das neue Alter das Maximum der aktuellen Phase überschreitet,
  /// wird automatisch zur nächsten Phase gewechselt.
  Future<void> alterErhoehen() async {
    final zyklus = state.aktuellerZyklus;
    if (zyklus == null) return;

    final neuesAlter = state.aktuellesAlter + 1;
    final aktuellePhase = state.aktuellePhase;

    // Neues Alter auch im Zyklus ablegen, damit es persistiert wird
    final zyklusMitAlter = zyklus.copyWith(aktuellesAlter: neuesAlter);

    // Automatischer Phasenwechsel wenn Altersgrenze überschritten
    GamePhase zielPhase = aktuellePhase;
    if (neuesAlter > aktuellePhase.maxAlter) {
      final naechste = aktuellePhase.naechstePhase;
      if (naechste != null) {
        zielPhase = naechste;
      }
    }

    // Wenn Phase gewechselt werden muss, phasWechseln aufrufen
    // (phasWechseln speichert den Zyklus selbst)
    if (zielPhase != aktuellePhase) {
      state = state.copyWith(
        aktuellesAlter: neuesAlter,
        aktuellerZyklus: zyklusMitAlter,
      );
      await phasWechseln(zielPhase);
      return;
    }

    state = state.copyWith(
      aktuellesAlter: neuesAlter,
      aktuellerZyklus: zyklusMitAlter,
      fehlerLoeschen: true,
    );
    await spielSpeichern();
  }

  /// Setzt das Alter des Charakters direkt auf [neuesAlter] und persistiert.
  ///
  /// Anders als [alterErhoehen] wird KEIN automatischer Phasenwechsel
  /// ausgelöst – gedacht für den Jahres-Loop der Phase 5 (Alter > Phasen-
  /// Maximum ohne vorzeitigen Übergang) und das dynamische Sterbealter
  /// in Phase 6.
  Future<void> alterSetzen(int neuesAlter) async {
    final zyklus = state.aktuellerZyklus;
    if (zyklus == null) return;

    state = state.copyWith(
      aktuellesAlter: neuesAlter,
      aktuellerZyklus: zyklus.copyWith(aktuellesAlter: neuesAlter),
      fehlerLoeschen: true,
    );
    await spielSpeichern();
  }

  /// Setzt die aktuelle Fehlermeldung zurück.
  void fehlerZuruecksetzen() {
    state = state.copyWith(fehlerLoeschen: true);
  }

  /// Speichert den aktuellen Spielstand in Hive.
  ///
  /// Schreibt Spielerprofil und aktiven Zyklus unter ihren jeweiligen IDs.
  /// Übernimmt einen extern (KarmaNotifier) geänderten Karma-Stand in
  /// Profil und Zyklus und persistiert ihn. Ohne diese Brücke ging jede
  /// Karma-Änderung der Phasen 3–9 beim App-Neustart verloren.
  Future<void> karmaUebernehmen(KarmaProfilModel karma) async {
    final profil = state.spielerProfil;
    if (profil == null) return;

    final aktualisiertProfil = profil.copyWith(
      kumulativesKarma: karma,
      letzterSpieltag: DateTime.now(),
    );
    final aktualisiertZyklus =
        state.aktuellerZyklus?.copyWith(karmaAmEnde: karma);

    state = state.copyWith(
      spielerProfil: aktualisiertProfil,
      aktuellerZyklus: aktualisiertZyklus,
      emotionsWetter: _wetterAusKarma(karma),
    );
    await spielSpeichern();
  }

  /// Ersetzt den aktiven Zyklus (z. B. nach dem Spermien-Rennen mit neuem
  /// genetischen Code) und persistiert den Stand.
  Future<void> zyklusAktualisieren(ZyklusModel aktualisiertZyklus) async {
    state = state.copyWith(aktuellerZyklus: aktualisiertZyklus);
    await spielSpeichern();
  }

  Future<void> spielSpeichern() async {
    final profil = state.spielerProfil;
    final zyklus = state.aktuellerZyklus;

    if (profil == null) return;

    try {
      _spielstandBox ??= await Hive.openBox<Map>(_kSpielstandBox);

      // Spielerprofil speichern
      await _spielstandBox!.put('profil_${profil.id}', profil.toJson());

      // Aktiven Zyklus speichern
      if (zyklus != null) {
        await _spielstandBox!.put('zyklus_${zyklus.id}', zyklus.toJson());
      }

      // Zyklusanzahl in Seelen-Zyklen-Box tracken
      _seelenZyklenBox ??= await Hive.openBox<int>(_kSeelenZyklenBox);
      await _seelenZyklenBox!.put(
        'anzahl_${profil.id}',
        profil.aktuellerZyklusNummer,
      );
    } catch (fehler) {
      // Speicherfehler im Zustand vermerken (nicht spielunterbrechend)
      state = state.copyWith(
        fehlerMeldung: 'Speichern fehlgeschlagen: ${fehler.toString()}',
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Private Hilfsmethoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Berechnet ein passendes Emotions-Wetter basierend auf dem Karma-Profil.
  EmotionsWetterModel _wetterAusKarma(KarmaProfilModel karma) {
    final avg = karma.durchschnitt;
    // Karma-Durchschnitt auf 0–1-Glücksskala mappen
    final glueck = ((avg + 100.0) / 200.0).clamp(0.0, 1.0);
    final stress = avg < 0 ? (-avg / 100.0) * 0.6 : 0.1;
    final liebe = (karma.liebe + 100.0) / 200.0;
    final spiritualitaet = (karma.weisheit + 100.0) / 200.0 * 0.7;

    return EmotionsWetterModel.vonEmotion(
      glueck: glueck,
      stress: stress,
      liebe: liebe,
      spiritualitaet: spiritualitaet,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Haupt-Spielzustand-Provider – Herzstück des gesamten State-Managements.
///
/// Alle spielrelevanten UI-Elemente lesen aus diesem Provider.
/// Änderungen werden ausschließlich über [SpielNotifier]-Methoden durchgeführt.
final spielProvider =
    StateNotifierProvider<SpielNotifier, SpielZustand>((ref) {
  return SpielNotifier();
});

// ─────────────────────────────────────────────────────────────────────────────
// Bequemlichkeits-Provider (leiten aus spielProvider ab)
// ─────────────────────────────────────────────────────────────────────────────

/// Gibt nur das aktuelle Spielerprofil zurück (null wenn nicht geladen).
final aktuellesProfilProvider = Provider<SpielerProfilModel?>((ref) {
  return ref.watch(spielProvider).spielerProfil;
});

/// Gibt nur den aktuellen Lebenszyklus zurück (null wenn nicht gestartet).
final aktuellerZyklusProvider = Provider<ZyklusModel?>((ref) {
  return ref.watch(spielProvider).aktuellerZyklus;
});

/// Gibt die aktuelle Spielphase zurück.
final aktuellePhaseProvider = Provider<GamePhase>((ref) {
  return ref.watch(spielProvider).aktuellePhase;
});

/// Gibt das aktuelle Alter des Charakters im laufenden Zyklus zurück.
final aktuellesAlterProvider = Provider<int>((ref) {
  return ref.watch(spielProvider).aktuellesAlter;
});

/// Gibt zurück, ob gerade eine Ladeoperation aktiv ist.
final istLadendProvider = Provider<bool>((ref) {
  return ref.watch(spielProvider).istLadend;
});

/// Gibt die aktuelle Fehlermeldung zurück (null wenn kein Fehler).
final fehlerMeldungProvider = Provider<String?>((ref) {
  return ref.watch(spielProvider).fehlerMeldung;
});

/// Gibt zurück, ob das Spiel aktiv läuft.
final spielLaeuftProvider = Provider<bool>((ref) {
  return ref.watch(spielProvider).spielLaeuft;
});

/// Gibt das aktuelle Emotions-Wetter zurück.
final emotionsWetterImSpielProvider = Provider<EmotionsWetterModel>((ref) {
  return ref.watch(spielProvider).emotionsWetter;
});
