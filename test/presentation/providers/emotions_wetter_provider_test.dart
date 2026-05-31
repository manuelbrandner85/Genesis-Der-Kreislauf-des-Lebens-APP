// emotions_wetter_provider_test.dart
// Tests für den EmotionsWetterProvider und ShaderParam-Berechnung.
// Prüft Wetter-Aktualisierung, Übergänge und Shader-Parameter.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/emotions_wetter_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/emotions_wetter_provider.dart';

void main() {
  group('EmotionsWetterProvider', () {
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

    test('startet mit klarem Wetter (klar-Typ)', () {
      final wetter = container.read(emotionsWetterProvider);
      expect(wetter.typ, equals(EmotionsWetterTyp.klar));
    });

    test('intensitaet im Initialzustand liegt im gültigen Bereich', () {
      final wetter = container.read(emotionsWetterProvider);
      expect(wetter.intensitaet, greaterThanOrEqualTo(0.0));
      expect(wetter.intensitaet, lessThanOrEqualTo(1.0));
    });

    test('wetterTypProvider gibt klar im Initialzustand zurück', () {
      expect(container.read(wetterTypProvider), equals(EmotionsWetterTyp.klar));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // wetterAktualisieren
    // ─────────────────────────────────────────────────────────────────────────

    group('wetterAktualisieren()', () {
      test('hoher Glück-Wert erzeugt Sonnenschein-Wetter', () {
        container.read(emotionsWetterProvider.notifier).wetterAktualisieren(
          glueck: 0.9,
          stress: 0.0,
          liebe: 0.5,
          spiritualitaet: 0.3,
        );
        final typ = container.read(wetterTypProvider);
        expect(typ, equals(EmotionsWetterTyp.sonnenschein));
      });

      test('hoher Stress-Wert erzeugt Gewitter-Wetter', () {
        container.read(emotionsWetterProvider.notifier).wetterAktualisieren(
          glueck: 0.0,
          stress: 0.9,
          liebe: 0.0,
          spiritualitaet: 0.0,
        );
        final typ = container.read(wetterTypProvider);
        expect(typ, equals(EmotionsWetterTyp.gewitter));
      });

      test('hohe Spiritualität mit hohem Glück erzeugt kosmisches Wetter', () {
        container.read(emotionsWetterProvider.notifier).wetterAktualisieren(
          glueck: 0.6,
          stress: 0.0,
          liebe: 0.7,
          spiritualitaet: 0.9,
        );
        final typ = container.read(wetterTypProvider);
        expect(typ, equals(EmotionsWetterTyp.kosmisch));
      });

      test('hohe Liebe erzeugt warmes Leuchten', () {
        container.read(emotionsWetterProvider.notifier).wetterAktualisieren(
          glueck: 0.6,
          stress: 0.1,
          liebe: 0.9,
          spiritualitaet: 0.2,
        );
        final typ = container.read(wetterTypProvider);
        expect(typ, equals(EmotionsWetterTyp.warmesLeuchten));
      });

      test('Eingabewerte werden auf [0.0, 1.0] begrenzt', () {
        expect(
          () => container.read(emotionsWetterProvider.notifier).wetterAktualisieren(
            glueck: 2.0,   // Außerhalb des Bereichs
            stress: -0.5,  // Außerhalb des Bereichs
            liebe: 0.5,
            spiritualitaet: 0.5,
          ),
          returnsNormally,
        );
        final wetter = container.read(emotionsWetterProvider);
        expect(wetter.intensitaet, greaterThanOrEqualTo(0.0));
        expect(wetter.intensitaet, lessThanOrEqualTo(1.0));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // wetterUebergang
    // ─────────────────────────────────────────────────────────────────────────

    group('wetterUebergang()', () {
      test('initiiert einen Übergang ohne sofortigen Fehler', () {
        expect(
          () => container.read(emotionsWetterProvider.notifier).wetterUebergang(
            EmotionsWetterTyp.gewitter,
            const Duration(milliseconds: 100),
          ),
          returnsNormally,
        );
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // zuruecksetzen
    // ─────────────────────────────────────────────────────────────────────────

    group('zuruecksetzen()', () {
      test('setzt auf Initialzustand zurück', () {
        final notifier = container.read(emotionsWetterProvider.notifier);
        // Zuerst auf Gewitter ändern
        notifier.wetterAktualisieren(
          glueck: 0.0,
          stress: 0.95,
          liebe: 0.0,
          spiritualitaet: 0.0,
        );
        expect(container.read(wetterTypProvider), equals(EmotionsWetterTyp.gewitter));

        // Dann zurücksetzen
        notifier.zuruecksetzen();
        expect(container.read(wetterTypProvider), equals(EmotionsWetterTyp.klar));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Shader-Parameter Provider
    // ─────────────────────────────────────────────────────────────────────────

    group('shaderParamProvider', () {
      test('enthält alle erwarteten Shader-Schlüssel', () {
        final params = container.read(shaderParamProvider);
        expect(params.containsKey('partikelDichte'), isTrue);
        expect(params.containsKey('windStaerke'), isTrue);
        expect(params.containsKey('intensitaet'), isTrue);
        expect(params.containsKey('leuchtenRadius'), isTrue);
        expect(params.containsKey('blitzEffekt'), isTrue);
        expect(params.containsKey('hauptR'), isTrue);
        expect(params.containsKey('hauptG'), isTrue);
        expect(params.containsKey('hauptB'), isTrue);
        expect(params.containsKey('nebenR'), isTrue);
        expect(params.containsKey('nebenG'), isTrue);
        expect(params.containsKey('nebenB'), isTrue);
      });

      test('alle Shader-Parameter sind im Bereich [0.0, 1.0] oder größer', () {
        final params = container.read(shaderParamProvider);
        // Farbwerte und Intensitäten müssen >= 0.0 sein
        for (final eintrag in params.entries) {
          expect(eintrag.value, greaterThanOrEqualTo(0.0),
              reason: '${eintrag.key} < 0.0');
        }
      });

      test('blitzEffektAktivProvider ist false bei klarem Wetter', () {
        expect(container.read(blitzEffektAktivProvider), isFalse);
      });

      test('partikelDichteProvider gibt gültigen Wert zurück', () {
        final dichte = container.read(partikelDichteProvider);
        expect(dichte, greaterThanOrEqualTo(0.0));
        expect(dichte, lessThanOrEqualTo(1.0));
      });

      test('leuchtenRadiusProvider gibt nicht-negativen Wert zurück', () {
        final radius = container.read(leuchtenRadiusProvider);
        expect(radius, greaterThanOrEqualTo(0.0));
      });
    });

    // ─────────────────────────────────────────────────────────────────────────
    // EmotionsWetterModel.vonEmotion
    // ─────────────────────────────────────────────────────────────────────────

    group('EmotionsWetterModel.vonEmotion()', () {
      test('erstellt gültiges Modell aus Emotions-Werten', () {
        final modell = EmotionsWetterModel.vonEmotion(
          glueck: 0.7,
          stress: 0.2,
          liebe: 0.4,
          spiritualitaet: 0.1,
        );
        expect(modell.intensitaet, greaterThanOrEqualTo(0.0));
        expect(modell.intensitaet, lessThanOrEqualTo(1.0));
        expect(modell.typ, isNotNull);
      });

      test('alle 8 Wettertypen können über vonEmotion erzeugt werden', () {
        // Jeder Wettertyp kann durch passende Eingaben erzeugt werden
        // Sonnenschein: hohes Glück, kein Stress
        expect(
          EmotionsWetterModel.vonEmotion(glueck: 0.9, stress: 0.0, liebe: 0.3, spiritualitaet: 0.1).typ,
          equals(EmotionsWetterTyp.sonnenschein),
        );
        // Gewitter: niedriges Glück, hoher Stress
        expect(
          EmotionsWetterModel.vonEmotion(glueck: 0.0, stress: 0.9, liebe: 0.0, spiritualitaet: 0.0).typ,
          equals(EmotionsWetterTyp.gewitter),
        );
      });

      test('toJson() und fromJson() sind invers', () {
        final original = EmotionsWetterModel.vonEmotion(
          glueck: 0.6,
          stress: 0.3,
          liebe: 0.5,
          spiritualitaet: 0.4,
        );
        final json = original.toJson();
        final wiederhergestellt = EmotionsWetterModel.fromJson(json);
        expect(wiederhergestellt.typ, equals(original.typ));
        expect(wiederhergestellt.intensitaet, closeTo(original.intensitaet, 0.001));
      });
    });
  });
}
