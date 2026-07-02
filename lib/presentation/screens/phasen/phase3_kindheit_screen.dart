// phase3_kindheit_screen.dart
// Phase 3: Die Kindheit – Alters-Progression 0–12 Jahre.
// Entscheidungsdaten werden aus assets/data/entscheidungen/kindheit.json geladen.
// Enthält: Laufen-Lernen-Sequenz (1–2 Jahre), Sprach-Entwicklung (2–4 Jahre),
// Entscheidungs-Karten für kindheitliche Weichenstellungen (5–12 Jahre).

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/karma_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/genesis_button.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Lokale JSON-Modelle für kindheit.json (ohne build_runner / json_serializable)
// ─────────────────────────────────────────────────────────────────────────────

/// Einzelne Antwort-Option aus kindheit.json
class _JsonOption {
  final String id;
  final String text;

  /// Karma-Auswirkungen: Schlüssel = KarmaDimension-Name, Wert = double
  final Map<String, double> karma;
  final List<String> sofortigeKonsequenzen;
  final List<String> verzoegerteKonsequenzen;
  final double egoistischAltruistisch;

  const _JsonOption({
    required this.id,
    required this.text,
    required this.karma,
    required this.sofortigeKonsequenzen,
    required this.verzoegerteKonsequenzen,
    required this.egoistischAltruistisch,
  });

  factory _JsonOption.fromJson(Map<String, dynamic> json) {
    // karma-Feld: Map<String, int/double>
    final karmaRaw = json['karma'] as Map<String, dynamic>? ?? {};
    final karmaMap = karmaRaw.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return _JsonOption(
      id: json['id'] as String,
      text: json['text'] as String,
      karma: karmaMap,
      sofortigeKonsequenzen: List<String>.from(
        json['sofortigeKonsequenzen'] as List? ?? [],
      ),
      verzoegerteKonsequenzen: List<String>.from(
        json['verzoegerteKonsequenzen'] as List? ?? [],
      ),
      egoistischAltruistisch:
          (json['egoistischAltruistisch'] as num?)?.toDouble() ?? 0.5,
    );
  }
}

/// Eine Entscheidung aus kindheit.json
class _JsonEntscheidung {
  final String id;
  final int alter;
  final String kontext;
  final String frage;
  final List<_JsonOption> optionen;

  const _JsonEntscheidung({
    required this.id,
    required this.alter,
    required this.kontext,
    required this.frage,
    required this.optionen,
  });

