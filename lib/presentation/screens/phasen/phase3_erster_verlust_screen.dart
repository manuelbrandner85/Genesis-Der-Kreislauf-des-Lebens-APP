// phase3_erster_verlust_screen.dart
// Phase 3 Prüfung: "Der erste Verlust" – Tod eines geliebten Haustieres
// oder Abschied eines Freundes. Cinematic Text-Erzählung + 2 Reaktions-Optionen.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/genesis_button.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Kapitel-Daten (Erzählschritte)
// ─────────────────────────────────────────────────────────────────────────────

/// Ein einzelnes Erzähl-Kapitel mit Text und optionalem Icon
class _KapitelDaten {
  final String text;
  final IconData? icon;
  final Duration einblendVerzoegerung;

  const _KapitelDaten({
    required this.text,
    this.icon,
    this.einblendVerzoegerung = Duration.zero,
  });
}

/// Alle Kapitel der Verlust-Erzählung
const List<_KapitelDaten> _kapitel = [
  _KapitelDaten(
    text: 'Bello liegt reglos im Gras.',
    icon: Icons.pets,
    einblendVerzoegerung: Duration.zero,
  ),
  _KapitelDaten(
    text: 'Du rufst seinen Namen. Nichts.',
    icon: null,
    einblendVerzoegerung: Duration(milliseconds: 500),
  ),
  _KapitelDaten(
    text: 'Du verstehst noch nicht was "für immer" bedeutet.',
    icon: null,
    einblendVerzoegerung: Duration(milliseconds: 800),
  ),
  _KapitelDaten(
    text: 'Aber du weißt: etwas ist anders.',
    icon: null,
    einblendVerzoegerung: Duration(milliseconds: 600),
  ),
  _KapitelDaten(
    text: 'Etwas, das nicht zurückkommt.',
    icon: Icons.hourglass_empty,
    einblendVerzoegerung: Duration(milliseconds: 1000),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Phase 3 Erster Verlust Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Unvermeidbare Prüfung in Phase 3: Der erste Verlust.
///
/// Zeigt eine text-basierte Erzählung in Kapiteln,
/// dann 2 Reaktions-Optionen die emotionale Verarbeitung + Karma beeinflussen.
class Phase3ErsterVerlustScreen extends ConsumerStatefulWidget {
  const Phase3ErsterVerlustScreen({super.key});

  @override
  ConsumerState<Phase3ErsterVerlustScreen> createState() =>
      _Phase3ErsterVerlustScreenState();
}

class _Phase3ErsterVerlustScreenState
    extends ConsumerState<Phase3ErsterVerlustScreen>
    with SingleTickerProviderStateMixin {
  // Aktuell sichtbares Kapitel (0-basiert, -1 = noch nicht gestartet)
  int _aktuellesKapitel = -1;

  // Ob alle Kapitel gezeigt wurden
  bool _erzaehlungFertig = false;

  // Gewählte Reaktions-Kombination (null = noch keine Wahl)
  // Erste Reaktion: 0 = Weinen, 1 = Nicht-Weinen
  // Zweite Reaktion: 0 = Fragen, 1 = Schweigen
  int? _ersteReaktion;
  int? _zweiteReaktion;

  // Ob das Ergebnis-Screen angezeigt wird
  bool _zeigeErgebnis = false;

  @override
  void initState() {
    super.initState();
    _erzaehlungStarten();
  }

  Future<void> _erzaehlungStarten() async {
    // Kapitel nacheinander aufdecken
    for (int i = 0; i < _kapitel.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;
      setState(() => _aktuellesKapitel = i);
    }

    // Kurze Pause, dann Reaktions-Optionen zeigen
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() => _erzaehlungFertig = true);
  }

  Future<void> _reaktionGewaehlt(bool istErste, int optionIndex) async {
    if (istErste) {
      setState(() => _ersteReaktion = optionIndex);
    } else {
      setState(() => _zweiteReaktion = optionIndex);
    }

    // Wenn beide Reaktionen gewählt wurden
    if (_ersteReaktion != null && _zweiteReaktion != null) {
      await _karmaAnwenden();
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _zeigeErgebnis = true);
    }
  }

  Future<void> _karmaAnwenden() async {
    // Erste Reaktion: Weinen = mehr Mitgefühl/Liebe; Nicht-Weinen = mehr Kontrolle
    final weinenBonus = _ersteReaktion == 0
        ? {
            KarmaDimension.mitgefuehl: 6.0,
            KarmaDimension.liebe: 4.0,
          }
        : {
            KarmaDimension.mut: 3.0,
          };

    // Zweite Reaktion: Fragen = mehr Weisheit; Schweigen = innere Verarbeitung
    final fragenBonus = _zweiteReaktion == 0
        ? {
            KarmaDimension.weisheit: 5.0,
            KarmaDimension.mitgefuehl: 2.0,
          }
        : {
            KarmaDimension.liebe: 3.0,
          };

    // Karma über den SpielProvider anwenden
    // (vereinfacht: wir protokollieren die Entscheidung)
    for (final dim in weinenBonus.keys) {
      // In der vollen Implementierung: direkte Karma-Aktualisierung
    }
  }

  void _weiterZuPhase4() {
    context.go(AppRouten.phase4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhasenHintergrund(
            phase: GamePhase.kindheit,
            abdunkelung: 0.7,
            mitPartikeln: false,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: _zeigeErgebnis
                ? _ErgebnisAnzeige(
                    key: const ValueKey('ergebnis'),
                    ersteReaktion: _ersteReaktion!,
                    zweiteReaktion: _zweiteReaktion!,
                    onWeiter: _weiterZuPhase4,
                  )
                : _ErzaehlungsAnzeige(
                    key: const ValueKey('erzaehlung'),
                    aktuellesKapitel: _aktuellesKapitel,
                    erzaehlungFertig: _erzaehlungFertig,
                    ersteReaktion: _ersteReaktion,
                    zweiteReaktion: _zweiteReaktion,
                    onReaktionGewaehlt: _reaktionGewaehlt,
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Erzählungs-Anzeige
// ─────────────────────────────────────────────────────────────────────────────

class _ErzaehlungsAnzeige extends StatelessWidget {
  final int aktuellesKapitel;
  final bool erzaehlungFertig;
  final int? ersteReaktion;
  final int? zweiteReaktion;
  final Future<void> Function(bool istErste, int optionIndex) onReaktionGewaehlt;

  const _ErzaehlungsAnzeige({
    super.key,
    required this.aktuellesKapitel,
    required this.erzaehlungFertig,
    required this.ersteReaktion,
    required this.zweiteReaktion,
    required this.onReaktionGewaehlt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1B2A),
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Phasen-Label
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppFarben.emotionTrauer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppFarben.emotionTrauer.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'PHASE III – PRÜFUNG',
                      style: AppTextStyles.beschriftungGross.copyWith(
                        color: AppFarben.emotionTrauer.withValues(alpha: 0.9),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Haupt-Erzählungsbereich
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Symbol
                      if (aktuellesKapitel >= 0 && _kapitel[aktuellesKapitel].icon != null)
                        Icon(
                          _kapitel[aktuellesKapitel].icon,
                          color: AppFarben.textSekundaer.withValues(alpha: 0.5),
                          size: 48,
                        ).animate().fadeIn(duration: 800.ms),

                      const SizedBox(height: 32),

                      // Kapitel-Texte (alle bisher sichtbaren)
                      for (int i = 0; i <= aktuellesKapitel && i < _kapitel.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            _kapitel[i].text,
                            style: AppTextStyles.ueberschrift3.copyWith(
                              color: i == aktuellesKapitel
                                  ? AppFarben.text.withValues(alpha: 0.95)
                                  : AppFarben.textSekundaer.withValues(alpha: 0.5),
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                              fontSize: i == aktuellesKapitel ? 22 : 18,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 1200.ms),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Reaktions-Optionen (erscheinen nach der Erzählung)
            if (erzaehlungFertig) ...[
              _ReaktionsBereich(
                ersteReaktion: ersteReaktion,
                zweiteReaktion: zweiteReaktion,
                onReaktionGewaehlt: onReaktionGewaehlt,
              ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reaktions-Bereich
// ─────────────────────────────────────────────────────────────────────────────

class _ReaktionsBereich extends StatelessWidget {
  final int? ersteReaktion;
  final int? zweiteReaktion;
  final Future<void> Function(bool istErste, int optionIndex) onReaktionGewaehlt;

  const _ReaktionsBereich({
    required this.ersteReaktion,
    required this.zweiteReaktion,
    required this.onReaktionGewaehlt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppFarben.tiefesBlau.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: AppFarben.emotionTrauer.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Erste Reaktion: Weinen oder Nicht-Weinen
          if (ersteReaktion == null) ...[
            Text(
              'Wie reagierst du?',
              style: AppTextStyles.koerperKleinFett.copyWith(
                color: AppFarben.textSekundaer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ReaktionsButton(
                    label: 'Weinen',
                    icon: Icons.water_drop,
                    farbe: const Color(0xFF42A5F5),
                    karma: '+ Mitgefühl',
                    onTippen: () => onReaktionGewaehlt(true, 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReaktionsButton(
                    label: 'Nicht weinen',
                    icon: Icons.shield,
                    farbe: const Color(0xFF78909C),
                    karma: '+ Stärke',
                    onTippen: () => onReaktionGewaehlt(true, 1),
                  ),
                ),
              ],
            ),
          ] else if (zweiteReaktion == null) ...[
            // Erste Reaktion bestätigen
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  ersteReaktion == 0 ? Icons.water_drop : Icons.shield,
                  color: AppFarben.karmaPositiv,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  ersteReaktion == 0 ? 'Du weinst.' : 'Du schluckst die Tränen hinunter.',
                  style: AppTextStyles.koerperKlein.copyWith(
                    color: AppFarben.karmaPositiv,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Zweite Reaktion: Fragen oder Schweigen
            Text(
              'Was tust du danach?',
              style: AppTextStyles.koerperKleinFett.copyWith(
                color: AppFarben.textSekundaer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ReaktionsButton(
                    label: 'Fragen stellen',
                    icon: Icons.help_outline,
                    farbe: const Color(0xFFFFCA28),
                    karma: '+ Weisheit',
                    onTippen: () => onReaktionGewaehlt(false, 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReaktionsButton(
                    label: 'Schweigen',
                    icon: Icons.volume_off,
                    farbe: const Color(0xFF9575CD),
                    karma: '+ innere Stärke',
                    onTippen: () => onReaktionGewaehlt(false, 1),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Beide Reaktionen gewählt – Warte-Anzeige
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppFarben.goldGlanz),
                strokeWidth: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Einzelner Reaktions-Button
class _ReaktionsButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color farbe;
  final String karma;
  final VoidCallback onTippen;

  const _ReaktionsButton({
    required this.label,
    required this.icon,
    required this.farbe,
    required this.karma,
    required this.onTippen,
  });

  @override
  State<_ReaktionsButton> createState() => _ReaktionsButtonState();
}

class _ReaktionsButtonState extends State<_ReaktionsButton> {
  bool _gedrueckt = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _gedrueckt = true),
      onTapUp: (_) {
        setState(() => _gedrueckt = false);
        widget.onTippen();
      },
      onTapCancel: () => setState(() => _gedrueckt = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: _gedrueckt
              ? widget.farbe.withValues(alpha: 0.3)
              : widget.farbe.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.farbe.withValues(alpha: 0.6),
            width: _gedrueckt ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: widget.farbe, size: 24),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: AppTextStyles.entscheidung.copyWith(
                color: widget.farbe,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.karma,
              style: AppTextStyles.beschriftung.copyWith(
                color: widget.farbe.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ergebnis-Anzeige
// ─────────────────────────────────────────────────────────────────────────────

class _ErgebnisAnzeige extends StatelessWidget {
  final int ersteReaktion;
  final int zweiteReaktion;
  final VoidCallback onWeiter;

  const _ErgebnisAnzeige({
    super.key,
    required this.ersteReaktion,
    required this.zweiteReaktion,
    required this.onWeiter,
  });

  String get _reflexionsText {
    if (ersteReaktion == 0 && zweiteReaktion == 0) {
      return 'Du hast geweint und gefragt. Manchmal muss man beides tun.\nDein Herz ist groß und dein Geist ist neugierig.';
    }
    if (ersteReaktion == 0 && zweiteReaktion == 1) {
      return 'Du hast geweint, aber dann Stille gewählt.\nTrauer braucht keinen Lärm. Sie ist still und tief.';
    }
    if (ersteReaktion == 1 && zweiteReaktion == 0) {
      return 'Du hast die Tränen zurückgehalten und Fragen gestellt.\nDu suchst Verstehen dort wo andere nur fühlen.';
    }
    return 'Du hast dich zurückgezogen und schweigend verarbeitet.\nManche Dinge sind zu groß für Worte.';
  }

  String get _attributText {
    final weinen = ersteReaktion == 0 ? 'Mitgefühl +6' : 'Stärke +3';
    final fragen = zweiteReaktion == 0 ? 'Weisheit +5' : 'innere Ruhe +3';
    return '$weinen  •  $fragen';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Symbol für emotionale Reifung
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppFarben.emotionTrauer.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        AppFarben.emotionTrauer.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    color: AppFarben.emotionTrauer.withValues(alpha: 0.8),
                    size: 40,
                  ),
                )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.elasticOut),

                const SizedBox(height: 32),

                Text(
                  'Der erste Verlust',
                  style: AppTextStyles.ueberschrift3.copyWith(
                    color: AppFarben.textSekundaer,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                Text(
                  _reflexionsText,
                  style: AppTextStyles.koerperKursiv.copyWith(
                    color: AppFarben.text.withValues(alpha: 0.9),
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 24),

                // Attribut-Gewinn
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppFarben.oberflaecheErhoben,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppFarben.goldGlanz.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _attributText,
                    style: AppTextStyles.beschriftungGross.copyWith(
                      color: AppFarben.goldGlanz.withValues(alpha: 0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 48),

                GenesisButton(
                  text: 'Das Leben geht weiter',
                  onPressed: onWeiter,
                  icon: Icons.arrow_forward,
                ).animate().fadeIn(delay: 1400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
