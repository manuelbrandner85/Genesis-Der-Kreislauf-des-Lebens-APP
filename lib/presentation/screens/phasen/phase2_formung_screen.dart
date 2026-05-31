// phase2_formung_screen.dart
// Phase 2: Die Formung – Embryo-Aufbau mit 3 Minigame-Stufen.
// Stufe 1: Organ-Puzzle (drag & drop)
// Stufe 2: Herzschlag-Rhythmus-Spiel
// Stufe 3: Synapsen-Verbinden
// Abschluss: Geburts-Cinematic

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/genesis_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Daten-Modelle für Minigames
// ─────────────────────────────────────────────────────────────────────────────

/// Repräsentiert ein Organ mit ID, Name, Icon und Slot-Position
class _OrganDaten {
  final String id;
  final String name;
  final IconData icon;
  final Color farbe;
  /// Relative Position im Körper-Slot (0.0–1.0)
  final Alignment slotPosition;

  const _OrganDaten({
    required this.id,
    required this.name,
    required this.icon,
    required this.farbe,
    required this.slotPosition,
  });
}

// Alle 6 Organe mit Positionen im Körper-Silhouetten-Slot
const List<_OrganDaten> _organe = [
  _OrganDaten(
    id: 'herz',
    name: 'Herz',
    icon: Icons.favorite,
    farbe: Color(0xFFEF5350),
    slotPosition: Alignment(0.0, -0.3),
  ),
  _OrganDaten(
    id: 'lunge',
    name: 'Lunge',
    icon: Icons.air,
    farbe: Color(0xFF42A5F5),
    slotPosition: Alignment(0.0, -0.1),
  ),
  _OrganDaten(
    id: 'gehirn',
    name: 'Gehirn',
    icon: Icons.psychology,
    farbe: Color(0xFFAB47BC),
    slotPosition: Alignment(0.0, -0.65),
  ),
  _OrganDaten(
    id: 'leber',
    name: 'Leber',
    icon: Icons.water_drop,
    farbe: Color(0xFF8D6E63),
    slotPosition: Alignment(0.2, 0.1),
  ),
  _OrganDaten(
    id: 'magen',
    name: 'Magen',
    icon: Icons.circle,
    farbe: Color(0xFF66BB6A),
    slotPosition: Alignment(0.0, 0.15),
  ),
  _OrganDaten(
    id: 'immunsystem',
    name: 'Immunsystem',
    icon: Icons.security,
    farbe: Color(0xFFFFCA28),
    slotPosition: Alignment(-0.2, 0.0),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Phase 2 Formung Screen – Haupt-Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Haupt-Screen für Phase 2: Die Formung.
///
/// Führt den Spieler durch drei Minigame-Stufen:
/// 1. Organ-Puzzle (Drag & Drop)
/// 2. Herzschlag-Rhythmus
/// 3. Synapsen-Verbinden
/// Danach: Geburts-Cinematic-Übergang zu Phase 3.
class Phase2FormungScreen extends ConsumerStatefulWidget {
  const Phase2FormungScreen({super.key});

  @override
  ConsumerState<Phase2FormungScreen> createState() =>
      _Phase2FormungScreenState();
}

class _Phase2FormungScreenState extends ConsumerState<Phase2FormungScreen> {
  // Aktuelle Stufe (0 = Intro, 1 = Organ-Puzzle, 2 = Herzschlag, 3 = Synapsen, 4 = Fertig)
  int _stufe = 0;

  // Berechnete Attribute aus den Minigames
  double _herzGesundheit = 0.8;
  double _intelligenz = 0.7;

  // Intro-Text läuft ab
  bool _introFertig = false;

  @override
  void initState() {
    super.initState();
    _introAbspielen();
  }

  Future<void> _introAbspielen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _introFertig = true;
      _stufe = 1;
    });
  }

  void _stufe1Abgeschlossen() {
    setState(() => _stufe = 2);
  }

  void _stufe2Abgeschlossen(double herzGesundheit) {
    setState(() {
      _herzGesundheit = herzGesundheit;
      _stufe = 3;
    });
  }

  void _stufe3Abgeschlossen(double intelligenz) {
    setState(() {
      _intelligenz = intelligenz;
      _stufe = 4;
    });
    // Phasenwechsel wird beim Geburts-Cinematic ausgelöst
  }

  void _zumGeburtsCinematic() {
    context.go('/phase/2/geburt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: switch (_stufe) {
            0 => _IntroSequenz(key: const ValueKey(0)),
            1 => _OrganPuzzleMinigame(
                key: const ValueKey(1),
                onAbgeschlossen: _stufe1Abgeschlossen,
              ),
            2 => _HerzschlagMinigame(
                key: const ValueKey(2),
                onAbgeschlossen: _stufe2Abgeschlossen,
              ),
            3 => _SynapsenMinigame(
                key: const ValueKey(3),
                onAbgeschlossen: _stufe3Abgeschlossen,
              ),
            _ => _AlleStufeAbgeschlossen(
                key: const ValueKey(4),
                herzGesundheit: _herzGesundheit,
                intelligenz: _intelligenz,
                onWeiter: _zumGeburtsCinematic,
              ),
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Intro-Sequenz
// ─────────────────────────────────────────────────────────────────────────────

class _IntroSequenz extends StatelessWidget {
  const _IntroSequenz({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Phasen-Symbol: wachsende Zelle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppFarben.phaseKindheit.withValues(alpha: 0.5),
                    AppFarben.kosmischSchwarz,
                  ],
                ),
                border: Border.all(
                  color: AppFarben.phaseKindheit.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.biotech,
                color: Color(0xFF81D4FA),
                size: 50,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.9, end: 1.1, duration: 1500.ms),

            const SizedBox(height: 32),

            Text(
              'PHASE II',
              style: AppTextStyles.beschriftungGross.copyWith(
                color: AppFarben.phaseKindheit.withValues(alpha: 0.7),
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 8),

            Text(
              'Die Formung',
              style: AppTextStyles.ueberschrift2,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 16),

            Text(
              'Ein Körper entsteht.\nOrgane, Herzschlag, Gedanken.',
              style: AppTextStyles.koerperKursiv,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 700.ms),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STUFE 1: Organ-Puzzle Minigame
// ─────────────────────────────────────────────────────────────────────────────

class _OrganPuzzleMinigame extends StatefulWidget {
  final VoidCallback onAbgeschlossen;

  const _OrganPuzzleMinigame({super.key, required this.onAbgeschlossen});

  @override
  State<_OrganPuzzleMinigame> createState() => _OrganPuzzleMinigameState();
}

class _OrganPuzzleMinigameState extends State<_OrganPuzzleMinigame> {
  // Welche Organe wurden korrekt platziert (nach ID)
  final Set<String> _platziertIds = {};

  // Welches Organ wird gerade gezogen
  String? _gezogenId;

  // Feedback-Text für Slot-Verbindung
  String? _feedbackText;

  bool get _allesPlatziertiert => _platziertIds.length >= _organe.length;

  void _organPlatziert(String organId) {
    if (_platziertIds.contains(organId)) return;
    setState(() {
      _platziertIds.add(organId);
      _feedbackText = '${_organe.firstWhere((o) => o.id == organId).name} verbunden';
    });

    // Feedback nach kurzer Zeit löschen
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _feedbackText = null);
    });

    if (_allesPlatziertiert) {
      Future.delayed(const Duration(milliseconds: 800), widget.onAbgeschlossen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StufeHeader(
          stufeNummer: 1,
          titel: 'Organ-Puzzle',
          beschreibung: 'Ziehe die Organe an die richtige Position',
          fortschritt: _platziertIds.length / _organe.length,
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Linke Seite: Organ-Liste zum Ziehen
                Expanded(
                  flex: 2,
                  child: _OrganListe(
                    organe: _organe,
                    platziertIds: _platziertIds,
                    onDragStart: (id) => setState(() => _gezogenId = id),
                    onDragEnd: () => setState(() => _gezogenId = null),
                  ),
                ),

                const SizedBox(width: 12),

                // Rechte Seite: Körper-Silhouette mit Slots
                Expanded(
                  flex: 3,
                  child: _KoerperSilhouette(
                    organe: _organe,
                    platziertIds: _platziertIds,
                    onOrganPlatziert: _organPlatziert,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Feedback-Anzeige
        if (_feedbackText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppFarben.karmaPositiv.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppFarben.karmaPositiv.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: AppFarben.karmaPositiv, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _feedbackText!,
                    style: AppTextStyles.koerperKleinFett.copyWith(
                      color: AppFarben.karmaPositiv,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().then(delay: 900.ms).fadeOut(),
          ),
      ],
    );
  }
}

/// Liste der Organ-Icons zum Ziehen (links im Puzzle)
class _OrganListe extends StatelessWidget {
  final List<_OrganDaten> organe;
  final Set<String> platziertIds;
  final Function(String) onDragStart;
  final VoidCallback onDragEnd;

  const _OrganListe({
    required this.organe,
    required this.platziertIds,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppFarben.oberflaecheErhoben.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppFarben.nebelGrau.withValues(alpha: 0.3)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: organe.map((organ) {
          final platziertiert = platziertIds.contains(organ.id);

          if (platziertiert) {
            // Platziiertes Organ: ausgegraut anzeigen
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Opacity(
                opacity: 0.3,
                child: _OrganChip(organ: organ, istKlein: true),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Draggable<String>(
              data: organ.id,
              onDragStarted: () => onDragStart(organ.id),
              onDragEnd: (_) => onDragEnd(),
              feedback: Material(
                color: Colors.transparent,
                child: _OrganChip(organ: organ, istKlein: false, istFeedback: true),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _OrganChip(organ: organ, istKlein: true),
              ),
              child: _OrganChip(organ: organ, istKlein: true),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Ein einzelner Organ-Chip
class _OrganChip extends StatelessWidget {
  final _OrganDaten organ;
  final bool istKlein;
  final bool istFeedback;

  const _OrganChip({
    required this.organ,
    required this.istKlein,
    this.istFeedback = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: istKlein ? 8 : 12,
        vertical: istKlein ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: organ.farbe.withValues(alpha: istFeedback ? 0.4 : 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: organ.farbe.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: istFeedback
            ? [BoxShadow(color: organ.farbe.withValues(alpha: 0.4), blurRadius: 12)]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(organ.icon, color: organ.farbe, size: istKlein ? 16 : 22),
          const SizedBox(width: 6),
          Text(
            organ.name,
            style: AppTextStyles.koerperKleinFett.copyWith(
              color: organ.farbe,
              fontSize: istKlein ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Körper-Silhouette mit Drag-Target-Slots
class _KoerperSilhouette extends StatelessWidget {
  final List<_OrganDaten> organe;
  final Set<String> platziertIds;
  final Function(String) onOrganPlatziert;

  const _KoerperSilhouette({
    required this.organe,
    required this.platziertIds,
    required this.onOrganPlatziert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppFarben.tiefesBlau.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppFarben.phaseKindheit.withValues(alpha: 0.3),
        ),
      ),
      child: Stack(
        children: [
          // Körper-Silhouette (vereinfacht als abgerundetes Rechteck)
          Center(
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: AppFarben.nebelGrau.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: AppFarben.nebelGrau.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),

          // Organ-Slots auf dem Körper
          ...organe.map((organ) {
            final platziertiert = platziertIds.contains(organ.id);

            return Align(
              alignment: organ.slotPosition,
              child: DragTarget<String>(
                onWillAcceptWithDetails: (details) => details.data == organ.id,
                onAcceptWithDetails: (details) => onOrganPlatziert(details.data),
                builder: (context, candidateData, rejectedData) {
                  final istAktiv = candidateData.isNotEmpty;

                  return Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: platziertiert
                          ? organ.farbe.withValues(alpha: 0.4)
                          : (istAktiv
                              ? organ.farbe.withValues(alpha: 0.3)
                              : AppFarben.kosmischSchwarz.withValues(alpha: 0.5)),
                      border: Border.all(
                        color: platziertiert
                            ? organ.farbe
                            : (istAktiv
                                ? organ.farbe
                                : AppFarben.nebelGrau.withValues(alpha: 0.4)),
                        width: platziertiert ? 2 : 1,
                      ),
                      boxShadow: platziertiert
                          ? [BoxShadow(color: organ.farbe.withValues(alpha: 0.6), blurRadius: 10)]
                          : null,
                    ),
                    child: Icon(
                      platziertiert ? organ.icon : Icons.add,
                      color: platziertiert
                          ? organ.farbe
                          : AppFarben.nebelGrau.withValues(alpha: 0.5),
                      size: platziertiert ? 20 : 16,
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STUFE 2: Herzschlag-Rhythmus Minigame
// ─────────────────────────────────────────────────────────────────────────────

class _HerzschlagMinigame extends StatefulWidget {
  final Function(double herzGesundheit) onAbgeschlossen;

  const _HerzschlagMinigame({super.key, required this.onAbgeschlossen});

  @override
  State<_HerzschlagMinigame> createState() => _HerzschlagMinigameState();
}

class _HerzschlagMinigameState extends State<_HerzschlagMinigame>
    with SingleTickerProviderStateMixin {
  // Puls-Animation (0.0–1.0, ein vollständiger Herzschlagzyklus)
  late final AnimationController _pulsController;

  // Anzahl notwendiger Tippversuche
  static const int _maxSchlaege = 10;

  // Aktueller Schlag-Zähler
  int _schlaege = 0;

  // Erfolgreiche Tipps (im richtigen Zeitfenster ±200ms)
  int _treffenderSchlaege = 0;

  // Peak-Zeit: wann hat der aktuelle Schlag seinen Höhepunkt?
  DateTime? _aktuellerPeakZeit;

  // Feedback nach Tipp
  String _feedback = '';

  // Schlag-Dauer (ms)
  static const int _schlagDauer = 900;

  // Toleranz-Fenster für richtiges Tippen (±ms)
  static const int _toleranzMs = 200;

  bool _aktiv = true;

  @override
  void initState() {
    super.initState();
    _pulsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _schlagDauer),
    );

    // Nächsten Schlag starten
    _naechsterSchlag();
  }

  @override
  void dispose() {
    _pulsController.dispose();
    super.dispose();
  }

  Future<void> _naechsterSchlag() async {
    if (!_aktiv || !mounted) return;
    if (_schlaege >= _maxSchlaege) {
      // Spiel beendet
      final erfolgsRate = _treffenderSchlaege / _maxSchlaege;
      final herzGesundheit = 0.6 + erfolgsRate * 0.4; // 60–100%
      widget.onAbgeschlossen(herzGesundheit);
      return;
    }

    // Kleines Intervall zwischen Schlägen
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted || !_aktiv) return;

    // Peak-Zeitpunkt festhalten (Mitte des Schlags = ~450ms nach Start)
    _aktuellerPeakZeit =
        DateTime.now().add(const Duration(milliseconds: _schlagDauer ~/ 2));

    _pulsController.forward(from: 0);
    setState(() => _schlaege++);

    await Future.delayed(const Duration(milliseconds: _schlagDauer));
    if (!mounted) return;

    _naechsterSchlag();
  }

  void _tippen() {
    if (!_aktiv || _aktuellerPeakZeit == null) return;

    final jetzt = DateTime.now();
    final differenzMs = jetzt.difference(_aktuellerPeakZeit!).inMilliseconds.abs();

    if (differenzMs <= _toleranzMs) {
      setState(() {
        _treffenderSchlaege++;
        _feedback = '♥ Perfekt!';
      });
    } else {
      setState(() => _feedback = 'Zu früh oder zu spät...');
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _feedback = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StufeHeader(
          stufeNummer: 2,
          titel: 'Herzschlag-Rhythmus',
          beschreibung: 'Tippe im richtigen Moment wenn der Puls seinen Höhepunkt erreicht',
          fortschritt: _schlaege / _maxSchlaege,
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Puls-Fortschrittsanzeige
                Text(
                  '$_treffenderSchlaege / $_schlaege Schläge getroffen',
                  style: AppTextStyles.spielStatus.copyWith(
                    color: AppFarben.textSekundaer,
                  ),
                ),

                const SizedBox(height: 32),

                // EKG-Linie mit CustomPainter
                AnimatedBuilder(
                  animation: _pulsController,
                  builder: (context, _) {
                    return SizedBox(
                      height: 100,
                      child: CustomPaint(
                        painter: _EkgPainter(fortschritt: _pulsController.value),
                        child: Container(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Feedback-Text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _feedback,
                    key: ValueKey(_feedback),
                    style: AppTextStyles.ueberschrift4.copyWith(
                      color: _feedback.contains('Perfekt')
                          ? AppFarben.karmaPositiv
                          : AppFarben.karmaNeutral,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Tipp-Button
                GestureDetector(
                  onTapDown: (_) => _tippen(),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFEF5350).withValues(alpha: 0.8),
                          const Color(0xFFB71C1C).withValues(alpha: 0.4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF5350).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(
                      begin: 1.0,
                      end: 1.08,
                      duration: const Duration(milliseconds: _schlagDauer),
                    ),

                const SizedBox(height: 20),

                Text(
                  'Tippe auf den Puls',
                  style: AppTextStyles.koerperKlein,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter für die EKG-Puls-Linie
class _EkgPainter extends CustomPainter {
  final double fortschritt; // 0.0 – 1.0

  _EkgPainter({required this.fortschritt});

  @override
  void paint(Canvas canvas, Size size) {
    final farbe = const Color(0xFF4CAF50);
    final paint = Paint()
      ..color = farbe
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final breite = size.width;
    final mitte = size.height / 2;

    // EKG-Wellenform: flache Linie → Spike → flache Linie (abhängig von fortschritt)
    path.moveTo(0, mitte);

    // Flache Linie bis zum Start des Spikes
    final spikeStart = breite * (fortschritt - 0.15).clamp(0.0, 1.0);
    final spikePeak = breite * fortschritt;
    final spikeEnd = breite * (fortschritt + 0.15).clamp(0.0, 1.0);

    path.lineTo(spikeStart, mitte);

    if (fortschritt > 0.15 && fortschritt < 0.85) {
      // QRS-Komplex: kleines Q (nach unten), R (nach oben), S (nach unten)
      path.lineTo(spikeStart + (spikePeak - spikeStart) * 0.3, mitte + 8);
      path.lineTo(spikePeak, mitte - size.height * 0.7);
      path.lineTo(spikeEnd - (spikeEnd - spikePeak) * 0.2, mitte + 12);
      path.lineTo(spikeEnd, mitte);
    }

    path.lineTo(breite, mitte);

    canvas.drawPath(path, paint);

    // Glowing-Punkt am aktuellen Fortschritt
    final glowPaint = Paint()
      ..color = farbe.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(
      Offset(breite * fortschritt, mitte),
      6,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_EkgPainter old) => old.fortschritt != fortschritt;
}

// ─────────────────────────────────────────────────────────────────────────────
// STUFE 3: Synapsen-Verbinden Minigame
// ─────────────────────────────────────────────────────────────────────────────

class _SynapsenMinigame extends StatefulWidget {
  final Function(double intelligenz) onAbgeschlossen;

  const _SynapsenMinigame({super.key, required this.onAbgeschlossen});

  @override
  State<_SynapsenMinigame> createState() => _SynapsenMinigameState();
}

class _SynapsenMinigameState extends State<_SynapsenMinigame> {
  // 8 Neuron-Punkte (relative Positionen 0.0–1.0)
  static final List<Offset> _neuronen = [
    const Offset(0.15, 0.15),
    const Offset(0.50, 0.10),
    const Offset(0.82, 0.20),
    const Offset(0.10, 0.50),
    const Offset(0.45, 0.45),
    const Offset(0.80, 0.55),
    const Offset(0.25, 0.82),
    const Offset(0.65, 0.80),
  ];

  // Verbindungen: List<Paar von Indizes>
  final List<(int, int)> _verbindungen = [];

  // Aktuell gezogenes Neuron (Start-Index)
  int? _gezogenStart;

  // Aktuelle Drag-Endposition
  Offset? _dragPosition;

  static const int _mindestVerbindungen = 6;

  bool get _genugVerbindungen => _verbindungen.length >= _mindestVerbindungen;

  bool _verbindungExistiert(int a, int b) {
    return _verbindungen.any(
      (v) => (v.$1 == a && v.$2 == b) || (v.$1 == b && v.$2 == a),
    );
  }

  void _neuronBerührt(int index) {
    if (_gezogenStart == null) {
      setState(() => _gezogenStart = index);
    } else if (_gezogenStart != index) {
      // Verbindung herstellen
      if (!_verbindungExistiert(_gezogenStart!, index)) {
        setState(() {
          _verbindungen.add((_gezogenStart!, index));
          _gezogenStart = null;
          _dragPosition = null;
        });
      } else {
        setState(() {
          _gezogenStart = null;
          _dragPosition = null;
        });
      }
    }
  }

  void _abschliessen() {
    final erfolgsRate = _verbindungen.length / 8;
    final intelligenz = (0.4 + erfolgsRate * 0.6).clamp(0.0, 1.0);
    widget.onAbgeschlossen(intelligenz);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StufeHeader(
          stufeNummer: 3,
          titel: 'Synapsen-Verbinden',
          beschreibung: 'Verbinde mindestens 6 von 8 Neuronen',
          fortschritt: (_verbindungen.length / _mindestVerbindungen).clamp(0.0, 1.0),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${_verbindungen.length} / 8 Verbindungen',
                  style: AppTextStyles.spielStatus.copyWith(
                    color: _genugVerbindungen
                        ? AppFarben.karmaPositiv
                        : AppFarben.textSekundaer,
                  ),
                ),

                const SizedBox(height: 12),

                // Neuron-Canvas
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapDown: (details) {
                          // Prüfen ob ein Neuron getroffen
                          final rel = Offset(
                            details.localPosition.dx / constraints.maxWidth,
                            details.localPosition.dy / constraints.maxHeight,
                          );
                          for (int i = 0; i < _neuronen.length; i++) {
                            final abstand = (_neuronen[i] - rel).distance;
                            if (abstand < 0.06) {
                              _neuronBerührt(i);
                              return;
                            }
                          }
                          // Kein Neuron getroffen: Reset
                          setState(() {
                            _gezogenStart = null;
                            _dragPosition = null;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppFarben.tiefesBlau.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppFarben.mystischLila.withValues(alpha: 0.3),
                            ),
                          ),
                          child: CustomPaint(
                            painter: _SynapsenPainter(
                              neuronen: _neuronen,
                              verbindungen: _verbindungen,
                              gezogenStart: _gezogenStart,
                              dragPosition: _dragPosition,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                if (_gezogenStart != null)
                  Text(
                    'Neuron ${_gezogenStart! + 1} ausgewählt – tippe ein weiteres',
                    style: AppTextStyles.koerperKlein.copyWith(
                      color: AppFarben.phaseKindheit,
                    ),
                  ),

                const SizedBox(height: 16),

                // Weiter-Button sobald genug Verbindungen
                if (_genugVerbindungen)
                  GenesisButton(
                    text: 'Synapsen aktiviert',
                    onPressed: _abschliessen,
                    icon: Icons.psychology,
                  ).animate().fadeIn().scale(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter für den Synapsen-Canvas
class _SynapsenPainter extends CustomPainter {
  final List<Offset> neuronen;
  final List<(int, int)> verbindungen;
  final int? gezogenStart;
  final Offset? dragPosition;

  _SynapsenPainter({
    required this.neuronen,
    required this.verbindungen,
    required this.gezogenStart,
    required this.dragPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final neuronFarbe = const Color(0xFF81D4FA);
    final verbindungsFarbe = const Color(0xFF4DD0E1).withValues(alpha: 0.6);

    final linePaint = Paint()
      ..color = verbindungsFarbe
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final neuronPaint = Paint()
      ..color = neuronFarbe
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = neuronFarbe.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.fill;

    // Verbindungen zeichnen
    for (final (a, b) in verbindungen) {
      final startPunkt = Offset(
        neuronen[a].dx * size.width,
        neuronen[a].dy * size.height,
      );
      final endPunkt = Offset(
        neuronen[b].dx * size.width,
        neuronen[b].dy * size.height,
      );
      canvas.drawLine(startPunkt, endPunkt, linePaint);
    }

    // Neuronen zeichnen
    for (int i = 0; i < neuronen.length; i++) {
      final pos = Offset(
        neuronen[i].dx * size.width,
        neuronen[i].dy * size.height,
      );
      final istAusgewaehlt = gezogenStart == i;

      // Glow für ausgewähltes Neuron
      if (istAusgewaehlt) {
        canvas.drawCircle(pos, 16, glowPaint);
      }

      // Neuron-Kreis
      canvas.drawCircle(
        pos,
        istAusgewaehlt ? 12 : 8,
        neuronPaint..color = istAusgewaehlt ? neuronFarbe : neuronFarbe.withValues(alpha: 0.8),
      );

      // Neuron-Nummer
      final textSpan = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          color: Colors.black87,
          fontSize: istAusgewaehlt ? 9 : 7,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_SynapsenPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Abschluss-Screen: Alle Stufen abgeschlossen
// ─────────────────────────────────────────────────────────────────────────────

class _AlleStufeAbgeschlossen extends StatelessWidget {
  final double herzGesundheit;
  final double intelligenz;
  final VoidCallback onWeiter;

  const _AlleStufeAbgeschlossen({
    super.key,
    required this.herzGesundheit,
    required this.intelligenz,
    required this.onWeiter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Erfolgs-Symbol
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppFarben.phaseKindheit.withValues(alpha: 0.6),
                    AppFarben.mystischLila.withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: AppFarben.phaseKindheit,
                  width: 2,
                ),
              ),
              child: const Icon(Icons.child_care, color: Colors.white, size: 50),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            Text(
              'Der Körper ist bereit',
              style: AppTextStyles.ueberschrift2,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 24),

            // Attribut-Anzeige
            _AttributReihe(
              label: 'Herz-Gesundheit',
              wert: herzGesundheit,
              farbe: const Color(0xFFEF5350),
              icon: Icons.favorite,
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 8),

            _AttributReihe(
              label: 'Intelligenz',
              wert: intelligenz,
              farbe: const Color(0xFFAB47BC),
              icon: Icons.psychology,
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 40),

            GenesisButton(
              text: 'Die Geburt erwartet dich',
              onPressed: onWeiter,
              icon: Icons.light_mode,
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}

/// Attribut-Balken-Widget
class _AttributReihe extends StatelessWidget {
  final String label;
  final double wert; // 0.0 – 1.0
  final Color farbe;
  final IconData icon;

  const _AttributReihe({
    required this.label,
    required this.wert,
    required this.farbe,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: farbe, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppTextStyles.koerperKleinFett),
                  Text(
                    '${(wert * 100).round()}%',
                    style: AppTextStyles.koerperKleinFett.copyWith(color: farbe),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: wert,
                  backgroundColor: AppFarben.nebelGrau.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(farbe),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gemeinsamer Stufen-Header
// ─────────────────────────────────────────────────────────────────────────────

class _StufeHeader extends StatelessWidget {
  final int stufeNummer;
  final String titel;
  final String beschreibung;
  final double fortschritt;

  const _StufeHeader({
    required this.stufeNummer,
    required this.titel,
    required this.beschreibung,
    required this.fortschritt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: AppFarben.tiefesBlau.withValues(alpha: 0.6),
        border: Border(
          bottom: BorderSide(
            color: AppFarben.phaseKindheit.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Stufen-Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppFarben.phaseKindheit.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppFarben.phaseKindheit.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'STUFE $stufeNummer',
                  style: AppTextStyles.beschriftungGross.copyWith(
                    color: AppFarben.phaseKindheit,
                    fontSize: 10,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  titel,
                  style: AppTextStyles.ueberschrift4.copyWith(
                    color: AppFarben.text,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            beschreibung,
            style: AppTextStyles.koerperKlein,
          ),

          const SizedBox(height: 8),

          // Fortschrittsbalken
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fortschritt,
              backgroundColor: AppFarben.nebelGrau.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppFarben.phaseKindheit),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
