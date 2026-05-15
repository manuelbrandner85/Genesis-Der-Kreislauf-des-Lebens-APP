// gedanken_provider.dart
// Gedanken-Inventar-Provider für GENESIS: Der Kreislauf des Lebens.
// Verwaltet alle aktiven Gedanken des Charakters: Hinzufügen, Abschließen,
// Loslassen und Auswählen für das Karma-Gericht.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GedankenNotifier – verwaltet das Gedanken-Inventar
// ─────────────────────────────────────────────────────────────────────────────

/// StateNotifier für die Liste aller aktiven Gedanken im Bewusstsein des Charakters.
///
/// Gedanken können aus dem aktuellen oder vergangenen Leben stammen.
/// Das Inventar wird im Karma-Gericht ausgewertet, um mitgenommene
/// Gedanken in den nächsten Zyklus zu übertragen.
class GedankenNotifier extends StateNotifier<List<GedankeModel>> {
  GedankenNotifier() : super(const []);

  // ───────────────────────────────────────────────────────────────────────────
  // Öffentliche Methoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Fügt einen neuen Gedanken zum Inventar hinzu.
  ///
  /// Duplikate (gleiche ID) werden ignoriert.
  void gedankeHinzufuegen(GedankeModel gedanke) {
    // Duplikat-Prüfung
    if (state.any((g) => g.id == gedanke.id)) return;

    state = [...state, gedanke];
  }

  /// Mehrere Gedanken auf einmal hinzufügen (z.B. beim Laden eines Zyklus).
  void gedankenSetzen(List<GedankeModel> gedanken) {
    state = List.from(gedanken);
  }

  /// Markiert einen Gedanken als abgeschlossen (aufgelöst, verarbeitet).
  ///
  /// Abgeschlossene Gedanken bleiben im Inventar, haben aber keinen
  /// aktiven Einfluss mehr auf den Charakter.
  void gedankeAbschliessen(String id) {
    state = state.map((g) {
      if (g.id != id) return g;
      return g.copyWith(istAbgeschlossen: true);
    }).toList();
  }

  /// Entfernt einen Gedanken vollständig aus dem Inventar (Loslassen).
  ///
  /// Dieser Vorgang ist unwiderruflich – der Gedanke kann nicht wiederhergestellt werden.
  void gedankeEntfernen(String id) {
    state = state.where((g) => g.id != id).toList();
  }

  /// Aktualisiert einen bestehenden Gedanken durch eine neue Instanz.
  ///
  /// Falls kein Gedanke mit der angegebenen ID existiert, wird nichts geändert.
  void gedankeAktualisieren(GedankeModel aktualisiert) {
    state = state.map((g) {
      return g.id == aktualisiert.id ? aktualisiert : g;
    }).toList();
  }

  /// Markiert oder hebt die Mitnahme-Markierung eines Gedankens auf.
  ///
  /// Im Karma-Gericht bestimmt diese Markierung, welche Gedanken
  /// ins nächste Leben mitgenommen werden.
  void mitnahmeToggle(String id) {
    state = state.map((g) {
      if (g.id != id) return g;
      return g.copyWith(wirdMitgenommen: !g.wirdMitgenommen);
    }).toList();
  }

  /// Setzt die Mitnahme-Markierung für einen Gedanken explizit.
  void mitnahmeSetzen(String id, {required bool wirdMitgenommen}) {
    state = state.map((g) {
      if (g.id != id) return g;
      return g.copyWith(wirdMitgenommen: wirdMitgenommen);
    }).toList();
  }

  /// Findet alle Gedanken, die durch ein bestimmtes Thema ausgelöst werden können.
  ///
  /// Sucht in [ausloesende_themen] (case-insensitive) nach dem Thema.
  /// Gibt eine leere Liste zurück, wenn kein Gedanke zutrifft.
  List<GedankeModel> ausloesendeFinden(String thema) {
    final themaNorm = thema.toLowerCase().trim();
    return state
        .where((g) => g.ausloesende_themen
            .any((t) => t.toLowerCase().contains(themaNorm)))
        .toList();
  }

