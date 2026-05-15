// karma_engine.dart
// Reine Berechnungs-Engine für alle Karma-bezogenen Operationen.
// Keine externe Abhängigkeiten auf Riverpod – nur pure Dart-Logik.
// Alle Methoden sind statisch, keine Instanzierung nötig.

import 'dart:math';
import 'package:genesis_spiel/data/models/karma_profil_model.dart';
import 'package:genesis_spiel/data/models/erinnerung_model.dart';
import 'package:genesis_spiel/data/models/gedanke_model.dart';
import 'package:genesis_spiel/data/models/entscheidung_model.dart';
import 'package:genesis_spiel/data/models/emotions_wetter_model.dart';
import 'package:genesis_spiel/data/models/zyklus_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KarmaEngine – statische Berechnungsmethoden für das Karma-System
// ─────────────────────────────────────────────────────────────────────────────
class KarmaEngine {
  // Privater Konstruktor – die Engine ist nicht instantiierbar
  KarmaEngine._();

  // ───────────────────────────────────────────────────────────────────────────
  // Internes Momentum-Gewicht: Bestehende Werte behalten 20 % Trägheit
  // ───────────────────────────────────────────────────────────────────────────
  static const double _momentumFaktor = 0.20;

  // ───────────────────────────────────────────────────────────────────────────
  // dimensionAktualisieren
  // Aktualisiert einen einzelnen Karma-Wert unter Berücksichtigung von
  // Momentum (Trägheit) und clamp auf den gültigen Wertebereich [-100, +100].
  // ───────────────────────────────────────────────────────────────────────────

