// phase5_zufallsereignis_screen.dart
// Zufallsereignis-Screen für Phase 5 (Erwachsenenleben) in GENESIS.
// Lädt das ECHTE Ereignis aus assets/data/entscheidungen/erwachsen.json
// (Schlüssel 'zufallsereignisse') anhand von [ereignisIndex] und zeigt
// Name, Beschreibung und alle Effekte an.
//
// Effekt-Anwendung:
// - karma      → karmaProvider.dimensionAendern(...)
// - stress     → koerperProvider.lebensstilAnpassen(stressLevel: ...)
// - gesundheit → wirkt heuristisch ÜBER den Stress-Level (die Körper-
//                Simulation kennt keinen direkten Gesundheits-Setter):
//                negative Gesundheit erhöht den Stress zusätzlich,
//                positive senkt ihn leicht.
// - geld       → wird NICHT hier verbucht, sondern beim Schließen via
//                context.pop(<geldDelta>) an Phase 5 zurückgegeben
//                (Phase 5 wertet das Ergebnis von await context.push aus).

import 'dart:convert';
import 'dart:math' as math;

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
import 'package:genesis_kreislauf_des_lebens/presentation/providers/koerper_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Datenmodell: Zufallsereignis aus erwachsen.json
// ─────────────────────────────────────────────────────────────────────────────

/// Ein Zufallsereignis, geparst aus dem 'zufallsereignisse'-Array.
class _EreignisDaten {
  final String id;
  final String name;
  final String beschreibung;
  final double wahrscheinlichkeit;
  final int alterVon;
  final int alterBis;
  final double gesundheit;
  final double geld;
  final double stress;
  final Map<KarmaDimension, double> karma;

  /// Zeitalter-Filter; null oder leer = gilt in jedem Zeitalter.
  final List<String>? zeitalter;

  const _EreignisDaten({
    required this.id,
    required this.name,
    required this.beschreibung,
    required this.wahrscheinlichkeit,
    required this.alterVon,
    required this.alterBis,
    required this.gesundheit,
    required this.geld,
    required this.stress,
    required this.karma,
    required this.zeitalter,
  });

  factory _EreignisDaten.fromJson(Map<String, dynamic> json) {
    final effekte = json['effekte'] as Map<String, dynamic>? ?? {};
    final karmaRoh = effekte['karma'] as Map<String, dynamic>? ?? {};
    final karmaParsed = <KarmaDimension, double>{};
    karmaRoh.forEach((schluessel, wert) {
      final dim = _dimensionVonString(schluessel);
      if (dim != null) karmaParsed[dim] = (wert as num).toDouble();
    });

    final zeitalterRoh = json['zeitalter'] as List<dynamic>?;

    return _EreignisDaten(
      id: json['id'] as String,
      name: json['name'] as String,
      beschreibung: json['beschreibung'] as String,
      wahrscheinlichkeit:
          (json['wahrscheinlichkeit'] as num?)?.toDouble() ?? 0.0,
      alterVon: (json['alterVon'] as num?)?.toInt() ?? 0,
      alterBis: (json['alterBis'] as num?)?.toInt() ?? 120,
      gesundheit: (effekte['gesundheit'] as num?)?.toDouble() ?? 0.0,
      geld: (effekte['geld'] as num?)?.toDouble() ?? 0.0,
      stress: (effekte['stress'] as num?)?.toDouble() ?? 0.0,
      karma: karmaParsed,
      zeitalter: zeitalterRoh?.cast<String>(),
    );
  }

  /// Gilt das Ereignis im gegebenen Zeitalter?
  bool passtZuZeitalter(String zeitalterName) {
    final z = zeitalter;
    if (z == null || z.isEmpty) return true;
    return z.contains(zeitalterName);
  }

