// jenseits_reich_screen.dart
// Jenseits-Reich-Erkundungs-Screen für GENESIS: Der Kreislauf des Lebens.
// Zeigt das zugewiesene Jenseits-Reich mit reich-spezifischer Atmosphäre,
// Weisheits-Fragmenten, animierten Effekten und dem Übergang zur kosmischen Reise.

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
// JenseitsReichScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Haupt-Erkundungs-Screen des Jenseits-Reiches.
///
/// Zeigt reichs-spezifische visuelle Atmosphäre, Weisheits-Fragmente und
/// den Timer-gesteuerten Übergang zur kosmischen Reise (Phase 8).
///
/// Jedes Reich hat:
/// - Einzigartigen Hintergrundgradienten und Partikeleffekte
/// - Reich-spezifische Botschaft und Weisheits-Fragmente
/// - Nach 10 Sekunden: Button "Die kosmische Reise beginnt" → /phase/8
///
/// Navigationsziele:
/// - Auto-Übergang nach 10s → [Phase8KosmischScreen] (`/phase/8`)
class JenseitsReichScreen extends ConsumerStatefulWidget {
  /// Name des Jenseits-Reiches aus dem URL-Parameter.
  /// Gültige Werte: 'elysium', 'harmonia', 'limbus', 'shadowlands', 'abyssus'
  final String reichName;

  const JenseitsReichScreen({super.key, required this.reichName});

  @override
  ConsumerState<JenseitsReichScreen> createState() =>
      _JenseitsReichScreenState();
}

