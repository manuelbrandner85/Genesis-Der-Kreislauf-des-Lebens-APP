// Phase 1: Die Entstehung – Spermium-Rennen Screen
// Startet das Flame-Engine-Arcade-Spiel (Spermium-Rennen).
// Übergangs-Screen mit Cinematic-Einleitung bevor das Minigame startet.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/genesis_button.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase 1 Screen – Entstehung
// ─────────────────────────────────────────────────────────────────────────────

/// Einstiegsscreen für Phase 1: Die Entstehung.
///
/// Zeigt eine cinematische Einleitung und startet dann das Spermium-Rennen
/// in der Flame Engine. Das Rennen bestimmt die Basis-Attribute des Lebens.
class Phase1EntstehungScreen extends ConsumerStatefulWidget {
  const Phase1EntstehungScreen({super.key});

  @override
  ConsumerState<Phase1EntstehungScreen> createState() =>
      _Phase1EntstehungScreenState();
}

class _Phase1EntstehungScreenState
    extends ConsumerState<Phase1EntstehungScreen>
    with TickerProviderStateMixin {
  // Zustand der Einleitung
  int _aktuellerSchritt = 0;
  bool _rennenGestartet = false;

  // Einleitungstext-Sequenz
  static const List<String> _einleitungsTexte = [
    'Am Anfang war die Dunkelheit.',
    'Dann: ein Impuls. Ein Wille zu sein.',
    'Millionen von dir rasen durch die Unendlichkeit.',
    'Nur einer wird es schaffen.',
    'Dieser Eine bist du.',
    'Das Rennen beginnt...',
  ];

  @override
  void initState() {
    super.initState();
    _einleitungAbspielen();
  }

  void _einleitungAbspielen() async {
    for (int i = 0; i < _einleitungsTexte.length; i++) {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (!mounted) return;
      setState(() => _aktuellerSchritt = i);
    }
    // Nach letztem Text: Rennen-Start-Button anzeigen
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _rennenGestartet = false); // Button erscheint
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Phasen-Artwork-Hintergrund
          const Positioned.fill(
            child: PhasenHintergrund(phase: GamePhase.entstehung),
          ),

          // Kosmischer Hintergrund – tiefes Schwarz mit Partikeleffekten
          _KosmischerHintergrund(),

          // Cinematischer Einleitungstext
          _EinleitungsText(
            text: _aktuellerSchritt < _einleitungsTexte.length
                ? _einleitungsTexte[_aktuellerSchritt]
                : '',
          ),

          // Start-Overlay nach Einleitung
          if (!_rennenGestartet && _aktuellerSchritt >= _einleitungsTexte.length - 1)
            _StartOverlay(
              onRennenStarten: () {
                setState(() => _rennenGestartet = true);
                context.go('/phase/1/rennen');
              },
            ),

          // Phase-Anzeige oben links
          Positioned(
            top: 48,
            left: 24,
            child: Text(
              'PHASE I',
              style: AppTextStyles.beschriftung.copyWith(
                color: AppFarben.goldGlanz.withValues(alpha: 0.6),
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: 500.ms),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kosmischer Hintergrund
// ─────────────────────────────────────────────────────────────────────────────

class _KosmischerHintergrund extends StatefulWidget {
  @override
  State<_KosmischerHintergrund> createState() => _KosmischerHintergrundState();
}

class _KosmischerHintergrundState extends State<_KosmischerHintergrund>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
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
          painter: _SternenPainter(fortschritt: _controller.value),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  AppFarben.tiefesBlau.withValues(alpha: 0.3),
                  Colors.black,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SternenPainter extends CustomPainter {
  final double fortschritt;

  _SternenPainter({required this.fortschritt});

  // Pseudo-zufällige Sternpositionen (deterministisch)
  static final List<(double, double, double)> _sterne = List.generate(
    150,
    (i) => (
      (i * 73.0 % 1.0),          // x-Position 0.0-1.0
      (i * 37.0 % 1.0),          // y-Position 0.0-1.0
      (i % 3 == 0 ? 2.0 : 1.0), // Größe
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final (x, y, groesse) in _sterne) {
      // Sterne flimmern basierend auf Fortschritt
      final index = _sterne.indexOf((x, y, groesse));
      final helligkeit = 0.3 + 0.7 * ((fortschritt + index * 0.1) % 1.0);

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        groesse,
        Paint()
          ..color = Colors.white.withValues(alpha: helligkeit)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_SternenPainter old) => old.fortschritt != fortschritt;
}

// ─────────────────────────────────────────────────────────────────────────────
// Einleitungstext-Widget
// ─────────────────────────────────────────────────────────────────────────────

class _EinleitungsText extends StatelessWidget {
  final String text;

  const _EinleitungsText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (kind, animation) {
            return FadeTransition(
              opacity: animation,
              child: kind,
            );
          },
          child: Text(
            text,
            key: ValueKey(text),
            style: AppTextStyles.ueberschrift3.copyWith(
              color: Colors.white,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Start-Overlay nach Einleitung
// ─────────────────────────────────────────────────────────────────────────────

class _StartOverlay extends StatelessWidget {
  final VoidCallback onRennenStarten;

  const _StartOverlay({required this.onRennenStarten});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            'DIE ENTSTEHUNG',
            style: AppTextStyles.phasenTitel.copyWith(
              color: AppFarben.goldGlanz,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 1.seconds),

          const SizedBox(height: 8),

          Text(
            'Das Rennen um das Leben',
            style: AppTextStyles.koerperGross.copyWith(
              color: AppFarben.textSekundaer,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Deine Route durch das kosmische Rennen bestimmt '
              'deine Basis-Attribute für dieses Leben.',
              style: AppTextStyles.koerperKlein.copyWith(
                color: AppFarben.textSekundaer,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 800.ms),
          ),

          const SizedBox(height: 40),

          GenesisButton(
            text: 'Das Rennen beginnt',
            onPressed: onRennenStarten,
            typ: GenesisButtonTyp.primaer,
          ).animate().fadeIn(delay: 1200.ms).scale(delay: 1200.ms),
        ],
      ),
    );
  }
}
