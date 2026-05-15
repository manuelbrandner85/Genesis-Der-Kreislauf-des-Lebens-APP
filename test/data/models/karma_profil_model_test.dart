// karma_profil_model_test.dart
// Tests für KarmaProfilModel: JSON-Serialisierung und Jenseitsreich-Berechnung.
// Testet alle fünf Jenseitsreiche anhand ihrer Grenzwerte.

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // Hilfsfunktion: Erstellt ein Profil mit einheitlichem Wert für alle Dimensionen
  // ───────────────────────────────────────────────────────────────────────────

  KarmaProfilModel gleichmaessigesProfil(double wert) => KarmaProfilModel(
        mitgefuehl: wert,
        ehrlichkeit: wert,
        mut: wert,
        grosszuegigkeit: wert,
        weisheit: wert,
        liebe: wert,
      );

  // ───────────────────────────────────────────────────────────────────────────
  // Serialisierungs-Tests
  // ───────────────────────────────────────────────────────────────────────────

  group('KarmaProfilModel Serialisierung', () {
    test('toJson() erzeugt korrektes Map mit allen sechs Dimensionen', () {
      const profil = KarmaProfilModel(
        mitgefuehl: 42.0,
        ehrlichkeit: -15.5,
        mut: 0.0,
        grosszuegigkeit: 100.0,
        weisheit: -100.0,
        liebe: 33.3,
      );

      final json = profil.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['mitgefuehl'], equals(42.0));
      expect(json['ehrlichkeit'], equals(-15.5));
      expect(json['mut'], equals(0.0));
      expect(json['grosszuegigkeit'], equals(100.0));
      expect(json['weisheit'], equals(-100.0));
      expect(json['liebe'], equals(33.3));

      // Keine zusätzlichen Felder im JSON
      expect(json.keys.length, equals(6));
    });

    test('fromJson() lädt korrekte Werte für alle Dimensionen', () {
      final json = <String, dynamic>{
        'mitgefuehl': 55.0,
        'ehrlichkeit': -22.5,
        'mut': 10.0,
        'grosszuegigkeit': -10.0,
        'weisheit': 75.5,
        'liebe': -75.5,
      };

      final profil = KarmaProfilModel.fromJson(json);

      expect(profil.mitgefuehl, equals(55.0));
      expect(profil.ehrlichkeit, equals(-22.5));
      expect(profil.mut, equals(10.0));
      expect(profil.grosszuegigkeit, equals(-10.0));
      expect(profil.weisheit, equals(75.5));
      expect(profil.liebe, equals(-75.5));
    });

    test('fromJson() konvertiert int-Werte korrekt zu double', () {
      // Hive speichert manchmal als int
      final json = <String, dynamic>{
        'mitgefuehl': 50,   // int statt double
        'ehrlichkeit': -30, // int statt double
        'mut': 0,
        'grosszuegigkeit': 100,
        'weisheit': -100,
        'liebe': 25,
      };

      final profil = KarmaProfilModel.fromJson(json);

      expect(profil.mitgefuehl, equals(50.0));
      expect(profil.ehrlichkeit, equals(-30.0));
      expect(profil.mut, equals(0.0));
    });

    test('Roundtrip toJson -> fromJson ist verlustfrei', () {
      const original = KarmaProfilModel(
        mitgefuehl: 12.345,
        ehrlichkeit: -67.890,
        mut: 0.001,
        grosszuegigkeit: -0.001,
        weisheit: 99.999,
        liebe: -99.999,
      );

      final json = original.toJson();
      final wiederhergestellt = KarmaProfilModel.fromJson(json);

      expect(wiederhergestellt.mitgefuehl, equals(original.mitgefuehl));
      expect(wiederhergestellt.ehrlichkeit, equals(original.ehrlichkeit));
      expect(wiederhergestellt.mut, equals(original.mut));
      expect(wiederhergestellt.grosszuegigkeit, equals(original.grosszuegigkeit));
      expect(wiederhergestellt.weisheit, equals(original.weisheit));
      expect(wiederhergestellt.liebe, equals(original.liebe));
    });

    test('neutral() Roundtrip ist korrekt', () {
      final neutral = KarmaProfilModel.neutral();
      final json = neutral.toJson();
      final wiederhergestellt = KarmaProfilModel.fromJson(json);

      expect(wiederhergestellt.durchschnitt, equals(0.0));
      expect(wiederhergestellt, equals(neutral));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Jenseitsreich-Tests
  // ───────────────────────────────────────────────────────────────────────────

  group('Karma Jenseitsreich', () {
    test('Alle 5 Reiche bei charakteristischen Werten korrekt bestimmt', () {
      // Elysium: Durchschnitt >= 60.0
      expect(
        gleichmaessigesProfil(70.0).jenseitsReichBerechnen(),
        equals(JenseitsReich.elysium),
        reason: 'Durchschnitt 70.0 sollte Elysium ergeben',
      );

      // Harmonia: Durchschnitt >= 20.0 und < 60.0
      expect(
        gleichmaessigesProfil(40.0).jenseitsReichBerechnen(),
        equals(JenseitsReich.harmonia),
        reason: 'Durchschnitt 40.0 sollte Harmonia ergeben',
      );

      // Limbus: -20.0 < Durchschnitt < 20.0
      expect(
        gleichmaessigesProfil(0.0).jenseitsReichBerechnen(),
        equals(JenseitsReich.limbus),
        reason: 'Durchschnitt 0.0 sollte Limbus ergeben',
      );

      // Shadowlands: Durchschnitt <= -20.0 und > -60.0
      expect(
        gleichmaessigesProfil(-40.0).jenseitsReichBerechnen(),
        equals(JenseitsReich.shadowlands),
        reason: 'Durchschnitt -40.0 sollte Shadowlands ergeben',
      );

      // Abyssus: Durchschnitt <= -60.0
      expect(
        gleichmaessigesProfil(-70.0).jenseitsReichBerechnen(),
        equals(JenseitsReich.abyssus),
        reason: 'Durchschnitt -70.0 sollte Abyssus ergeben',
      );
    });

    test('Grenzwert Elysium: exakt 60.0 → elysium', () {
      expect(
        gleichmaessigesProfil(60.0).jenseitsReichBerechnen(),
        equals(JenseitsReich.elysium),
      );
    });

    test('Grenzwert Harmonia: knapp unter 60.0 → harmonia', () {
      expect(
        gleichmaessigesProfil(59.99).jenseitsReichBerechnen(),
        equals(JenseitsReich.harmonia),
      );
    });

    test('Grenzwert Harmonia: exakt 20.0 → harmonia', () {
      expect(
        gleichmaessigesProfil(20.0).jenseitsReichBerechnen(),
        equals(JenseitsReich.harmonia),
      );
    });

    test('Grenzwert Limbus: knapp unter 20.0 → limbus', () {
      expect(
        gleichmaessigesProfil(19.99).jenseitsReichBerechnen(),
        equals(JenseitsReich.limbus),
      );
    });

    test('Grenzwert Limbus: knapp über -20.0 → limbus', () {
      expect(
        gleichmaessigesProfil(-19.99).jenseitsReichBerechnen(),
        equals(JenseitsReich.limbus),
      );
    });

    test('Grenzwert Shadowlands: exakt -20.0 → shadowlands', () {
      expect(
        gleichmaessigesProfil(-20.0).jenseitsReichBerechnen(),
        equals(JenseitsReich.shadowlands),
      );
    });

    test('Grenzwert Shadowlands: knapp über -60.0 → shadowlands', () {
      expect(
        gleichmaessigesProfil(-59.99).jenseitsReichBerechnen(),
        equals(JenseitsReich.shadowlands),
      );
    });

    test('Grenzwert Abyssus: exakt -60.0 → abyssus', () {
      expect(
        gleichmaessigesProfil(-60.0).jenseitsReichBerechnen(),
        equals(JenseitsReich.abyssus),
      );
    });

    test('Extremwert Maximum +100.0 → elysium', () {
      expect(
        gleichmaessigesProfil(100.0).jenseitsReichBerechnen(),
        equals(JenseitsReich.elysium),
      );
    });

    test('Extremwert Minimum -100.0 → abyssus', () {
      expect(
        gleichmaessigesProfil(-100.0).jenseitsReichBerechnen(),
        equals(JenseitsReich.abyssus),
      );
    });

    test('jenseitsReich Getter stimmt mit jenseitsReichBerechnen() überein',
        () {
      final profil = gleichmaessigesProfil(45.0);

      // Der Getter soll konsistent mit der Methode sein
      expect(profil.jenseitsReich, equals(profil.jenseitsReichBerechnen()));
    });

    test('gemischtes Profil mit ausgeglichenem Durchschnitt → limbus', () {
      // Positive und negative Werte heben sich auf
      const profil = KarmaProfilModel(
        mitgefuehl: 50.0,
        ehrlichkeit: -50.0,
        mut: 30.0,
        grosszuegigkeit: -30.0,
        weisheit: 10.0,
        liebe: -10.0,
      );

      expect(profil.durchschnitt, equals(0.0));
      expect(profil.jenseitsReichBerechnen(), equals(JenseitsReich.limbus));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheits-Tests
  // ───────────────────────────────────────────────────────────────────────────

  group('KarmaProfilModel Gleichheit', () {
    test('zwei identische Profile sind gleich', () {
      const profil1 = KarmaProfilModel(
        mitgefuehl: 10.0,
        ehrlichkeit: 20.0,
        mut: 30.0,
        grosszuegigkeit: 40.0,
        weisheit: 50.0,
        liebe: 60.0,
      );
      const profil2 = KarmaProfilModel(
        mitgefuehl: 10.0,
        ehrlichkeit: 20.0,
        mut: 30.0,
        grosszuegigkeit: 40.0,
        weisheit: 50.0,
        liebe: 60.0,
      );

      expect(profil1, equals(profil2));
    });

    test('Profile mit einem unterschiedlichen Wert sind ungleich', () {
      const profil1 = KarmaProfilModel(
        mitgefuehl: 10.0,
        ehrlichkeit: 20.0,
        mut: 30.0,
        grosszuegigkeit: 40.0,
        weisheit: 50.0,
        liebe: 60.0,
      );
      const profil2 = KarmaProfilModel(
        mitgefuehl: 10.0,
        ehrlichkeit: 20.0,
        mut: 30.0,
        grosszuegigkeit: 40.0,
        weisheit: 50.0,
        liebe: 61.0, // Abweichung
      );

      expect(profil1, isNot(equals(profil2)));
    });
  });
}
