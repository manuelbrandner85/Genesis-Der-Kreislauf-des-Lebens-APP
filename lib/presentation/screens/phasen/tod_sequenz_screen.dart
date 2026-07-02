// Tod-Sequenz Screen für GENESIS: Der Kreislauf des Lebens
// Zeigt den Lebensrückblick, die Tunnel-Sequenz und leitet zum Karma-Gericht über.
// Verschiedene Todesarten erzeugen unterschiedliche Sequenzen.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/karma_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/koerper_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tod-Sequenz Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt die Tod-Sequenz in drei Akten:
/// 1. Lebensrückblick (Foto-Erinnerungen)
/// 2. Tunnel-Sequenz (abhängig von Todesart und Karma)
/// 3. Letzter Atemzug → Übergang zum Karma-Gericht
class TodSequenzScreen extends ConsumerStatefulWidget {
  /// Die Art des Todes – bestimmt den visuellen Stil.
  /// Null = wird dynamisch aus der Körper-Simulation abgeleitet.
  final TodesArt? todesArt;

  /// Der Karma-Durchschnitt – bestimmt Farbe und Stimmung des Tunnels.
  /// Null = wird aus dem [karmaProvider] gelesen.
  final double? karmaDurchschnitt;

  /// Das Sterbealter. Null = wird aus dem [spielProvider] gelesen.
  final int? sterbealter;

  const TodSequenzScreen({
    super.key,
    this.todesArt,
    this.karmaDurchschnitt,
    this.sterbealter,
  });

  @override
  ConsumerState<TodSequenzScreen> createState() => _TodSequenzScreenState();
}

