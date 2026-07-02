// phase4_jugend_screen.dart
// Phase 4: Die Jugend – Social-Simulation mit Skill-Tree, Cliquen-System,
// Schul-Stress-Anzeige und Entscheidungen aus jugend.json.
// Alter 13–18, Identitätsfindung, Identitätskrise-Sequenz (Pflicht bei 16+).

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/karma_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Interne Datenmodelle für Phase 4
// ─────────────────────────────────────────────────────────────────────────────

/// Repräsentiert eine Clique mit Namen, Farbe und Ikonen-Beschreibung.
class _CliqueDaten {
  final String name;
  final IconData icon;
  final Color farbe;
  final String beschreibung;
  // Karma-Dimension, die diese Clique stärkt
  final KarmaDimension karmaBonus;

  const _CliqueDaten({
    required this.name,
    required this.icon,
    required this.farbe,
    required this.beschreibung,
    required this.karmaBonus,
  });
}

/// Liste der vier verfügbaren Cliquen.
const List<_CliqueDaten> _cliquen = [
  _CliqueDaten(
    name: 'Künstler',
    icon: Icons.palette,
    farbe: Color(0xFF9C27B0),
    beschreibung: 'Kreativ, rebellisch, individualistisch',
    karmaBonus: KarmaDimension.liebe,
  ),
  _CliqueDaten(
    name: 'Sportler',
    icon: Icons.sports_soccer,
    farbe: Color(0xFF2196F3),
    beschreibung: 'Diszipliniert, ehrgeizig, teamorientiert',
    karmaBonus: KarmaDimension.mut,
  ),
  _CliqueDaten(
    name: 'Intellektuelle',
    icon: Icons.menu_book,
    farbe: Color(0xFF4CAF50),
    beschreibung: 'Wissbegierig, analytisch, ruhig',
    karmaBonus: KarmaDimension.weisheit,
  ),
  _CliqueDaten(
    name: 'Außenseiter',
    icon: Icons.person_outline,
    farbe: Color(0xFF9E9E9E),
    beschreibung: 'Unabhängig, authentisch, allein',
    karmaBonus: KarmaDimension.ehrlichkeit,
  ),
];

/// Interne Entscheidungsoption aus der JSON-Datei.
class _JugendOption {
  final String id;
  final String text;
  final Map<KarmaDimension, double> karma;
  final List<String> sofortigeKonsequenzen;
  final double systemEinflussGewicht;

  const _JugendOption({
    required this.id,
    required this.text,
    required this.karma,
    required this.sofortigeKonsequenzen,
    required this.systemEinflussGewicht,
  });

