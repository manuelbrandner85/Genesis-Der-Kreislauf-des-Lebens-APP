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
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/karma_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Anzeige-Namen für Karma-Dimensionen und Jenseitsreiche
// ─────────────────────────────────────────────────────────────────────────────

String _dimensionsName(KarmaDimension dim) {
  switch (dim) {
    case KarmaDimension.mitgefuehl:
      return 'Mitgefühl';
    case KarmaDimension.ehrlichkeit:
      return 'Ehrlichkeit';
    case KarmaDimension.mut:
      return 'Mut';
    case KarmaDimension.grosszuegigkeit:
      return 'Großzügigkeit';
    case KarmaDimension.weisheit:
      return 'Weisheit';
    case KarmaDimension.liebe:
      return 'Liebe';
  }
}

String _reichName(JenseitsReich reich) {
  switch (reich) {
    case JenseitsReich.elysium:
      return 'Elysium';
    case JenseitsReich.harmonia:
      return 'Harmonia';
    case JenseitsReich.limbus:
      return 'Limbus';
    case JenseitsReich.shadowlands:
      return 'Shadowlands';
    case JenseitsReich.abyssus:
      return 'Abyssus';
  }
}

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

  // Echte Lebens-Bilanz (aus karmaProvider / spielProvider berechnet)
  final List<_GerichtErinnerung> _ausgewaehlteErinnerungen = [];

  // Karma-Werte, Durchschnitt und zugewiesenes Reich für die Ergebnis-Szene
  KarmaProfilModel _karma = KarmaProfilModel.neutral();
  JenseitsReich _reich = JenseitsReich.limbus;

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

    // Echte Lebens-Bilanz aus den Providern berechnen
    setState(() {
      _bilanzBerechnen();
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

  /// Berechnet die echte Lebens-Bilanz aus karmaProvider und spielProvider.
  ///
  /// Muss innerhalb von setState aufgerufen werden (mutiert Felder).
  void _bilanzBerechnen() {
    _karma = ref.read(karmaProvider);
    _reich = ref.read(jenseitsReichProvider);
    final dominant = ref.read(dominanteKarmaDimensionProvider);

    final spiel = ref.read(spielProvider);
    final anzahlEntscheidungen =
        spiel.aktuellerZyklus?.getroffeneEntscheidungen.length ?? 0;
    final erreichtesAlter = spiel.aktuellesAlter;

    // Wert der dominanten Dimension bestimmt das Urteil
    final dominantWert = switch (dominant) {
      KarmaDimension.mitgefuehl => _karma.mitgefuehl,
      KarmaDimension.ehrlichkeit => _karma.ehrlichkeit,
      KarmaDimension.mut => _karma.mut,
      KarmaDimension.grosszuegigkeit => _karma.grosszuegigkeit,
      KarmaDimension.weisheit => _karma.weisheit,
      KarmaDimension.liebe => _karma.liebe,
    };
    final dominantPositiv = dominantWert >= 0;

    _ausgewaehlteErinnerungen
      ..clear()
      ..addAll([
        _GerichtErinnerung(
          titel: '$erreichtesAlter gelebte Jahre',
          istAbgeschlossen: true,
          wirdZuStaerke: true,
          beschreibung: erreichtesAlter > 0
              ? 'Jedes Jahr hat Spuren hinterlassen. Sie gehören jetzt dir.'
              : 'Ein Leben, kaum begonnen. Auch das wird gewogen.',
        ),
        _GerichtErinnerung(
          titel: anzahlEntscheidungen == 1
              ? '1 getroffene Entscheidung'
              : '$anzahlEntscheidungen getroffene Entscheidungen',
          istAbgeschlossen: true,
          wirdZuStaerke: anzahlEntscheidungen > 0,
          beschreibung: anzahlEntscheidungen > 0
              ? 'Jede Wahl hat deinen Weg geformt. Keine davon war umsonst.'
              : 'Du hast dich treiben lassen. Auch Nicht-Wählen ist eine Wahl.',
        ),
        _GerichtErinnerung(
          titel: 'Deine Prägung: ${_dimensionsName(dominant)}',
          istAbgeschlossen: dominantPositiv,
          wirdZuStaerke: dominantPositiv,
          beschreibung: dominantPositiv
              ? '${_dimensionsName(dominant)} hat dein Leben getragen '
                  '(${dominantWert >= 0 ? '+' : ''}${dominantWert.toStringAsFixed(0)}). '
                  'Sie wird zur Stärke.'
              : '${_dimensionsName(dominant)} wurde zu deinem Schatten '
                  '(${dominantWert.toStringAsFixed(0)}). '
                  'Er wird zur Narbe, die du mitnimmst.',
        ),
      ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhasenHintergrund(
            assetPfad: 'assets/images/jenseits/limbus.webp',
            abdunkelung: 0.65,
            mitKenBurns: false,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 2000),
            child: switch (_phase) {
              0 => _AnkunftScene(lichterController: _lichterController),
              1 => _SortierungsScene(lichterController: _lichterController),
              2 => _ErgebnisScene(
                  erinnerungen: _ausgewaehlteErinnerungen,
                  karma: _karma,
                  reich: _reich,
                ),
              _ => _UebergangScene(reichName: _reichName(_reich)),
            },
          ),
        ],
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
              style: AppTextStyles.koerperGross.copyWith(
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
              style: AppTextStyles.koerperGross.copyWith(
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
  final KarmaProfilModel karma;
  final JenseitsReich reich;

  const _ErgebnisScene({
    required this.erinnerungen,
    required this.karma,
    required this.reich,
  });

  @override
  Widget build(BuildContext context) {
    final durchschnitt = karma.durchschnitt;
    final durchschnittFarbe =
        durchschnitt >= 0 ? AppFarben.goldGlanz : AppFarben.mystischLila;

    return Container(
      key: const ValueKey('ergebnis'),
      color: const Color(0xFF0A0A1F),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Du nimmst mit:',
                style: AppTextStyles.ueberschrift3.copyWith(
                  color: AppFarben.goldGlanz,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 32),

              // Echte Lebens-Bilanz anzeigen
              ...erinnerungen.asMap().entries.map(
                    (e) => _ErinnerungsKarte(
                  erinnerung: e.value,
                  verzoegerung: e.key * 800,
                ),
              ),

              const SizedBox(height: 8),

              // Karma-Waage: alle sechs Dimensionen + Durchschnitt + Reich
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppFarben.goldGlanz.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withValues(alpha: 0.03),
                ),
                child: Column(
                  children: [
                    Text(
                      'DIE WAAGE DEINER SEELE',
                      style: AppTextStyles.beschriftung.copyWith(
                        color: AppFarben.textSekundaer,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: KarmaDimension.values.map((dim) {
                        final wert = switch (dim) {
                          KarmaDimension.mitgefuehl => karma.mitgefuehl,
                          KarmaDimension.ehrlichkeit => karma.ehrlichkeit,
                          KarmaDimension.mut => karma.mut,
                          KarmaDimension.grosszuegigkeit =>
                            karma.grosszuegigkeit,
                          KarmaDimension.weisheit => karma.weisheit,
                          KarmaDimension.liebe => karma.liebe,
                        };
                        final farbe = wert >= 0
                            ? AppFarben.goldGlanz
                            : AppFarben.mystischLila;
                        return Text(
                          '${_dimensionsName(dim)} '
                          '${wert >= 0 ? '+' : ''}${wert.toStringAsFixed(0)}',
                          style: AppTextStyles.koerperKlein.copyWith(
                            color: farbe.withValues(alpha: 0.9),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bilanz: '
                      '${durchschnitt >= 0 ? '+' : ''}${durchschnitt.toStringAsFixed(1)}'
                      '  ·  ${_reichName(reich)}',
                      style: AppTextStyles.koerperGross.copyWith(
                        color: durchschnittFarbe,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (erinnerungen.length * 800).ms),

              const SizedBox(height: 32),
              Text(
                'Weil es dich nicht losgelassen hat.',
                style: AppTextStyles.koerperGross.copyWith(
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
                  style: AppTextStyles.koerperKlein.copyWith(
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
  final String reichName;

  const _UebergangScene({required this.reichName});

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
          '$reichName erwartet dich.',
          style: AppTextStyles.ueberschrift3.copyWith(
            color: Colors.black87,
            fontStyle: FontStyle.italic,
          ),
        ).animate().fadeIn(duration: 1.seconds),
      ),
    );
  }
}
