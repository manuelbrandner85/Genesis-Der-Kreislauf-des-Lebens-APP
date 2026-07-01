// phase2_geburt_cinematic.dart
// Geburts-Cinematic: Schwarzer Bildschirm → weißes Licht → Text → Phase 3.
// Automatischer Übergang nach 4 Sekunden.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase 2 Geburts-Cinematic
// ─────────────────────────────────────────────────────────────────────────────

/// Cinematischer Geburts-Übergang nach dem Embryo-Puzzle.
///
/// Ablauf:
/// 0–1 s: Schwarzer Bildschirm
/// 1–3 s: Langsames Einblenden von weißem Licht
/// 1,5 s: Erster Text "Du öffnest die Augen."
/// 2 s: Zweiter Text "Alles ist Licht."
/// 2,5 s: Baby-Symbol erscheint
/// 4 s: Automatische Navigation zu Phase 3
class Phase2GeburtCinematic extends ConsumerStatefulWidget {
  const Phase2GeburtCinematic({super.key});

  @override
  ConsumerState<Phase2GeburtCinematic> createState() =>
      _Phase2GeburtCinematicState();
}

class _Phase2GeburtCinematicState
    extends ConsumerState<Phase2GeburtCinematic>
    with TickerProviderStateMixin {
  // Controller für das weiße Licht-Overlay
  late final AnimationController _lichtController;
  late final Animation<double> _lichtAlpha;

  // Schritt 0 = Schwarz, 1 = Licht, 2 = Fertig
  int _schritt = 0;

  @override
  void initState() {
    super.initState();

    _lichtController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _lichtAlpha = CurvedAnimation(
      parent: _lichtController,
      curve: Curves.easeIn,
    );

    _sequenzAbspielen();
  }

  @override
  void dispose() {
    _lichtController.dispose();
    super.dispose();
  }

  Future<void> _sequenzAbspielen() async {
    // 1. Kurze schwarze Stille
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // 2. Weißes Licht einblenden
    setState(() => _schritt = 1);
    _lichtController.forward();

    // 3. Phasenwechsel festhalten (Phase 3: Kindheit)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await ref.read(spielProvider.notifier).phasWechseln(GamePhase.kindheit);

    // 4. Nach 4 Sekunden automatisch zu Phase 3 navigieren
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    context.go(AppRouten.phase3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Schwarzer Hintergrund
          Container(color: Colors.black),

          // Weißes Licht-Overlay
          AnimatedBuilder(
            animation: _lichtAlpha,
            builder: (context, _) {
              return Container(
                color: Colors.white.withValues(alpha: _lichtAlpha.value * 0.85),
              );
            },
          ),

          // Text und Symbole
          if (_schritt >= 1)
            _GeburtInhalt(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GeburtInhalt – Texte und Symbole
// ─────────────────────────────────────────────────────────────────────────────

class _GeburtInhalt extends StatelessWidget {
  const _GeburtInhalt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Baby-Symbol
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.6),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.child_care,
                color: AppFarben.phaseKindheit,
                size: 44,
              ),
            )
                .animate()
                .fadeIn(delay: 1200.ms, duration: 800.ms)
                .scaleXY(begin: 0.5, end: 1.0, delay: 1200.ms, duration: 800.ms, curve: Curves.elasticOut),

            const SizedBox(height: 48),

            // Erster Text
            Text(
              'Du öffnest die Augen.',
              style: AppTextStyles.ueberschrift3.copyWith(
                color: AppFarben.tiefesBlau.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 600.ms, duration: 1000.ms),

            const SizedBox(height: 16),

            // Zweiter Text
            Text(
              'Alles ist Licht.',
              style: AppTextStyles.ueberschrift2.copyWith(
                color: AppFarben.tiefesBlau.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 1400.ms, duration: 1000.ms),

            const SizedBox(height: 24),

            // Untertitel
            Text(
              'Das Leben beginnt...',
              style: AppTextStyles.koerperKursiv.copyWith(
                color: AppFarben.tiefesBlau.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 2000.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
