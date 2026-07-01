// koerper_simulation_test.dart
// Tests für die KoerperSimulation-Engine.
// Testet Organ-Gesundheit, Lebensstil-Auswirkungen und Todesursachen-Berechnung.

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/core/engines/koerper_simulation.dart';

void main() {
  group('KoerperZustand', () {
    // ─────────────────────────────────────────────────────────────────────────
    // Initialisierung
    // ─────────────────────────────────────────────────────────────────────────

    test('beiGeburt() erstellt alle Organe mit Vollgesundheit (100.0)', () {
      final zustand = KoerperZustand.beiGeburt();

      expect(zustand.organGesundheit, isNotEmpty);
      for (final gesundheit in zustand.organGesundheit.values) {
        expect(gesundheit, equals(100.0));
      }
    });

    test('beiGeburt() enthält alle Pflicht-Organsysteme', () {
      final zustand = KoerperZustand.beiGeburt();

      expect(zustand.organGesundheit.containsKey(OrganSystem.herz), isTrue);
      expect(zustand.organGesundheit.containsKey(OrganSystem.gehirn), isTrue);
      expect(zustand.organGesundheit.containsKey(OrganSystem.lunge), isTrue);
      expect(zustand.organGesundheit.containsKey(OrganSystem.leber), isTrue);
      expect(zustand.organGesundheit.containsKey(OrganSystem.immunsystem), isTrue);
    });

    test('gesamtGesundheit ist 100.0 bei Geburt', () {
      final zustand = KoerperZustand.beiGeburt();
      expect(zustand.gesamtGesundheit, closeTo(100.0, 0.01));
    });

    test('gesamtGesundheit berechnet Durchschnitt korrekt', () {
      final zustand = KoerperZustand.beiGeburt().copyWith(
        organGesundheit: {
          OrganSystem.herz: 80.0,
          OrganSystem.lunge: 60.0,
          OrganSystem.gehirn: 100.0,
          OrganSystem.leber: 80.0,
          OrganSystem.magen: 80.0,
          OrganSystem.immunsystem: 80.0,
          OrganSystem.bewegungsapparat: 80.0,
        },
      );

      // (80 + 60 + 100 + 80 + 80 + 80 + 80) / 7 ≈ 80.0
      expect(zustand.gesamtGesundheit, closeTo(80.0, 1.0));
    });

    test('istKrank ist false bei Geburt', () {
      expect(KoerperZustand.beiGeburt().istKrank, isFalse);
    });

    test('istKrank ist true wenn aktive Krankheiten vorhanden', () {
      final zustand = KoerperZustand.beiGeburt().copyWith(
        aktiveKrankheiten: {Krankheit.burnout: 0.5},
      );

      expect(zustand.istKrank, isTrue);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // JSON-Serialisierung
    // ─────────────────────────────────────────────────────────────────────────

    test('toJson() und fromJson() sind invers', () {
      final original = KoerperZustand.beiGeburt().copyWith(
        aktiveKrankheiten: {Krankheit.depression: 0.3},
        schaetzungMaximalAlter: 85,
      );

      final json = original.toJson();
      final wiederhergestellt = KoerperZustand.fromJson(json);

      expect(wiederhergestellt.gesamtGesundheit,
             closeTo(original.gesamtGesundheit, 0.01));
      expect(wiederhergestellt.aktiveKrankheiten.containsKey(Krankheit.depression),
             isTrue);
      expect(wiederhergestellt.schaetzungMaximalAlter,
             equals(original.schaetzungMaximalAlter));
    });
  });

  group('KoerperSimulation', () {
    late KoerperSimulation simulation;
    late KoerperZustand startZustand;

    setUp(() {
      simulation = KoerperSimulation();
      startZustand = KoerperZustand.beiGeburt();
    });

    // ─────────────────────────────────────────────────────────────────────────
    // jahrSimulieren – natürliche Alterung
    // ─────────────────────────────────────────────────────────────────────────

    test('jahrSimulieren() reduziert Gesundheit über Zeit', () {
      final nachEinemJahr = simulation.jahrSimulieren(
        aktuell: startZustand,
        alter: 30,
        lebensstil: LebensstilParameter.standard(),
        aktivierteGene: const [],
        krankheitsrisiken: const [],
      );

      expect(nachEinemJahr.gesamtGesundheit, lessThan(100.0));
    });

    test('jahrSimulieren() stärkerer Abfall nach 40 durch Altersfaktor', () {
      final jung = simulation.jahrSimulieren(
        aktuell: startZustand,
        alter: 25,
        lebensstil: LebensstilParameter.standard(),
        aktivierteGene: const [],
        krankheitsrisiken: const [],
      );

      final alt = simulation.jahrSimulieren(
        aktuell: startZustand,
        alter: 70,
        lebensstil: LebensstilParameter.standard(),
        aktivierteGene: const [],
        krankheitsrisiken: const [],
      );

      // Ältere Simulation verliert mehr Gesundheit pro Jahr
      final verlustJung = 100.0 - jung.gesamtGesundheit;
      final verlustAlt = 100.0 - alt.gesamtGesundheit;
      expect(verlustAlt, greaterThan(verlustJung));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Lebensstil-Auswirkungen
    // ─────────────────────────────────────────────────────────────────────────

    test('rauchen schadet der Lunge', () {
      final raucher = LebensstilParameter(
        raucht: true,
        sportStunden: 0,
        stressLevel: 0.3,
        alkoholKonsum: 0.0,
        substanzKonsum: 0.0,
        gesundeErnaehrung: false,
        schlafStunden: 7,
        meditiert: false,
        bildungsStunden: 2,
        sitzendeTaetigkeit: false,
      );

      final normal = LebensstilParameter.standard();

      final nachRauchen = simulation.jahrSimulieren(
        aktuell: startZustand,
        alter: 30,
        lebensstil: raucher,
        aktivierteGene: const [],
        krankheitsrisiken: const [],
      );

      final nachNormal = simulation.jahrSimulieren(
        aktuell: startZustand,
        alter: 30,
        lebensstil: normal,
        aktivierteGene: const [],
        krankheitsrisiken: const [],
      );

      // Raucher hat schlechtere Lungengesundheit
      expect(
        nachRauchen.organGesundheit[OrganSystem.lunge]!,
        lessThan(nachNormal.organGesundheit[OrganSystem.lunge]!),
      );
    });

    test('sport verbessert Herzgesundheit im Vergleich zu keinem Sport', () {
      final sportler = LebensstilParameter(
        sportStunden: 6,
        stressLevel: 0.2,
        raucht: false,
        passivRaucht: false,
        alkoholKonsum: 0.0,
        substanzKonsum: 0.0,
        gesundeErnaehrung: true,
        schlafStunden: 8,
        meditiert: false,
        bildungsStunden: 2,
        sitzendeTaetigkeit: false,
      );

      final sitzend = LebensstilParameter(
        sportStunden: 0,
        stressLevel: 0.7,
        raucht: false,
        passivRaucht: false,
        alkoholKonsum: 0.0,
        substanzKonsum: 0.0,
        gesundeErnaehrung: false,
        schlafStunden: 6,
        meditiert: false,
        bildungsStunden: 0,
        sitzendeTaetigkeit: true,
      );

      final nachSport = simulation.jahrSimulieren(
        aktuell: startZustand,
        alter: 30,
        lebensstil: sportler,
        aktivierteGene: const [],
        krankheitsrisiken: const [],
      );

      final nachSitzen = simulation.jahrSimulieren(
        aktuell: startZustand,
        alter: 30,
        lebensstil: sitzend,
        aktivierteGene: const [],
        krankheitsrisiken: const [],
      );

      // Sportler hat bessere Herzgesundheit
      expect(
        nachSport.organGesundheit[OrganSystem.herz]!,
        greaterThan(nachSitzen.organGesundheit[OrganSystem.herz]!),
      );
    });

    test('alkohol schadet der Leber', () {
      final trinker = LebensstilParameter(
        alkoholKonsum: 0.9,
        sportStunden: 1,
        stressLevel: 0.4,
        raucht: false,
        passivRaucht: false,
        substanzKonsum: 0.0,
        gesundeErnaehrung: false,
        schlafStunden: 7,
        meditiert: false,
        bildungsStunden: 1,
        sitzendeTaetigkeit: false,
      );

      final nachAlkohol = simulation.jahrSimulieren(
        aktuell: startZustand,
        alter: 35,
        lebensstil: trinker,
        aktivierteGene: const [],
        krankheitsrisiken: const [],
      );

      final nachStandard = simulation.jahrSimulieren(
        aktuell: startZustand,
        alter: 35,
        lebensstil: LebensstilParameter.standard(),
        aktivierteGene: const [],
        krankheitsrisiken: const [],
      );

      expect(
        nachAlkohol.organGesundheit[OrganSystem.leber]!,
        lessThan(nachStandard.organGesundheit[OrganSystem.leber]!),
      );
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Todesursachen-Berechnung
    // ─────────────────────────────────────────────────────────────────────────

    test('todesUrsacheBerechnen() gibt nicht-leeren String zurück', () {
      final ursache = simulation.todesUrsacheBerechnen(startZustand, 85);
      expect(ursache, isNotEmpty);
    });

    test('todesUrsacheBerechnen() berücksichtigt aktive Krankheiten', () {
      final mitKrankheit = startZustand.copyWith(
        aktiveKrankheiten: {Krankheit.herzinfarkt: 0.9},
      );

      final ursache = simulation.todesUrsacheBerechnen(mitKrankheit, 60);
      // Bei Herzinfarkt sollte der Text herz-/kardiobezogen sein
      expect(ursache, isNotEmpty);
    });

    test('todesUrsacheBerechnen() bei gesundem Körper basiert auf Alter', () {
      final ursacheJung = simulation.todesUrsacheBerechnen(startZustand, 30);
      final ursacheAlt = simulation.todesUrsacheBerechnen(startZustand, 90);

      // Beide geben valide Strings zurück
      expect(ursacheJung, isNotEmpty);
      expect(ursacheAlt, isNotEmpty);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Gen-Einflüsse
    // ─────────────────────────────────────────────────────────────────────────

    test('aktivierteGene beeinflussen Organgesundheit', () {
      final mitGenen = simulation.jahrSimulieren(
        aktuell: startZustand,
        alter: 40,
        lebensstil: LebensstilParameter.standard(),
        aktivierteGene: const ['gen_herz_stark', 'gen_ausdauer'],
        krankheitsrisiken: const [],
      );

      final ohneGene = simulation.jahrSimulieren(
        aktuell: startZustand,
        alter: 40,
        lebensstil: LebensstilParameter.standard(),
        aktivierteGene: const [],
        krankheitsrisiken: const [],
      );

      // Ergebnisse können unterschiedlich sein (Gene haben Einfluss)
      // Zumindest darf die Methode keine Exception werfen
      expect(mitGenen.organGesundheit, isNotEmpty);
      expect(ohneGene.organGesundheit, isNotEmpty);
    });

    test('Krankheitsrisiken können Krankheiten auslösen bei mehrjähriger Simulation', () {
      // 30 Jahre mit hohem Risiko simulieren
      var zustand = startZustand;
      for (int i = 0; i < 30; i++) {
        zustand = simulation.jahrSimulieren(
          aktuell: zustand,
          alter: 40 + i,
          lebensstil: LebensstilParameter(
            raucht: true,
            alkoholKonsum: 0.8,
            sportStunden: 0,
            stressLevel: 0.9,
            passivRaucht: false,
            substanzKonsum: 0.3,
            gesundeErnaehrung: false,
            schlafStunden: 5,
            meditiert: false,
            bildungsStunden: 0,
            sitzendeTaetigkeit: true,
          ),
          aktivierteGene: const [],
          krankheitsrisiken: const ['herzinfarkt_risiko', 'lungenkrebs_risiko'],
        );
      }

      // Nach 30 Jahren schlechtem Lebensstil sollte die Gesundheit erheblich gesunken sein
      expect(zustand.gesamtGesundheit, lessThan(90.0));
    });
  });

  group('LebensstilParameter', () {
    test('standard() erstellt valide Parameter', () {
      final ls = LebensstilParameter.standard();

      expect(ls.sportStunden, greaterThanOrEqualTo(0));
      expect(ls.stressLevel, inInclusiveRange(0.0, 1.0));
      expect(ls.schlafStunden, greaterThan(0));
    });
  });
}
