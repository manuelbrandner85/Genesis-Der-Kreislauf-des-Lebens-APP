// splash_screen.dart
// Aufwendiger Splash-Screen für GENESIS: Der Kreislauf des Lebens.
// Zeigt eine animierte Intro-Sequenz mit Partikeleffekten, goldenem Titel
// in Cinzel-Schrift und einem Ladebalken, bevor zum Hauptmenü navigiert wird.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Partikel-Datenmodell
// ─────────────────────────────────────────────────────────────────────────────

/// Repräsentiert ein einzelnes Partikel im Splash-Screen (Stern oder Atom-Punkt).
class _Partikel {
  /// Horizontale Position (0.0–1.0, relativ zur Bildschirmbreite)
  double x;

  /// Vertikale Position (0.0–1.0, relativ zur Bildschirmhöhe)
  double y;

  /// Durchmesser des Partikels in logischen Pixeln
  double groesse;

  /// Aktuelle Deckkraft (0.0–1.0)
  double opazitaet;

  /// Geschwindigkeit für das langsame Schweben (0.0–1.0)
  double geschwindigkeit;

  /// Partikelfarbe (weiß, goldgelb oder sanftes Blau)
  Color farbe;

  /// Phase im Animations-Zyklus (0.0–2π)
  double phase;

