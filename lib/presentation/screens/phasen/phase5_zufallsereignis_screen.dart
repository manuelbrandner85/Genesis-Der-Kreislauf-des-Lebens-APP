// phase5_zufallsereignis_screen.dart
// Zufallsereignis-Screen für Phase 5 (Erwachsenenleben) in GENESIS.
// Zeigt eine Ereignis-Karte mit Titel, Beschreibung und 2–3 Reaktions-Optionen.
// Nach Auswahl: Karma-Auswirkung sichtbar, automatische Rückkehr nach 2 Sekunden.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/karma_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Datenmodelle für Ereignisse
// ─────────────────────────────────────────────────────────────────────────────

/// Repräsentiert eine Reaktions-Option für ein Zufallsereignis.
class _ReaktionsOption {
  final String text;
  final String karmaBeschreibung;
  final Map<KarmaDimension, double> karmaAenderungen;
  final IconData icon;
  final bool istPositiv;

  const _ReaktionsOption({
    required this.text,
    required this.karmaBeschreibung,
    required this.karmaAenderungen,
    required this.icon,
    required this.istPositiv,
  });
}

/// Vollständige Datenstruktur eines Zufallsereignisses.
class _Zufallsereignis {
  final String titel;
  final String beschreibung;
  final String hintergrundText;
  final IconData icon;
  final Color akzentFarbe;
  final List<_ReaktionsOption> optionen;

