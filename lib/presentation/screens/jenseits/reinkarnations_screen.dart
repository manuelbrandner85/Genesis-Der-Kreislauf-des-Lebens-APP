// reinkarnations_screen.dart
// Wiedergeburts-Screen für GENESIS: Der Kreislauf des Lebens.
// Bietet dem Spieler zwei Wege für die nächste Inkarnation:
// Weg A: Als genetisches Kind des letzten Lebens weiterleben
// Weg B: Als neue Seele im nächsten Zeitalter beginnen

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/genetischer_code_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/karma_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/genesis_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ReinkarnationsScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Screen für die Auswahl der Wiedergeburt nach dem Tod.
///
/// Zeigt zwei Inkarnations-Wege:
/// - **Weg A – Als Kind weiterleben:** Genetisches Kind des letzten Lebens.
///   Zeigt berechnete Kind-Attribute und vererbte Erinnerungen.
/// - **Weg B – Neue Seele:** Neue Seele im nächsten chronologischen Zeitalter.
///   Zeigt mitgenommene Gedanken und Karma-Übertrag.
///
/// Navigationsziele:
/// - "Neues Leben beginnen" → Phase 1 [AppRouten.phase1]
/// - "Erst in der Bibliothek nachsehen" → BibliothekScreen
class ReinkarnationsScreen extends ConsumerStatefulWidget {
  const ReinkarnationsScreen({super.key});

  @override
  ConsumerState<ReinkarnationsScreen> createState() =>
      _ReinkarnationsScreenState();
}

