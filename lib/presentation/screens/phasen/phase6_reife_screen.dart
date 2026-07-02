// phase6_reife_screen.dart
// Phase 6 – Reife (60–80+ Jahre): Die Sterbebett-Szene.
// Der Spieler trifft seine letzten drei Entscheidungen, bevor er den
// letzten Atemzug tut und in die Tod-Sequenz übergeht.

import 'dart:convert';
import 'dart:math' as math;

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
import 'package:genesis_kreislauf_des_lebens/presentation/providers/koerper_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Interne Modelle für die Reife-Jahre (aus reife.json)
// ─────────────────────────────────────────────────────────────────────────────

/// Eine Entscheidung der Reife-Jahre (Alter 61+, vor dem Sterbebett).
class _ReifeEntscheidung {
  final String id;
  final int alter;
  final String kontext;
  final String frage;
  final List<_ReifeOption> optionen;

  const _ReifeEntscheidung({
    required this.id,
    required this.alter,
    required this.kontext,
    required this.frage,
    required this.optionen,
  });

  factory _ReifeEntscheidung.fromJson(Map<String, dynamic> json) {
    final optionenRoh = json['optionen'] as List<dynamic>? ?? [];
    return _ReifeEntscheidung(
      id: json['id'] as String,
      alter: (json['alter'] as num?)?.toInt() ?? 62,
      kontext: json['kontext'] as String? ?? '',
      frage: json['frage'] as String? ?? '',
      optionen: optionenRoh
          .map((o) => _ReifeOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Eine Antwortoption mit Karma-Wirkung und erzählter Konsequenz.
class _ReifeOption {
  final String text;
  final Map<KarmaDimension, double> karma;
  final String konsequenz;

  const _ReifeOption({
    required this.text,
    required this.karma,
    required this.konsequenz,
  });

  factory _ReifeOption.fromJson(Map<String, dynamic> json) {
    final karmaRoh = json['karma'] as Map<String, dynamic>? ?? {};
    final karma = <KarmaDimension, double>{};
    karmaRoh.forEach((schluessel, wert) {
      for (final dim in KarmaDimension.values) {
        if (dim.name == schluessel) {
          karma[dim] = (wert as num).toDouble();
          break;
        }
      }
    });
    final konsequenzen =
        (json['sofortigeKonsequenzen'] as List<dynamic>? ?? []).cast<String>();
    return _ReifeOption(
      text: json['text'] as String? ?? '',
      karma: karma,
      konsequenz: konsequenzen.isNotEmpty ? konsequenzen.first : '',
    );
  }
}

/// Phase 6 – Reife: Das Sterbebett.
///
/// In warmer, goldener Kerzenatmosphäre blickt die Seele auf ihr Leben
/// zurück und trifft drei letzte Entscheidungen.
class Phase6ReifeScreen extends ConsumerStatefulWidget {
  const Phase6ReifeScreen({super.key});

  @override
  ConsumerState<Phase6ReifeScreen> createState() => _Phase6ReifeScreenState();
}

class _Phase6ReifeScreenState extends ConsumerState<Phase6ReifeScreen>
    with TickerProviderStateMixin {
  // ── Warme Sepia-Farbpalette des Sterbebetts ───────────────────────────────
  static const Color _tiefgolden = Color(0xFFC9A227);
  static const Color _warmSepia = Color(0xFF1A130A);
  static const Color _sepiaHell = Color(0xFF2B1F10);
  static const Color _kerzenlicht = Color(0xFFFFE4A1);

  /// Aktuell sichtbare Entscheidung (0–2). Bei 3 sind alle getroffen.
  int _aktuelleEntscheidung = 0;

  /// Bereits getroffene Entscheidungen werden gesperrt dargestellt.
  final Set<int> _getroffen = <int>{};

  /// Anzahl der im Leben getroffenen Entscheidungen (für die Statistik).
  int _entscheidungenGesamt = 0;

  /// Letzte Worte des Spielers.
  final TextEditingController _letzteWorteController = TextEditingController();

  /// Steuert das Flackern der Kerzen.
  late final AnimationController _kerzenController;

  // ── Reife-Jahre (Alter 61+, aus reife.json) ───────────────────────────────

  /// Alle geladenen Reife-Entscheidungen.
  List<_ReifeEntscheidung> _reifeEntscheidungen = const [];

  /// Index der aktuell präsentierten Reife-Entscheidung.
  int _reifeIndex = 0;

  /// Erzählte Konsequenz der letzten Wahl (kurz eingeblendet).
  String? _reifeFeedback;

  /// Ob die Reife-Jahre durchlebt sind und das Sterbebett beginnt.
  bool _sterbebettErreicht = false;

  @override
  void initState() {
    super.initState();
    _kerzenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // Anzahl bisheriger Entscheidungen aus dem echten Zyklus ableiten.
    _entscheidungenGesamt = ref
            .read(spielProvider)
            .aktuellerZyklus
            ?.getroffeneEntscheidungen
            .length ??
        0;

    _reifeEntscheidungenLaden();
  }

  /// Lädt die Reife-Jahre-Entscheidungen aus reife.json.
  Future<void> _reifeEntscheidungenLaden() async {
    try {
      final roh = await rootBundle
          .loadString('assets/data/entscheidungen/reife.json');
      final json = jsonDecode(roh) as Map<String, dynamic>;
      final liste = (json['entscheidungen'] as List<dynamic>? ?? [])
          .map((e) => _ReifeEntscheidung.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.alter.compareTo(b.alter));

      if (!mounted) return;
      setState(() => _reifeEntscheidungen = liste);
    } catch (_) {
      // Ladefehler: direkt zum Sterbebett – das Spiel bleibt spielbar.
      if (!mounted) return;
      setState(() => _sterbebettErreicht = true);
    }
  }

  /// Verarbeitet die Wahl einer Reife-Option und schreitet im Leben voran.
  void _reifeWaehlen(_ReifeEntscheidung entscheidung, int optionIndex) {
    final option = entscheidung.optionen[optionIndex];
    HapticFeedback.lightImpact();

    // Karma anwenden (persistiert automatisch über die Karma-Brücke)
    final karmaNotifier = ref.read(karmaProvider.notifier);
    option.karma.forEach(karmaNotifier.dimensionAendern);

    // Entscheidung protokollieren + Lebensalter voranschreiten
    final spielNotifier = ref.read(spielProvider.notifier);
    spielNotifier.entscheidungTreffen(entscheidung.id, optionIndex);
    final aktuellesAlter = ref.read(spielProvider).aktuellesAlter;
    if (entscheidung.alter > aktuellesAlter) {
      spielNotifier.alterSetzen(entscheidung.alter);
    }

    setState(() {
      _reifeFeedback = option.konsequenz;
      _entscheidungenGesamt++;
      if (_reifeIndex + 1 < _reifeEntscheidungen.length) {
        _reifeIndex++;
      } else {
        _sterbebettErreicht = true;
      }
    });
  }

  @override
  void dispose() {
    _kerzenController.dispose();
    _letzteWorteController.dispose();
    super.dispose();
  }

  /// Trägt eine Karma-Auswirkung ein und schaltet die nächste Entscheidung frei.
  void _waehle(int index, KarmaDimension? dimension, int punkte) {
    if (_getroffen.contains(index)) return;
    if (dimension != null) {
      ref
          .read(karmaProvider.notifier)
          .dimensionAendern(dimension, punkte.toDouble());
    }
    setState(() {
      _getroffen.add(index);
      _entscheidungenGesamt++;
      if (_aktuelleEntscheidung < 3) {
        _aktuelleEntscheidung++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final durchschnitt =
        ref.watch(karmaProvider).durchschnitt.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: _warmSepia,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhasenHintergrund(phase: GamePhase.reife),
          AnimatedBuilder(
            animation: _kerzenController,
            builder: (context, child) {
              // Weiches Flackern moduliert den Schimmer des gesamten Raums.
              final flacker =
                  0.85 + 0.15 * math.sin(_kerzenController.value * math.pi * 2);
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.4,
                    colors: [
                      Color.lerp(_sepiaHell, _kerzenlicht, 0.12 * flacker)!,
                      _warmSepia,
                    ],
                  ),
                ),
                child: child,
              );
            },
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _baueKerzenReihe(),
                    const SizedBox(height: 16),
                    _baueKopf(durchschnitt),
                    const SizedBox(height: 28),
                    // Erst die Reife-Jahre (61+) durchleben,
                    // dann beginnt die Sterbebett-Szene.
                    if (!_sterbebettErreicht)
                      _baueReifeJahre()
                    else ...[
                      _baueEntscheidung1(),
                      if (_aktuelleEntscheidung >= 1) ...[
                        const SizedBox(height: 24),
                        _baueEntscheidung2(),
                      ],
                      if (_aktuelleEntscheidung >= 2) ...[
                        const SizedBox(height: 24),
                        _baueEntscheidung3(),
                      ],
                      if (_aktuelleEntscheidung >= 3) ...[
                        const SizedBox(height: 36),
                        _baueLetzterAtemzug(),
                      ],
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Atmosphärische Kerzen ─────────────────────────────────────────────────

  Widget _baueKerzenReihe() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) => _baueKerze(i)),
    );
  }

  Widget _baueKerze(int index) {
    return AnimatedBuilder(
      animation: _kerzenController,
      builder: (context, _) {
        // Jede Kerze flackert mit eigener Phase, damit es lebendig wirkt.
        final phase = _kerzenController.value * math.pi * 2 + index * 1.3;
        final opacity = 0.55 + 0.45 * ((math.sin(phase) + 1) / 2);
        final hoehe = 18.0 + 4.0 * math.sin(phase * 1.7);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flamme
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 8,
                height: hoehe,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      _tiefgolden.withValues(alpha: opacity),
                      _kerzenlicht.withValues(alpha: opacity),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: _kerzenlicht.withValues(alpha: 0.5 * opacity),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Kerzenkörper
              Container(
                width: 6,
                height: 26,
                color: const Color(0xFFE8D5A8).withValues(alpha: 0.7),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Lebensstatistik ───────────────────────────────────────────────────────

  Widget _baueKopf(String durchschnitt) {
    return Column(
      children: [
        Text(
          'PHASE VI · REIFE',
          textAlign: TextAlign.center,
          style: AppTextStyles.beschriftung.copyWith(
            color: _tiefgolden,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Das letzte Bett',
          textAlign: TextAlign.center,
          style: AppTextStyles.ueberschrift2.copyWith(color: _kerzenlicht),
        ),
        const SizedBox(height: 6),
        Text(
          'Der Atem wird flacher. Die Zeit der Ernte ist gekommen.',
          textAlign: TextAlign.center,
          style: AppTextStyles.koerperKlein.copyWith(
            color: _tiefgolden.withValues(alpha: 0.8),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _sepiaHell.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _tiefgolden.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _statZeile('Alter', '73 Jahre'),
              const SizedBox(height: 10),
              _statZeile('Karma-Durchschnitt', durchschnitt),
              const SizedBox(height: 10),
              _statZeile('Entscheidungen getroffen', '$_entscheidungenGesamt'),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms),
      ],
    );
  }

  Widget _statZeile(String label, String wert) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.koerperKlein.copyWith(
            color: AppFarben.textSekundaer,
          ),
        ),
        Text(
          wert,
          style: AppTextStyles.beschriftung.copyWith(
            color: _kerzenlicht,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ── Entscheidung 1: Wen rufst du zu dir? ──────────────────────────────────

  Widget _baueEntscheidung1() {
    return _baueEntscheidungsBlock(
      index: 0,
      frage: 'Wen rufst du zu dir?',
      optionen: [
        _Option('Die Familie', Icons.family_restroom, KarmaDimension.liebe, 8),
        _Option('Alte Freunde', Icons.groups, KarmaDimension.mitgefuehl, 6),
        _Option('Einen Priester', Icons.menu_book, KarmaDimension.weisheit, 6),
        _Option('Niemanden – allein', Icons.self_improvement, null, 0),
      ],
    );
  }

  // ── Entscheidung 2: Letzte Worte (Texteingabe) ────────────────────────────

  Widget _baueEntscheidung2() {
    final fertig = _getroffen.contains(1);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _blockDeko(aktiv: !fertig),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deine letzten Worte',
            style: AppTextStyles.ueberschrift3.copyWith(color: _kerzenlicht),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _letzteWorteController,
            enabled: !fertig,
            maxLength: 60,
            maxLines: 2,
            style: const TextStyle(
              fontFamily: 'Cinzel',
              color: _kerzenlicht,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            cursorColor: _tiefgolden,
            decoration: InputDecoration(
              hintText: 'Was möchtest du hinterlassen?',
              hintStyle: TextStyle(
                fontFamily: 'Cinzel',
                color: _tiefgolden.withValues(alpha: 0.4),
                fontSize: 15,
              ),
              counterStyle: TextStyle(
                color: _tiefgolden.withValues(alpha: 0.6),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: _tiefgolden.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _tiefgolden, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: _tiefgolden.withValues(alpha: 0.2)),
              ),
            ),
          ),
          if (!fertig) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    _waehle(1, KarmaDimension.ehrlichkeit, 4),
                child: Text(
                  'Worte sprechen',
                  style: AppTextStyles.beschriftung.copyWith(
                    color: _tiefgolden,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.1, end: 0);
  }

  // ── Entscheidung 3: Wie gehst du? ─────────────────────────────────────────

  Widget _baueEntscheidung3() {
    return _baueEntscheidungsBlock(
      index: 2,
      frage: 'Wie gehst du?',
      optionen: [
        _Option('In Frieden', Icons.spa, KarmaDimension.weisheit, 8),
        _Option('Mit Reue', Icons.cloud, null, 0),
        _Option('Dankbar', Icons.volunteer_activism,
            KarmaDimension.grosszuegigkeit, 7),
        _Option('Wütend', Icons.whatshot, KarmaDimension.weisheit, -5),
      ],
    );
  }

  // ── Generischer Entscheidungs-Block mit Options-Buttons ───────────────────

  Widget _baueEntscheidungsBlock({
    required int index,
    required String frage,
    required List<_Option> optionen,
  }) {
    final fertig = _getroffen.contains(index);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _blockDeko(aktiv: !fertig),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            frage,
            style: AppTextStyles.ueberschrift3.copyWith(color: _kerzenlicht),
          ),
          const SizedBox(height: 16),
          ...optionen.map((o) => _baueOption(index, o, fertig)),
        ],
      ),
    ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _baueOption(int index, _Option option, bool fertig) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: fertig
              ? null
              : () => _waehle(index, option.dimension, option.punkte),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _warmSepia.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _tiefgolden.withValues(alpha: fertig ? 0.15 : 0.45),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  option.icon,
                  color: _tiefgolden.withValues(alpha: fertig ? 0.4 : 0.9),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    option.titel,
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 16,
                      color: _kerzenlicht.withValues(alpha: fertig ? 0.4 : 1),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Reife-Jahre (Entscheidungen aus reife.json) ───────────────────────────

  Widget _baueReifeJahre() {
    // Noch am Laden → dezente Warteanzeige im Kerzenlicht
    if (_reifeEntscheidungen.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(
            color: _tiefgolden,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final entscheidung = _reifeEntscheidungen[_reifeIndex];

    return Column(
      key: ValueKey('reife_${entscheidung.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Alters- und Fortschrittszeile
        Text(
          'ALTER ${entscheidung.alter} · '
          '${_reifeIndex + 1}/${_reifeEntscheidungen.length}',
          textAlign: TextAlign.center,
          style: AppTextStyles.beschriftung.copyWith(
            color: _tiefgolden,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 20),

        // Nachhall der letzten Wahl
        if (_reifeFeedback != null && _reifeFeedback!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _sepiaHell.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _reifeFeedback!,
              style: AppTextStyles.koerperKlein.copyWith(
                color: _kerzenlicht.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 20),
        ],

        // Situation
        Container(
          padding: const EdgeInsets.all(18),
          decoration: _blockDeko(aktiv: true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entscheidung.kontext,
                style: AppTextStyles.koerper.copyWith(
                  color: AppFarben.text,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                entscheidung.frage,
                style: AppTextStyles.ueberschrift3.copyWith(
                  color: _kerzenlicht,
                  fontSize: 19,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: 18),

        // Optionen
        ...List.generate(entscheidung.optionen.length, (i) {
          final option = entscheidung.optionen[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _reifeWaehlen(entscheidung, i),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _warmSepia.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _tiefgolden.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    option.text,
                    style: AppTextStyles.koerper.copyWith(
                      color: AppFarben.text,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 350.ms, delay: (80 * i).ms);
        }),
      ],
    );
  }

  // ── Abschluss-Button ──────────────────────────────────────────────────────

  Widget _baueLetzterAtemzug() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          // Dynamisches Sterbealter: hängt an der gelebten Gesundheit
          // (45–99) statt an einem fixen Wert.
          final spiel = ref.read(spielProvider);
          final sterbealter = ref
              .read(koerperProvider.notifier)
              .sterbealterSchaetzen(spiel.aktuellesAlter);
          final spielNotifier = ref.read(spielProvider.notifier);
          await spielNotifier.alterSetzen(sterbealter);
          // Das Leben endet: Phase auf Jenseits setzen und speichern
          await spielNotifier.phasWechseln(GamePhase.jenseits);
          if (!mounted) return;
          context.go('/tod-sequenz');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _tiefgolden,
          foregroundColor: _warmSepia,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'DEN LETZTEN ATEMZUG TUN',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 900.ms)
        .then()
        .shimmer(duration: 1800.ms, color: _kerzenlicht);
  }

  BoxDecoration _blockDeko({required bool aktiv}) {
    return BoxDecoration(
      color: _sepiaHell.withValues(alpha: aktiv ? 0.55 : 0.3),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: _tiefgolden.withValues(alpha: aktiv ? 0.35 : 0.15),
      ),
    );
  }
}

/// Eine einzelne Antwortoption mit Karma-Auswirkung.
class _Option {
  final String titel;
  final IconData icon;
  final KarmaDimension? dimension;
  final int punkte;

  const _Option(this.titel, this.icon, this.dimension, this.punkte);
}
