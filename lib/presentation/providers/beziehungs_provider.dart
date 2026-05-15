// beziehungs_provider.dart
// Beziehungsnetzwerk-Provider für GENESIS: Der Kreislauf des Lebens.
// Verwaltet alle sozialen Verbindungen des Charakters – NPCs und echte Mitspieler.
// Beziehungen entwickeln sich über Entscheidungen, geteilte Erinnerungen und Konflikte.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genesis_kreislauf_des_lebens/data/models/beziehung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/erinnerung_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BeziehungsNotifier – verwaltet das soziale Netzwerk des Charakters
// ─────────────────────────────────────────────────────────────────────────────

/// StateNotifier für alle Beziehungen im aktuellen Lebenszyklus.
///
/// Beziehungen können zu NPCs oder echten Mitspielern bestehen.
/// Vertrauen, Respekt und Liebe ändern sich durch Entscheidungen und Ereignisse.
class BeziehungsNotifier extends StateNotifier<List<BeziehungModel>> {
  BeziehungsNotifier() : super(const []);

  // ───────────────────────────────────────────────────────────────────────────
  // Öffentliche Methoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Fügt eine neue Beziehung zum Netzwerk hinzu.
  ///
  /// Duplikate (gleiche ID) werden ignoriert, um inkonsistente Zustände zu vermeiden.
  void beziehungHinzufuegen(BeziehungModel beziehung) {
    if (state.any((b) => b.id == beziehung.id)) return;
    state = [...state, beziehung];
  }

  /// Setzt alle Beziehungen auf einmal (z.B. beim Laden eines gespeicherten Zyklus).
  void beziehungenSetzen(List<BeziehungModel> beziehungen) {
    state = List.from(beziehungen);
  }

  /// Ändert das Vertrauen in einer Beziehung um einen Delta-Wert.
  ///
  /// Der Wert wird auf [0.0, 100.0] begrenzt. Negative Werte senken das Vertrauen.
  /// [id] – ID der betroffenen Beziehung
  /// [delta] – Änderung des Vertrauenswerts (positiv = mehr, negativ = weniger)
  void vertrauenAendern(String id, double delta) {
    state = state.map((b) {
      if (b.id != id) return b;
      final neuerWert = (b.vertrauen + delta).clamp(0.0, 100.0);
      return b.copyWith(vertrauen: neuerWert);
    }).toList();
  }

  /// Ändert den Respekt in einer Beziehung um einen Delta-Wert.
  ///
  /// Der Wert wird auf [0.0, 100.0] begrenzt.
  void respektAendern(String id, double delta) {
    state = state.map((b) {
      if (b.id != id) return b;
      final neuerWert = (b.respekt + delta).clamp(0.0, 100.0);
      return b.copyWith(respekt: neuerWert);
    }).toList();
  }

  /// Ändert die Liebe in einer Beziehung um einen Delta-Wert.
  ///
  /// Der Wert wird auf [0.0, 100.0] begrenzt.
  void liebeAendern(String id, double delta) {
    state = state.map((b) {
      if (b.id != id) return b;
      final neuerWert = (b.liebe + delta).clamp(0.0, 100.0);
      return b.copyWith(liebe: neuerWert);
    }).toList();
  }

  /// Markiert eine Beziehung als geheilt.
  ///
  /// Setzt [istGeheilt] auf true und erhöht Vertrauen und Respekt um je 20 Punkte.
  /// Nur wirksam, wenn die Beziehung zerbrochen war.
  void beziehungHeilen(String id) {
    state = state.map((b) {
      if (b.id != id) return b;
      return b.copyWith(
        istGeheilt: true,
        vertrauen: (b.vertrauen + 20.0).clamp(0.0, 100.0),
        respekt: (b.respekt + 20.0).clamp(0.0, 100.0),
      );
    }).toList();
  }

  /// Fügt einen ungelösten Konflikt zu einer Beziehung hinzu.
  ///
  /// Konflikte belasten die Beziehungsqualität und können im späteren Leben
  /// eskalieren oder aufgelöst werden.
  void konfliktHinzufuegen(String id, String konflikt) {
    state = state.map((b) {
      if (b.id != id) return b;
      // Vertrauen durch Konflikt leicht verringern
      final aktualisiertKonflikte = [...b.ungeloestKonflikte, konflikt];
      return b.copyWith(
        ungeloestKonflikte: aktualisiertKonflikte,
        vertrauen: (b.vertrauen - 10.0).clamp(0.0, 100.0),
      );
    }).toList();
  }

  /// Löst einen Konflikt in einer Beziehung auf.
  ///
  /// Erhöht Vertrauen und Respekt leicht als Resultat der Konfliktlösung.
  void konfliktLoesen(String id, String konflikt) {
    state = state.map((b) {
      if (b.id != id) return b;
      final aktualisiertKonflikte =
          b.ungeloestKonflikte.where((k) => k != konflikt).toList();
      return b.copyWith(
        ungeloestKonflikte: aktualisiertKonflikte,
        vertrauen: (b.vertrauen + 8.0).clamp(0.0, 100.0),
        respekt: (b.respekt + 5.0).clamp(0.0, 100.0),
      );
    }).toList();
  }

