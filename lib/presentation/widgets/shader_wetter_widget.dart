// shader_wetter_widget.dart
// Shader-basiertes Emotions-Wetter-Overlay für GENESIS: Der Kreislauf des Lebens.
// Lädt den GLSL Fragment Shader (assets/shaders/emotions_wetter.frag) und
// übergibt die aktuellen Wetter-Uniform-Parameter an die GPU.
//
// Bei Fehler beim Laden des Shaders (z. B. auf Geräten ohne GLSL-Unterstützung)
// wird automatisch auf das rein-Dart-basierte EmotionsWetterWidget zurückgegriffen.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genesis_kreislauf_des_lebens/data/models/emotions_wetter_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/emotions_wetter_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/emotions_wetter_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShaderWetterWidget
// ─────────────────────────────────────────────────────────────────────────────

/// Halbtransparentes Shader-Overlay, das den GLSL Fragment Shader
/// `assets/shaders/emotions_wetter.frag` verwendet um das emotionale
/// Atmosphärenwetter des Charakters darzustellen.
///
/// Liest das aktuelle [EmotionsWetterModel] aus dem [emotionsWetterProvider]
/// und übergibt alle Uniform-Parameter an den Shader. Die Zeit-Uniform
/// wird kontinuierlich über einen [AnimationController] aktualisiert.
///
/// **Fallback-Verhalten:**
/// Wenn der Shader nicht geladen werden kann (fehlende Asset-Datei,
/// nicht unterstütztes Gerät), wird automatisch [EmotionsWetterWidget]
/// als rein-Dart-Implementierung verwendet.
///
/// Beispiel:
/// ```dart
/// Stack(
///   children: [
///     SpielInhalt(),
///     ShaderWetterWidget(),
///   ],
/// )
/// ```
class ShaderWetterWidget extends ConsumerStatefulWidget {
  /// Gibt an, ob das Overlay aktiv ist. Bei false kein Rendering.
  final bool istAktiv;

  const ShaderWetterWidget({
    super.key,
    this.istAktiv = true,
  });

  @override
  ConsumerState<ShaderWetterWidget> createState() => _ShaderWetterWidgetState();
}

