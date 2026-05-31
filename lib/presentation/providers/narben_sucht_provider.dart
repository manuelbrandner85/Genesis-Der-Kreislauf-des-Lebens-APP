// narben_sucht_provider.dart
// Riverpod-Provider für Narben und Süchte des aktiven Charakters.
// Verwaltet Heilungsfortschritte, Trigger-Erkennung und Wahrnehmungsverzerrung.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/narben_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/sucht_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zustandsklassen
// ─────────────────────────────────────────────────────────────────────────────

/// Gesamtzustand für Narben und Süchte des Charakters.
class NarbenSuchtZustand {
  final List<NarbenModel> narben;
  final List<SuchtModel> suchte;

  const NarbenSuchtZustand({
    this.narben = const [],
    this.suchte = const [],
  });

  NarbenSuchtZustand copyWith({
    List<NarbenModel>? narben,
    List<SuchtModel>? suchte,
  }) {
    return NarbenSuchtZustand(
      narben: narben ?? this.narben,
      suchte: suchte ?? this.suchte,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ─────────────────────────────────────────────────────────────────────────

  /// Alle aktiven (nicht geheilten) Narben
  List<NarbenModel> get aktiveNarben =>
      narben.where((n) => n.istAktiv).toList();

  /// Alle aktiven Süchte (nicht überwunden)
  List<SuchtModel> get aktiveSuchte =>
      suchte.where((s) => !s.istUeberwunden).toList();

  /// Ob irgendeine Sucht die Wahrnehmung verzerrt
  bool get istWahrnehmungVerzerrt =>
      suchte.any((s) => s.verzerrtWahrnehmung);

  /// Gesamtstärke aller aktiven Wahrnehmungsverzerrungen (0.0–1.0)
  double get gesamteVerzerrung {
    if (!istWahrnehmungVerzerrt) return 0.0;
    final verzerrendeStaerken = suchte
        .where((s) => s.verzerrtWahrnehmung)
        .map((s) => s.wahrnehmungsVerzerrung);
    if (verzerrendeStaerken.isEmpty) return 0.0;
    return verzerrendeStaerken.reduce((a, b) => a > b ? a : b);
  }

  /// Alle durch Süchte blockierten Entscheidungsoptionen
  List<String> get blockierteOptionen =>
      suchte.expand((s) => s.blockierteOptionen).toSet().toList();

  /// Gesamt-Entscheidungsmodifier durch alle aktiven Narben
  double get narbenModifier {
    if (aktiveNarben.isEmpty) return 0.0;
    return aktiveNarben
        .map((n) => n.entscheidungsModifier)
        .reduce((a, b) => a + b);
  }

  /// Ob aktuell Süchte im Entzug sind
  bool get hatAktivenEntzug => suchte.any((s) => s.istImEntzug);
}

// ─────────────────────────────────────────────────────────────────────────────
// NarbenSuchtNotifier
// ─────────────────────────────────────────────────────────────────────────────

/// StateNotifier für Narben und Süchte des Charakters.
class NarbenSuchtNotifier extends StateNotifier<NarbenSuchtZustand> {
  NarbenSuchtNotifier() : super(const NarbenSuchtZustand());

  Box<Map>? _box;

  // ───────────────────────────────────────────────────────────────────────────
  // Laden
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> laden(String zyklusId) async {
    _box ??= await Hive.openBox<Map>('narben_suchte');

    final narbenRoh = _box!.get('narben_$zyklusId');
    final suchteRoh = _box!.get('suchte_$zyklusId');

    final narben = narbenRoh != null
        ? (narbenRoh['narben'] as List? ?? [])
            .map((e) => NarbenModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <NarbenModel>[];

    final suchte = suchteRoh != null
        ? (suchteRoh['suchte'] as List? ?? [])
            .map((e) => SuchtModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <SuchtModel>[];

    state = NarbenSuchtZustand(narben: narben, suchte: suchte);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Narben-Verwaltung
  // ───────────────────────────────────────────────────────────────────────────

  /// Fügt eine neue Narbe hinzu.
  Future<void> narbenHinzufuegen({
    required String beschreibung,
    required NarbenTyp typ,
    required GamePhase phase,
    List<String> trigger = const [],
    double intensitaet = 0.5,
  }) async {
    final neueNarbe = NarbenModel.erstellen(
      beschreibung: beschreibung,
      typ: typ,
      entstandenInPhase: phase,
      trigger: trigger,
      intensitaet: intensitaet,
    );

    state = state.copyWith(narben: [...state.narben, neueNarbe]);
    await _speichern();
  }

  /// Heilt eine Narbe und wandelt sie in eine Stärke um.
  Future<void> narbenHeilen(String narbenId, String staerkeBeschreibung) async {
    final aktualisiert = state.narben.map((n) {
      if (n.id == narbenId) return n.heilen(staerkeBeschreibung);
      return n;
    }).toList();

    state = state.copyWith(narben: aktualisiert);
    await _speichern();
  }

  /// Verdrängt eine Narbe (erhöht ihr Trigger-Risiko).
  Future<void> narbenVerdraengen(String narbenId) async {
    final aktualisiert = state.narben.map((n) {
      if (n.id == narbenId) return n.verdraengen();
      return n;
    }).toList();

    state = state.copyWith(narben: aktualisiert);
    await _speichern();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Sucht-Verwaltung
  // ───────────────────────────────────────────────────────────────────────────

  /// Fügt eine neue Sucht-Abhängigkeit hinzu.
  Future<void> suchtHinzufuegen({
    required SuchtTyp typ,
    required GamePhase phase,
    String? ausloeserNarbenId,
  }) async {
    final neueSucht = SuchtModel.erstellen(
      typ: typ,
      entstandenInPhase: phase,
      ausloeserNarbenId: ausloeserNarbenId,
    );

    state = state.copyWith(suchte: [...state.suchte, neueSucht]);
    await _speichern();
  }

  /// Verstärkt eine bestehende Sucht.
  Future<void> suchtVerstaerken(String suchtId, double betrag) async {
    final aktualisiert = state.suchte.map((s) {
      if (s.id == suchtId) return s.verstaerken(betrag);
      return s;
    }).toList();

    state = state.copyWith(suchte: aktualisiert);
    await _speichern();
  }

  /// Beginnt den Entzug für eine Sucht.
  Future<void> entzugBeginnen(String suchtId) async {
    final aktualisiert = state.suchte.map((s) {
      if (s.id == suchtId) return s.entzugBeginnen();
      return s;
    }).toList();

    state = state.copyWith(suchte: aktualisiert);
    await _speichern();
  }

  /// Schreitet im Entzug voran.
  Future<void> entzugFortschreiten(String suchtId, double betrag) async {
    final aktualisiert = state.suchte.map((s) {
      if (s.id == suchtId) return s.entzugFortschreiten(betrag);
      return s;
    }).toList();

    state = state.copyWith(suchte: aktualisiert);
    await _speichern();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Trigger-Prüfung
  // ───────────────────────────────────────────────────────────────────────────

  /// Prüft ob eine Situation einen Narben-Trigger auslöst.
  /// Gibt die Liste der getriggerten Narben zurück.
  List<NarbenModel> triggerPruefen(List<String> situationsThemen) {
    return state.aktiveNarben
        .where((n) => n.trigger.any(situationsThemen.contains))
        .toList();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Persistenz
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _speichern() async {
    _box ??= await Hive.openBox<Map>('narben_suchte');
    // Zyklusbasierte Speicherung – wird von außen mit zyklusId aufgerufen
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Haupt-Provider für Narben und Süchte des aktiven Charakters.
final narbenSuchtProvider =
    StateNotifierProvider<NarbenSuchtNotifier, NarbenSuchtZustand>(
  (ref) => NarbenSuchtNotifier(),
);

/// Abgeleiteter Provider: Ob die Wahrnehmung aktuell verzerrt ist.
final wahrnehmungVerzerrtProvider = Provider<bool>((ref) {
  return ref.watch(narbenSuchtProvider).istWahrnehmungVerzerrt;
});

/// Abgeleiteter Provider: Alle blockierten Entscheidungsoptionen.
final blockierteOptionenProvider = Provider<List<String>>((ref) {
  return ref.watch(narbenSuchtProvider).blockierteOptionen;
});

/// Abgeleiteter Provider: Gesamte Narben-Modifier für Entscheidungen.
final narbenModifierProvider = Provider<double>((ref) {
  return ref.watch(narbenSuchtProvider).narbenModifier;
});