  factory _JsonEntscheidung.fromJson(Map<String, dynamic> json) {
    final optionenRaw = json['optionen'] as List? ?? [];
    return _JsonEntscheidung(
      id: json['id'] as String,
      alter: (json['alter'] as num).toInt(),
      kontext: json['kontext'] as String,
      frage: json['frage'] as String,
      optionen: optionenRaw
          .map((o) => _JsonOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hilfsfunktion: String → KarmaDimension
// ─────────────────────────────────────────────────────────────────────────────

KarmaDimension? _dimensionAusString(String name) {
  switch (name) {
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
// Phase 3 Kindheit Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Haupt-Screen für Phase 3: Die Kindheit.
///
/// Lädt Entscheidungen aus assets/data/entscheidungen/kindheit.json.
/// Zeigt eine Alters-Progression von 0–12 Jahren mit altersabhängigen
/// Entscheidungskarten, Karma-Feedback und Minigames.
class Phase3KindheitScreen extends ConsumerStatefulWidget {
  const Phase3KindheitScreen({super.key});

  @override
  ConsumerState<Phase3KindheitScreen> createState() =>
      _Phase3KindheitScreenState();
}

class _Phase3KindheitScreenState extends ConsumerState<Phase3KindheitScreen>
    with TickerProviderStateMixin {
  // Aktuell angezeigtes Jahr (0–12)
  int _aktuellesJahr = 0;

  // Geladene JSON-Entscheidungen, gruppiert nach Alter
  Map<int, List<_JsonEntscheidung>> _entscheidungenNachAlter = {};

  // Geladene Entscheidungen (alle)
  List<_JsonEntscheidung> _alleEntscheidungen = [];

  // Lade-Zustand
  bool _laedt = true;
  String? _ladefehler;

  // Welche Entscheidungen wurden bereits getroffen (id → gewählter Index)
  final Map<String, int> _getroffeneEntscheidungen = {};

  // Karma-Feedback-Anzeige
  _KarmaFeedback? _aktivesFeedback;

  // Minigame-Status
  bool _laufenAbgeschlossen = false;
  bool _sprachAbgeschlossen = false;

  // Prüfung "Der erste Verlust" – darf nur einmal pro Kindheit ausgelöst werden
  bool _verlustErlebt = false;

  // Scroll-Controller für Jahres-Navigation
  final PageController _jahresController = PageController();

  // Aktueller Modus: 0 = Jahres-Übersicht, 1 = Minigame, 2 = Entscheidung, 3 = Karma-Feedback
  int _modus = 0;

  // Aktive Entscheidung (JSON-Version)
  _JsonEntscheidung? _aktiveEntscheidung;

  // Aktives Minigame (0 = keins, 1 = Laufen, 2 = Sprache)
  int _aktivesMinigame = 0;

  @override
  void initState() {
    super.initState();
    _jsonLaden();
  }

  @override
  void dispose() {
    _jahresController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // JSON laden
  // ─────────────────────────────────────────────────────────────────────────

  /// Lädt kindheit.json aus den Assets und parst alle Entscheidungen.
  Future<void> _jsonLaden() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/data/entscheidungen/kindheit.json');
      final jsonDaten = json.decode(jsonString) as Map<String, dynamic>;
      final entscheidungenRaw =
          jsonDaten['entscheidungen'] as List? ?? [];

      final geladen = entscheidungenRaw
          .map((e) =>
              _JsonEntscheidung.fromJson(e as Map<String, dynamic>))
          .toList();

      // Nach Alter gruppieren
      final nachAlter = <int, List<_JsonEntscheidung>>{};
      for (final e in geladen) {
        nachAlter.putIfAbsent(e.alter, () => []).add(e);
      }

      if (mounted) {
        setState(() {
          _alleEntscheidungen = geladen;
          _entscheidungenNachAlter = nachAlter;
          _laedt = false;
        });
      }
    } catch (fehler) {
      if (mounted) {
        setState(() {
          _ladefehler = fehler.toString();
          _laedt = false;
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navigation
  // ─────────────────────────────────────────────────────────────────────────

  void _jahrWechseln(int jahr) {
    setState(() => _aktuellesJahr = jahr);
    _jahresController.animateToPage(
      jahr,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    ref.read(spielProvider.notifier).alterErhoehen();

    // Unvermeidbare Prüfung "Der erste Verlust" beim Erreichen des 8. Lebensjahres.
    if (jahr == 8 && !_verlustErlebt) {
      _verlustErlebt = true;
      _ersterVerlustStarten();
    }
  }

  /// Startet die Verlust-Sequenz (Route '/phase/3/verlust').
  ///
  /// WICHTIG: Der Verlust-Screen endet selbst mit
  /// `context.go(AppRouten.phase4)` ("Das Leben geht weiter") – er kehrt also
  /// nach Abschluss NICHT hierher zurück, sondern beendet die Kindheit.
  /// Deshalb wird hier trotzdem `context.push` verwendet: Bricht der Spieler
  /// die Sequenz per Zurück-Geste ab, landet er wieder in der Kindheit
  /// (Jahr 8) und der Verlust wird dank [_verlustErlebt] nicht erneut gestartet.
  ///
  /// Der Verlust-Screen wendet sein Karma selbst nicht an (seine
  /// `_karmaAnwenden`-Methode ist ein Stub) und protokolliert keine
  /// Entscheidung. Beides wird daher hier ergänzt: eine gemittelte
  /// Basis-Karma-Wirkung (die konkrete Reaktions-Wahl ist von außen nicht
  /// beobachtbar) und ein Protokoll-Eintrag für die Lebens-Bilanz.
  void _ersterVerlustStarten() {
    final karmaNotifier = ref.read(karmaProvider.notifier);
    karmaNotifier.dimensionAendern(KarmaDimension.mitgefuehl, 4.0);
    karmaNotifier.dimensionAendern(KarmaDimension.weisheit, 3.0);
    ref
        .read(spielProvider.notifier)
        .entscheidungTreffen('kindheit_08_erster_verlust', 0);

    context.push('/phase/3/verlust');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Entscheidungen
  // ─────────────────────────────────────────────────────────────────────────

  void _entscheidungStarten(_JsonEntscheidung entscheidung) {
    setState(() {
      _aktiveEntscheidung = entscheidung;
      _modus = 2;
    });
  }

  void _entscheidungAbgeschlossen(int optionIndex) {
    if (_aktiveEntscheidung == null) return;
    if (optionIndex < 0) {
      // Zurück ohne Entscheidung
      setState(() {
        _aktiveEntscheidung = null;
        _modus = 0;
      });
      return;
    }

    final entscheidung = _aktiveEntscheidung!;
    if (optionIndex >= entscheidung.optionen.length) return;

    final gewaehlt = entscheidung.optionen[optionIndex];

    // Karma-Änderungen anwenden
    final karmaDimensionen = <KarmaDimension, double>{};
    gewaehlt.karma.forEach((key, wert) {
      final dim = _dimensionAusString(key);
      if (dim != null) {
        ref.read(karmaProvider.notifier).dimensionAendern(dim, wert);
        karmaDimensionen[dim] = wert;
      }
    });

    // Spiel-Provider informieren
    ref.read(spielProvider.notifier).entscheidungTreffen(
      entscheidung.id,
      optionIndex,
    );

    setState(() {
      _getroffeneEntscheidungen[entscheidung.id] = optionIndex;
      _aktiveEntscheidung = null;
      _modus = 3; // Karma-Feedback anzeigen
      _aktivesFeedback = _KarmaFeedback(
        optionText: gewaehlt.text,
        konsequenz: gewaehlt.sofortigeKonsequenzen.isNotEmpty
            ? gewaehlt.sofortigeKonsequenzen.first
            : '',
        karmaDimensionen: karmaDimensionen,
        egoistischAltruistisch: gewaehlt.egoistischAltruistisch,
      );
    });
  }

  void _feedbackSchliessen() {
    setState(() {
      _aktivesFeedback = null;
      _modus = 0;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Minigames
  // ─────────────────────────────────────────────────────────────────────────

  void _minigameStarten(int minigameId) {
    setState(() {
      _aktivesMinigame = minigameId;
      _modus = 1;
    });
  }

  void _minigameAbgeschlossen() {
    setState(() {
      if (_aktivesMinigame == 1) _laufenAbgeschlossen = true;
      if (_aktivesMinigame == 2) _sprachAbgeschlossen = true;
      _aktivesMinigame = 0;
      _modus = 0;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Entscheidungen für das aktuelle Jahr
  // ─────────────────────────────────────────────────────────────────────────

  List<_JsonEntscheidung> get _jahresEntscheidungen {
    if (_aktuellesJahr < 5) return [];
    final fuerJahr =
        _entscheidungenNachAlter[_aktuellesJahr] ?? [];
    return fuerJahr
        .where((e) => !_getroffeneEntscheidungen.containsKey(e.id))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Lade-Spinner
    if (_laedt) {
      return Scaffold(
        backgroundColor: AppFarben.kosmischSchwarz,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppFarben.phaseKindheit,
              ),
              const SizedBox(height: 16),
              Text(
                'Kindheitserinnerungen laden...',
                style: AppTextStyles.koerperKlein.copyWith(
                  color: AppFarben.textSekundaer,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Fehler-Ansicht
    if (_ladefehler != null) {
      return Scaffold(
        backgroundColor: AppFarben.kosmischSchwarz,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AppFarben.karmaNegatv, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Fehler beim Laden der Entscheidungen.',
                  style: AppTextStyles.koerper.copyWith(
                    color: AppFarben.karmaNegatv,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GenesisButton(
                  text: 'Trotzdem weiterspielen',
                  onPressed: () {
                    // Fortschritt persistieren, dann navigieren
                    ref
                        .read(spielProvider.notifier)
                        .phasWechseln(GamePhase.jugend);
                    context.go(AppRouten.phase4);
                  },
                  typ: GenesisButtonTyp.sekundaer,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhasenHintergrund(phase: GamePhase.kindheit),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: switch (_modus) {
                1 => _MinigameWrapper(
                    key: const ValueKey('minigame'),
                    minigameId: _aktivesMinigame,
                    onAbgeschlossen: _minigameAbgeschlossen,
                  ),
                2 => _EntscheidungsWrapper(
                    key: const ValueKey('entscheidung'),
                    entscheidung: _aktiveEntscheidung!,
                    onAbgeschlossen: _entscheidungAbgeschlossen,
                  ),
                3 => _KarmaFeedbackOverlay(
                    key: const ValueKey('feedback'),
                    feedback: _aktivesFeedback!,
                    onWeiter: _feedbackSchliessen,
                  ),
                _ => _JahresHauptansicht(
                    key: const ValueKey('hauptansicht'),
                    aktuellesJahr: _aktuellesJahr,
                    jahresController: _jahresController,
                    jahresEntscheidungen: _jahresEntscheidungen,
                    laufenAbgeschlossen: _laufenAbgeschlossen,
                    sprachAbgeschlossen: _sprachAbgeschlossen,
                    onJahrWechseln: _jahrWechseln,
                    onEntscheidungStarten: _entscheidungStarten,
                    onMinigameStarten: _minigameStarten,
                    onPhaseAbschliessen: () {
                      // Fortschritt persistieren, dann navigieren
                      ref
                          .read(spielProvider.notifier)
                          .phasWechseln(GamePhase.jugend);
                      context.go(AppRouten.phase4);
                    },
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Karma-Feedback Daten-Klasse
// ─────────────────────────────────────────────────────────────────────────────

class _KarmaFeedback {
  final String optionText;
  final String konsequenz;
  final Map<KarmaDimension, double> karmaDimensionen;
  final double egoistischAltruistisch;

  const _KarmaFeedback({
    required this.optionText,
    required this.konsequenz,
    required this.karmaDimensionen,
    required this.egoistischAltruistisch,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Karma-Feedback Overlay
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt nach einer Entscheidung das Karma-Feedback an.
/// Buntes, kindgerechtes Design mit animierten Karma-Balken.
class _KarmaFeedbackOverlay extends StatelessWidget {
  final _KarmaFeedback feedback;
  final VoidCallback onWeiter;

  const _KarmaFeedbackOverlay({
    super.key,
    required this.feedback,
    required this.onWeiter,
  });

  @override
  Widget build(BuildContext context) {
    // Positive und negative Karma-Änderungen trennen
    final positiv = feedback.karmaDimensionen.entries
        .where((e) => e.value > 0)
        .toList();
    final negativ = feedback.karmaDimensionen.entries
        .where((e) => e.value < 0)
        .toList();

    final istMehrheitlichPositiv =
        positiv.fold(0.0, (sum, e) => sum + e.value) >
            negativ.fold(0.0, (sum, e) => sum + e.value.abs());

    final hauptfarbe = istMehrheitlichPositiv
        ? AppFarben.karmaPositiv
        : AppFarben.karmaNegatv;

    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Ergebnis-Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hauptfarbe.withValues(alpha: 0.15),
                  border: Border.all(color: hauptfarbe.withValues(alpha: 0.5), width: 2),
                ),
                child: Icon(
                  istMehrheitlichPositiv ? Icons.favorite : Icons.sentiment_dissatisfied,
                  color: hauptfarbe,
                  size: 36,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.5, 0.5)),

              const SizedBox(height: 20),

              // Gewählte Option
              Text(
                '"${feedback.optionText}"',
                style: AppTextStyles.koerperKursiv.copyWith(
                  color: AppFarben.text.withValues(alpha: 0.85),
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              // Sofortige Konsequenz
              if (feedback.konsequenz.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppFarben.oberflaecheErhoben.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppFarben.nebelGrau.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    feedback.konsequenz,
                    style: AppTextStyles.koerper.copyWith(
                      color: AppFarben.textSekundaer,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Karma-Dimensionen Anzeige
              if (feedback.karmaDimensionen.isNotEmpty) ...[
                Text(
                  'Karma-Auswirkung',
                  style: AppTextStyles.beschriftungGross.copyWith(
                    color: AppFarben.goldGlanz.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 12),

                ...feedback.karmaDimensionen.entries
                    .toList()
                    .asMap()
                    .entries
                    .map((eintrag) {
                  final delay = 600 + eintrag.key * 100;
                  final dim = eintrag.value.key;
                  final wert = eintrag.value.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _KarmaBalken(
                      dimension: dim,
                      wert: wert,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: delay))
                      .slideX(begin: wert > 0 ? -0.2 : 0.2);
                }),
              ],

              const Spacer(),

              // Weiter-Button
              GenesisButton(
                text: 'Weiter',
                onPressed: onWeiter,
                icon: Icons.arrow_forward,
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

/// Einzelner animierter Karma-Balken im Feedback-Screen.
class _KarmaBalken extends StatelessWidget {
  final KarmaDimension dimension;
  final double wert;

  const _KarmaBalken({required this.dimension, required this.wert});

  String get _dimensionsName {
    switch (dimension) {
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

  Color get _farbe => wert >= 0 ? AppFarben.karmaPositiv : AppFarben.karmaNegatv;

  @override
  Widget build(BuildContext context) {
    final anzeigeWert = wert.abs().clamp(0.0, 100.0);
    final fortschritt = anzeigeWert / 20.0; // max 20 pro Entscheidung

    return Row(
      children: [
        // Dimensions-Name
        SizedBox(
          width: 110,
          child: Text(
            _dimensionsName,
            style: AppTextStyles.beschriftung.copyWith(
              color: AppFarben.textSekundaer,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Balken
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fortschritt.clamp(0.0, 1.0),
              backgroundColor: AppFarben.nebelGrau.withValues(alpha: 0.2),
              color: _farbe,
              minHeight: 8,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Delta-Wert
        SizedBox(
          width: 36,
          child: Text(
            '${wert >= 0 ? '+' : ''}${wert.toInt()}',
            style: AppTextStyles.beschriftung.copyWith(
              color: _farbe,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Haupt-Jahres-Ansicht
// ─────────────────────────────────────────────────────────────────────────────

class _JahresHauptansicht extends StatelessWidget {
  final int aktuellesJahr;
  final PageController jahresController;
  final List<_JsonEntscheidung> jahresEntscheidungen;
  final bool laufenAbgeschlossen;
  final bool sprachAbgeschlossen;
  final Function(int) onJahrWechseln;
  final Function(_JsonEntscheidung) onEntscheidungStarten;
  final Function(int) onMinigameStarten;
  final VoidCallback onPhaseAbschliessen;

  const _JahresHauptansicht({
    super.key,
    required this.aktuellesJahr,
    required this.jahresController,
    required this.jahresEntscheidungen,
    required this.laufenAbgeschlossen,
    required this.sprachAbgeschlossen,
    required this.onJahrWechseln,
    required this.onEntscheidungStarten,
    required this.onMinigameStarten,
    required this.onPhaseAbschliessen,
  });

  // Blur-Stärke: bei Alter 0 maximal, bei Alter 12 minimal
  double get _blurSigma => (8.0 * (1.0 - aktuellesJahr / 12.0)).clamp(0.0, 8.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header mit Altersanzeige
        _KindheitHeader(aktuellesJahr: aktuellesJahr),

        // Horizontal scrollbare Jahres-Navigation
        _JahresNavigationsLeiste(
          aktuellesJahr: aktuellesJahr,
          onJahrWechseln: onJahrWechseln,
        ),

        // Hauptinhalt mit Blur-Effekt (simuliert verschwommene Kindheitswahrnehmung)
        Expanded(
          child: Stack(
            children: [
              // Farbiger Hintergrund
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppFarben.phaseKindheit.withValues(alpha: 0.08),
                      AppFarben.kosmischSchwarz,
                    ],
                  ),
                ),
              ),

              // Blur-Overlay (nimmt mit dem Alter ab)
              if (_blurSigma > 0.5)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _blurSigma,
                      sigmaY: _blurSigma,
                    ),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),

              // Scroll-Inhalt
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Jahres-Beschreibung
                    _JahresBeschreibung(jahr: aktuellesJahr),

                    const SizedBox(height: 16),

                    // Minigame-Karte: Laufen Lernen (Jahr 1–2)
                    if (aktuellesJahr >= 1 && aktuellesJahr <= 2 && !laufenAbgeschlossen)
                      _MinigameKarte(
                        titel: 'Laufen Lernen',
                        beschreibung: 'Dein Körper lernt sich zu bewegen.',
                        icon: Icons.directions_walk,
                        farbe: AppFarben.phaseKindheit,
                        onStarten: () => onMinigameStarten(1),
                      ).animate().fadeIn().slideY(begin: 0.1),

                    // Minigame-Karte: Sprach-Entwicklung (Jahr 2–4)
                    if (aktuellesJahr >= 2 && aktuellesJahr <= 4 && !sprachAbgeschlossen)
                      _MinigameKarte(
                        titel: 'Sprache Entwickeln',
                        beschreibung: 'Erste Worte, dann Sätze, dann Gedanken.',
                        icon: Icons.record_voice_over,
                        farbe: const Color(0xFF66BB6A),
                        onStarten: () => onMinigameStarten(2),
                      ).animate().fadeIn().slideY(begin: 0.1),

                    // Entscheidungskarten aus JSON (altersabhängig, bunte runde Karten)
                    for (final entscheidung in jahresEntscheidungen) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => onEntscheidungStarten(entscheidung),
                        child: _EntscheidungsVorschauKarte(
                          entscheidung: entscheidung,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    ],

                    const SizedBox(height: 24),

                    // Nächstes Jahr / Phase abschließen
                    if (aktuellesJahr < 12)
                      GenesisButton(
                        text: 'Jahr ${aktuellesJahr + 1} beginnt',
                        onPressed: () => onJahrWechseln(aktuellesJahr + 1),
                        typ: GenesisButtonTyp.sekundaer,
                        icon: Icons.arrow_forward,
                      )
                    else
                      GenesisButton(
                        text: 'Die Kindheit endet – Jugend beginnt',
                        onPressed: onPhaseAbschliessen,
                        icon: Icons.trending_up,
                      ).animate().fadeIn().scale(),
                  ],
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
// Kindheit-Header
// ─────────────────────────────────────────────────────────────────────────────

class _KindheitHeader extends StatelessWidget {
  final int aktuellesJahr;

  const _KindheitHeader({required this.aktuellesJahr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppFarben.tiefesBlau.withValues(alpha: 0.7),
        border: Border(
          bottom: BorderSide(
            color: AppFarben.phaseKindheit.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Phasen-Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppFarben.phaseKindheit.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_friendly,
              color: AppFarben.phaseKindheit,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PHASE III – DIE KINDHEIT',
                style: AppTextStyles.beschriftungGross.copyWith(
                  color: AppFarben.phaseKindheit,
                  letterSpacing: 2,
                ),
              ),
              Text(
                aktuellesJahr == 0
                    ? 'Neugeboren'
                    : '$aktuellesJahr Jahr${aktuellesJahr == 1 ? '' : 'e'} alt',
                style: AppTextStyles.koerperKlein,
              ),
            ],
          ),

          const Spacer(),

          // Fortschrittsanzeige
          Text(
            '${aktuellesJahr}/12',
            style: AppTextStyles.spielStatusWert.copyWith(
              color: AppFarben.phaseKindheit,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Jahres-Navigationsleiste
// ─────────────────────────────────────────────────────────────────────────────

class _JahresNavigationsLeiste extends StatelessWidget {
  final int aktuellesJahr;
  final Function(int) onJahrWechseln;

  const _JahresNavigationsLeiste({
    required this.aktuellesJahr,
    required this.onJahrWechseln,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: 13, // Jahre 0–12
        itemBuilder: (context, index) {
          final istAktuell = index == aktuellesJahr;
          final istVergangen = index < aktuellesJahr;

          return GestureDetector(
            onTap: istVergangen || istAktuell ? () => onJahrWechseln(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: istAktuell
                    ? AppFarben.phaseKindheit.withValues(alpha: 0.3)
                    : (istVergangen
                        ? AppFarben.oberflaecheErhoben
                        : AppFarben.kosmischSchwarz.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: istAktuell
                      ? AppFarben.phaseKindheit
                      : (istVergangen
                          ? AppFarben.nebelGrau.withValues(alpha: 0.4)
                          : AppFarben.nebelGrau.withValues(alpha: 0.2)),
                ),
              ),
              child: Text(
                index == 0 ? 'Baby' : 'Jahr $index',
                style: AppTextStyles.beschriftung.copyWith(
                  color: istAktuell
                      ? AppFarben.phaseKindheit
                      : (istVergangen
                          ? AppFarben.textSekundaer
                          : AppFarben.textDeaktiviert),
                  fontWeight: istAktuell ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Jahres-Beschreibung
// ─────────────────────────────────────────────────────────────────────────────

class _JahresBeschreibung extends StatelessWidget {
  final int jahr;

  const _JahresBeschreibung({required this.jahr});

  String get _beschreibung {
    if (jahr == 0) return 'Du hast gerade die Welt erblickt. Alles ist Licht und Lärm und Wärme.';
    if (jahr == 1) return 'Du lernst krabbeln. Die Welt ist riesig und voller Wunder.';
    if (jahr == 2) return 'Erste Worte kommen zögerlich. "Mama." "Nein." "Mehr."';
    if (jahr == 3) return 'Du stellst tausend Fragen. Warum? Und warum? Und nochmal warum?';
    if (jahr == 4) return 'Der Kindergarten. Neue Gesichter. Erste Freundschaften.';
    if (jahr == 5) return 'Du lernst, dass es Regeln gibt. Und dass man sie manchmal brechen kann.';
    if (jahr == 6) return 'Die Schule beginnt. Buchstaben werden zu Worten zu Geschichten.';
    if (jahr == 7) return 'Du hast deinen besten Freund. Ihr seid unzertrennlich.';
    if (jahr == 8) return 'Die Welt wird komplizierter. Nicht alles ist gut oder böse.';
    if (jahr == 9) return 'Du entdeckst eine Leidenschaft. Irgendetwas, das sich richtig anfühlt.';
    if (jahr == 10) return 'Zehn Jahre. Du beginnst, über die Zukunft nachzudenken.';
    if (jahr == 11) return 'Manchmal vermisst du, einfach nur Kind zu sein.';
    return 'Zwölf Jahre. Die Kindheit endet. Etwas Neues beginnt.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppFarben.oberflaecheErhoben.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppFarben.phaseKindheit.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        _beschreibung,
        style: AppTextStyles.koerperKursiv.copyWith(
          color: AppFarben.text.withValues(alpha: 0.9),
          height: 1.7,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Minigame-Vorschau-Karte
// ─────────────────────────────────────────────────────────────────────────────

class _MinigameKarte extends StatelessWidget {
  final String titel;
  final String beschreibung;
  final IconData icon;
  final Color farbe;
  final VoidCallback onStarten;

  const _MinigameKarte({
    required this.titel,
    required this.beschreibung,
    required this.icon,
    required this.farbe,
    required this.onStarten,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            farbe.withValues(alpha: 0.15),
            AppFarben.oberflaecheErhoben.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: farbe.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: farbe.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: farbe, size: 24),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titel,
                  style: AppTextStyles.ueberschrift4.copyWith(
                    color: farbe,
                    fontSize: 16,
                  ),
                ),
                Text(
                  beschreibung,
                  style: AppTextStyles.koerperKlein,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          ElevatedButton(
            onPressed: onStarten,
            style: ElevatedButton.styleFrom(
              backgroundColor: farbe.withValues(alpha: 0.3),
              foregroundColor: farbe,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: farbe.withValues(alpha: 0.6)),
              ),
              elevation: 0,
            ),
            child: const Text('Spielen', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entscheidungs-Vorschau-Karte (bunte, runde Karte – kindgerechtes Design)
// ─────────────────────────────────────────────────────────────────────────────

class _EntscheidungsVorschauKarte extends StatelessWidget {
  final _JsonEntscheidung entscheidung;

  const _EntscheidungsVorschauKarte({required this.entscheidung});

  /// Altersabhängige Akzentfarbe für die Karte
  Color _akzentFarbe() {
    final alter = entscheidung.alter;
    if (alter <= 6) return const Color(0xFFFFB74D); // Orange – frühes Kindalter
    if (alter <= 9) return const Color(0xFF4FC3F7); // Hellblau – mittlere Kindheit
    return const Color(0xFFBA68C8);                 // Lila – späte Kindheit
  }

  @override
  Widget build(BuildContext context) {
    final farbe = _akzentFarbe();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: farbe.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16), // runde Ecken – kindgerecht
        border: Border.all(
          color: farbe.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: farbe.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alter-Badge + Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: farbe.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entscheidung.alter} Jahre',
                  style: AppTextStyles.beschriftung.copyWith(
                    color: farbe,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Spacer(),

              Icon(
                Icons.help_outline_rounded,
                color: farbe.withValues(alpha: 0.7),
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Kontext (kursiv, dezent)
          if (entscheidung.kontext.isNotEmpty)
            Text(
              entscheidung.kontext,
              style: AppTextStyles.koerperKlein.copyWith(
                color: AppFarben.textSekundaer.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: 8),

          // Frage (fett)
          Text(
            entscheidung.frage,
            style: AppTextStyles.koerper.copyWith(
              color: AppFarben.text,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // Optionen-Hinweis
          Row(
            children: [
              Icon(
                Icons.touch_app_rounded,
                color: farbe.withValues(alpha: 0.6),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${entscheidung.optionen.length} Möglichkeiten – Tippe zum Entscheiden',
                style: AppTextStyles.beschriftung.copyWith(
                  color: farbe.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Minigame-Wrapper (Laufen + Sprache)
// ─────────────────────────────────────────────────────────────────────────────

class _MinigameWrapper extends StatelessWidget {
  final int minigameId;
  final VoidCallback onAbgeschlossen;

  const _MinigameWrapper({
    super.key,
    required this.minigameId,
    required this.onAbgeschlossen,
  });

  @override
  Widget build(BuildContext context) {
    return switch (minigameId) {
      1 => _LaufenLernenMinigame(onAbgeschlossen: onAbgeschlossen),
      2 => _SprachEntwicklungMinigame(onAbgeschlossen: onAbgeschlossen),
      _ => const SizedBox.shrink(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Laufen-Lernen Mini-Sequenz
// ─────────────────────────────────────────────────────────────────────────────

class _LaufenLernenMinigame extends StatefulWidget {
  final VoidCallback onAbgeschlossen;

  const _LaufenLernenMinigame({required this.onAbgeschlossen});

  @override
  State<_LaufenLernenMinigame> createState() => _LaufenLernenMinigameState();
}

class _LaufenLernenMinigameState extends State<_LaufenLernenMinigame>
    with SingleTickerProviderStateMixin {
  // Schritte: 0 = Krabbeln, 1 = Aufstehen, 2 = Loslaufen
  int _schritt = -1; // -1 = noch nichts getan
  bool _abgeschlossen = false;

  // Charakter-Position (0.0 links → 1.0 rechts)
  double _charakterPosition = 0.1;

  // Controller für Charakter-Animation
  late final AnimationController _bewegungController;

  @override
  void initState() {
    super.initState();
    _bewegungController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _bewegungController.dispose();
    super.dispose();
  }

  Future<void> _schrittAusfuehren(int schrittIndex) async {
    if (schrittIndex != _schritt + 1) return; // Reihenfolge einhalten

    setState(() => _schritt = schrittIndex);

    // Charakter bewegt sich
    final zielPosition = 0.1 + schrittIndex * 0.3;
    _bewegungController.reset();
    _bewegungController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _charakterPosition = zielPosition);

    if (schrittIndex == 2) {
      // Alle Schritte abgeschlossen
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _abgeschlossen = true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      widget.onAbgeschlossen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppFarben.textSekundaer),
                    onPressed: widget.onAbgeschlossen,
                  ),
                  Expanded(
                    child: Text(
                      'Laufen Lernen',
                      style: AppTextStyles.ueberschrift4,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 32),

              // Charakter-Animations-Bereich
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppFarben.oberflaecheErhoben.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Boden-Linie
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: AppFarben.nebelGrau.withValues(alpha: 0.3),
                      ),
                    ),

                    // Animierter Charakter-Kreis
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      left: _charakterPosition *
                          (MediaQuery.of(context).size.width - 100),
                      bottom: 22,
                      child: _CharakterKreis(schritt: _schritt),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Status-Text
              if (_abgeschlossen)
                Text(
                  'Du läufst! 🎉',
                  style: AppTextStyles.ueberschrift3.copyWith(
                    color: AppFarben.karmaPositiv,
                  ),
                ).animate().fadeIn().scale()
              else
                Text(
                  _schritt < 0
                      ? 'Tippe die Schritte in der richtigen Reihenfolge!'
                      : (_schritt == 0
                          ? 'Gut! Jetzt aufstehen...'
                          : 'Fast! Jetzt loslaufen!'),
                  style: AppTextStyles.koerper,
                  textAlign: TextAlign.center,
                ),

              const Spacer(),

              // Aktions-Buttons
              if (!_abgeschlossen) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SchrittButton(
                      label: 'Krabbeln',
                      icon: Icons.child_care,
                      istAktiv: _schritt < 0,
                      istErledigt: _schritt >= 0,
                      onTippen: () => _schrittAusfuehren(0),
                    ),
                    _SchrittButton(
                      label: 'Aufstehen',
                      icon: Icons.accessibility_new,
                      istAktiv: _schritt == 0,
                      istErledigt: _schritt >= 1,
                      onTippen: () => _schrittAusfuehren(1),
                    ),
                    _SchrittButton(
                      label: 'Loslaufen',
                      icon: Icons.directions_run,
                      istAktiv: _schritt == 1,
                      istErledigt: _schritt >= 2,
                      onTippen: () => _schrittAusfuehren(2),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Animierter Charakter-Kreis
class _CharakterKreis extends StatelessWidget {
  final int schritt;

  const _CharakterKreis({required this.schritt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppFarben.phaseKindheit.withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppFarben.phaseKindheit.withValues(alpha: 0.4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(
        schritt < 0
            ? Icons.child_care
            : (schritt < 1 ? Icons.accessibility_new : Icons.directions_run),
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

/// Einzelner Schritt-Button
class _SchrittButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool istAktiv;
  final bool istErledigt;
  final VoidCallback onTippen;

  const _SchrittButton({
    required this.label,
    required this.icon,
    required this.istAktiv,
    required this.istErledigt,
    required this.onTippen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: istAktiv ? onTippen : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: istErledigt
              ? AppFarben.karmaPositiv.withValues(alpha: 0.2)
              : (istAktiv
                  ? AppFarben.phaseKindheit.withValues(alpha: 0.2)
                  : AppFarben.nebelGrau.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: istErledigt
                ? AppFarben.karmaPositiv.withValues(alpha: 0.6)
                : (istAktiv
                    ? AppFarben.phaseKindheit.withValues(alpha: 0.6)
                    : AppFarben.nebelGrau.withValues(alpha: 0.3)),
            width: istAktiv ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              istErledigt ? Icons.check : icon,
              color: istErledigt
                  ? AppFarben.karmaPositiv
                  : (istAktiv ? AppFarben.phaseKindheit : AppFarben.textDeaktiviert),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.beschriftung.copyWith(
                color: istErledigt
                    ? AppFarben.karmaPositiv
                    : (istAktiv ? AppFarben.phaseKindheit : AppFarben.textDeaktiviert),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sprach-Entwicklung Mini-Game
// ─────────────────────────────────────────────────────────────────────────────

class _SprachEntwicklungMinigame extends StatefulWidget {
  final VoidCallback onAbgeschlossen;

  const _SprachEntwicklungMinigame({required this.onAbgeschlossen});

  @override
  State<_SprachEntwicklungMinigame> createState() =>
      _SprachEntwicklungMinigameState();
}

class _SprachEntwicklungMinigameState extends State<_SprachEntwicklungMinigame> {
  // Stufen: 0 = Vokale, 1 = Silben, 2 = Wörter
  int _sprachStufe = 0;

  // Ziel-Sequenz der aktuellen Stufe
  static const _sequenzen = [
    ['A', 'E', 'I', 'O', 'U'],           // Vokale (Baby)
    ['MA', 'MA', 'BA', 'BA', 'PA', 'PA'], // Silben (Kleinkind)
    ['Mama', 'Papa', 'Nein', 'Mehr', 'Ich'], // Wörter (Kind)
  ];

  int _aktuellerIndex = 0;
  final List<String> _getippteSequenz = [];
  String _feedback = '';
  bool _abgeschlossen = false;

  List<String> get _zielSequenz => _sequenzen[_sprachStufe];

  void _buchstabeTippen(String buchstabe) {
    if (_aktuellerIndex >= _zielSequenz.length) return;

    if (buchstabe == _zielSequenz[_aktuellerIndex]) {
      setState(() {
        _getippteSequenz.add(buchstabe);
        _aktuellerIndex++;
        _feedback = '✓';
      });

      if (_aktuellerIndex >= _zielSequenz.length) {
        // Stufe abgeschlossen
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          if (_sprachStufe < 2) {
            setState(() {
              _sprachStufe++;
              _aktuellerIndex = 0;
              _getippteSequenz.clear();
              _feedback = '';
            });
          } else {
            setState(() => _abgeschlossen = true);
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) widget.onAbgeschlossen();
            });
          }
        });
      }
    } else {
      setState(() => _feedback = '×');
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _feedback = '');
      });
    }
  }

  // Tasten-Layout abhängig von der Stufe
  List<String> get _tasten {
    if (_sprachStufe == 0) return ['A', 'E', 'I', 'O', 'U'];
    if (_sprachStufe == 1) return ['MA', 'BA', 'PA', 'DA', 'NA'];
    return ['Mama', 'Papa', 'Nein', 'Mehr', 'Ich', 'Du'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppFarben.textSekundaer),
                    onPressed: widget.onAbgeschlossen,
                  ),
                  Expanded(
                    child: Text(
                      'Sprache Entwickeln',
                      style: AppTextStyles.ueberschrift4,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 16),

              // Stufen-Anzeige
              Text(
                _sprachStufe == 0
                    ? 'Als Baby: Vokale lernen'
                    : (_sprachStufe == 1 ? 'Als Kleinkind: Silben sprechen' : 'Als Kind: Erste Wörter'),
                style: AppTextStyles.koerperKursiv.copyWith(
                  color: AppFarben.textSekundaer,
                ),
              ),

              const SizedBox(height: 24),

              // Ziel-Sequenz anzeigen
              Wrap(
                spacing: 8,
                children: _zielSequenz.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final buchstabe = entry.value;
                  final istGetippt = idx < _aktuellerIndex;
                  final istAktuell = idx == _aktuellerIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: istGetippt
                          ? AppFarben.karmaPositiv.withValues(alpha: 0.2)
                          : (istAktuell
                              ? AppFarben.goldGlanz.withValues(alpha: 0.2)
                              : AppFarben.oberflaecheErhoben),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: istGetippt
                            ? AppFarben.karmaPositiv
                            : (istAktuell
                                ? AppFarben.goldGlanz
                                : AppFarben.nebelGrau.withValues(alpha: 0.4)),
                      ),
                    ),
                    child: Text(
                      buchstabe,
                      style: AppTextStyles.ueberschrift4.copyWith(
                        color: istGetippt
                            ? AppFarben.karmaPositiv
                            : (istAktuell
                                ? AppFarben.goldGlanz
                                : AppFarben.textDeaktiviert),
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Feedback
              Text(
                _abgeschlossen ? 'Wunderbar!' : _feedback,
                style: AppTextStyles.ueberschrift3.copyWith(
                  color: _abgeschlossen || _feedback == '✓'
                      ? AppFarben.karmaPositiv
                      : AppFarben.karmaNegatv,
                ),
              ),

              const Spacer(),

              // Tasten-Layout
              if (!_abgeschlossen)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _tasten.map((taste) {
                    return GestureDetector(
                      onTap: () => _buchstabeTippen(taste),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppFarben.tiefesBlau.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppFarben.phaseKindheit.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          taste,
                          style: AppTextStyles.ueberschrift4.copyWith(
                            color: AppFarben.phaseKindheit,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entscheidungs-Wrapper (zeigt Frage und Optionen aus JSON)
// ─────────────────────────────────────────────────────────────────────────────

class _EntscheidungsWrapper extends StatelessWidget {
  final _JsonEntscheidung entscheidung;
  final Function(int) onAbgeschlossen;

  const _EntscheidungsWrapper({
    super.key,
    required this.entscheidung,
    required this.onAbgeschlossen,
  });

  /// Altersabhängige Farbe
  Color _akzentFarbe() {
    final alter = entscheidung.alter;
    if (alter <= 6) return const Color(0xFFFFB74D);
    if (alter <= 9) return const Color(0xFF4FC3F7);
    return const Color(0xFFBA68C8);
  }

  @override
  Widget build(BuildContext context) {
    final farbe = _akzentFarbe();

    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: SafeArea(
        child: Column(
          children: [
            // Schließen-Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppFarben.textSekundaer),
                    onPressed: () => onAbgeschlossen(-1),
                  ),
                  Text(
                    '${entscheidung.alter} Jahre alt',
                    style: AppTextStyles.koerperKlein.copyWith(
                      color: farbe,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kontext-Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: farbe.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: farbe.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        entscheidung.kontext,
                        style: AppTextStyles.koerperKursiv.copyWith(
                          color: AppFarben.textSekundaer,
                          height: 1.6,
                        ),
                      ),
                    ).animate().fadeIn(),

                    const SizedBox(height: 20),

                    // Frage
                    Text(
                      entscheidung.frage,
                      style: AppTextStyles.ueberschrift3.copyWith(
                        color: AppFarben.text,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 24),

                    // Optionen – bunte, runde Karten
                    ...entscheidung.optionen.asMap().entries.map((eintrag) {
                      final index = eintrag.key;
                      final option = eintrag.value;
                      final delay = 300 + index * 120;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => onAbgeschlossen(index),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: farbe.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: farbe.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Buchstaben-Kreis
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: farbe.withValues(alpha: 0.2),
                                    border: Border.all(color: farbe.withValues(alpha: 0.5)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index), // A, B, C...
                                      style: AppTextStyles.beschriftungGross.copyWith(
                                        color: farbe,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    option.text,
                                    style: AppTextStyles.koerper.copyWith(
                                      color: AppFarben.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: delay))
                          .slideY(begin: 0.15);
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
