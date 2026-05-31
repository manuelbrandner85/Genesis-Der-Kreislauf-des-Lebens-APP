// soundtrack_engine_test.dart
// Tests für die SoundtrackEngine und das SoundtrackProfil.
// Testet Schicht-Zuweisung, Profil-Berechnung und Sterbesequenz-Auswahl.

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/engines/soundtrack_engine.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/emotions_wetter_model.dart';

void main() {
  group('SoundtrackEngine', () {
    late SoundtrackEngine engine;

    setUp(() {
      engine = SoundtrackEngine();
    });

    // ─────────────────────────────────────────────────────────────────────────
    // aktiveSchichtenBerechnen
    // ─────────────────────────────────────────────────────────────────────────

    group('aktiveSchichtenBerechnen()', () {
      test('gibt immer eine Basis-Schicht zurück', () {
        final schichten = engine.aktiveSchichtenBerechnen(
          phase: GamePhase.kindheit,
          wetter: EmotionsWetterTyp.klar,
          istPruefung: false,
        );
        expect(schichten.containsKey(SoundtrackSchicht.basis), isTrue);
      });

      test('gibt Spannungs-Schicht zurück wenn istPruefung == true', () {
        final schichten = engine.aktiveSchichtenBerechnen(
          phase: GamePhase.erwachsen,
          wetter: EmotionsWetterTyp.sonnenschein,
          istPruefung: true,
        );
        expect(schichten.containsKey(SoundtrackSchicht.spannung), isTrue);
      });

      test('gibt KEINE Spannungs-Schicht ohne Prüfung', () {
        final schichten = engine.aktiveSchichtenBerechnen(
          phase: GamePhase.jugend,
          wetter: EmotionsWetterTyp.klar,
          istPruefung: false,
        );
        expect(schichten.containsKey(SoundtrackSchicht.spannung), isFalse);
      });

      test('Gewitter-Wetter überschreibt Emotions-Schicht', () {
        final schichten = engine.aktiveSchichtenBerechnen(
          phase: GamePhase.reife,
          wetter: EmotionsWetterTyp.gewitter,
          istPruefung: false,
        );
        // Emotions-Layer sollte vorhanden sein (mit Gewitter-Musik)
        expect(schichten.containsKey(SoundtrackSchicht.emotion), isTrue);
        final datei = schichten[SoundtrackSchicht.emotion] ?? '';
        expect(datei, isNotEmpty);
      });

      test('Basis-Track-Dateipfade sind nicht leer', () {
        for (final phase in GamePhase.values) {
          final schichten = engine.aktiveSchichtenBerechnen(
            phase: phase,
            wetter: EmotionsWetterTyp.klar,
            istPruefung: false,
          );
          final basis = schichten[SoundtrackSchicht.basis];
          if (basis != null) {
            expect(basis, isNotEmpty, reason: 'Basis-Track für ${phase.name} ist leer');
          }
        }
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // profilBerechnen
    // ─────────────────────────────────────────────────────────────────────────

    group('profilBerechnen()', () {
      test('sehr positives Karma → epische Stimmung', () {
        final profil = engine.profilBerechnen(
          karmaDurchschnitt: 80.0,
          dominanteDimensionWert: 90.0,
          zyklusNummer: 3,
        );
        expect(profil.dominanteStimmung, equals(SoundtrackStimmung.episch));
      });

      test('moderat positives Karma → warmHerzlich Stimmung', () {
        final profil = engine.profilBerechnen(
          karmaDurchschnitt: 40.0,
          dominanteDimensionWert: 50.0,
          zyklusNummer: 1,
        );
        expect(profil.dominanteStimmung, equals(SoundtrackStimmung.warmHerzlich));
      });

      test('neutrales Karma → mystisch Stimmung', () {
        final profil = engine.profilBerechnen(
          karmaDurchschnitt: 10.0,
          dominanteDimensionWert: 15.0,
          zyklusNummer: 1,
        );
        expect(profil.dominanteStimmung, equals(SoundtrackStimmung.mystisch));
      });

      test('negatives Karma → melancholisch Stimmung', () {
        final profil = engine.profilBerechnen(
          karmaDurchschnitt: -20.0,
          dominanteDimensionWert: -30.0,
          zyklusNummer: 2,
        );
        expect(profil.dominanteStimmung, equals(SoundtrackStimmung.melancholisch));
      });

      test('stark negatives Karma → dunkelSpannend Stimmung', () {
        final profil = engine.profilBerechnen(
          karmaDurchschnitt: -70.0,
          dominanteDimensionWert: -80.0,
          zyklusNummer: 1,
        );
        expect(profil.dominanteStimmung, equals(SoundtrackStimmung.dunkelSpannend));
      });

      test('positives Karma → Dur-Tonart', () {
        final profil = engine.profilBerechnen(
          karmaDurchschnitt: 30.0,
          dominanteDimensionWert: 40.0,
          zyklusNummer: 1,
        );
        expect(profil.isDurTonart, isTrue);
      });

      test('negatives Karma → Moll-Tonart', () {
        final profil = engine.profilBerechnen(
          karmaDurchschnitt: -30.0,
          dominanteDimensionWert: -50.0,
          zyklusNummer: 1,
        );
        expect(profil.isDurTonart, isFalse);
      });

      test('Intensität ist im Bereich [0.0, 1.0]', () {
        final profil = engine.profilBerechnen(
          karmaDurchschnitt: 50.0,
          dominanteDimensionWert: 150.0, // Extremwert – muss geclampt werden
          zyklusNummer: 1,
        );
        expect(profil.intensitaet, greaterThanOrEqualTo(0.0));
        expect(profil.intensitaet, lessThanOrEqualTo(1.0));
      });

      test('zyklusKomplexitaet entspricht dem übergebenen Zyklus-Nummer', () {
        final profil = engine.profilBerechnen(
          karmaDurchschnitt: 0.0,
          dominanteDimensionWert: 0.0,
          zyklusNummer: 7,
        );
        expect(profil.zyklusKomplexitaet, equals(7));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // sterbeSequenzSoundtrack
    // ─────────────────────────────────────────────────────────────────────────

    group('sterbeSequenzSoundtrack()', () {
      test('sehr positives Karma → friedlicher Tod-Track', () {
        final track = engine.sterbeSequenzSoundtrack(
          karmaDurchschnitt: 70.0,
          todesArt: 'alter',
        );
        expect(track, contains('frieden'));
      });

      test('stark negatives Karma → schwerer Tod-Track', () {
        final track = engine.sterbeSequenzSoundtrack(
          karmaDurchschnitt: -50.0,
          todesArt: 'unfall',
        );
        expect(track, contains('schwer'));
      });

      test('neutrales Karma → unentschlossener Tod-Track', () {
        final track = engine.sterbeSequenzSoundtrack(
          karmaDurchschnitt: 0.0,
          todesArt: 'krankheit',
        );
        expect(track, contains('unentschlossen'));
      });

      test('jeder Tod-Track ist ein gültiger Dateipfad', () {
        for (final karma in [-80.0, -10.0, 25.0, 75.0]) {
          final track = engine.sterbeSequenzSoundtrack(
            karmaDurchschnitt: karma,
            todesArt: 'test',
          );
          expect(track, startsWith('assets/audio/'));
          expect(track, endsWith('.mp3'));
        }
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SoundtrackProfil copyWith
    // ─────────────────────────────────────────────────────────────────────────

    group('SoundtrackProfil', () {
      test('copyWith ändert nur die angegebenen Felder', () {
        final profil = SoundtrackProfil(
          dominanteStimmung: SoundtrackStimmung.episch,
          intensitaet: 0.8,
          zyklusKomplexitaet: 3,
          isDurTonart: true,
        );
        final geaendert = profil.copyWith(intensitaet: 0.2);
        expect(geaendert.dominanteStimmung, equals(SoundtrackStimmung.episch));
        expect(geaendert.intensitaet, closeTo(0.2, 0.001));
        expect(geaendert.zyklusKomplexitaet, equals(3));
      });

      test('playlistTracks ist standardmäßig leer', () {
        final profil = SoundtrackProfil(
          dominanteStimmung: SoundtrackStimmung.mystisch,
          intensitaet: 0.5,
          zyklusKomplexitaet: 1,
          isDurTonart: true,
        );
        expect(profil.playlistTracks, isEmpty);
      });
    });
  });
}
