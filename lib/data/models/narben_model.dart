// narben_model.dart
// Narben repräsentieren physische und emotionale Wunden des Charakters.
// Geheilte Narben werden zu Stärken – ungeheilte zu Triggern.

import 'package:uuid/uuid.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: NarbenTyp
// ─────────────────────────────────────────────────────────────────────────────

/// Die zwei Arten von Narben im System
enum NarbenTyp {
  /// Körperliche Narbe – sichtbar, beeinflusst Körper-Simulation
  physisch,

  /// Emotionale Narbe – unsichtbar, beeinflusst Entscheidungsoptionen
  emotional,
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum: NarbenStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Der Heilungsstatus einer Narbe
enum NarbenStatus {
  /// Narbe ist frisch und aktiv – starker Einfluss
  frisch,

  /// Narbe verheilt langsam – mittlerer Einfluss
  heilend,

  /// Narbe ist geheilt – wird zur Stärke
  geheilt,

  /// Narbe wurde verdrängt – tritt als Trigger auf
  verdraengt,
}

// ─────────────────────────────────────────────────────────────────────────────
// NarbenModel – eine einzelne Narbe
// ─────────────────────────────────────────────────────────────────────────────

/// Repräsentiert eine physische oder emotionale Narbe des Charakters.
///
/// Jede Narbe hat Trigger-Situationen, die sie aktivieren,
/// und Heilungswege, die sie zur Stärke transformieren können.
class NarbenModel {
  /// Eindeutige ID dieser Narbe
  final String id;

  /// Beschreibung der Narbe (was passiert ist)
  final String beschreibung;

  /// Welche Art von Narbe
  final NarbenTyp typ;

  /// Aktueller Heilungsstatus
  final NarbenStatus status;

  /// Welche Spielphase diese Narbe verursacht hat
  final GamePhase entstandenInPhase;

  /// Situationen, die diese Narbe triggern (Themen-Schlüsselwörter)
  final List<String> trigger;

  /// Wie stark diese Narbe Entscheidungen beeinflusst (0.0–1.0)
  final double intensitaet;

  /// Ob diese Narbe an Kinder vererbt wurde (emotionale Narben)
  final bool istVererbt;

  /// Name des Heilungswegs (falls bekannt)
  final String? heilungsWeg;

  /// Wenn geheilt: welche Stärke daraus wurde
  final String? resultierendeStaerke;

  const NarbenModel({
    required this.id,
    required this.beschreibung,
    required this.typ,
    required this.status,
    required this.entstandenInPhase,
    required this.trigger,
    required this.intensitaet,
    required this.istVererbt,
    this.heilungsWeg,
    this.resultierendeStaerke,
  });

  factory NarbenModel.erstellen({
    required String beschreibung,
    required NarbenTyp typ,
    required GamePhase entstandenInPhase,
    List<String> trigger = const [],
    double intensitaet = 0.5,
    bool istVererbt = false,
    String? heilungsWeg,
  }) {
    return NarbenModel(
      id: const Uuid().v4(),
      beschreibung: beschreibung,
      typ: typ,
      status: NarbenStatus.frisch,
      entstandenInPhase: entstandenInPhase,
      trigger: trigger,
      intensitaet: intensitaet.clamp(0.0, 1.0),
      istVererbt: istVererbt,
      heilungsWeg: heilungsWeg,
      resultierendeStaerke: null,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Ob diese Narbe aktiv die Wahrnehmung einschränkt
  bool get istAktiv =>
      status == NarbenStatus.frisch || status == NarbenStatus.heilend;

  /// Ob diese Narbe zur Stärke geworden ist
  bool get istGeheilteStaerke =>
      status == NarbenStatus.geheilt && resultierendeStaerke != null;

  /// Modifier für Entscheidungsoptionen bei relevanten Triggern (-1.0 bis +1.0)
  double get entscheidungsModifier {
    if (status == NarbenStatus.geheilt) return 0.2; // Bonus für Überwundenes
    if (status == NarbenStatus.verdraengt) return -intensitaet;
    if (status == NarbenStatus.frisch) return -intensitaet;
    return -intensitaet * 0.5; // heilend
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Mutationsmethoden
  // ───────────────────────────────────────────────────────────────────────────

  NarbenModel copyWith({
    NarbenStatus? status,
    double? intensitaet,
    bool? istVererbt,
    String? heilungsWeg,
    String? resultierendeStaerke,
  }) {
    return NarbenModel(
      id: id,
      beschreibung: beschreibung,
      typ: typ,
      status: status ?? this.status,
      entstandenInPhase: entstandenInPhase,
      trigger: trigger,
      intensitaet: intensitaet ?? this.intensitaet,
      istVererbt: istVererbt ?? this.istVererbt,
      heilungsWeg: heilungsWeg ?? this.heilungsWeg,
      resultierendeStaerke: resultierendeStaerke ?? this.resultierendeStaerke,
    );
  }

  /// Heilt die Narbe und verwandelt sie in eine Stärke.
  NarbenModel heilen(String staerkeBeschreibung) => copyWith(
        status: NarbenStatus.geheilt,
        resultierendeStaerke: staerkeBeschreibung,
        intensitaet: 0.0,
      );

  /// Verdrängt die Narbe – erhöht das Trigger-Risiko.
  NarbenModel verdraengen() => copyWith(
        status: NarbenStatus.verdraengt,
        intensitaet: (intensitaet * 1.3).clamp(0.0, 1.0),
      );

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'beschreibung': beschreibung,
        'typ': typ.name,
        'status': status.name,
        'entstandenInPhase': entstandenInPhase.name,
        'trigger': trigger,
        'intensitaet': intensitaet,
        'istVererbt': istVererbt,
        'heilungsWeg': heilungsWeg,
        'resultierendeStaerke': resultierendeStaerke,
      };

  factory NarbenModel.fromJson(Map<String, dynamic> json) {
    return NarbenModel(
      id: json['id'] as String,
      beschreibung: json['beschreibung'] as String,
      typ: NarbenTyp.values.firstWhere(
        (t) => t.name == json['typ'],
        orElse: () => NarbenTyp.emotional,
      ),
      status: NarbenStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => NarbenStatus.frisch,
      ),
      entstandenInPhase: GamePhase.values.firstWhere(
        (p) => p.name == json['entstandenInPhase'],
        orElse: () => GamePhase.kindheit,
      ),
      trigger: List<String>.from(json['trigger'] as List),
      intensitaet: (json['intensitaet'] as num).toDouble(),
      istVererbt: json['istVererbt'] as bool,
      heilungsWeg: json['heilungsWeg'] as String?,
      resultierendeStaerke: json['resultierendeStaerke'] as String?,
    );
  }
}
