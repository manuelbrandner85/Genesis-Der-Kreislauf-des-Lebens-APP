// entscheidung_treffen_test.dart
// Tests für EntscheidungModel-Logik und EntscheidungsOption-Verhalten.
// Der vollständige EntscheidungTreffen-UseCase benötigt ein SpielRepository –
// diese Tests decken die Domänenlogik ohne Repository-Abhängigkeit ab.

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/entscheidung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/core/engines/karma_engine.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hilfsfunktionen
// ─────────────────────────────────────────────────────────────────────────────

EntscheidungModel _erstelleTestEntscheidung({String id = 'e_test_001'}) {
  return EntscheidungModel(
    id: id,
    frage: 'Was tust du?',
    kontext: 'Dein Kollege bittet um Hilfe.',
    istMikroEntscheidung: false,
    hatParallelvorschau: false,
    systemEinfluesse: const {'zeitgeist': 0.5, 'indoktrination': 0.3},
    optionen: [
      EntscheidungsOption(
        id: '${id}_0',
        text: 'Du hilfst sofort.',
        egoistischAltruistisch: 0.9,
        karmaAuswirkung: {
          KarmaDimension.mitgefuehl: 8.0,
          KarmaDimension.grosszuegigkeit: 5.0,
        },
        sofortigeKonsequenzen: ['Kollege ist dankbar.'],
        verzoegerteKonsequenzen: ['hilfe_zurueck_spaeter'],
        klingtMoralischAber: false,
      ),
      EntscheidungsOption(
        id: '${id}_1',
        text: 'Du hilfst nach der Arbeit.',
        egoistischAltruistisch: 0.5,
        karmaAuswirkung: {KarmaDimension.ehrlichkeit: 3.0},
        sofortigeKonsequenzen: ['Kollege nickt.'],
        verzoegerteKonsequenzen: [],
        klingtMoralischAber: false,
      ),
      EntscheidungsOption(
        id: '${id}_2',
        text: 'Du lehnst ab.',
        egoistischAltruistisch: 0.1,
        karmaAuswirkung: {KarmaDimension.mitgefuehl: -3.0},
        sofortigeKonsequenzen: ['Kollege schaut enttäuscht.'],
        verzoegerteKonsequenzen: [],
        klingtMoralischAber: false,
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('EntscheidungModel Domänenlogik', () {
    // ─────────────────────────────────────────────────────────────────────────
    // Erstellung und Felder
    // ─────────────────────────────────────────────────────────────────────────

    test('istGetroffen ist false vor einer Wahl', () {
      final e = _erstelleTestEntscheidung();
      expect(e.istGetroffen, isFalse);
      expect(e.gewaehltOption, isNull);
    });

    test('istGetroffen ist true nach copyWith mit gewaehlterOptionIndex', () {
      final e = _erstelleTestEntscheidung().copyWith(gewaehltOptionIndex: 0);
      expect(e.istGetroffen, isTrue);
    });

    test('gewaehltOption gibt die richtige Option zurück', () {
      final e = _erstelleTestEntscheidung().copyWith(gewaehltOptionIndex: 1);
      expect(e.gewaehltOption, isNotNull);
      expect(e.gewaehltOption!.id, endsWith('_1'));
    });

    test('gewaehltOption gibt null bei ungültigem Index', () {
      final e = _erstelleTestEntscheidung().copyWith(gewaehltOptionIndex: 99);
      expect(e.gewaehltOption, isNull);
    });

    test('systemEinfluesse werden korrekt gespeichert', () {
      final e = _erstelleTestEntscheidung();
      expect(e.systemEinfluesse['zeitgeist'], closeTo(0.5, 0.001));
      expect(e.systemEinfluesse['indoktrination'], closeTo(0.3, 0.001));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // JSON-Serialisierung
    // ─────────────────────────────────────────────────────────────────────────

    test('toJson() und fromJson() sind invers', () {
      final original = _erstelleTestEntscheidung()
          .copyWith(gewaehltOptionIndex: 0);
      final json = original.toJson();
      final wiederhergestellt = EntscheidungModel.fromJson(json);

      expect(wiederhergestellt.id, equals(original.id));
      expect(wiederhergestellt.frage, equals(original.frage));
      expect(wiederhergestellt.optionen.length, equals(original.optionen.length));
      expect(wiederhergestellt.gewaehltOptionIndex,
             equals(original.gewaehltOptionIndex));
      expect(wiederhergestellt.istGetroffen, isTrue);
    });
  });

  group('EntscheidungsOption Karma-Mechanik', () {
    // ─────────────────────────────────────────────────────────────────────────
    // Karma-Auswirkungen auf ein Profil anwenden (via KarmaEngine)
    // ─────────────────────────────────────────────────────────────────────────

    test('altruistische Option erhöht Mitgefühl und Großzügigkeit', () {
      final e = _erstelleTestEntscheidung();
      final option = e.optionen[0]; // egoistischAltruistisch: 0.9
      var karma = KarmaProfilModel.neutral();

      for (final eintrag in option.karmaAuswirkung.entries) {
        final altWert = switch (eintrag.key) {
          KarmaDimension.mitgefuehl => karma.mitgefuehl,
          KarmaDimension.ehrlichkeit => karma.ehrlichkeit,
          KarmaDimension.mut => karma.mut,
          KarmaDimension.grosszuegigkeit => karma.grosszuegigkeit,
          KarmaDimension.weisheit => karma.weisheit,
          KarmaDimension.liebe => karma.liebe,
        };
        karma = karma.dimensionAktualisieren(eintrag.key, altWert + eintrag.value);
      }

      expect(karma.mitgefuehl, greaterThan(0.0));
      expect(karma.grosszuegigkeit, greaterThan(0.0));
    });

    test('egoistische Option senkt Mitgefühl', () {
      final e = _erstelleTestEntscheidung();
      final option = e.optionen[2]; // egoistischAltruistisch: 0.1
      var karma = KarmaProfilModel.neutral();

      for (final eintrag in option.karmaAuswirkung.entries) {
        final altWert = switch (eintrag.key) {
          KarmaDimension.mitgefuehl => karma.mitgefuehl,
          KarmaDimension.ehrlichkeit => karma.ehrlichkeit,
          KarmaDimension.mut => karma.mut,
          KarmaDimension.grosszuegigkeit => karma.grosszuegigkeit,
          KarmaDimension.weisheit => karma.weisheit,
          KarmaDimension.liebe => karma.liebe,
        };
        karma = karma.dimensionAktualisieren(eintrag.key, altWert + eintrag.value);
      }

      expect(karma.mitgefuehl, lessThan(0.0));
    });

    test('sofortige Konsequenzen sind nicht leer für Option 0', () {
      final e = _erstelleTestEntscheidung();
      expect(e.optionen[0].sofortigeKonsequenzen, isNotEmpty);
    });

    test('verzögerte Konsequenzen existieren nur bei Option 0', () {
      final e = _erstelleTestEntscheidung();
      expect(e.optionen[0].verzoegerteKonsequenzen, isNotEmpty);
      expect(e.optionen[1].verzoegerteKonsequenzen, isEmpty);
      expect(e.optionen[2].verzoegerteKonsequenzen, isEmpty);
    });

    test('egoistischAltruistisch-Werte sind korrekt gesetzt', () {
      final e = _erstelleTestEntscheidung();
      expect(e.optionen[0].egoistischAltruistisch, closeTo(0.9, 0.001));
      expect(e.optionen[1].egoistischAltruistisch, closeTo(0.5, 0.001));
      expect(e.optionen[2].egoistischAltruistisch, closeTo(0.1, 0.001));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // KarmaEngine-Integration
    // ─────────────────────────────────────────────────────────────────────────

    test('KarmaEngine.dimensionAktualisieren wendet Option-Werte korrekt an', () {
      final option = EntscheidungsOption(
        id: 'opt_karma_test',
        text: 'Hilfreich sein',
        egoistischAltruistisch: 0.8,
        karmaAuswirkung: {KarmaDimension.mitgefuehl: 15.0},
        sofortigeKonsequenzen: const [],
        verzoegerteKonsequenzen: const [],
        klingtMoralischAber: false,
      );

      final altWert = 0.0;
      final neuerWert = KarmaEngine.dimensionAktualisieren(
        altWert,
        option.karmaAuswirkung[KarmaDimension.mitgefuehl]!,
      );

      expect(neuerWert, greaterThan(0.0));
      expect(neuerWert, lessThanOrEqualTo(100.0));
    });

    test('Kein Karma-Überlauf bei extremen Werten', () {
      final option = EntscheidungsOption(
        id: 'opt_extrem',
        text: 'Extrem altruistisch',
        egoistischAltruistisch: 1.0,
        karmaAuswirkung: {KarmaDimension.mitgefuehl: 200.0},
        sofortigeKonsequenzen: const [],
        verzoegerteKonsequenzen: const [],
        klingtMoralischAber: false,
      );

      final neuerWert = KarmaEngine.dimensionAktualisieren(
        90.0,
        option.karmaAuswirkung[KarmaDimension.mitgefuehl]!,
      );

      expect(neuerWert, lessThanOrEqualTo(100.0));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Gleichheits-Checks
    // ─────────────────────────────────────────────────────────────────────────

    test('Zwei Entscheidungen mit gleicher ID sind gleich', () {
      final e1 = _erstelleTestEntscheidung(id: 'gleiche_id');
      final e2 = _erstelleTestEntscheidung(id: 'gleiche_id');

      expect(e1, equals(e2));
    });

    test('Zwei Entscheidungen mit unterschiedlicher ID sind ungleich', () {
      final e1 = _erstelleTestEntscheidung(id: 'id_1');
      final e2 = _erstelleTestEntscheidung(id: 'id_2');

      expect(e1, isNot(equals(e2)));
    });
  });
}
