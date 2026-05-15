// emotions_wetter_provider.dart
// Emotions-Wetter-Provider für GENESIS: Der Kreislauf des Lebens.
// Das Emotions-Wetter aktualisiert sich dynamisch basierend auf Glück, Stress,
// Liebe und Spiritualität und steuert alle visuellen Shader-Effekte im Spiel.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genesis_kreislauf_des_lebens/data/models/emotions_wetter_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EmotionsWetterNotifier – verwaltet den emotionalen Wetterzustand
// ─────────────────────────────────────────────────────────────────────────────

/// StateNotifier für das Emotions-Wetter-System.
///
/// Das Wetter reagiert auf vier emotionale Kernwerte (0.0–1.0) und
/// berechnet daraus Shader-Parameter für visuelle Effekte.
/// Übergänge zwischen Wettertypen können sanft animiert werden.
class EmotionsWetterNotifier extends StateNotifier<EmotionsWetterModel> {
  EmotionsWetterNotifier()
      : super(
          // Standard-Startzustand: klares, ruhiges Wetter
          EmotionsWetterModel.vonEmotion(
            glueck: 0.5,
            stress: 0.1,
            liebe: 0.4,
            spiritualitaet: 0.2,
          ),
        );

  // Timer für sanfte Übergänge
  Timer? _uebergangsTimer;

  // Aktuelle Zielwerte für laufende Übergänge
  EmotionsWetterModel? _zielWetter;

  // ───────────────────────────────────────────────────────────────────────────
  // Öffentliche Methoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Aktualisiert das Wetter sofort basierend auf vier emotionalen Kernwerten.
  ///
  /// Alle Eingabewerte sollten im Bereich [0.0, 1.0] liegen.
  /// Das Modell berechnet automatisch den passenden Wettertyp.
  ///
  /// - [glueck]: Allgemeines Wohlbefinden (0 = elend, 1 = euphorisch)
  /// - [stress]: Anspannung und Überforderung (0 = entspannt, 1 = überwältigt)
  /// - [liebe]: Verbundenheit und Wärme (0 = isoliert, 1 = tief geliebt)
  /// - [spiritualitaet]: Transzendenz und Sinn (0 = leer, 1 = erleuchtet)
  void wetterAktualisieren({
    required double glueck,
    required double stress,
    required double liebe,
    required double spiritualitaet,
  }) {
    // Laufenden Übergangs-Timer abbrechen
    _uebergangsTimer?.cancel();
    _uebergangsTimer = null;
    _zielWetter = null;

    state = EmotionsWetterModel.vonEmotion(
      glueck: glueck.clamp(0.0, 1.0),
      stress: stress.clamp(0.0, 1.0),
      liebe: liebe.clamp(0.0, 1.0),
      spiritualitaet: spiritualitaet.clamp(0.0, 1.0),
    );
  }

