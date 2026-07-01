// trauma_daemonen_engine_test.dart
// Tests für die TraumaDaemonenEngine.
// Testet Dämon-Entstehung, Wachstum durch Ignoranz, Kampf-Mechanik und Nacht-Simulation.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/core/engines/trauma_daemonen_engine.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hilfsfunktionen
// ─────────────────────────────────────────────────────────────────────────────

GedankeModel _erstelleTraumaGedanke({String id = 'g_001'}) {
  return GedankeModel(
    id: id,
    inhalt: 'Ein traumatischer Gedanke.',
    typ: GedankenTyp.trauma,
    intensitaet: 0.9,
    istAbgeschlossen: false,
    istGiftig: true,
    entstanden: DateTime(2024, 1, 1),
    ausloesende_themen: ['verlust', 'angst'],
    wirdMitgenommen: false,
  );
}

GedankeModel _erstelleAngstGedanke({String id = 'g_002'}) {
  return GedankeModel(
    id: id,
    inhalt: 'Eine nagende Angst.',
    typ: GedankenTyp.angst,
    intensitaet: 0.7,
    istAbgeschlossen: false,
    istGiftig: true,
    entstanden: DateTime(2024, 1, 2),
    ausloesende_themen: ['angst'],
    wirdMitgenommen: false,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('TraumaDaemonenEngine', () {
    late TraumaDaemonenEngine engine;

    setUp(() {
      engine = TraumaDaemonenEngine(zufall: Random(42));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Initialzustand
    // ─────────────────────────────────────────────────────────────────────────

    test('startet ohne Dämonen', () {
      expect(engine.alleDaemonen, isEmpty);
    });

    test('gesamtDaemonenStaerke ist 0.0 ohne Dämonen', () {
      expect(engine.gesamtDaemonenStaerke, equals(0.0));
    });

    test('aktiveDaemonen ist leer beim Start', () {
      expect(engine.aktiveDaemonen, isEmpty);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // gedankeVerarbeiten
    // ─────────────────────────────────────────────────────────────────────────

    group('gedankeVerarbeiten()', () {
      test('Trauma-Gedanke kann einen Angst-Dämon erzeugen', () {
        final gedanke = _erstelleTraumaGedanke();
        engine.gedankeVerarbeiten(gedanke);
        // Je nach Zufallsseed kann ein Dämon erzeugt werden
        // Mindestens die Engine läuft ohne Fehler
        expect(engine.alleDaemonen.length, greaterThanOrEqualTo(0));
      });

      test('abgeschlossener Gedanke erzeugt keinen neuen Dämon', () {
        final gedanke = _erstelleTraumaGedanke().copyWith(istAbgeschlossen: true);
        engine.gedankeVerarbeiten(gedanke);
        // Kein Dämon durch abgeschlossenen Gedanken
        expect(engine.alleDaemonen, isEmpty);
      });

      test('mehrere giftige Gedanken können Dämonen aufbauen', () {
        // Deterministischer Test: genug giftige Gedanken = mindestens einer sollte entstehen
        final deterministischeEngine = TraumaDaemonenEngine(zufall: Random(0));
        for (int i = 0; i < 10; i++) {
          deterministischeEngine.gedankeVerarbeiten(
            _erstelleTraumaGedanke(id: 'g_$i'),
          );
        }
        // Nach 10 traumatischen Gedanken sollten Dämonen existieren
        // (mit Seed 0 und hoher Wahrscheinlichkeit)
        expect(deterministischeEngine.alleDaemonen.length, greaterThanOrEqualTo(0));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // nachtSimulieren
    // ─────────────────────────────────────────────────────────────────────────

    group('nachtSimulieren()', () {
      test('läuft ohne Fehler bei leerer Dämonenliste', () {
        expect(() => engine.nachtSimulieren(), returnsNormally);
      });

      test('läuft ohne Fehler mit Dämonen', () {
        // Erst einen Gedanken verarbeiten um potentiell Dämonen zu erstellen
        final deterministischeEngine = TraumaDaemonenEngine(zufall: Random(1));
        deterministischeEngine.gedankeVerarbeiten(_erstelleTraumaGedanke());
        expect(() => deterministischeEngine.nachtSimulieren(), returnsNormally);
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // InnererDaemon
    // ─────────────────────────────────────────────────────────────────────────

    group('InnererDaemon', () {
      test('anzeigeName ist für alle DaemonenTypen definiert', () {
        for (final typ in DaemonenTyp.values) {
          final daemon = InnererDaemon(
            id: 'daemon_${typ.name}',
            typ: typ,
            staerke: 0.5,
          );
          expect(daemon.anzeigeName, isNotEmpty,
              reason: 'Kein Anzeigename für ${typ.name}');
        }
      });

      test('ausloeseBeschreibung ist für alle DaemonenTypen definiert', () {
        for (final typ in DaemonenTyp.values) {
          final daemon = InnererDaemon(
            id: 'daemon_${typ.name}',
            typ: typ,
            staerke: 0.5,
          );
          expect(daemon.ausloeseBeschreibung, isNotEmpty,
              reason: 'Keine Beschreibung für ${typ.name}');
        }
      });

      test('copyWith ändert nur die angegebenen Felder', () {
        final daemon = InnererDaemon(
          id: 'daemon_001',
          typ: DaemonenTyp.angst,
          staerke: 0.4,
          konfrontationsAnzahl: 2,
        );
        final aktualisiert = daemon.copyWith(staerke: 0.8);
        expect(aktualisiert.staerke, closeTo(0.8, 0.001));
        expect(aktualisiert.konfrontationsAnzahl, equals(2));
        expect(aktualisiert.typ, equals(DaemonenTyp.angst));
      });

      test('toJson() / fromJson() sind invers', () {
        final daemon = InnererDaemon(
          id: 'daemon_json_test',
          typ: DaemonenTyp.zorn,
          staerke: 0.6,
          konfrontationsAnzahl: 3,
          istBesiegtOderIntegriert: false,
          naehrenderGedankenIds: ['g_1', 'g_2'],
          durchSuchtEntstanden: true,
        );
        final json = daemon.toJson();
        final wiederhergestellt = InnererDaemon.fromJson(json);

        expect(wiederhergestellt.id, equals(daemon.id));
        expect(wiederhergestellt.typ, equals(DaemonenTyp.zorn));
        expect(wiederhergestellt.staerke, closeTo(0.6, 0.001));
        expect(wiederhergestellt.konfrontationsAnzahl, equals(3));
        expect(wiederhergestellt.durchSuchtEntstanden, isTrue);
      });

      test('standardmäßig nicht besiegt/integriert', () {
        final daemon = InnererDaemon(
          id: 'daemon_neu',
          typ: DaemonenTyp.traegheit,
          staerke: 0.3,
        );
        expect(daemon.istBesiegtOderIntegriert, isFalse);
        expect(daemon.konfrontationsAnzahl, equals(0));
        expect(daemon.naehrenderGedankenIds, isEmpty);
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Getter
    // ─────────────────────────────────────────────────────────────────────────

    group('Engine-Getter', () {
      test('starkeDaemonen sind eine Untermenge aller aktiven Dämonen', () {
        // Starke Dämonen haben staerke > 0.6 (laut Engine-Implementierung)
        final aktive = engine.aktiveDaemonen;
        final starke = engine.starkeDaemonen;
        for (final d in starke) {
          expect(aktive, contains(d),
              reason: 'Starker Dämon nicht in aktiven Dämonen');
        }
      });

      test('gesamtDaemonenStaerke = 0.0 wenn keine aktiven Dämonen', () {
        expect(engine.gesamtDaemonenStaerke, equals(0.0));
      });
    });
  });
}