class _TodSequenzScreenState extends ConsumerState<TodSequenzScreen>
    with TickerProviderStateMixin {
  int _akt = 0; // 0=Einleitung, 1=Rückblick, 2=Tunnel, 3=Übergang

  late final AnimationController _tunnelController;

  @override
  void initState() {
    super.initState();
    _tunnelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _sequenzStarten();
  }

  @override
  void dispose() {
    _tunnelController.dispose();
    super.dispose();
  }

  void _sequenzStarten() async {
    // Akt 1: Einleitung (2 Sekunden)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _akt = 1);

    // Akt 2: Lebensrückblick (6 Sekunden)
    await Future.delayed(const Duration(seconds: 6));
    if (!mounted) return;
    setState(() => _akt = 2);
    _tunnelController.forward();

    // Akt 3: Tunnel (6 Sekunden)
    await Future.delayed(const Duration(seconds: 6));
    if (!mounted) return;
    setState(() => _akt = 3);

    // Akt 4: Übergang (3 Sekunden → Karma-Gericht)
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    context.go('/phase/7'); // Karma-Gericht / Jenseits
  }

  /// Leitet eine [TodesArt] aus dem Todesursachen-Text der
  /// Körper-Simulation ab (Fallback: natürlicher Tod).
  TodesArt _todesArtAusUrsache(String ursache) {
    final u = ursache.toLowerCase();
    if (u.contains('natürlich') || u.contains('alter')) {
      return TodesArt.natuerlich;
    }
    if (u.contains('unfall')) return TodesArt.unfall;
    if (u.contains('versagen') ||
        u.contains('infarkt') ||
        u.contains('schlaganfall') ||
        u.contains('krebs') ||
        u.contains('infektion') ||
        u.contains('depression') ||
        u.contains('demenz') ||
        u.contains('burnout') ||
        u.contains('sucht') ||
        u.contains('diabetes') ||
        u.contains('arthritis')) {
      return TodesArt.krankheit;
    }
    return TodesArt.natuerlich;
  }

  @override
  Widget build(BuildContext context) {
    // Dynamische Werte auflösen – explizite Konstruktor-Werte haben Vorrang
    final karmaDurchschnitt =
        widget.karmaDurchschnitt ?? ref.watch(karmaDurchschnittProvider);
    final alterImSpiel = ref.watch(spielProvider).aktuellesAlter;
    final sterbealter =
        widget.sterbealter ?? (alterImSpiel < 60 ? 60 : alterImSpiel);
    final todesArt = widget.todesArt ??
        _todesArtAusUrsache(
          ref.read(koerperProvider.notifier).todesUrsache(sterbealter),
        );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Hintergrund je nach Akt
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1500),
            child: switch (_akt) {
              0 => _dunkleFadeIn(),
              1 => _rueckblickHintergrund(),
              2 => _tunnelHintergrund(karmaDurchschnitt),
              _ => _weissesLicht(),
            },
          ),

          // Inhalt je nach Akt
          switch (_akt) {
            0 => _EinleitungsText(
                todesArt: todesArt,
                sterbealter: sterbealter,
              ),
            1 => _LebensRueckblick(karmaDurchschnitt: karmaDurchschnitt),
            2 => _TunnelSequenz(
                controller: _tunnelController,
                karmaDurchschnitt: karmaDurchschnitt,
              ),
            _ => _UebergangText(),
          },
        ],
      ),
    );
  }

  Widget _dunkleFadeIn() {
    return Container(
      key: const ValueKey('dunkel'),
      color: Colors.black,
    );
  }

  Widget _rueckblickHintergrund() {
    return Container(
      key: const ValueKey('rueckblick'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Colors.black],
        ),
      ),
    );
  }

  Widget _tunnelHintergrund(double karmaDurchschnitt) {
    // Tunnel-Farbe basierend auf Karma
    final tunnelFarbe = karmaDurchschnitt > 30
        ? AppFarben.goldGlanz.withValues(alpha: 0.3)
        : karmaDurchschnitt > -30
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2);

    return AnimatedBuilder(
      key: const ValueKey('tunnel'),
      animation: _tunnelController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.5 + _tunnelController.value * 1.5,
              colors: [
                tunnelFarbe,
                Colors.black,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _weissesLicht() {
    return Container(
      key: const ValueKey('licht'),
      color: Colors.white,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Einleitungs-Text
// ─────────────────────────────────────────────────────────────────────────────

class _EinleitungsText extends StatelessWidget {
  final TodesArt todesArt;
  final int sterbealter;

  const _EinleitungsText({
    required this.todesArt,
    required this.sterbealter,
  });

  String get _einleitungsText => switch (todesArt) {
        TodesArt.natuerlich =>
          'Im Alter von $sterbealter Jahren schließt sich der Kreis.',
        TodesArt.krankheit =>
          'Nach langem Kämpfen lässt du los.',
        TodesArt.unfall =>
          'In einem einzigen Moment – alles.',
        TodesArt.heldentod =>
          'Du hast alles gegeben. Mehr konnte kein Mensch geben.',
        TodesArt.schlaf =>
          'Im Schlaf – sanft, ohne Schmerz – beginnst du deine Reise.',
        TodesArt.sonstiges =>
          'Das Leben hat sein Ende gefunden.',
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Text(
          _einleitungsText,
          style: AppTextStyles.ueberschrift3.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontStyle: FontStyle.italic,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 1500.ms),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lebens-Rückblick
// ─────────────────────────────────────────────────────────────────────────────

class _LebensRueckblick extends StatelessWidget {
  final double karmaDurchschnitt;

  const _LebensRueckblick({required this.karmaDurchschnitt});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ein Leben zieht vorbei...',
            style: AppTextStyles.ueberschrift2.copyWith(
              color: AppFarben.goldGlanz.withValues(alpha: 0.8),
            ),
          ).animate().fadeIn().then().shimmer(duration: 2.seconds),

          const SizedBox(height: 48),

          // Platzhalter für Foto-Album-Animation
          // In der finalen Version: echte Erinnerungsfotos fliegen vorbei
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (context, i) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppFarben.oberflaeche,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppFarben.goldGlanz.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo,
                        color: AppFarben.goldGlanz.withValues(alpha: 0.5),
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Erinnerung ${i + 1}',
                        style: AppTextStyles.beschriftung.copyWith(
                          color: AppFarben.textSekundaer,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (i * 200).ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tunnel-Sequenz
// ─────────────────────────────────────────────────────────────────────────────

class _TunnelSequenz extends StatelessWidget {
  final AnimationController controller;
  final double karmaDurchschnitt;

  const _TunnelSequenz({
    required this.controller,
    required this.karmaDurchschnitt,
  });

  @override
  Widget build(BuildContext context) {
    final tunnelText = karmaDurchschnitt > 30
        ? 'Das Licht ist warm.\nDu erkennst es.'
        : karmaDurchschnitt > -30
            ? 'Ein Licht.\nDu nährst dich ihm.'
            : 'Dunkelheit.\nAber auch hier: ein Funken.';

    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Opacity(
            opacity: (controller.value * 2).clamp(0, 1),
            child: Text(
              tunnelText,
              style: AppTextStyles.ueberschrift2.copyWith(
                color: Colors.white,
                height: 2,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Übergangs-Text
// ─────────────────────────────────────────────────────────────────────────────

class _UebergangText extends StatelessWidget {
  const _UebergangText();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Das Gericht erwartet dich.',
        style: AppTextStyles.ueberschrift3.copyWith(
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ).animate().fadeIn(duration: 1.seconds),
    );
  }
}