  /// Berechnet den neuen Karma-Wert für eine einzelne Dimension.
  ///
  /// - [aktuell]: bisheriger Wert im Bereich [-100, +100]
  /// - [delta]: gewünschte Veränderung (positiv oder negativ)
  ///
  /// Das Momentum bewirkt, dass extreme Werte langsamer weitersteigen,
  /// da der bisherige Wert mit 20 % Gewichtung eingerechnet wird.
  static double dimensionAktualisieren(double aktuell, double delta) {
    // Momentum-Anteil: Bisheriger Wert bremst weitere Bewegung in gleicher Richtung
    final momentumDelta = aktuell * _momentumFaktor * delta.sign;
    final roherNeuerWert = aktuell + delta - momentumDelta;
    return roherNeuerWert.clamp(-100.0, 100.0);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // reichBerechnen
  // Bestimmt das Jenseitsreich aus dem aktuellen Karma-Profil.
  // Orientiert sich an den Schwellwerten aus KarmaProfilModel.
  // ───────────────────────────────────────────────────────────────────────────

  /// Berechnet das passende Jenseitsreich für ein gegebenes Karma-Profil.
  ///
  /// Die Berechnung basiert auf dem Durchschnittswert aller sechs
  /// Karma-Dimensionen und berücksichtigt besondere Muster.
  static JenseitsReich reichBerechnen(KarmaProfilModel karma) {
    final avg = karma.durchschnitt;

    // Elysium: Sehr hohes positives Karma über alle Dimensionen
    if (avg >= 60.0) return JenseitsReich.elysium;

    // Harmonia: Positives Karma, ausgeglichen
    if (avg >= 20.0) return JenseitsReich.harmonia;

    // Abyssus: Stark negatives Karma
    if (avg <= -60.0) return JenseitsReich.abyssus;

    // Shadowlands: Negatives Karma
    if (avg <= -20.0) return JenseitsReich.shadowlands;

    // Limbus: Ausgeglichenes oder neutrales Karma
    return JenseitsReich.limbus;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // erinnerungenFuerGerichtAuswaehlen
  // Das Karma-Gericht wählt 1–3 repräsentative Erinnerungen automatisch aus.
  // Kriterien: Emotionale Intensität, Wiederholung ähnlicher Themen, Vielfalt.
  // ───────────────────────────────────────────────────────────────────────────

  /// Wählt 1–3 Erinnerungen für das Karma-Gericht aus.
  ///
  /// Die Auswahl bevorzugt:
  /// 1. Erinnerungen mit höchster emotionaler Intensität
  /// 2. Erinnerungen, deren Themen sich mit offenen Gedanken überschneiden
  /// 3. Vielfalt: nicht mehr als eine Erinnerung pro Typ
  static List<ErinnerungModel> erinnerungenFuerGerichtAuswaehlen(
    List<ErinnerungModel> alle,
    List<GedankeModel> alleGedanken,
  ) {
    if (alle.isEmpty) return [];

    // Noch nicht als Gericht-Erinnerung markierte Einträge verwenden
    final kandidaten = alle.where((e) => !e.istKarmaGericht).toList();
    if (kandidaten.isEmpty) return [];

    // Offene Gedanken-Themen sammeln für Relevanz-Boost
    final offeneThemen = alleGedanken
        .where((g) => !g.istAbgeschlossen)
        .expand((g) => g.ausloesende_themen)
        .toSet();

    // Bewertungsfunktion: Intensität + Bonus für thematische Übereinstimmung
    double bewertung(ErinnerungModel e) {
      var score = e.emotionaleIntensitaet * 10.0;
      // Bonus wenn Beteiligte mit offenen Gedanken-Themen übereinstimmen
      for (final beteiligter in e.beteiligte) {
        if (offeneThemen.contains(beteiligter.toLowerCase())) {
          score += 2.0;
        }
      }
      return score;
    }

    // Kandidaten nach Bewertung sortieren (höchste zuerst)
    kandidaten.sort((a, b) => bewertung(b).compareTo(bewertung(a)));

    // Maximal 3 Erinnerungen, mit Typ-Diversität
    final ausgewaehlte = <ErinnerungModel>[];
    final verwendeteTypen = <ErinnerungsTyp>{};

    for (final erinnerung in kandidaten) {
      if (ausgewaehlte.length >= 3) break;
      // Typ-Diversität: Je Typ maximal eine Erinnerung bevorzugen
      if (!verwendeteTypen.contains(erinnerung.typ) ||
          ausgewaehlte.length < 2) {
        ausgewaehlte.add(erinnerung);
        verwendeteTypen.add(erinnerung.typ);
      }
    }

    // Mindestens eine Erinnerung sicherstellen
    if (ausgewaehlte.isEmpty && kandidaten.isNotEmpty) {
      ausgewaehlte.add(kandidaten.first);
    }

    return ausgewaehlte;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // mitgenommeneGedankenBestimmen
  // Bestimmt, welche Gedanken ins nächste Leben mitgetragen werden.
  // Offene (ungelöste) Gedanken werden bevorzugt mitgenommen.
  // Abgeschlossene Gedanken werden als Weisheit umgewandelt.
  // ───────────────────────────────────────────────────────────────────────────

  /// Bestimmt die Gedanken, die aus dem Karma-Gericht ins nächste Leben mitgehen.
  ///
  /// Regeln:
  /// - Offene, nicht abgeschlossene Gedanken werden fast immer mitgenommen
  /// - Abgeschlossene Gedanken werden zu Weisheits-Fragmenten umgewandelt
  /// - Giftige Gedanken haben 30 % höhere Übernahmewahrscheinlichkeit
  /// - Maximale Anzahl: 5 Gedanken werden mitgenommen
  static List<GedankeModel> mitgenommeneGedankenBestimmen(
    List<GedankeModel> alle,
    List<ErinnerungModel> ausgewaehlteErinnerungen,
  ) {
    if (alle.isEmpty) return [];

    // Themen der ausgewählten Gericht-Erinnerungen als Referenz
    final gerichtThemen = ausgewaehlteErinnerungen
        .expand((e) => e.beteiligte)
        .map((s) => s.toLowerCase())
        .toSet();

    final mitgenommen = <GedankeModel>[];
    final zufall = Random();

    for (final gedanke in alle) {
      // Abgeschlossene Gedanken werden nicht mitgenommen
      if (gedanke.istAbgeschlossen) continue;
      if (mitgenommen.length >= 5) break;

      // Basiswahrscheinlichkeit abhängig vom Typ
      double wahrscheinlichkeit;
      switch (gedanke.typ) {
        case GedankenTyp.trauma:
          // Traumata kleben hartnäckig
          wahrscheinlichkeit = 0.85;
        case GedankenTyp.angst:
          wahrscheinlichkeit = 0.75;
        case GedankenTyp.indoktrination:
          wahrscheinlichkeit = 0.60;
        case GedankenTyp.wunsch:
          wahrscheinlichkeit = 0.55;
        case GedankenTyp.ueberzeugung:
          wahrscheinlichkeit = 0.50;
        case GedankenTyp.erinnerung:
          wahrscheinlichkeit = 0.40;
        case GedankenTyp.weisheit:
          // Gewonnene Weisheiten werden häufig mitgenommen
          wahrscheinlichkeit = 0.70;
        case GedankenTyp.geerbterGedanke:
          // Geerbt und noch nicht aufgelöst: hohe Chance
          wahrscheinlichkeit = 0.80;
      }

      // Bonus für giftige Gedanken (schwerer loszulassen)
      if (gedanke.istGiftig) wahrscheinlichkeit = (wahrscheinlichkeit + 0.30).clamp(0.0, 1.0);

      // Bonus wenn Gedanke mit Gericht-Themen übereinstimmt
      final hatThemenMatch = gedanke.ausloesende_themen
          .any((t) => gerichtThemen.contains(t.toLowerCase()));
      if (hatThemenMatch) wahrscheinlichkeit = (wahrscheinlichkeit + 0.15).clamp(0.0, 1.0);

      // Würfeln ob mitgenommen
      if (zufall.nextDouble() < wahrscheinlichkeit) {
        mitgenommen.add(gedanke.copyWith(wirdMitgenommen: true));
      }
    }

    return mitgenommen;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // entscheidungsImpactBerechnen
  // Berechnet den tatsächlichen Karma-Impact einer Entscheidung unter
  // Berücksichtigung von Phasen-Multiplikator und den 14 Systemmodifikatoren.
  // ───────────────────────────────────────────────────────────────────────────

  /// Berechnet den Karma-Impact einer gewählten Option.
  ///
  /// Modifikatoren:
  /// - [zeitgeistModifikator]: Zeitgeist des Zeitalters (0.5–1.5)
  /// - [indoktrinationsLevel]: Wie stark das Individuum indoktriniert ist (0.0–1.0)
  /// - [gruppenZwangLevel]: Sozialer Druck durch Gruppe (0.0–1.0)
  ///
  /// Hohe Indoktrination und Gruppenzwang dämpfen die Karma-Wirkung,
  /// da freier Wille eingeschränkt ist.
  static Map<KarmaDimension, double> entscheidungsImpactBerechnen(
    EntscheidungsOption option,
    ZyklusModel zyklus,
    double zeitgeistModifikator,
    double indoktrinationsLevel,
    double gruppenZwangLevel,
  ) {
    // Phasen-Karma-Multiplikator
    final phasenMultiplikator = zyklus.aktuellePhase.karmaMultiplikator;

    // Freiheitsfaktor: Je mehr freier Wille, desto stärker die Karma-Wirkung
    // Indoktrination und Gruppenzwang reduzieren die Eigenverantwortung
    final freiheitsFaktor = 1.0 -
        (indoktrinationsLevel * 0.30) -
        (gruppenZwangLevel * 0.20);
    final begrenzteFreiheit = freiheitsFaktor.clamp(0.3, 1.0);

    // Gesamtmultiplikator
    final gesamtMultiplikator = phasenMultiplikator *
        zeitgeistModifikator.clamp(0.5, 1.5) *
        begrenzteFreiheit;

    // Impact pro Dimension berechnen
    final result = <KarmaDimension, double>{};
    for (final eintrag in option.karmaAuswirkung.entries) {
      result[eintrag.key] = eintrag.value * gesamtMultiplikator;
    }

    return result;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // echoEntscheidungGenerieren
  // Erzeugt eine Echo-Entscheidung: Eine frühere Entscheidungssituation
  // kehrt in veränderter Form zurück und gibt dem Spieler eine zweite Chance.
  // ───────────────────────────────────────────────────────────────────────────

  /// Generiert eine Echo-Entscheidung aus vergangenen Entscheidungen.
  ///
  /// Eine Echo-Entscheidung wiederholt eine signifikante frühere Situation
  /// in einem neuen Kontext. Nur Entscheidungen, die bereits getroffen wurden,
  /// können ein Echo erzeugen. Das Echo erscheint frühestens 5 Jahre nach
  /// der Originalentscheidung.
  ///
  /// Gibt [null] zurück, wenn keine geeignete Entscheidung gefunden wurde.
  static EntscheidungModel? echoEntscheidungGenerieren(
    List<EntscheidungModel> vergangeneEntscheidungen,
    int aktuellesAlter,
  ) {
    // Nur bereits getroffene, nicht-triviale Entscheidungen berücksichtigen
    final kandidaten = vergangeneEntscheidungen
        .where((e) =>
            e.istGetroffen &&
            !e.istMikroEntscheidung &&
            e.systemEinfluesse.values.any((v) => v > 0.3))
        .toList();

    if (kandidaten.isEmpty) return null;

    // Zufällige Auswahl – in der vollen Implementierung würde hier
    // die thematische Passung zum aktuellen Alter berücksichtigt
    final zufall = Random();
    final original = kandidaten[zufall.nextInt(kandidaten.length)];

    // Echo-Entscheidung erstellen: Gleiche Optionen, neuer Kontext
    return EntscheidungModel(
      id: 'echo_${original.id}_alter_$aktuellesAlter',
      frage: 'Ein Echo der Vergangenheit: ${original.frage}',
      kontext:
          'Diese Situation erinnert dich an etwas aus deiner Vergangenheit. '
          'Wieder stehst du vor derselben Wahl – doch du bist nicht mehr '
          'dieselbe Person.',
      optionen: original.optionen,
      gewaehltOptionIndex: null,
      istMikroEntscheidung: false,
      hatParallelvorschau: false,
      systemEinfluesse: original.systemEinfluesse,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // wetterBerechnen
  // Berechnet das Emotions-Wetter aus dem aktuellen Spielzustand.
  // Kombiniert Karma-Profil mit direkten Emotions-Werten.
  // ───────────────────────────────────────────────────────────────────────────

  /// Berechnet das Emotions-Wetter aus Karma-Profil und aktuellen Werten.
  ///
  /// Alle Eingabewerte für [stress], [glueck], [liebe] und [spiritualitaet]
  /// liegen im Bereich 0.0–1.0.
  ///
  /// Das Karma-Profil verstärkt oder dämpft das Wetter:
  /// - Positive Karma-Werte boost Glück und Liebe
  /// - Negative Karma-Werte boost Stress
  static EmotionsWetterModel wetterBerechnen(
    KarmaProfilModel karma,
    double stress,
    double glueck,
    double liebe,
    double spiritualitaet,
  ) {
    // Karma-Einfluss normalisieren (von [-100,+100] auf [-0.3,+0.3])
    final karmaDurchschnitt = karma.durchschnitt;
    final karmaEinfluss = (karmaDurchschnitt / 100.0) * 0.3;

    // Karma-justierte Basiswerte
    final adjustiertesGlueck = (glueck + karmaEinfluss).clamp(0.0, 1.0);
    final adjustierterStress = (stress - karmaEinfluss).clamp(0.0, 1.0);

    // Liebe wird durch Karma-Dimension "liebe" beeinflusst
    final liebeBoost = (karma.liebe / 100.0) * 0.2;
    final adjustierteLiebe = (liebe + liebeBoost).clamp(0.0, 1.0);

    // Spiritualität wird durch Weisheit-Dimension beeinflusst
    final weisheitsBoost = (karma.weisheit / 100.0) * 0.15;
    final adjustierteSpiritualitaet =
        (spiritualitaet + weisheitsBoost).clamp(0.0, 1.0);

    return EmotionsWetterModel.vonEmotion(
      glueck: adjustiertesGlueck,
      stress: adjustierterStress,
      liebe: adjustierteLiebe,
      spiritualitaet: adjustierteSpiritualitaet,
    );
  }
}
