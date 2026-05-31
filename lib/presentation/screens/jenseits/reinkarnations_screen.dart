// reinkarnations_screen.dart
// Reinkarnations-Entscheidungs-Screen für GENESIS: Der Kreislauf des Lebens.
// Der Spieler wählt zwischen zwei Wiedergeburtspfaden: Neue Seele (Neustart)
// oder Karma-Erbe (30% Karma übertragen, epigenetische Stärken beibehalten).
// Zeigt den Seelen-Code und die Karma-Zusammenfassung des letzten Lebens.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/karma_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/genesis_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ReinkarnationsScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Screen für die Reinkarnations-Entscheidung nach dem Jenseits.
///
/// Zeigt zwei mögliche Pfade für die nächste Inkarnation:
/// 1. **Neue Seele**: Frischer Neustart, neues Zeitalter, Karma-Reset,
///    genetischer Code wird vollständig neu generiert.
/// 2. **Karma-Erbe**: 30 % des Karma-Durchschnitts wird vererbt,
///    epigenetische Stärken bleiben erhalten.
///
/// Zeigt außerdem den Seelen-Code und die Karma-Zusammenfassung des letzten Lebens.
///
/// Navigationsziel:
/// - "Neu geboren werden" → [HauptMenueScreen] (`/hauptmenue`)
class ReinkarnationsScreen extends ConsumerStatefulWidget {
  const ReinkarnationsScreen({super.key});

  @override
  ConsumerState<ReinkarnationsScreen> createState() =>
      _ReinkarnationsScreenState();
}

