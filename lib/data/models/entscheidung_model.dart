// entscheidung_model.dart
// Repräsentiert eine Entscheidungssituation im Spiel.
// Entscheidungen können Mikro-Entscheidungen (alltäglich) oder große Weichenstellungen
// sein. Mit der Parallelvorschau kann der Spieler mögliche Konsequenzen erahnen –
// aber maximal 5 Mal pro Leben.

import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EntscheidungsOption – eine einzelne Antwortmöglichkeit
// ─────────────────────────────────────────────────────────────────────────────
// @JsonSerializable() – JSON-Serialisierung ist manuell implementiert
class EntscheidungsOption {
  /// Eindeutige ID dieser Option
  final String id;

  /// Anzeigetext der Option, der dem Spieler präsentiert wird
  final String text;

  /// Egoismus-Altruismus-Skala (-1.0 = rein egoistisch, +1.0 = rein altruistisch)
  final double egoistischAltruistisch;

  /// Karma-Auswirkung pro Dimension, die diese Wahl auslöst
  final Map<KarmaDimension, double> karmaAuswirkung;

  /// Konsequenzen, die sofort nach der Entscheidung eintreten
  final List<String> sofortigeKonsequenzen;

  /// Konsequenzen, die erst später im Leben sichtbar werden
  final List<String> verzoegerteKonsequenzen;

  /// Markiert Optionen, die moralisch klingen, aber negative Auswirkungen haben
  final bool klingtMoralischAber;

