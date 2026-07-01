// sucht_model.dart
// Modelliert Abhängigkeiten von Substanzen, Macht, Ruhm, Liebe oder Arbeit.
// Keine Überwindung führt zu einem anderen Weg – nicht zu einem schlechteren.

import 'package:uuid/uuid.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: SuchtTyp
// ─────────────────────────────────────────────────────────────────────────────

/// Die verschiedenen Arten von Abhängigkeiten im Spiel
enum SuchtTyp {
  /// Substanzen: Alkohol, Drogen, Medikamente
  substanz,

  /// Macht: politische Kontrolle, Dominanz
  macht,

  /// Ruhm: Aufmerksamkeit, Anerkennung, Status
  ruhm,

  /// Liebe: toxische Abhängigkeit von einer Person
  liebe,

  /// Arbeit: Workaholismus, Selbstverlust in der Arbeit
  arbeit,

  /// Glücksspiel: Kontrollverlust bei Risiko und Gewinn
  gluecksspiel,

  /// Religion/Ideologie: extremes Glaubenssystem
  ideologie,
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum: SuchtPhase
// ─────────────────────────────────────────────────────────────────────────────

/// Die Entwicklungsphasen einer Abhängigkeit
enum SuchtPhase {
  /// Erste Kontakte – Neugier ohne Abhängigkeit
  erstKontakt,

  /// Regelmäßiger Konsum – Abhängigkeit beginnt
  gewohnheit,

  /// Unkontrollierbare Abhängigkeit – Wahrnehmung verzerrt
  abhaengig,

  /// Aktiver Entzug – eigene Herausforderungssequenz
  entzug,

  /// Überwunden – Willenskraft-Bonus freigeschaltet
  ueberwunden,
}

// ─────────────────────────────────────────────────────────────────────────────
// SuchtModel – eine einzelne Abhängigkeit
// ─────────────────────────────────────────────────────────────────────────────

/// Modelliert eine Abhängigkeit mit Progression, Wahrnehmungsverzerrung
/// und Überwindungsmöglichkeit.
class SuchtModel {
  /// Eindeutige ID
  final String id;

  /// Art der Abhängigkeit
  final SuchtTyp typ;

  /// Aktuelle Phase der Sucht-Entwicklung
  final SuchtPhase phase;

  /// Stärke der Abhängigkeit (0.0–1.0)
  final double staerke;

  /// Wie stark die Wahrnehmung verzerrt wird (0.0 = keine, 1.0 = maximal)
  final double wahrnehmungsVerzerrung;

  /// Welcher ungeheilter Narben-Trigger diese Sucht ausgelöst hat
  final String? ausloeserNarbenId;

  /// In welcher Phase des Lebens die Sucht begann
  final GamePhase entstandenInPhase;

  /// Aktueller Entzugs-Fortschritt wenn in Entzugs-Phase (0.0–1.0)
  final double entzugsFortschritt;

  /// Willenskraft-Bonus nach Überwindung (0.0–0.3)
  final double willenskraftBonus;

  const SuchtModel({
    required this.id,
    required this.typ,
    required this.phase,
    required this.staerke,
    required this.wahrnehmungsVerzerrung,
    this.ausloeserNarbenId,
    required this.entstandenInPhase,
    required this.entzugsFortschritt,
    required this.willenskraftBonus,
  });

