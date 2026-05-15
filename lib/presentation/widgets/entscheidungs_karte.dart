// entscheidungs_karte.dart
// Wiederverwendbares Widget für Entscheidungssituationen in GENESIS.
// Zeigt Kontext, Frage und wählbare Optionen mit Karma-Vorschau.
// Unterstützt die optionale Parallelvorschau (max. 5× pro Leben).

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/entscheidung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EntscheidungsKarte
// ─────────────────────────────────────────────────────────────────────────────

/// Vollständige Entscheidungskarte für den Spieler.
///
/// Zeigt den narrativen Kontext, die Frage und wählbare Optionen.
/// Nach der Auswahl erscheint der Konsequenz-Text; erst dann wird
/// der [onEntscheidung]-Callback aufgerufen.
///
/// Bei [EntscheidungModel.hatParallelvorschau == true] werden kurz
/// (1,5 s) verschwommene Voransichten der anderen Optionen gezeigt.
class EntscheidungsKarte extends StatefulWidget {
  /// Die vollständige Entscheidungssituation mit Optionen.
  final EntscheidungModel entscheidung;

  /// Wird aufgerufen, sobald der Konsequenz-Text ausgeblendet ist.
  /// Übergibt den Index der gewählten Option.
  final Function(int optionIndex) onEntscheidung;

  const EntscheidungsKarte({
    super.key,
    required this.entscheidung,
    required this.onEntscheidung,
  });

  @override
  State<EntscheidungsKarte> createState() => _EntscheidungsKarteState();
}