class _ReinkarnationsScreenState extends ConsumerState<ReinkarnationsScreen>
    with TickerProviderStateMixin {
  // Aktuell gewählter Pfad (null = noch keine Auswahl)
  _ReinkarnationsPfad? _gewaehlterPfad;

  // Einblend-Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Kosmische Hintergrund-Animation (sanft weiß-blauer Schimmer)
  late AnimationController _hintergrundController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Hintergrund-Schimmer: sanfte Endlosschleife
    _hintergrundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _hintergrundController.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  /// Verarbeitet die Pfadwahl und navigiert zum Hauptmenü.
  void _neuGeborenWerden() {
    if (_gewaehlterPfad == null) return;

    // Neue Seele: Karma vollständig zurücksetzen
    if (_gewaehlterPfad == _ReinkarnationsPfad.neueSeele) {
      ref.read(karmaProvider.notifier).karmaZuruecksetzen();
    }
    // Karma-Erbe: 30 % des Karma-Werts in die neue Seele vererben
    else {
      final aktuell = ref.read(karmaProvider);
      ref.read(karmaProvider.notifier).karmaSetzen(
        aktuell.copyWith(
          mitgefuehl:      aktuell.mitgefuehl      * 0.3,
          ehrlichkeit:     aktuell.ehrlichkeit     * 0.3,
          mut:             aktuell.mut              * 0.3,
          grosszuegigkeit: aktuell.grosszuegigkeit * 0.3,
          weisheit:        aktuell.weisheit         * 0.3,
          liebe:           aktuell.liebe            * 0.3,
        ),
      );
    }

    // Neues Spiel beginnen – zum Hauptmenü
    context.go(AppRouten.hauptMenue);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final karma = ref.watch(karmaProvider);
    final durchschnitt = karma.durchschnitt;
    final jenseitsReich = karma.jenseitsReich;

    // Seelen-Code aus Karma und Reich berechnen
    final seelenCode = _berechneSeelenCode(durchschnitt, jenseitsReich);
    // Karma-Erbe-Wert: 30 % des Karma-Durchschnitts
    final karmaErbeWert = durchschnitt * 0.3;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1F),
      body: Stack(
        children: [
          // Weiß-blauer Hintergrund-Gradient (sanfter Übergang)
          _HintergrundSchimmer(controller: _hintergrundController),

          // Haupt-Inhalt
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // ── Kopfzeile ─────────────────────────────────────────────
                  _Kopfzeile(),

                  // ── Scrollbarer Inhalt ─────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Seelen-Code des letzten Lebens
                          _SeelenCodeAnzeige(seelenCode: seelenCode),

                          const SizedBox(height: 18),

                          // Karma-Zusammenfassung des letzten Lebens
                          _KarmaZusammenfassung(
                            karma: karma,
                            durchschnitt: durchschnitt,
                            karmaErbeWert: karmaErbeWert,
                            jenseitsReich: jenseitsReich,
                          ),

                          const SizedBox(height: 28),

                          // Pfad-Überschrift
                          Text(
                            'WÄHLE DEN PFAD DER NÄCHSTEN INKARNATION',
                            style: AppTextStyles.beschriftungGross.copyWith(
                              color: AppFarben.textTertiaer,
                              letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

                          const SizedBox(height: 18),

                          // Pfad 1: Neue Seele
                          _PfadKarte(
                            pfad: _ReinkarnationsPfad.neueSeele,
                            istGewaehlt: _gewaehlterPfad == _ReinkarnationsPfad.neueSeele,
                            onAusgewaehlt: () => setState(
                              () => _gewaehlterPfad = _ReinkarnationsPfad.neueSeele,
                            ),
                            karmaErbeWert: null,
                            verzoegerung: const Duration(milliseconds: 700),
                          ),

                          const SizedBox(height: 12),

                          // Trenn-Oder
                          _OderTrenner(),

                          const SizedBox(height: 12),

                          // Pfad 2: Karma-Erbe
                          _PfadKarte(
                            pfad: _ReinkarnationsPfad.karmaErbe,
                            istGewaehlt: _gewaehlterPfad == _ReinkarnationsPfad.karmaErbe,
                            onAusgewaehlt: () => setState(
                              () => _gewaehlterPfad = _ReinkarnationsPfad.karmaErbe,
                            ),
                            karmaErbeWert: karmaErbeWert,
                            verzoegerung: const Duration(milliseconds: 900),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // ── Aktions-Buttons ────────────────────────────────────────
                  _AktionsBereich(
                    gewaehlterPfad: _gewaehlterPfad,
                    onBestaetigt: _neuGeborenWerden,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Berechnet einen einzigartigen Seelen-Code aus Karma-Wert und Reich.
  String _berechneSeelenCode(double karma, JenseitsReich reich) {
    final reichKuerzel = switch (reich) {
      JenseitsReich.elysium    => 'EL',
      JenseitsReich.harmonia   => 'HA',
      JenseitsReich.limbus     => 'LI',
      JenseitsReich.shadowlands => 'SH',
      JenseitsReich.abyssus    => 'AB',
    };
    final karmaInt = karma.abs().toInt().toString().padLeft(3, '0');
    final suffix = ((karma.abs() * 13 + 47) % 999).toInt().toString().padLeft(3, '0');
    return '$reichKuerzel-$karmaInt-$suffix';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum: Reinkarnationspfad
// ─────────────────────────────────────────────────────────────────────────────

/// Die zwei möglichen Pfade der Wiedergeburt.
enum _ReinkarnationsPfad {
  /// Kompletter Neustart: Karma-Reset, neue Genetik, freie Zeitalter-Wahl
  neueSeele,

  /// 30 % des Karma wird vererbt, epigenetische Stärken bleiben erhalten
  karmaErbe,
}

// ─────────────────────────────────────────────────────────────────────────────
// Hintergrund-Schimmer (weiß-blauer Gradient)
// ─────────────────────────────────────────────────────────────────────────────

class _HintergrundSchimmer extends StatelessWidget {
  final AnimationController controller;

  const _HintergrundSchimmer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Sanfter Schimmer: Opazität pulsiert leicht
        final schimmerAlpha = 0.04 +
            0.03 * math.sin(controller.value * math.pi * 2);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: schimmerAlpha * 2),
                const Color(0xFF0D1B2A).withValues(alpha: 0.95),
                const Color(0xFF0A0A1F),
              ],
              stops: const [0.0, 0.35, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kopfzeile
// ─────────────────────────────────────────────────────────────────────────────

class _Kopfzeile extends StatelessWidget {
  const _Kopfzeile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppFarben.mystischLila.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Kreis-Symbol für Wiedergeburt
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppFarben.mystischLila.withValues(alpha: 0.3),
                      AppFarben.kosmischViolett.withValues(alpha: 0.15),
                    ],
                  ),
                  border: Border.all(
                    color: AppFarben.mystischLila.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.autorenew,
                  color: AppFarben.goldGlanz,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REINKARNATION',
                    style: AppTextStyles.ueberschrift3.copyWith(
                      color: AppFarben.goldGlanz,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Der Kreislauf dreht sich weiter',
                    style: AppTextStyles.koerperKursiv.copyWith(
                      color: AppFarben.textTertiaer,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 700.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Seelen-Code-Anzeige
// ─────────────────────────────────────────────────────────────────────────────

class _SeelenCodeAnzeige extends StatelessWidget {
  final String seelenCode;

  const _SeelenCodeAnzeige({required this.seelenCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppFarben.goldGlanz.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'SEELEN-CODE DES LETZTEN LEBENS',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.textTertiaer,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            seelenCode,
            style: AppTextStyles.spielStatusWert.copyWith(
              fontSize: 26,
              letterSpacing: 7.0,
              color: AppFarben.goldGlanz,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Diese Signatur bleibt im kosmischen Gedächtnis erhalten.',
            style: AppTextStyles.mikro.copyWith(
              color: AppFarben.textTertiaer,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Karma-Zusammenfassung
// ─────────────────────────────────────────────────────────────────────────────

class _KarmaZusammenfassung extends StatelessWidget {
  final KarmaProfilModel karma;
  final double durchschnitt;
  final double karmaErbeWert;
  final JenseitsReich jenseitsReich;

  const _KarmaZusammenfassung({
    required this.karma,
    required this.durchschnitt,
    required this.karmaErbeWert,
    required this.jenseitsReich,
  });

  Color get _karmaFarbe => AppFarben.fuerKarmaWert(durchschnitt);

  String get _reichBezeichnung => switch (jenseitsReich) {
    JenseitsReich.elysium    => 'Elysium',
    JenseitsReich.harmonia   => 'Harmonia',
    JenseitsReich.limbus     => 'Limbus',
    JenseitsReich.shadowlands => 'Shadowlands',
    JenseitsReich.abyssus    => 'Abyssus',
  };

  Color get _reichFarbe => switch (jenseitsReich) {
    JenseitsReich.elysium    => AppFarben.reichElysium,
    JenseitsReich.harmonia   => AppFarben.reichHarmonia,
    JenseitsReich.limbus     => AppFarben.reichLimbus,
    JenseitsReich.shadowlands => AppFarben.reichShadowlands,
    JenseitsReich.abyssus    => AppFarben.reichAbyssus,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppFarben.oberflaecheErhoben,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppFarben.trenner,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KARMA-BILANZ DES LETZTEN LEBENS',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.textTertiaer,
            ),
          ),
          const SizedBox(height: 14),

          // Gesamt-Karma + erreichtes Reich
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gesamt-Karma', style: AppTextStyles.beschriftung),
                    const SizedBox(height: 3),
                    Text(
                      '${durchschnitt >= 0 ? '+' : ''}${durchschnitt.toStringAsFixed(1)}',
                      style: AppTextStyles.spielStatusWert.copyWith(
                        fontSize: 28,
                        color: _karmaFarbe,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Erreichtes Reich', style: AppTextStyles.beschriftung),
                  const SizedBox(height: 3),
                  Text(
                    _reichBezeichnung.toUpperCase(),
                    style: AppTextStyles.koerperKleinFett.copyWith(
                      color: _reichFarbe,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Karma-Balken (normiert: -100 → 0.0, 0 → 0.5, +100 → 1.0)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ((durchschnitt + 100.0) / 200.0).clamp(0.0, 1.0),
              backgroundColor: AppFarben.karmaNegatv.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation<Color>(_karmaFarbe),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 12),

          // Vorschau: Karma-Erbe-Wert
          Text(
            'Karma-Erbe (30 %): '
            '${karmaErbeWert >= 0 ? '+' : ''}${karmaErbeWert.toStringAsFixed(1)}',
            style: AppTextStyles.koerperKlein.copyWith(
              color: AppFarben.karmaNeutral,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pfad-Karte
// ─────────────────────────────────────────────────────────────────────────────

class _PfadKarte extends StatelessWidget {
  final _ReinkarnationsPfad pfad;
  final bool istGewaehlt;
  final VoidCallback onAusgewaehlt;
  final double? karmaErbeWert; // Nur für Karma-Erbe relevant
  final Duration verzoegerung;

  const _PfadKarte({
    required this.pfad,
    required this.istGewaehlt,
    required this.onAusgewaehlt,
    required this.karmaErbeWert,
    required this.verzoegerung,
  });

  // ── Pfad-spezifische Eigenschaften ──────────────────────────────────────

  String get _titel => switch (pfad) {
    _ReinkarnationsPfad.neueSeele => 'NEUE SEELE',
    _ReinkarnationsPfad.karmaErbe => 'KARMA-ERBE',
  };

  String get _untertitel => switch (pfad) {
    _ReinkarnationsPfad.neueSeele => 'Frischer Start – alles beginnt neu',
    _ReinkarnationsPfad.karmaErbe => 'Die Seele trägt ihre Geschichte weiter',
  };

  IconData get _icon => switch (pfad) {
    _ReinkarnationsPfad.neueSeele => Icons.child_friendly_outlined,
    _ReinkarnationsPfad.karmaErbe => Icons.all_inclusive,
  };

  Color get _akzentFarbe => switch (pfad) {
    _ReinkarnationsPfad.neueSeele => const Color(0xFFF5F5F5), // Weiß-Hellblau
    _ReinkarnationsPfad.karmaErbe => AppFarben.goldGlanz,
  };

  List<String> get _merkmale => switch (pfad) {
    _ReinkarnationsPfad.neueSeele => [
      'Karma vollständig auf 0 zurückgesetzt',
      'Freie Zeitalter-Wahl für das neue Leben',
      'Genetischer Code komplett neu generiert',
    ],
    _ReinkarnationsPfad.karmaErbe => [
      '30 % des Karma-Durchschnitts wird vererbt',
      'Epigenetische Stärken bleiben aktiv',
      'Ein prägendes Erinnerungs-Fragment bleibt',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAusgewaehlt,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: istGewaehlt
              ? _akzentFarbe.withValues(alpha: 0.06)
              : AppFarben.oberflaecheErhoben,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: istGewaehlt
                ? _akzentFarbe.withValues(alpha: 0.55)
                : AppFarben.nebelGrau.withValues(alpha: 0.35),
            width: istGewaehlt ? 1.5 : 1.0,
          ),
          boxShadow: istGewaehlt
              ? [
                  BoxShadow(
                    color: _akzentFarbe.withValues(alpha: 0.10),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon-Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: istGewaehlt
                    ? _akzentFarbe.withValues(alpha: 0.15)
                    : AppFarben.nebelGrau.withValues(alpha: 0.15),
                border: Border.all(
                  color: istGewaehlt
                      ? _akzentFarbe
                      : AppFarben.nebelGrau,
                  width: 1.5,
                ),
              ),
              child: Icon(
                _icon,
                color: istGewaehlt ? _akzentFarbe : AppFarben.textSekundaer,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Pfad-Inhalt
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titel + Auswahl-Indikator
                  Row(
                    children: [
                      Text(
                        _titel,
                        style: AppTextStyles.ueberschrift4.copyWith(
                          color: istGewaehlt ? _akzentFarbe : AppFarben.text,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      // Auswahl-Kreis
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: istGewaehlt
                                ? _akzentFarbe
                                : AppFarben.nebelGrau,
                            width: 2,
                          ),
                          color: istGewaehlt
                              ? _akzentFarbe
                              : Colors.transparent,
                        ),
                        child: istGewaehlt
                            ? const Icon(
                                Icons.check,
                                color: AppFarben.kosmischSchwarz,
                                size: 12,
                              )
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Untertitel
                  Text(
                    _untertitel,
                    style: AppTextStyles.koerperKlein.copyWith(
                      color: AppFarben.textSekundaer,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  // Karma-Erbe-Wert-Chip (nur für Karma-Erbe Pfad)
                  if (pfad == _ReinkarnationsPfad.karmaErbe &&
                      karmaErbeWert != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppFarben.fuerKarmaWert(karmaErbeWert!)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppFarben.fuerKarmaWert(karmaErbeWert!)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Ererbtes Karma: '
                        '${karmaErbeWert! >= 0 ? '+' : ''}'
                        '${karmaErbeWert!.toStringAsFixed(1)}',
                        style: AppTextStyles.mikro.copyWith(
                          color: AppFarben.fuerKarmaWert(karmaErbeWert!),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Merkmals-Liste
                  ..._merkmale.map(
                    (merkmal) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_small,
                            color: istGewaehlt
                                ? _akzentFarbe
                                : AppFarben.textTertiaer,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              merkmal,
                              style: AppTextStyles.koerperKlein.copyWith(
                                color: istGewaehlt
                                    ? AppFarben.text
                                    : AppFarben.textSekundaer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: verzoegerung)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.06, end: 0, duration: 420.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Oder-Trenner
// ─────────────────────────────────────────────────────────────────────────────

class _OderTrenner extends StatelessWidget {
  const _OderTrenner();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppFarben.nebelGrau.withValues(alpha: 0.25),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ODER',
            style: AppTextStyles.beschriftung.copyWith(
              color: AppFarben.textTertiaer,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppFarben.nebelGrau.withValues(alpha: 0.25),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 800.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Aktions-Bereich (Bestätigungs-Button)
// ─────────────────────────────────────────────────────────────────────────────

class _AktionsBereich extends StatelessWidget {
  final _ReinkarnationsPfad? gewaehlterPfad;
  final VoidCallback onBestaetigt;

  const _AktionsBereich({
    required this.gewaehlterPfad,
    required this.onBestaetigt,
  });

  String get _buttonText => switch (gewaehlterPfad) {
    _ReinkarnationsPfad.neueSeele => 'ALS NEUE SEELE NEU GEBOREN WERDEN',
    _ReinkarnationsPfad.karmaErbe => 'MIT KARMA-ERBE NEU GEBOREN WERDEN',
    null => 'WÄHLE EINEN PFAD',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1F).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: AppFarben.mystischLila.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          GenesisButton(
            text: _buttonText,
            icon: Icons.arrow_forward,
            onPressed: gewaehlterPfad != null ? onBestaetigt : null,
            typ: GenesisButtonTyp.primaer,
          ),
          const SizedBox(height: 10),
          Text(
            'Diese Entscheidung kann nicht rückgängig gemacht werden.',
            style: AppTextStyles.mikro.copyWith(
              color: AppFarben.textTertiaer,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