class _ReinkarnationsScreenState extends ConsumerState<ReinkarnationsScreen>
    with TickerProviderStateMixin {
  // Gewählter Weg (null = noch keine Auswahl)
  _ReinkarnationsWeg? _gewaehlterWeg;

  // Einblend-Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Kosmische Partikel-Animation im Hintergrund
  late AnimationController _kosmosController;

  // Genetisch berechneter Kind-Code (wird einmal beim Init berechnet)
  late GenetischerCodeModel _kindCode;

  // Nächstes Zeitalter (wird beim Init berechnet)
  late Zeitalter _naechstesZeitalter;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _kosmosController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Kind-Code aus aktuellem Karma-Profil simulieren
    _kindCode = _berechneKindCode();

    // Nächstes Zeitalter (zyklisch durch alle Zeitalter)
    _naechstesZeitalter = _berechneNaechstesZeitalter();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _kosmosController.dispose();
    super.dispose();
  }

  // ── Hilfsfunktionen ───────────────────────────────────────────────────────

  /// Berechnet einen simulierten Kind-Code aus dem elterlichen Karma-Profil.
  /// In der vollständigen Implementierung wird der echte GenetischerCodeModel
  /// aus dem SpielProvider gelesen und mit dem Partner-Code gemischt.
  GenetischerCodeModel _berechneKindCode() {
    // Elterlicher Code als Basis
    final elterlicher = GenetischerCodeModel.generieren();

    // 50% elterliche Attribute + zufällige Modifikation (simuliert)
    final rng = math.Random();
    final kindAttribute = <String, double>{};
    for (final schluessel in kBasisAttributSchluessel) {
      final elternWert = elterlicher.basisAttribute[schluessel] ?? 50.0;
      // Kind erbt 50% des Eltern-Wertes plus eigene zufällige Komponente
      kindAttribute[schluessel] =
          (elternWert * 0.5 + rng.nextDouble() * 50.0).clamp(0.0, 100.0);
    }

    return elterlicher.copyWith(basisAttribute: kindAttribute);
  }

  /// Bestimmt das nächste Zeitalter (rotiert durch die Zeitalter-Liste).
  Zeitalter _berechneNaechstesZeitalter() {
    // Simuliert: Nächstes Zeitalter nach dem aktuellen
    // In der Vollimplementierung: aus SpielProvider lesen
    final alle = Zeitalter.values;
    // Deterministisch aus der Zeit bestimmen (Demo)
    final index = DateTime.now().second % alle.length;
    return alle[index];
  }

  /// Lokalisierter Name des Zeitalters.
  String _zeitalterName(Zeitalter z) {
    switch (z) {
      case Zeitalter.mittelalter:      return 'Das Mittelalter';
      case Zeitalter.renaissance:      return 'Die Renaissance';
      case Zeitalter.industriezeitalter: return 'Das Industriezeitalter';
      case Zeitalter.moderne:          return 'Die Moderne';
      case Zeitalter.zukunft:          return 'Die Zukunft';
    }
  }

  /// Lokalisierter Attributname.
  String _attributName(String schluessel) {
    switch (schluessel) {
      case 'kraft':        return 'Körperkraft';
      case 'intelligenz':  return 'Intelligenz';
      case 'empathie':     return 'Empathie';
      case 'kreativitaet': return 'Kreativität';
      case 'ausdauer':     return 'Ausdauer';
      case 'intuition':    return 'Intuition';
      default:             return schluessel;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  /// Startet das neue Leben und navigiert zu Phase 1.
  void _neuesLebenBeginnen() {
    if (_gewaehlterWeg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wähle zuerst einen Weg der Wiedergeburt.'),
          backgroundColor: Color(0xFF1F2937),
        ),
      );
      return;
    }
    // Navigation zu Phase 1 – SpielProvider wird im Hintergrund initialisiert
    context.go(AppRouten.phase1);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final karma = ref.watch(karmaProvider);

    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: Stack(
        children: [
          // Kosmischer Hintergrund
          _KosmischerHintergrund(controller: _kosmosController),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // ── Kopfzeile ─────────────────────────────────────────────
                  _Kopfzeile(),

                  // ── Scrollbarer Inhalt ────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Weg A: Als Kind weiterleben
                          _WegKarte(
                            weg: _ReinkarnationsWeg.kind,
                            istGewaehlt:
                                _gewaehlterWeg == _ReinkarnationsWeg.kind,
                            onGewaehlt: () => setState(
                                () => _gewaehlterWeg = _ReinkarnationsWeg.kind),
                            inhalt: _KindWegInhalt(kindCode: _kindCode),
                            delay: const Duration(milliseconds: 100),
                          ),

                          const SizedBox(height: 16),

                          // Weg B: Neue Seele
                          _WegKarte(
                            weg: _ReinkarnationsWeg.neueSeele,
                            istGewaehlt: _gewaehlterWeg ==
                                _ReinkarnationsWeg.neueSeele,
                            onGewaehlt: () => setState(() =>
                                _gewaehlterWeg = _ReinkarnationsWeg.neueSeele),
                            inhalt: _NeueSeeleWegInhalt(
                              zeitalter: _naechstesZeitalter,
                              zeitalterName:
                                  _zeitalterName(_naechstesZeitalter),
                              karma: karma,
                            ),
                            delay: const Duration(milliseconds: 250),
                          ),

                          const SizedBox(height: 32),

                          // Karma-Übertrag-Hinweis
                          _KarmaUebertragAnzeige(karma: karma),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),

                  // ── Aktions-Buttons ───────────────────────────────────────
                  _AktionsBereich(
                    kannBeginnen: _gewaehlterWeg != null,
                    onBeginnen: _neuesLebenBeginnen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum: ReinkarnationsWeg
// ─────────────────────────────────────────────────────────────────────────────

enum _ReinkarnationsWeg { kind, neueSeele }

// ─────────────────────────────────────────────────────────────────────────────
// Kosmischer Hintergrund
// ─────────────────────────────────────────────────────────────────────────────

class _KosmischerHintergrund extends StatelessWidget {
  final AnimationController controller;

  const _KosmischerHintergrund({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _KosmosPainter(fortschritt: controller.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _KosmosPainter extends CustomPainter {
  final double fortschritt;

  static final math.Random _rng = math.Random(7);
  static final List<_SternDaten> _sterne = List.generate(
    40,
    (_) => _SternDaten(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      groesse: 0.5 + _rng.nextDouble() * 2.0,
      phase: _rng.nextDouble() * math.pi * 2,
    ),
  );

  const _KosmosPainter({required this.fortschritt});

  @override
  void paint(Canvas canvas, Size size) {
    // Kosmischer Gradient
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.2,
      colors: [
        const Color(0xFF1A0F3C),
        AppFarben.kosmischSchwarz,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        ),
    );

    // Sterne
    final paint = Paint()..style = PaintingStyle.fill;
    for (final stern in _sterne) {
      final helligkeit = 0.2 +
          0.6 *
              (0.5 +
                  0.5 *
                      math.sin(
                          fortschritt * math.pi * 2 * 0.3 + stern.phase));
      paint.color = Colors.white.withValues(alpha: helligkeit);
      canvas.drawCircle(
        Offset(stern.x * size.width, stern.y * size.height),
        stern.groesse,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_KosmosPainter alt) => alt.fortschritt != fortschritt;
}

class _SternDaten {
  final double x, y, groesse, phase;
  const _SternDaten({
    required this.x,
    required this.y,
    required this.groesse,
    required this.phase,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Kopfzeile
// ─────────────────────────────────────────────────────────────────────────────

class _Kopfzeile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppFarben.textSekundaer),
                onPressed: () => context.pop(),
              ),
              const Spacer(),
              Text(
                'WIEDERGEBURT',
                style: AppTextStyles.ueberschrift3.copyWith(
                  color: AppFarben.goldGlanz,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48), // Balance für Back-Button
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Wähle deinen Weg zurück ins Leben',
            style: AppTextStyles.koerperKursiv.copyWith(
              color: AppFarben.textTertiaer,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppFarben.mystischLila.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weg-Karte (auswählbarer Container)
// ─────────────────────────────────────────────────────────────────────────────

class _WegKarte extends StatelessWidget {
  final _ReinkarnationsWeg weg;
  final bool istGewaehlt;
  final VoidCallback onGewaehlt;
  final Widget inhalt;
  final Duration delay;

  const _WegKarte({
    required this.weg,
    required this.istGewaehlt,
    required this.onGewaehlt,
    required this.inhalt,
    required this.delay,
  });

  String get _titel {
    switch (weg) {
      case _ReinkarnationsWeg.kind:
        return 'WEG A – ALS KIND WEITERLEBEN';
      case _ReinkarnationsWeg.neueSeele:
        return 'WEG B – NEUE SEELE IM NÄCHSTEN ZEITALTER';
    }
  }

  IconData get _icon {
    switch (weg) {
      case _ReinkarnationsWeg.kind:      return Icons.family_restroom;
      case _ReinkarnationsWeg.neueSeele: return Icons.auto_awesome;
    }
  }

  Color get _akzentFarbe {
    return istGewaehlt ? AppFarben.goldGlanz : AppFarben.textSekundaer;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onGewaehlt,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: istGewaehlt
              ? AppFarben.mystischLila.withValues(alpha: 0.25)
              : AppFarben.oberflaecheErhoben,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: istGewaehlt
                ? AppFarben.goldGlanz.withValues(alpha: 0.6)
                : AppFarben.nebelGrau.withValues(alpha: 0.3),
            width: istGewaehlt ? 1.5 : 1.0,
          ),
          boxShadow: istGewaehlt
              ? [
                  BoxShadow(
                    color: AppFarben.goldGlanz.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header-Zeile
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: istGewaehlt
                        ? AppFarben.goldGlanz.withValues(alpha: 0.2)
                        : AppFarben.nebelGrau.withValues(alpha: 0.2),
                    border: Border.all(color: _akzentFarbe.withValues(alpha: 0.5)),
                  ),
                  child: Icon(_icon, color: _akzentFarbe, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _titel,
                    style: AppTextStyles.beschriftungGross.copyWith(
                      color: _akzentFarbe,
                    ),
                  ),
                ),
                if (istGewaehlt)
                  const Icon(Icons.check_circle,
                      color: AppFarben.goldGlanz, size: 22),
              ],
            ),
            const SizedBox(height: 14),
            // Weg-spezifischer Inhalt
            inhalt,
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.08, end: 0, duration: 450.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weg A: Kind-Inhalt
// ─────────────────────────────────────────────────────────────────────────────

class _KindWegInhalt extends StatelessWidget {
  final GenetischerCodeModel kindCode;

  const _KindWegInhalt({required this.kindCode});

  String _attributName(String schluessel) {
    switch (schluessel) {
      case 'kraft':        return 'Kraft';
      case 'intelligenz':  return 'Intelligenz';
      case 'empathie':     return 'Empathie';
      case 'kreativitaet': return 'Kreativität';
      case 'ausdauer':     return 'Ausdauer';
      case 'intuition':    return 'Intuition';
      default:             return schluessel;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nur die ersten 3 Attribute für die kompakte Vorschau
    final attributeVorschau = kindCode.basisAttribute.entries
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genetisches Kind erbt 50% deiner Eigenschaften',
          style: AppTextStyles.koerperKlein.copyWith(
            color: AppFarben.textSekundaer,
          ),
        ),
        const SizedBox(height: 12),

        // Kind-Attribute
        Text(
          'KIND-ATTRIBUTE (VORSCHAU)',
          style: AppTextStyles.beschriftungGross.copyWith(
            color: AppFarben.textTertiaer,
          ),
        ),
        const SizedBox(height: 8),
        ...attributeVorschau.map((attr) {
          final wert = attr.value;
          final farbe = wert >= 60
              ? AppFarben.karmaPositiv
              : wert >= 35
                  ? AppFarben.karmaNeutral
                  : AppFarben.karmaNegatv;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    _attributName(attr.key),
                    style: AppTextStyles.beschriftung,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: wert / 100.0,
                      backgroundColor:
                          AppFarben.nebelGrau.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(farbe),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 32,
                  child: Text(
                    wert.toStringAsFixed(0),
                    style: AppTextStyles.beschriftung.copyWith(color: farbe),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),

        // Aktivierte Gene (Erinnerungen die das Kind trägt)
        if (kindCode.aktivierteGene.isNotEmpty) ...[
          Text(
            'VERERBTE ERINNERUNGEN',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.textTertiaer,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: kindCode.aktivierteGene.take(3).map((gen) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppFarben.mystischLila.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppFarben.mystischLila.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  gen.replaceAll('gen_', '').replaceAll('_', ' '),
                  style: AppTextStyles.mikro.copyWith(
                    color: AppFarben.mystischLila.withValues(alpha: 0.9),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weg B: Neue Seele Inhalt
// ─────────────────────────────────────────────────────────────────────────────

class _NeueSeeleWegInhalt extends StatelessWidget {
  final Zeitalter zeitalter;
  final String zeitalterName;
  final KarmaProfilModel karma;

  const _NeueSeeleWegInhalt({
    required this.zeitalter,
    required this.zeitalterName,
    required this.karma,
  });

  // Beschreibung des nächsten Zeitalters
  String _zeitalterBeschreibung() {
    switch (zeitalter) {
      case Zeitalter.mittelalter:
        return 'Ritterehre, Glaubenskämpfe und feudale Pflicht erwarten dich.';
      case Zeitalter.renaissance:
        return 'Kunst, Wissenschaft und der aufkeimende Humanismus prägen dein Leben.';
      case Zeitalter.industriezeitalter:
        return 'Dampf und Fortschritt in einer Welt voller sozialer Umwälzungen.';
      case Zeitalter.moderne:
        return 'Globalisierung, Technologie und individuelle Freiheit formen dich.';
      case Zeitalter.zukunft:
        return 'Post-humane Gesellschaft, KI und das Streben nach den Sternen.';
    }
  }

  // Mitgenommene Gedanken aus dem Karma-Gericht (simuliert)
  List<String> _mitgenommeneGedanken() {
    final avg = karma.durchschnitt;
    if (avg >= 60) {
      return ['Tiefer Frieden', 'Kosmische Verbundenheit', 'Ewige Weisheit'];
    } else if (avg >= 20) {
      return ['Streben nach Güte', 'Vertrauen ins Leben'];
    } else if (avg <= -60) {
      return ['Schwere Schuld', 'Tiefer Schmerz', 'Unerlöste Wunden'];
    } else if (avg <= -20) {
      return ['Reue', 'Unerfüllte Wünsche'];
    }
    return ['Unentschlossenheit', 'Offene Fragen'];
  }

  @override
  Widget build(BuildContext context) {
    final gedanken = _mitgenommeneGedanken();
    final karmaUebertrag = karma.durchschnitt * 0.2; // 20% Karma-Übertrag

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nächstes Zeitalter
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppFarben.tiefesBlau.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, color: AppFarben.goldGlanz, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NÄCHSTES ZEITALTER',
                      style: AppTextStyles.mikro.copyWith(
                        color: AppFarben.textTertiaer,
                      ),
                    ),
                    Text(
                      zeitalterName,
                      style: AppTextStyles.koerperKleinFett.copyWith(
                        color: AppFarben.goldGlanz,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _zeitalterBeschreibung(),
                      style: AppTextStyles.mikro.copyWith(
                        color: AppFarben.textSekundaer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Mitgenommene Gedanken
        Text(
          'MITGENOMMENE GEDANKEN',
          style: AppTextStyles.beschriftungGross.copyWith(
            color: AppFarben.textTertiaer,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: gedanken.map((gedanke) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppFarben.kosmischViolett.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppFarben.mystischLila.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                gedanke,
                style: AppTextStyles.mikro.copyWith(
                  color: AppFarben.textSekundaer,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Karma-Übertrag
        Row(
          children: [
            const Icon(Icons.balance, color: AppFarben.textTertiaer, size: 16),
            const SizedBox(width: 6),
            Text(
              'Karma-Übertrag: ',
              style: AppTextStyles.beschriftung,
            ),
            Text(
              '${karmaUebertrag >= 0 ? '+' : ''}${karmaUebertrag.toStringAsFixed(1)}',
              style: AppTextStyles.koerperKleinFett.copyWith(
                color: AppFarben.fuerKarmaWert(karmaUebertrag),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(20% des letzten Lebens)',
              style: AppTextStyles.mikro,
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Karma-Übertrag-Anzeige
// ─────────────────────────────────────────────────────────────────────────────

class _KarmaUebertragAnzeige extends StatelessWidget {
  final KarmaProfilModel karma;

  const _KarmaUebertragAnzeige({required this.karma});

  @override
  Widget build(BuildContext context) {
    final avg = karma.durchschnitt;
    final reich = karma.jenseitsReich;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppFarben.mystischLila.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              color: AppFarben.textTertiaer, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Karma dieses Lebens: ${avg >= 0 ? '+' : ''}${avg.toStringAsFixed(1)}',
                  style: AppTextStyles.koerperKlein.copyWith(
                    color: AppFarben.fuerKarmaWert(avg),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Zugewiesenes Reich: ${reich.name.toUpperCase()}',
                  style: AppTextStyles.koerperKlein.copyWith(
                    color: AppFarben.textSekundaer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Aktions-Bereich (Buttons)
// ─────────────────────────────────────────────────────────────────────────────

class _AktionsBereich extends StatelessWidget {
  final bool kannBeginnen;
  final VoidCallback onBeginnen;

  const _AktionsBereich({
    required this.kannBeginnen,
    required this.onBeginnen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: AppFarben.kosmischSchwarz.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: AppFarben.mystischLila.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          GenesisButton(
            text: 'NEUES LEBEN BEGINNEN',
            icon: Icons.play_arrow,
            onPressed: kannBeginnen ? onBeginnen : null,
            typ: GenesisButtonTyp.primaer,
          ),
          const SizedBox(height: 10),
          GenesisButton(
            text: 'ERST IN DER BIBLIOTHEK NACHSEHEN',
            icon: Icons.local_library,
            onPressed: () => context.go(AppRouten.bibliothek),
            typ: GenesisButtonTyp.sekundaer,
          ),
        ],
      ),
    );
  }
}
