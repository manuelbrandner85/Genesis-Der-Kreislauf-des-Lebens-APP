// karma_provider.dart
// Karma-spezifische Provider für GENESIS: Der Kreislauf des Lebens.
// Verwaltet Karma-Änderungen, berechnet das Jenseitsreich und
// protokolliert die letzten Karma-Ereignisse in einer rollenden Historie.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KarmaHistorieEintrag – Typdefinition für einen einzelnen Historieeintrag
// ─────────────────────────────────────────────────────────────────────────────

/// Repräsentiert eine einzelne Karma-Änderung mit Dimension, Delta und Grund.
typedef KarmaHistorieEintrag = ({
  KarmaDimension dimension,
  double delta,
  String grund,
});

// ─────────────────────────────────────────────────────────────────────────────
// KarmaNotifier – verwaltet Karma-Änderungen im aktiven Zyklus
// ─────────────────────────────────────────────────────────────────────────────

/// StateNotifier für das aktive Karma-Profil des laufenden Lebenszyklus.
///
/// Berechnet Jenseitsreich und dominante Dimension reaktiv. Änderungen
/// werden als Deltas übergeben und auf den Bereich [-100, +100] begrenzt.
class KarmaNotifier extends StateNotifier<KarmaProfilModel> {
  KarmaNotifier() : super(KarmaProfilModel.neutral());

  // ───────────────────────────────────────────────────────────────────────────
  // Öffentliche Methoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Addiert einen Delta-Wert auf eine Karma-Dimension.
  ///
  /// Der resultierende Wert wird auf [-100, +100] begrenzt.
  /// [dim] – die betroffene Karma-Achse
  /// [delta] – die Änderung (positiv = besser, negativ = schlechter)
  void dimensionAendern(KarmaDimension dim, double delta) {
    final aktuellerWert = switch (dim) {
      KarmaDimension.mitgefuehl => state.mitgefuehl,
      KarmaDimension.ehrlichkeit => state.ehrlichkeit,
      KarmaDimension.mut => state.mut,
      KarmaDimension.grosszuegigkeit => state.grosszuegigkeit,
      KarmaDimension.weisheit => state.weisheit,
      KarmaDimension.liebe => state.liebe,
    };

    final neuerWert = (aktuellerWert + delta).clamp(-100.0, 100.0);
    state = state.dimensionAktualisieren(dim, neuerWert);
  }

  /// Setzt das Karma-Profil auf neutral zurück (für neuen Zyklus).
  void karmaZuruecksetzen() {
    state = KarmaProfilModel.neutral();
  }

  /// Setzt das Karma-Profil auf einen bestimmten Wert (z.B. beim Laden).
  void karmaSetzen(KarmaProfilModel neuesProfil) {
    state = neuesProfil;
  }

