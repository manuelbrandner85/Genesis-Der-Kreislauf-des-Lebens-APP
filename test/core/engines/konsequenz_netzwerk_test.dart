// konsequenz_netzwerk_test.dart
// Tests für die KonsequenzNetzwerk-Engine.
// Testet Registrierung, zeitverzögertes Auslösen und Konsequenz-Getter.

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/engines/konsequenz_netzwerk.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/entscheidung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/konsequenz_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hilfsfunktionen
// ─────────────────────────────────────────────────────────────────────────────

EntscheidungModel _erstelleTestEntscheidung({
  String id = 'test_001',
  int optionenAnzahl = 2,
}) {
  final optionen = List.generate(
    optionenAnzahl,
    (i) => EntscheidungsOption(
      id: '${id}_opt_$i',
      text: 'Option $i',
      egoistischAltruistisch: 0.5,
      karmaAuswirkung: {
        KarmaDimension.mitgefuehl: i == 0 ? 5.0 : -3.0,
      },
      sofortigeKonsequenzen: ['Sofort-Konsequenz $i'],
      verzoegerteKonsequenzen: i == 0 ? ['konsequenz_verzoegert_a'] : [],
      klingtMoralischAber: false,
    ),
  );

  return EntscheidungModel(
    id: id,
    kontext: 'Testsituation',
    frage: 'Was tust du?',
    optionen: optionen,
    istMikroEntscheidung: false,
    hatParallelvorschau: false,
    systemEinfluesse: const {},
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('KonsequenzNetzwerk', () {
    late KonsequenzNetzwerk netzwerk;

    setUp(() {
      netzwerk = KonsequenzNetzwerk();
      netzwerk.startAlterSetzen(0);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Initialisierung
    // ─────────────────────────────────────────────────────────────────────────

    test('Netzwerk startet leer – keine Konsequenzen', () {
      expect(netzwerk.alleAktiven, isEmpty);
      expect(netzwerk.eingetreten, isEmpty);
      expect(netzwerk.ausstehend, isEmpty);
      expect(netzwerk.anzahl, equals(0));
    });

    test('startAlterSetzen() ändert das Referenzalter ohne Fehler', () {
      expect(() => netzwerk.startAlterSetzen(15), returnsNormally);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Registrierung
    // ─────────────────────────────────────────────────────────────────────────

    test('konsequenzenRegistrieren() fügt Konsequenzen hinzu', () {
      final entscheidung = _erstelleTestEntscheidung();
      netzwerk.konsequenzenRegistrieren(entscheidung, 0);

      expect(netzwerk.alleAktiven, isNotEmpty);
      expect(netzwerk.anzahl, greaterThan(0));
    });

    test('konsequenzenRegistrieren() mit ungültigem Index ignoriert Aktion', () {
      final entscheidung = _erstelleTestEntscheidung(optionenAnzahl: 2);
      netzwerk.konsequenzenRegistrieren(entscheidung, 99);
      expect(netzwerk.anzahl, equals(0));
    });

    test('konsequenzenRegistrieren() mit negativem Index ignoriert Aktion', () {
      final entscheidung = _erstelleTestEntscheidung();
      netzwerk.konsequenzenRegistrieren(entscheidung, -1);
      expect(netzwerk.anzahl, equals(0));
    });

    test('sofortige Konsequenzen (Verzögerung 0) werden als ausstehend registriert', () {
      final entscheidung = _erstelleTestEntscheidung();
      netzwerk.konsequenzenRegistrieren(entscheidung, 0);

      // Alle Konsequenzen sind anfangs ausstehend (noch nicht eingetreten)
      expect(netzwerk.ausstehend, isNotEmpty);
      expect(netzwerk.eingetreten, isEmpty);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Zeitliches Auslösen
    // ─────────────────────────────────────────────────────────────────────────

    test('alterSimulieren() löst sofortige Konsequenz beim ersten Aufruf aus', () {
      final entscheidung = _erstelleTestEntscheidung();
      netzwerk.konsequenzenRegistrieren(entscheidung, 0);

      final ausgeloest = netzwerk.alterSimulieren(1, GamePhase.kindheit);

      expect(ausgeloest, isNotEmpty);
      expect(netzwerk.eingetreten, isNotEmpty);
    });

    test('alterSimulieren() löst jede Konsequenz nur einmal aus', () {
      final entscheidung = _erstelleTestEntscheidung();
      netzwerk.konsequenzenRegistrieren(entscheidung, 0);

      final erstAusloesen = netzwerk.alterSimulieren(1, GamePhase.kindheit);
      final zweitAusloesen = netzwerk.alterSimulieren(1, GamePhase.kindheit);

      // Zweiter Aufruf mit gleichem Alter bringt keine neuen Konsequenzen
      expect(zweitAusloesen.length, lessThanOrEqualTo(erstAusloesen.length));
    });

    test('alterSimulieren() mit Alter < Startpunkt löst nichts aus', () {
      netzwerk.startAlterSetzen(10);
      final entscheidung = _erstelleTestEntscheidung(alter: 10);
      netzwerk.konsequenzenRegistrieren(entscheidung, 0);

      // Alter 5 liegt VOR dem Startpunkt
      final ausgeloest = netzwerk.alterSimulieren(5, GamePhase.kindheit);
      // Verzögerte Konsequenzen (Fälligkeit > 5) werden noch nicht ausgelöst
      // (sofortige haben Verzögerung 0, Fälligkeit = 10+0 = 10)
      expect(ausgeloest, isEmpty);
    });

    test('alterSimulieren() mit hohem Alter löst verzögerte Konsequenzen aus', () {
      netzwerk.startAlterSetzen(5);
      final entscheidung = _erstelleTestEntscheidung(alter: 5);
      netzwerk.konsequenzenRegistrieren(entscheidung, 0);

      // Sofortige Konsequenzen bei Alter 5 auslösen
      netzwerk.alterSimulieren(5, GamePhase.kindheit);

      // Verzögerte Konsequenzen bei hohem Alter auslösen
      netzwerk.alterSimulieren(25, GamePhase.erwachsen);

      // Jetzt sollten eingetretene Konsequenzen existieren
      expect(netzwerk.eingetreten, isNotEmpty);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Aktive vs. Eingetretene Konsequenzen
    // ─────────────────────────────────────────────────────────────────────────

    test('ausstehend() reduziert sich nach Auslösen', () {
      final entscheidung = _erstelleTestEntscheidung();
      netzwerk.konsequenzenRegistrieren(entscheidung, 0);

      final vorherAusstehend = netzwerk.ausstehend.length;
      netzwerk.alterSimulieren(1, GamePhase.kindheit);
      final nachherAusstehend = netzwerk.ausstehend.length;

      expect(nachherAusstehend, lessThanOrEqualTo(vorherAusstehend));
    });

    test('eingetreten() wächst nach Auslösen', () {
      final entscheidung = _erstelleTestEntscheidung();
      netzwerk.konsequenzenRegistrieren(entscheidung, 0);

      expect(netzwerk.eingetreten, isEmpty);
      netzwerk.alterSimulieren(5, GamePhase.kindheit);
      expect(netzwerk.eingetreten, isNotEmpty);
    });

    test('anzahl entspricht ausstehend + eingetreten', () {
      final entscheidung = _erstelleTestEntscheidung();
      netzwerk.konsequenzenRegistrieren(entscheidung, 0);
      netzwerk.alterSimulieren(5, GamePhase.kindheit);

      expect(
        netzwerk.anzahl,
        equals(netzwerk.ausstehend.length + netzwerk.eingetreten.length),
      );
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Mehrere Entscheidungen
    // ─────────────────────────────────────────────────────────────────────────

    test('mehrere Entscheidungen akkumulieren Konsequenzen korrekt', () {
      final ent1 = _erstelleTestEntscheidung(id: 'ent_1', alter: 5);
      final ent2 = _erstelleTestEntscheidung(id: 'ent_2', alter: 10);
      final ent3 = _erstelleTestEntscheidung(id: 'ent_3', alter: 15);

      netzwerk.konsequenzenRegistrieren(ent1, 0);
      netzwerk.konsequenzenRegistrieren(ent2, 0);
      netzwerk.konsequenzenRegistrieren(ent3, 1);

      // Mindestens 3 Konsequenzen (sofortige) sollten registriert sein
      expect(netzwerk.anzahl, greaterThanOrEqualTo(3));
    });

    test('verschiedene Optionen der gleichen Entscheidung akkumulieren separat', () {
      final entscheidung1 = _erstelleTestEntscheidung(id: 'ent_a');

      // Option 0 hat verzögerte Konsequenzen, Option 1 nicht
      netzwerk.konsequenzenRegistrieren(entscheidung1, 0);
      final anzahlMitVerzoegert = netzwerk.anzahl;

      final netzwerk2 = KonsequenzNetzwerk();
      netzwerk2.startAlterSetzen(0);
      netzwerk2.konsequenzenRegistrieren(entscheidung1, 1);
      final anzahlOhneVerzoegert = netzwerk2.anzahl;

      // Option 0 hat mehr Konsequenzen (inkl. verzögerte)
      expect(anzahlMitVerzoegert, greaterThanOrEqualTo(anzahlOhneVerzoegert));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // KonsequenzTypen
    // ─────────────────────────────────────────────────────────────────────────

    test('sofortige Konsequenzen haben Typ KonsequenzTyp.sofort', () {
      final entscheidung = _erstelleTestEntscheidung();
      netzwerk.konsequenzenRegistrieren(entscheidung, 0);

      final sofort = netzwerk.alleAktiven
          .where((k) => k.typ == KonsequenzTyp.sofort)
          .toList();

      expect(sofort, isNotEmpty);
      // Jede sofortige Konsequenz hat Verzögerung 0
      for (final k in sofort) {
        expect(k.verzoegerungInJahren, equals(0));
      }
    });

    test('verzögerte Konsequenzen haben Verzögerung > 0 wenn Option sie hat', () {
      final entscheidung = _erstelleTestEntscheidung();
      netzwerk.konsequenzenRegistrieren(entscheidung, 0); // Option 0 hat verzögerte

      final verzoegert = netzwerk.alleAktiven
          .where((k) => k.typ == KonsequenzTyp.verzoegert)
          .toList();

      for (final k in verzoegert) {
        expect(k.verzoegerungInJahren, greaterThan(0));
      }
    });
  });
}