class _ShaderWetterWidgetState extends ConsumerState<ShaderWetterWidget>
    with SingleTickerProviderStateMixin {
  // Der geladene GLSL Fragment Shader (null = noch nicht geladen oder Fehler)
  ui.FragmentShader? _shader;

  // AnimationController läuft unbegrenzt und liefert die Zeit-Uniform
  late AnimationController _zeitController;

  // Gibt an, ob der Shader-Ladeversuch abgeschlossen ist (egal ob Erfolg/Fehler)
  bool _ladeAbgeschlossen = false;

  // Gibt an, ob ein Lade-Fehler aufgetreten ist (→ Fallback aktivieren)
  bool _hatFehler = false;

  @override
  void initState() {
    super.initState();

    // Zeitanimation: läuft 10 Stunden durch (effektiv unendlich)
    // value * 36000 = Sekunden, was für uTime ausreicht
    _zeitController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 10),
    )..addListener(_aufAnimationAktualisieren);

    // Shader asynchron laden
    _shaderLaden();
  }

  @override
  void dispose() {
    _zeitController.dispose();
    super.dispose();
  }

  // ── Shader laden ──────────────────────────────────────────────────────────

  /// Lädt den GLSL Fragment Shader aus den Assets.
  /// Bei Erfolg: Shader wird gesetzt und Animation gestartet.
  /// Bei Fehler: _hatFehler wird true → EmotionsWetterWidget als Fallback.
  Future<void> _shaderLaden() async {
    try {
      // FragmentProgram aus der pubspec.yaml registrierten Shader-Datei laden
      final programm = await ui.FragmentProgram.fromAsset(
        'assets/shaders/emotions_wetter.frag',
      );

      // FragmentShader-Instanz erzeugen (Uniform-Slots vorbereiten)
      final shader = programm.fragmentShader();

      if (mounted) {
        setState(() {
          _shader = shader;
          _ladeAbgeschlossen = true;
        });

        // Zeitanimation nur starten wenn Widget aktiv ist
        if (widget.istAktiv) {
          _zeitController.repeat();
        }
      }
    } catch (fehler) {
      // Shader konnte nicht geladen werden → Fallback auf Dart-Widget
      debugPrint('[ShaderWetterWidget] Shader-Ladefehler: $fehler');
      if (mounted) {
        setState(() {
          _hatFehler = true;
          _ladeAbgeschlossen = true;
        });
      }
    }
  }

  /// Callback für jeden Animationsframe – löst einen Repaint aus.
  void _aufAnimationAktualisieren() {
    if (mounted && _shader != null) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(ShaderWetterWidget alt) {
    super.didUpdateWidget(alt);
    // Animation starten/stoppen wenn istAktiv sich ändert
    if (widget.istAktiv && !_zeitController.isAnimating && _shader != null) {
      _zeitController.repeat();
    } else if (!widget.istAktiv && _zeitController.isAnimating) {
      _zeitController.stop();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Nichts anzeigen wenn Overlay inaktiv
    if (!widget.istAktiv) return const SizedBox.shrink();

    // Wetter-Modell aus Provider lesen
    final wetter = ref.watch(emotionsWetterProvider);

    // Noch am Laden: Leeres SizedBox um Ruckeln zu vermeiden
    if (!_ladeAbgeschlossen) {
      return const SizedBox.shrink();
    }

    // Fehler oder Shader nicht verfügbar → Dart-Fallback
    if (_hatFehler || _shader == null) {
      return EmotionsWetterWidget(
        wetterModell: wetter,
        istAktiv: widget.istAktiv,
      );
    }

    // Shader verfügbar → GPU-beschleunigtes Rendering
    return IgnorePointer(
      // Overlay soll keine Touch-Events abfangen
      child: CustomPaint(
        painter: _ShaderWetterPainter(
          shader: _shader!,
          // Zeit in Sekunden: AnimationController.value * 36000
          time: _zeitController.value * 36000.0,
          wetter: wetter,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShaderWetterPainter
// ─────────────────────────────────────────────────────────────────────────────

/// CustomPainter, der den [ui.FragmentShader] mit allen Uniform-Parametern
/// befüllt und als vollflächiges Rechteck auf den Canvas zeichnet.
///
/// **Uniform-Slot-Zuordnung (Reihenfolge muss mit dem GLSL-Code übereinstimmen):**
/// - Slot 0:  uTime (float)
/// - Slot 1:  uResolution.x (float)
/// - Slot 2:  uResolution.y (float)
/// - Slot 3:  uHauptfarbe.r (float)
/// - Slot 4:  uHauptfarbe.g (float)
/// - Slot 5:  uHauptfarbe.b (float)
/// - Slot 6:  uHauptfarbe.a (float)
/// - Slot 7:  uNebenfarbe.r (float)
/// - Slot 8:  uNebenfarbe.g (float)
/// - Slot 9:  uNebenfarbe.b (float)
/// - Slot 10: uNebenfarbe.a (float)
/// - Slot 11: uIntensitaet (float)
/// - Slot 12: uPartikelDichte (float)
/// - Slot 13: uWindStaerke (float)
/// - Slot 14: uBlitz (float, 0.0 oder 1.0)
/// - Slot 15: uLeuchtRadius (float, in UV-Einheiten)
class _ShaderWetterPainter extends CustomPainter {
  /// Der vorbereitete Fragment-Shader
  final ui.FragmentShader shader;

  /// Aktuelle Zeit in Sekunden für die Animations-Uniform
  final double time;

  /// Das aktuelle Emotions-Wetter-Modell mit allen visuellen Parametern
  final EmotionsWetterModel wetter;

  const _ShaderWetterPainter({
    required this.shader,
    required this.time,
    required this.wetter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Uniform-Parameter setzen ──────────────────────────────────────────────

    // Slot 0: Zeit in Sekunden (Animations-Treiber)
    shader.setFloat(0, time);

    // Slots 1–2: Auflösung des Zeichenbereichs
    shader.setFloat(1, size.width);
    shader.setFloat(2, size.height);

    // Slots 3–6: Hauptfarbe als normalisierte RGBA-Komponenten (0.0–1.0)
    shader.setFloat(3, wetter.hauptfarbe.red / 255.0);
    shader.setFloat(4, wetter.hauptfarbe.green / 255.0);
    shader.setFloat(5, wetter.hauptfarbe.blue / 255.0);
    shader.setFloat(6, wetter.hauptfarbe.alpha / 255.0);

    // Slots 7–10: Nebenfarbe als normalisierte RGBA-Komponenten
    shader.setFloat(7, wetter.nebenfarbe.red / 255.0);
    shader.setFloat(8, wetter.nebenfarbe.green / 255.0);
    shader.setFloat(9, wetter.nebenfarbe.blue / 255.0);
    shader.setFloat(10, wetter.nebenfarbe.alpha / 255.0);

    // Slot 11: Gesamtintensität des Effekts (0.0–1.0)
    shader.setFloat(11, wetter.intensitaet);

    // Slot 12: Partikel-Dichte (0.0–1.0 → skaliert zu 0–20 Partikel im Shader)
    shader.setFloat(12, wetter.partikelDichte);

    // Slot 13: Windstärke für horizontale Partikel-Verschiebung (0.0–1.0)
    shader.setFloat(13, wetter.windStaerke);

    // Slot 14: Blitz-Aktivierung (1.0 = aktiv, 0.0 = inaktiv)
    shader.setFloat(14, wetter.blitzEffekt ? 1.0 : 0.0);

    // Slot 15: Leuchtradius für kosmisches Glühen
    // Umrechnung: Pixel → UV-Einheiten (relativ zur Bildschirmbreite)
    final leuchtRadiusUV = size.width > 0
        ? (wetter.leuchtenRadius / size.width).clamp(0.0, 1.0)
        : 0.0;
    shader.setFloat(15, leuchtRadiusUV);

    // ── Shader als vollflächiges Rechteck rendern ─────────────────────────────
    final paint = Paint()..shader = shader;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ShaderWetterPainter alt) {
    // Repaint wenn Zeit (Animation-Frame), Wettertyp oder Intensität sich ändern
    return alt.time != time ||
        alt.wetter.typ != wetter.typ ||
        alt.wetter.intensitaet != wetter.intensitaet ||
        alt.wetter.blitzEffekt != wetter.blitzEffekt;
  }
}
