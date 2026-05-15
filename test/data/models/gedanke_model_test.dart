// gedanke_model_test.dart
// Tests für GedankeModel: Serialisierung, copyWith-Verhalten und
// Identifikation giftiger/abgeschlossener Gedanken.

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // Hilfsfunktion: Erstellt einen Standard-Testgedanken
  // ───────────────────────────────────────────────────────────────────────────

  GedankeModel testGedanke({
    String id = 'gedanke-001',
    String inhalt = 'Ich bin nicht gut genug.',
    GedankenTyp typ = GedankenTyp.trauma,
    double intensitaet = 0.8,
    bool istAbgeschlossen = false,
    bool istGiftig = true,
    String? herkunftZyklusId,
    DateTime? entstanden,
    List<String> ausloesendeThemen = const ['versagen', 'selbstwert'],
    bool wirdMitgenommen = false,
  }) {
    return GedankeModel(
      id: id,
      inhalt: inhalt,
      typ: typ,
      intensitaet: intensitaet,
      istAbgeschlossen: istAbgeschlossen,
      istGiftig: istGiftig,
      herkunftZyklusId: herkunftZyklusId,
      entstanden: entstanden ?? DateTime(2024, 1, 15, 10, 30),
      ausloesende_themen: ausloesendeThemen,
      wirdMitgenommen: wirdMitgenommen,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GedankeModel Tests
  // ───────────────────────────────────────────────────────────────────────────

  group('GedankeModel', () {
    // ── copyWith ─────────────────────────────────────────────────────────────

    test('copyWith ändert nur angegebene Felder', () {
      final original = testGedanke();

      final kopie = original.copyWith(
        inhalt: 'Ich bin stark genug.',
        istAbgeschlossen: true,
      );

      // Geänderte Felder
      expect(kopie.inhalt, equals('Ich bin stark genug.'));
      expect(kopie.istAbgeschlossen, isTrue);

      // Unveränderte Felder
      expect(kopie.id, equals(original.id));
      expect(kopie.typ, equals(original.typ));
      expect(kopie.intensitaet, equals(original.intensitaet));
      expect(kopie.istGiftig, equals(original.istGiftig));
      expect(kopie.herkunftZyklusId, equals(original.herkunftZyklusId));
      expect(kopie.entstanden, equals(original.entstanden));
      expect(kopie.ausloesende_themen, equals(original.ausloesende_themen));
      expect(kopie.wirdMitgenommen, equals(original.wirdMitgenommen));
    });

    test('copyWith ohne Argumente erzeugt identische Kopie', () {
      final original = testGedanke();
      final kopie = original.copyWith();

      expect(kopie.id, equals(original.id));
      expect(kopie.inhalt, equals(original.inhalt));
      expect(kopie.typ, equals(original.typ));
      expect(kopie.intensitaet, equals(original.intensitaet));
      expect(kopie.istAbgeschlossen, equals(original.istAbgeschlossen));
      expect(kopie.istGiftig, equals(original.istGiftig));
    });

    test('copyWith kann wirdMitgenommen auf true setzen', () {
      final gedanke = testGedanke(wirdMitgenommen: false);
      final mitgenommen = gedanke.copyWith(wirdMitgenommen: true);

      expect(mitgenommen.wirdMitgenommen, isTrue);
      expect(mitgenommen.id, equals(gedanke.id)); // Unverändertes Feld
    });

    test('copyWith kann herkunftZyklusId setzen', () {
      final gedanke = testGedanke();
      final mitHerkunft = gedanke.copyWith(herkunftZyklusId: 'zyklus-abc-123');

      expect(mitHerkunft.herkunftZyklusId, equals('zyklus-abc-123'));
    });

    // ── JSON Roundtrip ────────────────────────────────────────────────────────

    test('toJson und fromJson sind invers', () {
      final original = testGedanke(
        id: 'gedanke-roundtrip-001',
        inhalt: 'Die Welt ist ungerecht.',
        typ: GedankenTyp.ueberzeugung,
        intensitaet: 0.65,
        istAbgeschlossen: false,
        istGiftig: true,
        herkunftZyklusId: 'zyklus-456',
        entstanden: DateTime(2023, 6, 21, 14, 0),
        ausloesendeThemen: ['ungerechtigkeit', 'wut', 'gesellschaft'],
        wirdMitgenommen: true,
      );

      final json = original.toJson();
      final wiederhergestellt = GedankeModel.fromJson(json);

      expect(wiederhergestellt.id, equals(original.id));
      expect(wiederhergestellt.inhalt, equals(original.inhalt));
      expect(wiederhergestellt.typ, equals(original.typ));
      expect(wiederhergestellt.intensitaet, equals(original.intensitaet));
      expect(wiederhergestellt.istAbgeschlossen, equals(original.istAbgeschlossen));
      expect(wiederhergestellt.istGiftig, equals(original.istGiftig));
      expect(wiederhergestellt.herkunftZyklusId, equals(original.herkunftZyklusId));
      expect(wiederhergestellt.entstanden, equals(original.entstanden));
      expect(wiederhergestellt.ausloesende_themen,
          equals(original.ausloesende_themen));
      expect(wiederhergestellt.wirdMitgenommen, equals(original.wirdMitgenommen));
    });

    test('toJson und fromJson funktionieren ohne herkunftZyklusId (null)', () {
      final original = testGedanke(herkunftZyklusId: null);

      final json = original.toJson();
      final wiederhergestellt = GedankeModel.fromJson(json);

      expect(wiederhergestellt.herkunftZyklusId, isNull);
    });

    test('toJson erzeugt korrektes Map', () {
      final gedanke = testGedanke(
        id: 'gedanke-json-test',
        typ: GedankenTyp.weisheit,
      );

      final json = gedanke.toJson();

      expect(json['id'], equals('gedanke-json-test'));
      expect(json['typ'], equals('weisheit')); // Enum als String
      expect(json['intensitaet'], equals(0.8));
      expect(json['istAbgeschlossen'], isFalse);
      expect(json['istGiftig'], isTrue);
      expect(json['ausloesende_themen'], isA<List>());
      expect(json['entstanden'], isA<String>()); // ISO 8601
    });

    // ── Giftige Gedanken ──────────────────────────────────────────────────────

    test('giftige Gedanken werden korrekt identifiziert', () {
      final giftiger = testGedanke(istGiftig: true);
      final harmloser = testGedanke(istGiftig: false);

      expect(giftiger.istGiftig, isTrue);
      expect(harmloser.istGiftig, isFalse);
    });

    test('Trauma-Gedanken können giftig sein', () {
      final trauma = testGedanke(
        typ: GedankenTyp.trauma,
        istGiftig: true,
        intensitaet: 0.9,
      );

      expect(trauma.typ, equals(GedankenTyp.trauma));
      expect(trauma.istGiftig, isTrue);
    });

    test('Weisheits-Gedanken können nicht giftig sein', () {
      final weisheit = testGedanke(
        typ: GedankenTyp.weisheit,
        istGiftig: false,
        inhalt: 'Jede Prüfung stärkt die Seele.',
      );

      expect(weisheit.istGiftig, isFalse);
      expect(weisheit.typ, equals(GedankenTyp.weisheit));
    });

    // ── Abgeschlossene Gedanken ───────────────────────────────────────────────

    test('abgeschlossene Gedanken werden korrekt markiert', () {
      final offen = testGedanke(istAbgeschlossen: false);
      final abgeschlossen = testGedanke(istAbgeschlossen: true);

      expect(offen.istAbgeschlossen, isFalse);
      expect(abgeschlossen.istAbgeschlossen, isTrue);
    });

    // ── Gleichheit ────────────────────────────────────────────────────────────

    test('Gleichheit basiert nur auf der ID', () {
      final gedanke1 = testGedanke(id: 'gleiche-id');
      final gedanke2 = testGedanke(
        id: 'gleiche-id',
        inhalt: 'Anderer Inhalt',
        intensitaet: 0.1,
      );
      final gedanke3 = testGedanke(id: 'andere-id');

      expect(gedanke1, equals(gedanke2)); // Gleiche ID = gleich
      expect(gedanke1, isNot(equals(gedanke3))); // Andere ID = verschieden
    });

    // ── Alle GedankenTypen ────────────────────────────────────────────────────

    test('alle GedankenTypen können serialisiert werden', () {
      for (final typ in GedankenTyp.values) {
        final gedanke = testGedanke(id: 'test-${typ.name}', typ: typ);
        final json = gedanke.toJson();
        final wiederhergestellt = GedankeModel.fromJson(json);

        expect(wiederhergestellt.typ, equals(typ),
            reason: 'Fehler bei GedankenTyp.${typ.name}');
      }
    });
  });
}
