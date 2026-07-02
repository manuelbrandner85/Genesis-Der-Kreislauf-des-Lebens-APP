// phase5_erwachsen_screen.dart
// Phase 5: Das Erwachsenenleben (19–60 Jahre) – volle Lebenssimulation.
//
// Datengrundlage: assets/data/entscheidungen/erwachsen.json
//   - lebensabschnitte : Aufbaujahre (19–28), Lebensmitte (29–45), Umbruchjahre (46–60)
//   - karrieren        : zeitalter-gefilterte Karrierepfade mit Attribut-Gates,
//                        Gehaltsstufen (Beförderung) und Stress pro Jahr
//   - zufallsereignisse: pro Jahr max. 1 gewürfeltes Ereignis → eigener Screen
//   - entscheidungen   : altersgestreute Lebens-Entscheidungen mit Karma
//
// Jahres-Loop ("Nächstes Jahr"):
//   1. Alter +1 (spielProvider, persistiert)
//   2. Körper-Simulation (koerperProvider.jahrSimulieren mit Genen/Risiken)
//   3. Gehalt − Lebenshaltungskosten aufs Geld
//   4. Zufallsereignis würfeln → /phase/5/ereignis (pop liefert Geld-Delta)
//   5. Fällige Entscheidung präsentieren (blockiert das nächste Jahr)
//
// Übergang zu Phase 6: Gesundheit < 15 % ODER Alter >= 60.
//
// Der gesamte Lebens-Zustand (Geld, Karriere, Familie, Burnout) lebt als
// lokaler State im ConsumerStatefulWidget – KEINE globalen StateProvider
// mehr in dieser Datei (behebt Audit-Fund #13).

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
import 'package:genesis_kreislauf_des_lebens/core/utils/attribut_gates.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/genetischer_code_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/karma_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/koerper_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Interne Datenmodelle (geparst aus erwachsen.json)
// ─────────────────────────────────────────────────────────────────────────────

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

/// Parst ein 'voraussetzungAttribute'/'mindestAttribute'-Objekt.
Map<String, num> _attributeVonJson(dynamic roh) {
  final map = roh as Map<String, dynamic>? ?? {};
  return map.map((k, v) => MapEntry(k, v as num));
}

/// Ein Lebensabschnitt (Kapitel) der Erwachsenen-Phase.
class _Lebensabschnitt {
  final String id;
  final String name;
  final int alterVon;
  final int alterBis;

  const _Lebensabschnitt({
    required this.id,
    required this.name,
    required this.alterVon,
    required this.alterBis,
  });

  factory _Lebensabschnitt.fromJson(Map<String, dynamic> json) {
    return _Lebensabschnitt(
      id: json['id'] as String,
      name: json['name'] as String,
      alterVon: (json['alterVon'] as num).toInt(),
      alterBis: (json['alterBis'] as num).toInt(),
    );
  }
}

/// Eine Karriere-Stufe (Beförderung ab X Berufsjahren).
class _KarriereStufe {
  final String name;
  final int abJahren;
  final double gehaltFaktor;

  const _KarriereStufe({
    required this.name,
    required this.abJahren,
    required this.gehaltFaktor,
  });

  factory _KarriereStufe.fromJson(Map<String, dynamic> json) {
    return _KarriereStufe(
      name: json['name'] as String,
      abJahren: (json['abJahren'] as num).toInt(),
      gehaltFaktor: (json['gehaltFaktor'] as num).toDouble(),
    );
  }
}

/// Eine Karriere mit Attribut-Gates, Gehalt, Stress und Stufen.
class _Karriere {
  final String id;
  final String name;
  final String beschreibung;
  final List<String> zeitalter;
  final Map<String, num> mindestAttribute;
  final double einstiegsGehalt;
  final double stressProJahr;
  final List<_KarriereStufe> stufen;

  const _Karriere({
    required this.id,
    required this.name,
    required this.beschreibung,
    required this.zeitalter,
    required this.mindestAttribute,
    required this.einstiegsGehalt,
    required this.stressProJahr,
    required this.stufen,
  });

  factory _Karriere.fromJson(Map<String, dynamic> json) {
    final stufenRoh = json['stufen'] as List<dynamic>? ?? [];
    return _Karriere(
      id: json['id'] as String,
      name: json['name'] as String,
      beschreibung: json['beschreibung'] as String? ?? '',
      zeitalter: (json['zeitalter'] as List<dynamic>? ?? []).cast<String>(),
      mindestAttribute: _attributeVonJson(json['mindestAttribute']),
      einstiegsGehalt: (json['einstiegsGehalt'] as num?)?.toDouble() ?? 500.0,
      stressProJahr: (json['stressProJahr'] as num?)?.toDouble() ?? 0.3,
      stufen: stufenRoh
          .map((s) => _KarriereStufe.fromJson(s as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.abJahren.compareTo(b.abJahren)),
    );
  }

  /// Immer verfügbare Rückfall-Karriere (verhindert Softlock, wenn kein
  /// Karrierepfad die Attribut-Gates erfüllt).
  static const _Karriere einfacheArbeit = _Karriere(
    id: 'einfache_arbeit',
    name: 'Einfache Arbeit',
    beschreibung:
        'Gelegenheitsarbeiten, wo immer Hände gebraucht werden. Kein Ruhm, '
        'aber ein ehrliches Auskommen – in jedem Zeitalter.',
    zeitalter: [],
    mindestAttribute: {},
    einstiegsGehalt: 550,
    stressProJahr: 0.3,
    stufen: [
      _KarriereStufe(name: 'Gehilfe', abJahren: 0, gehaltFaktor: 1.0),
      _KarriereStufe(
          name: 'Erfahrene Kraft', abJahren: 6, gehaltFaktor: 1.3),
      _KarriereStufe(name: 'Altgeselle', abJahren: 14, gehaltFaktor: 1.6),
    ],
  );

  /// Gilt die Karriere im gegebenen Zeitalter? (leer = immer)
  bool passtZuZeitalter(String zeitalterName) {
    if (zeitalter.isEmpty) return true;
    return zeitalter.contains(zeitalterName);
  }

  /// Index der höchsten erreichten Stufe nach [berufsjahre] Jahren.
  int stufeFuer(int berufsjahre) {
    var index = 0;
    for (var i = 0; i < stufen.length; i++) {
      if (berufsjahre >= stufen[i].abJahren) index = i;
    }
    return index;
  }
}

/// Ein Zufallsereignis (nur die Felder, die Phase 5 zum Würfeln braucht –
/// Anzeige und Effekt-Anwendung übernimmt der Ereignis-Screen).
class _ErwachsenEreignis {
  final String id;
  final String name;
  final double wahrscheinlichkeit;
  final int alterVon;
  final int alterBis;
  final double stress;
  final List<String>? zeitalter;

