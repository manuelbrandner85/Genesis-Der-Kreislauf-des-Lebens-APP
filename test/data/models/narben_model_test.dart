// narben_model_test.dart
// Tests für das NarbenModel: Heilung, Verdrängung und Entscheidungs-Modifier.

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/narben_model.dart';

void main() {
  group('NarbenModel', () {
    // ─────────────────────────────────────────────────────────────────────────
    // Erstellung
    // ─────────────────────────────────────────────────────────────────────────

    test('erstellen() erzeugt frische Narbe mit korrekten Standardwerten', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Verlust eines Freundes',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.kindheit,
        trigger: ['verlust', 'freundschaft'],
        intensitaet: 0.7,
      );

      expect(narbe.id, isNotEmpty);
      expect(narbe.beschreibung, equals('Verlust eines Freundes'));
      expect(narbe.typ, equals(NarbenTyp.emotional));
      expect(narbe.status, equals(NarbenStatus.frisch));
      expect(narbe.entstandenInPhase, equals(GamePhase.kindheit));
      expect(narbe.trigger, containsAll(['verlust', 'freundschaft']));
      expect(narbe.intensitaet, equals(0.7));
      expect(narbe.istVererbt, isFalse);
      expect(narbe.resultierendeStaerke, isNull);
    });

    test('erstellen() clämmt Intensität auf [0.0, 1.0]', () {
      final zuhoch = NarbenModel.erstellen(
        beschreibung: 'Test',
        typ: NarbenTyp.physisch,
        entstandenInPhase: GamePhase.erwachsen,
        intensitaet: 2.5,
      );
      final zuniedrig = NarbenModel.erstellen(
        beschreibung: 'Test',
        typ: NarbenTyp.physisch,
        entstandenInPhase: GamePhase.erwachsen,
        intensitaet: -0.5,
      );

      expect(zuhoch.intensitaet, equals(1.0));
      expect(zuniedrig.intensitaet, equals(0.0));
    });

    test('erstellen() erzeugt eindeutige IDs', () {
      final narbe1 = NarbenModel.erstellen(
        beschreibung: 'Test 1',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.jugend,
      );
      final narbe2 = NarbenModel.erstellen(
        beschreibung: 'Test 2',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.jugend,
      );

      expect(narbe1.id, isNot(equals(narbe2.id)));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Heilung
    // ─────────────────────────────────────────────────────────────────────────

    test('heilen() setzt Status auf geheilt und fügt Stärke hinzu', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Scham',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.jugend,
        intensitaet: 0.8,
      );

      final geheilt = narbe.heilen('Selbstakzeptanz als Stärke');

      expect(geheilt.status, equals(NarbenStatus.geheilt));
      expect(geheilt.resultierendeStaerke, equals('Selbstakzeptanz als Stärke'));
      expect(geheilt.intensitaet, equals(0.0));
    });

    test('geheilte Narbe ist Stärke wenn resultierendeStaerke gesetzt', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Test',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.kindheit,
      );
      final geheilt = narbe.heilen('Resilienz');

      expect(geheilt.istGeheilteStaerke, isTrue);
    });

    test('ungeheilte Narbe ist keine Stärke', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Test',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.kindheit,
      );

      expect(narbe.istGeheilteStaerke, isFalse);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Verdrängung
    // ─────────────────────────────────────────────────────────────────────────

    test('verdraengen() setzt Status auf verdraengt und erhöht Intensität', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Trauma',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.kindheit,
        intensitaet: 0.5,
      );

      final verdraengt = narbe.verdraengen();

      expect(verdraengt.status, equals(NarbenStatus.verdraengt));
      expect(verdraengt.intensitaet, greaterThan(0.5));
    });

    test('verdraengen() clämmt Intensität auf 1.0', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Schweres Trauma',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.kindheit,
        intensitaet: 0.9,
      );

      final verdraengt = narbe.verdraengen();
      expect(verdraengt.intensitaet, lessThanOrEqualTo(1.0));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Aktiv-Status
    // ─────────────────────────────────────────────────────────────────────────

    test('frische Narbe ist aktiv', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Test',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.kindheit,
      );

      expect(narbe.istAktiv, isTrue);
    });

    test('geheilte Narbe ist nicht aktiv', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Test',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.kindheit,
      ).heilen('Stärke');

      expect(narbe.istAktiv, isFalse);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Entscheidungs-Modifier
    // ─────────────────────────────────────────────────────────────────────────

    test('frische Narbe hat negativen Entscheidungs-Modifier', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Test',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.kindheit,
        intensitaet: 0.6,
      );

      expect(narbe.entscheidungsModifier, lessThan(0.0));
    });

    test('geheilte Narbe hat positiven Entscheidungs-Modifier (Bonus)', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Test',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.kindheit,
      ).heilen('Stärke');

      expect(narbe.entscheidungsModifier, greaterThan(0.0));
    });

    test('verdrängte Narbe hat stark negativen Modifier', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Test',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.kindheit,
        intensitaet: 0.7,
      ).verdraengen();

      expect(narbe.entscheidungsModifier, lessThan(-0.5));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // JSON-Serialisierung
    // ─────────────────────────────────────────────────────────────────────────

    test('toJson() und fromJson() sind invers', () {
      final original = NarbenModel.erstellen(
        beschreibung: 'Verlust der Mutter',
        typ: NarbenTyp.emotional,
        entstandenInPhase: GamePhase.kindheit,
        trigger: ['mutter', 'verlust', 'familie'],
        intensitaet: 0.85,
        istVererbt: true,
        heilungsWeg: 'Therapie',
      );

      final json = original.toJson();
      final wiederhergestellt = NarbenModel.fromJson(json);

      expect(wiederhergestellt.id, equals(original.id));
      expect(wiederhergestellt.beschreibung, equals(original.beschreibung));
      expect(wiederhergestellt.typ, equals(original.typ));
      expect(wiederhergestellt.status, equals(original.status));
      expect(wiederhergestellt.intensitaet, closeTo(original.intensitaet, 0.001));
      expect(wiederhergestellt.istVererbt, equals(original.istVererbt));
      expect(wiederhergestellt.heilungsWeg, equals(original.heilungsWeg));
      expect(wiederhergestellt.trigger, equals(original.trigger));
    });

    test('toJson() enthält alle Pflichtfelder', () {
      final narbe = NarbenModel.erstellen(
        beschreibung: 'Test',
        typ: NarbenTyp.physisch,
        entstandenInPhase: GamePhase.erwachsen,
      );

      final json = narbe.toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('beschreibung'), isTrue);
      expect(json.containsKey('typ'), isTrue);
      expect(json.containsKey('status'), isTrue);
      expect(json.containsKey('intensitaet'), isTrue);
    });
  });
}