  /// Ist das Ereignis insgesamt eher positiv?
  bool get istPositiv => geld + gesundheit * 40 - stress * 2000 >= 0;
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

/// Lokalisierter Name der Karma-Dimension.
String _dimensionName(KarmaDimension dim) {
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

// ─────────────────────────────────────────────────────────────────────────────
// Phase5ZufallsereignisScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Zufallsereignis-Screen für Phase 5.
///
/// [ereignisIndex] ist der Index im GESAMTEN 'zufallsereignisse'-Array der
/// erwachsen.json. Ist er null, wird ein zufälliges, zu Alter und Zeitalter
/// passendes Ereignis gewählt.
///
/// Beim Schließen wird das Geld-Delta des Ereignisses via context.pop(double)
/// an den aufrufenden Screen (Phase 5) zurückgegeben.
class Phase5ZufallsereignisScreen extends ConsumerStatefulWidget {
  /// Index in erwachsen.json → zufallsereignisse (null = zufällig passend).
  final int? ereignisIndex;

  const Phase5ZufallsereignisScreen({super.key, this.ereignisIndex});

  @override
  ConsumerState<Phase5ZufallsereignisScreen> createState() =>
      _Phase5ZufallsereignisScreenState();
}

class _Phase5ZufallsereignisScreenState
    extends ConsumerState<Phase5ZufallsereignisScreen>
    with SingleTickerProviderStateMixin {
  // Geladenes Ereignis (null = lädt noch oder Fehler)
  _EreignisDaten? _ereignis;

  // Ladefehler-Flag (JSON nicht lesbar → Screen schließt sich neutral)
  bool _ladeFehler = false;

  // Effekte dürfen nur genau einmal angewendet werden
  bool _effekteAngewendet = false;

  // Einblend-Animation für die Ereignis-Karte
  late final AnimationController _erscheinController;
  late final Animation<double> _erscheinAnimation;

  @override
  void initState() {
    super.initState();

    _erscheinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _erscheinAnimation = CurvedAnimation(
      parent: _erscheinController,
      curve: Curves.easeOut,
    );

    _ereignisLaden();
  }

  @override
  void dispose() {
    _erscheinController.dispose();
    super.dispose();
  }

  // ── Ereignis aus erwachsen.json laden ─────────────────────────────────────

  Future<void> _ereignisLaden() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/data/entscheidungen/erwachsen.json');
      if (!mounted) return;

      final jsonDaten = jsonDecode(jsonString) as Map<String, dynamic>;
      final listeRoh = jsonDaten['zufallsereignisse'] as List<dynamic>;
      final alle = listeRoh
          .map((e) => _EreignisDaten.fromJson(e as Map<String, dynamic>))
          .toList();

      if (alle.isEmpty) {
        setState(() => _ladeFehler = true);
        return;
      }

      _EreignisDaten gewaehlt;
      final index = widget.ereignisIndex;
      if (index != null && index >= 0 && index < alle.length) {
        gewaehlt = alle[index];
      } else {
        // Kein Index: zufälliges, zu Alter + Zeitalter passendes Ereignis
        final spielZustand = ref.read(spielProvider);
        final alter = spielZustand.aktuellesAlter;
        final zeitalterName =
            spielZustand.aktuellerZyklus?.zeitalter.name ?? '';
        final passende = alle
            .where((e) =>
                alter >= e.alterVon &&
                alter <= e.alterBis &&
                e.passtZuZeitalter(zeitalterName))
            .toList();
        final pool = passende.isNotEmpty ? passende : alle;
        gewaehlt = pool[math.Random().nextInt(pool.length)];
      }

      setState(() => _ereignis = gewaehlt);
      _erscheinController.forward();
      HapticFeedback.mediumImpact();
    } catch (_) {
      if (!mounted) return;
      setState(() => _ladeFehler = true);
    }
  }

  // ── Effekte anwenden + schließen ──────────────────────────────────────────

