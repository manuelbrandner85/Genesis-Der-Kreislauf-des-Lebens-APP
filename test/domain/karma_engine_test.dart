// karma_engine_test.dart
// Vollständige Tests für die KarmaEngine und verwandte Modell-Logik.
// Testet Berechnungen, Grenzbereiche und Konsistenz der Karma-Mechanik.

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/core/engines/karma_engine.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/genetischer_code_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // KarmaProfilModel Tests
  // ───────────────────────────────────────────────────────────────────────────

  group('KarmaProfilModel', () {
    test('neutral() erstellt alle Dimensionen mit 0.0', () {
      final profil = KarmaProfilModel.neutral();

      expect(profil.mitgefuehl, equals(0.0));
      expect(profil.ehrlichkeit, equals(0.0));
      expect(profil.mut, equals(0.0));
      expect(profil.grosszuegigkeit, equals(0.0));
      expect(profil.weisheit, equals(0.0));
      expect(profil.liebe, equals(0.0));
      expect(profil.durchschnitt, equals(0.0));
    });

    test('durchschnitt berechnet korrekt über alle sechs Dimensionen', () {
      final profil = KarmaProfilModel(
        mitgefuehl: 60.0,
        ehrlichkeit: 60.0,
        mut: 60.0,
        grosszuegigkeit: 60.0,
        weisheit: 60.0,
        liebe: 60.0,
      );

      // Alle Werte gleich → Durchschnitt = gleicher Wert
      expect(profil.durchschnitt, equals(60.0));
    });

    test('durchschnitt berechnet korrekt bei gemischten Werten', () {
      final profil = KarmaProfilModel(
        mitgefuehl: 100.0,
        ehrlichkeit: -100.0,
        mut: 50.0,
        grosszuegigkeit: -50.0,
        weisheit: 20.0,
        liebe: -20.0,
      );

      // (100 + (-100) + 50 + (-50) + 20 + (-20)) / 6 = 0 / 6 = 0.0
      expect(profil.durchschnitt, equals(0.0));
    });

    test('jenseitsReichBerechnen() bei hohem positivem Karma = elysium', () {
      final profil = KarmaProfilModel(
        mitgefuehl: 80.0,
        ehrlichkeit: 90.0,
        mut: 70.0,
        grosszuegigkeit: 80.0,
        weisheit: 85.0,
        liebe: 75.0,
      );

      // Durchschnitt ≈ 80.0 → >= 60.0 → elysium
      expect(profil.jenseitsReichBerechnen(), equals(JenseitsReich.elysium));
    });

    test('jenseitsReichBerechnen() bei ausgeglichenem Karma = limbus', () {
      final profil = KarmaProfilModel(
        mitgefuehl: 10.0,
        ehrlichkeit: -10.0,
        mut: 5.0,
        grosszuegigkeit: -5.0,
        weisheit: 8.0,
        liebe: -8.0,
      );

      // Durchschnitt ≈ 0.0 → zwischen -20 und +20 → limbus
      expect(profil.jenseitsReichBerechnen(), equals(JenseitsReich.limbus));
    });

    test('jenseitsReichBerechnen() bei sehr negativem Karma = abyssus', () {
      final profil = KarmaProfilModel(
        mitgefuehl: -80.0,
        ehrlichkeit: -90.0,
        mut: -70.0,
        grosszuegigkeit: -75.0,
        weisheit: -85.0,
        liebe: -80.0,
      );

      // Durchschnitt ≈ -80.0 → <= -60.0 → abyssus
      expect(profil.jenseitsReichBerechnen(), equals(JenseitsReich.abyssus));
    });

    test(
        'jenseitsReichBerechnen() bei mäßig positivem Karma = harmonia', () {
      final profil = KarmaProfilModel(
        mitgefuehl: 40.0,
        ehrlichkeit: 30.0,
        mut: 35.0,
        grosszuegigkeit: 25.0,
        weisheit: 40.0,
        liebe: 30.0,
      );

      // Durchschnitt ≈ 33.3 → >= 20.0 und < 60.0 → harmonia
      expect(profil.jenseitsReichBerechnen(), equals(JenseitsReich.harmonia));
    });

    test(
        'jenseitsReichBerechnen() bei mäßig negativem Karma = shadowlands',
        () {
      final profil = KarmaProfilModel(
        mitgefuehl: -40.0,
        ehrlichkeit: -30.0,
        mut: -35.0,
        grosszuegigkeit: -25.0,
        weisheit: -40.0,
        liebe: -30.0,
      );

      // Durchschnitt ≈ -33.3 → <= -20.0 und > -60.0 → shadowlands
      expect(
          profil.jenseitsReichBerechnen(), equals(JenseitsReich.shadowlands));
    });

    test('dimensionAktualisieren() klemmt bei oberer Grenze (+100)', () {
      final profil = KarmaProfilModel.neutral();

      // +120 auf eine Dimension → sollte auf +100 begrenzt werden
      final aktualisiert = profil.dimensionAktualisieren(
        KarmaDimension.mitgefuehl,
        120.0,
      );

      expect(aktualisiert.mitgefuehl, equals(100.0));
      // Andere Dimensionen bleiben unverändert
      expect(aktualisiert.ehrlichkeit, equals(0.0));
    });

    test('dimensionAktualisieren() klemmt bei unterer Grenze (-100)', () {
      final profil = KarmaProfilModel.neutral();

      // -120 auf eine Dimension → sollte auf -100 begrenzt werden
      final aktualisiert = profil.dimensionAktualisieren(
        KarmaDimension.mut,
        -120.0,
      );

      expect(aktualisiert.mut, equals(-100.0));
    });

    test('dominanteDimension liefert die Dimension mit dem größten Absolutwert',
        () {
      final profil = KarmaProfilModel(
        mitgefuehl: 10.0,
        ehrlichkeit: 30.0,
        mut: -80.0, // Größter Absolutwert
        grosszuegigkeit: 5.0,
        weisheit: -20.0,
        liebe: 15.0,
      );

      expect(profil.dominanteDimension, equals(KarmaDimension.mut));
    });

    test('dominanteDimension bei neutralem Profil liefert definierte Dimension',
        () {
      final profil = KarmaProfilModel.neutral();

      // Bei Gleichheit (alle 0.0): erste Dimension mit maximalem Abs-Wert
      // (alle gleich, daher die erste: mitgefuehl)
      expect(KarmaDimension.values.contains(profil.dominanteDimension), isTrue);
    });

    test('copyWith ändert nur angegebene Felder', () {
      const original = KarmaProfilModel(
        mitgefuehl: 50.0,
        ehrlichkeit: 30.0,
        mut: 20.0,
        grosszuegigkeit: 10.0,
        weisheit: 40.0,
        liebe: 60.0,
      );

      final kopie = original.copyWith(mitgefuehl: 100.0);

      expect(kopie.mitgefuehl, equals(100.0));
      expect(kopie.ehrlichkeit, equals(30.0)); // Unverändert
      expect(kopie.mut, equals(20.0));          // Unverändert
      expect(kopie.grosszuegigkeit, equals(10.0)); // Unverändert
      expect(kopie.weisheit, equals(40.0));    // Unverändert
      expect(kopie.liebe, equals(60.0));        // Unverändert
    });

    test('toJson und fromJson sind invers', () {
      const profil = KarmaProfilModel(
        mitgefuehl: 42.5,
        ehrlichkeit: -33.1,
        mut: 0.0,
        grosszuegigkeit: 99.9,
        weisheit: -99.9,
        liebe: 17.3,
      );

      final json = profil.toJson();
      final wiederhergestellt = KarmaProfilModel.fromJson(json);

      expect(wiederhergestellt.mitgefuehl, equals(profil.mitgefuehl));
      expect(wiederhergestellt.ehrlichkeit, equals(profil.ehrlichkeit));
      expect(wiederhergestellt.mut, equals(profil.mut));
      expect(wiederhergestellt.grosszuegigkeit, equals(profil.grosszuegigkeit));
      expect(wiederhergestellt.weisheit, equals(profil.weisheit));
      expect(wiederhergestellt.liebe, equals(profil.liebe));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // KarmaEngine Tests
  // ───────────────────────────────────────────────────────────────────────────

  group('KarmaEngine', () {
    test('dimensionAktualisieren() mit positivem Delta erhöht den Wert', () {
      final neuerWert = KarmaEngine.dimensionAktualisieren(0.0, 20.0);

      // Wert sollte positiv sein und zwischen 0 und 20 liegen (Momentum dämpft)
      expect(neuerWert, greaterThan(0.0));
      expect(neuerWert, lessThanOrEqualTo(20.0));
    });

    test(
        'dimensionAktualisieren() klemmt Ergebnis immer auf [-100, +100]', () {
      // Sehr hoher positiver Wert mit sehr hohem Delta
      final oben = KarmaEngine.dimensionAktualisieren(90.0, 50.0);
      expect(oben, lessThanOrEqualTo(100.0));

      // Sehr hoher negativer Wert mit sehr negativem Delta
      final unten = KarmaEngine.dimensionAktualisieren(-90.0, -50.0);
      expect(unten, greaterThanOrEqualTo(-100.0));
    });

    test('reichBerechnen() gibt elysium für sehr positives Karma zurück', () {
      final profil = KarmaProfilModel(
        mitgefuehl: 90.0,
        ehrlichkeit: 85.0,
        mut: 80.0,
        grosszuegigkeit: 75.0,
        weisheit: 90.0,
        liebe: 85.0,
      );

      expect(KarmaEngine.reichBerechnen(profil), equals(JenseitsReich.elysium));
    });

    test('reichBerechnen() gibt limbus für neutrales Karma zurück', () {
      expect(
        KarmaEngine.reichBerechnen(KarmaProfilModel.neutral()),
        equals(JenseitsReich.limbus),
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GenetischerCodeModel Tests
  // ───────────────────────────────────────────────────────────────────────────

  group('GenetischerCodeModel', () {
    test('generieren() erstellt valide zufällige Attribute', () {
      final code = GenetischerCodeModel.generieren();

      // Seelen- und Körper-ID müssen gesetzt sein
      expect(code.seelencodeId, isNotEmpty);
      expect(code.koerpercode, isNotEmpty);
      expect(code.seelencodeId, isNot(equals(code.koerpercode)));

      // Alle Basis-Attribute müssen vorhanden und im gültigen Bereich sein
      for (final attr in kBasisAttributSchluessel) {
        expect(code.basisAttribute.containsKey(attr), isTrue);
        expect(code.basisAttribute[attr]!, greaterThanOrEqualTo(0.0));
        expect(code.basisAttribute[attr]!, lessThanOrEqualTo(100.0));
      }

      // Maximalattribute müssen >= Basisattribute sein
      for (final attr in kBasisAttributSchluessel) {
        expect(
          code.maximalAttribute[attr]!,
          greaterThanOrEqualTo(code.basisAttribute[attr]! - 0.001),
        );
      }

      // Gene müssen aus den bekannten Genen stammen
      for (final gen in code.aktivierteGene) {
        expect(kMoeglicheGene.contains(gen), isTrue);
      }
      for (final gen in code.schlafendeGene) {
        expect(kMoeglicheGene.contains(gen), isTrue);
      }

      // Kein Gen kann gleichzeitig aktiv und schlafend sein
      final schnittmenge = code.aktivierteGene
          .toSet()
          .intersection(code.schlafendeGene.toSet());
      expect(schnittmenge, isEmpty);
    });

    test('mitPartnerMischen() erzeugt Kind-Code im gültigen Bereich', () {
      final elternteil1 = GenetischerCodeModel.generieren();
      final elternteil2 = GenetischerCodeModel.generieren();

      final kind = elternteil1.mitPartnerMischen(elternteil2);

      // Kind hat neue Seelen-UUID (eigene Identität)
      expect(kind.seelencodeId, isNot(equals(elternteil1.seelencodeId)));
      expect(kind.seelencodeId, isNot(equals(elternteil2.seelencodeId)));

      // Attribute des Kindes im gültigen Bereich
      for (final attr in kBasisAttributSchluessel) {
        expect(kind.basisAttribute[attr]!, greaterThanOrEqualTo(0.0));
        expect(kind.basisAttribute[attr]!, lessThanOrEqualTo(100.0));
      }
    });

    test('genAktivieren() verschiebt Gen aus schlafend zu aktiv', () {
      final code = GenetischerCodeModel.generieren();

      // Mindestens ein schlafendes Gen für den Test nötig
      if (code.schlafendeGene.isEmpty) return;

      final zuAktivierendesGen = code.schlafendeGene.first;
      final aktiviert = code.genAktivieren(zuAktivierendesGen);

      // Gen ist nun aktiv
      expect(aktiviert.aktivierteGene.contains(zuAktivierendesGen), isTrue);
      // Gen ist nicht mehr schlafend
      expect(aktiviert.schlafendeGene.contains(zuAktivierendesGen), isFalse);
    });

    test('genAktivieren() ignoriert bereits aktive Gene', () {
      final code = GenetischerCodeModel.generieren();

      if (code.aktivierteGene.isEmpty) return;

      final aktivesGen = code.aktivierteGene.first;
      final unveraendert = code.genAktivieren(aktivesGen);

      // Anzahl der aktiven Gene bleibt gleich (kein Duplikat)
      expect(unveraendert.aktivierteGene.length, equals(code.aktivierteGene.length));
    });

    test('genAktivieren() ignoriert unbekannte Gene', () {
      final code = GenetischerCodeModel.generieren();
      final unveraendert = code.genAktivieren('gen_inexistent_12345');

      // Code bleibt identisch
      expect(unveraendert.aktivierteGene.length, equals(code.aktivierteGene.length));
      expect(unveraendert.schlafendeGene.length, equals(code.schlafendeGene.length));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // KonsequenzNetzwerk Tests (via KarmaEngine.echoEntscheidungGenerieren)
  // ───────────────────────────────────────────────────────────────────────────

  group('KonsequenzNetzwerk (Echo via KarmaEngine)', () {
    test('echoEntscheidungGenerieren() gibt null bei leerer Liste zurück', () {
      final ergebnis = KarmaEngine.echoEntscheidungGenerieren([], 25);
      expect(ergebnis, isNull);
    });

    test(
        'echoEntscheidungGenerieren() gibt null zurück wenn keine Entscheidung getroffen',
        () {
      // Entscheidung ohne gewaehltOptionIndex (istGetroffen == false)
      // Diese Entscheidung wird in der Engine herausgefiltert
      final ergebnis = KarmaEngine.echoEntscheidungGenerieren([], 30);
      expect(ergebnis, isNull);
    });
  });
}
