// phasen_uebergang.dart
// Vollbild-Overlay-Animation beim Übergang zwischen Lebensphasen.
// Zeigt cineastisch: Einblenden → Phasen-Titel → Beschreibung → Ausblenden.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PhasenUebergang
// ─────────────────────────────────────────────────────────────────────────────

/// Vollbild-Overlay-Widget für den Übergang zur angegebenen [neuPhase].
///
/// Ablauf:
/// 1. Schwarzes Einblenden (500 ms)
/// 2. Phasen-Nummer "PHASE {n}" erscheint (800 ms)
/// 3. Phasen-Name erscheint (900 ms)
/// 4. Kurze Beschreibung erscheint (1 s sichtbar)
/// 5. Ausblenden → [onFertig] wird aufgerufen
///
/// Gesamtdauer: ~3,5 Sekunden
class PhasenUebergang extends StatefulWidget {
  /// Die neue Phase, zu der gewechselt wird.
  final GamePhase neuPhase;

  /// Wird aufgerufen, sobald die Übergangs-Animation beendet ist.
  final VoidCallback onFertig;

  const PhasenUebergang({
    super.key,
    required this.neuPhase,
    required this.onFertig,
  });

  @override
  State<PhasenUebergang> createState() => _PhasenUebergangState();
}

class _PhasenUebergangState extends State<PhasenUebergang>
    with SingleTickerProviderStateMixin {
  // Schritt 0 = Einblenden, 1 = Titel sichtbar, 2 = Ausblenden
  int _schritt = 0;

  // Haupt-Controller für das schwarze Overlay
  late final AnimationController _overlayController;
  late final Animation<double> _overlayAlpha;

  @override
  void initState() {
    super.initState();

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _overlayAlpha = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeIn,
    );

    _animationAbspielen();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  // ── Übergangs-Sequenz ──────────────────────────────────────────────────────

  Future<void> _animationAbspielen() async {
    // 1. Schwarzes Overlay einblenden
    await _overlayController.forward();

    // 2. Titel-Elemente erscheinen (werden durch flutter_animate gesteuert)
    if (!mounted) return;
    setState(() => _schritt = 1);

    // 3. Beschreibung lesen lassen
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    // 4. Ausblenden
    setState(() => _schritt = 2);
    await _overlayController.reverse();
    if (!mounted) return;

    // 5. Callback auslösen
    widget.onFertig();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final phaseFarbe = AppFarben.fuerPhaseNummer(widget.neuPhase.nummer);

    return AnimatedBuilder(
      animation: _overlayAlpha,
      builder: (context, child) {
        return Opacity(
          opacity: _overlayAlpha.value,
          child: child,
        );
      },
      child: Container(
        color: AppFarben.kosmischSchwarz,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _schritt >= 1
                  ? _PhasenTitelInhalt(
                      phase: widget.neuPhase,
                      phaseFarbe: phaseFarbe,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PhasenTitelInhalt – animierter Phasen-Titel-Block
// ─────────────────────────────────────────────────────────────────────────────

class _PhasenTitelInhalt extends StatelessWidget {
  final GamePhase phase;
  final Color phaseFarbe;

  const _PhasenTitelInhalt({
    required this.phase,
    required this.phaseFarbe,
  });

  // Römische Zahl für die Phasennummer
  String get _roemischeZahl {
    const zahlen = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX'];
    final idx = phase.nummer - 1;
    if (idx < 0 || idx >= zahlen.length) return phase.nummer.toString();
    return zahlen[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dekorative Linie oben
        Container(
          width: 60,
          height: 1,
          color: phaseFarbe.withValues(alpha: 0.5),
        ).animate().scaleX(duration: 600.ms, curve: Curves.easeOut),

        const SizedBox(height: 20),

        // Phasen-Nummer "PHASE III" (klein, gedimmt)
        Text(
          'PHASE $_roemischeZahl',
          style: AppTextStyles.beschriftungGross.copyWith(
            color: phaseFarbe.withValues(alpha: 0.7),
            letterSpacing: 4.0,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms),

        const SizedBox(height: 12),

        // Phasen-Name (groß, gold, Cinzel)
        Text(
          phase.anzeigeName.toUpperCase(),
          style: AppTextStyles.phasenTitel.copyWith(
            color: phaseFarbe,
            fontSize: 32,
            letterSpacing: 5.0,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 800.ms)
            .slideY(begin: 0.2, end: 0, delay: 500.ms, duration: 800.ms),

        const SizedBox(height: 20),

        // Dekorative Linie unten
        Container(
          width: 120,
          height: 1,
          color: phaseFarbe.withValues(alpha: 0.3),
        ).animate().scaleX(delay: 400.ms, duration: 600.ms),

        const SizedBox(height: 20),

        // Kurze Phasen-Beschreibung
        Text(
          phase.beschreibung,
          style: AppTextStyles.koerperKursiv.copyWith(
            color: AppFarben.textSekundaer.withValues(alpha: 0.9),
            height: 1.7,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        )
            .animate()
            .fadeIn(delay: 900.ms, duration: 700.ms),
      ],
    );
  }
}
