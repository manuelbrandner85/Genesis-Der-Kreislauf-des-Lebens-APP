// jenseits_ankunft_screen.dart
// Ankunfts-Screen im Jenseits für GENESIS: Der Kreislauf des Lebens.
// Zeigt das zugewiesene Jenseits-Reich basierend auf dem Karma-Profil.
// Jedes der 5 Reiche hat eine einzigartige visuelle Darstellung mit
// unterschiedlichen Farben, Partikeln und atmosphärischen Effekten.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/karma_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/genesis_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// JenseitsAnkunftScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt die dramatische Ankunft im Jenseits-Reich nach dem Tod.
///
/// Das zugewiesene Reich wird aus dem [karmaProvider] ermittelt und
/// bestimmt die gesamte Visualisierung: Hintergrundfarben, Partikeleffekte,
/// Reich-Name und atmosphärische Beschreibung.
///
/// Navigationsziele:
/// - "Reich erkunden" → [JenseitsReichScreen] (`/jenseits/:reich`)
/// - "Wiedergeburt planen" → [ReinkarnationsScreen] (`/reinkarnation`)
class JenseitsAnkunftScreen extends ConsumerStatefulWidget {
  /// Optionale Überschreibung des Reiches (z. B. bei direktem Routing).
  /// Falls null, wird das Reich aus dem Karma-Provider berechnet.
  final JenseitsReich? reichOverride;

  const JenseitsAnkunftScreen({super.key, this.reichOverride});

  @override
  ConsumerState<JenseitsAnkunftScreen> createState() =>
      _JenseitsAnkunftScreenState();
}