  /// Teilt eine Erinnerung mit einer bestimmten Person.
  ///
  /// Fügt die Erinnerung zu [geteilteErinnerungen] hinzu und
  /// stärkt die Verbindung (Vertrauen und Liebe +5 je nach Erinnerungsqualität).
  void erinnerungTeilen(String id, ErinnerungModel erinnerung) {
    state = state.map((b) {
      if (b.id != id) return b;

      // Duplikat-Prüfung
      if (b.geteilteErinnerungen.any((e) => e.id == erinnerung.id)) return b;

      final aktualisiertErinnerungen = [...b.geteilteErinnerungen, erinnerung];

      // Positive Erinnerungen stärken die Verbindung mehr als negative
      final vertrauensBonus =
          erinnerung.emotionaleIntensitaet * 0.1 * 5.0; // max +5
      return b.copyWith(
        geteilteErinnerungen: aktualisiertErinnerungen,
        vertrauen: (b.vertrauen + vertrauensBonus).clamp(0.0, 100.0),
        liebe: (b.liebe + vertrauensBonus * 0.5).clamp(0.0, 100.0),
      );
    }).toList();
  }

  /// Entfernt eine Beziehung vollständig aus dem Netzwerk.
  void beziehungEntfernen(String id) {
    state = state.where((b) => b.id != id).toList();
  }

  /// Löscht alle Beziehungen (z.B. beim Start eines neuen Zyklus).
  void alleLoeschen() {
    state = const [];
  }

  /// Findet die wichtigste Beziehung basierend auf der höchsten Beziehungsstärke.
  ///
  /// Die Beziehungsstärke ist der Durchschnitt aus Vertrauen, Respekt, Liebe und Abhängigkeit.
  /// Gibt null zurück, wenn keine Beziehungen vorhanden sind.
  BeziehungModel? wichtigsteFinden() {
    if (state.isEmpty) return null;
    return state.reduce(
      (a, b) =>
          a.beziehungsStaerke >= b.beziehungsStaerke ? a : b,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Beziehungs-Provider – verwaltet das gesamte soziale Netzwerk des Charakters.
final beziehungsProvider =
    StateNotifierProvider<BeziehungsNotifier, List<BeziehungModel>>((ref) {
  return BeziehungsNotifier();
});

// ─────────────────────────────────────────────────────────────────────────────
// Abgeleitete Provider (gefilterte Sichten auf das Netzwerk)
// ─────────────────────────────────────────────────────────────────────────────

/// Gibt nur echte Mitspieler-Beziehungen zurück ([istEcht] == true).
///
/// Diese unterscheiden sich von NPCs durch ihre Seelen-UUID ([teilnehmerId]).
final echtePersonenProvider = Provider<List<BeziehungModel>>((ref) {
  final beziehungen = ref.watch(beziehungsProvider);
  return beziehungen.where((b) => b.istEcht).toList();
});

/// Gibt die romantische Partnerschaft zurück (Typ == [BeziehungsTyp.partner]).
///
/// Es wird angenommen, dass maximal eine Partner-Beziehung aktiv ist.
/// Gibt null zurück, wenn kein Partner existiert.
final partnerProvider = Provider<BeziehungModel?>((ref) {
  final beziehungen = ref.watch(beziehungsProvider);
  try {
    return beziehungen.firstWhere((b) => b.typ == BeziehungsTyp.partner);
  } catch (_) {
    return null;
  }
});

/// Gibt alle Familienmitglieder zurück (Elternteil, Geschwister, Kind).
final familieProvider = Provider<List<BeziehungModel>>((ref) {
  final beziehungen = ref.watch(beziehungsProvider);
  return beziehungen
      .where((b) =>
          b.typ == BeziehungsTyp.elternteil ||
          b.typ == BeziehungsTyp.geschwister ||
          b.typ == BeziehungsTyp.kind)
      .toList();
});

/// Gibt alle Freundschaften zurück ([BeziehungsTyp.freund]).
final freundeProvider = Provider<List<BeziehungModel>>((ref) {
  final beziehungen = ref.watch(beziehungsProvider);
  return beziehungen.where((b) => b.typ == BeziehungsTyp.freund).toList();
});

/// Gibt alle Rivalen und Feinde zurück.
final antagonistenProvider = Provider<List<BeziehungModel>>((ref) {
  final beziehungen = ref.watch(beziehungsProvider);
  return beziehungen
      .where(
          (b) => b.typ == BeziehungsTyp.rivale || b.typ == BeziehungsTyp.feind)
      .toList();
});

/// Gibt die wichtigste Beziehung zurück (höchste Gesamtstärke).
final wichtigsteBeziehungProvider = Provider<BeziehungModel?>((ref) {
  final notifier = ref.watch(beziehungsProvider.notifier);
  return notifier.wichtigsteFinden();
});

/// Gibt alle Beziehungen mit ungelösten Konflikten zurück.
final konfliktBeziehungenProvider = Provider<List<BeziehungModel>>((ref) {
  final beziehungen = ref.watch(beziehungsProvider);
  return beziehungen.where((b) => b.ungeloestKonflikte.isNotEmpty).toList();
});

/// Gibt die Gesamtanzahl aktiver Beziehungen zurück (für UI-Anzeigen).
final beziehungsAnzahlProvider = Provider<int>((ref) {
  return ref.watch(beziehungsProvider).length;
});

/// Filtert Beziehungen nach einem bestimmten [BeziehungsTyp].
final beziehungenNachTypProvider =
    Provider.family<List<BeziehungModel>, BeziehungsTyp>((ref, typ) {
  final beziehungen = ref.watch(beziehungsProvider);
  return beziehungen.where((b) => b.typ == typ).toList();
});

/// Gibt die durchschnittliche Beziehungsstärke über alle Beziehungen zurück.
///
/// Ein hoher Wert signalisiert ein starkes, unterstützendes soziales Netzwerk.
final durchschnittlicheBeziehungsStaerkeProvider = Provider<double>((ref) {
  final beziehungen = ref.watch(beziehungsProvider);
  if (beziehungen.isEmpty) return 0.0;
  final summe =
      beziehungen.fold<double>(0.0, (sum, b) => sum + b.beziehungsStaerke);
  return summe / beziehungen.length;
});