  const EntscheidungsOption({
    required this.id,
    required this.text,
    required this.egoistischAltruistisch,
    required this.karmaAuswirkung,
    required this.sofortigeKonsequenzen,
    required this.verzoegerteKonsequenzen,
    required this.klingtMoralischAber,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  EntscheidungsOption copyWith({
    String? id,
    String? text,
    double? egoistischAltruistisch,
    Map<KarmaDimension, double>? karmaAuswirkung,
    List<String>? sofortigeKonsequenzen,
    List<String>? verzoegerteKonsequenzen,
    bool? klingtMoralischAber,
  }) {
    return EntscheidungsOption(
      id: id ?? this.id,
      text: text ?? this.text,
      egoistischAltruistisch:
          egoistischAltruistisch ?? this.egoistischAltruistisch,
      karmaAuswirkung: karmaAuswirkung ?? this.karmaAuswirkung,
      sofortigeKonsequenzen:
          sofortigeKonsequenzen ?? this.sofortigeKonsequenzen,
      verzoegerteKonsequenzen:
          verzoegerteKonsequenzen ?? this.verzoegerteKonsequenzen,
      klingtMoralischAber: klingtMoralischAber ?? this.klingtMoralischAber,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  factory EntscheidungsOption.fromJson(Map<String, dynamic> json) {
    // Karma-Auswirkung als Map<KarmaDimension, double> deserialisieren
    final karmaRaw =
        json['karmaAuswirkung'] as Map<String, dynamic>;
    final karmaAuswirkung = karmaRaw.map(
      (key, value) => MapEntry(
        KarmaDimension.values.byName(key),
        (value as num).toDouble(),
      ),
    );

    return EntscheidungsOption(
      id: json['id'] as String,
      text: json['text'] as String,
      egoistischAltruistisch:
          (json['egoistischAltruistisch'] as num).toDouble(),
      karmaAuswirkung: karmaAuswirkung,
      sofortigeKonsequenzen:
          List<String>.from(json['sofortigeKonsequenzen'] as List),
      verzoegerteKonsequenzen:
          List<String>.from(json['verzoegerteKonsequenzen'] as List),
      klingtMoralischAber: json['klingtMoralischAber'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'egoistischAltruistisch': egoistischAltruistisch,
        // KarmaDimension-Enum-Namen als Schlüssel verwenden
        'karmaAuswirkung': karmaAuswirkung
            .map((dim, wert) => MapEntry(dim.name, wert)),
        'sofortigeKonsequenzen': sofortigeKonsequenzen,
        'verzoegerteKonsequenzen': verzoegerteKonsequenzen,
        'klingtMoralischAber': klingtMoralischAber,
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntscheidungsOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'EntscheidungsOption(id: $id, egoistischAltruistisch: '
      '$egoistischAltruistisch, klingtMoralischAber: $klingtMoralischAber)';
}

// ─────────────────────────────────────────────────────────────────────────────
// EntscheidungModel – eine vollständige Entscheidungssituation
// ─────────────────────────────────────────────────────────────────────────────
// @JsonSerializable() – JSON-Serialisierung ist manuell implementiert
class EntscheidungModel {
  /// Eindeutige ID dieser Entscheidung
  final String id;

  /// Die gestellte Frage oder das Dilemma
  final String frage;

  /// Narrativer Kontext zur Entscheidungssituation
  final String kontext;

  /// Alle wählbaren Optionen dieser Entscheidung
  final List<EntscheidungsOption> optionen;

  /// Index der gewählten Option (null = noch keine Wahl getroffen)
  final int? gewaehltOptionIndex;

  /// Gibt an, ob es sich um eine alltägliche Mikro-Entscheidung handelt
  final bool istMikroEntscheidung;

  /// Gibt an, ob die Parallelvorschau für diese Entscheidung genutzt wurde
  /// (max. 5 Mal pro Leben verfügbar)
  final bool hatParallelvorschau;

  /// Einfluss der 14 gesellschaftlichen Systeme auf diese Entscheidungssituation
  /// (Schlüssel: Systemname, Wert: Einfluss 0.0–1.0)
  final Map<String, double> systemEinfluesse;

  const EntscheidungModel({
    required this.id,
    required this.frage,
    required this.kontext,
    required this.optionen,
    this.gewaehltOptionIndex,
    required this.istMikroEntscheidung,
    required this.hatParallelvorschau,
    required this.systemEinfluesse,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Hilfsgetter
  // ───────────────────────────────────────────────────────────────────────────

  /// Gibt die gewählte Option zurück oder null, wenn noch keine Wahl getroffen wurde
  EntscheidungsOption? get gewaehltOption {
    if (gewaehltOptionIndex == null) return null;
    if (gewaehltOptionIndex! < 0 || gewaehltOptionIndex! >= optionen.length) {
      return null;
    }
    return optionen[gewaehltOptionIndex!];
  }

  /// Gibt an, ob diese Entscheidung bereits getroffen wurde
  bool get istGetroffen => gewaehltOptionIndex != null;

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  EntscheidungModel copyWith({
    String? id,
    String? frage,
    String? kontext,
    List<EntscheidungsOption>? optionen,
    int? gewaehltOptionIndex,
    bool? istMikroEntscheidung,
    bool? hatParallelvorschau,
    Map<String, double>? systemEinfluesse,
  }) {
    return EntscheidungModel(
      id: id ?? this.id,
      frage: frage ?? this.frage,
      kontext: kontext ?? this.kontext,
      optionen: optionen ?? this.optionen,
      gewaehltOptionIndex: gewaehltOptionIndex ?? this.gewaehltOptionIndex,
      istMikroEntscheidung: istMikroEntscheidung ?? this.istMikroEntscheidung,
      hatParallelvorschau: hatParallelvorschau ?? this.hatParallelvorschau,
      systemEinfluesse: systemEinfluesse ?? this.systemEinfluesse,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  factory EntscheidungModel.fromJson(Map<String, dynamic> json) {
    return EntscheidungModel(
      id: json['id'] as String,
      frage: json['frage'] as String,
      kontext: json['kontext'] as String,
      optionen: (json['optionen'] as List)
          .map((o) => EntscheidungsOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      gewaehltOptionIndex: json['gewaehltOptionIndex'] as int?,
      istMikroEntscheidung: json['istMikroEntscheidung'] as bool,
      hatParallelvorschau: json['hatParallelvorschau'] as bool,
      systemEinfluesse: Map<String, double>.from(
        (json['systemEinfluesse'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'frage': frage,
        'kontext': kontext,
        'optionen': optionen.map((o) => o.toJson()).toList(),
        'gewaehltOptionIndex': gewaehltOptionIndex,
        'istMikroEntscheidung': istMikroEntscheidung,
        'hatParallelvorschau': hatParallelvorschau,
        'systemEinfluesse': systemEinfluesse,
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntscheidungModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'EntscheidungModel(id: $id, frage: "$frage", '
      'optionen: ${optionen.length}, istGetroffen: $istGetroffen, '
      'istMikro: $istMikroEntscheidung)';
}