  const _Zufallsereignis({
    required this.titel,
    required this.beschreibung,
    required this.hintergrundText,
    required this.icon,
    required this.akzentFarbe,
    required this.optionen,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Ereignis-Pool (simuliert – wird in der Vollimpl. aus JSON geladen)
// ─────────────────────────────────────────────────────────────────────────────

const List<_Zufallsereignis> _ereignisPool = [
  // ── Beförderung ────────────────────────────────────────────────────────────
  _Zufallsereignis(
    titel: 'Unerwartete Beförderung',
    beschreibung:
        'Dein Vorgesetzter ruft dich ins Büro. Er bietet dir eine '
        'leitende Position mit mehr Verantwortung – und deutlich mehr Gehalt. '
        'Doch es bedeutet auch, dass ein Kollege, der sich ebenfalls beworben hat, '
        'übergangen wird.',
    hintergrundText: 'Die Entscheidung wird deinen Karriereweg für Jahre prägen.',
    icon: Icons.trending_up,
    akzentFarbe: AppFarben.phaseBluete,
    optionen: [
      _ReaktionsOption(
        text: 'Annehmen und Kollegen unterstützen',
        karmaBeschreibung: '+Mitgefühl, +Großzügigkeit',
        karmaAenderungen: {
          KarmaDimension.mitgefuehl: 8.0,
          KarmaDimension.grosszuegigkeit: 5.0,
        },
        icon: Icons.handshake,
        istPositiv: true,
      ),
      _ReaktionsOption(
        text: 'Annehmen – du hast es verdient',
        karmaBeschreibung: '+Mut, keine Karma-Änderung',
        karmaAenderungen: {
          KarmaDimension.mut: 3.0,
        },
        icon: Icons.work,
        istPositiv: true,
      ),
      _ReaktionsOption(
        text: 'Ablehnen zugunsten des Kollegen',
        karmaBeschreibung: '+Liebe, +Mitgefühl, -Mut',
        karmaAenderungen: {
          KarmaDimension.liebe: 10.0,
          KarmaDimension.mitgefuehl: 12.0,
          KarmaDimension.mut: -5.0,
        },
        icon: Icons.volunteer_activism,
        istPositiv: true,
      ),
    ],
  ),

  // ── Unfall ─────────────────────────────────────────────────────────────────
  _Zufallsereignis(
    titel: 'Zeuge eines Unfalls',
    beschreibung:
        'Auf dem Weg zur Arbeit siehst du, wie ein älterer Mann auf der '
        'vereisten Straße stürzt. Er liegt auf dem Boden und scheint Schmerzen zu haben. '
        'Andere Menschen gehen vorüber – du bist spät dran.',
    hintergrundText: 'Manchmal entscheiden Sekunden über unseren Charakter.',
    icon: Icons.warning_amber,
    akzentFarbe: AppFarben.karmaNeutral,
    optionen: [
      _ReaktionsOption(
        text: 'Sofort helfen und Notarzt rufen',
        karmaBeschreibung: '+Mitgefühl, +Mut',
        karmaAenderungen: {
          KarmaDimension.mitgefuehl: 15.0,
          KarmaDimension.mut: 8.0,
        },
        icon: Icons.medical_services,
        istPositiv: true,
      ),
      _ReaktionsOption(
        text: 'Jemand anderen darum bitten zu helfen',
        karmaBeschreibung: '+Mitgefühl (teilweise)',
        karmaAenderungen: {
          KarmaDimension.mitgefuehl: 5.0,
        },
        icon: Icons.people,
        istPositiv: true,
      ),
    ],
  ),

  // ── Lottogewinn ───────────────────────────────────────────────────────────
  _Zufallsereignis(
    titel: 'Kleiner Lottogewinn',
    beschreibung:
        'Du hast 800 Euro gewonnen! Ein unerwarteter Glücksmoment. '
        'Gleichzeitig weißt du, dass deine Nachbarin gerade in finanziellen '
        'Schwierigkeiten steckt und ihr Kind neue Schulbücher braucht.',
    hintergrundText: 'Glück verpflichtet – oder auch nicht.',
    icon: Icons.casino,
    akzentFarbe: AppFarben.goldGlanz,
    optionen: [
      _ReaktionsOption(
        text: 'Geld mit Nachbarin teilen',
        karmaBeschreibung: '+Großzügigkeit, +Liebe',
        karmaAenderungen: {
          KarmaDimension.grosszuegigkeit: 18.0,
          KarmaDimension.liebe: 10.0,
        },
        icon: Icons.favorite,
        istPositiv: true,
      ),
      _ReaktionsOption(
        text: 'Geld sparen für eigene Ziele',
        karmaBeschreibung: 'Keine Änderung',
        karmaAenderungen: {},
        icon: Icons.savings,
        istPositiv: true,
      ),
      _ReaktionsOption(
        text: 'Fest feiern und Freunde einladen',
        karmaBeschreibung: '+Liebe, -Weisheit',
        karmaAenderungen: {
          KarmaDimension.liebe: 5.0,
          KarmaDimension.weisheit: -3.0,
        },
        icon: Icons.celebration,
        istPositiv: true,
      ),
    ],
  ),

  // ── Neue Liebe ─────────────────────────────────────────────────────────────
  _Zufallsereignis(
    titel: 'Unerwartete Begegnung',
    beschreibung:
        'In einer Buchhandlung begegnet dir eine Person, die dich sofort fasziniert. '
        'Das Gespräch fließt wie von selbst. Du spürst eine tiefe Verbindung – '
        'obwohl du eigentlich gerade nicht nach einer Beziehung suchst.',
    hintergrundText: 'Das Herz kennt keine perfekten Zeitpunkte.',
    icon: Icons.favorite_border,
    akzentFarbe: AppFarben.emotionVerliebt,
    optionen: [
      _ReaktionsOption(
        text: 'Nummern austauschen und treffen',
        karmaBeschreibung: '+Mut, +Liebe',
        karmaAenderungen: {
          KarmaDimension.mut: 8.0,
          KarmaDimension.liebe: 12.0,
        },
        icon: Icons.phone,
        istPositiv: true,
      ),
      _ReaktionsOption(
        text: 'Das Schicksal seinem Lauf lassen',
        karmaBeschreibung: 'Keine Änderung – aber ein stilles Bedauern.',
        karmaAenderungen: {},
        icon: Icons.directions_walk,
        istPositiv: false,
      ),
    ],
  ),

  // ── Reisechance ────────────────────────────────────────────────────────────
  _Zufallsereignis(
    titel: 'Reisechance ins Ausland',
    beschreibung:
        'Ein Freund bietet dir an, ihn für drei Monate auf einer Reise nach '
        'Südostasien zu begleiten. Die Kosten wären gering, aber du müsstest '
        'deinen Job für diesen Zeitraum aufgeben. Die Erfahrung wäre einmalig.',
    hintergrundText: 'Manchmal ist das größte Risiko, keines einzugehen.',
    icon: Icons.flight,
    akzentFarbe: AppFarben.phaseAufbruch,
    optionen: [
      _ReaktionsOption(
        text: 'Mitgehen – das Leben wartet!',
        karmaBeschreibung: '+Mut, +Weisheit',
        karmaAenderungen: {
          KarmaDimension.mut: 15.0,
          KarmaDimension.weisheit: 8.0,
        },
        icon: Icons.luggage,
        istPositiv: true,
      ),
      _ReaktionsOption(
        text: 'Ablehnen – Job-Sicherheit hat Vorrang',
        karmaBeschreibung: '+Weisheit (kurzfristig), -Mut',
        karmaAenderungen: {
          KarmaDimension.weisheit: 3.0,
          KarmaDimension.mut: -5.0,
        },
        icon: Icons.work_outline,
        istPositiv: false,
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Phase5ZufallsereignisScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Zufallsereignis-Screen für Phase 5.
///
/// Zeigt ein zufällig ausgewähltes Ereignis mit Titel, Beschreibung,
/// kontextualisierendem Hintergrund-Text und 2–3 Reaktions-Optionen.
///
/// Nach Auswahl einer Option:
/// 1. Karma-Änderung wird angezeigt (+/- Werte pro Dimension)
/// 2. Rückkehr zu Phase 5 nach 2,5 Sekunden (automatisch)
class Phase5ZufallsereignisScreen extends ConsumerStatefulWidget {
  /// Optionaler Index zur Auswahl eines bestimmten Ereignisses.
  /// Falls null, wird tagesbasiert zufällig gewählt.
  final int? ereignisIndex;

  const Phase5ZufallsereignisScreen({super.key, this.ereignisIndex});

  @override
  ConsumerState<Phase5ZufallsereignisScreen> createState() =>
      _Phase5ZufallsereignisScreenState();
}

class _Phase5ZufallsereignisScreenState
    extends ConsumerState<Phase5ZufallsereignisScreen>
    with SingleTickerProviderStateMixin {
  // Gewählte Option (null = noch keine Auswahl)
  int? _gewaehlteOptionIndex;

  // Ob die Karma-Auswirkungen bereits angezeigt werden
  bool _zeigeKarmaAuswirkung = false;

  // Einblend-Animation für die Ereignis-Karte
  late AnimationController _erscheinController;
  late Animation<double> _erscheinAnimation;

  // Karma-Auswirkung-Animation
  late AnimationController _karmaController;
  late Animation<double> _karmaAnimation;

  // Ausgewähltes Ereignis
  late _Zufallsereignis _ereignis;

  @override
  void initState() {
    super.initState();

    // Tagesbasiert zufällig oder per Index wählen
    final index = widget.ereignisIndex ??
        (DateTime.now().day % _ereignisPool.length);
    _ereignis = _ereignisPool[index.clamp(0, _ereignisPool.length - 1)];

    // Einblend-Animation
    _erscheinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _erscheinAnimation = CurvedAnimation(
      parent: _erscheinController,
      curve: Curves.easeOut,
    );
    _erscheinController.forward();

    // Karma-Anzeige-Animation
    _karmaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _karmaAnimation = CurvedAnimation(
      parent: _karmaController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _erscheinController.dispose();
    _karmaController.dispose();
    super.dispose();
  }

  // ── Reaktion auswählen ────────────────────────────────────────────────────

  void _optionWaehlen(int index) {
    if (_gewaehlteOptionIndex != null) return; // Bereits gewählt

    final option = _ereignis.optionen[index];

    // Karma-Änderungen anwenden
    final karmaNotifier = ref.read(karmaProvider.notifier);
    for (final eintrag in option.karmaAenderungen.entries) {
      karmaNotifier.dimensionAendern(eintrag.key, eintrag.value);
    }

    setState(() {
      _gewaehlteOptionIndex = index;
      _zeigeKarmaAuswirkung = true;
    });

    // Karma-Einblend-Animation starten
    _karmaController.forward();

    // Automatische Rückkehr nach 2.5 Sekunden
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go(AppRouten.phase5);
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: Stack(
        children: [
          // Hintergrund-Glow passend zur Ereignis-Farbe
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  _ereignis.akzentFarbe.withValues(alpha: 0.08),
                  AppFarben.kosmischSchwarz,
                ],
              ),
            ),
          ),

          // Haupt-Inhalt
          SafeArea(
            child: FadeTransition(
              opacity: _erscheinAnimation,
              child: Column(
                children: [
                  // ── Kopfzeile ─────────────────────────────────────────────
                  _Kopfzeile(akzentFarbe: _ereignis.akzentFarbe),

                  // ── Scrollbarer Inhalt ────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ereignis-Karte
                          _EreignisKarte(ereignis: _ereignis),

                          const SizedBox(height: 24),

                          // Reaktions-Optionen (nur wenn noch keine Auswahl)
                          if (_gewaehlteOptionIndex == null) ...[
                            Text(
                              'WIE REAGIERST DU?',
                              style: AppTextStyles.beschriftungGross.copyWith(
                                color: _ereignis.akzentFarbe,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ..._ereignis.optionen.asMap().entries.map((entry) {
                              return _OptionKarte(
                                option: entry.value,
                                index: entry.key,
                                onGewaehlt: () => _optionWaehlen(entry.key),
                                delay: Duration(
                                    milliseconds: 100 + entry.key * 80),
                                akzentFarbe: _ereignis.akzentFarbe,
                              );
                            }),
                          ],

                          // Karma-Auswirkung nach Auswahl
                          if (_zeigeKarmaAuswirkung &&
                              _gewaehlteOptionIndex != null)
                            _KarmaAuswirkungAnzeige(
                              option: _ereignis
                                  .optionen[_gewaehlteOptionIndex!],
                              animation: _karmaAnimation,
                            ),
                        ],
                      ),
                    ),
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
// Kopfzeile
// ─────────────────────────────────────────────────────────────────────────────

class _Kopfzeile extends StatelessWidget {
  final Color akzentFarbe;

  const _Kopfzeile({required this.akzentFarbe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: akzentFarbe.withValues(alpha: 0.7)),
            onPressed: () => context.go(AppRouten.phase5),
          ),
          Text(
            'TAGESEREIGNIS',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: akzentFarbe,
            ),
          ),
          const Spacer(),
          // Fortschritts-Chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: akzentFarbe.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Phase V – Erwachsen',
              style: AppTextStyles.mikro.copyWith(color: akzentFarbe),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ereignis-Karte
// ─────────────────────────────────────────────────────────────────────────────

class _EreignisKarte extends StatelessWidget {
  final _Zufallsereignis ereignis;

  const _EreignisKarte({required this.ereignis});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppFarben.oberflaecheErhoben,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ereignis.akzentFarbe.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ereignis.akzentFarbe.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ereignis-Icon und Titel
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ereignis.akzentFarbe.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ereignis.akzentFarbe.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  ereignis.icon,
                  color: ereignis.akzentFarbe,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  ereignis.titel,
                  style: AppTextStyles.ueberschrift4.copyWith(
                    color: ereignis.akzentFarbe,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Trennlinie
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ereignis.akzentFarbe.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Ereignis-Beschreibung
          Text(
            ereignis.beschreibung,
            style: AppTextStyles.koerper.copyWith(height: 1.7),
          ),

          const SizedBox(height: 14),

          // Hintergrund-Kontext (kursiv)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppFarben.tiefesBlau.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ereignis.hintergrundText,
              style: AppTextStyles.gedanke,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.05, end: 0, duration: 450.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Options-Karte (auswählbare Reaktion)
// ─────────────────────────────────────────────────────────────────────────────

class _OptionKarte extends StatefulWidget {
  final _ReaktionsOption option;
  final int index;
  final VoidCallback onGewaehlt;
  final Duration delay;
  final Color akzentFarbe;

  const _OptionKarte({
    required this.option,
    required this.index,
    required this.onGewaehlt,
    required this.delay,
    required this.akzentFarbe,
  });

  @override
  State<_OptionKarte> createState() => _OptionKarteState();
}

class _OptionKarteState extends State<_OptionKarte> {
  bool _gedrueckt = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _gedrueckt = true),
      onTapUp: (_) {
        setState(() => _gedrueckt = false);
        widget.onGewaehlt();
      },
      onTapCancel: () => setState(() => _gedrueckt = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _gedrueckt
              ? widget.akzentFarbe.withValues(alpha: 0.2)
              : AppFarben.oberflaecheErhoben,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _gedrueckt
                ? widget.akzentFarbe
                : AppFarben.nebelGrau.withValues(alpha: 0.35),
            width: _gedrueckt ? 1.5 : 1.0,
          ),
          boxShadow: _gedrueckt
              ? [
                  BoxShadow(
                    color: widget.akzentFarbe.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Optionsbuchstabe (A, B, C)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.akzentFarbe.withValues(alpha: 0.5),
                ),
                color: widget.akzentFarbe.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + widget.index), // A, B, C
                  style: AppTextStyles.koerperKleinFett.copyWith(
                    color: widget.akzentFarbe,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.option.text,
                    style: AppTextStyles.entscheidung,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.option.karmaBeschreibung,
                    style: AppTextStyles.beschriftung.copyWith(
                      color: widget.option.istPositiv
                          ? AppFarben.karmaPositiv.withValues(alpha: 0.8)
                          : AppFarben.textTertiaer,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              widget.option.icon,
              color: widget.akzentFarbe.withValues(alpha: 0.6),
              size: 22,
            ),
          ],
        ),
      ),
    )
        .animate(delay: widget.delay)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.05, end: 0, duration: 350.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Karma-Auswirkung-Anzeige (nach Auswahl)
// ─────────────────────────────────────────────────────────────────────────────

class _KarmaAuswirkungAnzeige extends StatelessWidget {
  final _ReaktionsOption option;
  final Animation<double> animation;

  const _KarmaAuswirkungAnzeige({
    required this.option,
    required this.animation,
  });

  /// Lokalisierter Name der Karma-Dimension.
  String _dimensionName(KarmaDimension dim) {
    switch (dim) {
      case KarmaDimension.mitgefuehl:      return 'Mitgefühl';
      case KarmaDimension.ehrlichkeit:     return 'Ehrlichkeit';
      case KarmaDimension.mut:             return 'Mut';
      case KarmaDimension.grosszuegigkeit: return 'Großzügigkeit';
      case KarmaDimension.weisheit:        return 'Weisheit';
      case KarmaDimension.liebe:           return 'Liebe';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hatAenderungen = option.karmaAenderungen.isNotEmpty;

    return ScaleTransition(
      scale: animation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppFarben.oberflaecheErhoben,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppFarben.goldGlanz.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppFarben.goldGlanz.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppFarben.karmaPositiv, size: 22),
                const SizedBox(width: 8),
                Text(
                  'ENTSCHEIDUNG GETROFFEN',
                  style: AppTextStyles.beschriftungGross.copyWith(
                    color: AppFarben.goldGlanz,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              option.text,
              style: AppTextStyles.koerperKursiv.copyWith(
                color: AppFarben.textSekundaer,
              ),
            ),

            const SizedBox(height: 16),

            // ── Karma-Änderungen ──────────────────────────────────────────
            if (hatAenderungen) ...[
              Text(
                'KARMA-AUSWIRKUNG',
                style: AppTextStyles.beschriftungGross.copyWith(
                  color: AppFarben.textTertiaer,
                ),
              ),
              const SizedBox(height: 10),
              ...option.karmaAenderungen.entries.map((eintrag) {
                final istPositiv = eintrag.value >= 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          _dimensionName(eintrag.key),
                          style: AppTextStyles.koerperKlein,
                        ),
                      ),
                      // Grafischer Balken der Änderung
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: (eintrag.value.abs() / 20.0).clamp(0.0, 1.0),
                            backgroundColor:
                                AppFarben.nebelGrau.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              istPositiv
                                  ? AppFarben.karmaPositiv
                                  : AppFarben.karmaNegatv,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '${istPositiv ? '+' : ''}${eintrag.value.toStringAsFixed(0)}',
                          style: AppTextStyles.koerperKleinFett.copyWith(
                            color: istPositiv
                                ? AppFarben.karmaPositiv
                                : AppFarben.karmaNegatv,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              Row(
                children: [
                  const Icon(Icons.balance,
                      color: AppFarben.textTertiaer, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Keine Karma-Änderung.',
                    style: AppTextStyles.koerperKlein.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // ── Automatische Rückkehr-Hinweis ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppFarben.tiefesBlau.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppFarben.phaseBluete,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Kehre in 2 Sekunden zurück zum Leben…',
                    style: AppTextStyles.mikro.copyWith(
                      color: AppFarben.textTertiaer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