  /// Wendet Karma-, Stress- und Gesundheits-Effekte genau einmal an und
  /// gibt das Geld-Delta per pop an den Aufrufer zurück.
  void _anwendenUndSchliessen() {
    final ereignis = _ereignis;
    double geldDelta = 0.0;

    if (ereignis != null && !_effekteAngewendet) {
      _effekteAngewendet = true;

      // 1. Karma
      final karmaNotifier = ref.read(karmaProvider.notifier);
      for (final eintrag in ereignis.karma.entries) {
        karmaNotifier.dimensionAendern(eintrag.key, eintrag.value);
      }

      // 2. Stress + Gesundheit (Gesundheit wirkt heuristisch über Stress:
      //    -25 Gesundheit ≈ +0.10 zusätzlicher Stress, +20 ≈ -0.04)
      final koerperNotifier = ref.read(koerperProvider.notifier);
      final aktuellerStress =
          ref.read(koerperProvider).lebensstil.stressLevel;
      final gesundheitAlsStress = ereignis.gesundheit < 0
          ? (-ereignis.gesundheit / 100.0) * 0.4
          : -(ereignis.gesundheit / 100.0) * 0.2;
      final neuerStress = (aktuellerStress + ereignis.stress + gesundheitAlsStress)
          .clamp(0.0, 1.0);
      koerperNotifier.lebensstilAnpassen(stressLevel: neuerStress);

      // 3. Geld → an Phase 5 zurückgeben
      geldDelta = ereignis.geld;
    }

    HapticFeedback.selectionClick();
    if (context.canPop()) {
      context.pop(geldDelta);
    } else {
      // Direktaufruf ohne Stack (z. B. Deep-Link): zurück zu Phase 5
      context.go(AppRouten.phase5);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ereignis = _ereignis;
    final akzentFarbe = ereignis == null
        ? AppFarben.goldGlanz
        : ereignis.istPositiv
            ? AppFarben.goldGlanz
            : AppFarben.karmaNegatv;

    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: Stack(
        children: [
          // Phasen-Artwork-Hintergrund
          const Positioned.fill(
            child: PhasenHintergrund(
              phase: GamePhase.erwachsen,
              abdunkelung: 0.65,
            ),
          ),

          // Hintergrund-Glow passend zur Ereignis-Farbe
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  akzentFarbe.withValues(alpha: 0.08),
                  AppFarben.kosmischSchwarz,
                ],
              ),
            ),
          ),

