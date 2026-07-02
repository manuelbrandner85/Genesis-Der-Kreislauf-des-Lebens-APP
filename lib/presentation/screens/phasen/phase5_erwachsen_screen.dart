// phase5_erwachsen_screen.dart
// Phase 5: Das Erwachsenenleben (20–60 Jahre) – Grand-Strategy mit 4 Tabs.
//
// Tabs:
// 1. Leben     – Tagesroutine, Gesundheitsauswirkungen
// 2. Karriere  – Jobwahl, Beförderungen, ethische Dilemmas
// 3. Beziehungen – Partner, Freundschaft, Konflikte
// 4. Seele     – Meditation, Spiritualität, Erinnerungen
//
// Am unteren Rand: langsam vorschreitendes Alters-Meter (20–60).
// Button "Das Leben reift weiter" → /phase/6

import 'package:flutter/material.dart';
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
// Lokale Datenstrukturen
// ─────────────────────────────────────────────────────────────────────────────

/// Eine Tagesroutine-Entscheidung im "Leben"-Tab.
class _LebenEntscheidung {
  final String titel;
  final String beschreibung;
  final IconData icon;
  final String optionA;
  final String optionB;
  final Map<KarmaDimension, double> karmaA;
  final Map<KarmaDimension, double> karmaB;
  final int gesundheitA; // -20 bis +20
  final int gesundheitB;

  const _LebenEntscheidung({
    required this.titel,
    required this.beschreibung,
    required this.icon,
    required this.optionA,
    required this.optionB,
    required this.karmaA,
    required this.karmaB,
    required this.gesundheitA,
    required this.gesundheitB,
  });
}

const List<_LebenEntscheidung> _lebenEntscheidungen = [
  _LebenEntscheidung(
    titel: 'Morgenroutine',
    beschreibung: 'Der Wecker klingelt um 6 Uhr. Du hast heute einen wichtigen Tag.',
    icon: Icons.wb_sunny_outlined,
    optionA: 'Früh aufstehen und meditieren',
    optionB: 'Noch eine Stunde ausschlafen',
    karmaA: {KarmaDimension.weisheit: 4.0, KarmaDimension.mut: 2.0},
    karmaB: {KarmaDimension.weisheit: -1.0},
    gesundheitA: 8,
    gesundheitB: 2,
  ),
  _LebenEntscheidung(
    titel: 'Mittagspause',
    beschreibung: 'Du hast 30 Minuten Pause. Der Döner-Stand riecht verlockend.',
    icon: Icons.lunch_dining_outlined,
    optionA: 'Gesund kochen – Salat und Vollkorn',
    optionB: 'Fast Food – schnell und lecker',
    karmaA: {KarmaDimension.weisheit: 3.0},
    karmaB: {KarmaDimension.weisheit: -2.0},
    gesundheitA: 10,
    gesundheitB: -5,
  ),
  _LebenEntscheidung(
    titel: 'Feierabend',
    beschreibung: 'Nach einem langen Tag: Sport oder Netflix?',
    icon: Icons.sports_gymnastics,
    optionA: 'Laufen gehen – 30 Minuten Bewegung',
    optionB: 'Serie schauen und entspannen',
    karmaA: {KarmaDimension.mut: 3.0, KarmaDimension.weisheit: 2.0},
    karmaB: {KarmaDimension.weisheit: 1.0},
    gesundheitA: 15,
    gesundheitB: -2,
  ),
  _LebenEntscheidung(
    titel: 'Wochenendritual',
    beschreibung: 'Samstag frei – wie nutzt du die Zeit?',
    icon: Icons.weekend_outlined,
    optionA: 'Natur erkunden, frische Luft tanken',
    optionB: 'Freunde treffen, Spaß haben',
    karmaA: {KarmaDimension.weisheit: 4.0, KarmaDimension.liebe: 2.0},
    karmaB: {KarmaDimension.liebe: 6.0, KarmaDimension.mitgefuehl: 3.0},
    gesundheitA: 12,
    gesundheitB: 5,
  ),
];

/// Ein Karrierepfad mit Beschreibung und Karma-Profil.
class _KarrierePfad {
  final String titel;
  final String beschreibung;
  final IconData icon;
  final Color farbe;
  final Map<KarmaDimension, double> karmaBonus;
  final String zeitalterHinweis;

  const _KarrierePfad({
    required this.titel,
    required this.beschreibung,
    required this.icon,
    required this.farbe,
    required this.karmaBonus,
    required this.zeitalterHinweis,
  });
}