  /// Berechnet das kumulative Karma aus einer Liste aller vergangenen Zyklen.
  ///
  /// Mittelt alle sechs Dimensionen über alle übergebenen [alleZyklen].
  /// Gibt ein neutrales Profil zurück, wenn die Liste leer ist.
  KarmaProfilModel kumulativesKarmaBerechnen(
      List<KarmaProfilModel> alleZyklen) {
    if (alleZyklen.isEmpty) return KarmaProfilModel.neutral();

    final anzahl = alleZyklen.length.toDouble();

    // Summen über alle Zyklen berechnen
    double sumMitgefuehl = 0;
    double sumEhrlichkeit = 0;
    double sumMut = 0;
    double sumGrosszuegigkeit = 0;
    double sumWeisheit = 0;
    double sumLiebe = 0;

    for (final zyklus in alleZyklen) {
      sumMitgefuehl += zyklus.mitgefuehl;
      sumEhrlichkeit += zyklus.ehrlichkeit;
      sumMut += zyklus.mut;
      sumGrosszuegigkeit += zyklus.grosszuegigkeit;
      sumWeisheit += zyklus.weisheit;
      sumLiebe += zyklus.liebe;
    }

    return KarmaProfilModel(
      mitgefuehl: (sumMitgefuehl / anzahl).clamp(-100.0, 100.0),
      ehrlichkeit: (sumEhrlichkeit / anzahl).clamp(-100.0, 100.0),
      mut: (sumMut / anzahl).clamp(-100.0, 100.0),
      grosszuegigkeit: (sumGrosszuegigkeit / anzahl).clamp(-100.0, 100.0),
      weisheit: (sumWeisheit / anzahl).clamp(-100.0, 100.0),
      liebe: (sumLiebe / anzahl).clamp(-100.0, 100.0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Karma-Provider – verwaltet das aktive Karma-Profil des laufenden Zyklus.
final karmaProvider =
    StateNotifierProvider<KarmaNotifier, KarmaProfilModel>((ref) {
  return KarmaNotifier();
});

// ─────────────────────────────────────────────────────────────────────────────
// Berechnete Provider (reaktiv aus karmaProvider abgeleitet)
// ─────────────────────────────────────────────────────────────────────────────

/// Berechnet das Jenseitsreich basierend auf dem aktuellen Karma-Durchschnitt.
///
/// Gibt eines der fünf Jenseitsreiche zurück:
/// Elysium (≥60), Harmonia (≥20), Limbus (neutral),
/// Shadowlands (≤-20), Abyssus (≤-60)
final jenseitsReichProvider = Provider<JenseitsReich>((ref) {
  final karma = ref.watch(karmaProvider);
  return karma.jenseitsReich;
});

/// Gibt den Karma-Durchschnittswert über alle sechs Dimensionen zurück.
///
/// Bereich: -100.0 (vollständig negativ) bis +100.0 (vollständig positiv)
final karmaDurchschnittProvider = Provider<double>((ref) {
  final karma = ref.watch(karmaProvider);
  return karma.durchschnitt;
});

/// Gibt die Karma-Dimension mit dem höchsten absoluten Wert zurück.
///
/// Diese Dimension prägt den Charakter am stärksten – positiv oder negativ.
final dominanteKarmaDimensionProvider = Provider<KarmaDimension>((ref) {
  final karma = ref.watch(karmaProvider);
  return karma.dominanteDimension;
});

/// Gibt alle sechs Karma-Dimensionswerte als geordnete Map zurück.
///
/// Nützlich für Radar-Chart-Darstellungen und Karma-Übersichten.
final karmaWerteMapProvider = Provider<Map<KarmaDimension, double>>((ref) {
  final karma = ref.watch(karmaProvider);
  return {
    KarmaDimension.mitgefuehl: karma.mitgefuehl,
    KarmaDimension.ehrlichkeit: karma.ehrlichkeit,
    KarmaDimension.mut: karma.mut,
    KarmaDimension.grosszuegigkeit: karma.grosszuegigkeit,
    KarmaDimension.weisheit: karma.weisheit,
    KarmaDimension.liebe: karma.liebe,
  };
});

/// Gibt zurück, ob das aktuelle Karma insgesamt positiv ist (Durchschnitt > 0).
final istKarmaPositivProvider = Provider<bool>((ref) {
  return ref.watch(karmaDurchschnittProvider) > 0;
});

// ─────────────────────────────────────────────────────────────────────────────
// Karma-Historie (letzte 10 Änderungen, rollend)
// ─────────────────────────────────────────────────────────────────────────────

/// Rollende Liste der letzten 10 Karma-Änderungen.
///
/// Jeder Eintrag enthält Dimension, Delta und den Auslösegrund.
/// Älteste Einträge werden automatisch verdrängt, wenn die Kapazität voll ist.
final karmaHistorieProvider =
    StateProvider<List<KarmaHistorieEintrag>>((ref) => const []);

/// Maximale Anzahl an Einträgen in der Karma-Historie.
const int kMaxKarmaHistorieEintraege = 10;

/// Hilfsfunktion: Fügt einen neuen Eintrag zur Karma-Historie hinzu.
///
/// Wird von außen aufgerufen (z.B. aus SpielNotifier oder KarmaNotifier),
/// wenn eine Karma-Änderung stattfindet.
///
/// Benutze [ref.read(karmaHistorieProvider.notifier).state] um zu aktualisieren.
void karmaHistorieEintragHinzufuegen(
  StateController<List<KarmaHistorieEintrag>> notifier,
  KarmaDimension dimension,
  double delta,
  String grund,
) {
  final neuerEintrag = (dimension: dimension, delta: delta, grund: grund);
  final aktuelleHistorie = notifier.state;

  // Rollende Liste: maximale Kapazität einhalten
  final aktualisiert = [
    neuerEintrag,
    ...aktuelleHistorie,
  ].take(kMaxKarmaHistorieEintraege).toList();

  notifier.state = aktualisiert;
}

/// Gibt nur Karma-Historieeinträge einer bestimmten Dimension zurück.
final karmaHistorieNachDimensionProvider =
    Provider.family<List<KarmaHistorieEintrag>, KarmaDimension>(
  (ref, dimension) {
    final historie = ref.watch(karmaHistorieProvider);
    return historie.where((e) => e.dimension == dimension).toList();
  },
);
