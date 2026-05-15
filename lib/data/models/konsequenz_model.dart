// konsequenz_model.dart
// Repräsentiert eine Konsequenz einer getroffenen Entscheidung.
// Konsequenzen können sofort eintreten, verzögert auftreten oder
// sogar generationell weitergegeben werden.

// ─────────────────────────────────────────────────────────────────────────────
// Enum: KonsequenzTyp – der zeitliche Charakter einer Konsequenz
// ─────────────────────────────────────────────────────────────────────────────
enum KonsequenzTyp {
  /// Tritt unmittelbar nach der Entscheidung ein
  sofort,

  /// Tritt erst nach einer bestimmten Zeitspanne ein
  verzoegert,

  /// Wirkt sich auf nachfolgende Generationen oder Zyklen aus
  generationell,
}

// ─────────────────────────────────────────────────────────────────────────────
// KonsequenzModel
// ─────────────────────────────────────────────────────────────────────────────
// @JsonSerializable() – JSON-Serialisierung ist manuell implementiert
class KonsequenzModel {
  /// Eindeutige ID dieser Konsequenz
  final String id;

  /// ID der Entscheidung, aus der diese Konsequenz resultiert
  final String quelleEntscheidungId;

  /// Beschreibung der Konsequenz für den Spieler
  final String beschreibung;

  /// Zeitlicher Charakter der Konsequenz (sofort, verzögert, generationell)
  final KonsequenzTyp typ;

  /// Verzögerung in Jahren bis zum Eintreten (0 = sofort)
  final int verzoegerungInJahren;

  /// Verzögerung in Spielphasen bis zum Eintreten (null = keine Phasenverzögerung)
  final int? verzoegerungInPhasen;

  /// Gibt an, ob diese Konsequenz bereits eingetreten ist
  final bool istEingetreten;

  /// Auswirkungen auf Charakter-Attribute (Schlüssel: Attributname, Wert: Delta)
  final Map<String, double> attributAuswirkungen;

  /// Liste der IDs von Beziehungen, die von dieser Konsequenz betroffen sind
  final List<String> betroffeneBeziehungen;

  const KonsequenzModel({
    required this.id,
    required this.quelleEntscheidungId,
    required this.beschreibung,
    required this.typ,
    required this.verzoegerungInJahren,
    this.verzoegerungInPhasen,
    required this.istEingetreten,
    required this.attributAuswirkungen,
    required this.betroffeneBeziehungen,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  KonsequenzModel copyWith({
    String? id,
    String? quelleEntscheidungId,
    String? beschreibung,
    KonsequenzTyp? typ,
    int? verzoegerungInJahren,
    int? verzoegerungInPhasen,
    bool? istEingetreten,
    Map<String, double>? attributAuswirkungen,
    List<String>? betroffeneBeziehungen,
  }) {
    return KonsequenzModel(
      id: id ?? this.id,
      quelleEntscheidungId:
          quelleEntscheidungId ?? this.quelleEntscheidungId,
      beschreibung: beschreibung ?? this.beschreibung,
      typ: typ ?? this.typ,
      verzoegerungInJahren:
          verzoegerungInJahren ?? this.verzoegerungInJahren,
      verzoegerungInPhasen:
          verzoegerungInPhasen ?? this.verzoegerungInPhasen,
      istEingetreten: istEingetreten ?? this.istEingetreten,
      attributAuswirkungen:
          attributAuswirkungen ?? this.attributAuswirkungen,
      betroffeneBeziehungen:
          betroffeneBeziehungen ?? this.betroffeneBeziehungen,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  factory KonsequenzModel.fromJson(Map<String, dynamic> json) {
    return KonsequenzModel(
      id: json['id'] as String,
      quelleEntscheidungId: json['quelleEntscheidungId'] as String,
      beschreibung: json['beschreibung'] as String,
      typ: KonsequenzTyp.values.byName(json['typ'] as String),
      verzoegerungInJahren: json['verzoegerungInJahren'] as int,
      verzoegerungInPhasen: json['verzoegerungInPhasen'] as int?,
      istEingetreten: json['istEingetreten'] as bool,
      attributAuswirkungen: Map<String, double>.from(
        (json['attributAuswirkungen'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      betroffeneBeziehungen:
          List<String>.from(json['betroffeneBeziehungen'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quelleEntscheidungId': quelleEntscheidungId,
        'beschreibung': beschreibung,
        'typ': typ.name,
        'verzoegerungInJahren': verzoegerungInJahren,
        'verzoegerungInPhasen': verzoegerungInPhasen,
        'istEingetreten': istEingetreten,
        'attributAuswirkungen': attributAuswirkungen,
        'betroffeneBeziehungen': betroffeneBeziehungen,
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KonsequenzModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'KonsequenzModel(id: $id, typ: ${typ.name}, '
      'verzoegerungInJahren: $verzoegerungInJahren, '
      'istEingetreten: $istEingetreten)';
}
