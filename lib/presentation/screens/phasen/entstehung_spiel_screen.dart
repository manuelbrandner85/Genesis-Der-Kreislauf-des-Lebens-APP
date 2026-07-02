// entstehung_spiel_screen.dart
// Flutter-Wrapper-Screen für das Flame-Spiel "Spermium-Rennen".
// Bettet das FlameGame in einen Flutter-Screen ein, stellt Pause-Steuerung
// bereit und verarbeitet das Rennergebnis nach Abschluss.

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/entstehungs_controller.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/entstehungs_spiel.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/rennen_ergebnis.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EntstehungSpielScreen – Flutter-Wrapper
// ─────────────────────────────────────────────────────────────────────────────

/// Flutter-Screen der das Spermium-Rennen-Flame-Spiel einbettet.
///
/// Verwaltet:
/// - Pause/Fortsetzen-Steuerung
/// - Ergebnis-Verarbeitung nach dem Rennen
/// - Spielende-Overlay (Sieg / Niederlage)
class EntstehungSpielScreen extends ConsumerStatefulWidget {
  const EntstehungSpielScreen({super.key});

  @override
  ConsumerState<EntstehungSpielScreen> createState() =>
      _EntstehungSpielScreenState();
}

class _EntstehungSpielScreenState
    extends ConsumerState<EntstehungSpielScreen> {
  // Das Flame-Spiel (wird einmalig erstellt und wiederverwendet)
  late final EntstehungsSpiel _spiel;

  // Aktueller Spielzustand für UI-Reaktion
  EntstehungsSpielZustand _spielZustand =
      EntstehungsSpielZustand.laufend;

  // Rennergebnis (gesetzt nach Spielende)
  RennenErgebnis? _ergebnis;

  // Verarbeitung läuft (für Ladeindikator)
  bool _verarbeiteErgebnis = false;

  @override
  void initState() {
    super.initState();

    // Flame-Spiel erstellen und Callbacks registrieren
    _spiel = EntstehungsSpiel();

    _spiel.onRennenBeendet = (ergebnis) {
      if (mounted) {
        setState(() {
          _ergebnis = ergebnis;
          _spielZustand = EntstehungsSpielZustand.rennenBeendet;
        });
      }
    };

    _spiel.onZustandGeaendert = (zustand) {
      if (mounted) {
        setState(() => _spielZustand = zustand);
      }
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Flame-Spiel (Vollbild) ────────────────────────────────────────
          GameWidget(
            game: _spiel,
            // Keine Ladeansicht nötig – alles geometrisch gezeichnet
            loadingBuilder: (context) => const _LadeScreen(),
          ),

          // ── Pause-Button (oben rechts, klein) ─────────────────────────────
          if (_spielZustand == EntstehungsSpielZustand.laufend ||
              _spielZustand == EntstehungsSpielZustand.routenWahl)
            Positioned(
              top: 12,
              right: 12,
              child: SafeArea(
                child: _PauseButton(
                  onPause: () => _spiel.pauseUmschalten(),
                ),
              ),
            ),

          // ── Pause-Overlay ─────────────────────────────────────────────────
          if (_spielZustand == EntstehungsSpielZustand.pausiert)
            _PauseOverlay(
              onFortsetzen: () => _spiel.pauseUmschalten(),
              // GoRouter-Navigation: pop() würde crashen ("nothing to pop"),
              // da alle Screens per go() ersetzt werden.
              onAbbrechen: () => context.go(AppRouten.hauptMenue),
            ),

          // ── Spielende-Overlay (Niederlage) ─────────────────────────────────
          if (_spielZustand == EntstehungsSpielZustand.spielVorbei)
            _SpielVorbeiOverlay(
              onWeiter: () {
                // Kurz warten bis das Rennen automatisch beendet
              },
            ),

          // ── Rennen-Abschluss-Overlay ──────────────────────────────────────
          if (_spielZustand == EntstehungsSpielZustand.rennenBeendet &&
              _ergebnis != null)
            _RennenErgebnisOverlay(
              ergebnis: _ergebnis!,
              verarbeitet: _verarbeiteErgebnis,
              onWeiter: () => _ergebnisVerarbeiten(_ergebnis!),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Ergebnis verarbeiten
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _ergebnisVerarbeiten(RennenErgebnis ergebnis) async {
    if (_verarbeiteErgebnis) return;

    setState(() => _verarbeiteErgebnis = true);

    await EntstehungsController.rennenAbschliessen(
      ref,
      ergebnis,
      context,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LadeScreen – Lade-Platzhalter
// ─────────────────────────────────────────────────────────────────────────────

class _LadeScreen extends StatelessWidget {
  const _LadeScreen();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF050510),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFFFD700),
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text(
              'Das Rennen bereitet sich vor...',
              style: TextStyle(
                fontFamily: 'Cinzel',
                color: Color(0xFF9CA3AF),
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PauseButton
// ─────────────────────────────────────────────────────────────────────────────

class _PauseButton extends StatelessWidget {
  final VoidCallback onPause;

  const _PauseButton({required this.onPause});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPause,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.pause,
          color: Colors.white,
          size: 20,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PauseOverlay
// ─────────────────────────────────────────────────────────────────────────────

class _PauseOverlay extends StatelessWidget {
  final VoidCallback onFortsetzen;
  final VoidCallback onAbbrechen;

  const _PauseOverlay({
    required this.onFortsetzen,
    required this.onAbbrechen,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PAUSE',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
                letterSpacing: 6,
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 48),

            // Fortsetzen
            _OverlayButton(
              text: 'FORTSETZEN',
              farbe: const Color(0xFFFFD700),
              onTap: onFortsetzen,
            ),

            const SizedBox(height: 16),

            // Abbrechen
            _OverlayButton(
              text: 'ABBRECHEN',
              farbe: Colors.white.withValues(alpha: 0.4),
              onTap: onAbbrechen,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SpielVorbeiOverlay
// ─────────────────────────────────────────────────────────────────────────────

class _SpielVorbeiOverlay extends StatelessWidget {
  final VoidCallback onWeiter;

  const _SpielVorbeiOverlay({required this.onWeiter});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              color: Color(0xFFFF4466),
              size: 64,
            ).animate().scale(duration: 500.ms),

            const SizedBox(height: 24),

            const Text(
              'ALLE LEBEN VERBRAUCHT',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF4466),
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            const Text(
              'Das Rennen wird trotzdem beendet...',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),

            const SizedBox(height: 32),

            const CircularProgressIndicator(
              color: Color(0xFFFF4466),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RennenErgebnisOverlay
// ─────────────────────────────────────────────────────────────────────────────

class _RennenErgebnisOverlay extends StatelessWidget {
  final RennenErgebnis ergebnis;
  final bool verarbeitet;
  final VoidCallback onWeiter;

  const _RennenErgebnisOverlay({
    required this.ergebnis,
    required this.verarbeitet,
    required this.onWeiter,
  });

  @override
  Widget build(BuildContext context) {
    final attribute = ergebnis.attributeBerechnen();
    final istErster = ergebnis.endPlatzierung == 1;

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.88),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sieges-/Niederlage-Icon
                Icon(
                  istErster ? Icons.emoji_events : Icons.timeline,
                  color: istErster
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF9CA3AF),
                  size: 64,
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 16),

                // Titel
                Text(
                  istErster ? 'GEBOREN!' : 'RENNEN BEENDET',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: istErster
                        ? const Color(0xFFFFD700)
                        : Colors.white,
                    letterSpacing: 3,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 8),

                // Platzierung
                Text(
                  'Platz ${ergebnis.endPlatzierung} von 1.000.000',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 24),

                // Route-Anzeige
                _RoutenBadge(route: ergebnis.gewaehltRoute),

                const SizedBox(height: 24),

                // Attribute-Tabelle
                _AttributeTabelle(attribute: attribute),

                const SizedBox(height: 32),

                // Weiter-Button
                if (!verarbeitet)
                  _OverlayButton(
                    text: 'DIESES LEBEN BEGINNEN',
                    farbe: const Color(0xFFFFD700),
                    onTap: onWeiter,
                  )
                else
                  const Column(
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFFFFD700),
                        strokeWidth: 2,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Leben wird vorbereitet...',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RoutenBadge
// ─────────────────────────────────────────────────────────────────────────────

class _RoutenBadge extends StatelessWidget {
  final RoutenTyp route;

  const _RoutenBadge({required this.route});

  Color get _farbe {
    switch (route) {
      case RoutenTyp.kraft:
        return const Color(0xFFFF3333);
      case RoutenTyp.intelligenz:
        return const Color(0xFF3399FF);
      case RoutenTyp.empathie:
        return const Color(0xFF33FF66);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _farbe.withValues(alpha: 0.6), width: 1.5),
        color: _farbe.withValues(alpha: 0.12),
      ),
      child: Column(
        children: [
          Text(
            'ROUTE: ${route.anzeigeName.toUpperCase()}',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _farbe,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            route.beschreibung,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 12,
              color: _farbe.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AttributeTabelle
// ─────────────────────────────────────────────────────────────────────────────

class _AttributeTabelle extends StatelessWidget {
  final Map<String, double> attribute;

  const _AttributeTabelle({required this.attribute});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'STARTATTRIBUTE',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          ...attribute.entries.map(
            (eintrag) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AttributeZeile(
                name: eintrag.key,
                wert: eintrag.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributeZeile extends StatelessWidget {
  final String name;
  final double wert;

  const _AttributeZeile({required this.name, required this.wert});

  @override
  Widget build(BuildContext context) {
    final farbe = wert >= 60 ? const Color(0xFFFFD700) : Colors.white;

    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            name.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Hintergrundbalken
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Füllbalken
              FractionallySizedBox(
                widthFactor: (wert / 100.0).clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: farbe.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            wert.toStringAsFixed(0),
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 12,
              color: farbe,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OverlayButton – Allgemeiner Button für Overlays
// ─────────────────────────────────────────────────────────────────────────────

class _OverlayButton extends StatelessWidget {
  final String text;
  final Color farbe;
  final VoidCallback onTap;

  const _OverlayButton({
    required this.text,
    required this.farbe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: farbe, width: 1.5),
          borderRadius: BorderRadius.circular(4),
          color: farbe.withValues(alpha: 0.1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: farbe,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