  _Partikel({
    required this.x,
    required this.y,
    required this.groesse,
    required this.opazitaet,
    required this.geschwindigkeit,
    required this.farbe,
    required this.phase,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SplashScreen – Haupt-Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Aufwendiger Splash-Screen mit Animations-Sequenz.
///
/// Ablauf:
/// 1. Schwarzer Hintergrund erscheint
/// 2. Partikel (Sterne/Atome) erscheinen langsam
/// 3. "GENESIS" blendet in goldener Cinzel-Schrift ein
/// 4. Untertitel "Der Kreislauf des Lebens" erscheint
/// 5. Ladebalken füllt sich in 3 Sekunden
/// 6. Automatische Navigation zum Hauptmenü
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animations-Controller ─────────────────────────────────────────────────

  /// Controller für das Partikel-Schweben (läuft in Endlosschleife)
  late AnimationController _partikelController;

  /// Controller für den Ladebalken (0.0 → 1.0 in 3 Sekunden)
  late AnimationController _ladebalkenController;

  /// Animation für den Ladebalken-Fortschritt
  late Animation<double> _ladebalkenAnimation;

  // ── Partikel-System ───────────────────────────────────────────────────────

  /// Liste aller Partikel im Hintergrund
  final List<_Partikel> _partikel = [];

  /// Zufallsgenerator für Partikel-Initialisierung
  final math.Random _zufall = math.Random();

  // ── Zustand ───────────────────────────────────────────────────────────────

  /// Gibt an, ob bereits zur nächsten Route navigiert wurde
  bool _navigiert = false;

  @override
  void initState() {
    super.initState();

    // Partikel initialisieren
    _partikelErzeugen();

    // Partikel-Animations-Controller (Endlosschleife, 4 Sekunden pro Zyklus)
    _partikelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Ladebalken-Controller (einmalig, 3.2 Sekunden Gesamtdauer)
    _ladebalkenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Ladebalken-Animation mit Ease-in-out-Kurve
    _ladebalkenAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _ladebalkenController,
        curve: Curves.easeInOut,
      ),
    );

    // Ladebalken startet nach kurzer Verzögerung (Titeltext blendet ein)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ladebalkenController.forward();
    });

    // Nach 3.8 Sekunden zum Hauptmenü navigieren
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted && !_navigiert) {
        _navigiert = true;
        context.go(AppRouten.hauptMenue);
      }
    });
  }

  /// Erzeugt 60 zufällig verteilte Partikel für den Hintergrund.
  void _partikelErzeugen() {
    for (int i = 0; i < 60; i++) {
      _partikel.add(_Partikel(
        x: _zufall.nextDouble(),
        y: _zufall.nextDouble(),
        groesse: _zufall.nextDouble() * 3.0 + 0.8,
        opazitaet: _zufall.nextDouble() * 0.7 + 0.1,
        geschwindigkeit: _zufall.nextDouble() * 0.3 + 0.1,
        farbe: _zufaelligeFarbe(),
        phase: _zufall.nextDouble() * math.pi * 2,
      ));
    }
  }

  /// Gibt eine zufällige Partikelfarbe zurück (weiß, gold oder hellblau).
  Color _zufaelligeFarbe() {
    final auswahl = _zufall.nextInt(3);
    switch (auswahl) {
      case 0:
        return Colors.white.withValues(alpha: 0.8);
      case 1:
        return AppFarben.goldGlanz.withValues(alpha: 0.9);
      case 2:
      default:
        return const Color(0xFF87CEEB).withValues(alpha: 0.7);
    }
  }

  @override
  void dispose() {
    _partikelController.dispose();
    _ladebalkenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Schicht 1: Animierter Partikel-Hintergrund ─────────────────
          AnimatedBuilder(
            animation: _partikelController,
            builder: (context, child) {
              return CustomPaint(
                painter: _PartikelMaler(
                  partikel: _partikel,
                  animation: _partikelController.value,
                ),
              );
            },
          ),

          // ── Schicht 2: Zentraler Titel-Bereich ────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Abstand nach oben
                const Spacer(flex: 3),

                // Goldene horizontale Linie oben
                Container(
                  width: 120,
                  height: 1,
                  color: AppFarben.goldGlanz.withValues(alpha: 0.5),
                )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                    )
                    .scaleX(
                      begin: 0.0,
                      end: 1.0,
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 20),

                // ── "GENESIS" – Haupttitel ─────────────────────────────
                Text(
                  'GENESIS',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: AppFarben.goldGlanz,
                    letterSpacing: 12.0,
                    // Goldener Text-Schatten für Leucht-Effekt
                    shadows: [
                      Shadow(
                        color: AppFarben.goldGlanz.withValues(alpha: 0.8),
                        blurRadius: 20,
                        offset: Offset.zero,
                      ),
                      Shadow(
                        color: AppFarben.goldGlanz.withValues(alpha: 0.4),
                        blurRadius: 40,
                        offset: Offset.zero,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeIn,
                    )
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 12),

                // ── Untertitel ─────────────────────────────────────────
                Text(
                  'Der Kreislauf des Lebens',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppFarben.text.withValues(alpha: 0.85),
                    letterSpacing: 4.0,
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 600),
                    )
                    .slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 20),

                // Goldene horizontale Linie unten
                Container(
                  width: 120,
                  height: 1,
                  color: AppFarben.goldGlanz.withValues(alpha: 0.5),
                )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 400),
                    )
                    .scaleX(
                      begin: 0.0,
                      end: 1.0,
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    ),

                const Spacer(flex: 2),

                // ── Ladebalken ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Column(
                    children: [
                      // Lade-Text
                      Text(
                        'INITIALISIERE KREISLAUF...',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 10,
                          color: AppFarben.textSekundaer.withValues(alpha: 0.7),
                          letterSpacing: 2.0,
                        ),
                      )
                          .animate()
                          .fadeIn(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 800),
                          ),

                      const SizedBox(height: 8),

                      // Ladebalken-Container
                      AnimatedBuilder(
                        animation: _ladebalkenAnimation,
                        builder: (context, child) {
                          return Container(
                            height: 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _ladebalkenAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppFarben.goldGlanz.withValues(alpha: 0.7),
                                      AppFarben.goldGlanz,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppFarben.goldGlanz
                                          .withValues(alpha: 0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ).animate().fadeIn(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 800),
                          ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Partikel-Painter – Custom Painter für Hintergrund-Partikel
// ─────────────────────────────────────────────────────────────────────────────

/// Zeichnet alle Hintergrund-Partikel auf ein Canvas.
///
/// Partikel schweben sanft auf und nieder (Sinus-Bewegung) und
/// pulsieren in ihrer Helligkeit.
class _PartikelMaler extends CustomPainter {
  /// Liste aller zu zeichnenden Partikel
  final List<_Partikel> partikel;

  /// Aktueller Animations-Wert (0.0–1.0)
  final double animation;

  _PartikelMaler({
    required this.partikel,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in partikel) {
      // Schwebende vertikale Bewegung via Sinus-Funktion
      final schwebeFaktor = math.sin(
        animation * math.pi * 2 + p.phase,
      );

      // Berechnete Position auf dem Canvas
      final posX = p.x * size.width;
      final posY = p.y * size.height + schwebeFaktor * 6.0 * p.geschwindigkeit;

      // Pulsierende Deckkraft (zwischen 30% und 100% der Basis-Opazität)
      final pulsOpazitaet =
          p.opazitaet * (0.4 + 0.6 * (0.5 + 0.5 * schwebeFaktor));

      final farbe = p.farbe.withValues(alpha: pulsOpazitaet);

      // Partikel zeichnen (einfacher Kreis)
      canvas.drawCircle(
        Offset(posX, posY),
        p.groesse / 2,
        Paint()
          ..color = farbe
          ..style = PaintingStyle.fill,
      );

      // Leucht-Halo um größere Partikel
      if (p.groesse > 2.0) {
        canvas.drawCircle(
          Offset(posX, posY),
          p.groesse * 1.5,
          Paint()
            ..color = farbe.withValues(alpha: pulsOpazitaet * 0.3)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PartikelMaler oldDelegate) =>
      oldDelegate.animation != animation;
}
