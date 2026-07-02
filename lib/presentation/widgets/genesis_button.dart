// genesis_button.dart
// Wiederverwendbarer Button-Widget für GENESIS: Der Kreislauf des Lebens.
// Unterstützt drei visuelle Typen: primär (Gold), sekundär (outlined),
// und Gefahr (Rot). Enthält optionale Lade-Animation und Icon-Unterstützung.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: GenesisButtonTyp
// ─────────────────────────────────────────────────────────────────────────────

/// Die drei visuellen Varianten des GenesisButton.
enum GenesisButtonTyp {
  /// Goldener Hintergrund mit schwarzem Text – für die wichtigste Aktion.
  primaer,

  /// Transparenter Hintergrund mit goldenem Rand – für sekundäre Aktionen.
  sekundaer,

  /// Roter Hintergrund – für kritische/destruktive Aktionen (z.B. Löschen).
  gefahr,
}

// ─────────────────────────────────────────────────────────────────────────────
// GenesisButton
// ─────────────────────────────────────────────────────────────────────────────

/// Einheitlicher Button für das gesamte GENESIS-Spiel.
///
/// Beispiel:
/// ```dart
/// GenesisButton(
///   text: 'Neues Leben beginnen',
///   onPressed: () => context.go(AppRouten.neuesSpiel),
///   typ: GenesisButtonTyp.primaer,
///   icon: Icons.auto_awesome,
/// )
/// ```
class GenesisButton extends StatefulWidget {
  /// Beschriftungstext des Buttons.
  final String text;

  /// Callback, der beim Antippen ausgelöst wird.
  /// Wenn null, ist der Button deaktiviert.
  final VoidCallback? onPressed;

  /// Visuelle Variante des Buttons (Standard: primär).
  final GenesisButtonTyp typ;

  /// Breite des Buttons (Standard: gesamte verfügbare Breite).
  final double? breite;

  /// Höhe des Buttons (Standard: 56 logische Pixel).
  final double hoehe;

  /// Wenn true, wird ein Lade-Spinner angezeigt und der Button deaktiviert.
  final bool istLadend;

  /// Optionales Icon, das links vom Text angezeigt wird.
  final IconData? icon;

  const GenesisButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.typ = GenesisButtonTyp.primaer,
    this.breite,
    this.hoehe = 56,
    this.istLadend = false,
    this.icon,
  });

  @override
  State<GenesisButton> createState() => _GenesisButtonState();
}

class _GenesisButtonState extends State<GenesisButton>
    with SingleTickerProviderStateMixin {
  // Animation-Controller für den primären Pulsier-Effekt
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool _gedrueckt = false;

  @override
  void initState() {
    super.initState();
    // Sanftes Pulsieren nur für den primären Button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.typ == GenesisButtonTyp.primaer && widget.onPressed != null) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GenesisButton old) {
    super.didUpdateWidget(old);
    // Pulsieren bei Typ-Wechsel starten/stoppen
    if (widget.typ == GenesisButtonTyp.primaer &&
        widget.onPressed != null &&
        !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.typ != GenesisButtonTyp.primaer ||
        widget.onPressed == null) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Farbpalette je nach Typ ───────────────────────────────────────────────

  Color get _hauptFarbe {
    switch (widget.typ) {
      case GenesisButtonTyp.primaer:
        return AppFarben.goldGlanz;
      case GenesisButtonTyp.sekundaer:
        return Colors.transparent;
      case GenesisButtonTyp.gefahr:
        return AppFarben.fehler;
    }
  }

  Color get _textFarbe {
    switch (widget.typ) {
      case GenesisButtonTyp.primaer:
        return AppFarben.kosmischSchwarz;
      case GenesisButtonTyp.sekundaer:
        return AppFarben.goldGlanz;
      case GenesisButtonTyp.gefahr:
        return AppFarben.text;
    }
  }

  Color get _randFarbe {
    switch (widget.typ) {
      case GenesisButtonTyp.primaer:
        return Colors.transparent;
      case GenesisButtonTyp.sekundaer:
        return AppFarben.goldGlanz.withValues(alpha: 0.7);
      case GenesisButtonTyp.gefahr:
        return AppFarben.fehler;
    }
  }

  Color get _glowFarbe {
    switch (widget.typ) {
      case GenesisButtonTyp.primaer:
        return AppFarben.goldGlanz.withValues(alpha: 0.4);
      case GenesisButtonTyp.sekundaer:
        return AppFarben.goldGlanz.withValues(alpha: 0.2);
      case GenesisButtonTyp.gefahr:
        return AppFarben.fehler.withValues(alpha: 0.4);
    }
  }

  // ── Zustand: aktiv oder deaktiviert ──────────────────────────────────────

  bool get _istDeaktiviert =>
      widget.onPressed == null || widget.istLadend;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        // Pulsierender Glow nur für primären Button
        final glowRadius = widget.typ == GenesisButtonTyp.primaer &&
                !_istDeaktiviert
            ? 8.0 + _pulseAnimation.value * 8.0
            : 0.0;

        return GestureDetector(
          onTapDown: _istDeaktiviert
              ? null
              : (_) => setState(() => _gedrueckt = true),
          onTapUp: _istDeaktiviert
              ? null
              : (_) {
                  setState(() => _gedrueckt = false);
                  // Spürbares Feedback bei jedem Tastendruck
                  HapticFeedback.lightImpact();
                  widget.onPressed?.call();
                },
          onTapCancel: () => setState(() => _gedrueckt = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: widget.breite ?? double.infinity,
            height: widget.hoehe,
            decoration: BoxDecoration(
              color: _istDeaktiviert
                  ? AppFarben.nebelGrau.withValues(alpha: 0.3)
                  : (_gedrueckt
                      ? _hauptFarbe.withValues(alpha: 0.7)
                      : _hauptFarbe),
              border: Border.all(
                color: _istDeaktiviert
                    ? AppFarben.nebelGrau.withValues(alpha: 0.3)
                    : _randFarbe,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: _istDeaktiviert || _gedrueckt
                  ? null
                  : [
                      BoxShadow(
                        color: _glowFarbe,
                        blurRadius: glowRadius,
                        spreadRadius: 0.5,
                      ),
                    ],
            ),
            child: child,
          ),
        );
      },
      child: _ButtonInhalt(
        text: widget.text,
        textFarbe: _istDeaktiviert ? AppFarben.textDeaktiviert : _textFarbe,
        icon: widget.icon,
        istLadend: widget.istLadend,
        ladefarbe: _textFarbe,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internes Widget: Buttoninhalt (Text + Icon + Spinner)
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt den Inhalt des Buttons: optional Icon, Text oder Lade-Spinner.
class _ButtonInhalt extends StatelessWidget {
  final String text;
  final Color textFarbe;
  final IconData? icon;
  final bool istLadend;
  final Color ladefarbe;

  const _ButtonInhalt({
    required this.text,
    required this.textFarbe,
    this.icon,
    required this.istLadend,
    required this.ladefarbe,
  });

  @override
  Widget build(BuildContext context) {
    if (istLadend) {
      // Lade-Spinner in Button-Farbe
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(ladefarbe),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 200.ms);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: textFarbe, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: AppTextStyles.buttonPrimaer.copyWith(color: textFarbe),
        ),
      ],
    );
  }
}
