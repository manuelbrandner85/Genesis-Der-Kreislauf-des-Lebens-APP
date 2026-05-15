// beziehung_model.dart
// Repräsentiert eine zwischenmenschliche Beziehung des Charakters.
// Beziehungen können zu echten Mitspielern oder NPCs bestehen und
// entwickeln sich über den gesamten Lebenszyklus.

import 'package:genesis_kreislauf_des_lebens/data/models/erinnerung_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: BeziehungsTyp – die Art der Verbindung zwischen zwei Personen
// ─────────────────────────────────────────────────────────────────────────────
enum BeziehungsTyp {
  /// Mutter oder Vater des Charakters
  elternteil,

  /// Bruder oder Schwester des Charakters
  geschwister,

  /// Enger Freund oder Freundin
  freund,

  /// Romantischer Partner oder Lebenspartner
  partner,

  /// Eigenes Kind des Charakters
  kind,

  /// Beruflicher Kollege
  kollege,

  /// Lehrmeister oder Lebensberater
  mentor,

  /// Konkurrent oder Widersacher mit Respekt
  rivale,

  /// Antagonist mit aktiver Feindschaft
  feind,
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum: BeziehungsQualitaet – zusammenfassende Bewertung einer Beziehung
// ─────────────────────────────────────────────────────────────────────────────
enum BeziehungsQualitaet {
  /// Sehr starke, tiefe Verbindung
  tiefVerbunden,

  /// Gute, stabile Beziehung
  gut,

  /// Durchschnittliche, neutrale Beziehung
  neutral,

  /// Angespannte oder distanzierte Beziehung
  angespannt,

  /// Zerbrochene oder toxische Beziehung
  zerbrochen,
}

// ─────────────────────────────────────────────────────────────────────────────
// BeziehungModel
// ─────────────────────────────────────────────────────────────────────────────
// @JsonSerializable() – JSON-Serialisierung ist manuell implementiert
class BeziehungModel {
  /// Eindeutige ID dieser Beziehung
  final String id;

  /// Name der Person, mit der die Beziehung besteht
  final String personName;

  /// Art der Beziehung (z. B. Freund, Partner, Rivale)
  final BeziehungsTyp typ;

  /// Vertrauensniveau (0.0 = kein Vertrauen, 100.0 = blindes Vertrauen)
  final double vertrauen;

  /// Grad des gegenseitigen Respekts (0.0 = kein Respekt, 100.0 = tiefer Respekt)
  final double respekt;

  /// Stärke der emotionalen Zuneigung (0.0 = keine, 100.0 = bedingungslose Liebe)
  final double liebe;

  /// Grad der emotionalen oder praktischen Abhängigkeit (0.0–100.0)
  final double abhaengigkeit;

  /// Gemeinsame Erinnerungen, die mit dieser Person geteilt wurden
  final List<ErinnerungModel> geteilteErinnerungen;

  /// Gibt an, ob diese Person ein echter Mitspieler (true) oder ein NPC (false) ist
  final bool istEcht;

  /// Seelen-UUID des echten Mitspielers (null bei NPCs)
  final String? teilnehmerId;

  /// Gibt an, ob eine zerbrochene Beziehung wieder geheilt wurde
  final bool istGeheilt;

  /// Liste ungelöster Konflikte in dieser Beziehung
  final List<String> ungeloestKonflikte;

  const BeziehungModel({
    required this.id,
    required this.personName,
    required this.typ,
    required this.vertrauen,
    required this.respekt,
    required this.liebe,
    required this.abhaengigkeit,
    required this.geteilteErinnerungen,
    required this.istEcht,
    this.teilnehmerId,
    required this.istGeheilt,
    required this.ungeloestKonflikte,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Durchschnittliche Beziehungsstärke aus Vertrauen, Respekt, Liebe und Abhängigkeit
  double get beziehungsStaerke =>
      (vertrauen + respekt + liebe + abhaengigkeit) / 4.0;

  /// Qualitative Bewertung der Beziehung auf Basis der Beziehungsstärke
  BeziehungsQualitaet get beziehungsQualitaet {
    final staerke = beziehungsStaerke;
    if (staerke >= 75.0) return BeziehungsQualitaet.tiefVerbunden;
    if (staerke >= 50.0) return BeziehungsQualitaet.gut;
    if (staerke >= 30.0) return BeziehungsQualitaet.neutral;
    if (staerke >= 15.0) return BeziehungsQualitaet.angespannt;
    return BeziehungsQualitaet.zerbrochen;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  BeziehungModel copyWith({
    String? id,
    String? personName,
    BeziehungsTyp? typ,
    double? vertrauen,
    double? respekt,
    double? liebe,
    double? abhaengigkeit,
    List<ErinnerungModel>? geteilteErinnerungen,
    bool? istEcht,
    String? teilnehmerId,
    bool? istGeheilt,
    List<String>? ungeloestKonflikte,
  }) {
    return BeziehungModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      typ: typ ?? this.typ,
      vertrauen: vertrauen ?? this.vertrauen,
      respekt: respekt ?? this.respekt,
      liebe: liebe ?? this.liebe,
      abhaengigkeit: abhaengigkeit ?? this.abhaengigkeit,
      geteilteErinnerungen: geteilteErinnerungen ?? this.geteilteErinnerungen,
      istEcht: istEcht ?? this.istEcht,
      teilnehmerId: teilnehmerId ?? this.teilnehmerId,
      istGeheilt: istGeheilt ?? this.istGeheilt,
      ungeloestKonflikte: ungeloestKonflikte ?? this.ungeloestKonflikte,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  factory BeziehungModel.fromJson(Map<String, dynamic> json) {
    return BeziehungModel(
      id: json['id'] as String,
      personName: json['personName'] as String,
      typ: BeziehungsTyp.values.byName(json['typ'] as String),
      vertrauen: (json['vertrauen'] as num).toDouble(),
      respekt: (json['respekt'] as num).toDouble(),
      liebe: (json['liebe'] as num).toDouble(),
      abhaengigkeit: (json['abhaengigkeit'] as num).toDouble(),
      geteilteErinnerungen: (json['geteilteErinnerungen'] as List)
          .map((e) => ErinnerungModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      istEcht: json['istEcht'] as bool,
      teilnehmerId: json['teilnehmerId'] as String?,
      istGeheilt: json['istGeheilt'] as bool,
      ungeloestKonflikte:
          List<String>.from(json['ungeloestKonflikte'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'personName': personName,
        'typ': typ.name,
        'vertrauen': vertrauen,
        'respekt': respekt,
        'liebe': liebe,
        'abhaengigkeit': abhaengigkeit,
        'geteilteErinnerungen':
            geteilteErinnerungen.map((e) => e.toJson()).toList(),
        'istEcht': istEcht,
        'teilnehmerId': teilnehmerId,
        'istGeheilt': istGeheilt,
        'ungeloestKonflikte': ungeloestKonflikte,
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BeziehungModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BeziehungModel(id: $id, personName: "$personName", '
      'typ: ${typ.name}, staerke: ${beziehungsStaerke.toStringAsFixed(1)}, '
      'qualitaet: ${beziehungsQualitaet.name})';
}