const List<_KarrierePfad> _karrierePfade = [
  _KarrierePfad(
    titel: 'Heiler',
    beschreibung: 'Arzt, Pfleger oder Therapeut – du rettest Leben.',
    icon: Icons.medical_services_outlined,
    farbe: Color(0xFF4CAF50),
    karmaBonus: {KarmaDimension.mitgefuehl: 15.0, KarmaDimension.weisheit: 8.0},
    zeitalterHinweis: 'Zeitlos, in jedem Zeitalter gefragt',
  ),
  _KarrierePfad(
    titel: 'Künstler',
    beschreibung: 'Schriftsteller, Maler, Musiker – du schenkst Schönheit.',
    icon: Icons.palette_outlined,
    farbe: Color(0xFF9C27B0),
    karmaBonus: {KarmaDimension.liebe: 12.0, KarmaDimension.ehrlichkeit: 8.0},
    zeitalterHinweis: 'Floriert in Renaissance und Moderne',
  ),
  _KarrierePfad(
    titel: 'Händler',
    beschreibung: 'Kaufmann, Unternehmer, Trader – du akkumulierst Reichtum.',
    icon: Icons.storefront_outlined,
    farbe: Color(0xFFFFD700),
    karmaBonus: {KarmaDimension.grosszuegigkeit: 5.0, KarmaDimension.weisheit: 6.0},
    zeitalterHinweis: 'Besonders mächtig im Industriezeitalter',
  ),
  _KarrierePfad(
    titel: 'Gelehrter',
    beschreibung: 'Wissenschaftler, Lehrer, Philosoph – du weitest Wissen aus.',
    icon: Icons.school_outlined,
    farbe: Color(0xFF2196F3),
    karmaBonus: {KarmaDimension.weisheit: 18.0, KarmaDimension.ehrlichkeit: 6.0},
    zeitalterHinweis: 'Entfaltet sich in Moderne und Zukunft',
  ),
  _KarrierePfad(
    titel: 'Krieger',
    beschreibung: 'Soldat, Polizist, Kämpfer – du schützt oder zerstörst.',
    icon: Icons.shield_outlined,
    farbe: Color(0xFFF44336),
    karmaBonus: {KarmaDimension.mut: 15.0, KarmaDimension.ehrlichkeit: 5.0},
    zeitalterHinweis: 'Dominiert in Mittelalter und Industriezeit',
  ),
];

/// Eine Karriere-Entscheidung (Ethik-Dilemma oder Beförderung).
class _KarriereEntscheidung {
  final String situation;
  final String optionA;
  final String optionB;
  final Map<KarmaDimension, double> karmaA;
  final Map<KarmaDimension, double> karmaB;

  const _KarriereEntscheidung({
    required this.situation,
    required this.optionA,
    required this.optionB,
    required this.karmaA,
    required this.karmaB,
  });
}

const List<_KarriereEntscheidung> _karriereEntscheidungen = [
  _KarriereEntscheidung(
    situation:
        'Beförderung: Dein Chef fragt, ob du eine Kollegin übergehen würdest, die eigentlich besser qualifiziert ist.',
    optionA: 'Nein – ich empfehle sie stattdessen.',
    optionB: 'Ja – die Chance nehme ich.',
    karmaA: {KarmaDimension.ehrlichkeit: 10.0, KarmaDimension.mitgefuehl: 8.0},
    karmaB: {KarmaDimension.grosszuegigkeit: -8.0, KarmaDimension.ehrlichkeit: -6.0},
  ),
  _KarriereEntscheidung(
    situation:
        'Ethik-Dilemma: Du entdeckst, dass dein Unternehmen heimlich Daten verkauft.',
    optionA: 'Whistleblowing – du meldest es öffentlich.',
    optionB: 'Schweigen – du brauchst den Job.',
    karmaA: {KarmaDimension.mut: 12.0, KarmaDimension.ehrlichkeit: 10.0},
    karmaB: {KarmaDimension.ehrlichkeit: -9.0, KarmaDimension.mut: -6.0},
  ),
  _KarriereEntscheidung(
    situation:
        'Überstunden: Ein Kollege braucht Hilfe, du hast aber eigene Deadlines.',
    optionA: 'Du hilfst – auch wenn du länger bleibst.',
    optionB: 'Du fokussierst dich auf deine Arbeit.',
    karmaA: {KarmaDimension.mitgefuehl: 7.0, KarmaDimension.liebe: 5.0},
    karmaB: {KarmaDimension.weisheit: 3.0, KarmaDimension.mitgefuehl: -3.0},
  ),
];

/// Beziehungskandidat für den Beziehungs-Tab.
class _BeziehungsKandidat {
  final String name;
  final String beschreibung;
  final List<String> pros;
  final List<String> contras;
  final IconData icon;
  final Color farbe;
  final Map<KarmaDimension, double> karmaBonus;

  const _BeziehungsKandidat({
    required this.name,
    required this.beschreibung,
    required this.pros,
    required this.contras,
    required this.icon,
    required this.farbe,
    required this.karmaBonus,
  });
}

const List<_BeziehungsKandidat> _kandidaten = [
  _BeziehungsKandidat(
    name: 'Das Freie Herz',
    beschreibung: 'Leidenschaftlich, ungebunden, intensiv. Liebt das Abenteuer.',
    pros: ['Aufregend', 'Inspirierend', 'Lebendig'],
    contras: ['Unzuverlässig', 'Konfliktreich', 'Instabil'],
    icon: Icons.local_fire_department_outlined,
    farbe: Color(0xFFFF5722),
    karmaBonus: {KarmaDimension.liebe: 12.0, KarmaDimension.mut: 5.0},
  ),
  _BeziehungsKandidat(
    name: 'Der stille Begleiter',
    beschreibung: 'Ruhig, verlässlich, treu. Gibt Stabilität und Geborgenheit.',
    pros: ['Vertrauenswürdig', 'Stabil', 'Fürsorglich'],
    contras: ['Wenig Aufregung', 'Introvertiert', 'Manchmal langweilig'],
    icon: Icons.anchor_outlined,
    farbe: Color(0xFF2196F3),
    karmaBonus: {KarmaDimension.liebe: 8.0, KarmaDimension.mitgefuehl: 10.0},
  ),
  _BeziehungsKandidat(
    name: 'Der weise Spiegel',
    beschreibung: 'Klug, wachstumsorientiert, herausfordernd. Bringt dich voran.',
    pros: ['Inspiriert Wachstum', 'Tiefgründig', 'Ehrlich'],
    contras: ['Fordernd', 'Wenig Romantik', 'Kritisch'],
    icon: Icons.auto_stories_outlined,
    farbe: Color(0xFF9C27B0),
    karmaBonus: {KarmaDimension.weisheit: 12.0, KarmaDimension.ehrlichkeit: 7.0},
  ),
];