class _JenseitsAnkunftScreenState extends ConsumerState<JenseitsAnkunftScreen>
    with TickerProviderStateMixin {
  // Haupt-Einblend-Animation für den gesamten Screen
  late AnimationController _erscheinController;
  late Animation<double> _erscheinAnimation;

  // Partikel-Animation (Endlosschleife)
  late AnimationController _partikelController;

  // Pulsierende Leucht-Animation für das Reich-Symbol
  late AnimationController _pulsController;
  late Animation<double> _pulsAnimation;

  @override
  void initState() {
    super.initState();

    // Einblend-Animation: 2 Sekunden Fade-In beim Screen-Start
    _erscheinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _erscheinAnimation = CurvedAnimation(
      parent: _erscheinController,
      curve: Curves.easeOut,
    );
    _erscheinController.forward();

    // Partikel-Animation: läuft endlos für Partikel-Bewegung
    _partikelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Puls-Animation: sanftes Auf und Ab für das Leucht-Symbol
    _pulsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _pulsAnimation = CurvedAnimation(
      parent: _pulsController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _erscheinController.dispose();
    _partikelController.dispose();
    _pulsController.dispose();
    super.dispose();
  }

  // ── Reich-Konfiguration ───────────────────────────────────────────────────

  /// Gibt das anzuzeigende Reich zurück (aus Override oder Provider).
  JenseitsReich get _aktuellesReich {
    if (widget.reichOverride != null) return widget.reichOverride!;
    // Karma-Provider lesen und Reich berechnen
    final karma = ref.read(karmaProvider);
    return karma.jenseitsReich;
  }

  /// Konfigurationsdaten für jedes Reich: Farben, Titel, Beschreibung, Icon.
  _ReichKonfiguration _konfiguationFuerReich(JenseitsReich reich) {
    switch (reich) {
      case JenseitsReich.elysium:
        return _ReichKonfiguration(
          name: 'ELYSIUM',
          untertitel: 'Das Reich der Erleuchteten',
          beschreibung:
              'Deine Seele strahlt in vollkommenem Licht.\n'
              'Nur die reinsten Herzen finden den Weg hierher.\n'
              'Ewige Harmonie erwartet dich.',
          hauptfarbe: AppFarben.reichElysium,
          nebenfarbe: AppFarben.reichElysiumGlow,
          hintergrundStart: const Color(0xFF0A1628),
          hintergrundEnde: const Color(0xFF1A3A5C),
          partikelFarbe: AppFarben.goldGlanz,
          icon: Icons.brightness_high,
          partikelTyp: _PartikelTyp.leuchtend,
          hatKosmischesLeuchten: true,
        );

      case JenseitsReich.harmonia:
        return _ReichKonfiguration(
          name: 'HARMONIA',
          untertitel: 'Das Reich des Gleichgewichts',
          beschreibung:
              'Deine Taten hinterließen mehr Gutes als Schlechtes.\n'
              'Natur und Stille empfangen dich mit offenen Armen.\n'
              'Verdiente Ruhe nach einem wohlgelebten Leben.',
          hauptfarbe: AppFarben.reichHarmonia,
          nebenfarbe: AppFarben.reichHarmoniaGlow,
          hintergrundStart: const Color(0xFF0A1A0A),
          hintergrundEnde: const Color(0xFF0F2D0F),
          partikelFarbe: AppFarben.reichHarmoniaGlow,
          icon: Icons.eco,
          partikelTyp: _PartikelTyp.schwebend,
          hatKosmischesLeuchten: false,
        );

      case JenseitsReich.limbus:
        return _ReichKonfiguration(
          name: 'LIMBUS',
          untertitel: 'Das Reich des Übergangs',
          beschreibung:
              'Weder Licht noch Dunkelheit hat deine Seele geprägt.\n'
              'Im ewigen Nebel zwischen den Welten\n'
              'wartest du auf eine neue Chance.',
          hauptfarbe: AppFarben.reichLimbus,
          nebenfarbe: AppFarben.reichLimbusGlow,
          hintergrundStart: const Color(0xFF111111),
          hintergrundEnde: const Color(0xFF1E1E2A),
          partikelFarbe: AppFarben.reichLimbusGlow,
          icon: Icons.cloud,
          partikelTyp: _PartikelTyp.nebel,
          hatKosmischesLeuchten: false,
        );

      case JenseitsReich.shadowlands:
        return _ReichKonfiguration(
          name: 'SHADOWLANDS',
          untertitel: 'Das Reich der Schatten',
          beschreibung:
              'Deine Taten hinterließen Schatten in der Welt.\n'
              'In ewiger Dunkelheit büßt deine Seele ihre Fehler.\n'
              'Doch auch hier gibt es einen Weg zurück.',
          hauptfarbe: AppFarben.reichShadowlands,
          nebenfarbe: AppFarben.reichShadowlandsGlow,
          hintergrundStart: const Color(0xFF0A000F),
          hintergrundEnde: const Color(0xFF1A0030),
          partikelFarbe: AppFarben.reichShadowlandsGlow,
          icon: Icons.nights_stay,
          partikelTyp: _PartikelTyp.fallend,
          hatKosmischesLeuchten: false,
        );

      case JenseitsReich.abyssus:
        return _ReichKonfiguration(
          name: 'ABYSSUS',
          untertitel: 'Der tiefste Abgrund',
          beschreibung:
              'Die Last deiner Taten ist schwer wie Stein.\n'
              'Der Abyssus nimmt dich auf in seine ewige Qual.\n'
              'Nur die tiefste Reue öffnet den Weg zurück.',
          hauptfarbe: AppFarben.reichAbyssus,
          nebenfarbe: AppFarben.reichAbyssusGlow,
          hintergrundStart: const Color(0xFF0F0000),
          hintergrundEnde: const Color(0xFF2A0000),
          partikelFarbe: AppFarben.reichAbyssusGlow,
          icon: Icons.keyboard_double_arrow_down,
          partikelTyp: _PartikelTyp.absinkend,
          hatKosmischesLeuchten: false,
        );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final reich = _aktuellesReich;
    final config = _konfiguationFuerReich(reich);

    return Scaffold(
      backgroundColor: config.hintergrundStart,
      body: Stack(
        children: [
          // Hintergrund-Gradient
          _HintergrundGradient(config: config),

          // Partikel-Overlay
          _PartikelOverlay(
            config: config,
            controller: _partikelController,
          ),

          // Kosmisches Leuchten für Elysium
          if (config.hatKosmischesLeuchten)
            _KosmischesLeuchten(
              farbe: config.nebenfarbe,
              pulsAnimation: _pulsAnimation,
            ),

          // Haupt-Inhalt
          SafeArea(
            child: FadeTransition(
              opacity: _erscheinAnimation,
              child: _AnkunftInhalt(
                config: config,
                reich: reich,
                pulsAnimation: _pulsAnimation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Datenklasse: Reich-Konfiguration
// ─────────────────────────────────────────────────────────────────────────────

/// Enthält alle visuellen Parameter eines Jenseits-Reiches.
class _ReichKonfiguration {
  final String name;
  final String untertitel;
  final String beschreibung;
  final Color hauptfarbe;
  final Color nebenfarbe;
  final Color hintergrundStart;
  final Color hintergrundEnde;
  final Color partikelFarbe;
  final IconData icon;
  final _PartikelTyp partikelTyp;
  final bool hatKosmischesLeuchten;

  const _ReichKonfiguration({
    required this.name,
    required this.untertitel,
    required this.beschreibung,
    required this.hauptfarbe,
    required this.nebenfarbe,
    required this.hintergrundStart,
    required this.hintergrundEnde,
    required this.partikelFarbe,
    required this.icon,
    required this.partikelTyp,
    required this.hatKosmischesLeuchten,
  });
}

/// Partikel-Verhaltensmuster je nach Reich.
enum _PartikelTyp {
  leuchtend,  // Elysium: weiße Licht-Partikel schweben aufwärts
  schwebend,  // Harmonia: grüne Partikel driften sanft
  nebel,      // Limbus: graue Nebel-Partikel bewegen sich langsam
  fallend,    // Shadowlands: dunkle Partikel fallen langsam
  absinkend,  // Abyssus: rote Partikel sinken schnell ab
}

// ─────────────────────────────────────────────────────────────────────────────
// Hintergrund-Gradient
// ─────────────────────────────────────────────────────────────────────────────

class _HintergrundGradient extends StatelessWidget {
  final _ReichKonfiguration config;

  const _HintergrundGradient({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.8,
          colors: [
            config.hintergrundEnde,
            config.hintergrundStart,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Partikel-Overlay (Dart-basiert, kein Shader)
// ─────────────────────────────────────────────────────────────────────────────

class _PartikelOverlay extends StatelessWidget {
  final _ReichKonfiguration config;
  final AnimationController controller;

  const _PartikelOverlay({
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _PartikelPainter(
              config: config,
              fortschritt: controller.value,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _PartikelPainter extends CustomPainter {
  final _ReichKonfiguration config;
  final double fortschritt; // 0.0 bis 1.0 (Animations-Fortschritt)

  static final math.Random _rng = math.Random(42); // Fester Seed für Reproduzierbarkeit
  static final List<_PartikelDaten> _partikel = _erstellePartikel();

  static List<_PartikelDaten> _erstellePartikel() {
    return List.generate(25, (i) {
      return _PartikelDaten(
        x: _rng.nextDouble(),
        yStart: _rng.nextDouble(),
        groesse: 2.0 + _rng.nextDouble() * 4.0,
        geschwindigkeit: 0.05 + _rng.nextDouble() * 0.15,
        phase: _rng.nextDouble() * math.pi * 2,
        opazitaet: 0.3 + _rng.nextDouble() * 0.5,
      );
    });
  }

  const _PartikelPainter({
    required this.config,
    required this.fortschritt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _partikel) {
      // Y-Position je nach Partikel-Typ berechnen
      double y;
      double x = p.x * size.width;

      switch (config.partikelTyp) {
        case _PartikelTyp.leuchtend:
        case _PartikelTyp.schwebend:
          // Partikel steigen auf (von unten nach oben)
          y = size.height * (1.0 - fract(p.yStart + fortschritt * p.geschwindigkeit));
          x += math.sin(fortschritt * math.pi * 2 + p.phase) * 10;
        case _PartikelTyp.nebel:
          // Partikel driften horizontal durch den Screen
          y = p.yStart * size.height;
          x = (p.x + fortschritt * p.geschwindigkeit * 0.5) % 1.0 * size.width;
        case _PartikelTyp.fallend:
        case _PartikelTyp.absinkend:
          // Partikel sinken ab (von oben nach unten)
          y = size.height * fract(p.yStart + fortschritt * p.geschwindigkeit);
      }

      // Opazität pulsiert leicht
      final aktuelleOpazitaet = p.opazitaet *
          (0.7 + 0.3 * math.sin(fortschritt * math.pi * 4 + p.phase));

      paint.color = config.partikelFarbe.withValues(alpha: aktuelleOpazitaet.clamp(0.0, 1.0));

      // Elysium: Sternförmige Partikel, andere: Kreise
      if (config.partikelTyp == _PartikelTyp.leuchtend && p.groesse > 3.5) {
        _zeichneStern(canvas, Offset(x, y), p.groesse, paint);
      } else {
        canvas.drawCircle(Offset(x, y), p.groesse, paint);
      }
    }
  }

  /// Zeichnet einen einfachen 4-Punkt-Stern.
  void _zeichneStern(Canvas canvas, Offset mitte, double radius, Paint paint) {
    final path = Path();
    final kleinerRadius = radius * 0.35;
    for (int i = 0; i < 8; i++) {
      final winkel = i * math.pi / 4 - math.pi / 8;
      final r = i.isEven ? radius : kleinerRadius;
      final punkt = Offset(
        mitte.dx + r * math.cos(winkel),
        mitte.dy + r * math.sin(winkel),
      );
      if (i == 0) {
        path.moveTo(punkt.dx, punkt.dy);
      } else {
        path.lineTo(punkt.dx, punkt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Gibt den gebrochenem Anteil einer Zahl zurück (wie GLSL fract()).
  double fract(double x) => x - x.floorToDouble();

  @override
  bool shouldRepaint(_PartikelPainter alt) => alt.fortschritt != fortschritt;
}

/// Daten für einen einzelnen Partikel (statisch, wird einmal generiert).
class _PartikelDaten {
  final double x;
  final double yStart;
  final double groesse;
  final double geschwindigkeit;
  final double phase;
  final double opazitaet;

  const _PartikelDaten({
    required this.x,
    required this.yStart,
    required this.groesse,
    required this.geschwindigkeit,
    required this.phase,
    required this.opazitaet,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Kosmisches Leuchten (nur Elysium)
// ─────────────────────────────────────────────────────────────────────────────

class _KosmischesLeuchten extends StatelessWidget {
  final Color farbe;
  final Animation<double> pulsAnimation;

  const _KosmischesLeuchten({
    required this.farbe,
    required this.pulsAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulsAnimation,
      builder: (context, _) {
        final radius = 0.35 + pulsAnimation.value * 0.15;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: radius,
              colors: [
                farbe.withValues(alpha: 0.25),
                farbe.withValues(alpha: 0.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ankunfts-Inhalt (Texte, Symbol, Buttons)
// ─────────────────────────────────────────────────────────────────────────────

class _AnkunftInhalt extends StatelessWidget {
  final _ReichKonfiguration config;
  final JenseitsReich reich;
  final Animation<double> pulsAnimation;

  const _AnkunftInhalt({
    required this.config,
    required this.reich,
    required this.pulsAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),

          // ── Ankündigungs-Text ────────────────────────────────────────────
          Text(
            'DU BIST ANGEKOMMEN',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: config.hauptfarbe.withValues(alpha: 0.7),
              letterSpacing: 3.0,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 200.ms),

          const SizedBox(height: 32),

          // ── Reich-Symbol (pulsierend) ────────────────────────────────────
          AnimatedBuilder(
            animation: pulsAnimation,
            builder: (context, child) {
              final glowRadius = 20.0 + pulsAnimation.value * 20.0;
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: config.hauptfarbe.withValues(alpha: 0.6),
                    width: 2.0,
                  ),
                  gradient: RadialGradient(
                    colors: [
                      config.hauptfarbe.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: config.hauptfarbe.withValues(alpha: 0.3),
                      blurRadius: glowRadius,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Icon(
              config.icon,
              color: config.hauptfarbe,
              size: 58,
            ),
          )
              .animate()
              .fadeIn(duration: 1000.ms, delay: 400.ms)
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                duration: 800.ms,
                delay: 400.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: 32),

          // ── Reich-Name ────────────────────────────────────────────────────
          Text(
            config.name,
            style: AppTextStyles.jenseitsTitel.copyWith(
              color: config.hauptfarbe,
              shadows: [
                Shadow(
                  color: config.hauptfarbe.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: Offset.zero,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 600.ms)
              .slideY(begin: 0.2, end: 0, duration: 700.ms, delay: 600.ms),

          const SizedBox(height: 8),

          // ── Untertitel ────────────────────────────────────────────────────
          Text(
            config.untertitel,
            style: AppTextStyles.koerperKursiv.copyWith(
              color: config.nebenfarbe.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 800.ms),

          const SizedBox(height: 36),

          // ── Trennlinie ────────────────────────────────────────────────────
          Container(
            width: 200,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  config.hauptfarbe.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 900.ms),

          const SizedBox(height: 32),

          // ── Beschreibung ──────────────────────────────────────────────────
          Text(
            config.beschreibung,
            style: AppTextStyles.koerper.copyWith(
              color: AppFarben.textSekundaer,
              height: 1.9,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 1000.ms),

          const SizedBox(height: 56),

          // ── Buttons ───────────────────────────────────────────────────────
          GenesisButton(
            text: 'REICH ERKUNDEN',
            icon: Icons.explore,
            onPressed: () => context.go(AppRouten.jenseits(reich.name)),
            typ: GenesisButtonTyp.primaer,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 1200.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 1200.ms),

          const SizedBox(height: 14),

          GenesisButton(
            text: 'WIEDERGEBURT PLANEN',
            icon: Icons.autorenew,
            onPressed: () => context.go('/reinkarnation'),
            typ: GenesisButtonTyp.sekundaer,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 1400.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 1400.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
