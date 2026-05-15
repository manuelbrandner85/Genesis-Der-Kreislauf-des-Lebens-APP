// Karma-Gericht Screen für GENESIS: Der Kreislauf des Lebens
// Vollautomatisches Karma-Gericht – keine Spielerwahl.
// Das System wählt 1-3 Erinnerungen basierend auf Intensität und Unerledigtem.
// Abgeschlossenes wird zur Stärke, Offenes zur Narbe.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/erinnerung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Karma-Gericht Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Das automatische Karma-Gericht nach dem Tod.
///
/// KEIN Menü, KEINE Spielerwahl. Das System entscheidet.
/// Wird als narrativer Moment dargestellt – eine Szene, keine UI.
class KarmaGerichtScreen extends ConsumerStatefulWidget {
  const KarmaGerichtScreen({super.key});

  @override
  ConsumerState<KarmaGerichtScreen> createState() => _KarmaGerichtScreenState();
}

class _KarmaGerichtScreenState extends ConsumerState<KarmaGerichtScreen>
    with TickerProviderStateMixin {
  int _phase = 0;
  // 0: Ankunft, 1: Sortierung läuft, 2: Ergebnisse, 3: Übergang ins Jenseits

  // Simulierte Erinnerungen für die Demo
  // In der Produktion: aus dem ZyklusModel laden
  final List<_GerichtErinnerung> _ausgewaehlteErinnerungen = [];

  late final AnimationController _lichterController;

  @override
  void initState() {
    super.initState();
    _lichterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _sequenzAbspielen();
  }

  @override
  void dispose() {
    _lichterController.dispose();
    super.dispose();
  }

  void _sequenzAbspielen() async {
    // Phase 0: Ankunft (4 Sekunden)
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    // Erinnerungen auswählen (wird automatisch berechnet)
    setState(() {
      _ausgewaehlteErinnerungen.addAll([
        _GerichtErinnerung(
          titel: 'Der Moment der Entscheidung',
          istAbgeschlossen: true,
          wirdZuStaerke: true,
          beschreibung: 'Du hast damals entschieden und damit Frieden gefunden.',
        ),
        _GerichtErinnerung(
          titel: 'Das unausgesprochene Wort',
          istAbgeschlossen: false,
          wirdZuStaerke: false,
          beschreibung: 'Es hat dich nie losgelassen. Dieses Wort. Du nimmst es mit.',
        ),
      ]);
      _phase = 1;
    });

    // Phase 1: Sortierung (6 Sekunden)
    await Future.delayed(const Duration(seconds: 6));
    if (!mounted) return;
    setState(() => _phase = 2);

    // Phase 2: Ergebnisse zeigen (8 Sekunden)
    await Future.delayed(const Duration(seconds: 8));
    if (!mounted) return;
    setState(() => _phase = 3);

    // Phase 3: Übergang ins Jenseits (3 Sekunden)
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    context.go('/phase/7/reich'); // Zum Jenseitsreich
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 2000),
        child: switch (_phase) {
          0 => _AnkunftScene(lichterController: _lichterController),
          1 => _SortierungsScene(lichterController: _lichterController),
          2 => _ErgebnisScene(erinnerungen: _ausgewaehlteErinnerungen),
          _ => _UebergangScene(),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gericht-Erinnerungs-Modell (lokal für diesen Screen)
// ─────────────────────────────────────────────────────────────────────────────

class _GerichtErinnerung {
  final String titel;
  final bool istAbgeschlossen;
  final bool wirdZuStaerke;
  final String beschreibung;

  const _GerichtErinnerung({
    required this.titel,
    required this.istAbgeschlossen,
    required this.wirdZuStaerke,
    required this.beschreibung,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Szene 1: Ankunft
// ─────────────────────────────────────────────────────────────────────────────

class _AnkunftScene extends StatelessWidget {
  final AnimationController lichterController;

  const _AnkunftScene({required this.lichterController});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('ankunft'),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF1A0A2E), Colors.black],
          radius: 1.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: lichterController,
              builder: (context, _) {
                return Icon(
                  Icons.brightness_7,
                  size: 80 + lichterController.value * 20,
                  color: AppFarben.goldGlanz
                      .withValues(alpha: 0.5 + lichterController.value * 0.5),
                );
              },
            ),
            const SizedBox(height: 48),
            Text(
              'Das Gericht der Seele',
              style: AppTextStyles.ueberschrift2.copyWith(
                color: AppFarben.goldGlanz,
                letterSpacing: 3,
              ),
            ).animate().fadeIn(delay: 1.seconds),
            const SizedBox(height: 16),
            Text(
              'Was du warst, wird gewogen.\nNicht von anderen. Von dir.',
              style: AppTextStyles.koerpergross.copyWith(
                color: AppFarben.textSekundaer,
                height: 1.8,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 2.seconds),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Szene 2: Sortierung
// ─────────────────────────────────────────────────────────────────────────────

class _SortierungsScene extends StatelessWidget {
  final AnimationController lichterController;

  const _SortierungsScene({required this.lichterController});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('sortierung'),
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: lichterController,
              builder: (context, _) {
                return Container(
                  width: 200 + lichterController.value * 50,
                  height: 200 + lichterController.value * 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppFarben.mystischLila.withValues(
                          alpha: 0.3 + lichterController.value * 0.5,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            Text(
              'Dein Leben wird sortiert...',
              style: AppTextStyles.ueberschrift3.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 16),
            Text(
              'Abgeschlossenes wird zur Stärke.\nOffenes wird zur Narbe.\nBeides trägst du mit.',
              style: AppTextStyles.koerpergross.copyWith(
                color: AppFarben.textSekundaer,
                height: 2,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 1.seconds),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Szene 3: Ergebnisse
// ─────────────────────────────────────────────────────────────────────────────

class _ErgebnisScene extends StatelessWidget {
  final List<_GerichtErinnerung> erinnerungen;

  const _ErgebnisScene({required this.erinnerungen});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('ergebnis'),
      color: const Color(0xFF0A0A1F),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Du nimmst mit:',
                style: AppTextStyles.ueberschrift3.copyWith(
                  color: AppFarben.goldGlanz,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 48),

              // Ausgewählte Erinnerungen anzeigen
              ...erinnerungen.asMap().entries.map(
                    (e) => _ErinnerungsKarte(
                  erinnerung: e.value,
                  verzoegerung: e.key * 800,
                ),
              ),

              const SizedBox(height: 48),
              Text(
                'Weil es dich nicht losgelassen hat.',
                style: AppTextStyles.koerpergross.copyWith(
                  color: AppFarben.textSekundaer,
                  fontStyle: FontStyle.italic,
                ),
              ).animate().fadeIn(delay: (erinnerungen.length * 800 + 500).ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErinnerungsKarte extends StatelessWidget {
  final _GerichtErinnerung erinnerung;
  final int verzoegerung;

  const _ErinnerungsKarte({
    required this.erinnerung,
    required this.verzoegerung,
  });

  @override
  Widget build(BuildContext context) {
    final farbe = erinnerung.wirdZuStaerke ? AppFarben.goldGlanz : AppFarben.mystischLila;
    final symbol = erinnerung.wirdZuStaerke ? '✦' : '◈';
    final label = erinnerung.wirdZuStaerke ? 'wird zur Stärke' : 'wird zur Narbe';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: farbe.withValues(alpha: 0.5), width: 1),
        borderRadius: BorderRadius.circular(8),
        color: farbe.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Text(symbol, style: TextStyle(color: farbe, fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  erinnerung.titel,
                  style: AppTextStyles.spielStatus.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  erinnerung.beschreibung,
                  style: AppTextStyles.koerperklein.copyWith(
                    color: AppFarben.textSekundaer,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.beschriftung.copyWith(
                    color: farbe,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: verzoegerung.ms).slideX(begin: -0.2, delay: verzoegerung.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Szene 4: Übergang
// ─────────────────────────────────────────────────────────────────────────────

class _UebergangScene extends StatelessWidget {
  const _UebergangScene();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('uebergang'),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.white, Color(0xFFE8D5A3), Colors.black],
          stops: [0.0, 0.3, 1.0],
          radius: 1.0,
        ),
      ),
      child: Center(
        child: Text(
          'Das nächste Reich erwartet dich.',
          style: AppTextStyles.ueberschrift3.copyWith(
            color: Colors.black87,
            fontStyle: FontStyle.italic,
          ),
        ).animate().fadeIn(duration: 1.seconds),
      ),
    );
  }
}
