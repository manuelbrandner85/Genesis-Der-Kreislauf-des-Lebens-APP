// phase7_jenseits_vorbereitung_screen.dart
// Phase 7 – Jenseits-Vorbereitung: Letzte Reflexion vor dem Karma-Gericht.
// Eine rein cineastische Sequenz ohne Gameplay – das Licht wird heller,
// vier Erkenntnisse erscheinen nacheinander, dann öffnet sich das Gericht.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

/// Phase 7 – Jenseits-Vorbereitung.
///
/// Übergangsszene zwischen Tod und Karma-Gericht. Das Licht steigt über
/// zwölf Sekunden von tiefem Violett zu reinem Weiß.
class Phase7JenseitsVorbereitungScreen extends ConsumerStatefulWidget {
  const Phase7JenseitsVorbereitungScreen({super.key});

  @override
  ConsumerState<Phase7JenseitsVorbereitungScreen> createState() =>
      _Phase7JenseitsVorbereitungScreenState();
}

class _Phase7JenseitsVorbereitungScreenState
    extends ConsumerState<Phase7JenseitsVorbereitungScreen>
    with SingleTickerProviderStateMixin {
  /// Die vier Erkenntnis-Texte, die nacheinander erscheinen.
  static const List<String> _texte = [
    'Das Licht wird heller.',
    'Die Zeit hört auf zu fließen.',
    'Du erinnerst dich an alles.',
    'Das Gericht erwartet dich.',
  ];

  /// Wie viele Texte bereits sichtbar sind.
  int _sichtbareTexte = 0;

  /// Ob der Übergangs-Button erscheinen darf.
  bool _bereit = false;

  /// Steuert das langsam heller werdende Licht (12 Sekunden).
  late final AnimationController _lichtController;

  final List<Timer> _timer = [];

  @override
  void initState() {
    super.initState();
    _lichtController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..forward();

    // Jeder Text erscheint mit drei Sekunden Abstand.
    for (var i = 0; i < _texte.length; i++) {
      _timer.add(
        Timer(Duration(seconds: 3 * (i + 1)), () {
          if (!mounted) return;
          setState(() => _sichtbareTexte = i + 1);
        }),
      );
    }

    // Nach Ablauf des Lichts darf der Übergang erfolgen.
    _lichtController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _bereit = true);
      }
    });
  }

  @override
  void dispose() {
    for (final t in _timer) {
      t.cancel();
    }
    _lichtController.dispose();
    super.dispose();
  }

  void _weiter() {
    context.go('/karma-gericht');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhasenHintergrund(
            assetPfad: 'assets/images/jenseits/limbus.webp',
            abdunkelung: 0.6,
          ),
          AnimatedBuilder(
            animation: _lichtController,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_lichtController.value);
              // Hintergrund wechselt von dunkelviolett zu hellweiß.
              final hintergrund = Color.lerp(
                const Color(0xFF1A0F3C),
                const Color(0xFFF5F3FF),
                t,
              )!;
              // Textfarbe invertiert sich, damit Lesbarkeit erhalten bleibt.
              final textFarbe =
                  Color.lerp(AppFarben.text, const Color(0xFF2D1B69), t)!;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.6 + t * 1.4,
                    colors: [
                      Color.lerp(const Color(0xFF6A0DAD), Colors.white, t)!,
                      hintergrund,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < _sichtbareTexte; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                _texte[i],
                                textAlign: TextAlign.center,
                                style: AppTextStyles.ueberschrift3.copyWith(
                                  color: textFarbe,
                                  letterSpacing: 2.5,
                                  height: 1.6,
                                ),
                              ).animate().fadeIn(duration: 1500.ms),
                            ),
                          const SizedBox(height: 48),
                          if (_bereit)
                            OutlinedButton(
                              onPressed: _weiter,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2D1B69),
                                side: const BorderSide(
                                  color: Color(0xFF6A0DAD),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 36,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'VOR DAS KARMA-GERICHT',
                                style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              ),
                            ).animate().fadeIn(duration: 1200.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