  factory _JugendOption.fromJson(Map<String, dynamic> json) {
    // Karma-Werte aus JSON parsen
    final karmaRoh = json['karma'] as Map<String, dynamic>? ?? {};
    final karmaParsed = <KarmaDimension, double>{};
    karmaRoh.forEach((schluessel, wert) {
      final dim = _dimensionVonString(schluessel);
      if (dim != null) {
        karmaParsed[dim] = (wert as num).toDouble();
      }
    });

    final konsequenzenRoh =
        json['sofortigeKonsequenzen'] as List<dynamic>? ?? [];

    return _JugendOption(
      id: json['id'] as String,
      text: json['text'] as String,
      karma: karmaParsed,
      sofortigeKonsequenzen: konsequenzenRoh.cast<String>(),
      systemEinflussGewicht:
          (json['systemEinflussGewicht'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Interne Entscheidungssituation aus der JSON-Datei.
class _JugendEntscheidung {
  final String id;
  final int alter;
  final String kontext;
  final String frage;
  final String typ;
  final List<String> systemEinfluesse;
  final List<_JugendOption> optionen;

  const _JugendEntscheidung({
    required this.id,
    required this.alter,
    required this.kontext,
    required this.frage,
    required this.typ,
    required this.systemEinfluesse,
    required this.optionen,
  });

  factory _JugendEntscheidung.fromJson(Map<String, dynamic> json) {
    final optionenRoh = json['optionen'] as List<dynamic>;
    return _JugendEntscheidung(
      id: json['id'] as String,
      alter: json['alter'] as int,
      kontext: json['kontext'] as String,
      frage: json['frage'] as String,
      typ: json['typ'] as String,
      systemEinfluesse:
          (json['systemEinfluesse'] as List<dynamic>).cast<String>(),
      optionen:
          optionenRoh.map((o) => _JugendOption.fromJson(o as Map<String, dynamic>)).toList(),
    );
  }
}

/// Hilfsfunktion: String → KarmaDimension.
KarmaDimension? _dimensionVonString(String s) {
  switch (s) {
    case 'mitgefuehl':
      return KarmaDimension.mitgefuehl;
    case 'ehrlichkeit':
      return KarmaDimension.ehrlichkeit;
    case 'mut':
      return KarmaDimension.mut;
    case 'grosszuegigkeit':
      return KarmaDimension.grosszuegigkeit;
    case 'weisheit':
      return KarmaDimension.weisheit;
    case 'liebe':
      return KarmaDimension.liebe;
    default:
      return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Identity-Crisis-Antworten (Alter 16)
// ─────────────────────────────────────────────────────────────────────────────

/// Mögliche Antworten auf die Identity-Crisis-Frage "Wer bin ich?"
class _IdentitaetsAntwort {
  final String text;
  final Map<KarmaDimension, double> karma;
  final String folgeText;

  const _IdentitaetsAntwort({
    required this.text,
    required this.karma,
    required this.folgeText,
  });
}

const List<_IdentitaetsAntwort> _identitaetsAntworten = [
  _IdentitaetsAntwort(
    text: 'Ich bin meine Taten – was ich tue, definiert mich.',
    karma: {KarmaDimension.mut: 8.0, KarmaDimension.ehrlichkeit: 7.0},
    folgeText:
        'Eine tiefe Stille senkt sich über dich. Du spürst die Last und Kraft dieser Worte.',
  ),
  _IdentitaetsAntwort(
    text: 'Ich bin das Produkt meiner Umgebung – geprägt durch andere.',
    karma: {KarmaDimension.weisheit: 6.0, KarmaDimension.mitgefuehl: 5.0},
    folgeText:
        'Du erkennst, wie sehr die Menschen um dich herum dich formen. Das gibt dir Mitgefühl.',
  ),
  _IdentitaetsAntwort(
    text: 'Ich weiß es nicht – und das ist okay.',
    karma: {KarmaDimension.weisheit: 9.0, KarmaDimension.ehrlichkeit: 8.0},
    folgeText:
        'Diese Ehrlichkeit ist seltener Mut. Die Frage bleibt offen – ein Geschenk, keine Last.',
  ),
  _IdentitaetsAntwort(
    text: 'Ich bin die Liebe, die ich gebe – nichts mehr, nichts weniger.',
    karma: {KarmaDimension.liebe: 10.0, KarmaDimension.grosszuegigkeit: 6.0},
    folgeText:
        'Dein Herz öffnet sich weit. Etwas in dir verändert sich dauerhaft.',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Phase 4 Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Jugend-Phase (13–18 Jahre): Identitätsfindung, Clique, Stress-Meter.
///
/// Lädt Entscheidungen aus dem JSON-Asset, verwaltet das Stress-Meter,
/// zeigt das Clique-System und löst den Identity-Crisis-Moment aus.
class Phase4JugendScreen extends ConsumerStatefulWidget {
  const Phase4JugendScreen({super.key});

  @override
  ConsumerState<Phase4JugendScreen> createState() => _Phase4JugendScreenState();
}

class _Phase4JugendScreenState extends ConsumerState<Phase4JugendScreen>
    with TickerProviderStateMixin {
  // Liste aller Entscheidungen aus dem JSON-Asset
  List<_JugendEntscheidung> _entscheidungen = [];

  // Aktuell angezeigter Entscheidungsindex
  int _aktuellerIndex = 0;

  // Gewählte Clique (null = noch keine Wahl)
  _CliqueDaten? _gewaehlteCLique;

  // Stress-Meter: 0–100
  int _stress = 0;

  // Ob die Clique-Auswahl aktuell angezeigt wird
  bool _zeigeCliqueWahl = true;

  // Ob der Identity-Crisis-Moment aktiv ist
  bool _identitaetsCrisisAktiv = false;

  // Ob eine Entscheidung gerade verarbeitet wird (Konsequenz wird angezeigt)
  bool _verarbeiteEntscheidung = false;

  // Text der aktuell angezeigten Konsequenz
  String _konsequenzText = '';

  // Karma-Änderung der letzten Entscheidung (+/- Wert für Anzeige)
  double _letzteKarmaAenderung = 0.0;

  // Ob die Phase abgeschlossen ist
  bool _phaseAbgeschlossen = false;

  // Ladeindikator für JSON
  bool _laedt = true;

  // Animation-Controller für Stress-Balken-Puls
  late final AnimationController _stressPulsController;
  late final Animation<double> _stressPulsAnimation;

  // Animation-Controller für Identity-Crisis-Einblendung
  late final AnimationController _crisisController;
  late final Animation<double> _crisisAnimation;

  @override
  void initState() {
    super.initState();

    // Stress-Puls-Animation (wiederkehrend bei hohem Stress)
    _stressPulsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _stressPulsAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _stressPulsController, curve: Curves.easeInOut),
    );

    // Identity-Crisis-Animation
    _crisisController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _crisisAnimation = CurvedAnimation(
      parent: _crisisController,
      curve: Curves.easeInOut,
    );

    _entscheidungenLaden();
  }

  @override
  void dispose() {
    _stressPulsController.dispose();
    _crisisController.dispose();
    super.dispose();
  }

  // Lädt alle Jugend-Entscheidungen aus dem JSON-Asset
  Future<void> _entscheidungenLaden() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/data/entscheidungen/jugend.json');
      final jsonDaten = jsonDecode(jsonString) as Map<String, dynamic>;
      final listeRoh = jsonDaten['entscheidungen'] as List<dynamic>;

      setState(() {
        _entscheidungen = listeRoh
            .map((e) => _JugendEntscheidung.fromJson(e as Map<String, dynamic>))
            .toList();
        _laedt = false;
      });
    } catch (e) {
      // Fehlerbehandlung: leere Liste
      setState(() => _laedt = false);
    }
  }

  // Clique auswählen und Karma-Bonus vergeben
  void _cliqueWaehlen(_CliqueDaten clique) {
    setState(() => _gewaehlteCLique = clique);
    // Kleiner Karma-Bonus für die gewählte Clique
    ref
        .read(karmaProvider.notifier)
        .dimensionAendern(clique.karmaBonus, 5.0);

    // Kurze Pause, dann Clique-Auswahl ausblenden
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _zeigeCliqueWahl = false);
    });
  }

  // Entscheidung verarbeiten: Karma ändern, Stress anpassen, nächste laden
  Future<void> _entscheidungVerarbeiten(
      _JugendEntscheidung entscheidung, _JugendOption option) async {
    if (_verarbeiteEntscheidung) return;

    setState(() {
      _verarbeiteEntscheidung = true;
      _konsequenzText = option.sofortigeKonsequenzen.isNotEmpty
          ? option.sofortigeKonsequenzen.first
          : 'Die Wahl ist gefallen.';
    });

    // Karma für alle betroffenen Dimensionen anpassen
    double gesamtKarma = 0.0;
    option.karma.forEach((dim, delta) {
      ref.read(karmaProvider.notifier).dimensionAendern(dim, delta);
      gesamtKarma += delta;
    });
    setState(() => _letzteKarmaAenderung = gesamtKarma);

    // Stress erhöhen bei hohem systemEinflussGewicht (Systemdruck-Entscheidungen)
    final stressDelta = (option.systemEinflussGewicht * 15).round();
    setState(() {
      _stress = (_stress + stressDelta).clamp(0, 100);
    });

    // Bei hohem Stress: Puls-Animation starten
    if (_stress > 60) {
      _stressPulsController.repeat(reverse: true);
    }

    // Konsequenz 2,5 Sekunden anzeigen
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Identity-Crisis bei Alter 16 prüfen
    final naechsteEntscheidung = _aktuellerIndex + 1 < _entscheidungen.length
        ? _entscheidungen[_aktuellerIndex + 1]
        : null;
    final istIdentitaetsCrisis = naechsteEntscheidung == null ||
        (naechsteEntscheidung.alter == 16 &&
            entscheidung.alter < 16 &&
            !_identitaetsCrisisAktiv);

    if (istIdentitaetsCrisis && !_identitaetsCrisisAktiv) {
      // Identity-Crisis-Moment aktivieren
      setState(() {
        _verarbeiteEntscheidung = false;
        _identitaetsCrisisAktiv = true;
      });
      _crisisController.forward();
      return;
    }

    // Zur nächsten Entscheidung oder Phase-Ende
    if (_aktuellerIndex + 1 >= _entscheidungen.length) {
      setState(() {
        _verarbeiteEntscheidung = false;
        _phaseAbgeschlossen = true;
      });
    } else {
      setState(() {
        _verarbeiteEntscheidung = false;
        _aktuellerIndex++;
      });
    }
  }

  // Identity-Crisis-Antwort verarbeiten
  Future<void> _identitaetsAntwortWaehlen(
      _IdentitaetsAntwort antwort) async {
    // Karma-Änderungen anwenden
    antwort.karma.forEach((dim, delta) {
      ref.read(karmaProvider.notifier).dimensionAendern(dim, delta);
    });

    // Kurze Anzeige des Folge-Textes
    setState(() {
      _konsequenzText = antwort.folgeText;
      _verarbeiteEntscheidung = true;
    });

    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    // Stress um 10 abbauen (Selbsterkenntnis reduziert Stress)
    setState(() {
      _stress = (_stress - 10).clamp(0, 100);
      _identitaetsCrisisAktiv = false;
      _verarbeiteEntscheidung = false;
    });

    // Weiter mit nächster Entscheidung oder Phase-Ende
    if (_aktuellerIndex + 1 >= _entscheidungen.length) {
      setState(() => _phaseAbgeschlossen = true);
    } else {
      setState(() => _aktuellerIndex++);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Teenager-Ästhetik: dunkles Hintergrundsystem
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhasenHintergrund(phase: GamePhase.jugend),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // Halbtransparent, damit das Phasen-Artwork durchscheint
                colors: [
                  Color(0xB30A0A14), // Tiefes Schwarz-Blau (70 %)
                  Color(0x99120820), // Dunkles Lila-Schwarz (60 %)
                  Color(0xB30A0A14),
                ],
              ),
            ),
            child: SafeArea(
              child: _laedt
                  ? _LadeAnzeige()
                  : _phaseAbgeschlossen
                      ? _PhaseAbschluss(onWeiter: () {
                          // Fortschritt persistieren, dann navigieren
                          ref
                              .read(spielProvider.notifier)
                              .phasWechseln(GamePhase.erwachsen);
                          context.go('/phase/5');
                        })
                      : Column(
                          children: [
                            // Kopfzeile: Phase-Titel + Stress-Meter
                            _KopfZeile(
                              stress: _stress,
                              stressPulsAnimation: _stressPulsAnimation,
                              gewaehlteCLique: _gewaehlteCLique,
                            ),

                            // Hauptinhalt
                            Expanded(
                              child: _buildHauptinhalt(),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHauptinhalt() {
    // Clique-Auswahl zuerst anzeigen
    if (_zeigeCliqueWahl) {
      return _CliqueAuswahl(onCliqueWaehlen: _cliqueWaehlen)
          .animate()
          .fadeIn(duration: 800.ms);
    }

    // Identity-Crisis-Moment bei Alter 16
    if (_identitaetsCrisisAktiv) {
      return FadeTransition(
        opacity: _crisisAnimation,
        child: _IdentitaetsCrisisWidget(
          onAntwortWaehlen: _identitaetsAntwortWaehlen,
          verarbeitung: _verarbeiteEntscheidung,
          konsequenzText: _konsequenzText,
        ),
      );
    }

    // Keine Entscheidungen geladen
    if (_entscheidungen.isEmpty) {
      return _LeereEntscheidungen();
    }

    final aktuelleEntscheidung = _entscheidungen[_aktuellerIndex];

    // Konsequenz-Anzeige nach Auswahl
    if (_verarbeiteEntscheidung) {
      return _KonsequenzAnzeige(
        konsequenzText: _konsequenzText,
        karmaAenderung: _letzteKarmaAenderung,
      );
    }

    // Entscheidungs-Karte
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _JugendEntscheidungsKarte(
        entscheidung: aktuelleEntscheidung,
        fortschritt: _aktuellerIndex,
        gesamtAnzahl: _entscheidungen.length,
        onOptionWaehlen: (option) =>
            _entscheidungVerarbeiten(aktuelleEntscheidung, option),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _KopfZeile – Phase-Titel, Stress-Meter, Clique-Anzeige
// ─────────────────────────────────────────────────────────────────────────────

class _KopfZeile extends StatelessWidget {
  final int stress;
  final Animation<double> stressPulsAnimation;
  final _CliqueDaten? gewaehlteCLique;

  const _KopfZeile({
    required this.stress,
    required this.stressPulsAnimation,
    required this.gewaehlteCLique,
  });

  Color get _stressFarbe {
    if (stress > 70) return AppFarben.karmaNegatv;
    if (stress > 40) return AppFarben.karmaNeutral;
    return AppFarben.karmaPositiv;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        border: Border(
          bottom: BorderSide(
            color: AppFarben.mystischLila.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Phase-Titel
              Text(
                'DIE JUGEND',
                style: AppTextStyles.beschriftungGross.copyWith(
                  color: AppFarben.phaseJugend,
                  letterSpacing: 3,
                ),
              ),

              // Clique-Badge
              if (gewaehlteCLique != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gewaehlteCLique!.farbe.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: gewaehlteCLique!.farbe.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(gewaehlteCLique!.icon,
                          size: 12, color: gewaehlteCLique!.farbe),
                      const SizedBox(width: 5),
                      Text(
                        gewaehlteCLique!.name,
                        style: AppTextStyles.beschriftung
                            .copyWith(color: gewaehlteCLique!.farbe),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Stress-Meter
          Row(
            children: [
              Text(
                'STRESS',
                style: AppTextStyles.mikro.copyWith(
                  color: _stressFarbe,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedBuilder(
                  animation: stressPulsAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scaleY: stress > 60 ? stressPulsAnimation.value : 1.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: stress / 100.0,
                          minHeight: 6,
                          backgroundColor:
                              AppFarben.nebelGrau.withValues(alpha: 0.3),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_stressFarbe),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$stress%',
                style: AppTextStyles.mikro.copyWith(color: _stressFarbe),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CliqueAuswahl – Auswahl der sozialen Gruppe
// ─────────────────────────────────────────────────────────────────────────────

class _CliqueAuswahl extends StatelessWidget {
  final void Function(_CliqueDaten) onCliqueWaehlen;

  const _CliqueAuswahl({required this.onCliqueWaehlen});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Überschrift mit atmosphärischem Styling
          Text(
            'Alter 13',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.textSekundaer,
              letterSpacing: 3,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 8),

          Text(
            'Wo gehörst du hin?',
            style: AppTextStyles.ueberschrift2.copyWith(
              color: AppFarben.text,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 8),

          Text(
            'Die Schule ist ein Dschungel aus Gruppen.\nWähle die Clique, der du dich zugehörig fühlst.',
            style: AppTextStyles.koerperKursiv,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 28),

          // Cliquen-Karten
          ...List.generate(_cliquen.length, (i) {
            final clique = _cliquen[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CliqueKarte(
                clique: clique,
                onWaehlen: () => onCliqueWaehlen(clique),
              ).animate().fadeIn(delay: Duration(milliseconds: 700 + i * 120))
                  .slideX(begin: 0.05, end: 0),
            );
          }),
        ],
      ),
    );
  }
}

/// Einzelne Clique-Karte.
class _CliqueKarte extends StatefulWidget {
  final _CliqueDaten clique;
  final VoidCallback onWaehlen;

  const _CliqueKarte({required this.clique, required this.onWaehlen});

  @override
  State<_CliqueKarte> createState() => _CliqueKarteState();
}

class _CliqueKarteState extends State<_CliqueKarte> {
  bool _gedrueckt = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _gedrueckt = true),
      onTapUp: (_) {
        setState(() => _gedrueckt = false);
        widget.onWaehlen();
      },
      onTapCancel: () => setState(() => _gedrueckt = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _gedrueckt
              ? widget.clique.farbe.withValues(alpha: 0.2)
              : const Color(0xFF111118),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.clique.farbe.withValues(alpha: _gedrueckt ? 0.8 : 0.4),
            width: _gedrueckt ? 2.0 : 1.0,
          ),
          boxShadow: _gedrueckt
              ? [
                  BoxShadow(
                    color: widget.clique.farbe.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            // Clique-Icon im Kreis
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.clique.farbe.withValues(alpha: 0.15),
              ),
              child: Icon(
                widget.clique.icon,
                color: widget.clique.farbe,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Name und Beschreibung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.clique.name,
                    style: AppTextStyles.ueberschrift4.copyWith(
                      color: widget.clique.farbe,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.clique.beschreibung,
                    style: AppTextStyles.koerperKlein,
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              color: widget.clique.farbe.withValues(alpha: 0.6),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _JugendEntscheidungsKarte – Entscheidung mit Alter-Anzeige und Typ-Badge
// ─────────────────────────────────────────────────────────────────────────────

class _JugendEntscheidungsKarte extends StatelessWidget {
  final _JugendEntscheidung entscheidung;
  final int fortschritt;
  final int gesamtAnzahl;
  final void Function(_JugendOption) onOptionWaehlen;

  const _JugendEntscheidungsKarte({
    required this.entscheidung,
    required this.fortschritt,
    required this.gesamtAnzahl,
    required this.onOptionWaehlen,
  });

  // Entscheidungstyp → lesbarer Text
  String _typBezeichnung(String typ) {
    switch (typ) {
      case 'gruppenzwang':
        return 'GRUPPENZWANG';
      case 'identitaet':
        return 'IDENTITÄT';
      case 'erste_liebe':
        return 'ERSTE LIEBE';
      case 'dilemma':
        return 'DILEMMA';
      case 'schulstress':
        return 'SCHULSTRESS';
      case 'rebellion':
        return 'REBELLION';
      case 'ehrlichkeit':
        return 'EHRLICHKEIT';
      case 'mut':
        return 'MUT';
      default:
        return typ.toUpperCase();
    }
  }

  // Typ → Akzentfarbe
  Color _typFarbe(String typ) {
    switch (typ) {
      case 'gruppenzwang':
        return const Color(0xFF9C27B0);
      case 'identitaet':
        return const Color(0xFF2196F3);
      case 'erste_liebe':
        return const Color(0xFFE91E63);
      case 'dilemma':
        return const Color(0xFFFF9800);
      case 'schulstress':
        return const Color(0xFF9E9E9E);
      case 'rebellion':
        return const Color(0xFFF44336);
      default:
        return AppFarben.goldGlanz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final akzent = _typFarbe(entscheidung.typ);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Alter und Fortschritts-Leiste
        Row(
          children: [
            Text(
              'Alter ${entscheidung.alter}',
              style: AppTextStyles.spielStatus.copyWith(
                color: AppFarben.phaseJugend,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              '${fortschritt + 1} / $gesamtAnzahl',
              style: AppTextStyles.beschriftung,
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Fortschrittsbalken
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (fortschritt + 1) / gesamtAnzahl,
            minHeight: 3,
            backgroundColor: AppFarben.nebelGrau.withValues(alpha: 0.3),
            valueColor:
                AlwaysStoppedAnimation<Color>(AppFarben.phaseJugend),
          ),
        ),

        const SizedBox(height: 20),

        // Entscheidungs-Karte
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E1C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: akzent.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: akzent.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Typ-Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: akzent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: akzent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _typBezeichnung(entscheidung.typ),
                  style: AppTextStyles.mikro.copyWith(
                    color: akzent,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Kontext
              Text(
                entscheidung.kontext,
                style: AppTextStyles.koerperKursiv,
              ).animate().fadeIn(duration: 600.ms),

              // Systemeinflüsse (kleine Badges)
              if (entscheidung.systemEinfluesse.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: entscheidung.systemEinfluesse
                      .map((einfluss) => _SystemEinflussBadge(text: einfluss))
                      .toList(),
                ),
              ],

              const SizedBox(height: 16),

              // Divider
              Container(
                height: 1,
                color: akzent.withValues(alpha: 0.2),
              ),

              const SizedBox(height: 16),

              // Frage
              Text(
                entscheidung.frage,
                style: AppTextStyles.ueberschrift4.copyWith(
                  color: AppFarben.text,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 20),

              // Optionen
              ...List.generate(entscheidung.optionen.length, (i) {
                final option = entscheidung.optionen[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OptionSchaltflaeche(
                    option: option,
                    onWaehlen: () => onOptionWaehlen(option),
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: 300 + i * 120),
                      ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

/// Badge für Systemeinflüsse (z.B. "Gruppenzwang", "Indoktrination").
class _SystemEinflussBadge extends StatelessWidget {
  final String text;
  const _SystemEinflussBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppFarben.mystischLila.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppFarben.mystischLila.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text.replaceAll('_', ' '),
        style: AppTextStyles.mikro.copyWith(
          color: AppFarben.mystischLila.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

/// Einzelne Option als tippbare Schaltfläche.
class _OptionSchaltflaeche extends StatefulWidget {
  final _JugendOption option;
  final VoidCallback onWaehlen;

  const _OptionSchaltflaeche({required this.option, required this.onWaehlen});

  @override
  State<_OptionSchaltflaeche> createState() => _OptionSchaltflaecheState();
}

class _OptionSchaltflaecheState extends State<_OptionSchaltflaeche> {
  bool _gedrueckt = false;

  // Berechnet den Gesamt-Karma-Wert der Option für Farb-Vorschau
  double get _karmaGesamt =>
      widget.option.karma.values.fold(0.0, (s, v) => s + v);

  Color get _karmaFarbe {
    if (_karmaGesamt > 5) return AppFarben.karmaPositiv;
    if (_karmaGesamt < -5) return AppFarben.karmaNegatv;
    return AppFarben.karmaNeutral;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _gedrueckt = true),
      onTapUp: (_) {
        setState(() => _gedrueckt = false);
        widget.onWaehlen();
      },
      onTapCancel: () => setState(() => _gedrueckt = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _gedrueckt
              ? _karmaFarbe.withValues(alpha: 0.12)
              : const Color(0xFF141420),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                _gedrueckt ? _karmaFarbe : AppFarben.nebelGrau.withValues(alpha: 0.4),
            width: _gedrueckt ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.option.text,
                style: AppTextStyles.entscheidung,
              ),
            ),

            const SizedBox(width: 8),

            // Karma-Vorschau
            Text(
              '${_karmaGesamt >= 0 ? '+' : ''}${_karmaGesamt.toStringAsFixed(0)}',
              style: AppTextStyles.beschriftung.copyWith(
                color: _karmaFarbe,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _IdentitaetsCrisisWidget – Der "Wer bin ich?"-Moment bei Alter 16
// ─────────────────────────────────────────────────────────────────────────────

class _IdentitaetsCrisisWidget extends StatelessWidget {
  final void Function(_IdentitaetsAntwort) onAntwortWaehlen;
  final bool verarbeitung;
  final String konsequenzText;

  const _IdentitaetsCrisisWidget({
    required this.onAntwortWaehlen,
    required this.verarbeitung,
    required this.konsequenzText,
  });

  @override
  Widget build(BuildContext context) {
    if (verarbeitung) {
      // Folge-Text nach Antwort anzeigen
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.self_improvement,
                color: AppFarben.goldGlanz,
                size: 48,
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                konsequenzText,
                style: AppTextStyles.koerperGross.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppFarben.text,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Alter-Angabe
          Text(
            'ALTER 16 – IDENTITY CRISIS',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.karmaNegatv.withValues(alpha: 0.8),
              letterSpacing: 2,
            ),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 20),

          // Große Frage mit dramatischem Styling
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppFarben.mystischLila.withValues(alpha: 0.3),
                  const Color(0xFF0A0A14),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppFarben.mystischLila.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Puls-Icon
                const Icon(
                  Icons.psychology,
                  color: AppFarben.mystischLila,
                  size: 40,
                ).animate().shimmer(
                      duration: 2000.ms,
                      color: AppFarben.goldGlanz.withValues(alpha: 0.4),
                    ),

                const SizedBox(height: 20),

                Text(
                  'Wer bin ich?',
                  style: AppTextStyles.ueberschrift1.copyWith(
                    fontSize: 38,
                    color: AppFarben.text,
                    shadows: [
                      Shadow(
                        color:
                            AppFarben.mystischLila.withValues(alpha: 0.8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 12),

                Text(
                  'Du sitzt allein in deinem Zimmer. '
                  'Die Welt draußen rauscht.\n'
                  'Zum ersten Mal spürst du: Diese Frage braucht eine Antwort.',
                  style: AppTextStyles.koerperKursiv.copyWith(height: 1.7),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Antwort-Optionen
          ...List.generate(_identitaetsAntworten.length, (i) {
            final antwort = _identitaetsAntworten[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _IdentitaetsAntwortKarte(
                antwort: antwort,
                onWaehlen: () => onAntwortWaehlen(antwort),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 800 + i * 150),
                  ),
            );
          }),
        ],
      ),
    );
  }
}

/// Einzelne Antwort-Karte für den Identity-Crisis-Moment.
class _IdentitaetsAntwortKarte extends StatefulWidget {
  final _IdentitaetsAntwort antwort;
  final VoidCallback onWaehlen;

  const _IdentitaetsAntwortKarte({
    required this.antwort,
    required this.onWaehlen,
  });

  @override
  State<_IdentitaetsAntwortKarte> createState() =>
      _IdentitaetsAntwortKarteState();
}

class _IdentitaetsAntwortKarteState extends State<_IdentitaetsAntwortKarte> {
  bool _gedrueckt = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _gedrueckt = true),
      onTapUp: (_) {
        setState(() => _gedrueckt = false);
        widget.onWaehlen();
      },
      onTapCancel: () => setState(() => _gedrueckt = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _gedrueckt
              ? AppFarben.goldGlanz.withValues(alpha: 0.1)
              : const Color(0xFF0E0E1C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _gedrueckt
                ? AppFarben.goldGlanz.withValues(alpha: 0.6)
                : AppFarben.nebelGrau.withValues(alpha: 0.4),
          ),
          boxShadow: _gedrueckt
              ? [
                  BoxShadow(
                    color: AppFarben.goldGlanz.withValues(alpha: 0.2),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
        child: Text(
          widget.antwort.text,
          style: AppTextStyles.koerper.copyWith(
            fontStyle: FontStyle.italic,
            color: _gedrueckt ? AppFarben.goldGlanz : AppFarben.text,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _KonsequenzAnzeige – Sofortige Rückmeldung nach Entscheidung
// ─────────────────────────────────────────────────────────────────────────────

class _KonsequenzAnzeige extends StatelessWidget {
  final String konsequenzText;
  final double karmaAenderung;

  const _KonsequenzAnzeige({
    required this.konsequenzText,
    required this.karmaAenderung,
  });

  @override
  Widget build(BuildContext context) {
    final istPositiv = karmaAenderung >= 0;
    final farbe = istPositiv ? AppFarben.karmaPositiv : AppFarben.karmaNegatv;
    final prefix = istPositiv ? '+' : '';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Karma-Änderungs-Anzeige
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: farbe.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: farbe.withValues(alpha: 0.5)),
              ),
              child: Text(
                '$prefix${karmaAenderung.toStringAsFixed(0)} Karma',
                style: AppTextStyles.spielStatus.copyWith(color: farbe),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

            const SizedBox(height: 28),

            // Konsequenz-Text
            Text(
              konsequenzText,
              style: AppTextStyles.koerperGross.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms, duration: 700.ms),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hilfswi dgets
// ─────────────────────────────────────────────────────────────────────────────

/// Ladeindikator während die JSON-Datei geladen wird.
class _LadeAnzeige extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppFarben.mystischLila),
    );
  }
}

/// Anzeige wenn keine Entscheidungen geladen wurden (Fehlerfall).
class _LeereEntscheidungen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Keine Entscheidungen verfügbar.',
        style: AppTextStyles.koerperKlein,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PhaseAbschluss – Ende der Jugend-Phase
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseAbschluss extends StatelessWidget {
  final VoidCallback onWeiter;

  const _PhaseAbschluss({required this.onWeiter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Abschluss-Symbol
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppFarben.phaseJugend.withValues(alpha: 0.4),
                    const Color(0xFF0A0A14),
                  ],
                ),
                border: Border.all(
                  color: AppFarben.phaseJugend.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.arrow_upward,
                color: AppFarben.phaseJugend,
                size: 40,
              ),
            ).animate().scale(duration: 700.ms, curve: Curves.elasticOut),

            const SizedBox(height: 28),

            Text(
              'Die Jugend liegt hinter dir.',
              style: AppTextStyles.ueberschrift3,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 12),

            Text(
              'Du bist geformt worden – durch Entscheidungen,\n'
              'durch Schmerz, durch erste Lieben und Verluste.\n'
              'Das Erwachsensein wartet.',
              style: AppTextStyles.koerperKursiv.copyWith(height: 1.8),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 40),

            // Weiter-Button
            GestureDetector(
              onTap: onWeiter,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppFarben.phaseJugend.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppFarben.phaseJugend.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'INS ERWACHSENENLEBEN',
                  style: AppTextStyles.buttonPrimaer.copyWith(
                    color: AppFarben.phaseJugend,
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}
