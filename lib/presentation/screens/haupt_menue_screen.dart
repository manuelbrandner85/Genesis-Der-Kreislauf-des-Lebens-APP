// haupt_menue_screen.dart
// Hauptmenü-Screen für GENESIS: Der Kreislauf des Lebens.
// Zeigt das animierte GENESIS-Logo, Sternenhintergrund und
// alle Navigationsbuttons für den Spieler.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Datenmodell: einzelner Stern im Hintergrund
// ─────────────────────────────────────────────────────────────────────────────

/// Repräsentiert einen einzelnen Stern im animierten Sternenhintergrund.
class _Stern {
  final double x;       // Relative X-Position (0.0 – 1.0)
  final double y;       // Relative Y-Position (0.0 – 1.0)
  final double groesse; // Radius des Sterns (0.5 – 2.5)
  final double helligkeit; // Anfangs-Opazität (0.3 – 1.0)
  final double flimmerDauer; // Dauer einer Flimmer-Animation (Sekunden)

  const _Stern({
    required this.x,
    required this.y,
    required this.groesse,
    required this.helligkeit,
    required this.flimmerDauer,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter: Sternenhintergrund
// ─────────────────────────────────────────────────────────────────────────────

/// Zeichnet alle Sterne als weiße Punkte auf einem dunklen Hintergrund.
/// Wird von [_SternenHintergrundWidget] mit einem [AnimationController]
/// kombiniert, um ein sanftes Flimmern zu erzeugen.
class _SternenPainter extends CustomPainter {
  final List<_Stern> sterne;
  final double animationsWert; // 0.0 – 1.0, treibt das Flimmern

  _SternenPainter({
    required this.sterne,
    required this.animationsWert,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < sterne.length; i++) {
      final stern = sterne[i];
      // Phasenverschoben flimmern: jeder Stern hat eine leicht andere Phase
      final phase = (animationsWert + i * 0.07) % 1.0;
      final opazitaet = stern.helligkeit *
          (0.5 + 0.5 * math.sin(phase * math.pi * 2));

      final farbe = Colors.white.withValues(alpha: opazitaet.clamp(0.0, 1.0));
      final paint = Paint()
        ..color = farbe
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(stern.x * size.width, stern.y * size.height),
        stern.groesse,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SternenPainter old) =>
      old.animationsWert != animationsWert;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Animierter Sternenhintergrund
// ─────────────────────────────────────────────────────────────────────────────

/// Füllt den gesamten verfügbaren Platz mit flimmernden Sternen.
/// Nutzt einen [AnimationController] für kontinuierliches Flimmern.
class _SternenHintergrundWidget extends StatefulWidget {
  const _SternenHintergrundWidget();

  @override
  State<_SternenHintergrundWidget> createState() =>
      _SternenHintergrundWidgetState();
}

class _SternenHintergrundWidgetState
    extends State<_SternenHintergrundWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Stern> _sterne;

  @override
  void initState() {
    super.initState();

    // Controller für gleichmäßiges, endloses Flimmern
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 120 Sterne mit zufälligen Positionen und Eigenschaften generieren
    final rng = math.Random(42); // Fester Seed für reproduzierbares Layout
    _sterne = List.generate(120, (_) {
      return _Stern(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        groesse: 0.5 + rng.nextDouble() * 2.0,
        helligkeit: 0.3 + rng.nextDouble() * 0.7,
        flimmerDauer: 2.0 + rng.nextDouble() * 4.0,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _SternenPainter(
            sterne: _sterne,
            animationsWert: _controller.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hauptmenü-Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Hauptmenü von GENESIS.
///
/// Zeigt:
/// - Animierten Sternenhintergrund (CustomPainter + AnimationController)
/// - GENESIS-Logo mit goldenem Glow in der Cinzel-Schrift
/// - Vier Navigations-Buttons
/// - Seelen-Zyklus-Anzeige unten (aktueller Zyklus und Jenseitsreich)
class HauptMenueScreen extends ConsumerWidget {
  const HauptMenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: Stack(
        children: [
          // ── Hintergrund: Kosmischer Gradient ─────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.4),
                radius: 1.6,
                colors: [
                  AppFarben.kosmischViolett,
                  AppFarben.tiefesBlau,
                  AppFarben.kosmischSchwarz,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Sternenhintergrund ────────────────────────────────────────────
          const Positioned.fill(
            child: _SternenHintergrundWidget(),
          ),

          // ── Kosmischer Nebel-Overlay ──────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [
                    AppFarben.mystischLila.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Hauptinhalt ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── GENESIS-Logo ──────────────────────────────────────────
                _GenesisLogo(),

                const Spacer(flex: 2),

                // ── Navigations-Buttons ───────────────────────────────────
                _MenueButtons(),

                const Spacer(flex: 1),

                // ── Seelen-Zyklus-Anzeige ─────────────────────────────────
                const _ZyklusAnzeige(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GENESIS-Logo Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt das GENESIS-Logo mit Untertitel und Glow-Animation.
class _GenesisLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Goldener kosmischer Kreis über dem Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppFarben.goldGlanz.withValues(alpha: 0.6),
              width: 1.5,
            ),
            gradient: RadialGradient(
              colors: [
                AppFarben.goldGlanz.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
          child: const Icon(
            Icons.all_inclusive,
            color: AppFarben.goldGlanz,
            size: 40,
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 200.ms)
            .scale(begin: const Offset(0.7, 0.7), duration: 800.ms),

        const SizedBox(height: 20),

        // Haupttitel "GENESIS"
        Text(
          'GENESIS',
          style: AppTextStyles.ueberschrift1.copyWith(
            fontSize: 56,
            letterSpacing: 10,
            shadows: [
              Shadow(
                color: AppFarben.goldGlanz.withValues(alpha: 0.8),
                blurRadius: 24,
              ),
              Shadow(
                color: AppFarben.goldGlanz.withValues(alpha: 0.4),
                blurRadius: 48,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 1000.ms, delay: 400.ms)
            .slideY(begin: -0.3, end: 0, duration: 800.ms),

        const SizedBox(height: 8),

        // Untertitel
        Text(
          'Der Kreislauf des Lebens',
          style: AppTextStyles.zitat.copyWith(
            fontSize: 15,
            letterSpacing: 3,
            color: AppFarben.goldDunkel,
          ),
        )
            .animate()
            .fadeIn(duration: 1000.ms, delay: 700.ms),

        const SizedBox(height: 12),

        // Trennlinie mit Goldglanz
        Container(
          width: 200,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppFarben.goldGlanz.withValues(alpha: 0.7),
                Colors.transparent,
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 900.ms)
            .scaleX(begin: 0, end: 1, duration: 600.ms),

        const SizedBox(height: 12),

        // Motto
        Text(
          'Jedes Leben ist eine Reise.',
          style: AppTextStyles.koerperKursiv.copyWith(
            fontSize: 13,
            color: AppFarben.textTertiaer,
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 1100.ms),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Menü-Buttons Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Rendert die vier Hauptmenü-Buttons mit konsistenter Gestaltung.
class _MenueButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primärer Button: Neues Leben beginnen
          _HauptMenueButton(
            text: 'Neues Leben beginnen',
            istPrimaer: true,
            icon: Icons.auto_awesome,
            verzoegerung: 1200.ms,
            onPressed: () => context.go(AppRouten.neuesSpiel),
          ),

          const SizedBox(height: 12),

          // Sekundärer Button: Fortfahren
          _HauptMenueButton(
            text: 'Fortfahren',
            istPrimaer: false,
            icon: Icons.play_circle_outline,
            verzoegerung: 1350.ms,
            onPressed: () => context.go(AppRouten.spielLaden),
          ),

          const SizedBox(height: 12),

          // Sekundärer Button: Seelenbibliothek
          _HauptMenueButton(
            text: 'Seelenbibliothek',
            istPrimaer: false,
            icon: Icons.menu_book_outlined,
            verzoegerung: 1500.ms,
            onPressed: () => context.go(AppRouten.bibliothek),
          ),

          const SizedBox(height: 12),

          // Tertiärer Button: Einstellungen
          _HauptMenueButton(
            text: 'Einstellungen',
            istPrimaer: false,
            icon: Icons.settings_outlined,
            verzoegerung: 1650.ms,
            onPressed: () => _zeigeEinstellungen(context),
          ),
        ],
      ),
    );
  }

  /// Navigiert zum Einstellungs-Screen.
  void _zeigeEinstellungen(BuildContext context) {
    context.go(AppRouten.einstellungen);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Einzelner Menü-Button
// ─────────────────────────────────────────────────────────────────────────────

/// Einzelner Hauptmenü-Button mit zwei Stilvarianten.
///
/// [istPrimaer] = true → goldener Hintergrund mit schwarzem Text
/// [istPrimaer] = false → transparenter Hintergrund mit goldenem Rand
class _HauptMenueButton extends StatefulWidget {
  final String text;
  final bool istPrimaer;
  final IconData icon;
  final Duration verzoegerung;
  final VoidCallback onPressed;

  const _HauptMenueButton({
    required this.text,
    required this.istPrimaer,
    required this.icon,
    required this.verzoegerung,
    required this.onPressed,
  });

  @override
  State<_HauptMenueButton> createState() => _HauptMenueButtonState();
}

class _HauptMenueButtonState extends State<_HauptMenueButton> {
  bool _gedrueckt = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _gedrueckt = true),
      onTapUp: (_) {
        setState(() => _gedrueckt = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _gedrueckt = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: widget.istPrimaer
              ? LinearGradient(
                  colors: _gedrueckt
                      ? [AppFarben.goldDunkel, AppFarben.goldDunkel]
                      : [AppFarben.goldGlanz, AppFarben.goldDunkel],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !widget.istPrimaer
              ? (_gedrueckt
                  ? AppFarben.goldGlanz.withValues(alpha: 0.1)
                  : Colors.transparent)
              : null,
          border: Border.all(
            color: widget.istPrimaer
                ? Colors.transparent
                : AppFarben.goldGlanz.withValues(alpha: _gedrueckt ? 0.9 : 0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: widget.istPrimaer && !_gedrueckt
              ? [
                  BoxShadow(
                    color: AppFarben.goldGlanz.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: widget.istPrimaer
                  ? AppFarben.kosmischSchwarz
                  : AppFarben.goldGlanz,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              widget.text,
              style: widget.istPrimaer
                  ? AppTextStyles.buttonPrimaer
                  : AppTextStyles.buttonPrimaer.copyWith(
                      color: AppFarben.goldGlanz,
                      fontWeight: FontWeight.w500,
                    ),
            ),
          ],
        ),
      )
          .animate(delay: widget.verzoegerung)
          .fadeIn(duration: 500.ms)
          .slideX(begin: -0.1, end: 0, duration: 400.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Seelen-Zyklus-Anzeige
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt den aktuellen Seelen-Zyklus und das aktuelle Jenseitsreich am
/// unteren Bildschirmrand an.
class _ZyklusAnzeige extends StatelessWidget {
  const _ZyklusAnzeige();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trennlinie
        Container(
          width: 120,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppFarben.nebelGrau.withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Zyklus-Text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.loop,
              size: 14,
              color: AppFarben.reichLimbus,
            ),
            const SizedBox(width: 8),
            Text(
              'Zyklus 1',
              style: AppTextStyles.beschriftungGross.copyWith(
                color: AppFarben.reichLimbus,
                letterSpacing: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '|',
                style: AppTextStyles.beschriftungGross.copyWith(
                  color: AppFarben.nebelGrau,
                ),
              ),
            ),
            Text(
              'Limbus',
              style: AppTextStyles.beschriftungGross.copyWith(
                color: AppFarben.reichLimbus,
                letterSpacing: 2,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          'Deine Seele beginnt ihre erste Reise',
          style: AppTextStyles.mikro.copyWith(
            color: AppFarben.textTertiaer,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 1800.ms);
  }
}
