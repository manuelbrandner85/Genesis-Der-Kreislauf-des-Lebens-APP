// phasen_hintergrund.dart
// Zentrales Hintergrund-Widget für alle Phasen- und Jenseits-Screens.
// Zeigt das Phasen-Artwork mit langsamem Ken-Burns-Zoom, einem
// Lesbarkeits-Gradient und schwebenden Licht-Partikeln.
// Fällt elegant auf einen Farbverlauf zurück, wenn kein Artwork existiert.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Asset-Pfade
// ─────────────────────────────────────────────────────────────────────────────

/// Liefert den Artwork-Pfad für eine Spielphase.
String phasenArtworkPfad(GamePhase phase) => switch (phase) {
      GamePhase.entstehung => 'assets/images/phasen/entstehung.webp',
      GamePhase.formung => 'assets/images/phasen/formung.webp',
      GamePhase.kindheit => 'assets/images/phasen/kindheit.webp',
      GamePhase.jugend => 'assets/images/phasen/jugend.webp',
      GamePhase.erwachsen => 'assets/images/phasen/erwachsen.webp',
      GamePhase.reife => 'assets/images/phasen/reife.webp',
      GamePhase.jenseits => 'assets/images/jenseits/limbus.webp',
      GamePhase.kosmisch => 'assets/images/phasen/kosmisch.webp',
      GamePhase.schoepfung => 'assets/images/phasen/schoepfung.webp',
    };

/// Liefert den Artwork-Pfad für ein Jenseits-Reich.
String jenseitsArtworkPfad(JenseitsReich reich) => switch (reich) {
      JenseitsReich.elysium => 'assets/images/jenseits/elysium.webp',
      JenseitsReich.harmonia => 'assets/images/jenseits/harmonia.webp',
      JenseitsReich.limbus => 'assets/images/jenseits/limbus.webp',
      JenseitsReich.shadowlands => 'assets/images/jenseits/shadowlands.webp',
      JenseitsReich.abyssus => 'assets/images/jenseits/abyssus.webp',
    };

/// Fallback-Farbverlauf je Phase (wenn Artwork fehlt oder als Unterlage).
List<Color> _fallbackFarben(GamePhase phase) => switch (phase) {
      GamePhase.entstehung => const [Color(0xFF041E2B), Color(0xFF0A3D4D)],
      GamePhase.formung => const [Color(0xFF2B1408), Color(0xFF5C2E10)],
      GamePhase.kindheit => const [Color(0xFF1A3A12), Color(0xFF3F6B1E)],
      GamePhase.jugend => const [Color(0xFF0D1B3A), Color(0xFF31226B)],
      GamePhase.erwachsen => const [Color(0xFF2B1B08), Color(0xFF6B4A16)],
      GamePhase.reife => const [Color(0xFF3A2408), Color(0xFF7A5218)],
      GamePhase.jenseits => const [Color(0xFF14141F), Color(0xFF2E2E4A)],
      GamePhase.kosmisch => const [Color(0xFF0A0A2B), Color(0xFF2D1B69)],
      GamePhase.schoepfung => const [Color(0xFF1F0A2B), Color(0xFF4A1B69)],
    };

// ─────────────────────────────────────────────────────────────────────────────
// PhasenHintergrund
// ─────────────────────────────────────────────────────────────────────────────

/// Vollflächiger Artwork-Hintergrund mit Ken-Burns-Zoom, Abdunkelungs-
/// Gradient und Licht-Partikeln. In einen [Stack] als unterste Ebene legen.
class PhasenHintergrund extends StatefulWidget {
  /// Direkte Angabe eines Asset-Pfads (hat Vorrang vor [phase]).
  final String? assetPfad;

  /// Phase, deren Artwork gezeigt werden soll.
  final GamePhase? phase;

  /// Stärke der Abdunkelung über dem Artwork (0.0–1.0).
  final double abdunkelung;

  /// Ob die schwebenden Licht-Partikel gezeichnet werden.
  final bool mitPartikeln;

