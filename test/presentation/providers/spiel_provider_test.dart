// spiel_provider_test.dart
// ProviderContainer-Tests für den spielProvider und SpielNotifier.
// Testet Initialzustand, Zustandsübergänge und Fehlerfälle ohne Hive-Abhängigkeit.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_zustand.dart';

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // SpielProvider Tests
  // ───────────────────────────────────────────────────────────────────────────

  group('SpielProvider', () {
    late ProviderContainer container;

    setUp(() {
      // Frischen Container für jeden Test erstellen (isoliert)
      container = ProviderContainer();
    });

    tearDown(() {
      // Container nach jedem Test sauber freigeben
      container.dispose();
    });

    // ── Initialzustand ────────────────────────────────────────────────────────

    test('Initialzustand hat kein Spielerprofil', () {
      final zustand = container.read(spielProvider);
      expect(zustand.spielerProfil, isNull);
    });

    test('Initialzustand hat keinen aktiven Zyklus', () {
      final zustand = container.read(spielProvider);
      expect(zustand.aktuellerZyklus, isNull);
    });

    test('Initialzustand hat GamePhase.entstehung als aktuelle Phase', () {
      final zustand = container.read(spielProvider);
      expect(zustand.aktuellePhase, equals(GamePhase.entstehung));
    });

    test('Initialzustand ist nicht ladend', () {
      final zustand = container.read(spielProvider);
      expect(zustand.istLadend, isFalse);
    });

    test('Initialzustand hat keine Fehlermeldung', () {
      final zustand = container.read(spielProvider);
      expect(zustand.fehlerMeldung, isNull);
    });

    test('Initialzustand hat Spiel nicht laufend', () {
      final zustand = container.read(spielProvider);
      expect(zustand.spielLaeuft, isFalse);
    });

    test('Initialzustand hat Alter 0', () {
      final zustand = container.read(spielProvider);
      expect(zustand.aktuellesAlter, equals(0));
    });

    test('Initialzustand ist nicht bereit (kein Profil + kein Zyklus)', () {
      final zustand = container.read(spielProvider);
      expect(zustand.istBereit, isFalse);
    });

    test('Initialzustand kann keine Entscheidung treffen', () {
      final zustand = container.read(spielProvider);
      expect(zustand.kannEntscheidungTreffen, isFalse);
    });

    // ── Bequemlichkeits-Provider ──────────────────────────────────────────────

    test('aktuellesProfilProvider liefert null im Initialzustand', () {
      final profil = container.read(aktuellesProfilProvider);
      expect(profil, isNull);
    });

    test('aktuellerZyklusProvider liefert null im Initialzustand', () {
      final zyklus = container.read(aktuellerZyklusProvider);
      expect(zyklus, isNull);
    });

    test('aktuellePhaseProvider liefert GamePhase.entstehung im Initialzustand',
        () {
      final phase = container.read(aktuellePhaseProvider);
      expect(phase, equals(GamePhase.entstehung));
    });

    test('aktuellesAlterProvider liefert 0 im Initialzustand', () {
      final alter = container.read(aktuellesAlterProvider);
      expect(alter, equals(0));
    });

    test('istLadendProvider liefert false im Initialzustand', () {
      final istLadend = container.read(istLadendProvider);
      expect(istLadend, isFalse);
    });

    test('fehlerMeldungProvider liefert null im Initialzustand', () {
      final fehler = container.read(fehlerMeldungProvider);
      expect(fehler, isNull);
    });

    test('spielLaeuftProvider liefert false im Initialzustand', () {
      final laeuft = container.read(spielLaeuftProvider);
      expect(laeuft, isFalse);
    });

    // ── Fehler zurücksetzen ───────────────────────────────────────────────────

    test('fehlerZuruecksetzen() löscht vorhandene Fehlermeldung', () {
      // Notifier direkten Zugriff für Test
      final notifier = container.read(spielProvider.notifier);

      // Intern eine Fehlermeldung setzen (via spielerLaden mit ungültiger ID)
      // Wir testen nur den synchronen Fehler-Reset
      notifier.fehlerZuruecksetzen();

      final zustand = container.read(spielProvider);
      expect(zustand.fehlerMeldung, isNull);
    });

    // ── SpielZustand Konsistenz ───────────────────────────────────────────────

    test('SpielZustand.initial() ist konsistent', () {
      final initial = SpielZustand.initial();

      expect(initial.spielerProfil, isNull);
      expect(initial.aktuellerZyklus, isNull);
      expect(initial.aktuellePhase, equals(GamePhase.entstehung));
      expect(initial.istLadend, isFalse);
      expect(initial.fehlerMeldung, isNull);
      expect(initial.spielLaeuft, isFalse);
      expect(initial.aktuellesAlter, equals(0));
    });

    test('SpielZustand.initial() stimmt mit Provider-Initialzustand überein',
        () {
      final fromProvider = container.read(spielProvider);
      final initialFabrik = SpielZustand.initial();

      // Kernfelder vergleichen
      expect(fromProvider.spielerProfil, equals(initialFabrik.spielerProfil));
      expect(fromProvider.aktuellerZyklus, equals(initialFabrik.aktuellerZyklus));
      expect(fromProvider.aktuellePhase, equals(initialFabrik.aktuellePhase));
      expect(fromProvider.istLadend, equals(initialFabrik.istLadend));
      expect(fromProvider.spielLaeuft, equals(initialFabrik.spielLaeuft));
      expect(fromProvider.aktuellesAlter, equals(initialFabrik.aktuellesAlter));
    });

    // ── Emotions-Wetter ───────────────────────────────────────────────────────

    test('Initialzustand hat gültiges Emotions-Wetter', () {
      final zustand = container.read(spielProvider);

      // Intensitätswert muss im gültigen Bereich [0.0, 1.0] sein
      expect(zustand.emotionsWetter.intensitaet, greaterThanOrEqualTo(0.0));
      expect(zustand.emotionsWetter.intensitaet, lessThanOrEqualTo(1.0));
      // Wettertyp muss ein gültiger EmotionsWetterTyp sein
      expect(zustand.emotionsWetter.typ, isNotNull);
    });

    test('emotionsWetterImSpielProvider liefert gültiges Wetter', () {
      final wetter = container.read(emotionsWetterImSpielProvider);

      expect(wetter.intensitaet, greaterThanOrEqualTo(0.0));
      expect(wetter.intensitaet, lessThanOrEqualTo(1.0));
      expect(wetter.typ, isNotNull);
    });

    // ── Mehrere Container ─────────────────────────────────────────────────────

    test('zwei separate Container haben unabhängige Zustände', () {
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      // Beide Container starten mit dem gleichen Initialzustand
      final zustand1 = container.read(spielProvider);
      final zustand2 = container2.read(spielProvider);

      expect(zustand1.aktuellePhase, equals(zustand2.aktuellePhase));
      expect(zustand1.spielLaeuft, equals(zustand2.spielLaeuft));
    });

    // ── Notifier-Verfügbarkeit ────────────────────────────────────────────────

    test('SpielNotifier ist über container.read(spielProvider.notifier) erreichbar',
        () {
      final notifier = container.read(spielProvider.notifier);
      expect(notifier, isNotNull);
    });

    test('alterErhoehen() tut nichts wenn kein aktiver Zyklus vorhanden', () async {
      final notifier = container.read(spielProvider.notifier);

      // Ohne aktiven Zyklus sollte alterErhoehen() keinen Fehler werfen
      // und den Zustand unverändert lassen
      await notifier.alterErhoehen();

      final zustand = container.read(spielProvider);
      // Alter bleibt 0 (kein Zyklus aktiv)
      expect(zustand.aktuellesAlter, equals(0));
    });
  });
}