  const _ErwachsenEreignis({
    required this.id,
    required this.name,
    required this.wahrscheinlichkeit,
    required this.alterVon,
    required this.alterBis,
    required this.stress,
    required this.zeitalter,
  });

  factory _ErwachsenEreignis.fromJson(Map<String, dynamic> json) {
    final effekte = json['effekte'] as Map<String, dynamic>? ?? {};
    return _ErwachsenEreignis(
      id: json['id'] as String,
      name: json['name'] as String,
      wahrscheinlichkeit:
          (json['wahrscheinlichkeit'] as num?)?.toDouble() ?? 0.0,
      alterVon: (json['alterVon'] as num?)?.toInt() ?? 0,
      alterBis: (json['alterBis'] as num?)?.toInt() ?? 120,
      stress: (effekte['stress'] as num?)?.toDouble() ?? 0.0,
      zeitalter: (json['zeitalter'] as List<dynamic>?)?.cast<String>(),
    );
  }

  bool passtZu(int alter, String zeitalterName) {
    if (alter < alterVon || alter > alterBis) return false;
    final z = zeitalter;
    if (z == null || z.isEmpty) return true;
    return z.contains(zeitalterName);
  }
}

/// Eine Antwort-Option einer Erwachsenen-Entscheidung.
class _ErwachsenOption {
  final String id;
  final String text;
  final Map<KarmaDimension, double> karma;
  final List<String> sofortigeKonsequenzen;
  final Map<String, num> voraussetzungAttribute;

  const _ErwachsenOption({
    required this.id,
    required this.text,
    required this.karma,
    required this.sofortigeKonsequenzen,
    required this.voraussetzungAttribute,
  });

  factory _ErwachsenOption.fromJson(Map<String, dynamic> json) {
    final karmaRoh = json['karma'] as Map<String, dynamic>? ?? {};
    final karmaParsed = <KarmaDimension, double>{};
    karmaRoh.forEach((schluessel, wert) {
      final dim = _dimensionVonString(schluessel);
      if (dim != null) karmaParsed[dim] = (wert as num).toDouble();
    });
    return _ErwachsenOption(
      id: json['id'] as String,
      text: json['text'] as String,
      karma: karmaParsed,
      sofortigeKonsequenzen:
          (json['sofortigeKonsequenzen'] as List<dynamic>? ?? [])
              .cast<String>(),
      voraussetzungAttribute:
          _attributeVonJson(json['voraussetzungAttribute']),
    );
  }
}

/// Eine Erwachsenen-Entscheidung aus der JSON-Datei.
class _ErwachsenEntscheidung {
  final String id;
  final int alter;
  final String? abschnitt;
  final List<String>? zeitalter;
  final String kontext;
  final String frage;
  final List<_ErwachsenOption> optionen;

  const _ErwachsenEntscheidung({
    required this.id,
    required this.alter,
    required this.abschnitt,
    required this.zeitalter,
    required this.kontext,
    required this.frage,
    required this.optionen,
  });

