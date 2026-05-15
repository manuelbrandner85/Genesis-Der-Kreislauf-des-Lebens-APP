// phase3_kindheit_screen.dart
// Phase 3: Die Kindheit – Alters-Progression 0–12 Jahre.
// Enthält: Laufen-Lernen-Sequenz (1–2 Jahre), Sprach-Entwicklung (2–4 Jahre),
// Entscheidungs-Karten für kindheitliche Weichenstellungen.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/entscheidung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/entscheidungs_karte.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/genesis_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Eingebettete Kindheits-Entscheidungen (normalerweise aus kindheit.json)
// ─────────────────────────────────────────────────────────────────────────────

/// Statische Beispiel-Entscheidungen für die Kindheits-Phase.
/// In der Produktionsversion werden diese aus assets/data/kindheit.json geladen.
final List<EntscheidungModel> _kindheitsEntscheidungen = [
  EntscheidungModel(
    id: 'k_spielplatz_1',
    frage: 'Ein Kind weint allein auf dem Spielplatz.',
    kontext: 'Du bist 5 Jahre alt. Alle anderen Kinder spielen. Ein fremdes Kind sitzt allein und weint.',
    optionen: [
      EntscheidungsOption(
        id: 'k1_o1',
        text: 'Ich gehe zu ihm und frage was los ist.',
        egoistischAltruistisch: 0.8,
        karmaAuswirkung: {
          KarmaDimension.mitgefuehl: 8.0,
          KarmaDimension.liebe: 5.0,
        },
        sofortigeKonsequenzen: ['Das Kind lächelt dankbar. Du hast einen neuen Freund gefunden.'],
        verzoegerteKonsequenzen: ['Deine Empathie wächst mit jedem Jahr.'],
        klingtMoralischAber: false,
      ),
      EntscheidungsOption(
        id: 'k1_o2',
        text: 'Ich spiele weiter. Das ist nicht mein Problem.',
        egoistischAltruistisch: -0.6,
        karmaAuswirkung: {
          KarmaDimension.mitgefuehl: -5.0,
        },
        sofortigeKonsequenzen: ['Du spielst weiter. Das Gefühl lässt dich aber nicht los.'],
        verzoegerteKonsequenzen: ['Manchmal denkst du noch daran zurück.'],
        klingtMoralischAber: false,
      ),
    ],
    istMikroEntscheidung: true,
    hatParallelvorschau: false,
    systemEinfluesse: {},
  ),
  EntscheidungModel(
    id: 'k_geheimnis_2',
    frage: 'Du findest das Tagebuch deiner Schwester.',
    kontext: 'Du bist 8 Jahre alt und findest zufällig das Tagebuch deiner älteren Schwester unter ihrem Bett.',
    optionen: [
      EntscheidungsOption(
        id: 'k2_o1',
        text: 'Ich lege es zurück ohne es zu lesen.',
        egoistischAltruistisch: 0.5,
        karmaAuswirkung: {
          KarmaDimension.ehrlichkeit: 7.0,
          KarmaDimension.mut: 3.0,
        },
        sofortigeKonsequenzen: ['Respekt für Grenzen wächst in dir.'],
        verzoegerteKonsequenzen: ['Deine Schwester vertraut dir blind.'],
        klingtMoralischAber: false,
      ),
      EntscheidungsOption(
        id: 'k2_o2',
        text: 'Ich lese nur ein bisschen... nur kurz.',
        egoistischAltruistisch: -0.3,
        karmaAuswirkung: {
          KarmaDimension.ehrlichkeit: -6.0,
          KarmaDimension.weisheit: -2.0,
        },
        sofortigeKonsequenzen: ['Du liest über Dinge die du nicht verstehst.'],
        verzoegerteKonsequenzen: ['Deine Schwester bemerkt es eines Tages.'],
        klingtMoralischAber: false,
      ),
      EntscheidungsOption(
        id: 'k2_o3',
        text: 'Ich gebe es ihr und sage was ich gefunden habe.',
        egoistischAltruistisch: 0.7,
        karmaAuswirkung: {
          KarmaDimension.ehrlichkeit: 10.0,
          KarmaDimension.liebe: 4.0,
        },
        sofortigeKonsequenzen: ['Deine Schwester ist überrascht, aber dankbar.'],
        verzoegerteKonsequenzen: ['Eure Bindung wird stärker.'],
        klingtMoralischAber: false,
      ),
    ],
    istMikroEntscheidung: false,
    hatParallelvorschau: true,
    systemEinfluesse: {},
  ),
  EntscheidungModel(
    id: 'k_luege_3',
    frage: 'Du hast aus Versehen die Lieblingstasse deiner Mutter zerbrochen.',
    kontext: 'Niemand hat es gesehen. Deine Mutter liebt diese Tasse sehr – sie war ein Geschenk ihrer eigenen Mutter.',
    optionen: [
      EntscheidungsOption(
        id: 'k3_o1',
        text: 'Ich sage ihr die Wahrheit und entschuldige mich.',
        egoistischAltruistisch: 0.6,
        karmaAuswirkung: {
          KarmaDimension.ehrlichkeit: 9.0,
          KarmaDimension.mut: 5.0,
        },
        sofortigeKonsequenzen: ['Mama ist traurig, aber stolz auf deine Ehrlichkeit.'],
        verzoegerteKonsequenzen: ['Du lernst: Ehrlichkeit ist leichter als Lügen.'],
        klingtMoralischAber: false,
      ),
      EntscheidungsOption(
        id: 'k3_o2',
        text: 'Ich schiebe die Schuld auf den Hund.',
        egoistischAltruistisch: -0.7,
        karmaAuswirkung: {
          KarmaDimension.ehrlichkeit: -8.0,
          KarmaDimension.mitgefuehl: -4.0,
        },
        sofortigeKonsequenzen: ['Der Hund wird bestraft. Das Schuldgefühl sitzt tief.'],
        verzoegerteKonsequenzen: ['Du erinnerst dich manchmal daran wenn du älter bist.'],
        klingtMoralischAber: false,
      ),
    ],
    istMikroEntscheidung: true,
    hatParallelvorschau: false,
    systemEinfluesse: {},
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Phase 3 Kindheit Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Haupt-Screen für Phase 3: Die Kindheit.
///
/// Zeigt eine Alters-Progression von 0–12 Jahren.
/// Enthält Minigames (Laufen-Lernen, Sprach-Entwicklung) und
/// altersabhängige Entscheidungskarten.
class Phase3KindheitScreen extends ConsumerStatefulWidget {
  const Phase3KindheitScreen({super.key});

  @override
  ConsumerState<Phase3KindheitScreen> createState() =>
      _Phase3KindheitScreenState();
}

class _Phase3KindheitScreenState extends ConsumerState<Phase3KindheitScreen>
    with TickerProviderStateMixin {
  // Aktuell angezeigtes Kapitel (Jahr 0–12)
  int _aktuellesJahr = 0;

  // Welche Entscheidungen wurden bereits getroffen
  final Set<String> _getroffeneEntscheidungen = {};

  // Welche Minigames wurden bereits abgeschlossen
  bool _laufenAbgeschlossen = false;
  bool _sprachAbgeschlossen = false;

  // Scroll-Controller für Jahres-Navigation
  final PageController _jahresController = PageController();

  // Aktueller Modus (0 = Jahres-Übersicht, 1 = Minigame, 2 = Entscheidung)
  int _modus = 0;

  // Aktive Entscheidung
  EntscheidungModel? _aktiveEntscheidung;

  // Aktives Minigame (0 = keins, 1 = Laufen, 2 = Sprache)
  int _aktivesMinigame = 0;

  @override
  void dispose() {
    _jahresController.dispose();
    super.dispose();
  }

  void _jahrWechseln(int jahr) {
    setState(() => _aktuellesJahr = jahr);
    _jahresController.animateToPage(
      jahr,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    // Alters-Provider aktualisieren
    ref.read(spielProvider.notifier).alterErhoehen();
  }

  void _entscheidungStarten(EntscheidungModel entscheidung) {
    setState(() {
      _aktiveEntscheidung = entscheidung;
      _modus = 2;
    });
  }

  void _entscheidungAbgeschlossen(int optionIndex) {
    if (_aktiveEntscheidung == null) return;
    ref.read(spielProvider.notifier).entscheidungTreffen(
      _aktiveEntscheidung!.id,
      optionIndex,
    );
    setState(() {
      _getroffeneEntscheidungen.add(_aktiveEntscheidung!.id);
      _aktiveEntscheidung = null;
      _modus = 0;
    });
  }

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

  // Entscheidungen für das aktuelle Jahr
  List<EntscheidungModel> get _jahresEntscheidungen {
    // Vereinfachte Zuteilung: Je nach Altersgruppe andere Entscheidungen
    if (_aktuellesJahr < 4) return [];
    if (_aktuellesJahr < 8) {
      return _kindheitsEntscheidungen
          .where((e) => !_getroffeneEntscheidungen.contains(e.id))
          .take(1)
          .toList();
    }
    return _kindheitsEntscheidungen
        .where((e) => !_getroffeneEntscheidungen.contains(e.id))
        .take(2)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: SafeArea(
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
                onPhaseAbschliessen: () => context.go(AppRouten.phase4),
              ),
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Haupt-Jahres-Ansicht
// ─────────────────────────────────────────────────────────────────────────────

class _JahresHauptansicht extends StatelessWidget {
  final int aktuellesJahr;
  final PageController jahresController;
  final List<EntscheidungModel> jahresEntscheidungen;
  final bool laufenAbgeschlossen;
  final bool sprachAbgeschlossen;
  final Function(int) onJahrWechseln;
  final Function(EntscheidungModel) onEntscheidungStarten;
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

                    // Entscheidungskarten
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
// Entscheidungs-Vorschau-Karte
// ─────────────────────────────────────────────────────────────────────────────

class _EntscheidungsVorschauKarte extends StatelessWidget {
  final EntscheidungModel entscheidung;

  const _EntscheidungsVorschauKarte({required this.entscheidung});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppFarben.mystischLila.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppFarben.mystischLila.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.help_outline,
            color: AppFarben.goldGlanz.withValues(alpha: 0.8),
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entscheidung.frage,
                  style: AppTextStyles.entscheidung.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${entscheidung.optionen.length} Optionen',
                  style: AppTextStyles.beschriftung.copyWith(
                    color: AppFarben.textTertiaer,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_right,
            color: AppFarben.goldGlanz.withValues(alpha: 0.6),
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
    ['A', 'E', 'I', 'O', 'U'],          // Vokale (Baby)
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
// Entscheidungs-Wrapper (zeigt die vollständige EntscheidungsKarte)
// ─────────────────────────────────────────────────────────────────────────────

class _EntscheidungsWrapper extends StatelessWidget {
  final EntscheidungModel entscheidung;
  final Function(int) onAbgeschlossen;

  const _EntscheidungsWrapper({
    super.key,
    required this.entscheidung,
    required this.onAbgeschlossen,
  });

  @override
  Widget build(BuildContext context) {
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
                    'Eine Entscheidung',
                    style: AppTextStyles.koerperKlein.copyWith(
                      color: AppFarben.textSekundaer,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: EntscheidungsKarte(
                    entscheidung: entscheidung,
                    onEntscheidung: onAbgeschlossen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
