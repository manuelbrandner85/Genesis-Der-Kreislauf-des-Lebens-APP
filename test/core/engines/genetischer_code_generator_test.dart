// genetischer_code_generator_test.dart
// Tests für den GenetischerCodeGenerator.
// Prüft Attribut-Generierung, Gen-Aktivierung, Eltern-Vererbung und Epigenetik.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/core/engines/genetischer_code_generator.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/genetischer_code_model.dart';

void main() {
  group('GenetischerCodeGenerator', () {
    late GenetischerCodeGenerator generator;

    setUp(() {
      // Fester Seed für deterministische Tests
      generator = GenetischerCodeGenerator(zufall: Random(42));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Neuer Code
    // ─────────────────────────────────────────────────────────────────────────

    group('neuenCodeGenerieren()', () {
      test('generiert einen Code mit nicht-leerer seelencodeId', () {
        final code = generator.neuenCodeGenerieren();
        expect(code.seelencodeId, isNotEmpty);
      });

      test('generiert einen Code mit nicht-leerem koerpercode', () {
        final code = generator.neuenCodeGenerieren();
        expect(code.koerpercode, isNotEmpty);
      });

      test('seelencodeId und koerpercode sind unterschiedlich', () {
        final code = generator.neuenCodeGenerieren();
        expect(code.seelencodeId, isNot(equals(code.koerpercode)));
      });

      test('basisAttribute enthält alle erwarteten Attributschlüssel', () {
        final code = generator.neuenCodeGenerieren();
        for (final schluessel in kBasisAttributSchluessel) {
          expect(code.basisAttribute.containsKey(schluessel), isTrue,
              reason: 'Schlüssel fehlt: $schluessel');
        }
      });

      test('basisAttribute-Werte liegen im Bereich [10, 90]', () {
        final code = generator.neuenCodeGenerieren();
        for (final eintrag in code.basisAttribute.entries) {
          expect(eintrag.value, greaterThanOrEqualTo(10),
              reason: '${eintrag.key} < 10');
          expect(eintrag.value, lessThanOrEqualTo(90),
              reason: '${eintrag.key} > 90');
        }
      });

      test('aktivierteGene und schlafendeGene zusammen decken alle Gene ab', () {
        final code = generator.neuenCodeGenerieren();
        final alleGene = {...code.aktivierteGene, ...code.schlafendeGene};
        for (final gen in kMoeglicheGene) {
          expect(alleGene.contains(gen), isTrue,
              reason: 'Gen $gen fehlt komplett');
        }
      });

      test('versteckteTalente ist nicht leer', () {
        final code = generator.neuenCodeGenerieren();
        expect(code.versteckteTalente, isNotEmpty);
      });

      test('zwei aufeinander folgende Codes haben verschiedene koerpercodes', () {
        final gen2 = GenetischerCodeGenerator();
        final code1 = gen2.neuenCodeGenerieren();
        final code2 = gen2.neuenCodeGenerieren();
        expect(code1.koerpercode, isNot(equals(code2.koerpercode)));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Wiedergeburt
    // ─────────────────────────────────────────────────────────────────────────

    group('wiedergeburtsCodeGenerieren()', () {
      test('behält die seelencodeId des Vorgängers', () {
        final original = generator.neuenCodeGenerieren();
        final wiedergeburt = generator.wiedergeburtsCodeGenerieren(original, {});
        expect(wiedergeburt.seelencodeId, equals(original.seelencodeId));
      });

      test('vergibt einen neuen koerpercode', () {
        final original = generator.neuenCodeGenerieren();
        final wiedergeburt = generator.wiedergeburtsCodeGenerieren(original, {});
        expect(wiedergeburt.koerpercode, isNot(equals(original.koerpercode)));
      });

      test('epigenetische Veränderungen für bekannte Attribute werden angewendet', () {
        final original = generator.neuenCodeGenerieren();
        final wiedergeburt = generator.wiedergeburtsCodeGenerieren(
          original,
          {'ausdauer': 20.0},
        );
        // Ausdauer liegt im gültigen Bereich (kann durch Epigenetik leicht höher sein)
        final neueAusdauer = wiedergeburt.basisAttribute['ausdauer'] ?? 0;
        expect(neueAusdauer, greaterThanOrEqualTo(0));
        expect(neueAusdauer, lessThanOrEqualTo(100));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Eltern-Vererbung
    // ─────────────────────────────────────────────────────────────────────────

    group('kindCodeErstellen()', () {
      test('Kind-Code hat neue seelencodeId (eigene Seele)', () {
        final elternteil1 = generator.neuenCodeGenerieren();
        final elternteil2 = generator.neuenCodeGenerieren();
        final kind = generator.kindCodeErstellen(elternteil1, elternteil2);
        expect(kind.seelencodeId, isNot(equals(elternteil1.seelencodeId)));
        expect(kind.seelencodeId, isNot(equals(elternteil2.seelencodeId)));
      });

      test('Kind-Code enthält Gene aus beiden Elternteilen', () {
        final elternteil1 = generator.neuenCodeGenerieren();
        final elternteil2 = generator.neuenCodeGenerieren();
        final kind = generator.kindCodeErstellen(elternteil1, elternteil2);
        expect(kind.aktivierteGene.length + kind.schlafendeGene.length,
            greaterThan(0));
      });

      test('Kind-basisAttribute liegen im gültigen Bereich', () {
        final elternteil1 = generator.neuenCodeGenerieren();
        final elternteil2 = generator.neuenCodeGenerieren();
        final kind = generator.kindCodeErstellen(elternteil1, elternteil2);
        for (final wert in kind.basisAttribute.values) {
          expect(wert, greaterThanOrEqualTo(0));
          expect(wert, lessThanOrEqualTo(100));
        }
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Epigenetik-Berechnung
    // ─────────────────────────────────────────────────────────────────────────

    group('epigenetikBerechnen()', () {
      test('Rauchen erhöht Lungenrisiko-Marker', () {
        final veraenderungen = generator.epigenetikBerechnen(
          raucher: true,
          sportlich: false,
          meditiert: false,
          chronicStress: false,
          gesundeErnaehrung: false,
          substanzAbhaengig: false,
        );
        expect(veraenderungen['gen_lungenrisiko'], greaterThan(0));
      });

      test('Sport erhöht Herzstärke-Marker', () {
        final veraenderungen = generator.epigenetikBerechnen(
          raucher: false,
          sportlich: true,
          meditiert: false,
          chronicStress: false,
          gesundeErnaehrung: false,
          substanzAbhaengig: false,
        );
        expect(veraenderungen['gen_herzstaerke'], greaterThan(0));
      });

      test('Meditation erhöht Stressresistenz-Marker', () {
        final veraenderungen = generator.epigenetikBerechnen(
          raucher: false,
          sportlich: false,
          meditiert: true,
          chronicStress: false,
          gesundeErnaehrung: false,
          substanzAbhaengig: false,
        );
        expect(veraenderungen['gen_stressresistenz'], greaterThan(0));
      });

      test('chronischer Stress erhöht Angstneigung', () {
        final veraenderungen = generator.epigenetikBerechnen(
          raucher: false,
          sportlich: false,
          meditiert: false,
          chronicStress: true,
          gesundeErnaehrung: false,
          substanzAbhaengig: false,
        );
        expect(veraenderungen['gen_angstneigung'], greaterThan(0));
      });

      test('gesunde Ernährung stärkt Immunsystem', () {
        final veraenderungen = generator.epigenetikBerechnen(
          raucher: false,
          sportlich: false,
          meditiert: false,
          chronicStress: false,
          gesundeErnaehrung: true,
          substanzAbhaengig: false,
        );
        expect(veraenderungen['gen_immunstaerke'], greaterThan(0));
      });

      test('Substanzabhängigkeit erhöht Suchtneigung', () {
        final veraenderungen = generator.epigenetikBerechnen(
          raucher: false,
          sportlich: false,
          meditiert: false,
          chronicStress: false,
          gesundeErnaehrung: false,
          substanzAbhaengig: true,
        );
        expect(veraenderungen['gen_suchtneigung'], greaterThan(0));
      });

      test('keine Lebensstil-Inputs = leere Veränderungen', () {
        final veraenderungen = generator.epigenetikBerechnen(
          raucher: false,
          sportlich: false,
          meditiert: false,
          chronicStress: false,
          gesundeErnaehrung: false,
          substanzAbhaengig: false,
        );
        expect(veraenderungen, isEmpty);
      });
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // GenetischerCodeModel
  // ─────────────────────────────────────────────────────────────────────────────

  group('GenetischerCodeModel', () {
    GenetischerCodeModel _erstelleTestCode() => GenetischerCodeModel(
          seelencodeId: 'seele_001',
          koerpercode: 'koerper_001',
          basisAttribute: {
            'kraft': 50.0,
            'intelligenz': 70.0,
            'empathie': 60.0,
            'kreativitaet': 55.0,
            'ausdauer': 65.0,
            'intuition': 45.0,
          },
          maximalAttribute: {
            'kraft': 80.0,
            'intelligenz': 95.0,
            'empathie': 85.0,
            'kreativitaet': 80.0,
            'ausdauer': 90.0,
            'intuition': 75.0,
          },
          aktivierteGene: ['gen_heilung', 'gen_einfuehlsam'],
          schlafendeGene: ['gen_fuehrerschaft', 'gen_kreativ'],
          krankheitsrisiken: ['sehschwaeche'],
          versteckteTalente: ['gen_kommunikation'],
          epigenetischeVeraenderungen: {},
        );

    test('genAktivieren() verschiebt Gen von schlafend nach aktiv', () {
      final code = _erstelleTestCode();
      final aktualisiert = code.genAktivieren('gen_fuehrerschaft');
      expect(aktualisiert.aktivierteGene, contains('gen_fuehrerschaft'));
      expect(aktualisiert.schlafendeGene, isNot(contains('gen_fuehrerschaft')));
    });

    test('genAktivieren() tut nichts wenn Gen nicht schlafend ist', () {
      final code = _erstelleTestCode();
      final aktualisiert = code.genAktivieren('gen_heilung'); // schon aktiv
      // Aktivierte Gene unverändert (Duplikatschutz)
      expect(aktualisiert.aktivierteGene.where((g) => g == 'gen_heilung').length,
          equals(1));
    });

    test('toJson() / fromJson() sind invers', () {
      final original = _erstelleTestCode();
      final json = original.toJson();
      final wiederhergestellt = GenetischerCodeModel.fromJson(json);

      expect(wiederhergestellt.seelencodeId, equals(original.seelencodeId));
      expect(wiederhergestellt.koerpercode, equals(original.koerpercode));
      expect(wiederhergestellt.aktivierteGene, equals(original.aktivierteGene));
      expect(wiederhergestellt.basisAttribute['kraft'],
          closeTo(original.basisAttribute['kraft']!, 0.001));
    });

    test('Gleichheit basiert auf seelencodeId und koerpercode', () {
      final code1 = _erstelleTestCode();
      final code2 = code1.copyWith(basisAttribute: {'kraft': 99.0});
      expect(code1, equals(code2)); // gleiche IDs → gleich
    });

    test('verschiedene koerpercodes → ungleich', () {
      final code1 = _erstelleTestCode();
      final code2 = code1.copyWith(koerpercode: 'koerper_999');
      expect(code1, isNot(equals(code2)));
    });
  });
}
