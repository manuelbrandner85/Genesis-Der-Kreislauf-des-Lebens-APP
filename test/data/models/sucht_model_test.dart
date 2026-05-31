// sucht_model_test.dart
// Tests für das SuchtModel: Progression, Wahrnehmungsverzerrung und Überwindung.

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/sucht_model.dart';

void main() {
  group('SuchtModel', () {
    // ─────────────────────────────────────────────────────────────────────────
    // Erstellung
    // ─────────────────────────────────────────────────────────────────────────

    test('erstellen() erzeugt Erst-Kontakt mit minimaler Stärke', () {
      final sucht = SuchtModel.erstellen(
        typ: SuchtTyp.substanz,
        entstandenInPhase: GamePhase.jugend,
      );

      expect(sucht.id, isNotEmpty);
      expect(sucht.typ, equals(SuchtTyp.substanz));
      expect(sucht.phase, equals(SuchtPhase.erstKontakt));
      expect(sucht.staerke, closeTo(0.1, 0.01));
      expect(sucht.wahrnehmungsVerzerrung, lessThan(0.2));
      expect(sucht.entzugsFortschritt, equals(0.0));
      expect(sucht.willenskraftBonus, equals(0.0));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Progression
    // ─────────────────────────────────────────────────────────────────────────

    test('verstaerken() erhöht die Stärke', () {
      final sucht = SuchtModel.erstellen(
        typ: SuchtTyp.macht,
        entstandenInPhase: GamePhase.erwachsen,
      );

      final verstaerkt = sucht.verstaerken(0.2);
      expect(verstaerkt.staerke, greaterThan(sucht.staerke));
    });

    test('verstaerken() wechselt Phase zu gewohnheit bei Stärke >= 0.3', () {
      final sucht = SuchtModel.erstellen(
        typ: SuchtTyp.arbeit,
        entstandenInPhase: GamePhase.erwachsen,
      );

      final verstaerkt = sucht.verstaerken(0.25); // 0.1 + 0.25 = 0.35
      expect(verstaerkt.phase, equals(SuchtPhase.gewohnheit));
    });

    test('verstaerken() wechselt Phase zu abhaengig bei Stärke >= 0.7', () {
      final sucht = SuchtModel.erstellen(
        typ: SuchtTyp.ruhm,
        entstandenInPhase: GamePhase.erwachsen,
      );

      final verstaerkt = sucht.verstaerken(0.65); // 0.1 + 0.65 = 0.75
      expect(verstaerkt.phase, equals(SuchtPhase.abhaengig));
    });

    test('verstaerken() clämmt Stärke auf maximal 1.0', () {
      final sucht = SuchtModel.erstellen(
        typ: SuchtTyp.substanz,
        entstandenInPhase: GamePhase.jugend,
      );

      final verstaerkt = sucht.verstaerken(10.0); // Übertrieben
      expect(verstaerkt.staerke, equals(1.0));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Wahrnehmungsverzerrung
    // ─────────────────────────────────────────────────────────────────────────

    test('abhängige Sucht verzerrt Wahrnehmung wenn Stärke > 0.3', () {
      var sucht = SuchtModel.erstellen(
        typ: SuchtTyp.liebe,
        entstandenInPhase: GamePhase.erwachsen,
      );
      sucht = sucht.verstaerken(0.65); // abhaengig

      expect(sucht.verzerrtWahrnehmung, isTrue);
    });

    test('blockierteOptionen ist leer bei gesunder Sucht', () {
      final sucht = SuchtModel.erstellen(
        typ: SuchtTyp.substanz,
        entstandenInPhase: GamePhase.jugend,
      );

      expect(sucht.blockierteOptionen, isEmpty);
    });

    test('blockierteOptionen enthält macht-spezifische Optionen bei Macht-Sucht', () {
      var sucht = SuchtModel.erstellen(
        typ: SuchtTyp.macht,
        entstandenInPhase: GamePhase.erwachsen,
      );
      sucht = sucht.verstaerken(0.65); // abhaengig mit Verzerrung

      expect(sucht.blockierteOptionen, contains('teilen'));
      expect(sucht.blockierteOptionen, contains('zuruecktreten'));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Entzug
    // ─────────────────────────────────────────────────────────────────────────

    test('entzugBeginnen() wechselt Phase zu entzug', () {
      final sucht = SuchtModel.erstellen(
        typ: SuchtTyp.substanz,
        entstandenInPhase: GamePhase.jugend,
      );

      final imEntzug = sucht.entzugBeginnen();
      expect(imEntzug.phase, equals(SuchtPhase.entzug));
      expect(imEntzug.istImEntzug, isTrue);
    });

    test('entzugFortschreiten() erhöht Fortschritt und reduziert Stärke', () {
      var sucht = SuchtModel.erstellen(
        typ: SuchtTyp.substanz,
        entstandenInPhase: GamePhase.jugend,
      ).verstaerken(0.5).entzugBeginnen();

      final fortschritt = sucht.entzugFortschreiten(0.3);
      expect(fortschritt.entzugsFortschritt, closeTo(0.3, 0.01));
      expect(fortschritt.staerke, lessThan(sucht.staerke));
    });

    test('entzugFortschreiten() bei 1.0 = vollständig überwunden', () {
      var sucht = SuchtModel.erstellen(
        typ: SuchtTyp.substanz,
        entstandenInPhase: GamePhase.jugend,
      ).verstaerken(0.5).entzugBeginnen();

      final ueberwunden = sucht.entzugFortschreiten(1.0);
      expect(ueberwunden.phase, equals(SuchtPhase.ueberwunden));
      expect(ueberwunden.istUeberwunden, isTrue);
      expect(ueberwunden.staerke, equals(0.0));
      expect(ueberwunden.wahrnehmungsVerzerrung, equals(0.0));
      expect(ueberwunden.willenskraftBonus, greaterThan(0.0));
    });

    test('überwundene Sucht gibt Willenskraft-Bonus', () {
      var sucht = SuchtModel.erstellen(
        typ: SuchtTyp.arbeit,
        entstandenInPhase: GamePhase.erwachsen,
      ).entzugBeginnen().entzugFortschreiten(1.0);

      expect(sucht.willenskraftBonus, closeTo(0.25, 0.01));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // JSON-Serialisierung
    // ─────────────────────────────────────────────────────────────────────────

    test('toJson() und fromJson() sind invers', () {
      final original = SuchtModel.erstellen(
        typ: SuchtTyp.gluecksspiel,
        entstandenInPhase: GamePhase.erwachsen,
        ausloeserNarbenId: 'narbe_test_123',
      ).verstaerken(0.4);

      final json = original.toJson();
      final wiederhergestellt = SuchtModel.fromJson(json);

      expect(wiederhergestellt.id, equals(original.id));
      expect(wiederhergestellt.typ, equals(original.typ));
      expect(wiederhergestellt.phase, equals(original.phase));
      expect(wiederhergestellt.staerke, closeTo(original.staerke, 0.001));
      expect(wiederhergestellt.ausloeserNarbenId, equals(original.ausloeserNarbenId));
      expect(wiederhergestellt.entstandenInPhase, equals(original.entstandenInPhase));
    });

    test('verschiedene SuchtTypen haben unterschiedliche blockierte Optionen', () {
      final suchtTypen = [
        SuchtTyp.macht,
        SuchtTyp.ruhm,
        SuchtTyp.liebe,
        SuchtTyp.arbeit,
        SuchtTyp.gluecksspiel,
        SuchtTyp.ideologie,
      ];

      final alleBlockierungen = <Set<String>>[];
      for (final typ in suchtTypen) {
        var sucht = SuchtModel.erstellen(
          typ: typ,
          entstandenInPhase: GamePhase.erwachsen,
        ).verstaerken(0.65);
        alleBlockierungen.add(sucht.blockierteOptionen.toSet());
      }

      // Überprüfen, dass verschiedene Typen unterschiedliche Blockierungen haben
      // (nicht alle Sets sind identisch)
      final allGleich = alleBlockierungen.every(
        (s) => s.containsAll(alleBlockierungen.first),
      );
      expect(allGleich, isFalse);
    });
  });
}