  factory _ErwachsenEntscheidung.fromJson(Map<String, dynamic> json) {
    return _ErwachsenEntscheidung(
      id: json['id'] as String,
      alter: (json['alter'] as num?)?.toInt() ?? 19,
      abschnitt: json['abschnitt'] as String?,
      zeitalter: (json['zeitalter'] as List<dynamic>?)?.cast<String>(),
      kontext: json['kontext'] as String? ?? '',
      frage: json['frage'] as String? ?? '',
      optionen: (json['optionen'] as List<dynamic>? ?? [])
          .map((o) => _ErwachsenOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  bool passtZuZeitalter(String zeitalterName) {
    final z = zeitalter;
    if (z == null || z.isEmpty) return true;
    return z.contains(zeitalterName);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase 5 Screen – volle Lebenssimulation
// ─────────────────────────────────────────────────────────────────────────────

/// Erwachsenen-Phase (19–60 Jahre): Karriere, Familie, Finanzen, Gesundheit,
/// Zufallsereignisse und die großen Lebens-Entscheidungen.
class Phase5ErwachsenScreen extends ConsumerStatefulWidget {
  const Phase5ErwachsenScreen({super.key});

  @override
  ConsumerState<Phase5ErwachsenScreen> createState() =>
      _Phase5ErwachsenScreenState();
}

class _Phase5ErwachsenScreenState extends ConsumerState<Phase5ErwachsenScreen> {
  // ── Kumulierter Stress, ab dem das Burnout-Dilemma erzwungen wird ─────────
  static const double _burnoutSchwelle = 3.0;

  // ── Geladene JSON-Daten ────────────────────────────────────────────────────
  bool _laedt = true;
  List<_Lebensabschnitt> _abschnitte = [];
  List<_Karriere> _karrieren = [];
  List<_ErwachsenEreignis> _ereignisse = []; // Index = extra für den Ereignis-Screen
  List<_ErwachsenEntscheidung> _entscheidungen = [];

  // ── Lebens-Zustand (lokal, ersetzt die alten globalen StateProvider) ──────
  double _geld = 800.0;
  _Karriere? _karriere;
  int _berufsjahre = 0;
  int _stufenIndex = 0;
  bool _kuerzerGetreten = false;
  double _kumStress = 0.0;
  bool _verheiratet = false;
  int _kinderAnzahl = 0;
  bool _burnoutErlitten = false;
  bool _burnoutFrageOffen = false;

  // ── Ablauf-Zustand ─────────────────────────────────────────────────────────
  _ErwachsenEntscheidung? _aktuelleEntscheidung;
  final Set<String> _erledigteEntscheidungen = <String>{};
  final List<String> _chronik = <String>[];
  bool _jahrLaeuft = false;

  // Feedback-Nachricht (erscheint kurz nach Aktionen)
  String? _feedbackNachricht;
  Color _feedbackFarbe = AppFarben.karmaPositiv;

  final math.Random _zufall = math.Random();

  @override
  void initState() {
    super.initState();
    _datenLaden();

    // Startalter der Phase sicherstellen (19 Jahre)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final zustand = ref.read(spielProvider);
      if (zustand.aktuellerZyklus != null && zustand.aktuellesAlter < 19) {
        await ref.read(spielProvider.notifier).alterSetzen(19);
      }
    });
  }

  // ── JSON laden ─────────────────────────────────────────────────────────────

  Future<void> _datenLaden() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/data/entscheidungen/erwachsen.json');
      if (!mounted) return;

      final jsonDaten = jsonDecode(jsonString) as Map<String, dynamic>;

      final abschnitte = (jsonDaten['lebensabschnitte'] as List<dynamic>? ?? [])
          .map((e) => _Lebensabschnitt.fromJson(e as Map<String, dynamic>))
          .toList();
      final karrieren = (jsonDaten['karrieren'] as List<dynamic>? ?? [])
          .map((e) => _Karriere.fromJson(e as Map<String, dynamic>))
          .toList();
      final ereignisse = (jsonDaten['zufallsereignisse'] as List<dynamic>? ?? [])
          .map((e) => _ErwachsenEreignis.fromJson(e as Map<String, dynamic>))
          .toList();
      final entscheidungen =
          (jsonDaten['entscheidungen'] as List<dynamic>? ?? [])
              .map((e) =>
                  _ErwachsenEntscheidung.fromJson(e as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => a.alter.compareTo(b.alter));

      setState(() {
        _abschnitte = abschnitte;
        _karrieren = karrieren;
        _ereignisse = ereignisse;
        _entscheidungen = entscheidungen;
        _laedt = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _laedt = false);
    }
  }

  // ── Ableitungen ────────────────────────────────────────────────────────────

  String get _zeitalterName =>
      ref.read(spielProvider).aktuellerZyklus?.zeitalter.name ?? 'moderne';

  _Lebensabschnitt? _abschnittFuer(int alter) {
    for (final a in _abschnitte) {
      if (alter >= a.alterVon && alter <= a.alterBis) return a;
    }
    return _abschnitte.isNotEmpty ? _abschnitte.last : null;
  }

  /// Zeitalter-gefilterte Karrieren + immer verfügbare Rückfall-Karriere.
  List<_Karriere> get _verfuegbareKarrieren {
    final zeitalter = _zeitalterName;
    return [
      ..._karrieren.where((k) => k.passtZuZeitalter(zeitalter)),
      _Karriere.einfacheArbeit,
    ];
  }

  /// Nächste fällige, noch offene Entscheidung für [alter].
  _ErwachsenEntscheidung? _naechsteFaelligeEntscheidung(int alter) {
    final zeitalter = _zeitalterName;
    for (final e in _entscheidungen) {
      if (_erledigteEntscheidungen.contains(e.id)) continue;
      if (e.alter > alter) continue;
      if (!e.passtZuZeitalter(zeitalter)) continue;
      return e;
    }
    return null;
  }

  bool _uebergangFrei(int alter, double gesundheit) =>
      alter >= 60 || gesundheit < 15.0;

  // ── Feedback-Einblendung ───────────────────────────────────────────────────

  void _feedbackZeigen(String text, {bool positiv = true}) {
    setState(() {
      _feedbackNachricht = text;
      _feedbackFarbe = positiv ? AppFarben.karmaPositiv : AppFarben.karmaNegatv;
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      if (_feedbackNachricht == text) {
        setState(() => _feedbackNachricht = null);
      }
    });
  }

  void _chronikEintrag(String text) {
    _chronik.insert(0, text);
    if (_chronik.length > 8) _chronik.removeLast();
  }

  // ── Karrierewahl ───────────────────────────────────────────────────────────

  void _karriereWaehlen(_Karriere karriere) {
    if (_karriere != null) return;
    final code = ref.read(spielProvider).aktuellerZyklus?.genetischerCode;
    if (code == null) return;
    if (!erfuelltVoraussetzungen(karriere.mindestAttribute, code)) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _karriere = karriere;
      _berufsjahre = 0;
      _stufenIndex = 0;
      _chronikEintrag(
          'Karriere begonnen: ${karriere.name} (${karriere.stufen.first.name})');
    });
    _feedbackZeigen('Du beginnst als ${karriere.stufen.first.name} – '
        '${karriere.name}.');
  }

  // ── Jahres-Loop ────────────────────────────────────────────────────────────

  Future<void> _naechstesJahr() async {
    if (_jahrLaeuft || _laedt) return;
    if (_karriere == null ||
        _burnoutFrageOffen ||
        _aktuelleEntscheidung != null) {
      return;
    }

    final zustand = ref.read(spielProvider);
    final zyklus = zustand.aktuellerZyklus;
    if (zyklus == null) return;
    if (_uebergangFrei(
        zustand.aktuellesAlter, ref.read(gesundheitProzentProvider))) {
      return;
    }

    setState(() => _jahrLaeuft = true);
    HapticFeedback.selectionClick();

    // (a) Alter erhöhen (persistiert). Jenseits des Phasen-Maximums (50)
    //     via alterSetzen, damit KEIN vorzeitiger Phasenwechsel ausgelöst wird.
    final spielNotifier = ref.read(spielProvider.notifier);
    final neuesAlter = zustand.aktuellesAlter + 1;
    if (neuesAlter <= GamePhase.erwachsen.maxAlter) {
      await spielNotifier.alterErhoehen();
    } else {
      await spielNotifier.alterSetzen(neuesAlter);
    }
    if (!mounted) return;

    // (b) Körper-Simulation mit genetischem Code des Zyklus
    ref.read(koerperProvider.notifier).jahrSimulieren(
          neuesAlter,
          aktivierteGene: zyklus.genetischerCode.aktivierteGene,
          krankheitsrisiken: zyklus.genetischerCode.krankheitsrisiken,
        );

    // (c) Finanzen: Gehalt (mit Stufe/Beförderung) minus Lebenshaltung
    final karriere = _karriere!;
    _berufsjahre++;
    final neueStufe = karriere.stufeFuer(_berufsjahre);
    final befoerdert = neueStufe > _stufenIndex;
    _stufenIndex = neueStufe;

    final gehaltFaktor = karriere.stufen[_stufenIndex].gehaltFaktor *
        (_kuerzerGetreten ? 0.7 : 1.0);
    final jahresGehalt = karriere.einstiegsGehalt * gehaltFaktor;
    final lebenshaltung =
        600.0 + (_verheiratet ? 150.0 : 0.0) + _kinderAnzahl * 250.0;
    _geld += jahresGehalt - lebenshaltung;

    _chronikEintrag('Alter $neuesAlter: +${jahresGehalt.toStringAsFixed(0)} '
        'Gehalt, −${lebenshaltung.toStringAsFixed(0)} Lebenshaltung');

    if (befoerdert) {
      HapticFeedback.mediumImpact();
      final stufe = karriere.stufen[_stufenIndex];
      _chronikEintrag('Beförderung: ${stufe.name}');
      _feedbackZeigen(
          'Beförderung! Du bist jetzt ${stufe.name} '
          '(Gehalt ×${stufe.gehaltFaktor.toStringAsFixed(1)}).');
    }

    // Karriere-Stress kumulieren + Körper-Stresslevel nachführen
    _kumStress += karriere.stressProJahr * (_kuerzerGetreten ? 0.5 : 1.0);
    ref.read(koerperProvider.notifier).lebensstilAnpassen(
          stressLevel: (0.15 + _kumStress * 0.12).clamp(0.0, 1.0),
        );

    // (d) Zufallsereignis würfeln (max. 1 pro Jahr):
    //     gefilterte Kandidaten mischen, jedes mit eigener Wahrscheinlichkeit.
    final zeitalter = _zeitalterName;
    final kandidaten = <int>[
      for (var i = 0; i < _ereignisse.length; i++)
        if (_ereignisse[i].passtZu(neuesAlter, zeitalter)) i,
    ]..shuffle(_zufall);

    int? getroffenerIndex;
    for (final i in kandidaten) {
      if (_zufall.nextDouble() < _ereignisse[i].wahrscheinlichkeit) {
        getroffenerIndex = i;
        break;
      }
    }

    if (getroffenerIndex != null) {
      final ereignis = _ereignisse[getroffenerIndex];
      HapticFeedback.heavyImpact();
      // extra = Index im GESAMT-zufallsereignisse-Array; der Ereignis-Screen
      // löst ihn auf und liefert das Geld-Delta über pop zurück.
      final ergebnis =
          await context.push('/phase/5/ereignis', extra: getroffenerIndex);
      if (!mounted) return;
      if (ergebnis is num) _geld += ergebnis.toDouble();
      _kumStress = (_kumStress + ereignis.stress).clamp(0.0, 99.0);
      _chronikEintrag('Ereignis: ${ereignis.name}');
    }

    // Burnout-Prüfung: kumulierter Stress über der Schwelle → Pflicht-Dilemma
    if (!_burnoutFrageOffen && !_burnoutErlitten && _kumStress > _burnoutSchwelle) {
      _burnoutFrageOffen = true;
      HapticFeedback.heavyImpact();
    }

    // (e) Fällige Abschnitts-Entscheidung präsentieren
    _aktuelleEntscheidung ??= _naechsteFaelligeEntscheidung(neuesAlter);

    setState(() => _jahrLaeuft = false);
  }

  // ── Burnout-Pflichtentscheidung ────────────────────────────────────────────

  void _burnoutEntscheiden(bool kuerzertreten) {
    HapticFeedback.mediumImpact();
    if (kuerzertreten) {
      _kuerzerGetreten = true;
      _kumStress = 1.0;
      ref.read(koerperProvider.notifier).lebensstilAnpassen(stressLevel: 0.3);
      _feedbackZeigen(
          'Du trittst kürzer: −30 % Gehalt, aber dein Kopf wird wieder klar.');
      _chronikEintrag('Kürzergetreten – weniger Gehalt, weniger Stress');
    } else {
      _burnoutErlitten = true;
      _kumStress = 2.0;
      // Weitermachen = dauerhaft hoher Stress → Gesundheitsrisiko in der
      // Körper-Simulation (Depression/Herz leiden unter stressLevel > 0.7)
      ref.read(koerperProvider.notifier).lebensstilAnpassen(stressLevel: 0.95);
      _feedbackZeigen(
          'Du machst weiter. Dein Körper wird die Rechnung stellen.',
          positiv: false);
      _chronikEintrag('Burnout ignoriert – Gesundheitsrisiko steigt');
    }
    setState(() => _burnoutFrageOffen = false);
  }

  // ── Entscheidungen aus JSON ────────────────────────────────────────────────

  Future<void> _entscheidungWaehlen(
      _ErwachsenEntscheidung entscheidung, int optionIndex) async {
    final code = ref.read(spielProvider).aktuellerZyklus?.genetischerCode;
    final option = entscheidung.optionen[optionIndex];
    if (code == null) return;
    if (!erfuelltVoraussetzungen(option.voraussetzungAttribute, code)) return;

    HapticFeedback.mediumImpact();

    // Karma anwenden (persistiert der KarmaNotifier automatisch)
    final karmaNotifier = ref.read(karmaProvider.notifier);
    for (final eintrag in option.karma.entries) {
      karmaNotifier.dimensionAendern(eintrag.key, eintrag.value);
    }

    // Entscheidung im Spiel-Protokoll persistieren
    await ref
        .read(spielProvider.notifier)
        .entscheidungTreffen(entscheidung.id, optionIndex);
    if (!mounted) return;

    // Familien-/Geld-Auswirkungen anhand der konkreten Entscheidungs-IDs
    _familienEffektAnwenden(entscheidung.id, optionIndex);
    _geldEffektAnwenden(entscheidung.id, optionIndex);

    final konsequenz = option.sofortigeKonsequenzen.isNotEmpty
        ? option.sofortigeKonsequenzen.first
        : 'Die Wahl ist gefallen.';

    setState(() {
      _erledigteEntscheidungen.add(entscheidung.id);
      _aktuelleEntscheidung = null;
      _chronikEintrag('Entschieden: ${entscheidung.frage}');
    });
    _feedbackZeigen(konsequenz);
  }

  /// Heirat/Kinder/Trennung aus den JSON-Entscheidungs-IDs ableiten.
  void _familienEffektAnwenden(String entscheidungId, int optionIndex) {
    switch (entscheidungId) {
      case 'erwachsen_007': // "Sollten wir heiraten?"
        // a: Ja (mit Zweifel), b: ehrliches Fundament → Ehe; c: Nein
        if (optionIndex == 0 || optionIndex == 1) _verheiratet = true;
      case 'erwachsen_004': // Partner möchte Kinder
        // a: zustimmen, b: gemeinsamer Weg → Kind; c: kategorisch ablehnen
        if (optionIndex == 0 || optionIndex == 1) _kinderAnzahl++;
      case 'erwachsen_010': // "Euer zweites Kind ist unterwegs"
        _kinderAnzahl = _kinderAnzahl < 2 ? 2 : _kinderAnzahl + 1;
      case 'erwachsen_014': // Leere-Nest-Krise
        // a: Trennung ausgesprochen
        if (optionIndex == 0) _verheiratet = false;
    }
  }

  /// Direkte Geld-Auswirkungen markanter Entscheidungen.
  void _geldEffektAnwenden(String entscheidungId, int optionIndex) {
    switch (entscheidungId) {
      case 'erwachsen_009': // Freund bittet um 4000 Erspartes
        if (optionIndex == 0) _geld -= 4000;
        if (optionIndex == 1) _geld -= 2000;
      case 'erwachsen_008': // Hauskauf
        if (optionIndex == 0) _geld -= 5000;
        if (optionIndex == 2) _geld -= 2500;
    }
  }

  // ── Übergang zu Phase 6 ────────────────────────────────────────────────────

  Future<void> _zurReifeWechseln() async {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(spielProvider.notifier);
    if (ref.read(spielProvider).aktuellePhase.nummer <
        GamePhase.reife.nummer) {
      await notifier.phasWechseln(GamePhase.reife);
    }
    if (!mounted) return;
    context.go('/phase/6');
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final spielZustand = ref.watch(spielProvider);
    final alter = spielZustand.aktuellesAlter;
    final gesundheit = ref.watch(gesundheitProzentProvider);
    final abschnitt = _abschnittFuer(alter);
    final code = spielZustand.aktuellerZyklus?.genetischerCode;
    final uebergangFrei = _uebergangFrei(alter, gesundheit);

    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhasenHintergrund(phase: GamePhase.erwachsen),
          SafeArea(
            child: Column(
              children: [
                // Kopfzeile: Abschnitt + Alter + Gesundheit + Geld + Stress
                _LebensKopfzeile(
                  abschnittName: abschnitt?.name ?? 'Erwachsenenleben',
                  alter: alter,
                  gesundheit: gesundheit,
                  geld: _geld,
                  kumStress: _kumStress,
                  burnoutSchwelle: _burnoutSchwelle,
                  feedbackNachricht: _feedbackNachricht,
                  feedbackFarbe: _feedbackFarbe,
                ),

                // Hauptinhalt
                Expanded(
                  child: _laedt
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppFarben.phaseBluete,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Kapitel-Karte des Lebensabschnitts
                              if (abschnitt != null)
                                _AbschnittsBanner(abschnitt: abschnitt),
                              const SizedBox(height: 14),

                              // Karrierewahl (Pflicht zu Beginn, Alter 19–21)
                              if (_karriere == null && code != null)
                                _KarriereWahlSektion(
                                  karrieren: _verfuegbareKarrieren,
                                  code: code,
                                  onWaehlen: _karriereWaehlen,
                                )
                              else if (_karriere != null) ...[
                                _KarriereStatusKarte(
                                  karriere: _karriere!,
                                  stufenIndex: _stufenIndex,
                                  berufsjahre: _berufsjahre,
                                  kuerzerGetreten: _kuerzerGetreten,
                                  verheiratet: _verheiratet,
                                  kinderAnzahl: _kinderAnzahl,
                                  burnoutErlitten: _burnoutErlitten,
                                ),
                              ],

                              // Burnout-Pflichtentscheidung
                              if (_burnoutFrageOffen) ...[
                                const SizedBox(height: 14),
                                _BurnoutKarte(
                                    onEntscheiden: _burnoutEntscheiden),
                              ],

                              // Fällige Lebens-Entscheidung
                              if (_aktuelleEntscheidung != null &&
                                  code != null) ...[
                                const SizedBox(height: 14),
                                _EntscheidungsKarte(
                                  entscheidung: _aktuelleEntscheidung!,
                                  code: code,
                                  onWahl: (i) => _entscheidungWaehlen(
                                      _aktuelleEntscheidung!, i),
                                ),
                              ],

                              // Chronik der letzten Jahre
                              if (_chronik.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                _ChronikListe(eintraege: _chronik),
                              ],
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                ),

                // Unterer Bereich: Alters-Meter + Hauptaktion
                _AltersUndAktionsLeiste(
                  alter: alter,
                  laedt: _laedt || _jahrLaeuft,
                  uebergangFrei: uebergangFrei,
                  karriereGewaehlt: _karriere != null,
                  entscheidungOffen:
                      _aktuelleEntscheidung != null || _burnoutFrageOffen,
                  onNaechstesJahr: _naechstesJahr,
                  onWeiter: _zurReifeWechseln,
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
// _LebensKopfzeile – Abschnitt, Alter, Gesundheit, Geld, Stress
// ─────────────────────────────────────────────────────────────────────────────

class _LebensKopfzeile extends StatelessWidget {
  final String abschnittName;
  final int alter;
  final double gesundheit;
  final double geld;
  final double kumStress;
  final double burnoutSchwelle;
  final String? feedbackNachricht;
  final Color feedbackFarbe;

  const _LebensKopfzeile({
    required this.abschnittName,
    required this.alter,
    required this.gesundheit,
    required this.geld,
    required this.kumStress,
    required this.burnoutSchwelle,
    required this.feedbackNachricht,
    required this.feedbackFarbe,
  });

  @override
  Widget build(BuildContext context) {
    final gesundheitFarbe = gesundheit > 60
        ? AppFarben.karmaPositiv
        : gesundheit > 30
            ? AppFarben.karmaNeutral
            : AppFarben.karmaNegatv;
    final stressAnteil = (kumStress / burnoutSchwelle).clamp(0.0, 1.0);
    final stressFarbe = stressAnteil < 0.6
        ? AppFarben.karmaPositiv
        : stressAnteil < 0.9
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
              // Abschnittsname + Alter
              Expanded(
                child: Text(
                  '${abschnittName.toUpperCase()} · $alter JAHRE',
                  style: AppTextStyles.beschriftungGross.copyWith(
                    color: AppFarben.phaseBluete,
                    letterSpacing: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Geld
              Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      color: AppFarben.goldGlanz, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    geld.toStringAsFixed(0),
                    style: AppTextStyles.beschriftung
                        .copyWith(color: AppFarben.goldGlanz),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Gesundheits-Balken
          Row(
            children: [
              Icon(Icons.favorite, color: gesundheitFarbe, size: 13),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (gesundheit / 100.0).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor:
                        AppFarben.nebelGrau.withValues(alpha: 0.2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(gesundheitFarbe),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${gesundheit.toStringAsFixed(0)}%',
                style: AppTextStyles.mikro.copyWith(color: gesundheitFarbe),
              ),
              const SizedBox(width: 14),

              // Stress-Anzeige
              Icon(Icons.bolt, color: stressFarbe, size: 13),
              const SizedBox(width: 4),
              Text(
                'Stress ${(stressAnteil * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.mikro.copyWith(color: stressFarbe),
              ),
            ],
          ),

          // Feedback-Nachricht (kurz nach Aktionen)
          if (feedbackNachricht != null) ...[
            const SizedBox(height: 6),
            Text(
              feedbackNachricht!,
              style:
                  AppTextStyles.beschriftung.copyWith(color: feedbackFarbe),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ).animate().fadeIn(),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AbschnittsBanner – Kapitel-Karte des aktuellen Lebensabschnitts
// ─────────────────────────────────────────────────────────────────────────────

class _AbschnittsBanner extends StatelessWidget {
  final _Lebensabschnitt abschnitt;

  const _AbschnittsBanner({required this.abschnitt});

  String get _beschreibung {
    switch (abschnitt.id) {
      case 'aufbau':
        return 'Ausbildung, erste Liebe, der Grundstein für alles Weitere.';
      case 'mitte':
        return 'Familie, Verantwortung und die Frage, wofür das alles ist.';
      case 'umbruch':
        return 'Bilanz ziehen, loslassen, noch einmal neu wagen.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppFarben.phaseBluete.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppFarben.phaseBluete.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kapitel: ${abschnitt.name} '
            '(${abschnitt.alterVon}–${abschnitt.alterBis})',
            style: AppTextStyles.koerperKleinFett
                .copyWith(color: AppFarben.phaseBluete),
          ),
          if (_beschreibung.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(_beschreibung, style: AppTextStyles.koerperKlein),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Karrierewahl
// ─────────────────────────────────────────────────────────────────────────────

class _KarriereWahlSektion extends StatelessWidget {
  final List<_Karriere> karrieren;
  final GenetischerCodeModel code;
  final void Function(_Karriere) onWaehlen;

  const _KarriereWahlSektion({
    required this.karrieren,
    required this.code,
    required this.onWaehlen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wähle deinen Weg', style: AppTextStyles.ueberschrift3)
            .animate()
            .fadeIn(delay: 100.ms),
        const SizedBox(height: 4),
        Text(
          'Deine Karriere bestimmt Einkommen, Stress und Aufstieg. '
          'Manche Wege verlangen besondere Anlagen.',
          style: AppTextStyles.koerperKlein,
        ),
        const SizedBox(height: 14),
        ...List.generate(karrieren.length, (i) {
          final karriere = karrieren[i];
          final erfuellt =
              erfuelltVoraussetzungen(karriere.mindestAttribute, code);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _KarriereKarte(
              karriere: karriere,
              gesperrt: !erfuellt,
              onWaehlen: erfuellt ? () => onWaehlen(karriere) : null,
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 100 + i * 70),
                ),
          );
        }),
      ],
    );
  }
}

/// Karte für eine Karriere (ggf. gesperrt mit Voraussetzungs-Hinweis).
class _KarriereKarte extends StatelessWidget {
  final _Karriere karriere;
  final bool gesperrt;
  final VoidCallback? onWaehlen;

  const _KarriereKarte({
    required this.karriere,
    required this.gesperrt,
    required this.onWaehlen,
  });

  @override
  Widget build(BuildContext context) {
    final farbe =
        gesperrt ? AppFarben.nebelGrau : AppFarben.phaseBluete;

    return Opacity(
      opacity: gesperrt ? 0.55 : 1.0,
      child: GestureDetector(
        onTap: onWaehlen,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppFarben.oberflaeche,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: farbe.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    gesperrt ? Icons.lock_outline : Icons.work_outline,
                    color: farbe,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      karriere.name,
                      style: AppTextStyles.koerperKleinFett
                          .copyWith(color: gesperrt ? AppFarben.textSekundaer : AppFarben.text),
                    ),
                  ),
                  Text(
                    '${karriere.einstiegsGehalt.toStringAsFixed(0)}/Jahr',
                    style: AppTextStyles.beschriftung
                        .copyWith(color: AppFarben.goldGlanz),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                karriere.beschreibung,
                style: AppTextStyles.koerperKlein,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              if (gesperrt)
                Text(
                  'Voraussetzung: '
                  '${voraussetzungenText(karriere.mindestAttribute)}',
                  style: AppTextStyles.mikro
                      .copyWith(color: AppFarben.karmaNegatv),
                )
              else
                Text(
                  'Stufen: '
                  '${karriere.stufen.map((s) => s.name).join(' → ')}',
                  style: AppTextStyles.mikro.copyWith(
                    color: AppFarben.phaseBluete.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Karriere-Status + Familie
// ─────────────────────────────────────────────────────────────────────────────

class _KarriereStatusKarte extends StatelessWidget {
  final _Karriere karriere;
  final int stufenIndex;
  final int berufsjahre;
  final bool kuerzerGetreten;
  final bool verheiratet;
  final int kinderAnzahl;
  final bool burnoutErlitten;

  const _KarriereStatusKarte({
    required this.karriere,
    required this.stufenIndex,
    required this.berufsjahre,
    required this.kuerzerGetreten,
    required this.verheiratet,
    required this.kinderAnzahl,
    required this.burnoutErlitten,
  });

  @override
  Widget build(BuildContext context) {
    final stufe = karriere.stufen[stufenIndex];
    final chips = <Widget>[
      _StatusChip(
        icon: Icons.work_outline,
        text: '${karriere.name} · ${stufe.name}',
        farbe: AppFarben.phaseBluete,
      ),
      _StatusChip(
        icon: Icons.timelapse,
        text: '$berufsjahre Berufsjahre',
        farbe: AppFarben.textSekundaer,
      ),
      if (verheiratet)
        const _StatusChip(
          icon: Icons.favorite,
          text: 'Verheiratet',
          farbe: AppFarben.emotionVerliebt,
        ),
      if (kinderAnzahl > 0)
        _StatusChip(
          icon: Icons.child_care,
          text: kinderAnzahl == 1 ? '1 Kind' : '$kinderAnzahl Kinder',
          farbe: AppFarben.karmaPositiv,
        ),
      if (kuerzerGetreten)
        const _StatusChip(
          icon: Icons.self_improvement,
          text: 'Kürzergetreten',
          farbe: AppFarben.karmaNeutral,
        ),
      if (burnoutErlitten)
        const _StatusChip(
          icon: Icons.local_fire_department,
          text: 'Burnout',
          farbe: AppFarben.karmaNegatv,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppFarben.goldGlanz.withValues(alpha: 0.2),
        ),
      ),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color farbe;

  const _StatusChip({
    required this.icon,
    required this.text,
    required this.farbe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: farbe.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: farbe.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: farbe),
          const SizedBox(width: 5),
          Text(text, style: AppTextStyles.mikro.copyWith(color: farbe)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Burnout-Pflichtentscheidung
// ─────────────────────────────────────────────────────────────────────────────

class _BurnoutKarte extends StatelessWidget {
  final void Function(bool kuerzertreten) onEntscheiden;

  const _BurnoutKarte({required this.onEntscheiden});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppFarben.karmaNegatv.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppFarben.karmaNegatv.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department,
                  color: AppFarben.karmaNegatv, size: 20),
              const SizedBox(width: 8),
              Text(
                'AM RANDE DES BURNOUTS',
                style: AppTextStyles.beschriftungGross
                    .copyWith(color: AppFarben.karmaNegatv),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Jahre unter Dauerdruck fordern ihren Tribut: Schlaflosigkeit, '
            'Herzrasen, Leere. So kann es nicht weitergehen – du musst dich '
            'entscheiden.',
            style: AppTextStyles.koerperKlein,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BurnoutOption(
                  text: 'Kürzertreten',
                  untertitel: '−30 % Gehalt, −Stress',
                  positiv: true,
                  onTap: () => onEntscheiden(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BurnoutOption(
                  text: 'Weitermachen',
                  untertitel: 'Volles Gehalt, Gesundheitsrisiko',
                  positiv: false,
                  onTap: () => onEntscheiden(false),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).shake(hz: 3, duration: 500.ms);
  }
}

class _BurnoutOption extends StatelessWidget {
  final String text;
  final String untertitel;
  final bool positiv;
  final VoidCallback onTap;

  const _BurnoutOption({
    required this.text,
    required this.untertitel,
    required this.positiv,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final farbe = positiv ? AppFarben.karmaPositiv : AppFarben.karmaNegatv;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: farbe.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: farbe.withValues(alpha: 0.45)),
        ),
        child: Column(
          children: [
            Text(
              text,
              style: AppTextStyles.koerperKleinFett.copyWith(color: farbe),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              untertitel,
              style: AppTextStyles.mikro
                  .copyWith(color: AppFarben.textSekundaer),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entscheidungs-Karte (aus JSON, mit Attribut-Gates auf Optionen)
// ─────────────────────────────────────────────────────────────────────────────

class _EntscheidungsKarte extends StatelessWidget {
  final _ErwachsenEntscheidung entscheidung;
  final GenetischerCodeModel code;
  final void Function(int optionIndex) onWahl;

  const _EntscheidungsKarte({
    required this.entscheidung,
    required this.code,
    required this.onWahl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppFarben.oberflaecheErhoben,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppFarben.mystischLila.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppFarben.mystischLila.withValues(alpha: 0.12),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EINE ENTSCHEIDUNG STEHT AN (${entscheidung.alter})',
            style: AppTextStyles.beschriftungGross
                .copyWith(color: AppFarben.mystischLila),
          ),
          const SizedBox(height: 10),
          Text(entscheidung.kontext, style: AppTextStyles.koerperKursiv),
          const SizedBox(height: 8),
          Text(
            entscheidung.frage,
            style: AppTextStyles.koerperKleinFett,
          ),
          const SizedBox(height: 12),
          ...List.generate(entscheidung.optionen.length, (i) {
            final option = entscheidung.optionen[i];
            final erfuellt = erfuelltVoraussetzungen(
                option.voraussetzungAttribute, code);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _OptionsZeile(
                index: i,
                option: option,
                gesperrt: !erfuellt,
                onTap: erfuellt ? () => onWahl(i) : null,
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.04, end: 0);
  }
}

class _OptionsZeile extends StatelessWidget {
  final int index;
  final _ErwachsenOption option;
  final bool gesperrt;
  final VoidCallback? onTap;

  const _OptionsZeile({
    required this.index,
    required this.option,
    required this.gesperrt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final farbe =
        gesperrt ? AppFarben.nebelGrau : AppFarben.mystischLila;

    return Opacity(
      opacity: gesperrt ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppFarben.oberflaeche,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: farbe.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              // Optionsbuchstabe (A, B, C)
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: farbe.withValues(alpha: 0.5)),
                  color: farbe.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: AppTextStyles.mikro.copyWith(color: farbe),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.text, style: AppTextStyles.koerperKlein),
                    if (gesperrt) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Voraussetzung: '
                        '${voraussetzungenText(option.voraussetzungAttribute)}',
                        style: AppTextStyles.mikro
                            .copyWith(color: AppFarben.karmaNegatv),
                      ),
                    ],
                  ],
                ),
              ),
              if (gesperrt)
                const Icon(Icons.lock_outline,
                    size: 14, color: AppFarben.nebelGrau),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chronik (Jahres-Log)
// ─────────────────────────────────────────────────────────────────────────────

class _ChronikListe extends StatelessWidget {
  final List<String> eintraege;

  const _ChronikListe({required this.eintraege});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppFarben.nebelGrau.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHRONIK',
            style: AppTextStyles.beschriftungGross
                .copyWith(color: AppFarben.textTertiaer),
          ),
          const SizedBox(height: 8),
          ...eintraege.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '· $e',
                style: AppTextStyles.mikro
                    .copyWith(color: AppFarben.textSekundaer),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AltersUndAktionsLeiste – Alters-Meter (19–60) + Hauptaktion
// ─────────────────────────────────────────────────────────────────────────────

class _AltersUndAktionsLeiste extends StatelessWidget {
  final int alter;
  final bool laedt;
  final bool uebergangFrei;
  final bool karriereGewaehlt;
  final bool entscheidungOffen;
  final VoidCallback onNaechstesJahr;
  final VoidCallback onWeiter;

  const _AltersUndAktionsLeiste({
    required this.alter,
    required this.laedt,
    required this.uebergangFrei,
    required this.karriereGewaehlt,
    required this.entscheidungOffen,
    required this.onNaechstesJahr,
    required this.onWeiter,
  });

  @override
  Widget build(BuildContext context) {
    // Fortschritt von 19 bis 60 (0.0 – 1.0)
    final alterFortschritt = ((alter - 19) / 41.0).clamp(0.0, 1.0);

    // Beschriftung + Aktion der Hauptschaltfläche bestimmen
    final String buttonText;
    final VoidCallback? onTap;
    if (laedt) {
      buttonText = 'DAS LEBEN ORDNET SICH …';
      onTap = null;
    } else if (uebergangFrei) {
      buttonText = 'DAS LEBEN REIFT WEITER';
      onTap = onWeiter;
    } else if (!karriereGewaehlt) {
      buttonText = 'WÄHLE ZUERST DEINE KARRIERE';
      onTap = null;
    } else if (entscheidungOffen) {
      buttonText = 'TRIFF ZUERST DEINE ENTSCHEIDUNG';
      onTap = null;
    } else {
      buttonText = 'NÄCHSTES JAHR (${alter + 1})';
      onTap = onNaechstesJahr;
    }
    final aktiv = onTap != null;

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
                '19',
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

          // Hauptaktion
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: aktiv
                      ? AppFarben.phaseBluete.withValues(alpha: 0.15)
                      : AppFarben.nebelGrau.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: aktiv
                        ? AppFarben.phaseBluete.withValues(alpha: 0.6)
                        : AppFarben.nebelGrau.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: AppTextStyles.buttonPrimaer.copyWith(
                    color: aktiv
                        ? AppFarben.phaseBluete
                        : AppFarben.textTertiaer,
                    fontSize: aktiv ? 13 : 11,
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