/// Eine Konflikt-Situation im Beziehungs-Tab.
class _BeziehungsKonflikt {
  final String situation;
  final String optionLoesen;
  final String optionIgnorieren;
  final Map<KarmaDimension, double> karmaLoesen;
  final Map<KarmaDimension, double> karmaIgnorieren;

  const _BeziehungsKonflikt({
    required this.situation,
    required this.optionLoesen,
    required this.optionIgnorieren,
    required this.karmaLoesen,
    required this.karmaIgnorieren,
  });
}

const List<_BeziehungsKonflikt> _konflikte = [
  _BeziehungsKonflikt(
    situation: 'Dein Partner fühlt sich vernachlässigt. Ein großes Gespräch steht an.',
    optionLoesen: 'Offen reden, zuhören, Verantwortung übernehmen',
    optionIgnorieren: 'Ablenken – die Zeit heilt alles',
    karmaLoesen: {KarmaDimension.liebe: 9.0, KarmaDimension.ehrlichkeit: 7.0},
    karmaIgnorieren: {KarmaDimension.liebe: -8.0, KarmaDimension.mut: -4.0},
  ),
  _BeziehungsKonflikt(
    situation: 'Ein enger Freund hat dich belogen. Du hast es herausgefunden.',
    optionLoesen: 'Konfrontation mit Mitgefühl – du gibst ihm eine Chance',
    optionIgnorieren: 'Stille ziehen – du distanzierst dich ohne Erklärung',
    karmaLoesen: {KarmaDimension.mut: 8.0, KarmaDimension.mitgefuehl: 7.0},
    karmaIgnorieren: {KarmaDimension.ehrlichkeit: -5.0, KarmaDimension.liebe: -4.0},
  ),
];

/// Eine Seelen-Aktivität im Seele-Tab.
class _SeelenAktivitaet {
  final String name;
  final String beschreibung;
  final IconData icon;
  final Color farbe;
  final Map<KarmaDimension, double> karmaBonus;
  final String wirkung;

  const _SeelenAktivitaet({
    required this.name,
    required this.beschreibung,
    required this.icon,
    required this.farbe,
    required this.karmaBonus,
    required this.wirkung,
  });
}

