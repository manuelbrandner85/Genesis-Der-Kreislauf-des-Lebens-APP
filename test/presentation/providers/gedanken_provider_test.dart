// gedanken_provider_test.dart
// Tests für den GedankenProvider und GedankenNotifier.
// Prüft CRUD-Operationen, Filtering und Karma-Gericht-Auswahl.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/gedanken_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hilfsfunktionen
// ─────────────────────────────────────────────────────────────────────────────

GedankeModel _erstelleGedanke({
  String id = 'g_001',
  GedankenTyp typ = GedankenTyp.ueberzeugung,
  double intensitaet = 0.5,
  bool istGiftig = false,
  bool istAbgeschlossen = false,
  List<String> themen = const ['test'],
}) {
  return GedankeModel(
    id: id,
    inhalt: 'Ein Testgedanke',
    typ: typ,
    intensitaet: intensitaet,
    istAbgeschlossen: istAbgeschlossen,
    istGiftig: istGiftig,
    entstanden: DateTime(2024, 1, 1),
    ausloesende_themen: themen,
    wirdMitgenommen: false,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('GedankenProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Initialzustand
    // ─────────────────────────────────────────────────────────────────────────

    test('startet mit leerer Gedankenliste', () {
      final gedanken = container.read(gedankenProvider);
      expect(gedanken, isEmpty);
    });

    test('gedankenAnzahlProvider liefert 0 im Initialzustand', () {
      expect(container.read(gedankenAnzahlProvider), equals(0));
    });

    test('giftigeGedankenAnzahlProvider liefert 0 im Initialzustand', () {
      expect(container.read(giftigeGedankenAnzahlProvider), equals(0));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Hinzufügen
    // ─────────────────────────────────────────────────────────────────────────

    group('gedankeHinzufuegen()', () {
      test('fügt einen Gedanken hinzu', () {
        container.read(gedankenProvider.notifier).gedankeHinzufuegen(
          _erstelleGedanke(),
        );
        expect(container.read(gedankenProvider).length, equals(1));
      });

      test('ignoriert Duplikate mit gleicher ID', () {
        final gedanke = _erstelleGedanke();
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(gedanke);
        notifier.gedankeHinzufuegen(gedanke); // Duplikat
        expect(container.read(gedankenProvider).length, equals(1));
      });

      test('verschiedene IDs werden separat gespeichert', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_001'));
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_002'));
        expect(container.read(gedankenProvider).length, equals(2));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Setzen und Löschen
    // ─────────────────────────────────────────────────────────────────────────

    group('gedankenSetzen()', () {
      test('ersetzt alle Gedanken mit der neuen Liste', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'alt'));
        notifier.gedankenSetzen([
          _erstelleGedanke(id: 'neu_1'),
          _erstelleGedanke(id: 'neu_2'),
        ]);
        expect(container.read(gedankenProvider).length, equals(2));
        expect(
          container.read(gedankenProvider).any((g) => g.id == 'alt'),
          isFalse,
        );
      });
    });

    group('alleLoeschen()', () {
      test('leert das Inventar vollständig', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_001'));
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_002'));
        notifier.alleLoeschen();
        expect(container.read(gedankenProvider), isEmpty);
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Abschließen und Entfernen
    // ─────────────────────────────────────────────────────────────────────────

    group('gedankeAbschliessen()', () {
      test('markiert Gedanken als abgeschlossen', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_001'));
        notifier.gedankeAbschliessen('g_001');
        final gedanken = container.read(gedankenProvider);
        expect(gedanken.first.istAbgeschlossen, isTrue);
      });

      test('bleibt im Inventar nach Abschließen', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_001'));
        notifier.gedankeAbschliessen('g_001');
        expect(container.read(gedankenProvider).length, equals(1));
      });
    });

    group('gedankeEntfernen()', () {
      test('entfernt Gedanken vollständig', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_001'));
        notifier.gedankeEntfernen('g_001');
        expect(container.read(gedankenProvider), isEmpty);
      });

      test('lässt andere Gedanken unberührt', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_001'));
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_002'));
        notifier.gedankeEntfernen('g_001');
        expect(container.read(gedankenProvider).length, equals(1));
        expect(container.read(gedankenProvider).first.id, equals('g_002'));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Mitnahme-Toggle
    // ─────────────────────────────────────────────────────────────────────────

    group('mitnahmeToggle()', () {
      test('toggelt wirdMitgenommen auf true', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_001'));
        notifier.mitnahmeToggle('g_001');
        expect(container.read(gedankenProvider).first.wirdMitgenommen, isTrue);
      });

      test('zweifaches Toggling kehrt zum Ausgangszustand zurück', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_001'));
        notifier.mitnahmeToggle('g_001');
        notifier.mitnahmeToggle('g_001');
        expect(container.read(gedankenProvider).first.wirdMitgenommen, isFalse);
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Ausgelöste Themen
    // ─────────────────────────────────────────────────────────────────────────

    group('ausloesendeFinden()', () {
      test('findet Gedanken mit übereinstimmendem Thema', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(
          _erstelleGedanke(id: 'g_001', themen: ['verlust', 'trauer']),
        );
        notifier.gedankeHinzufuegen(
          _erstelleGedanke(id: 'g_002', themen: ['freude']),
        );
        final gefunden = notifier.ausloesendeFinden('verlust');
        expect(gefunden.length, equals(1));
        expect(gefunden.first.id, equals('g_001'));
      });

      test('gibt leere Liste zurück wenn kein Thema passt', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(themen: ['freude']));
        expect(notifier.ausloesendeFinden('tod'), isEmpty);
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Karma-Gericht Auswahl
    // ─────────────────────────────────────────────────────────────────────────

    group('fuerKarmaGerichtAuswaehlen()', () {
      test('gibt maximal 3 Gedanken zurück', () {
        final notifier = container.read(gedankenProvider.notifier);
        for (int i = 0; i < 10; i++) {
          notifier.gedankeHinzufuegen(
            _erstelleGedanke(id: 'g_$i', intensitaet: i * 0.1),
          );
        }
        final ausgewaehlt = notifier.fuerKarmaGerichtAuswaehlen();
        expect(ausgewaehlt.length, lessThanOrEqualTo(3));
      });

      test('gibt leere Liste zurück wenn alle abgeschlossen', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(
          _erstelleGedanke(id: 'g_001', istAbgeschlossen: true),
        );
        expect(notifier.fuerKarmaGerichtAuswaehlen(), isEmpty);
      });

      test('bevorzugt Gedanken mit höchster Intensität', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(
          _erstelleGedanke(id: 'niedrig', intensitaet: 0.1),
        );
        notifier.gedankeHinzufuegen(
          _erstelleGedanke(id: 'hoch', intensitaet: 0.95),
        );
        notifier.gedankeHinzufuegen(
          _erstelleGedanke(id: 'mittel', intensitaet: 0.5),
        );
        final ausgewaehlt = notifier.fuerKarmaGerichtAuswaehlen();
        // Erster Eintrag sollte der mit höchster Intensität sein
        expect(ausgewaehlt.first.id, equals('hoch'));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Abgeleitete Provider
    // ─────────────────────────────────────────────────────────────────────────

    group('abgeleitete Provider', () {
      test('giftigeGedankenProvider gibt nur toxische Gedanken zurück', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'normal', istGiftig: false));
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'giftig', istGiftig: true));
        final giftige = container.read(giftigeGedankenProvider);
        expect(giftige.length, equals(1));
        expect(giftige.first.id, equals('giftig'));
      });

      test('abgeschlosseneGedankenProvider gibt nur abgeschlossene zurück', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'offen'));
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'fertig', istAbgeschlossen: true));
        final abgeschlossene = container.read(abgeschlosseneGedankenProvider);
        expect(abgeschlossene.length, equals(1));
        expect(abgeschlossene.first.id, equals('fertig'));
      });

      test('aktiveGedankenProvider gibt nur nicht-abgeschlossene zurück', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'offen'));
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'fertig', istAbgeschlossen: true));
        final aktive = container.read(aktiveGedankenProvider);
        expect(aktive.length, equals(1));
        expect(aktive.first.id, equals('offen'));
      });

      test('mitgenommeneGedankenProvider gibt nur markierte Gedanken zurück', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_001'));
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_002'));
        notifier.mitnahmeSetzen('g_001', wirdMitgenommen: true);
        final mitgenommen = container.read(mitgenommeneGedankenProvider);
        expect(mitgenommen.length, equals(1));
        expect(mitgenommen.first.id, equals('g_001'));
      });

      test('gedankenNachTypProvider filtert nach Typ korrekt', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(
          _erstelleGedanke(id: 'trauma', typ: GedankenTyp.trauma),
        );
        notifier.gedankeHinzufuegen(
          _erstelleGedanke(id: 'weisheit', typ: GedankenTyp.weisheit),
        );
        final traumaGedanken =
            container.read(gedankenNachTypProvider(GedankenTyp.trauma));
        expect(traumaGedanken.length, equals(1));
        expect(traumaGedanken.first.id, equals('trauma'));
      });

      test('gedankenIntensitaetDurchschnittProvider berechnet Durchschnitt', () {
        final notifier = container.read(gedankenProvider.notifier);
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_1', intensitaet: 0.4));
        notifier.gedankeHinzufuegen(_erstelleGedanke(id: 'g_2', intensitaet: 0.8));
        final durchschnitt =
            container.read(gedankenIntensitaetDurchschnittProvider);
        expect(durchschnitt, closeTo(0.6, 0.001));
      });

      test('gedankenIntensitaetDurchschnittProvider gibt 0.0 bei leerer Liste', () {
        final durchschnitt =
            container.read(gedankenIntensitaetDurchschnittProvider);
        expect(durchschnitt, equals(0.0));
      });
    });
  });
}
