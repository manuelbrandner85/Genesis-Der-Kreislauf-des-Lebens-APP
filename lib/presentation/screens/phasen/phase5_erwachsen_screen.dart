// phase5_erwachsen_screen.dart
// Phase 5 – Das Erwachsenenleben für GENESIS: Der Kreislauf des Lebens.
// Grand-Strategy Screen mit 4 Tabs: Leben, Karriere, Beziehungen, Seele.
// Zeigt alle Lebensbereiche des Erwachsenenlebens (Alter 19–40).

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/karma_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/genesis_button.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/karma_anzeige.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/emissions_wetter_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase5ErwachsenScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Grand-Strategy Screen für Phase 5 (Erwachsenenleben, Alter 19–40).
///
/// 4 Bottom-Navigation-Tabs:
/// - Tab 0 "Leben": Aktuelle Situation, Zufallsereignisse
/// - Tab 1 "Karriere": 50+ Karrierepfade als Karten
/// - Tab 2 "Beziehungen": Netzwerk-Kreis-Visualisierung
/// - Tab 3 "Seele": Karma, Gedanken, Mentale Gesundheit
class Phase5ErwachsenScreen extends ConsumerStatefulWidget {
  const Phase5ErwachsenScreen({super.key});

  @override
  ConsumerState<Phase5ErwachsenScreen> createState() =>
      _Phase5ErwachsenScreenState();
}