const List<_SeelenAktivitaet> _seelenAktivitaeten = [
  _SeelenAktivitaet(
    name: 'Meditation',
    beschreibung: '20 Minuten Stille. Der Atem beruhigt sich. Trauma-Schatten verblassen.',
    icon: Icons.self_improvement,
    farbe: Color(0xFF9C27B0),
    karmaBonus: {KarmaDimension.weisheit: 6.0, KarmaDimension.liebe: 4.0},
    wirkung: 'Heilt Trauma-Dämonen',
  ),
  _SeelenAktivitaet(
    name: 'Spirituelle Praxis',
    beschreibung: 'Gebet, Ritual oder Zeremonie – du verbindest dich mit dem Größeren.',
    icon: Icons.brightness_5,
    farbe: Color(0xFFFFD700),
    karmaBonus: {KarmaDimension.grosszuegigkeit: 5.0, KarmaDimension.weisheit: 7.0},
    wirkung: '+Karma durch spirituelle Verbindung',
  ),
  _SeelenAktivitaet(
    name: 'Erinnerungen schreiben',
    beschreibung: 'Du hältst ein Erlebnis fest. Die Seele verarbeitet und erinnert.',
    icon: Icons.edit_note,
    farbe: Color(0xFF4CAF50),
    karmaBonus: {KarmaDimension.ehrlichkeit: 6.0, KarmaDimension.weisheit: 5.0},
    wirkung: 'Generiert Gedanken für die Bibliothek',
  ),
  _SeelenAktivitaet(
    name: 'Dankbarkeit kultivieren',
    beschreibung: 'Drei Dinge, für die du heute dankbar bist. Einfach, aber transformativ.',
    icon: Icons.favorite_border,
    farbe: Color(0xFFE91E63),
    karmaBonus: {KarmaDimension.liebe: 7.0, KarmaDimension.mitgefuehl: 5.0},
    wirkung: '+Liebe und +Mitgefühl',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod-Provider für Phase-5-Zustand
// ─────────────────────────────────────────────────────────────────────────────

/// Aktuelles Alter des Charakters in Phase 5 (20–60).
final _p5AlterProvider = StateProvider<int>((ref) => 20);

/// Gesundheits-Wert in Phase 5 (0–100).
final _p5GesundheitProvider = StateProvider<int>((ref) => 75);

/// Gewählter Karrierepfad in Phase 5 (null = noch nicht gewählt).
final _p5KarriereProvider = StateProvider<_KarrierePfad?>((ref) => null);

/// Gewählter Beziehungskandidat in Phase 5 (null = noch nicht gewählt).
final _p5BeziehungProvider = StateProvider<_BeziehungsKandidat?>((ref) => null);

/// Anzahl absolvierter Seelen-Aktivitäten in Phase 5.
final _p5SeelenAktivitaetenProvider = StateProvider<int>((ref) => 0);

// ─────────────────────────────────────────────────────────────────────────────
// Phase 5 Screen – Hauptscreen mit Tab-Navigation
// ─────────────────────────────────────────────────────────────────────────────

/// Erwachsenen-Phase (20–60 Jahre) als Grand-Strategy mit 4 Tabs.
class Phase5ErwachsenScreen extends ConsumerStatefulWidget {
  const Phase5ErwachsenScreen({super.key});

  @override
  ConsumerState<Phase5ErwachsenScreen> createState() =>
      _Phase5ErwachsenScreenState();
}

class _Phase5ErwachsenScreenState
    extends ConsumerState<Phase5ErwachsenScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // Welche Entscheidungen bereits getroffen wurden
  final Set<int> _getroffeneLebenEntscheidungen = {};
  final Set<int> _getroffeneKarriereEntscheidungen = {};
  final Set<int> _getroffeneKonflikte = {};

  // Feedback-Nachricht (erscheint kurz nach Aktionen)
  String? _feedbackNachricht;
  Color _feedbackFarbe = AppFarben.karmaPositiv;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Alter um 5 Jahre erhöhen (max. 60)
  void _alterErhoehen() {
    final alter = ref.read(_p5AlterProvider);
    if (alter < 60) {
      ref.read(_p5AlterProvider.notifier).state = alter + 5;
    }
  }

  // Karma und Gesundheit anpassen + Feedback anzeigen
  void _karmaUndGesundheitAnpassen({
    required Map<KarmaDimension, double> karma,
    int gesundheitsDelta = 0,
    required String feedback,
    bool positiv = true,
  }) {
    // Karma-Änderungen auf alle Dimensionen anwenden
    karma.forEach((dim, delta) {
      ref.read(karmaProvider.notifier).dimensionAendern(dim, delta);
    });

    // Gesundheit anpassen
    if (gesundheitsDelta != 0) {
      final aktuelleGesundheit = ref.read(_p5GesundheitProvider);
      ref.read(_p5GesundheitProvider.notifier).state =
          (aktuelleGesundheit + gesundheitsDelta).clamp(0, 100);
    }

    // Alter langsam vorschreiten lassen
    _alterErhoehen();

    // Feedback-Nachricht kurz einblenden
    setState(() {
      _feedbackNachricht = feedback;
      _feedbackFarbe = positiv ? AppFarben.karmaPositiv : AppFarben.karmaNegatv;
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() => _feedbackNachricht = null);
    });
  }

  // Prüft, ob alle Pflichtentscheidungen getroffen wurden
  bool get _kannWeiter {
    final karriere = ref.read(_p5KarriereProvider);
    return karriere != null && ref.read(_p5AlterProvider) >= 40;
  }

  @override
  Widget build(BuildContext context) {
    final alter = ref.watch(_p5AlterProvider);
    final gesundheit = ref.watch(_p5GesundheitProvider);

    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhasenHintergrund(phase: GamePhase.erwachsen),
          SafeArea(
            child: Column(
              children: [
                // Kopfzeile: Titel + Gesundheit + Feedback
                _ErwachsenenKopfzeile(
                  alter: alter,
                  gesundheit: gesundheit,
                  feedbackNachricht: _feedbackNachricht,
                  feedbackFarbe: _feedbackFarbe,
                ),

                // Tab-Bar mit 4 Registerkarten
                _ErwachsenenTabBar(controller: _tabController),

                // Tab-Inhalte
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Leben – Tagesroutine-Entscheidungen
                      _LebenTab(
                        getroffene: _getroffeneLebenEntscheidungen,
                        onEntscheidung: (index, optionA) {
                          final e = _lebenEntscheidungen[index];
                          _getroffeneLebenEntscheidungen.add(index);
                          _karmaUndGesundheitAnpassen(
                            karma: optionA ? e.karmaA : e.karmaB,
                            gesundheitsDelta:
                                optionA ? e.gesundheitA : e.gesundheitB,
                            feedback: optionA
                                ? '${e.optionA} gewählt'
                                : '${e.optionB} gewählt',
                            positiv: optionA
                                ? e.gesundheitA > 0
                                : e.gesundheitB > 0,
                          );
                        },
                      ),

                      // Tab 2: Karriere – Pfadwahl + Dilemmas
                      _KarriereTab(
                        gewaehltePfad: ref.watch(_p5KarriereProvider),
                        getroffeneEntscheidungen: _getroffeneKarriereEntscheidungen,
                        onPfadWaehlen: (pfad) {
                          ref.read(_p5KarriereProvider.notifier).state = pfad;
                          _karmaUndGesundheitAnpassen(
                            karma: pfad.karmaBonus,
                            feedback: 'Karrierepfad: ${pfad.titel}',
                          );
                        },
                        onEntscheidung: (index, optionA) {
                          final e = _karriereEntscheidungen[index];
                          _getroffeneKarriereEntscheidungen.add(index);
                          _karmaUndGesundheitAnpassen(
                            karma: optionA ? e.karmaA : e.karmaB,
                            feedback: optionA ? e.optionA : e.optionB,
                            positiv: optionA,
                          );
                        },
                      ),

                      // Tab 3: Beziehungen – Kandidatenwahl + Konflikte
                      _BeziehungenTab(
                        gewaehltKandidat: ref.watch(_p5BeziehungProvider),
                        getroffeneKonflikte: _getroffeneKonflikte,
                        onKandidatWaehlen: (kandidat) {
                          ref.read(_p5BeziehungProvider.notifier).state = kandidat;
                          _karmaUndGesundheitAnpassen(
                            karma: kandidat.karmaBonus,
                            gesundheitsDelta: 5,
                            feedback: '${kandidat.name} – Beziehung begonnen',
                          );
                        },
                        onKonflikt: (index, loesen) {
                          final k = _konflikte[index];
                          _getroffeneKonflikte.add(index);
                          _karmaUndGesundheitAnpassen(
                            karma: loesen ? k.karmaLoesen : k.karmaIgnorieren,
                            feedback: loesen
                                ? 'Konflikt gelöst'
                                : 'Konflikt ignoriert',
                            positiv: loesen,
                          );
                        },
                      ),

                      // Tab 4: Seele – Meditation, Spiritualität, Erinnerungen
                      _SeelenTab(
                        aktivitaetenCount:
                            ref.watch(_p5SeelenAktivitaetenProvider),
                        onAktivitaet: (aktivitaet) {
                          ref
                              .read(_p5SeelenAktivitaetenProvider.notifier)
                              .state++;
                          _karmaUndGesundheitAnpassen(
                            karma: aktivitaet.karmaBonus,
                            gesundheitsDelta: 5,
                            feedback:
                                '${aktivitaet.name}: ${aktivitaet.wirkung}',
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Unterer Bereich: Alters-Meter + Weiter-Button
                _AltersUndWeiterLeiste(
                  alter: alter,
                  kannWeiter: _kannWeiter,
                  onWeiter: () {
                    // Fortschritt persistieren, dann navigieren
                    ref
                        .read(spielProvider.notifier)
                        .phasWechseln(GamePhase.reife);
                    context.go('/phase/6');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErwachsenenKopfzeile
// ─────────────────────────────────────────────────────────────────────────────

class _ErwachsenenKopfzeile extends StatelessWidget {
  final int alter;
  final int gesundheit;
  final String? feedbackNachricht;
  final Color feedbackFarbe;

  const _ErwachsenenKopfzeile({
    required this.alter,
    required this.gesundheit,
    required this.feedbackNachricht,
    required this.feedbackFarbe,
  });

  @override
  Widget build(BuildContext context) {
    // Gesundheitsfarbe je nach Wert
    final gesundheitFarbe = gesundheit > 60
        ? AppFarben.karmaPositiv
        : gesundheit > 30
            ? AppFarben.karmaNeutral
            : AppFarben.karmaNegatv;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        border: Border(
          bottom: BorderSide(
            color: AppFarben.goldGlanz.withValues(alpha: 0.2),
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
              // Phasentitel
              Text(
                'DAS ERWACHSENENLEBEN',
                style: AppTextStyles.beschriftungGross.copyWith(
                  color: AppFarben.phaseBluete,
                  letterSpacing: 2,
                ),
              ),

              // Gesundheits-Anzeige
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: gesundheitFarbe,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$gesundheit%',
                    style: AppTextStyles.beschriftung
                        .copyWith(color: gesundheitFarbe),
                  ),
                ],
              ),
            ],
          ),

          // Feedback-Nachricht (kurz nach Aktionen)
          if (feedbackNachricht != null) ...[
            const SizedBox(height: 6),
            Text(
              feedbackNachricht!,
              style: AppTextStyles.beschriftung
                  .copyWith(color: feedbackFarbe),
            ).animate().fadeIn().then().fadeOut(delay: 2000.ms),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErwachsenenTabBar
// ─────────────────────────────────────────────────────────────────────────────

class _ErwachsenenTabBar extends StatelessWidget {
  final TabController controller;

  const _ErwachsenenTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppFarben.oberflaecheErhoben,
      child: TabBar(
        controller: controller,
        indicatorColor: AppFarben.goldGlanz,
        indicatorWeight: 2,
        labelColor: AppFarben.goldGlanz,
        unselectedLabelColor: AppFarben.textSekundaer,
        labelStyle: AppTextStyles.beschriftung.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.home_outlined, size: 18), text: 'Leben'),
          Tab(icon: Icon(Icons.work_outline, size: 18), text: 'Karriere'),
          Tab(
              icon: Icon(Icons.people_outline, size: 18),
              text: 'Beziehungen'),
          Tab(icon: Icon(Icons.spa_outlined, size: 18), text: 'Seele'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1: Leben – Tagesroutine-Entscheidungen
// ─────────────────────────────────────────────────────────────────────────────

class _LebenTab extends StatelessWidget {
  final Set<int> getroffene;
  final void Function(int index, bool optionA) onEntscheidung;

  const _LebenTab({
    required this.getroffene,
    required this.onEntscheidung,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Tägliche Entscheidungen',
            style: AppTextStyles.ueberschrift3,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 4),
          Text(
            'Kleine Entscheidungen, große Auswirkungen auf Gesundheit und Seele.',
            style: AppTextStyles.koerperKlein,
          ),
          const SizedBox(height: 20),

          ...List.generate(_lebenEntscheidungen.length, (i) {
            final e = _lebenEntscheidungen[i];
            final getroffen = getroffene.contains(i);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TagesroutinenKarte(
                entscheidung: e,
                getroffen: getroffen,
                onA: getroffen ? null : () => onEntscheidung(i, true),
                onB: getroffen ? null : () => onEntscheidung(i, false),
              ).animate().fadeIn(delay: Duration(milliseconds: 100 + i * 80)),
            );
          }),
        ],
      ),
    );
  }
}

/// Karte für eine Tagesroutinen-Entscheidung.
class _TagesroutinenKarte extends StatelessWidget {
  final _LebenEntscheidung entscheidung;
  final bool getroffen;
  final VoidCallback? onA;
  final VoidCallback? onB;

  const _TagesroutinenKarte({
    required this.entscheidung,
    required this.getroffen,
    required this.onA,
    required this.onB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: getroffen
            ? AppFarben.oberflaeche.withValues(alpha: 0.5)
            : AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: getroffen
              ? AppFarben.nebelGrau.withValues(alpha: 0.3)
              : AppFarben.phaseBluete.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                entscheidung.icon,
                color: getroffen
                    ? AppFarben.textSekundaer
                    : AppFarben.phaseBluete,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entscheidung.titel,
                  style: AppTextStyles.koerperKleinFett.copyWith(
                    color: getroffen
                        ? AppFarben.textSekundaer
                        : AppFarben.text,
                  ),
                ),
              ),
              if (getroffen)
                const Icon(
                  Icons.check_circle,
                  color: AppFarben.karmaPositiv,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entscheidung.beschreibung,
            style: AppTextStyles.koerperKlein.copyWith(
              color: getroffen
                  ? AppFarben.textTertiaer
                  : AppFarben.textSekundaer,
            ),
          ),

          // Optionen (nur wenn noch nicht getroffen)
          if (!getroffen) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AktionsSchaltflaeche(
                    text: entscheidung.optionA,
                    positiv: true,
                    gesundheitsDelta: entscheidung.gesundheitA,
                    onTap: onA,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AktionsSchaltflaeche(
                    text: entscheidung.optionB,
                    positiv: entscheidung.gesundheitB > 0,
                    gesundheitsDelta: entscheidung.gesundheitB,
                    onTap: onB,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Kleine Aktionsschaltfläche mit Gesundheits-Preview.
class _AktionsSchaltflaeche extends StatelessWidget {
  final String text;
  final bool positiv;
  final int gesundheitsDelta;
  final VoidCallback? onTap;

  const _AktionsSchaltflaeche({
    required this.text,
    required this.positiv,
    required this.gesundheitsDelta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final farbe = positiv ? AppFarben.karmaPositiv : AppFarben.karmaNeutral;
    final prefix = gesundheitsDelta >= 0 ? '+' : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: farbe.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: farbe.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: AppTextStyles.koerperKlein
                  .copyWith(color: AppFarben.text),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$prefix$gesundheitsDelta Gesundheit',
              style: AppTextStyles.mikro.copyWith(color: farbe),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2: Karriere
// ─────────────────────────────────────────────────────────────────────────────

class _KarriereTab extends StatelessWidget {
  final _KarrierePfad? gewaehltePfad;
  final Set<int> getroffeneEntscheidungen;
  final void Function(_KarrierePfad) onPfadWaehlen;
  final void Function(int index, bool optionA) onEntscheidung;

  const _KarriereTab({
    required this.gewaehltePfad,
    required this.getroffeneEntscheidungen,
    required this.onPfadWaehlen,
    required this.onEntscheidung,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Deinen Karrierepfad wählen',
            style: AppTextStyles.ueberschrift3,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 4),
          Text(
            'Was willst du der Welt geben?',
            style: AppTextStyles.koerperKlein,
          ),
          const SizedBox(height: 16),

          // 5 Karrierepfade
          ...List.generate(_karrierePfade.length, (i) {
            final pfad = _karrierePfade[i];
            final istGewaehlt = gewaehltePfad?.titel == pfad.titel;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _KarrierePfadKarte(
                pfad: pfad,
                gewaehlt: istGewaehlt,
                andereGewaehlt: gewaehltePfad != null && !istGewaehlt,
                onWaehlen: gewaehltePfad == null
                    ? () => onPfadWaehlen(pfad)
                    : null,
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 100 + i * 80),
                  ),
            );
          }),

          // Ethik-Dilemmas (nur nach Karrierewahl sichtbar)
          if (gewaehltePfad != null) ...[
            const SizedBox(height: 24),
            Text(
              'Karriere-Dilemmas',
              style: AppTextStyles.ueberschrift3,
            ).animate().fadeIn(),
            const SizedBox(height: 4),
            Text(
              'Entscheidungen, die deinen Ruf prägen.',
              style: AppTextStyles.koerperKlein,
            ),
            const SizedBox(height: 16),

            ...List.generate(_karriereEntscheidungen.length, (i) {
              final e = _karriereEntscheidungen[i];
              final getroffen = getroffeneEntscheidungen.contains(i);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _DilemmaKarte(
                  situation: e.situation,
                  optionA: e.optionA,
                  optionB: e.optionB,
                  getroffen: getroffen,
                  onA: getroffen ? null : () => onEntscheidung(i, true),
                  onB: getroffen ? null : () => onEntscheidung(i, false),
                ).animate().fadeIn(
                      delay: Duration(milliseconds: 200 + i * 100),
                    ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

/// Karte für einen Karrierepfad.
class _KarrierePfadKarte extends StatelessWidget {
  final _KarrierePfad pfad;
  final bool gewaehlt;
  final bool andereGewaehlt;
  final VoidCallback? onWaehlen;

  const _KarrierePfadKarte({
    required this.pfad,
    required this.gewaehlt,
    required this.andereGewaehlt,
    required this.onWaehlen,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: andereGewaehlt ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: onWaehlen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: gewaehlt
                ? pfad.farbe.withValues(alpha: 0.12)
                : AppFarben.oberflaeche,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: gewaehlt
                  ? pfad.farbe
                  : pfad.farbe.withValues(alpha: 0.3),
              width: gewaehlt ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon-Kreis
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pfad.farbe.withValues(alpha: 0.15),
                ),
                child: Icon(pfad.icon, color: pfad.farbe, size: 20),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pfad.titel,
                      style: AppTextStyles.koerperKleinFett
                          .copyWith(color: pfad.farbe),
                    ),
                    Text(
                      pfad.beschreibung,
                      style: AppTextStyles.koerperKlein,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pfad.zeitalterHinweis,
                      style: AppTextStyles.mikro.copyWith(
                        color: pfad.farbe.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              if (gewaehlt)
                const Icon(
                  Icons.check_circle,
                  color: AppFarben.karmaPositiv,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3: Beziehungen
// ─────────────────────────────────────────────────────────────────────────────

class _BeziehungenTab extends StatelessWidget {
  final _BeziehungsKandidat? gewaehltKandidat;
  final Set<int> getroffeneKonflikte;
  final void Function(_BeziehungsKandidat) onKandidatWaehlen;
  final void Function(int index, bool loesen) onKonflikt;

  const _BeziehungenTab({
    required this.gewaehltKandidat,
    required this.getroffeneKonflikte,
    required this.onKandidatWaehlen,
    required this.onKonflikt,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Den richtigen Menschen finden',
            style: AppTextStyles.ueberschrift3,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 4),
          Text(
            'Wen lässt du in dein Herz?',
            style: AppTextStyles.koerperKlein,
          ),
          const SizedBox(height: 16),

          // Kandidaten
          ...List.generate(_kandidaten.length, (i) {
            final kandidat = _kandidaten[i];
            final istGewaehlt =
                gewaehltKandidat?.name == kandidat.name;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _KandidatenKarte(
                kandidat: kandidat,
                gewaehlt: istGewaehlt,
                andereGewaehlt:
                    gewaehltKandidat != null && !istGewaehlt,
                onWaehlen: gewaehltKandidat == null
                    ? () => onKandidatWaehlen(kandidat)
                    : null,
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 100 + i * 100),
                  ),
            );
          }),

          // Konflikte (nach Kandidatenwahl)
          if (gewaehltKandidat != null) ...[
            const SizedBox(height: 24),
            Text(
              'Konflikte & Entscheidungen',
              style: AppTextStyles.ueberschrift3,
            ).animate().fadeIn(),
            const SizedBox(height: 4),
            Text(
              'Jede Beziehung bringt Reibung. Wie gehst du damit um?',
              style: AppTextStyles.koerperKlein,
            ),
            const SizedBox(height: 16),

            ...List.generate(_konflikte.length, (i) {
              final k = _konflikte[i];
              final getroffen = getroffeneKonflikte.contains(i);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _DilemmaKarte(
                  situation: k.situation,
                  optionA: k.optionLoesen,
                  optionB: k.optionIgnorieren,
                  getroffen: getroffen,
                  onA: getroffen ? null : () => onKonflikt(i, true),
                  onB: getroffen ? null : () => onKonflikt(i, false),
                ).animate().fadeIn(
                      delay: Duration(milliseconds: 200 + i * 100),
                    ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

/// Kandidaten-Karte mit Pro/Contra-Liste.
class _KandidatenKarte extends StatelessWidget {
  final _BeziehungsKandidat kandidat;
  final bool gewaehlt;
  final bool andereGewaehlt;
  final VoidCallback? onWaehlen;

  const _KandidatenKarte({
    required this.kandidat,
    required this.gewaehlt,
    required this.andereGewaehlt,
    required this.onWaehlen,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: andereGewaehlt ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: onWaehlen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: gewaehlt
                ? kandidat.farbe.withValues(alpha: 0.1)
                : AppFarben.oberflaeche,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: gewaehlt
                  ? kandidat.farbe
                  : kandidat.farbe.withValues(alpha: 0.3),
              width: gewaehlt ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(kandidat.icon, color: kandidat.farbe, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kandidat.name,
                          style: AppTextStyles.koerperKleinFett
                              .copyWith(color: kandidat.farbe),
                        ),
                        Text(
                          kandidat.beschreibung,
                          style: AppTextStyles.koerperKlein,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (gewaehlt)
                    const Icon(
                      Icons.favorite,
                      color: AppFarben.emotionVerliebt,
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Pro/Contra-Liste
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: kandidat.pros
                          .map((p) => _ProContraZeile(text: p, positiv: true))
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: kandidat.contras
                          .map((c) => _ProContraZeile(text: c, positiv: false))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pro/Contra-Zeile mit farblichem Marker.
class _ProContraZeile extends StatelessWidget {
  final String text;
  final bool positiv;

  const _ProContraZeile({required this.text, required this.positiv});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positiv ? Icons.add : Icons.remove,
            size: 10,
            color:
                positiv ? AppFarben.karmaPositiv : AppFarben.karmaNegatv,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.mikro.copyWith(
                color: positiv
                    ? AppFarben.karmaPositivHell
                    : AppFarben.karmaNegatv.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 4: Seele
// ─────────────────────────────────────────────────────────────────────────────

class _SeelenTab extends StatelessWidget {
  final int aktivitaetenCount;
  final void Function(_SeelenAktivitaet) onAktivitaet;

  const _SeelenTab({
    required this.aktivitaetenCount,
    required this.onAktivitaet,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Die innere Welt pflegen',
            style: AppTextStyles.ueberschrift3,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 4),
          Text(
            'Was du im Inneren kultivierst, prägt alles andere.',
            style: AppTextStyles.koerperKlein,
          ),
          const SizedBox(height: 4),
          Text(
            '${aktivitaetenCount}× praktiziert',
            style: AppTextStyles.beschriftung.copyWith(
              color: AppFarben.emotionSpirituell,
            ),
          ),
          const SizedBox(height: 20),

          // Seelen-Aktivitäten
          ...List.generate(_seelenAktivitaeten.length, (i) {
            final akt = _seelenAktivitaeten[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SeelenAktivitaetenKarte(
                aktivitaet: akt,
                onAktivieren: () => onAktivitaet(akt),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 100 + i * 100),
                  ),
            );
          }),

          // Abschlusszitat
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppFarben.mystischLila.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppFarben.mystischLila.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              '„Das Außen spiegelt das Innen.\n'
              'Kultiviere die Stille, und die Welt wird stiller."',
              style: AppTextStyles.zitat,
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

/// Karte für eine Seelen-Aktivität (mehrfach aktivierbar).
class _SeelenAktivitaetenKarte extends StatefulWidget {
  final _SeelenAktivitaet aktivitaet;
  final VoidCallback onAktivieren;

  const _SeelenAktivitaetenKarte({
    required this.aktivitaet,
    required this.onAktivieren,
  });

  @override
  State<_SeelenAktivitaetenKarte> createState() =>
      _SeelenAktivitaetenKarteState();
}

class _SeelenAktivitaetenKarteState extends State<_SeelenAktivitaetenKarte> {
  bool _aktiv = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onAktivieren();
        setState(() => _aktiv = true);
        Future.delayed(
          const Duration(seconds: 2),
          () {
            if (mounted) setState(() => _aktiv = false);
          },
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _aktiv
              ? widget.aktivitaet.farbe.withValues(alpha: 0.15)
              : AppFarben.oberflaeche,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _aktiv
                ? widget.aktivitaet.farbe
                : widget.aktivitaet.farbe.withValues(alpha: 0.3),
            width: _aktiv ? 2 : 1,
          ),
          boxShadow: _aktiv
              ? [
                  BoxShadow(
                    color: widget.aktivitaet.farbe.withValues(alpha: 0.25),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Aktivitäts-Icon im Kreis
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.aktivitaet.farbe.withValues(alpha: 0.3),
                    widget.aktivitaet.farbe.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Icon(
                widget.aktivitaet.icon,
                color: widget.aktivitaet.farbe,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.aktivitaet.name,
                    style: AppTextStyles.koerperKleinFett.copyWith(
                      color: widget.aktivitaet.farbe,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.aktivitaet.beschreibung,
                    style: AppTextStyles.koerperKlein,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.aktivitaet.wirkung,
                    style: AppTextStyles.mikro.copyWith(
                      color: widget.aktivitaet.farbe.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Aktivierungs-Kreis
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _aktiv
                    ? widget.aktivitaet.farbe
                    : widget.aktivitaet.farbe.withValues(alpha: 0.15),
              ),
              child: Icon(
                _aktiv ? Icons.check : Icons.play_arrow,
                color: _aktiv ? Colors.white : widget.aktivitaet.farbe,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gemeinsames Dilemma-Widget (Karriere + Beziehungen)
// ─────────────────────────────────────────────────────────────────────────────

class _DilemmaKarte extends StatelessWidget {
  final String situation;
  final String optionA;
  final String optionB;
  final bool getroffen;
  final VoidCallback? onA;
  final VoidCallback? onB;

  const _DilemmaKarte({
    required this.situation,
    required this.optionA,
    required this.optionB,
    required this.getroffen,
    required this.onA,
    required this.onB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: getroffen
            ? AppFarben.oberflaeche.withValues(alpha: 0.5)
            : AppFarben.oberflaecheErhoben,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: getroffen
              ? AppFarben.nebelGrau.withValues(alpha: 0.3)
              : AppFarben.mystischLila.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            situation,
            style: AppTextStyles.koerperKursiv,
          ),

          if (!getroffen) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DilemmaSchaltflaeche(
                    text: optionA,
                    positiv: true,
                    onTap: onA,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DilemmaSchaltflaeche(
                    text: optionB,
                    positiv: false,
                    onTap: onB,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 6),
            Text(
              'Entscheidung getroffen.',
              style: AppTextStyles.beschriftung
                  .copyWith(color: AppFarben.karmaPositiv),
            ),
          ],
        ],
      ),
    );
  }
}

class _DilemmaSchaltflaeche extends StatelessWidget {
  final String text;
  final bool positiv;
  final VoidCallback? onTap;

  const _DilemmaSchaltflaeche({
    required this.text,
    required this.positiv,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final farbe = positiv ? AppFarben.karmaPositiv : AppFarben.karmaNegatv;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: farbe.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: farbe.withValues(alpha: 0.4)),
        ),
        child: Text(
          text,
          style: AppTextStyles.koerperKlein.copyWith(color: AppFarben.text),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AltersUndWeiterLeiste – Alter-Meter + Weiter-Button
// ─────────────────────────────────────────────────────────────────────────────

class _AltersUndWeiterLeiste extends StatelessWidget {
  final int alter;
  final bool kannWeiter;
  final VoidCallback onWeiter;

  const _AltersUndWeiterLeiste({
    required this.alter,
    required this.kannWeiter,
    required this.onWeiter,
  });

  @override
  Widget build(BuildContext context) {
    // Fortschritt von 20 bis 60 (0.0 – 1.0)
    final alterFortschritt = ((alter - 20) / 40.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        border: Border(
          top: BorderSide(
            color: AppFarben.goldGlanz.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Alters-Fortschrittsbalken
          Row(
            children: [
              Text(
                '20',
                style: AppTextStyles.mikro
                    .copyWith(color: AppFarben.textTertiaer),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: alterFortschritt,
                        minHeight: 8,
                        backgroundColor:
                            AppFarben.nebelGrau.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppFarben.phaseBluete,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Alter $alter',
                      style: AppTextStyles.mikro.copyWith(
                        color: AppFarben.phaseBluete,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '60',
                style: AppTextStyles.mikro
                    .copyWith(color: AppFarben.textTertiaer),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Weiter-Button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: kannWeiter ? onWeiter : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: kannWeiter
                      ? AppFarben.phaseBluete.withValues(alpha: 0.15)
                      : AppFarben.nebelGrau.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: kannWeiter
                        ? AppFarben.phaseBluete.withValues(alpha: 0.6)
                        : AppFarben.nebelGrau.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  kannWeiter
                      ? 'DAS LEBEN REIFT WEITER'
                      : 'KARRIEREPFAD WÄHLEN & ALTER 40 ERREICHEN',
                  style: AppTextStyles.buttonPrimaer.copyWith(
                    color: kannWeiter
                        ? AppFarben.phaseBluete
                        : AppFarben.textTertiaer,
                    fontSize: kannWeiter ? 13 : 10,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