  /// Ob der langsame Ken-Burns-Zoom aktiv ist.
  final bool mitKenBurns;

  /// Ob die Handy-Neigung eine echte 3D-Parallaxe erzeugt
  /// (Artwork und Partikel verschieben sich gegenläufig + perspektivische
  /// Kippung – das Display wirkt wie ein Fenster in die Szene).
  final bool mitGyroParallax;

  const PhasenHintergrund({
    super.key,
    this.assetPfad,
    this.phase,
    this.abdunkelung = 0.45,
    this.mitPartikeln = true,
    this.mitKenBurns = true,
    this.mitGyroParallax = true,
  }) : assert(assetPfad != null || phase != null,
            'Entweder assetPfad oder phase angeben');

  @override
  State<PhasenHintergrund> createState() => _PhasenHintergrundState();
}

class _PhasenHintergrundState extends State<PhasenHintergrund>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // ── Gyro-Parallax-Zustand ──────────────────────────────────────────────────

  /// Tiefpass-gefilterte Neigung (-1..1 je Achse, 0 = Ruhelage).
  double _neigungX = 0.0;
  double _neigungY = 0.0;

  /// Ruhelage der Y-Achse (Gravitation bei typischer Haltehaltung);
  /// wird beim ersten Sensor-Ereignis kalibriert.
  double? _ruheY;

  StreamSubscription<AccelerometerEvent>? _sensorAbo;

  @override
  void initState() {
    super.initState();
    // Sehr langsamer Loop: treibt Ken-Burns-Zoom und Partikel gemeinsam an.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat(reverse: true);

    if (widget.mitGyroParallax) {
      _sensorStarten();
    }
  }

  /// Startet den Lagesensor. Fehlende Sensoren (Emulator, Desktop)
  /// werden still ignoriert – der Hintergrund bleibt dann statisch.
  void _sensorStarten() {
    try {
      _sensorAbo = accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (ereignis) {
          // Ruhelage einmalig aus der ersten Messung kalibrieren
          _ruheY ??= ereignis.y;

          // Rohwerte auf -1..1 normieren (±4 m/s² Auslenkung = Vollausschlag)
          final zielX = (-ereignis.x / 4.0).clamp(-1.0, 1.0);
          final zielY = ((ereignis.y - _ruheY!) / 4.0).clamp(-1.0, 1.0);

          // Tiefpass: weiche, träge Kamerabewegung statt Zitterei
          _neigungX += (zielX - _neigungX) * 0.12;
          _neigungY += (zielY - _neigungY) * 0.12;
          // Kein setState nötig – der AnimationController-Ticker
          // (AnimatedBuilder) zeichnet ohnehin jeden Frame neu.
        },
        onError: (_) {},
        cancelOnError: true,
      );
    } catch (_) {
      // Sensor nicht verfügbar – Parallaxe bleibt aus.
    }
  }

  @override
  void dispose() {
    _sensorAbo?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pfad = widget.assetPfad ?? phasenArtworkPfad(widget.phase!);
    final fallback = _fallbackFarben(widget.phase ?? GamePhase.kosmisch);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // Ken-Burns: sanfter Zoom zwischen 1.0 und 1.08.
        // Bei aktiver Parallaxe zusätzlicher Zoom-Puffer, damit beim
        // Verschieben keine Bildränder sichtbar werden.
        final parallaxPuffer = widget.mitGyroParallax ? 0.08 : 0.0;
        final zoom =
            (widget.mitKenBurns ? 1.0 + 0.08 * t : 1.0) + parallaxPuffer;

        // 3D-Parallaxe: Neigung → Kameraversatz + perspektivische Kippung
        final versatz = Offset(_neigungX * 20, _neigungY * 14);
        final kippung = Matrix4.identity()
          ..setEntry(3, 2, 0.0012) // Perspektiv-Anteil (Fluchtpunkt)
          ..rotateY(_neigungX * 0.05)
          ..rotateX(-_neigungY * 0.05);

        return Stack(
          fit: StackFit.expand,
          children: [
            // Unterste Ebene: Fallback-Verlauf (sichtbar bis Artwork lädt
            // bzw. dauerhaft, wenn das Asset fehlt)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [fallback[0], fallback[1], AppFarben.kosmischSchwarz],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),

            // Artwork mit Ken-Burns-Zoom und 3D-Parallaxe
            ClipRect(
              child: Transform(
                alignment: Alignment.center,
                transform: kippung
                  ..translate(versatz.dx, versatz.dy)
                  ..scale(zoom),
                child: Image.asset(
                  pfad,
                  fit: BoxFit.cover,
                  // Fehlendes Asset → unsichtbar, Verlauf bleibt sichtbar
                  errorBuilder: (_, __, ___) => const SizedBox.expand(),
                  // Sanftes Einblenden beim ersten Frame
                  frameBuilder: (context, child, frame, wasSyncLoaded) {
                    if (wasSyncLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                ),
              ),
            ),

            // Lesbarkeits-Gradient: oben leicht, unten stark abgedunkelt
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(widget.abdunkelung * 0.6),
                    Colors.black.withOpacity(widget.abdunkelung * 0.25),
                    Colors.black.withOpacity(widget.abdunkelung),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Vignette für cinematischen Look
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.6, 1.0],
                ),
              ),
            ),

            // Schwebende Licht-Partikel – bewegen sich als Vordergrund-Ebene
            // GEGENLÄUFIG zum Artwork (stärkerer Versatz = näher am Auge)
            if (widget.mitPartikeln)
              CustomPaint(
                painter: _LichtPartikelPainter(
                  fortschritt: t,
                  parallaxVersatz: Offset(-versatz.dx * 1.8, -versatz.dy * 1.8),
                ),
                size: Size.infinite,
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Licht-Partikel-Painter
// ─────────────────────────────────────────────────────────────────────────────

/// Zeichnet sanft aufsteigende, pulsierende Licht-Partikel.
/// Deterministische Pseudo-Zufallsverteilung → kein State nötig.
class _LichtPartikelPainter extends CustomPainter {
  final double fortschritt;

  /// Parallax-Versatz der Partikel-Ebene (gegenläufig zum Artwork).
  final Offset parallaxVersatz;

  _LichtPartikelPainter({
    required this.fortschritt,
    this.parallaxVersatz = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Gesamte Partikel-Ebene um den Parallax-Versatz verschieben
    canvas.translate(parallaxVersatz.dx, parallaxVersatz.dy);
    final paint = Paint()..style = PaintingStyle.fill;
    // Fester Seed: Partikel-Positionen bleiben über Frames stabil
    final zufall = math.Random(7);

    for (int i = 0; i < 28; i++) {
      final basisX = zufall.nextDouble();
      final basisY = zufall.nextDouble();
      final groesse = 0.8 + zufall.nextDouble() * 2.2;
      final phase = zufall.nextDouble() * 2 * math.pi;
      final tempo = 0.3 + zufall.nextDouble() * 0.7;

      // Vertikales Aufsteigen mit Wrap-around, horizontales Pendeln
      final y = (basisY - fortschritt * tempo) % 1.0;
      final x = basisX + 0.015 * math.sin(fortschritt * 2 * math.pi + phase);

      // Pulsierende Transparenz
      final alpha =
          0.10 + 0.20 * (0.5 + 0.5 * math.sin(fortschritt * 4 * math.pi + phase));

      paint.color = Colors.white.withOpacity(alpha);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        groesse,
        paint,
      );

      // Weicher Glow um größere Partikel
      if (groesse > 2.0) {
        paint.color = AppFarben.goldGlanz.withOpacity(alpha * 0.3);
        canvas.drawCircle(
          Offset(x * size.width, y * size.height),
          groesse * 2.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_LichtPartikelPainter oldDelegate) =>
      oldDelegate.fortschritt != fortschritt ||
      oldDelegate.parallaxVersatz != parallaxVersatz;
}
