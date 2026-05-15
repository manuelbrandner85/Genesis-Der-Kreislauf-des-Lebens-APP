// gedanke_model.dart
// Repräsentiert einen einzelnen Gedanken im Bewusstsein des Charakters.
// Gedanken können aus dem aktuellen Leben stammen oder aus vergangenen
// Inkarnationen geerbt worden sein.

// ─────────────────────────────────────────────────────────────────────────────
// Enum: GedankenTyp – kategorisiert die Art eines Gedankens
// ─────────────────────────────────────────────────────────────────────────────
enum GedankenTyp {
  /// Eine tief verankerte Überzeugung über sich oder die Welt
  ueberzeugung,

  /// Eine konkrete Erinnerung an ein Erlebnis
  erinnerung,

  /// Ein psychisches Trauma aus vergangenen Erfahrungen
  trauma,

  /// Eine gewonnene Weisheit oder Erkenntnis
  weisheit,

  /// Ein Wunsch oder eine Sehnsucht
  wunsch,

  /// Eine irrationale oder begründete Angst
  angst,

  /// Ein durch äußere Einflüsse eingeprägter Gedanke
  indoktrination,

  /// Ein Gedanke, der aus einem früheren Leben übernommen wurde
  geerbterGedanke,
}

// ─────────────────────────────────────────────────────────────────────────────
// GedankeModel
// ─────────────────────────────────────────────────────────────────────────────
// @JsonSerializable() – JSON-Serialisierung ist manuell implementiert
class GedankeModel {
  /// Eindeutige ID dieses Gedankens
  final String id;

  /// Textlicher Inhalt des Gedankens
  final String inhalt;

  /// Kategorisierung des Gedankens (Überzeugung, Trauma, Weisheit usw.)
  final GedankenTyp typ;

  /// Emotionale Stärke des Gedankens (0.0 = kaum spürbar, 1.0 = überwältigend)
  final double intensitaet;

  /// Gibt an, ob der Gedanke abgeschlossen/aufgelöst wurde
  final bool istAbgeschlossen;

  /// Gibt an, ob dieser Gedanke toxisch und schädlich für das Wohlbefinden ist
  final bool istGiftig;

  /// ID des Lebenszyklus, aus dem dieser Gedanke stammt (null = aktuelles Leben)
  final String? herkunftZyklusId;

  /// Zeitpunkt, zu dem der Gedanke entstanden ist
  final DateTime entstanden;

  /// Themen, die diesen Gedanken auslösen können (z.B. 'tod', 'verlust', 'liebe')
  final List<String> ausloesende_themen;

  /// Gibt an, ob dieser Gedanke ins Karma-Gericht mitgenommen wird
  final bool wirdMitgenommen;

  const GedankeModel({
    required this.id,
    required this.inhalt,
    required this.typ,
    required this.intensitaet,
    required this.istAbgeschlossen,
    required this.istGiftig,
    this.herkunftZyklusId,
    required this.entstanden,
    required this.ausloesende_themen,
    required this.wirdMitgenommen,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  GedankeModel copyWith({
    String? id,
    String? inhalt,
    GedankenTyp? typ,
    double? intensitaet,
    bool? istAbgeschlossen,
    bool? istGiftig,
    String? herkunftZyklusId,
    DateTime? entstanden,
    List<String>? ausloesende_themen,
    bool? wirdMitgenommen,
  }) {
    return GedankeModel(
      id: id ?? this.id,
      inhalt: inhalt ?? this.inhalt,
      typ: typ ?? this.typ,
      intensitaet: intensitaet ?? this.intensitaet,
      istAbgeschlossen: istAbgeschlossen ?? this.istAbgeschlossen,
      istGiftig: istGiftig ?? this.istGiftig,
      herkunftZyklusId: herkunftZyklusId ?? this.herkunftZyklusId,
      entstanden: entstanden ?? this.entstanden,
      ausloesende_themen: ausloesende_themen ?? this.ausloesende_themen,
      wirdMitgenommen: wirdMitgenommen ?? this.wirdMitgenommen,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  factory GedankeModel.fromJson(Map<String, dynamic> json) {
    return GedankeModel(
      id: json['id'] as String,
      inhalt: json['inhalt'] as String,
      typ: GedankenTyp.values.byName(json['typ'] as String),
      intensitaet: (json['intensitaet'] as num).toDouble(),
      istAbgeschlossen: json['istAbgeschlossen'] as bool,
      istGiftig: json['istGiftig'] as bool,
      herkunftZyklusId: json['herkunftZyklusId'] as String?,
      entstanden: DateTime.parse(json['entstanden'] as String),
      ausloesende_themen:
          List<String>.from(json['ausloesende_themen'] as List),
      wirdMitgenommen: json['wirdMitgenommen'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'inhalt': inhalt,
        'typ': typ.name,
        'intensitaet': intensitaet,
        'istAbgeschlossen': istAbgeschlossen,
        'istGiftig': istGiftig,
        'herkunftZyklusId': herkunftZyklusId,
        'entstanden': entstanden.toIso8601String(),
        'ausloesende_themen': ausloesende_themen,
        'wirdMitgenommen': wirdMitgenommen,
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GedankeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GedankeModel(id: $id, typ: ${typ.name}, '
      'intensitaet: $intensitaet, istGiftig: $istGiftig, '
      'wirdMitgenommen: $wirdMitgenommen)';
}
