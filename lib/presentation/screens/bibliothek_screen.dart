// bibliothek_screen.dart
// Seelenbibliothek-Screen für GENESIS: Der Kreislauf des Lebens.
// Zeigt alle gesammelten Zyklen, Gedanken, Weisheiten und Ahnenreihe
// in einer TabBar-Struktur mit kosmischer Bibliotheks-Ästhetik.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BibliothekScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Seelenbibliothek – zeigt alle gesammelten Inhalte des Spielers.
///
/// Die vier Tabs:
/// 1. Leben – alle abgeschlossenen Lebenszyklen
/// 2. Gedanken – mitgenommene Gedanken als Karten
/// 3. Weisheiten – freigeschaltete Weisheiten
/// 4. Ahnenreihe – Stammbaum-Platzhalter
class BibliothekScreen extends ConsumerWidget {
  const BibliothekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppFarben.kosmischSchwarz,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppFarben.kosmischViolett.withValues(alpha: 0.6),
                AppFarben.kosmischSchwarz,
              ],
              stops: const [0.0, 0.4],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Kopfzeile ────────────────────────────────────────────
                _BibliothekKopfzeile(
                  onZurueck: () => context.go(AppRouten.hauptMenue),
                ),

                // ── Dekorative goldene Bücherrücken-Silhouette ───────────
                const _BuecherSilhouette(),

                const SizedBox(height: 8),

                // ── TabBar ────────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppFarben.oberflaeche,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppFarben.goldGlanz.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: TabBar(
                    labelColor: AppFarben.goldGlanz,
                    unselectedLabelColor: AppFarben.textTertiaer,
                    indicatorColor: AppFarben.goldGlanz,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyles.beschriftungGross.copyWith(
                      color: AppFarben.goldGlanz,
                      letterSpacing: 0.8,
                    ),
                    unselectedLabelStyle: AppTextStyles.beschriftungGross,
                    tabs: const [
                      Tab(text: 'Leben'),
                      Tab(text: 'Gedanken'),
                      Tab(text: 'Weisheiten'),
                      Tab(text: 'Ahnenreihe'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Tab-Inhalte ───────────────────────────────────────────
                const Expanded(
                  child: TabBarView(
                    children: [
                      _LifeTab(),
                      _GedankenTab(),
                      _WeisheitenTab(),
                      _AhnenreiheTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kopfzeile der Bibliothek
// ─────────────────────────────────────────────────────────────────────────────

class _BibliothekKopfzeile extends StatelessWidget {
  final VoidCallback onZurueck;

  const _BibliothekKopfzeile({required this.onZurueck});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          // Zurück-Button
          IconButton(
            onPressed: onZurueck,
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: AppFarben.goldGlanz,
            tooltip: 'Zurück',
          ),

          const SizedBox(width: 8),

          // Titel
          Text(
            'Seelenbibliothek',
            style: AppTextStyles.ueberschrift3.copyWith(
              color: AppFarben.goldGlanz,
              fontSize: 20,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms),

          const Spacer(),

          // Bibliotheks-Icon
          const Icon(
            Icons.menu_book,
            color: AppFarben.goldDunkel,
            size: 22,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dekorative Bücherrücken-Silhouette
// ─────────────────────────────────────────────────────────────────────────────

/// Eine stilisierte Silhouette von Bücherrücken für die kosmische Bibliotheks-Ästhetik.
class _BuecherSilhouette extends StatelessWidget {
  const _BuecherSilhouette();

  @override
  Widget build(BuildContext context) {
    // Einfache stilisierte Bücherrücken als Container-Reihe
    const buecherFarben = [
      Color(0xFF1A0F3C),
      Color(0xFF2D1B69),
      Color(0xFF0D1B2A),
      Color(0xFF1A0F3C),
      Color(0xFF0A0F1A),
      Color(0xFF2D1B69),
      Color(0xFF1A0F3C),
      Color(0xFF0D1B2A),
      Color(0xFF2D1B69),
    ];

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: buecherFarben.asMap().entries.map((e) {
            final index = e.key;
            final farbe = e.value;
            // Unterschiedliche Höhen für realistische Silhouette
            final hoehen = [38.0, 44.0, 32.0, 48.0, 36.0, 42.0, 28.0, 46.0, 34.0];
            final hoehe = hoehen[index % hoehen.length];

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Container(
                  height: hoehe,
                  decoration: BoxDecoration(
                    color: farbe,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                    border: Border.all(
                      color: AppFarben.goldGlanz.withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1: Leben
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt alle abgeschlossenen Lebenszyklen des Spielers.
class _LifeTab extends StatelessWidget {
  const _LifeTab();

  @override
  Widget build(BuildContext context) {
    // Aktuell leer – wird später aus der Datenbank geladen
    const zyklen = <Map<String, dynamic>>[];

    if (zyklen.isEmpty) {
      return _LeererZustand(
        icon: Icons.self_improvement,
        titel: 'Kein Leben gelebt',
        beschreibung:
            'Deine Geschichte beginnt erst...\n\nSchließe dein erstes Leben ab, um es hier zu sehen. Jeder Zyklus hinterlässt eine einzigartige Spur in der Seelenbibliothek.',
        farbe: AppFarben.phaseKindheit,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: zyklen.length,
      itemBuilder: (context, index) {
        final zyklus = zyklen[index];
        return _ZyklusKarte(zyklus: zyklus);
      },
    );
  }
}

/// Eine Karte für einen einzelnen abgeschlossenen Lebenszyklus.
class _ZyklusKarte extends StatelessWidget {
  final Map<String, dynamic> zyklus;

  const _ZyklusKarte({required this.zyklus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppFarben.goldGlanz.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            zyklus['name'] as String? ?? 'Unbekanntes Leben',
            style: AppTextStyles.erinnerungsTitel,
          ),
          const SizedBox(height: 4),
          Text(
            zyklus['beschreibung'] as String? ?? '',
            style: AppTextStyles.koerperKlein,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2: Gedanken
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt alle mitgenommenen Gedanken des Spielers als Karten.
class _GedankenTab extends StatelessWidget {
  const _GedankenTab();

  @override
  Widget build(BuildContext context) {
    // Aktuell leer – wird später aus der Datenbank geladen
    const gedanken = <Map<String, dynamic>>[];

    if (gedanken.isEmpty) {
      return _LeererZustand(
        icon: Icons.psychology_outlined,
        titel: 'Keine Gedanken gesammelt',
        beschreibung:
            'Besondere Erkenntnisse aus deinen Leben erscheinen hier.\n\nManche Gedanken sind so tief, dass sie den Tod überleben und in die nächste Inkarnation mitgenommen werden.',
        farbe: AppFarben.emotionSpirituell,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: gedanken.length,
      itemBuilder: (context, index) {
        final gedanke = gedanken[index];
        return _GedankeKarte(gedanke: gedanke);
      },
    );
  }
}

/// Eine einzelne Gedanken-Karte.
class _GedankeKarte extends StatelessWidget {
  final Map<String, dynamic> gedanke;

  const _GedankeKarte({required this.gedanke});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppFarben.emotionSpirituell.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote,
            color: AppFarben.goldDunkel,
            size: 20,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              gedanke['text'] as String? ?? '',
              style: AppTextStyles.gedanke,
              overflow: TextOverflow.fade,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gedanke['herkunft'] as String? ?? '',
            style: AppTextStyles.mikro,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3: Weisheiten
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt alle freigeschalteten Weisheiten des Spielers.
class _WeisheitenTab extends StatelessWidget {
  const _WeisheitenTab();

  @override
  Widget build(BuildContext context) {
    // Aktuell leer – wird später durch Spielfortschritt befüllt
    const weisheiten = <Map<String, dynamic>>[];

    if (weisheiten.isEmpty) {
      return _LeererZustand(
        icon: Icons.auto_awesome,
        titel: 'Noch keine Weisheiten',
        beschreibung:
            'Weisheiten werden durch besondere Entscheidungen und das Erreichen von Meilensteinen freigeschaltet.\n\nLebe mehrere Zyklen, um die tiefsten Geheimnisse der Existenz zu entdecken.',
        farbe: AppFarben.goldGlanz,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: weisheiten.length,
      itemBuilder: (context, index) {
        final weisheit = weisheiten[index];
        return _WeisheitKarte(weisheit: weisheit);
      },
    );
  }
}

/// Eine einzelne Weisheits-Karte.
class _WeisheitKarte extends StatelessWidget {
  final Map<String, dynamic> weisheit;

  const _WeisheitKarte({required this.weisheit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppFarben.goldGlanz.withValues(alpha: 0.08),
            AppFarben.oberflaeche,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppFarben.goldGlanz.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppFarben.goldGlanz,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                weisheit['kategorie'] as String? ?? 'Weisheit',
                style: AppTextStyles.beschriftungGross.copyWith(
                  color: AppFarben.goldDunkel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            weisheit['text'] as String? ?? '',
            style: AppTextStyles.zitat,
          ),
          if (weisheit['quelle'] != null) ...[
            const SizedBox(height: 8),
            Text(
              '– ${weisheit['quelle']}',
              style: AppTextStyles.mikro.copyWith(
                color: AppFarben.textTertiaer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 4: Ahnenreihe
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt den Stammbaum aller gespielten Seelen (Platzhalter).
class _AhnenreiheTab extends StatelessWidget {
  const _AhnenreiheTab();

  @override
  Widget build(BuildContext context) {
    return _LeererZustand(
      icon: Icons.account_tree_outlined,
      titel: 'Ahnenreihe noch nicht zugänglich',
      beschreibung:
          'Der Stammbaum deiner Seele entfaltet sich über viele Inkarnationen.\n\nMit jedem vollendeten Leben wächst dein Stammbaum um einen neuen Ast. Drei abgeschlossene Zyklen sind notwendig, um die Ahnenreihe freizuschalten.',
      farbe: AppFarben.phaseWeisheit,
      zusatzWidget: _AhnenreiheVorschau(),
    );
  }
}

/// Stilisierte Vorschau eines Stammbaums.
class _AhnenreiheVorschau extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppFarben.phaseWeisheit.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Wurzel-Knoten
          _StammbaumKnoten(
            label: '?',
            istAktiv: false,
            ebene: 0,
          ),

          const SizedBox(height: 8),

          // Verbindungslinien
          Container(
            width: 2,
            height: 24,
            color: AppFarben.nebelGrau.withValues(alpha: 0.3),
          ),

          // Zwei Äste
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StammbaumKnoten(label: '?', istAktiv: false, ebene: 1),
              _StammbaumKnoten(label: '?', istAktiv: false, ebene: 1),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Starte 3 Zyklen um deinen Stammbaum zu enthüllen',
            style: AppTextStyles.beschriftung.copyWith(
              color: AppFarben.textTertiaer,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Ein einzelner Knoten im Stammbaum.
class _StammbaumKnoten extends StatelessWidget {
  final String label;
  final bool istAktiv;
  final int ebene;

  const _StammbaumKnoten({
    required this.label,
    required this.istAktiv,
    required this.ebene,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: istAktiv
            ? AppFarben.phaseWeisheit.withValues(alpha: 0.3)
            : AppFarben.nebelGrau.withValues(alpha: 0.15),
        border: Border.all(
          color: istAktiv
              ? AppFarben.phaseWeisheit
              : AppFarben.nebelGrau.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.beschriftungGross.copyWith(
            color: istAktiv ? AppFarben.phaseWeisheit : AppFarben.textTertiaer,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Leerer Zustand
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt einen stilisierten leeren Zustand mit Icon, Titel und Beschreibung.
class _LeererZustand extends StatelessWidget {
  final IconData icon;
  final String titel;
  final String beschreibung;
  final Color farbe;
  final Widget? zusatzWidget;

  const _LeererZustand({
    required this.icon,
    required this.titel,
    required this.beschreibung,
    required this.farbe,
    this.zusatzWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Icon-Kreis
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: farbe.withValues(alpha: 0.1),
              border: Border.all(
                color: farbe.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: farbe.withValues(alpha: 0.7),
              size: 36,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 500.ms),

          const SizedBox(height: 20),

          Text(
            titel,
            style: AppTextStyles.ueberschrift3.copyWith(
              color: farbe.withValues(alpha: 0.9),
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 150.ms),

          const SizedBox(height: 12),

          Text(
            beschreibung,
            style: AppTextStyles.koerperKlein.copyWith(
              color: AppFarben.textSekundaer,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms),

          if (zusatzWidget != null) ...[
            const SizedBox(height: 8),
            zusatzWidget!
                .animate()
                .fadeIn(duration: 500.ms, delay: 500.ms),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