          // Haupt-Inhalt
          SafeArea(
            child: _ladeFehler
                ? _FehlerAnzeige(onSchliessen: _anwendenUndSchliessen)
                : ereignis == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppFarben.goldGlanz,
                          ),
                        ),
                      )
                    : FadeTransition(
                        opacity: _erscheinAnimation,
                        child: Column(
                          children: [
                            _Kopfzeile(
                              akzentFarbe: akzentFarbe,
                              onSchliessen: _anwendenUndSchliessen,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _EreignisKarte(
                                      ereignis: ereignis,
                                      akzentFarbe: akzentFarbe,
                                    ),
                                    const SizedBox(height: 20),
                                    _EffekteListe(
                                      ereignis: ereignis,
                                      akzentFarbe: akzentFarbe,
                                    ),
                                    const SizedBox(height: 24),
                                    _WeiterButton(
                                      akzentFarbe: akzentFarbe,
                                      onTap: _anwendenUndSchliessen,
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
// Fehler-Anzeige (JSON nicht ladbar)
// ─────────────────────────────────────────────────────────────────────────────

class _FehlerAnzeige extends StatelessWidget {
  final VoidCallback onSchliessen;

  const _FehlerAnzeige({required this.onSchliessen});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off,
              color: AppFarben.textTertiaer, size: 40),
          const SizedBox(height: 12),
          Text(
            'Das Schicksal schweigt heute.',
            style: AppTextStyles.koerper
                .copyWith(color: AppFarben.textSekundaer),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onSchliessen,
            child: Text(
              'Zurück zum Leben',
              style: AppTextStyles.beschriftung
                  .copyWith(color: AppFarben.goldGlanz),
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
  final VoidCallback onSchliessen;

  const _Kopfzeile({required this.akzentFarbe, required this.onSchliessen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: akzentFarbe.withValues(alpha: 0.7)),
            onPressed: onSchliessen,
          ),
          Text(
            'SCHICKSALSMOMENT',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: akzentFarbe,
            ),
          ),
          const Spacer(),
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
  final _EreignisDaten ereignis;
  final Color akzentFarbe;

  const _EreignisKarte({required this.ereignis, required this.akzentFarbe});

  IconData get _icon {
    if (ereignis.gesundheit < 0) return Icons.healing;
    if (ereignis.geld > 0) return Icons.auto_awesome;
    if (ereignis.geld < 0) return Icons.trending_down;
    return Icons.stars_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppFarben.oberflaecheErhoben,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: akzentFarbe.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: akzentFarbe.withValues(alpha: 0.1),
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
                  color: akzentFarbe.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: akzentFarbe.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(_icon, color: akzentFarbe, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  ereignis.name,
                  style: AppTextStyles.ueberschrift4.copyWith(
                    color: akzentFarbe,
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
                  akzentFarbe.withValues(alpha: 0.4),
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
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.05, end: 0, duration: 450.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Effekte-Liste
// ─────────────────────────────────────────────────────────────────────────────

class _EffekteListe extends StatelessWidget {
  final _EreignisDaten ereignis;
  final Color akzentFarbe;

  const _EffekteListe({required this.ereignis, required this.akzentFarbe});

  @override
  Widget build(BuildContext context) {
    final zeilen = <Widget>[];

    if (ereignis.geld != 0) {
      zeilen.add(_EffektZeile(
        icon: Icons.payments_outlined,
        label: 'Geld',
        wertText:
            '${ereignis.geld > 0 ? '+' : ''}${ereignis.geld.toStringAsFixed(0)}',
        positiv: ereignis.geld > 0,
      ));
    }
    if (ereignis.gesundheit != 0) {
      zeilen.add(_EffektZeile(
        icon: Icons.favorite_outline,
        label: 'Gesundheit',
        wertText:
            '${ereignis.gesundheit > 0 ? '+' : ''}${ereignis.gesundheit.toStringAsFixed(0)}',
        positiv: ereignis.gesundheit > 0,
      ));
    }
    if (ereignis.stress != 0) {
      zeilen.add(_EffektZeile(
        icon: Icons.bolt_outlined,
        label: 'Stress',
        wertText:
            '${ereignis.stress > 0 ? '+' : ''}${(ereignis.stress * 100).toStringAsFixed(0)} %',
        positiv: ereignis.stress < 0,
      ));
    }
    for (final eintrag in ereignis.karma.entries) {
      zeilen.add(_EffektZeile(
        icon: Icons.brightness_7_outlined,
        label: _dimensionName(eintrag.key),
        wertText:
            '${eintrag.value > 0 ? '+' : ''}${eintrag.value.toStringAsFixed(0)} Karma',
        positiv: eintrag.value > 0,
      ));
    }

    if (zeilen.isEmpty) {
      zeilen.add(const _EffektZeile(
        icon: Icons.balance,
        label: 'Keine unmittelbaren Auswirkungen',
        wertText: '',
        positiv: true,
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: akzentFarbe.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUSWIRKUNGEN',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.textTertiaer,
            ),
          ),
          const SizedBox(height: 12),
          ...zeilen,
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}

/// Eine Zeile der Effekt-Liste (Icon, Label, Wert).
class _EffektZeile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String wertText;
  final bool positiv;

  const _EffektZeile({
    required this.icon,
    required this.label,
    required this.wertText,
    required this.positiv,
  });

  @override
  Widget build(BuildContext context) {
    final farbe = positiv ? AppFarben.karmaPositiv : AppFarben.karmaNegatv;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: farbe.withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: AppTextStyles.koerperKlein),
          ),
          Text(
            wertText,
            style: AppTextStyles.koerperKleinFett.copyWith(color: farbe),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weiter-Button (Effekte anwenden + zurück zu Phase 5)
// ─────────────────────────────────────────────────────────────────────────────

class _WeiterButton extends StatelessWidget {
  final Color akzentFarbe;
  final VoidCallback onTap;

  const _WeiterButton({required this.akzentFarbe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: akzentFarbe.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: akzentFarbe.withValues(alpha: 0.6)),
        ),
        child: Text(
          'WEITER IM LEBEN',
          textAlign: TextAlign.center,
          style: AppTextStyles.buttonPrimaer.copyWith(
            color: akzentFarbe,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 350.ms);
  }
}