class _JenseitsReichScreenState extends ConsumerState<JenseitsReichScreen>
    with TickerProviderStateMixin {
  // Einblend-Animation für den gesamten Screen
  late AnimationController _erscheinController;
  late Animation<double> _erscheinAnimation;

  // Partikel-Animation (Endlosschleife für Hintergrundeffekte)
  late AnimationController _partikelController;

  // Pulsierender Leucht-Effekt für Elysium
  late AnimationController _pulsController;
  late Animation<double> _pulsAnimation;

  // Flackernde Animation für Limbus-Nebel und Shadowlands
  late AnimationController _flackerController;
  late Animation<double> _flackerAnimation;

  // Freigeschaltete Weisheits-Fragmente (werden nacheinander eingeblendet)
  int _freigeschalteteWeisheiten = 0;

  // Gibt an, ob der Übergangs-Button sichtbar ist (nach 10 Sekunden)
  bool _buttonSichtbar = false;

  @override
  void initState() {
    super.initState();

    // Einblend-Animation: 2 Sekunden Fade-In
    _erscheinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _erscheinAnimation = CurvedAnimation(
      parent: _erscheinController,
      curve: Curves.easeOut,
    );
    _erscheinController.forward();

    // Partikel-Animation: läuft endlos
    _partikelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Puls-Animation: sanftes Auf und Ab
    _pulsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _pulsAnimation = CurvedAnimation(
      parent: _pulsController,
      curve: Curves.easeInOut,
    );

    // Flacker-Animation: unregelmäßiges Flimmern für Limbus/Shadowlands
    _flackerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
    _flackerAnimation = CurvedAnimation(
      parent: _flackerController,
      curve: Curves.easeInOut,
    );

    // Weisheits-Fragmente schrittweise freischalten
    _weisheitenFreischalten();

    // Übergangs-Button nach 10 Sekunden einblenden
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) setState(() => _buttonSichtbar = true);
    });
  }

  @override
  void dispose() {
    _erscheinController.dispose();
    _partikelController.dispose();
    _pulsController.dispose();
    _flackerController.dispose();
    super.dispose();
  }

  /// Schaltet Weisheits-Fragmente zeitverzögert frei.
  void _weisheitenFreischalten() async {
    final maxWeisheiten = _reichKonfiguration.weisheiten.length;
    for (int i = 0; i < maxWeisheiten; i++) {
      // Jede Weisheit erscheint mit 2 Sekunden Abstand
      await Future.delayed(Duration(seconds: 2 + i * 2));
      if (mounted) setState(() => _freigeschalteteWeisheiten = i + 1);
    }
  }

  // ── Reich-Konfiguration ───────────────────────────────────────────────────

  /// Gibt das JenseitsReich-Enum für den URL-Parameter zurück.
  JenseitsReich get _reich {
    switch (widget.reichName.toLowerCase()) {
      case 'elysium':    return JenseitsReich.elysium;
      case 'harmonia':   return JenseitsReich.harmonia;
      case 'shadowlands': return JenseitsReich.shadowlands;
      case 'abyssus':    return JenseitsReich.abyssus;
      default:           return JenseitsReich.limbus;
    }
  }

  /// Vollständige visuelle Konfiguration für das aktuelle Reich.
  _ReichKonfiguration get _reichKonfiguration {
    switch (_reich) {
      case JenseitsReich.elysium:
        return const _ReichKonfiguration(
          name: 'ELYSIUM',
          hauptbotschaft: 'Willkommen in der ewigen Harmonie',
          hauptfarbe: AppFarben.reichElysium,
          nebenfarbe: AppFarben.reichElysiumGlow,
          hintergrundFarben: [Color(0xFF0A1628), Color(0xFF1A3A5C)],
          partikelFarbe: AppFarben.goldGlanz,
          partikelTyp: _PartikelTyp.aufsteigend,
          hatRadialLeuchten: true,
          weisheiten: [
            'Mitgefühl ist die höchste Form der Stärke.',
            'In der Liebe zum anderen erkennst du dich selbst.',
            'Das Ewige ist kein Ort – es ist ein Zustand der Seele.',
          ],
          stimmung: 'golden',
        );
      case JenseitsReich.harmonia:
        return const _ReichKonfiguration(
          name: 'HARMONIA',
          hauptbotschaft: 'Du hast gut gelebt',
          hauptfarbe: AppFarben.reichHarmonia,
          nebenfarbe: AppFarben.reichHarmoniaGlow,
          hintergrundFarben: [Color(0xFF0A1A0A), Color(0xFF0F2D0F)],
          partikelFarbe: AppFarben.reichHarmoniaGlow,
          partikelTyp: _PartikelTyp.schwebend,
          hatRadialLeuchten: false,
          weisheiten: [
            'Das Gleichgewicht ist kein Stillstand – es ist Bewegung in Harmonie.',
            'Jeder Baum trägt die Geschichte des Bodens, aus dem er wuchs.',
          ],
          stimmung: 'gruen',
        );
      case JenseitsReich.limbus:
        return const _ReichKonfiguration(
          name: 'LIMBUS',
          hauptbotschaft: 'Noch ist nichts entschieden',
          hauptfarbe: AppFarben.reichLimbus,
          nebenfarbe: AppFarben.reichLimbusGlow,
          hintergrundFarben: [Color(0xFF111111), Color(0xFF1E1E2A)],
          partikelFarbe: AppFarben.reichLimbusGlow,
          partikelTyp: _PartikelTyp.nebel,
          hatRadialLeuchten: false,
          weisheiten: [
            'Im Grau liegt die Möglichkeit aller Farben.',
          ],
          stimmung: 'grau',
        );
      case JenseitsReich.shadowlands:
        return const _ReichKonfiguration(
          name: 'SHADOWLANDS',
          hauptbotschaft: 'Deine Taten verfolgen dich',
          hauptfarbe: AppFarben.reichShadowlands,
          nebenfarbe: AppFarben.reichShadowlandsGlow,
          hintergrundFarben: [Color(0xFF0A000F), Color(0xFF1A0030)],
          partikelFarbe: AppFarben.reichShadowlandsGlow,
          partikelTyp: _PartikelTyp.fallend,
          hatRadialLeuchten: false,
          weisheiten: [
            '⚠ Hier wohnt das Echo jeder unbereueten Tat.',
          ],
          stimmung: 'dunkel',
        );
      case JenseitsReich.abyssus:
        return const _ReichKonfiguration(
          name: 'ABYSSUS',
          hauptbotschaft: 'Die absolute Dunkelheit',
          hauptfarbe: AppFarben.reichAbyssus,
          nebenfarbe: AppFarben.reichAbyssusGlow,
          hintergrundFarben: [Color(0xFF0F0000), Color(0xFF2A0000)],
          partikelFarbe: AppFarben.reichAbyssusGlow,
          partikelTyp: _PartikelTyp.absinkend,
          hatRadialLeuchten: false,
          weisheiten: [],
          stimmung: 'dunkelrot',
        );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final config = _reichKonfiguration;

    return Scaffold(
      backgroundColor: config.hintergrundFarben.first,
      body: Stack(
        children: [
          // Hintergrund-Gradient (reich-spezifisch)
          _HintergrundGradient(config: config),

          // Partikel-Overlay (reich-spezifisches Verhalten)
          _PartikelOverlay(
            config: config,
            controller: _partikelController,
          ),

          // Nebel-Effekt für Limbus (animierte Opazität)
          if (_reich == JenseitsReich.limbus)
            _NebelEffekt(flackerAnimation: _flackerAnimation),

          // Flackernde Schatten für Shadowlands
          if (_reich == JenseitsReich.shadowlands)
            _SchattenFlackern(flackerAnimation: _flackerAnimation),

          // Kosmisches Radialleuchten für Elysium
          if (config.hatRadialLeuchten)
            _RadialLeuchten(
              farbe: config.nebenfarbe,
              pulsAnimation: _pulsAnimation,
            ),

          // Haupt-Inhalt des Reiches
          SafeArea(
            child: FadeTransition(
              opacity: _erscheinAnimation,
              child: _ReichInhalt(
                config: config,
                reich: _reich,
                freigeschalteteWeisheiten: _freigeschalteteWeisheiten,
                buttonSichtbar: _buttonSichtbar,
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

/// Vollständige visuelle und inhaltliche Konfiguration eines Jenseits-Reiches.
class _ReichKonfiguration {
  final String name;
  final String hauptbotschaft;
  final Color hauptfarbe;
  final Color nebenfarbe;
  final List<Color> hintergrundFarben;
  final Color partikelFarbe;
  final _PartikelTyp partikelTyp;
  final bool hatRadialLeuchten;

  /// Weisheits-Fragmente: Elysium 3, Harmonia 2, Limbus 1, Shadowlands 1, Abyssus 0
  final List<String> weisheiten;

  /// Atmosphärischer Stimmungstyp (bestimmt Zusatzeffekte)
  final String stimmung;

  const _ReichKonfiguration({
    required this.name,
    required this.hauptbotschaft,
    required this.hauptfarbe,
    required this.nebenfarbe,
    required this.hintergrundFarben,
    required this.partikelFarbe,
    required this.partikelTyp,
    required this.hatRadialLeuchten,
    required this.weisheiten,
    required this.stimmung,
  });
}

/// Partikel-Verhaltensmuster je nach Reich.
enum _PartikelTyp {
  aufsteigend,  // Elysium: goldene Lichtpartikel steigen auf
  schwebend,    // Harmonia: grüne Partikel driften sanft
  nebel,        // Limbus: graue Nebelpartikel bewegen sich träge
  fallend,      // Shadowlands: dunkle Partikel sinken langsam
  absinkend,    // Abyssus: rote Partikel sinken schnell in die Tiefe
}

// ─────────────────────────────────────────────────────────────────────────────
// Hintergrund-Gradient
// ─────────────────────────────────────────────────────────────────────────────

class _HintergrundGradient extends StatelessWidget {
  final _ReichKonfiguration config;

  const _HintergrundGradient({required this.config});

  @override
  Widget build(BuildContext context) {
    // Elysium: RadialGradient weiß/gold
    if (config.stimmung == 'golden') {
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.6,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              config.hauptfarbe.withValues(alpha: 0.15),
              config.hintergrundFarben.last,
              config.hintergrundFarben.first,
            ],
            stops: const [0.0, 0.25, 0.6, 1.0],
          ),
        ),
      );
    }

    // Alle anderen: linearer Gradient von unten nach oben
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: config.hintergrundFarben,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Partikel-Overlay (CustomPainter)
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
            painter: _ReichPartikelPainter(
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

/// CustomPainter für reich-spezifische Partikeleffekte.
class _ReichPartikelPainter extends CustomPainter {
  final _ReichKonfiguration config;
  final double fortschritt;

  // Statische Partikelzahl je Reich
  static const int _anzahlPartikel = 30;

  // Fester Seed für reproduzierbare Partikelverteilung
  static final math.Random _rng = math.Random(13);
  static final List<_PartikelDaten> _partikel = _generierePartikel();

  static List<_PartikelDaten> _generierePartikel() {
    return List.generate(_anzahlPartikel, (i) {
      return _PartikelDaten(
        x: _rng.nextDouble(),
        yStart: _rng.nextDouble(),
        groesse: 1.5 + _rng.nextDouble() * 4.5,
        geschwindigkeit: 0.04 + _rng.nextDouble() * 0.12,
        phase: _rng.nextDouble() * math.pi * 2,
        opazitaet: 0.25 + _rng.nextDouble() * 0.55,
      );
    });
  }

  const _ReichPartikelPainter({
    required this.config,
    required this.fortschritt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final farbe = config.partikelFarbe;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _partikel) {
      double y;
      double x = p.x * size.width;

      // Y-Position und Bewegung je Partikeltyp
      switch (config.partikelTyp) {
        case _PartikelTyp.aufsteigend:
        case _PartikelTyp.schwebend:
          // Partikel steigen von unten nach oben
          y = size.height *
              (1.0 - _fract(p.yStart + fortschritt * p.geschwindigkeit));
          // Sanfte Seitenbewegung
          x += math.sin(fortschritt * math.pi * 2 + p.phase) * 12;
        case _PartikelTyp.nebel:
          // Nebel-Partikel driften horizontal
          y = p.yStart * size.height;
          x = _fract(p.x + fortschritt * p.geschwindigkeit * 0.4) * size.width;
        case _PartikelTyp.fallend:
        case _PartikelTyp.absinkend:
          // Partikel sinken von oben nach unten
          final speed = config.partikelTyp == _PartikelTyp.absinkend
              ? p.geschwindigkeit * 1.8  // Abyssus fällt schneller
              : p.geschwindigkeit;
          y = size.height * _fract(p.yStart + fortschritt * speed);
      }

      // Opazität pulsiert leicht
      final aktuelleOpazitaet = p.opazitaet *
          (0.6 + 0.4 * math.sin(fortschritt * math.pi * 3 + p.phase));

      paint.color = farbe.withValues(
        alpha: aktuelleOpazitaet.clamp(0.0, 1.0),
      );

      // Elysium: Sternförmige Lichtpartikel für größere Partikel
      if (config.partikelTyp == _PartikelTyp.aufsteigend && p.groesse > 3.5) {
        _zeichneStern(canvas, Offset(x, y), p.groesse, paint);
      } else {
        canvas.drawCircle(Offset(x, y), p.groesse, paint);
      }
    }
  }

  /// Zeichnet einen kleinen 4-zackigen Stern (Elysium-Lichtpartikel).
  void _zeichneStern(Canvas canvas, Offset mitte, double radius, Paint paint) {
    final pfad = Path();
    final kleinerRadius = radius * 0.3;
    for (int i = 0; i < 8; i++) {
      final winkel = i * math.pi / 4 - math.pi / 8;
      final r = i.isEven ? radius : kleinerRadius;
      final punkt = Offset(
        mitte.dx + r * math.cos(winkel),
        mitte.dy + r * math.sin(winkel),
      );
      if (i == 0) {
        pfad.moveTo(punkt.dx, punkt.dy);
      } else {
        pfad.lineTo(punkt.dx, punkt.dy);
      }
    }
    pfad.close();
    canvas.drawPath(pfad, paint);
  }

  /// Gebrochener Anteil (wie GLSL fract).
  double _fract(double x) => x - x.floorToDouble();

  @override
  bool shouldRepaint(_ReichPartikelPainter alt) =>
      alt.fortschritt != fortschritt;
}

/// Daten für einen einzelnen Partikel.
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
// Nebel-Effekt (Limbus)
// ─────────────────────────────────────────────────────────────────────────────

/// Animierter Nebelschleier für das Limbus-Reich.
/// Verwendet AnimatedOpacity mit leichtem Flimmern.
class _NebelEffekt extends StatelessWidget {
  final Animation<double> flackerAnimation;

  const _NebelEffekt({required this.flackerAnimation});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: flackerAnimation,
        builder: (context, _) {
          // Opazität flimmert unregelmäßig zwischen 0.06 und 0.18
          final alpha = 0.06 + flackerAnimation.value * 0.12;
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  AppFarben.reichLimbusGlow.withValues(alpha: alpha),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schatten-Flackern (Shadowlands)
// ─────────────────────────────────────────────────────────────────────────────

/// Flackernde Schattenüberlagerung für das Shadowlands-Reich.
class _SchattenFlackern extends StatelessWidget {
  final Animation<double> flackerAnimation;

  const _SchattenFlackern({required this.flackerAnimation});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: flackerAnimation,
        builder: (context, _) {
          // Schattenwolken flackern asymmetrisch
          final alpha1 = 0.08 + flackerAnimation.value * 0.14;
          final alpha2 = 0.14 - flackerAnimation.value * 0.08;
          return Stack(
            children: [
              // Linke Schattenwolke
              Positioned(
                left: -80,
                top: 100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppFarben.reichShadowlandsGlow.withValues(
                      alpha: alpha1,
                    ),
                  ),
                ),
              ),
              // Rechte Schattenwolke
              Positioned(
                right: -60,
                bottom: 200,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppFarben.reichShadowlands.withValues(
                      alpha: alpha2,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Radiales Leuchten (Elysium)
// ─────────────────────────────────────────────────────────────────────────────

/// Pulsierendes Radialleuchten für das Elysium-Reich.
class _RadialLeuchten extends StatelessWidget {
  final Color farbe;
  final Animation<double> pulsAnimation;

  const _RadialLeuchten({
    required this.farbe,
    required this.pulsAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: pulsAnimation,
        builder: (context, _) {
          final radius = 0.3 + pulsAnimation.value * 0.18;
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: radius,
                colors: [
                  Colors.white.withValues(alpha: 0.12 + pulsAnimation.value * 0.08),
                  farbe.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Haupt-Inhalt (Reich-Anzeige und Weisheits-Fragmente)
// ─────────────────────────────────────────────────────────────────────────────

class _ReichInhalt extends StatelessWidget {
  final _ReichKonfiguration config;
  final JenseitsReich reich;
  final int freigeschalteteWeisheiten;
  final bool buttonSichtbar;
  final Animation<double> pulsAnimation;

  const _ReichInhalt({
    required this.config,
    required this.reich,
    required this.freigeschalteteWeisheiten,
    required this.buttonSichtbar,
    required this.pulsAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // ── Reich-Symbol (pulsierend) ────────────────────────────────────
          _ReichSymbol(
            config: config,
            pulsAnimation: pulsAnimation,
          ),

          const SizedBox(height: 28),

          // ── Reich-Name ────────────────────────────────────────────────────
          Text(
            config.name,
            style: AppTextStyles.jenseitsTitel.copyWith(
              color: config.hauptfarbe,
              shadows: [
                Shadow(
                  color: config.hauptfarbe.withValues(alpha: 0.5),
                  blurRadius: 24.0,
                  offset: Offset.zero,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 800.ms, delay: 300.ms),

          const SizedBox(height: 12),

          // ── Trennlinie ────────────────────────────────────────────────────
          Container(
            width: 180,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  config.hauptfarbe.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

          const SizedBox(height: 24),

          // ── Hauptbotschaft ────────────────────────────────────────────────
          _Hauptbotschaft(config: config, reich: reich),

          const SizedBox(height: 36),

          // ── Weisheits-Fragmente ───────────────────────────────────────────
          // Werden schrittweise freigeschaltet (maximal 3 für Elysium)
          if (config.weisheiten.isNotEmpty) ...[
            Text(
              'WEISHEITS-FRAGMENTE',
              style: AppTextStyles.beschriftungGross.copyWith(
                color: config.hauptfarbe.withValues(alpha: 0.7),
                letterSpacing: 2.5,
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
            const SizedBox(height: 16),
            ...List.generate(config.weisheiten.length, (index) {
              final istFreigeschaltet = index < freigeschalteteWeisheiten;
              return _WeisheitsFragment(
                text: config.weisheiten[index],
                nummer: index + 1,
                gesamt: config.weisheiten.length,
                istFreigeschaltet: istFreigeschaltet,
                reichFarbe: config.hauptfarbe,
                nebenfarbe: config.nebenfarbe,
              );
            }),
            const SizedBox(height: 20),
          ],

          // ── Abyssus: Nur Warnungs-Text, keine Weisheiten ──────────────────
          if (reich == JenseitsReich.abyssus)
            _AbyssusWarnung(config: config),

          const SizedBox(height: 40),

          // ── Übergangs-Button (nach 10 Sekunden sichtbar) ──────────────────
          AnimatedOpacity(
            opacity: buttonSichtbar ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeIn,
            child: AnimatedSlide(
              offset: buttonSichtbar ? Offset.zero : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              child: GenesisButton(
                text: 'DIE KOSMISCHE REISE BEGINNT',
                icon: Icons.rocket_launch,
                onPressed: buttonSichtbar
                    ? () => context.go(AppRouten.phase8)
                    : null,
                typ: GenesisButtonTyp.primaer,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reich-Symbol (pulsierendes Icon-Widget)
// ─────────────────────────────────────────────────────────────────────────────

class _ReichSymbol extends StatelessWidget {
  final _ReichKonfiguration config;
  final Animation<double> pulsAnimation;

  const _ReichSymbol({
    required this.config,
    required this.pulsAnimation,
  });

  /// Icon je Reich.
  IconData get _icon {
    switch (config.stimmung) {
      case 'golden':   return Icons.brightness_high;
      case 'gruen':    return Icons.eco;
      case 'grau':     return Icons.cloud;
      case 'dunkel':   return Icons.nights_stay;
      case 'dunkelrot': return Icons.keyboard_double_arrow_down;
      default:         return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulsAnimation,
      builder: (context, child) {
        final glowRadius = 18.0 + pulsAnimation.value * 22.0;
        return Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: config.hauptfarbe.withValues(alpha: 0.6),
              width: 2.0,
            ),
            gradient: RadialGradient(
              colors: [
                config.hauptfarbe.withValues(alpha: 0.18),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: config.hauptfarbe.withValues(alpha: 0.28),
                blurRadius: glowRadius,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Icon(_icon, color: config.hauptfarbe, size: 54),
    )
        .animate()
        .fadeIn(duration: 1000.ms, delay: 200.ms)
        .scale(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          delay: 200.ms,
          curve: Curves.elasticOut,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hauptbotschaft (reich-spezifisch)
// ─────────────────────────────────────────────────────────────────────────────

class _Hauptbotschaft extends StatelessWidget {
  final _ReichKonfiguration config;
  final JenseitsReich reich;

  const _Hauptbotschaft({required this.config, required this.reich});

  /// Gibt eine erweiterte Beschreibung passend zum Reich zurück.
  String get _beschreibung {
    switch (reich) {
      case JenseitsReich.elysium:
        return 'Deine Seele hat den höchsten Gipfel der Menschlichkeit erklommen.\n'
            'Hier ruht das Licht, das du in der Welt verbreitetet hast.';
      case JenseitsReich.harmonia:
        return 'Dein Leben war ein ausgewogenes Zusammenspiel von Geben und Nehmen.\n'
            'Die Natur empfängt dich als eines ihrer eigenen.';
      case JenseitsReich.limbus:
        return 'Deine Seele steht am Scheideweg.\n'
            'Der Nebel hüllt alles ein – was wird die nächste Entscheidung sein?';
      case JenseitsReich.shadowlands:
        return 'Die Schatten deiner Handlungen sind lang.\n'
            'Aber auch hier kann Einsicht den Weg erhellen.';
      case JenseitsReich.abyssus:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Kernbotschaft
        Text(
          config.hauptbotschaft,
          style: AppTextStyles.ueberschrift3.copyWith(
            color: config.hauptfarbe,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 700.ms, delay: 700.ms),

        // Beschreibung (nur wenn vorhanden)
        if (_beschreibung.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            _beschreibung,
            style: AppTextStyles.koerper.copyWith(
              color: AppFarben.textSekundaer,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 700.ms, delay: 900.ms),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weisheits-Fragment (einzelnes freigeschaltetes Fragment)
// ─────────────────────────────────────────────────────────────────────────────

class _WeisheitsFragment extends StatelessWidget {
  final String text;
  final int nummer;
  final int gesamt;
  final bool istFreigeschaltet;
  final Color reichFarbe;
  final Color nebenfarbe;

  const _WeisheitsFragment({
    required this.text,
    required this.nummer,
    required this.gesamt,
    required this.istFreigeschaltet,
    required this.reichFarbe,
    required this.nebenfarbe,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: istFreigeschaltet ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeIn,
      child: AnimatedSlide(
        offset: istFreigeschaltet ? Offset.zero : const Offset(0, 0.2),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: reichFarbe.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: istFreigeschaltet
                  ? reichFarbe.withValues(alpha: 0.35)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fragment-Nummer als kleines Symbol
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: reichFarbe.withValues(alpha: 0.6),
                  ),
                  color: reichFarbe.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    '$nummer',
                    style: AppTextStyles.mikro.copyWith(
                      color: reichFarbe,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Weisheits-Text
              Expanded(
                child: Text(
                  '"$text"',
                  style: AppTextStyles.koerperKursiv.copyWith(
                    color: AppFarben.text,
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Abyssus-Warnung (spezielle Darstellung für das tiefste Reich)
// ─────────────────────────────────────────────────────────────────────────────

class _AbyssusWarnung extends StatelessWidget {
  final _ReichKonfiguration config;

  const _AbyssusWarnung({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppFarben.reichAbyssus.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppFarben.reichAbyssusGlow.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppFarben.reichAbyssusGlow,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            'Du hast den tiefsten Abgrund erreicht.',
            style: AppTextStyles.koerperKleinFett.copyWith(
              color: AppFarben.reichAbyssusGlow,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Doch selbst hier – im Herz der Dunkelheit –\n'
            'existiert ein Funke, der nicht erlöschen kann.',
            style: AppTextStyles.koerperKlein.copyWith(
              color: AppFarben.textSekundaer,
              height: 1.7,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 1200.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0));
  }
}