  /// Wählt 1 bis 3 Gedanken für das Karma-Gericht aus.
  ///
  /// Auswahlkriterien (absteigende Priorität):
  /// 1. Nicht abgeschlossene Gedanken
  /// 2. Höchste Intensität
  /// 3. Giftige Gedanken haben Vorrang bei gleichem Intensitätswert
  ///
  /// Gibt maximal 3 Gedanken zurück; mindestens 1 wenn vorhanden.
  List<GedankeModel> fuerKarmaGerichtAuswaehlen() {
    // Nur aktive (nicht abgeschlossene) Gedanken berücksichtigen
    final aktive = state.where((g) => !g.istAbgeschlossen).toList();

    if (aktive.isEmpty) return const [];

    // Nach Intensität sortieren (höchste zuerst), giftige bevorzugen
    aktive.sort((a, b) {
      // Giftiger Gedanke erhält Bonus von +0.2 auf die effektive Intensität
      final effektivA = a.intensitaet + (a.istGiftig ? 0.2 : 0.0);
      final effektivB = b.intensitaet + (b.istGiftig ? 0.2 : 0.0);
      return effektivB.compareTo(effektivA);
    });

    // Maximal 3 zurückgeben (mindestens 1)
    return aktive.take(3).toList();
  }

  /// Löscht alle Gedanken (z.B. beim Start eines neuen Zyklus).
  void alleLoeschen() {
    state = const [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Gedanken-Provider – verwaltet das vollständige Gedanken-Inventar.
final gedankenProvider =
    StateNotifierProvider<GedankenNotifier, List<GedankeModel>>((ref) {
  return GedankenNotifier();
});

// ─────────────────────────────────────────────────────────────────────────────
// Abgeleitete Provider (gefilterte Sichten auf das Inventar)
// ─────────────────────────────────────────────────────────────────────────────

/// Gibt nur toxische/giftige Gedanken zurück.
///
/// Giftige Gedanken belasten den Charakter und beeinflussen das Karma negativ.
final giftigeGedankenProvider = Provider<List<GedankeModel>>((ref) {
  final gedanken = ref.watch(gedankenProvider);
  return gedanken.where((g) => g.istGiftig && !g.istAbgeschlossen).toList();
});

/// Gibt alle Gedanken zurück, die für den nächsten Zyklus markiert sind.
///
/// Diese Gedanken hat der Spieler im Karma-Gericht als mitzunehmend ausgewählt.
final mitgenommeneGedankenProvider = Provider<List<GedankeModel>>((ref) {
  final gedanken = ref.watch(gedankenProvider);
  return gedanken.where((g) => g.wirdMitgenommen).toList();
});

/// Gibt alle abgeschlossenen Gedanken zurück.
///
/// Diese wurden verarbeitet und haben keinen aktiven Einfluss mehr.
final abgeschlosseneGedankenProvider = Provider<List<GedankeModel>>((ref) {
  final gedanken = ref.watch(gedankenProvider);
  return gedanken.where((g) => g.istAbgeschlossen).toList();
});

/// Gibt alle aktiven (nicht abgeschlossenen) Gedanken zurück.
final aktiveGedankenProvider = Provider<List<GedankeModel>>((ref) {
  final gedanken = ref.watch(gedankenProvider);
  return gedanken.where((g) => !g.istAbgeschlossen).toList();
});

/// Filtert Gedanken nach einem bestimmten [GedankenTyp].
///
/// Nützlich für typ-spezifische Anzeigen (z.B. nur Traumata, nur Weisheiten).
final gedankenNachTypProvider =
    Provider.family<List<GedankeModel>, GedankenTyp>((ref, typ) {
  final gedanken = ref.watch(gedankenProvider);
  return gedanken.where((g) => g.typ == typ).toList();
});

/// Gibt die Anzahl aller aktiven Gedanken zurück (für UI-Badges).
final gedankenAnzahlProvider = Provider<int>((ref) {
  return ref.watch(aktiveGedankenProvider).length;
});

/// Gibt die Anzahl giftiger Gedanken zurück (für Warn-Badges).
final giftigeGedankenAnzahlProvider = Provider<int>((ref) {
  return ref.watch(giftigeGedankenProvider).length;
});

/// Gibt die durchschnittliche Intensität aller aktiven Gedanken zurück.
///
/// Ein hoher Wert signalisiert einen aufgewühlten mentalen Zustand.
final gedankenIntensitaetDurchschnittProvider = Provider<double>((ref) {
  final aktive = ref.watch(aktiveGedankenProvider);
  if (aktive.isEmpty) return 0.0;
  final summe = aktive.fold<double>(0.0, (sum, g) => sum + g.intensitaet);
  return summe / aktive.length;
});
