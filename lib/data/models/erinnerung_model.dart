// erinnerung_model.dart
// Repräsentiert eine emotionale Schlüsselerinnerung aus dem Leben eines Charakters.
// Erinnerungen können im Karma-Gericht ausgewählt werden und ins nächste Leben
// mitgetragen werden.

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: ErinnerungsTyp – die emotionale Qualität einer Erinnerung
// ─────────────────────────────────────────────────────────────────────────────
enum ErinnerungsTyp {
  /// Ein Moment tiefer Freude oder Glück
  freude,

  /// Ein Moment des Verlusts oder der Trauer
  trauer,

  /// Ein Moment, der Angst ausgelöst hat oder auslöst
  angst,

  /// Ein Moment unkontrollierbarer Wut
  wut,

  /// Ein Moment tiefer Verbundenheit und Liebe
  liebe,

  /// Der Verlust einer wichtigen Person oder Sache
  verlust,

  /// Ein persönlicher Sieg oder eine überwundene Herausforderung
  triumph,

  /// Ein Moment der Scham oder des Bedauerns
  scham,

  /// Ein Moment des Stolzes auf sich selbst oder andere
  stolz,

  /// Ein Moment des Staunens und der Ehrfurcht
  staunen,
}

// ─────────────────────────────────────────────────────────────────────────────
// ErinnerungModel
// ─────────────────────────────────────────────────────────────────────────────
// @JsonSerializable() – JSON-Serialisierung ist manuell implementiert
class ErinnerungModel {
  /// Eindeutige ID dieser Erinnerung
  final String id;

  /// Kurzer, prägnanter Titel der Erinnerung
  final String titel;

  /// Ausführliche Beschreibung des erlebten Moments
  final String beschreibung;

  /// Alter des Charakters zum Zeitpunkt dieser Erinnerung
  final int alter;

  /// Spielphase, in der diese Erinnerung entstanden ist
  final GamePhase phase;

  /// Emotionale Intensität der Erinnerung (0.0 = verblasst, 1.0 = unvergesslich)
  final double emotionaleIntensitaet;

  /// Emotionale Qualität dieser Erinnerung
  final ErinnerungsTyp typ;

  /// Gibt an, ob diese Erinnerung im Karma-Gericht präsentiert wurde
  final bool istKarmaGericht;

  /// Gibt an, ob diese Erinnerung ins nächste Leben mitgetragen wird
  final bool istMitgenommen;

  /// Namen der Personen, die an diesem Moment beteiligt waren
  final List<String> beteiligte;

  /// Referenz auf ein Foto im Foto-Album (null = kein Foto)
  final String? fotoRef;

  const ErinnerungModel({
    required this.id,
    required this.titel,
    required this.beschreibung,
    required this.alter,
    required this.phase,
    required this.emotionaleIntensitaet,
    required this.typ,
    required this.istKarmaGericht,
    required this.istMitgenommen,
    required this.beteiligte,
    this.fotoRef,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  ErinnerungModel copyWith({
    String? id,
    String? titel,
    String? beschreibung,
    int? alter,
    GamePhase? phase,
    double? emotionaleIntensitaet,
    ErinnerungsTyp? typ,
    bool? istKarmaGericht,
    bool? istMitgenommen,
    List<String>? beteiligte,
    String? fotoRef,
  }) {
    return ErinnerungModel(
      id: id ?? this.id,
      titel: titel ?? this.titel,
      beschreibung: beschreibung ?? this.beschreibung,
      alter: alter ?? this.alter,
      phase: phase ?? this.phase,
      emotionaleIntensitaet:
          emotionaleIntensitaet ?? this.emotionaleIntensitaet,
      typ: typ ?? this.typ,
      istKarmaGericht: istKarmaGericht ?? this.istKarmaGericht,
      istMitgenommen: istMitgenommen ?? this.istMitgenommen,
      beteiligte: beteiligte ?? this.beteiligte,
      fotoRef: fotoRef ?? this.fotoRef,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  factory ErinnerungModel.fromJson(Map<String, dynamic> json) {
    return ErinnerungModel(
      id: json['id'] as String,
      titel: json['titel'] as String,
      beschreibung: json['beschreibung'] as String,
      alter: json['alter'] as int,
      phase: GamePhase.values.byName(json['phase'] as String),
      emotionaleIntensitaet:
          (json['emotionaleIntensitaet'] as num).toDouble(),
      typ: ErinnerungsTyp.values.byName(json['typ'] as String),
      istKarmaGericht: json['istKarmaGericht'] as bool,
      istMitgenommen: json['istMitgenommen'] as bool,
      beteiligte: List<String>.from(json['beteiligte'] as List),
      fotoRef: json['fotoRef'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titel': titel,
        'beschreibung': beschreibung,
        'alter': alter,
        'phase': phase.name,
        'emotionaleIntensitaet': emotionaleIntensitaet,
        'typ': typ.name,
        'istKarmaGericht': istKarmaGericht,
        'istMitgenommen': istMitgenommen,
        'beteiligte': beteiligte,
        'fotoRef': fotoRef,
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ErinnerungModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ErinnerungModel(id: $id, titel: "$titel", alter: $alter, '
      'typ: ${typ.name}, intensitaet: $emotionaleIntensitaet, '
      'istMitgenommen: $istMitgenommen)';
}
