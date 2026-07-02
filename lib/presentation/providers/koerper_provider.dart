// koerper_provider.dart
// Riverpod-Provider für die Körper-Simulation von GENESIS.
// Verbindet die bestehende Engine (KoerperSimulation) mit dem UI-State:
// Lebensstil-Entscheidungen wirken auf Organe, Gesundheit und Todesursache.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genesis_kreislauf_des_lebens/core/engines/koerper_simulation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KoerperSpielZustand – unveränderliche State-Klasse
// ─────────────────────────────────────────────────────────────────────────────

/// Kapselt den aktuellen Körperzustand und den gewählten Lebensstil.
///
/// Unveränderlich – Änderungen erzeugen über [copyWith] eine neue Instanz.
class KoerperSpielZustand {
  /// Der körperliche Zustand (Organe, Krankheiten)
  final KoerperZustand zustand;

  /// Der aktuell gelebte Lebensstil
  final LebensstilParameter lebensstil;

  const KoerperSpielZustand({
    required this.zustand,
    required this.lebensstil,
  });

  /// Anfangszustand: gesunder Körper bei Geburt, Standard-Lebensstil
  factory KoerperSpielZustand.initial() => KoerperSpielZustand(
        zustand: KoerperZustand.beiGeburt(),
        lebensstil: LebensstilParameter.standard(),
      );

  KoerperSpielZustand copyWith({
    KoerperZustand? zustand,
    LebensstilParameter? lebensstil,
  }) {
    return KoerperSpielZustand(
      zustand: zustand ?? this.zustand,
      lebensstil: lebensstil ?? this.lebensstil,
    );
  }

  /// Allgemeine Gesundheit in Prozent (0.0–100.0)
  double get gesundheitProzent => zustand.gesamtGesundheit;
}

// ─────────────────────────────────────────────────────────────────────────────
// KoerperNotifier – steuert die Körper-Simulation
// ─────────────────────────────────────────────────────────────────────────────

/// StateNotifier für die Körper-Simulation des laufenden Lebens.
///
/// Session-genau (kein Hive) – bei jedem neuen Leben via [zuruecksetzen]
/// auf den Geburtszustand zurücksetzen.
class KoerperNotifier extends StateNotifier<KoerperSpielZustand> {
  KoerperNotifier() : super(KoerperSpielZustand.initial());

  final KoerperSimulation _engine = KoerperSimulation();

  /// Setzt Körper und Lebensstil auf den Geburtszustand zurück.
  void zuruecksetzen() {
    state = KoerperSpielZustand.initial();
  }

  /// Passt einzelne Lebensstil-Parameter an (alle optional).
  ///
  /// Nicht übergebene Parameter behalten ihren aktuellen Wert.
  void lebensstilAnpassen({
    double? sportStunden,
    double? stressLevel,
    bool? raucht,
    bool? passivRaucht,
    double? alkoholKonsum,
    double? substanzKonsum,
    bool? gesundeErnaehrung,
    double? schlafStunden,
    bool? meditiert,
    double? bildungsStunden,
    bool? sitzendeTaetigkeit,
  }) {
    final aktuell = state.lebensstil;
    state = state.copyWith(
      lebensstil: LebensstilParameter(
        sportStunden: sportStunden ?? aktuell.sportStunden,
        stressLevel: stressLevel ?? aktuell.stressLevel,
        raucht: raucht ?? aktuell.raucht,
        passivRaucht: passivRaucht ?? aktuell.passivRaucht,
        alkoholKonsum: alkoholKonsum ?? aktuell.alkoholKonsum,
        substanzKonsum: substanzKonsum ?? aktuell.substanzKonsum,
        gesundeErnaehrung: gesundeErnaehrung ?? aktuell.gesundeErnaehrung,
        schlafStunden: schlafStunden ?? aktuell.schlafStunden,
        meditiert: meditiert ?? aktuell.meditiert,
        bildungsStunden: bildungsStunden ?? aktuell.bildungsStunden,
        sitzendeTaetigkeit: sitzendeTaetigkeit ?? aktuell.sitzendeTaetigkeit,
      ),
    );
  }

  /// Simuliert ein Lebensjahr mit dem aktuellen Lebensstil.
  ///
  /// [aktivierteGene] und [krankheitsrisiken] stammen aus dem
  /// genetischen Code des laufenden Zyklus.
  void jahrSimulieren(
    int alter, {
    List<String> aktivierteGene = const [],
    List<String> krankheitsrisiken = const [],
  }) {
    final neuerZustand = _engine.jahrSimulieren(
      aktuell: state.zustand,
      alter: alter,
      lebensstil: state.lebensstil,
      aktivierteGene: aktivierteGene,
      krankheitsrisiken: krankheitsrisiken,
    );
    state = state.copyWith(zustand: neuerZustand);
  }

  /// Allgemeine Gesundheit in Prozent (0.0–100.0)
  double get gesundheitProzent => state.zustand.gesamtGesundheit;

  /// Schätzt das Sterbealter anhand der aktuellen Gesundheit.
  ///
  /// Heuristik: 60 + (Gesundheit% / 100) × 35, geklemmt auf 45–99 Jahre.
  /// Liegt das aktuelle Alter bereits darüber, wird es zurückgegeben.
  int sterbealterSchaetzen(int aktuellesAlter) {
    final geschaetzt = (60 + (gesundheitProzent / 100.0) * 35).round();
    final geklemmt = geschaetzt.clamp(45, 99);
    return geklemmt < aktuellesAlter ? aktuellesAlter : geklemmt;
  }

  /// Berechnet die wahrscheinlichste Todesursache als Text.
  String todesUrsache(int alter) {
    return _engine.todesUrsacheBerechnen(state.zustand, alter);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Haupt-Provider der Körper-Simulation.
final koerperProvider =
    StateNotifierProvider<KoerperNotifier, KoerperSpielZustand>((ref) {
  return KoerperNotifier();
});

/// Allgemeine Gesundheit in Prozent (0.0–100.0).
final gesundheitProzentProvider = Provider<double>((ref) {
  return ref.watch(koerperProvider).gesundheitProzent;
});

/// Der aktuell gelebte Lebensstil.
final lebensstilProvider = Provider<LebensstilParameter>((ref) {
  return ref.watch(koerperProvider).lebensstil;
});

/// Gibt an, ob der Charakter aktuell an mindestens einer Krankheit leidet.
final istKrankProvider = Provider<bool>((ref) {
  return ref.watch(koerperProvider).zustand.istKrank;
});