  /// Initiiert einen sanften Übergang zu einem Ziel-Wettertyp.
  ///
  /// Der Übergang erfolgt schrittweise über die angegebene [dauer].
  /// Dabei werden Intensität, Partikelwerte und Leuchtradius interpoliert.
  /// Der Wettertyp wechselt sofort, die Parameter gleiten sanft zum Ziel.
  ///
  /// [ziel] – der angestrebte Wettertyp
  /// [dauer] – die Gesamtdauer des Übergangs (z.B. const Duration(seconds: 3))
  void wetterUebergang(EmotionsWetterTyp ziel, Duration dauer) {
    // Ziel-Wetter basierend auf Typ berechnen
    _zielWetter = _standardWetterFuerTyp(ziel);
    final startWetter = state;
    final zielWetter = _zielWetter!;

    // Laufenden Timer abbrechen
    _uebergangsTimer?.cancel();

    // Übergang in 20 Schritten durchführen
    const schritte = 20;
    final schrittDauer =
        Duration(milliseconds: dauer.inMilliseconds ~/ schritte);
    int schritt = 0;

    _uebergangsTimer = Timer.periodic(schrittDauer, (timer) {
      schritt++;
      final fortschritt = schritt / schritte;

      if (!mounted) {
        timer.cancel();
        return;
      }

      if (schritt >= schritte) {
        // Übergang abgeschlossen – Zielwert setzen
        state = zielWetter;
        _zielWetter = null;
        timer.cancel();
        _uebergangsTimer = null;
        return;
      }

      // Lineare Interpolation der numerischen Parameter
      state = EmotionsWetterModel(
        // Typ wechselt sofort zum Ziel (visueller Schock wäre unerwünscht)
        typ: fortschritt > 0.5 ? zielWetter.typ : startWetter.typ,
        intensitaet: _lerp(
          startWetter.intensitaet,
          zielWetter.intensitaet,
          fortschritt,
        ),
        hauptfarbe: startWetter.hauptfarbe,
        nebenfarbe: startWetter.nebenfarbe,
        partikelDichte: _lerp(
          startWetter.partikelDichte,
          zielWetter.partikelDichte,
          fortschritt,
        ),
        windStaerke: _lerp(
          startWetter.windStaerke,
          zielWetter.windStaerke,
          fortschritt,
        ),
        // Blitzeffekt erst bei 80% des Übergangs aktivieren
        blitzEffekt: fortschritt > 0.8 ? zielWetter.blitzEffekt : false,
        leuchtenRadius: _lerp(
          startWetter.leuchtenRadius,
          zielWetter.leuchtenRadius,
          fortschritt,
        ),
      );
    });
  }

  /// Setzt das Wetter sofort auf den initialen Standardzustand zurück.
  void zuruecksetzen() {
    _uebergangsTimer?.cancel();
    _uebergangsTimer = null;
    _zielWetter = null;

    state = EmotionsWetterModel.vonEmotion(
      glueck: 0.5,
      stress: 0.1,
      liebe: 0.4,
      spiritualitaet: 0.2,
    );
  }