  factory SuchtModel.erstellen({
    required SuchtTyp typ,
    required GamePhase entstandenInPhase,
    String? ausloeserNarbenId,
  }) {
    return SuchtModel(
      id: const Uuid().v4(),
      typ: typ,
      phase: SuchtPhase.erstKontakt,
      staerke: 0.1,
      wahrnehmungsVerzerrung: 0.05,
      ausloeserNarbenId: ausloeserNarbenId,
      entstandenInPhase: entstandenInPhase,
      entzugsFortschritt: 0.0,
      willenskraftBonus: 0.0,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Ob die Sucht aktiv die Wahrnehmung verzerrt (Phase: abhängig)
  bool get verzerrtWahrnehmung =>
      phase == SuchtPhase.abhaengig && wahrnehmungsVerzerrung > 0.3;

  /// Ob die Sucht vollständig überwunden wurde
  bool get istUeberwunden => phase == SuchtPhase.ueberwunden;

  /// Ob gerade aktiver Entzug läuft
  bool get istImEntzug => phase == SuchtPhase.entzug;

  /// Welche Entscheidungsoptionen durch diese Sucht blockiert oder verändert werden
  List<String> get blockierteOptionen {
    if (!verzerrtWahrnehmung) return const [];
    return switch (typ) {
      SuchtTyp.substanz => ['rational_entscheiden', 'konsequenzen_sehen'],
      SuchtTyp.macht => ['teilen', 'zuruecktreten', 'nachgeben'],
      SuchtTyp.ruhm => ['bescheidenheit', 'stille'],
      SuchtTyp.liebe => ['trennung', 'abstand', 'eigenstaendigkeit'],
      SuchtTyp.arbeit => ['pause', 'urlaub', 'familie_prioritaet'],
      SuchtTyp.gluecksspiel => ['sparen', 'aufhoeren'],
      SuchtTyp.ideologie => ['hinterfragen', 'anderssein'],
    };
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Mutationsmethoden
  // ───────────────────────────────────────────────────────────────────────────

  SuchtModel copyWith({
    SuchtPhase? phase,
    double? staerke,
    double? wahrnehmungsVerzerrung,
    double? entzugsFortschritt,
    double? willenskraftBonus,
  }) {
    return SuchtModel(
      id: id,
      typ: typ,
      phase: phase ?? this.phase,
      staerke: (staerke ?? this.staerke).clamp(0.0, 1.0),
      wahrnehmungsVerzerrung:
          (wahrnehmungsVerzerrung ?? this.wahrnehmungsVerzerrung).clamp(0.0, 1.0),
      ausloeserNarbenId: ausloeserNarbenId,
      entstandenInPhase: entstandenInPhase,
      entzugsFortschritt:
          (entzugsFortschritt ?? this.entzugsFortschritt).clamp(0.0, 1.0),
      willenskraftBonus:
          (willenskraftBonus ?? this.willenskraftBonus).clamp(0.0, 0.3),
    );
  }

  /// Verstärkt die Sucht (weiterer Konsum / Verstrickung)
  SuchtModel verstaerken(double betrag) {
    final neueStaerke = (staerke + betrag).clamp(0.0, 1.0);
    SuchtPhase neuePhase = phase;

    if (neueStaerke >= 0.7 && phase != SuchtPhase.abhaengig &&
        phase != SuchtPhase.entzug && phase != SuchtPhase.ueberwunden) {
      neuePhase = SuchtPhase.abhaengig;
    } else if (neueStaerke >= 0.3 && phase == SuchtPhase.erstKontakt) {
      neuePhase = SuchtPhase.gewohnheit;
    }

    return copyWith(
      staerke: neueStaerke,
      wahrnehmungsVerzerrung: neueStaerke * 0.8,
      phase: neuePhase,
    );
  }

  /// Startet den Entzug
  SuchtModel entzugBeginnen() => copyWith(phase: SuchtPhase.entzug);

  /// Fortschritt im Entzug – bei 1.0 vollständig überwunden
  SuchtModel entzugFortschreiten(double betrag) {
    final neuerFortschritt = (entzugsFortschritt + betrag).clamp(0.0, 1.0);
    if (neuerFortschritt >= 1.0) {
      return copyWith(
        phase: SuchtPhase.ueberwunden,
        entzugsFortschritt: 1.0,
        staerke: 0.0,
        wahrnehmungsVerzerrung: 0.0,
        willenskraftBonus: 0.25,
      );
    }
    return copyWith(
      entzugsFortschritt: neuerFortschritt,
      staerke: (staerke - betrag * 0.5).clamp(0.0, 1.0),
      wahrnehmungsVerzerrung: ((1 - neuerFortschritt) * staerke * 0.8).clamp(0.0, 1.0),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'typ': typ.name,
        'phase': phase.name,
        'staerke': staerke,
        'wahrnehmungsVerzerrung': wahrnehmungsVerzerrung,
        'ausloeserNarbenId': ausloeserNarbenId,
        'entstandenInPhase': entstandenInPhase.name,
        'entzugsFortschritt': entzugsFortschritt,
        'willenskraftBonus': willenskraftBonus,
      };

  factory SuchtModel.fromJson(Map<String, dynamic> json) {
    return SuchtModel(
      id: json['id'] as String,
      typ: SuchtTyp.values.firstWhere(
        (t) => t.name == json['typ'],
        orElse: () => SuchtTyp.substanz,
      ),
      phase: SuchtPhase.values.firstWhere(
        (p) => p.name == json['phase'],
        orElse: () => SuchtPhase.erstKontakt,
      ),
      staerke: (json['staerke'] as num).toDouble(),
      wahrnehmungsVerzerrung:
          (json['wahrnehmungsVerzerrung'] as num).toDouble(),
      ausloeserNarbenId: json['ausloeserNarbenId'] as String?,
      entstandenInPhase: GamePhase.values.firstWhere(
        (p) => p.name == json['entstandenInPhase'],
        orElse: () => GamePhase.jugend,
      ),
      entzugsFortschritt: (json['entzugsFortschritt'] as num).toDouble(),
      willenskraftBonus: (json['willenskraftBonus'] as num).toDouble(),
    );
  }
}
