// phase8_kosmisch_screen.dart
// Phase 8 – Die Kosmische Reise: Zwischen den Welten.
// Die Seele schwebt durch einen Sternenhimmel, während fünf kosmische
// Erkenntnisse erscheinen. Nach 18 Sekunden geht es weiter zur Schöpfung.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

/// Phase 8 – Die Kosmische Reise.
///
/// Ein meditativer Übergang durch das All mit funkelnden Sternen und
/// goldenen Erkenntnissen über das gelebte Leben.
class Phase8KosmischScreen extends ConsumerStatefulWidget {
  const Phase8KosmischScreen({super.key});

  @override
  ConsumerState<Phase8KosmischScreen> createState() =>
      _Phase8KosmischScreenState();
}

class _Phase8KosmischScreenState extends ConsumerState<Phase8KosmischScreen>
    with SingleTickerProviderStateMixin {
  /// Die fünf kosmischen Erkenntnisse.
  static const List<String> _erkenntnisse = [
    'Du warst.',
    'Du hast gelebt.',
    'Du hast entschieden.',
    'Jede Entscheidung war notwendig.',
    'Die Seele wählt ihren nächsten Weg.',
  ];

  /// Aktuell sichtbare Erkenntnis (Index, -1 = noch keine).
  int _aktuell = -1;

  /// Ob der optionale Weiter-Button erscheint (nach 15 s).
  bool _zeigeButton = false;

  /// Steuert das Funkeln der Sterne.
  late final AnimationController _sterneController;

  /// Die vorab generierten Sterne.
  late final List<_Stern> _sterne;

  final List<Timer> _timer = [];

  @override
  void initState() {
    super.initState();
    final zufall = math.Random(42);
    _sterne = List.generate(150, (_) => _Stern.zufaellig(zufall));

    _sterneController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Jede Erkenntnis erscheint mit drei Sekunden Abstand.
    for (var i = 0; i < _erkenntnisse.length; i++) {
      _timer.add(
        Timer(Duration(seconds: 3 * (i + 1)), () {
          if (!mounted) return;
          setState(() => _aktuell = i);
        }),
      );
    }

    // Optionaler Weiter-Button nach 15 Sekunden.
    _timer.add(Timer(const Duration(seconds: 15), () {
      if (!mounted) return;
      setState(() => _zeigeButton = true);
    }));

    // Automatischer Übergang nach 18 Sekunden.
    _timer.add(Timer(const Duration(seconds: 18), () {
      if (!mounted) return;
      context.go('/phase/9');
    }));
  }

  @override
  void dispose() {
    for (final t in _timer) {
      t.cancel();
    }
    _sterneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Phasen-Artwork-Hintergrund
          const Positioned.fill(
            child: PhasenHintergrund(phase: GamePhase.kosmisch),
          ),

          // Animiertes Sternenfeld
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sterneController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SternenPainter(
                    sterne: _sterne,
                    fortschritt: _sterneController.value,
                  ),
                );
              },
            ),
          ),

          // Kosmische Erkenntnisse
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: _aktuell < 0
                    ? const SizedBox.shrink()
                    : Text(
                        _erkenntnisse[_aktuell],
                        key: ValueKey(_aktuell),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.ueberschrift2.copyWith(
                          color: AppFarben.goldGlanz,
                          letterSpacing: 3,
                          height: 1.5,
                        ),
                      )
                        .animate()
                        .fadeIn(duration: 1400.ms)
                        .then()
                        .shimmer(
                          duration: 1800.ms,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
              ),
            ),
          ),

          // Optionaler Weiter-Button
          if (_zeigeButton)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: OutlinedButton(
                  onPressed: () => context.go('/phase/9'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppFarben.goldGlanz,
                    side: BorderSide(
                      color: AppFarben.goldGlanz.withValues(alpha: 0.6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'WEITER',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                ).animate().fadeIn(duration: 1000.ms),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ein einzelner Stern im Sternenfeld.
class _Stern {
  final double x; // relative Position 0..1
  final double y;
  final double groesse;
  final double helligkeit;
  final double phase; // individueller Twinkle-Versatz

  const _Stern({
    required this.x,
    required this.y,
    required this.groesse,
    required this.helligkeit,
    required this.phase,
  });

  factory _Stern.zufaellig(math.Random r) {
    return _Stern(
      x: r.nextDouble(),
      y: r.nextDouble(),
      groesse: 0.5 + r.nextDouble() * 2.2,
      helligkeit: 0.3 + r.nextDouble() * 0.7,
      phase: r.nextDouble() * math.pi * 2,
    );
  }
}

/// Zeichnet das funkelnde Sternenfeld.
class _SternenPainter extends CustomPainter {
  final List<_Stern> sterne;
  final double fortschritt;

  _SternenPainter({required this.sterne, required this.fortschritt});

  @override
  void paint(Canvas canvas, Size size) {
    // Kosmischer Hintergrundverlauf – halbtransparent,
    // damit das Galaxie-Artwork darunter sichtbar bleibt.
    final hintergrund = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x661A0F3C), Color(0x8C000000)],
        radius: 1.0,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, hintergrund);

    final winkel = fortschritt * math.pi * 2;
    for (final stern in sterne) {
      // Twinkeln über eine Sinuswelle mit individuellem Versatz.
      final twinkle = (math.sin(winkel + stern.phase) + 1) / 2;
      final alpha = (stern.helligkeit * (0.4 + 0.6 * twinkle)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..maskFilter = stern.groesse > 1.5
            ? const MaskFilter.blur(BlurStyle.normal, 1.2)
            : null;
      canvas.drawCircle(
        Offset(stern.x * size.width, stern.y * size.height),
        stern.groesse,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SternenPainter old) =>
      old.fortschritt != fortschritt;
}