  @override
  void dispose() {
    _uebergangsTimer?.cancel();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Private Hilfsmethoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Lineare Interpolation zwischen zwei Werten.
  double _lerp(double start, double ziel, double t) {
    return start + (ziel - start) * t;
  }

  /// Erzeugt ein Standard-Wetter-Modell für einen gegebenen Wettertyp.
  ///
  /// Wird für Übergänge genutzt, wenn kein konkretes Ziel-Modell bekannt ist.
  EmotionsWetterModel _standardWetterFuerTyp(EmotionsWetterTyp typ) {
    return switch (typ) {
      EmotionsWetterTyp.sonnenschein => EmotionsWetterModel.vonEmotion(
          glueck: 0.8,
          stress: 0.1,
          liebe: 0.5,
          spiritualitaet: 0.3,
        ),
      EmotionsWetterTyp.regen => EmotionsWetterModel.vonEmotion(
          glueck: 0.2,
          stress: 0.5,
          liebe: 0.3,
          spiritualitaet: 0.1,
        ),
      EmotionsWetterTyp.gewitter => EmotionsWetterModel.vonEmotion(
          glueck: 0.1,
          stress: 0.8,
          liebe: 0.2,
          spiritualitaet: 0.2,
        ),
      EmotionsWetterTyp.warmesLeuchten => EmotionsWetterModel.vonEmotion(
          glueck: 0.7,
          stress: 0.1,
          liebe: 0.8,
          spiritualitaet: 0.4,
        ),
      EmotionsWetterTyp.kosmisch => EmotionsWetterModel.vonEmotion(
          glueck: 0.6,
          stress: 0.0,
          liebe: 0.7,
          spiritualitaet: 0.9,
        ),
      EmotionsWetterTyp.nebel => EmotionsWetterModel.vonEmotion(
          glueck: 0.2,
          stress: 0.3,
          liebe: 0.2,
          spiritualitaet: 0.1,
        ),
      EmotionsWetterTyp.sturm => EmotionsWetterModel.vonEmotion(
          glueck: 0.05,
          stress: 0.95,
          liebe: 0.1,
          spiritualitaet: 0.1,
        ),
      EmotionsWetterTyp.klar => EmotionsWetterModel.vonEmotion(
          glueck: 0.5,
          stress: 0.1,
          liebe: 0.4,
          spiritualitaet: 0.2,
        ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Emotions-Wetter-Provider – steuert alle visuellen Atmosphären-Effekte.
final emotionsWetterProvider =
    StateNotifierProvider<EmotionsWetterNotifier, EmotionsWetterModel>((ref) {
  return EmotionsWetterNotifier();
});

// ─────────────────────────────────────────────────────────────────────────────
// Shader-Parameter Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Bereitet alle Shader-Parameter als flache Map für GLSL-Shader auf.
///
/// Die zurückgegebene Map enthält benannte Werte (0.0–1.0 bzw. Pixel),
/// die direkt an Fragment-Shader übergeben werden können:
/// - `partikelDichte`: Dichte der Partikeleffekte
/// - `windStaerke`: Windstärke für Partikelbewegung
/// - `leuchtenRadius`: Radius des Leuchteffekts in logischen Pixeln
/// - `intensitaet`: Allgemeine Effektstärke
/// - `blitzEffekt`: 1.0 wenn Blitz aktiv, 0.0 wenn inaktiv
/// - `rH`, `rG`, `rB`: Hauptfarbe als RGB-Komponenten (0.0–1.0)
/// - `nH`, `nG`, `nB`: Nebenfarbe als RGB-Komponenten (0.0–1.0)
final shaderParamProvider = Provider<Map<String, double>>((ref) {
  final wetter = ref.watch(emotionsWetterProvider);

  // Farben aus dart:ui Color in 0.0–1.0 Komponenten zerlegen
  final haupt = wetter.hauptfarbe;
  final neben = wetter.nebenfarbe;

  return {
    // Partikel- und Bewegungsparameter
    'partikelDichte': wetter.partikelDichte,
    'windStaerke': wetter.windStaerke,
    'intensitaet': wetter.intensitaet,

    // Leuchteffekt-Parameter
    'leuchtenRadius': wetter.leuchtenRadius,

    // Blitzeffekt (binärer Wert als Float für GLSL)
    'blitzEffekt': wetter.blitzEffekt ? 1.0 : 0.0,

    // Hauptfarbe als normalisierte RGB-Komponenten
    'hauptR': haupt.red / 255.0,
    'hauptG': haupt.green / 255.0,
    'hauptB': haupt.blue / 255.0,
    'hauptA': haupt.alpha / 255.0,

    // Nebenfarbe als normalisierte RGB-Komponenten
    'nebenR': neben.red / 255.0,
    'nebenG': neben.green / 255.0,
    'nebenB': neben.blue / 255.0,
    'nebenA': neben.alpha / 255.0,
  };
});

/// Gibt nur den aktuellen Wettertyp zurück (für Typ-basierte UI-Logik).
final wetterTypProvider = Provider<EmotionsWetterTyp>((ref) {
  return ref.watch(emotionsWetterProvider).typ;
});

/// Gibt zurück, ob aktuell ein Blitzeffekt aktiv ist.
final blitzEffektAktivProvider = Provider<bool>((ref) {
  return ref.watch(emotionsWetterProvider).blitzEffekt;
});

/// Gibt die aktuelle Partikelwichte für animierte Partikelsysteme zurück.
final partikelDichteProvider = Provider<double>((ref) {
  return ref.watch(emotionsWetterProvider).partikelDichte;
});

/// Gibt den aktuellen Leuchtradius für Glow-Effekte zurück.
final leuchtenRadiusProvider = Provider<double>((ref) {
  return ref.watch(emotionsWetterProvider).leuchtenRadius;
});