class _EntscheidungsKarteState extends State<EntscheidungsKarte>
    with SingleTickerProviderStateMixin {
  // Index der ausgewählten Option (null = noch keine Wahl)
  int? _gewaehltIndex;

  // Ob gerade die Konsequenz angezeigt wird
  bool _zeigeKonsequenz = false;

  // Ob gerade die Parallelvorschau aktiv ist
  bool _zeigeParallelvorschau = false;

  // Index für Leucht-Animation bei Auswahl
  int? _leuchtenIndex;

  // Animation-Controller für den Auswahl-Glow
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  // ── Option antippen ────────────────────────────────────────────────────────

  Future<void> _optionWaehlen(int index) async {
    if (_gewaehltIndex != null) return; // Bereits gewählt

    // Parallelvorschau anzeigen (falls verfügbar)
    if (widget.entscheidung.hatParallelvorschau) {
      setState(() => _zeigeParallelvorschau = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() => _zeigeParallelvorschau = false);
    }

    // Auswahl markieren + Leucht-Animation starten
    setState(() {
      _gewaehltIndex = index;
      _leuchtenIndex = index;
    });
    _glowController.forward();

    // Kurze Pause, dann Konsequenz einblenden
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _zeigeKonsequenz = true);

    // Konsequenz 2,5 Sekunden anzeigen, dann Callback
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    widget.onEntscheidung(index);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _zeigeKonsequenz
          ? _KonsequenzAnzeige(
              key: const ValueKey('konsequenz'),
              option: widget.entscheidung.optionen[_gewaehltIndex!],
            )
          : _EntscheidungsInhalt(
              key: const ValueKey('entscheidung'),
              entscheidung: widget.entscheidung,
              gewaehltIndex: _gewaehltIndex,
              leuchtenIndex: _leuchtenIndex,
              glowAnimation: _glowAnimation,
              zeigeParallelvorschau: _zeigeParallelvorschau,
              onOptionWaehlen: _optionWaehlen,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EntscheidungsInhalt – Kontext, Frage und Optionen
// ─────────────────────────────────────────────────────────────────────────────

class _EntscheidungsInhalt extends StatelessWidget {
  final EntscheidungModel entscheidung;
  final int? gewaehltIndex;
  final int? leuchtenIndex;
  final Animation<double> glowAnimation;
  final bool zeigeParallelvorschau;
  final Future<void> Function(int) onOptionWaehlen;

  const _EntscheidungsInhalt({
    super.key,
    required this.entscheidung,
    required this.gewaehltIndex,
    required this.leuchtenIndex,
    required this.glowAnimation,
    required this.zeigeParallelvorschau,
    required this.onOptionWaehlen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppFarben.mystischLila.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppFarben.mystischLila.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kontext-Text (kursiv, gedimmt)
            Text(
              entscheidung.kontext,
              style: AppTextStyles.koerperKursiv,
            ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 16),

            // Trennlinie
            Container(
              height: 1,
              color: AppFarben.mystischLila.withValues(alpha: 0.3),
            ),

            const SizedBox(height: 16),

            // Frage-Text (fett, hervorgehoben)
            Text(
              entscheidung.frage,
              style: AppTextStyles.ueberschrift4.copyWith(
                color: AppFarben.text,
                letterSpacing: 0.5,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 20),

            // Optionen als horizontale oder vertikale Karten
            _OptionenReihe(
              optionen: entscheidung.optionen,
              gewaehltIndex: gewaehltIndex,
              leuchtenIndex: leuchtenIndex,
              glowAnimation: glowAnimation,
              zeigeParallelvorschau: zeigeParallelvorschau,
              onOptionWaehlen: onOptionWaehlen,
            ),

            // Parallelvorschau-Hinweis
            if (entscheidung.hatParallelvorschau && gewaehltIndex == null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility,
                    color: AppFarben.goldGlanz.withValues(alpha: 0.6),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Parallelvorschau verfügbar',
                    style: AppTextStyles.beschriftung.copyWith(
                      color: AppFarben.goldGlanz.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OptionenReihe – horizontale Optionskarten
// ─────────────────────────────────────────────────────────────────────────────

class _OptionenReihe extends StatelessWidget {
  final List<EntscheidungsOption> optionen;
  final int? gewaehltIndex;
  final int? leuchtenIndex;
  final Animation<double> glowAnimation;
  final bool zeigeParallelvorschau;
  final Future<void> Function(int) onOptionWaehlen;

  const _OptionenReihe({
    required this.optionen,
    required this.gewaehltIndex,
    required this.leuchtenIndex,
    required this.glowAnimation,
    required this.zeigeParallelvorschau,
    required this.onOptionWaehlen,
  });

  @override
  Widget build(BuildContext context) {
    // Bei mehr als 2 Optionen: vertikal stapeln
    if (optionen.length > 2) {
      return Column(
        children: [
          for (int i = 0; i < optionen.length; i++) ...[
            _OptionsKarte(
              option: optionen[i],
              index: i,
              gewaehlt: gewaehltIndex == i,
              istGleuchend: leuchtenIndex == i,
              andereGewaehlt: gewaehltIndex != null && gewaehltIndex != i,
              glowAnimation: glowAnimation,
              zeigeParallelvorschau: zeigeParallelvorschau && gewaehltIndex == null,
              onTippen: () => onOptionWaehlen(i),
            ).animate().fadeIn(delay: (300 + i * 150).ms),
            if (i < optionen.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
    }

    // Bei 1-2 Optionen: nebeneinander
    return Row(
      children: [
        for (int i = 0; i < optionen.length; i++) ...[
          Expanded(
            child: _OptionsKarte(
              option: optionen[i],
              index: i,
              gewaehlt: gewaehltIndex == i,
              istGleuchend: leuchtenIndex == i,
              andereGewaehlt: gewaehltIndex != null && gewaehltIndex != i,
              glowAnimation: glowAnimation,
              zeigeParallelvorschau: zeigeParallelvorschau && gewaehltIndex == null,
              onTippen: () => onOptionWaehlen(i),
            ).animate().fadeIn(delay: (300 + i * 150).ms),
          ),
          if (i < optionen.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OptionsKarte – einzelne wählbare Option
// ─────────────────────────────────────────────────────────────────────────────

class _OptionsKarte extends StatefulWidget {
  final EntscheidungsOption option;
  final int index;
  final bool gewaehlt;
  final bool istGleuchend;
  final bool andereGewaehlt;
  final Animation<double> glowAnimation;
  final bool zeigeParallelvorschau;
  final VoidCallback onTippen;

  const _OptionsKarte({
    required this.option,
    required this.index,
    required this.gewaehlt,
    required this.istGleuchend,
    required this.andereGewaehlt,
    required this.glowAnimation,
    required this.zeigeParallelvorschau,
    required this.onTippen,
  });

  @override
  State<_OptionsKarte> createState() => _OptionsKarteState();
}

class _OptionsKarteState extends State<_OptionsKarte> {
  bool _gedrueckt = false;

  // Karma-Vorschau: dominante Dimension der Option
  KarmaDimension? get _dominantKarma {
    if (widget.option.karmaAuswirkung.isEmpty) return null;
    return widget.option.karmaAuswirkung.entries
        .reduce((a, b) => a.value.abs() >= b.value.abs() ? a : b)
        .key;
  }

  double get _karmaGesamtWert {
    if (widget.option.karmaAuswirkung.isEmpty) return 0;
    return widget.option.karmaAuswirkung.values
        .fold(0.0, (sum, v) => sum + v);
  }

  // Farbe basierend auf Egoismus/Altruismus-Wert
  Color get _karmaFarbe {
    final v = widget.option.egoistischAltruistisch;
    if (v > 0.3) return AppFarben.karmaPositiv;
    if (v < -0.3) return AppFarben.karmaNegatv;
    return AppFarben.karmaNeutral;
  }

  // Icon für die dominante Karma-Dimension
  IconData _karmaIcon(KarmaDimension dim) {
    switch (dim) {
      case KarmaDimension.mitgefuehl:
        return Icons.favorite_border;
      case KarmaDimension.ehrlichkeit:
        return Icons.verified_user_outlined;
      case KarmaDimension.mut:
        return Icons.shield_outlined;
      case KarmaDimension.grosszuegigkeit:
        return Icons.volunteer_activism;
      case KarmaDimension.weisheit:
        return Icons.auto_stories;
      case KarmaDimension.liebe:
        return Icons.favorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ausgeblendet wenn andere Option gewählt
    final opacity = widget.andereGewaehlt ? 0.35 : 1.0;

    return AnimatedBuilder(
      animation: widget.glowAnimation,
      builder: (context, child) {
        // Glow-Effekt bei gewählter Option
        final glowRadius = widget.istGleuchend
            ? widget.glowAnimation.value * 16.0
            : 0.0;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: opacity,
          child: GestureDetector(
            onTapDown: widget.andereGewaehlt
                ? null
                : (_) => setState(() => _gedrueckt = true),
            onTapUp: widget.andereGewaehlt
                ? null
                : (_) {
                    setState(() => _gedrueckt = false);
                    widget.onTippen();
                  },
            onTapCancel: () => setState(() => _gedrueckt = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.gewaehlt
                    ? _karmaFarbe.withValues(alpha: 0.2)
                    : (_gedrueckt
                        ? AppFarben.oberflaecheErhoben
                        : AppFarben.oberflaecheErhoben.withValues(alpha: 0.7)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.gewaehlt
                      ? _karmaFarbe
                      : AppFarben.nebelGrau.withValues(alpha: 0.5),
                  width: widget.gewaehlt ? 2.0 : 1.0,
                ),
                boxShadow: widget.istGleuchend && glowRadius > 0
                    ? [
                        BoxShadow(
                          color: _karmaFarbe.withValues(alpha: 0.5),
                          blurRadius: glowRadius,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  // Parallelvorschau: verschwommener Hintergrund
                  if (widget.zeigeParallelvorschau)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            color: _karmaFarbe.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    ),

                  // Inhalt der Option
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Options-Text
                      Text(
                        widget.option.text,
                        style: AppTextStyles.entscheidung.copyWith(
                          color: widget.gewaehlt
                              ? AppFarben.text
                              : AppFarben.text.withValues(alpha: 0.9),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Karma-Vorschau-Icons
                      _KarmaVorschauLeiste(
                        karmaWert: _karmaGesamtWert,
                        farbe: _karmaFarbe,
                        dominanteDim: _dominantKarma,
                        karmaIconFn: _karmaIcon,
                      ),

                      // Hinweis auf "klingt moralisch, aber..."
                      if (widget.option.klingtMoralischAber) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: AppFarben.karmaNeutral.withValues(alpha: 0.7),
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Schein oder Sein?',
                              style: AppTextStyles.mikro.copyWith(
                                color: AppFarben.karmaNeutral.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _KarmaVorschauLeiste – kleine Symbole zur Karma-Vorschau
// ─────────────────────────────────────────────────────────────────────────────

class _KarmaVorschauLeiste extends StatelessWidget {
  final double karmaWert;
  final Color farbe;
  final KarmaDimension? dominanteDim;
  final IconData Function(KarmaDimension) karmaIconFn;

  const _KarmaVorschauLeiste({
    required this.karmaWert,
    required this.farbe,
    required this.dominanteDim,
    required this.karmaIconFn,
  });

  @override
  Widget build(BuildContext context) {
    // Anzahl der Karma-Symbole (1-3) je nach Stärke
    final symbolAnzahl = karmaWert.abs() > 20 ? 3 : (karmaWert.abs() > 8 ? 2 : 1);
    final prefix = karmaWert >= 0 ? '+' : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dominante Karma-Dimension als Icon
        if (dominanteDim != null) ...[
          Icon(
            karmaIconFn(dominanteDim!),
            color: farbe.withValues(alpha: 0.8),
            size: 12,
          ),
          const SizedBox(width: 3),
        ],

        // Karma-Wert-Vorschau
        Text(
          '$prefix${karmaWert.toStringAsFixed(0)}',
          style: AppTextStyles.beschriftung.copyWith(
            color: farbe,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),

        const SizedBox(width: 4),

        // Symbole je nach Stärke
        for (int i = 0; i < symbolAnzahl; i++)
          Icon(
            karmaWert >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
            color: farbe.withValues(alpha: 0.6),
            size: 10,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _KonsequenzAnzeige – Ergebnis-Text nach der Wahl
// ─────────────────────────────────────────────────────────────────────────────

class _KonsequenzAnzeige extends StatelessWidget {
  final EntscheidungsOption option;

  const _KonsequenzAnzeige({
    super.key,
    required this.option,
  });

  @override
  Widget build(BuildContext context) {
    // Erste sofortige Konsequenz anzeigen (falls vorhanden)
    final konsequenzText = option.sofortigeKonsequenzen.isNotEmpty
        ? option.sofortigeKonsequenzen.first
        : 'Du hast entschieden.';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppFarben.goldGlanz.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kleines Ergebnis-Icon
            Icon(
              Icons.auto_awesome,
              color: AppFarben.goldGlanz.withValues(alpha: 0.8),
              size: 28,
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

            const SizedBox(height: 16),

            // Konsequenz-Text
            Text(
              konsequenzText,
              style: AppTextStyles.koerperGross.copyWith(
                color: AppFarben.text,
                fontStyle: FontStyle.italic,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

            // Gewählter Options-Text (klein, gedimmt)
            if (option.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '„${option.text}"',
                style: AppTextStyles.koerperKlein.copyWith(
                  color: AppFarben.textTertiaer,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