class _Phase5ErwachsenScreenState extends ConsumerState<Phase5ErwachsenScreen>
    with SingleTickerProviderStateMixin {
  // Aktiver Tab-Index
  int _aktiverTab = 0;

  // Simulierter Spieler-Zustand (in der vollständigen Impl. aus SpielProvider)
  int _alter = 24;
  String _wohnort = 'Stadtmitte';
  String _beruf = 'Noch nicht gewählt';
  String _beziehungsStatus = 'Single';
  double _mentaleGesundheit = 0.72;
  bool _hatAktuellesEreignis = false;

  @override
  void initState() {
    super.initState();
    // Zufallsereignis mit 40% Wahrscheinlichkeit beim Start
    _hatAktuellesEreignis = math.Random().nextDouble() < 0.4;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final karma = ref.watch(karmaProvider);

    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      appBar: _Phase5AppBar(alter: _alter),
      body: IndexedStack(
        index: _aktiverTab,
        children: [
          // Tab 0: Leben
          _LebenTab(
            alter: _alter,
            wohnort: _wohnort,
            beruf: _beruf,
            beziehungsStatus: _beziehungsStatus,
            hatEreignis: _hatAktuellesEreignis,
            onEreignisTap: () => context.go('/phase/5/ereignis'),
            onAlterErhoehen: () => setState(() {
              _alter++;
              _hatAktuellesEreignis = math.Random().nextDouble() < 0.4;
            }),
          ),

          // Tab 1: Karriere
          _KarriereTab(
            aktuellerBeruf: _beruf,
            onBerufGewaehlt: (beruf) => setState(() => _beruf = beruf),
          ),

          // Tab 2: Beziehungen
          const _BeziehungenTab(),

          // Tab 3: Seele
          _SeeleTab(
            karmaProfil: karma,
            mentaleGesundheit: _mentaleGesundheit,
          ),
        ],
      ),
      bottomNavigationBar: _Phase5BottomNav(
        aktiverIndex: _aktiverTab,
        onTabGewechselt: (index) => setState(() => _aktiverTab = index),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App-Bar
// ─────────────────────────────────────────────────────────────────────────────

class _Phase5AppBar extends StatelessWidget implements PreferredSizeWidget {
  final int alter;

  const _Phase5AppBar({required this.alter});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppFarben.tiefesBlau,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppFarben.phaseBluete),
        onPressed: () => context.go(AppRouten.phase(4)),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PHASE V – DAS ERWACHSENENLEBEN',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.phaseBluete,
            ),
          ),
          Text(
            'Alter: $alter Jahre',
            style: AppTextStyles.mikro.copyWith(
              color: AppFarben.textTertiaer,
            ),
          ),
        ],
      ),
      actions: [
        // Schnell-Navigation zur nächsten Phase
        TextButton(
          onPressed: () => context.go(AppRouten.phase(6)),
          child: Text(
            'Phase VI →',
            style: AppTextStyles.beschriftung.copyWith(
              color: AppFarben.phaseBluete.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom-Navigation
// ─────────────────────────────────────────────────────────────────────────────

class _Phase5BottomNav extends StatelessWidget {
  final int aktiverIndex;
  final ValueChanged<int> onTabGewechselt;

  const _Phase5BottomNav({
    required this.aktiverIndex,
    required this.onTabGewechselt,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: aktiverIndex,
      onTap: onTabGewechselt,
      backgroundColor: AppFarben.tiefesBlau,
      selectedItemColor: AppFarben.phaseBluete,
      unselectedItemColor: AppFarben.textTertiaer,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTextStyles.mikro.copyWith(
        color: AppFarben.phaseBluete,
      ),
      unselectedLabelStyle: AppTextStyles.mikro,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Leben',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work),
          label: 'Karriere',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Beziehungen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.self_improvement),
          label: 'Seele',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 0: Leben
// ─────────────────────────────────────────────────────────────────────────────

class _LebenTab extends StatelessWidget {
  final int alter;
  final String wohnort;
  final String beruf;
  final String beziehungsStatus;
  final bool hatEreignis;
  final VoidCallback onEreignisTap;
  final VoidCallback onAlterErhoehen;

  const _LebenTab({
    required this.alter,
    required this.wohnort,
    required this.beruf,
    required this.beziehungsStatus,
    required this.hatEreignis,
    required this.onEreignisTap,
    required this.onAlterErhoehen,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Aktuelle Situation ────────────────────────────────────────────
          Text(
            'AKTUELLE SITUATION',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.phaseBluete,
            ),
          ),
          const SizedBox(height: 12),

          _SituationsGrid(
            alter: alter,
            wohnort: wohnort,
            beruf: beruf,
            beziehungsStatus: beziehungsStatus,
          ),

          const SizedBox(height: 24),

          // ── Zufallsereignis-System ────────────────────────────────────────
          Row(
            children: [
              Text(
                'TAGESEREIGNIS',
                style: AppTextStyles.beschriftungGross.copyWith(
                  color: AppFarben.phaseBluete,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onAlterErhoehen,
                icon: const Icon(Icons.skip_next,
                    size: 16, color: AppFarben.textTertiaer),
                label: Text(
                  'Nächster Tag',
                  style: AppTextStyles.beschriftung,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (hatEreignis)
            _EreignisKarte(onTap: onEreignisTap)
          else
            _KeinEreignisKarte(),

          const SizedBox(height: 24),

          // ── Lebens-Fortschritt ────────────────────────────────────────────
          Text(
            'LEBENSFORTSCHRITT',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.phaseBluete,
            ),
          ),
          const SizedBox(height: 12),
          _LebensfortschrittsBalken(alter: alter),
        ],
      ),
    );
  }
}

class _SituationsGrid extends StatelessWidget {
  final int alter;
  final String wohnort;
  final String beruf;
  final String beziehungsStatus;

  const _SituationsGrid({
    required this.alter,
    required this.wohnort,
    required this.beruf,
    required this.beziehungsStatus,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.cake, 'label': 'Alter', 'wert': '$alter Jahre'},
      {'icon': Icons.location_city, 'label': 'Wohnort', 'wert': wohnort},
      {'icon': Icons.work_outline, 'label': 'Beruf', 'wert': beruf},
      {'icon': Icons.favorite_outline, 'label': 'Beziehung', 'wert': beziehungsStatus},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppFarben.oberflaecheErhoben,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppFarben.phaseBluete.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(item['icon'] as IconData,
                  color: AppFarben.phaseBluete, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['label'] as String,
                      style: AppTextStyles.mikro,
                    ),
                    Text(
                      item['wert'] as String,
                      style: AppTextStyles.koerperKleinFett,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _EreignisKarte extends StatelessWidget {
  final VoidCallback onTap;

  // Zufallsereignis-Pool (wird in der Vollimplementierung aus JSON geladen)
  static const List<Map<String, dynamic>> _ereignisPool = [
    {
      'titel': 'Unerwartete Beförderung',
      'beschreibung': 'Dein Chef bietet dir eine leitende Position an.',
      'typ': 'positiv',
      'icon': Icons.trending_up,
    },
    {
      'titel': 'Gesundheitliche Beschwerde',
      'beschreibung': 'Du fühlst dich seit Tagen nicht gut. Zum Arzt gehen?',
      'typ': 'neutral',
      'icon': Icons.medical_services,
    },
    {
      'titel': 'Lottogewinn – Kleiner Betrag',
      'beschreibung': 'Du hast 500€ gewonnen. Was machst du damit?',
      'typ': 'positiv',
      'icon': Icons.casino,
    },
    {
      'titel': 'Neue Bekanntschaft',
      'beschreibung': 'Eine faszinierende Person tritt in dein Leben.',
      'typ': 'positiv',
      'icon': Icons.person_add,
    },
    {
      'titel': 'Reisechance',
      'beschreibung': 'Du hast die Möglichkeit, drei Monate ins Ausland zu gehen.',
      'typ': 'neutral',
      'icon': Icons.flight,
    },
  ];

  const _EreignisKarte({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Tagesbasierte Zufallsauswahl (deterministisch für den Tag)
    final index = DateTime.now().day % _ereignisPool.length;
    final ereignis = _ereignisPool[index];
    final istPositiv = ereignis['typ'] == 'positiv';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppFarben.oberflaecheErhoben,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: istPositiv
                ? AppFarben.phaseBluete.withValues(alpha: 0.5)
                : AppFarben.karmaNeutral.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppFarben.phaseBluete.withValues(alpha: 0.1),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppFarben.phaseBluete.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                ereignis['icon'] as IconData,
                color: AppFarben.phaseBluete,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ereignis['titel'] as String,
                    style: AppTextStyles.koerperKleinFett,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ereignis['beschreibung'] as String,
                    style: AppTextStyles.koerperKlein,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppFarben.goldGlanz.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppFarben.goldGlanz.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'REAGIEREN',
                style: AppTextStyles.mikro.copyWith(
                  color: AppFarben.goldGlanz,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .shimmer(duration: 1500.ms, color: AppFarben.phaseBluete.withValues(alpha: 0.1));
  }
}

class _KeinEreignisKarte extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppFarben.nebelGrau.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined,
              color: AppFarben.textTertiaer, size: 24),
          const SizedBox(width: 12),
          Text(
            'Ein ruhiger Tag – keine besonderen Ereignisse.',
            style: AppTextStyles.koerperKlein.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _LebensfortschrittsBalken extends StatelessWidget {
  final int alter;

  const _LebensfortschrittsBalken({required this.alter});

  @override
  Widget build(BuildContext context) {
    // Phase 5: Alter 19–40 (21 Jahre Spanne)
    final fortschritt = ((alter - 19) / 21.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppFarben.oberflaecheErhoben,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('19 J.', style: AppTextStyles.mikro),
              Text(
                'Phase V – Erwachsen',
                style: AppTextStyles.beschriftung.copyWith(
                  color: AppFarben.phaseBluete,
                ),
              ),
              Text('40 J.', style: AppTextStyles.mikro),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fortschritt,
              backgroundColor: AppFarben.nebelGrau.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppFarben.phaseBluete,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(fortschritt * 100).toInt()}% der Phase abgeschlossen',
            style: AppTextStyles.mikro.copyWith(
              color: AppFarben.textTertiaer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1: Karriere
// ─────────────────────────────────────────────────────────────────────────────

class _KarriereTab extends StatefulWidget {
  final String aktuellerBeruf;
  final ValueChanged<String> onBerufGewaehlt;

  const _KarriereTab({
    required this.aktuellerBeruf,
    required this.onBerufGewaehlt,
  });

  @override
  State<_KarriereTab> createState() => _KarriereTabState();
}

class _KarriereTabState extends State<_KarriereTab> {
  String _gewaehlterFilter = 'Alle';

  // Karrierepfade mit Zeitalter-Zuordnung (gefiltert nach Moderne als Standard)
  static const List<Map<String, dynamic>> _karrierePfade = [
    {'name': 'Arzt/Ärztin', 'kategorie': 'Gesundheit', 'skill': 'Intelligenz 70+', 'gehalt': '★★★★', 'icon': Icons.medical_services},
    {'name': 'Lehrer/Lehrerin', 'kategorie': 'Bildung', 'skill': 'Empathie 50+', 'gehalt': '★★★', 'icon': Icons.school},
    {'name': 'Software-Entwickler/in', 'kategorie': 'Technologie', 'skill': 'Intelligenz 60+', 'gehalt': '★★★★', 'icon': Icons.code},
    {'name': 'Künstler/in', 'kategorie': 'Kunst', 'skill': 'Kreativität 70+', 'gehalt': '★★', 'icon': Icons.palette},
    {'name': 'Unternehmer/in', 'kategorie': 'Wirtschaft', 'skill': 'Kraft 40+ & Int 50+', 'gehalt': '★★★★★', 'icon': Icons.business},
    {'name': 'Sozialarbeiter/in', 'kategorie': 'Soziales', 'skill': 'Empathie 65+', 'gehalt': '★★', 'icon': Icons.volunteer_activism},
    {'name': 'Wissenschaftler/in', 'kategorie': 'Forschung', 'skill': 'Intelligenz 75+', 'gehalt': '★★★', 'icon': Icons.science},
    {'name': 'Journalist/in', 'kategorie': 'Medien', 'skill': 'Kreativität 55+', 'gehalt': '★★★', 'icon': Icons.article},
    {'name': 'Ingenieur/in', 'kategorie': 'Technologie', 'skill': 'Intelligenz 65+', 'gehalt': '★★★★', 'icon': Icons.engineering},
    {'name': 'Psycholog/in', 'kategorie': 'Gesundheit', 'skill': 'Empathie 70+', 'gehalt': '★★★', 'icon': Icons.psychology},
    {'name': 'Sportler/in', 'kategorie': 'Sport', 'skill': 'Kraft 75+', 'gehalt': '★★★', 'icon': Icons.sports},
    {'name': 'Politiker/in', 'kategorie': 'Politik', 'skill': 'Intuition 60+', 'gehalt': '★★★', 'icon': Icons.account_balance},
  ];

  static const List<String> _kategorien = [
    'Alle', 'Gesundheit', 'Technologie', 'Bildung', 'Kunst', 'Wirtschaft', 'Soziales', 'Forschung',
  ];

  List<Map<String, dynamic>> get _gefiltert {
    if (_gewaehlterFilter == 'Alle') return _karrierePfade;
    return _karrierePfade
        .where((k) => k['kategorie'] == _gewaehlterFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aktueller Beruf-Banner
        Container(
          padding: const EdgeInsets.all(14),
          color: AppFarben.tiefesBlau,
          child: Row(
            children: [
              const Icon(Icons.work, color: AppFarben.phaseBluete, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aktueller Beruf', style: AppTextStyles.mikro),
                  Text(
                    widget.aktuellerBeruf,
                    style: AppTextStyles.koerperKleinFett.copyWith(
                      color: AppFarben.phaseBluete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Kategorie-Filter
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: _kategorien.length,
            itemBuilder: (context, i) {
              final istAktiv = _kategorien[i] == _gewaehlterFilter;
              return GestureDetector(
                onTap: () =>
                    setState(() => _gewaehlterFilter = _kategorien[i]),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: istAktiv
                        ? AppFarben.phaseBluete.withValues(alpha: 0.2)
                        : AppFarben.oberflaeche,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: istAktiv
                          ? AppFarben.phaseBluete
                          : AppFarben.nebelGrau.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _kategorien[i],
                    style: AppTextStyles.beschriftung.copyWith(
                      color: istAktiv
                          ? AppFarben.phaseBluete
                          : AppFarben.textTertiaer,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Karriere-Karten
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _gefiltert.length,
            itemBuilder: (context, i) {
              final karriere = _gefiltert[i];
              final istAktiv = karriere['name'] == widget.aktuellerBeruf;
              return _KarriereKarte(
                karriere: karriere,
                istAktiv: istAktiv,
                onGewaehlt: () => widget.onBerufGewaehlt(karriere['name']),
                delay: Duration(milliseconds: i * 40),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _KarriereKarte extends StatelessWidget {
  final Map<String, dynamic> karriere;
  final bool istAktiv;
  final VoidCallback onGewaehlt;
  final Duration delay;

  const _KarriereKarte({
    required this.karriere,
    required this.istAktiv,
    required this.onGewaehlt,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onGewaehlt,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: istAktiv
              ? AppFarben.phaseBluete.withValues(alpha: 0.15)
              : AppFarben.oberflaecheErhoben,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: istAktiv
                ? AppFarben.phaseBluete.withValues(alpha: 0.6)
                : AppFarben.nebelGrau.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppFarben.phaseBluete.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                karriere['icon'] as IconData,
                color: istAktiv
                    ? AppFarben.phaseBluete
                    : AppFarben.textSekundaer,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(karriere['name'] as String,
                      style: AppTextStyles.koerperKleinFett.copyWith(
                        color: istAktiv
                            ? AppFarben.phaseBluete
                            : AppFarben.text,
                      )),
                  Row(
                    children: [
                      Text(karriere['kategorie'] as String,
                          style: AppTextStyles.mikro),
                      const Text(' · ',
                          style: TextStyle(color: AppFarben.textTertiaer)),
                      Text(karriere['skill'] as String,
                          style: AppTextStyles.mikro),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              karriere['gehalt'] as String,
              style: AppTextStyles.beschriftung.copyWith(
                color: AppFarben.goldGlanz,
              ),
            ),
            if (istAktiv) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle,
                  color: AppFarben.phaseBluete, size: 18),
            ],
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2: Beziehungen (Netzwerk-Visualisierung)
// ─────────────────────────────────────────────────────────────────────────────

class _BeziehungenTab extends StatelessWidget {
  const _BeziehungenTab();

  static const List<Map<String, dynamic>> _beziehungen = [
    {'name': 'Partner/in', 'typ': 'Romantisch', 'staerke': 0.85, 'farbe': 0xFFFF69B4},
    {'name': 'Beste Freundin', 'typ': 'Freundschaft', 'staerke': 0.75, 'farbe': 0xFF87CEEB},
    {'name': 'Mutter', 'typ': 'Familie', 'staerke': 0.65, 'farbe': 0xFF90EE90},
    {'name': 'Vater', 'typ': 'Familie', 'staerke': 0.50, 'farbe': 0xFF90EE90},
    {'name': 'Kollege', 'typ': 'Beruflich', 'staerke': 0.40, 'farbe': 0xFFFFD700},
    {'name': 'Mentor', 'typ': 'Beruflich', 'staerke': 0.60, 'farbe': 0xFFFFD700},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BEZIEHUNGS-NETZWERK',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.phaseBluete,
            ),
          ),
          const SizedBox(height: 16),

          // Kreis-Visualisierung
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _NetzwerkPainter(beziehungen: _beziehungen),
              ),
            ),
          ).animate().fadeIn(duration: 700.ms).scale(
              begin: const Offset(0.8, 0.8), duration: 600.ms),

          const SizedBox(height: 20),

          // Beziehungs-Liste
          Text(
            'ALLE BEZIEHUNGEN',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.phaseBluete,
            ),
          ),
          const SizedBox(height: 8),
          ..._beziehungen.asMap().entries.map((entry) {
            final b = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppFarben.oberflaecheErhoben,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        Color(b['farbe'] as int).withValues(alpha: 0.3),
                    child: Text(
                      (b['name'] as String)[0],
                      style: TextStyle(
                        color: Color(b['farbe'] as int),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b['name'] as String,
                            style: AppTextStyles.koerperKleinFett),
                        Text(b['typ'] as String,
                            style: AppTextStyles.mikro),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: b['staerke'] as double,
                        backgroundColor:
                            AppFarben.nebelGrau.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(b['farbe'] as int),
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right,
                      color: AppFarben.textTertiaer, size: 18),
                ],
              ),
            )
                .animate(
                    delay: Duration(milliseconds: entry.key * 60))
                .fadeIn(duration: 350.ms);
          }),
        ],
      ),
    );
  }
}

/// Zeichnet das Beziehungs-Netzwerk als Kreis-Visualisierung.
class _NetzwerkPainter extends CustomPainter {
  final List<Map<String, dynamic>> beziehungen;

  const _NetzwerkPainter({required this.beziehungen});

  @override
  void paint(Canvas canvas, Size size) {
    final zentrum = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Spieler in der Mitte
    final spielerPaint = Paint()
      ..color = AppFarben.phaseBluete
      ..style = PaintingStyle.fill;
    canvas.drawCircle(zentrum, 20, spielerPaint);

    // Beschriftung "DU" in der Mitte
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'DU',
        style: TextStyle(
          color: AppFarben.kosmischSchwarz,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      zentrum - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Beziehungs-Knoten im Kreis
    for (int i = 0; i < beziehungen.length; i++) {
      final b = beziehungen[i];
      final winkel = (2 * math.pi / beziehungen.length) * i - math.pi / 2;
      final pos = Offset(
        zentrum.dx + radius * math.cos(winkel),
        zentrum.dy + radius * math.sin(winkel),
      );

      final farbe = Color(b['farbe'] as int);
      final staerke = b['staerke'] as double;

      // Verbindungslinie
      final liniePaint = Paint()
        ..color = farbe.withValues(alpha: staerke * 0.5)
        ..strokeWidth = staerke * 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(zentrum, pos, liniePaint);

      // Knoten-Kreis
      final knotenPaint = Paint()
        ..color = farbe.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 16, knotenPaint);
      canvas.drawCircle(
        pos,
        16,
        Paint()
          ..color = farbe.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Initialen
      final initialPainter = TextPainter(
        text: TextSpan(
          text: (b['name'] as String)[0],
          style: TextStyle(
            color: farbe,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      initialPainter.paint(
        canvas,
        pos - Offset(initialPainter.width / 2, initialPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_NetzwerkPainter alt) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3: Seele
// ─────────────────────────────────────────────────────────────────────────────

class _SeeleTab extends StatelessWidget {
  final KarmaProfilModel karmaProfil;
  final double mentaleGesundheit;

  const _SeeleTab({
    required this.karmaProfil,
    required this.mentaleGesundheit,
  });

  // Simulierte Gedanken-Liste (aus GedankenProvider in der Vollimplementierung)
  static const List<Map<String, String>> _gedanken = [
    {'inhalt': 'Ich möchte etwas Bleibendes hinterlassen.', 'typ': 'Wunsch'},
    {'inhalt': 'Was, wenn ich die falsche Wahl getroffen habe?', 'typ': 'Angst'},
    {'inhalt': 'Jeder Mensch trägt seine eigene Bürde.', 'typ': 'Weisheit'},
    {'inhalt': 'Liebe bedeutet, Schwäche zulassen zu können.', 'typ': 'Überzeugung'},
  ];

  Color _gedankenTypFarbe(String typ) {
    switch (typ) {
      case 'Wunsch':       return AppFarben.emotionVerliebt;
      case 'Angst':        return AppFarben.emotionAngst;
      case 'Weisheit':     return AppFarben.goldGlanz;
      case 'Überzeugung':  return AppFarben.emotionSpirituell;
      case 'Trauma':       return AppFarben.karmaNegatv;
      default:             return AppFarben.textSekundaer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentaleGesundheitFarbe = mentaleGesundheit >= 0.6
        ? AppFarben.karmaPositiv
        : mentaleGesundheit >= 0.35
            ? AppFarben.karmaNeutral
            : AppFarben.karmaNegatv;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Mentale Gesundheit ────────────────────────────────────────────
          Text(
            'MENTALE GESUNDHEIT',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.phaseBluete,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppFarben.oberflaecheErhoben,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Innere Balance', style: AppTextStyles.koerperKlein),
                    Text(
                      '${(mentaleGesundheit * 100).toInt()}%',
                      style: AppTextStyles.koerperKleinFett.copyWith(
                        color: mentaleGesundheitFarbe,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mentaleGesundheit,
                    backgroundColor:
                        AppFarben.nebelGrau.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      mentaleGesundheitFarbe,
                    ),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // ── Karma-Anzeige (kompakt) ───────────────────────────────────────
          Text(
            'KARMA-PROFIL',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.phaseBluete,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppFarben.oberflaecheErhoben,
              borderRadius: BorderRadius.circular(8),
            ),
            child: KarmaAnzeige(
              karmaProfil: karmaProfil,
              anzeigeTyp: KarmaAnzeigeTyp.kompakt,
              animiert: true,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          const SizedBox(height: 24),

          // ── Gedanken-Inventar ─────────────────────────────────────────────
          Text(
            'GEDANKEN-INVENTAR',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.phaseBluete,
            ),
          ),
          const SizedBox(height: 8),
          ..._gedanken.asMap().entries.map((entry) {
            final g = entry.value;
            final typFarbe = _gedankenTypFarbe(g['typ']!);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppFarben.oberflaecheErhoben,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: typFarbe.withValues(alpha: 0.6),
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '„${g['inhalt']!}"',
                          style: AppTextStyles.koerperKursiv,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          g['typ']!,
                          style: AppTextStyles.mikro.copyWith(
                            color: typFarbe,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: AppFarben.textTertiaer, size: 18),
                ],
              ),
            )
                .animate(
                    delay: Duration(milliseconds: entry.key * 60))
                .fadeIn(duration: 350.ms);
          }),
        ],
      ),
    );
  }
}
