// beziehungs_provider_test.dart
// Tests für den BeziehungsProvider und BeziehungsNotifier.
// Prüft Beziehungs-CRUD, Vertrauensänderungen, Konflikte und geteilte Erinnerungen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/beziehung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/erinnerung_model.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/beziehungs_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hilfsfunktionen
// ─────────────────────────────────────────────────────────────────────────────

BeziehungModel _erstelleBeziehung({
  String id = 'b_001',
  String name = 'Max Mustermann',
  BeziehungsTyp typ = BeziehungsTyp.freund,
  double vertrauen = 50.0,
  double respekt = 50.0,
  double liebe = 30.0,
  double abhaengigkeit = 10.0,
  bool istEcht = false,
}) {
  return BeziehungModel(
    id: id,
    personName: name,
    typ: typ,
    vertrauen: vertrauen,
    respekt: respekt,
    liebe: liebe,
    abhaengigkeit: abhaengigkeit,
    geteilteErinnerungen: const [],
    istEcht: istEcht,
    istGeheilt: false,
    ungeloestKonflikte: const [],
  );
}

ErinnerungModel _erstelleErinnerung({String id = 'e_001'}) {
  return ErinnerungModel(
    id: id,
    titel: 'Gemeinsamer Moment',
    beschreibung: 'Ein schöner Augenblick.',
    alter: 25,
    phase: GamePhase.erwachsen,
    emotionaleIntensitaet: 0.7,
    typ: ErinnerungsTyp.freude,
    istKarmaGericht: false,
    istMitgenommen: false,
    beteiligte: ['Max Mustermann'],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('BeziehungsProvider', () {
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

    test('startet ohne Beziehungen', () {
      expect(container.read(beziehungsProvider), isEmpty);
    });

    test('beziehungsAnzahlProvider liefert 0', () {
      expect(container.read(beziehungsAnzahlProvider), equals(0));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Hinzufügen
    // ─────────────────────────────────────────────────────────────────────────

    group('beziehungHinzufuegen()', () {
      test('fügt eine Beziehung hinzu', () {
        container.read(beziehungsProvider.notifier)
            .beziehungHinzufuegen(_erstelleBeziehung());
        expect(container.read(beziehungsProvider).length, equals(1));
      });

      test('ignoriert Duplikate mit gleicher ID', () {
        final b = _erstelleBeziehung();
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(b);
        notifier.beziehungHinzufuegen(b);
        expect(container.read(beziehungsProvider).length, equals(1));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Vertrauen ändern
    // ─────────────────────────────────────────────────────────────────────────

    group('vertrauenAendern()', () {
      test('erhöht Vertrauen um den Delta-Wert', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(_erstelleBeziehung(vertrauen: 40.0));
        notifier.vertrauenAendern('b_001', 20.0);
        final b = container.read(beziehungsProvider).first;
        expect(b.vertrauen, closeTo(60.0, 0.001));
      });

      test('klemmt Vertrauen auf maximal 100.0', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(_erstelleBeziehung(vertrauen: 90.0));
        notifier.vertrauenAendern('b_001', 50.0);
        expect(container.read(beziehungsProvider).first.vertrauen, equals(100.0));
      });

      test('klemmt Vertrauen auf minimal 0.0', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(_erstelleBeziehung(vertrauen: 10.0));
        notifier.vertrauenAendern('b_001', -50.0);
        expect(container.read(beziehungsProvider).first.vertrauen, equals(0.0));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Heilen
    // ─────────────────────────────────────────────────────────────────────────

    group('beziehungHeilen()', () {
      test('setzt istGeheilt auf true', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(_erstelleBeziehung(vertrauen: 5.0));
        notifier.beziehungHeilen('b_001');
        expect(container.read(beziehungsProvider).first.istGeheilt, isTrue);
      });

      test('erhöht Vertrauen und Respekt um 20 Punkte', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(vertrauen: 20.0, respekt: 30.0),
        );
        notifier.beziehungHeilen('b_001');
        final b = container.read(beziehungsProvider).first;
        expect(b.vertrauen, closeTo(40.0, 0.001));
        expect(b.respekt, closeTo(50.0, 0.001));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Konflikte
    // ─────────────────────────────────────────────────────────────────────────

    group('Konflikte', () {
      test('konfliktHinzufuegen() fügt Konflikt hinzu und reduziert Vertrauen', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(_erstelleBeziehung(vertrauen: 60.0));
        notifier.konfliktHinzufuegen('b_001', 'Streit über Geld');
        final b = container.read(beziehungsProvider).first;
        expect(b.ungeloestKonflikte, contains('Streit über Geld'));
        expect(b.vertrauen, lessThan(60.0));
      });

      test('konfliktLoesen() entfernt Konflikt und erhöht Vertrauen/Respekt', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(_erstelleBeziehung(vertrauen: 40.0, respekt: 40.0));
        notifier.konfliktHinzufuegen('b_001', 'Missverständnis');
        notifier.konfliktLoesen('b_001', 'Missverständnis');
        final b = container.read(beziehungsProvider).first;
        expect(b.ungeloestKonflikte, isNot(contains('Missverständnis')));
        // Vertrauen nach Hinzufügen (-10) und Lösen (+8) = netto -2
        expect(b.vertrauen, lessThan(40.0)); // netto schlechter als Ausgangswert
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Erinnerungen teilen
    // ─────────────────────────────────────────────────────────────────────────

    group('erinnerungTeilen()', () {
      test('fügt Erinnerung zu geteilten Erinnerungen hinzu', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(_erstelleBeziehung());
        notifier.erinnerungTeilen('b_001', _erstelleErinnerung());
        final b = container.read(beziehungsProvider).first;
        expect(b.geteilteErinnerungen.length, equals(1));
      });

      test('ignoriert Duplikat-Erinnerungen', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(_erstelleBeziehung());
        final erinnerung = _erstelleErinnerung();
        notifier.erinnerungTeilen('b_001', erinnerung);
        notifier.erinnerungTeilen('b_001', erinnerung);
        expect(container.read(beziehungsProvider).first.geteilteErinnerungen.length,
            equals(1));
      });

      test('teilen einer Erinnerung erhöht Vertrauen leicht', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(_erstelleBeziehung(vertrauen: 50.0));
        notifier.erinnerungTeilen('b_001', _erstelleErinnerung());
        final b = container.read(beziehungsProvider).first;
        expect(b.vertrauen, greaterThan(50.0));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Beziehungsqualität
    // ─────────────────────────────────────────────────────────────────────────

    group('BeziehungsQualitaet', () {
      test('tiefVerbunden bei Stärke >= 75', () {
        final b = _erstelleBeziehung(
          vertrauen: 90.0, respekt: 90.0, liebe: 90.0, abhaengigkeit: 30.0,
        );
        expect(b.beziehungsQualitaet, equals(BeziehungsQualitaet.tiefVerbunden));
      });

      test('zerbrochen bei Stärke < 15', () {
        final b = _erstelleBeziehung(
          vertrauen: 5.0, respekt: 5.0, liebe: 5.0, abhaengigkeit: 0.0,
        );
        expect(b.beziehungsQualitaet, equals(BeziehungsQualitaet.zerbrochen));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Abgeleitete Provider
    // ─────────────────────────────────────────────────────────────────────────

    group('abgeleitete Provider', () {
      test('partnerProvider gibt Partner zurück', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(id: 'p_001', typ: BeziehungsTyp.partner),
        );
        expect(container.read(partnerProvider), isNotNull);
        expect(container.read(partnerProvider)!.typ, equals(BeziehungsTyp.partner));
      });

      test('partnerProvider gibt null ohne Partner', () {
        expect(container.read(partnerProvider), isNull);
      });

      test('familieProvider gibt Familienmitglieder zurück', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(id: 'e_001', typ: BeziehungsTyp.elternteil),
        );
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(id: 'g_001', typ: BeziehungsTyp.geschwister),
        );
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(id: 'f_001', typ: BeziehungsTyp.freund),
        );
        expect(container.read(familieProvider).length, equals(2));
      });

      test('echtePersonenProvider gibt nur echte Mitspieler zurück', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(id: 'npc', istEcht: false),
        );
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(id: 'real', istEcht: true),
        );
        expect(container.read(echtePersonenProvider).length, equals(1));
      });

      test('antagonistenProvider gibt Rivalen und Feinde zurück', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(id: 'r_001', typ: BeziehungsTyp.rivale),
        );
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(id: 'f_001', typ: BeziehungsTyp.feind),
        );
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(id: 'fr_001', typ: BeziehungsTyp.freund),
        );
        expect(container.read(antagonistenProvider).length, equals(2));
      });

      test('wichtigsteBeziehungProvider gibt Beziehung mit höchster Stärke zurück',
          () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(id: 'schwach', vertrauen: 10.0, respekt: 10.0),
        );
        notifier.beziehungHinzufuegen(
          _erstelleBeziehung(id: 'stark', vertrauen: 90.0, respekt: 90.0),
        );
        final wichtigste = container.read(wichtigsteBeziehungProvider);
        expect(wichtigste?.id, equals('stark'));
      });

      test('durchschnittlicheBeziehungsStaerkeProvider berechnet Durchschnitt', () {
        final notifier = container.read(beziehungsProvider.notifier);
        // Beziehung 1: (100+100+100+100)/4 = 100
        notifier.beziehungHinzufuegen(_erstelleBeziehung(
          id: 'b1', vertrauen: 100.0, respekt: 100.0, liebe: 100.0, abhaengigkeit: 100.0,
        ));
        // Beziehung 2: (0+0+0+0)/4 = 0
        notifier.beziehungHinzufuegen(_erstelleBeziehung(
          id: 'b2', vertrauen: 0.0, respekt: 0.0, liebe: 0.0, abhaengigkeit: 0.0,
        ));
        final durchschnitt = container.read(durchschnittlicheBeziehungsStaerkeProvider);
        expect(durchschnitt, closeTo(50.0, 0.001));
      });

      test('konfliktBeziehungenProvider gibt nur Beziehungen mit Konflikten zurück', () {
        final notifier = container.read(beziehungsProvider.notifier);
        notifier.beziehungHinzufuegen(_erstelleBeziehung(id: 'ohne'));
        notifier.beziehungHinzufuegen(_erstelleBeziehung(id: 'mit'));
        notifier.konfliktHinzufuegen('mit', 'Streit');
        expect(container.read(konfliktBeziehungenProvider).length, equals(1));
        expect(container.read(konfliktBeziehungenProvider).first.id, equals('mit'));
      });
    });
  });
}
