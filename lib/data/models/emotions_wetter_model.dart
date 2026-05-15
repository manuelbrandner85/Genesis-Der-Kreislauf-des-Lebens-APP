// emotions_wetter_model.dart
// Repräsentiert den emotionalen Wetterzustand des Charakters.
// Das Emotions-Wetter wird durch Glück, Stress, Liebe und Spiritualität
// berechnet und steuert visuelle Shader-Effekte und Partikel im Spiel.

import 'dart:ui' show Color;

// ─────────────────────────────────────────────────────────────────────────────
// Enum: EmotionsWetterTyp – die Art des emotionalen Wetters
// ─────────────────────────────────────────────────────────────────────────────
enum EmotionsWetterTyp {
  /// Helles, freudiges Wetter – Glück und Zufriedenheit
  sonnenschein,

  /// Sanfter Regen – Melancholie oder stille Trauer
  regen,

  /// Heftiges Gewitter – innere Aufruhr, Wut oder Angst
  gewitter,

  /// Warmes, goldenes Leuchten – Liebe und Geborgenheit
  warmesLeuchten,

  /// Kosmisches Glühen – spirituelle Erleuchtung oder Transzendenz
  kosmisch,

  /// Dichter Nebel – Verwirrung, Unklarheit oder Dissoziation
  nebel,

  /// Heftiger Sturm – existenzielle Krise oder überwältigender Stress
  sturm,

  /// Klarer, ruhiger Himmel – innerer Frieden und Klarheit
  klar,
}

// ─────────────────────────────────────────────────────────────────────────────
// EmotionsWetterModel
// ─────────────────────────────────────────────────────────────────────────────
// @JsonSerializable() – JSON-Serialisierung ist manuell implementiert
class EmotionsWetterModel {
  /// Der aktuelle Wettertyp des emotionalen Zustands
  final EmotionsWetterTyp typ;

  /// Intensität des Wettereffekts (0.0 = kaum wahrnehmbar, 1.0 = maximal)
  final double intensitaet;

  /// Hauptfarbe für den Shader-Effekt (als ARGB-Integer gespeichert)
  final Color hauptfarbe;

  /// Nebenfarbe für Verlaufs- oder Akzenteffekte (als ARGB-Integer gespeichert)
  final Color nebenfarbe;

  /// Dichte der Partikeleffekte (0.0 = keine Partikel, 1.0 = maximale Dichte)
  final double partikelDichte;

  /// Stärke des virtuellen Winds für Partikel-Bewegungsrichtung (0.0–1.0)
  final double windStaerke;

  /// Gibt an, ob ein Blitzeffekt aktiv ist (z. B. bei Gewitter oder Sturm)
  final bool blitzEffekt;

  /// Radius des Leuchteffekts für spirituelle Zustände (in logischen Pixeln)
  final double leuchtenRadius;

  const EmotionsWetterModel({
    required this.typ,
    required this.intensitaet,
    required this.hauptfarbe,
    required this.nebenfarbe,
    required this.partikelDichte,
    required this.windStaerke,
    required this.blitzEffekt,
    required this.leuchtenRadius,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Factory: Wetter aus Emotionswerten berechnen
  // ───────────────────────────────────────────────────────────────────────────

  /// Berechnet das passende Emotions-Wetter basierend auf vier emotionalen
  /// Kernwerten. Alle Eingabewerte liegen im Bereich 0.0–1.0.
  ///
  /// - [glueck]: Allgemeines Wohlbefinden und Zufriedenheit
  /// - [stress]: Anspannung, Druck und Überforderung
  /// - [liebe]: Verbundenheit und emotionale Wärme
  /// - [spiritualitaet]: Transzendenz, Sinn und innere Stille
  static EmotionsWetterModel vonEmotion({
    required double glueck,
    required double stress,
    required double liebe,
    required double spiritualitaet,
  }) {
    // Typ bestimmen: dominanter Faktor gewinnt
    EmotionsWetterTyp typ;
    double intensitaet;
    Color hauptfarbe;
    Color nebenfarbe;
    double partikelDichte;
    double windStaerke;
    bool blitzEffekt;
    double leuchtenRadius;

    // Spiritualität dominiert → kosmisches Leuchten
    if (spiritualitaet >= 0.75) {
      typ = EmotionsWetterTyp.kosmisch;
      intensitaet = spiritualitaet;
      hauptfarbe = const Color(0xFF7B68EE); // Mittelschieferblau
      nebenfarbe = const Color(0xFFE0D7FF); // Helles Lavendel
      partikelDichte = 0.6;
      windStaerke = 0.1;
      blitzEffekt = false;
      leuchtenRadius = 120.0 * spiritualitaet;
    }
    // Hoher Stress → Gewitter oder Sturm
    else if (stress >= 0.75) {
      typ = stress >= 0.9
          ? EmotionsWetterTyp.sturm
          : EmotionsWetterTyp.gewitter;
      intensitaet = stress;
      hauptfarbe = const Color(0xFF4A4A6A); // Dunkles Blaugrau
      nebenfarbe = const Color(0xFF8B0000); // Dunkelrot
      partikelDichte = 0.8;
      windStaerke = stress;
      blitzEffekt = stress >= 0.8;
      leuchtenRadius = 0.0;
    }
    // Hohe Liebe + mittleres Glück → warmes Leuchten
    else if (liebe >= 0.6 && glueck >= 0.5) {
      typ = EmotionsWetterTyp.warmesLeuchten;
      intensitaet = (liebe + glueck) / 2.0;
      hauptfarbe = const Color(0xFFFFD700); // Gold
      nebenfarbe = const Color(0xFFFF8C69); // Lachsrosa
      partikelDichte = 0.3;
      windStaerke = 0.05;
      blitzEffekt = false;
      leuchtenRadius = 80.0 * liebe;
    }
    // Hohes Glück → Sonnenschein
    else if (glueck >= 0.65) {
      typ = EmotionsWetterTyp.sonnenschein;
      intensitaet = glueck;
      hauptfarbe = const Color(0xFFFFF176); // Hellgelb
      nebenfarbe = const Color(0xFF87CEEB); // Himmelblau
      partikelDichte = 0.2;
      windStaerke = 0.15;
      blitzEffekt = false;
      leuchtenRadius = 40.0;
    }
    // Niedriges Glück + hoher Stress → Regen
    else if (glueck <= 0.35 && stress >= 0.4) {
      typ = EmotionsWetterTyp.regen;
      intensitaet = (stress + (1.0 - glueck)) / 2.0;
      hauptfarbe = const Color(0xFF607D8B); // Blaugrau
      nebenfarbe = const Color(0xFF90A4AE); // Helles Blaugrau
      partikelDichte = 0.7;
      windStaerke = 0.3;
      blitzEffekt = false;
      leuchtenRadius = 0.0;
    }
    // Niedriges Glück, geringer Stress → Nebel
    else if (glueck <= 0.3) {
      typ = EmotionsWetterTyp.nebel;
      intensitaet = 1.0 - glueck;
      hauptfarbe = const Color(0xFFB0BEC5); // Silbergrau
      nebenfarbe = const Color(0xFFECEFF1); // Fast weiß
      partikelDichte = 0.5;
      windStaerke = 0.05;
      blitzEffekt = false;
      leuchtenRadius = 0.0;
    }
    // Ausgeglichener, ruhiger Zustand → klar
    else {
      typ = EmotionsWetterTyp.klar;
      intensitaet = glueck;
      hauptfarbe = const Color(0xFF81D4FA); // Helles Blau
      nebenfarbe = const Color(0xFFE1F5FE); // Sehr helles Blau
      partikelDichte = 0.1;
      windStaerke = 0.1;
      blitzEffekt = false;
      leuchtenRadius = 20.0 * spiritualitaet;
    }

    return EmotionsWetterModel(
      typ: typ,
      intensitaet: intensitaet.clamp(0.0, 1.0),
      hauptfarbe: hauptfarbe,
      nebenfarbe: nebenfarbe,
      partikelDichte: partikelDichte.clamp(0.0, 1.0),
      windStaerke: windStaerke.clamp(0.0, 1.0),
      blitzEffekt: blitzEffekt,
      leuchtenRadius: leuchtenRadius,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  EmotionsWetterModel copyWith({
    EmotionsWetterTyp? typ,
    double? intensitaet,
    Color? hauptfarbe,
    Color? nebenfarbe,
    double? partikelDichte,
    double? windStaerke,
    bool? blitzEffekt,
    double? leuchtenRadius,
  }) {
    return EmotionsWetterModel(
      typ: typ ?? this.typ,
      intensitaet: intensitaet ?? this.intensitaet,
      hauptfarbe: hauptfarbe ?? this.hauptfarbe,
      nebenfarbe: nebenfarbe ?? this.nebenfarbe,
      partikelDichte: partikelDichte ?? this.partikelDichte,
      windStaerke: windStaerke ?? this.windStaerke,
      blitzEffekt: blitzEffekt ?? this.blitzEffekt,
      leuchtenRadius: leuchtenRadius ?? this.leuchtenRadius,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // Color wird als ARGB-Integer (int) serialisiert
  // ───────────────────────────────────────────────────────────────────────────

  factory EmotionsWetterModel.fromJson(Map<String, dynamic> json) {
    return EmotionsWetterModel(
      typ: EmotionsWetterTyp.values.byName(json['typ'] as String),
      intensitaet: (json['intensitaet'] as num).toDouble(),
      hauptfarbe: Color(json['hauptfarbe'] as int),
      nebenfarbe: Color(json['nebenfarbe'] as int),
      partikelDichte: (json['partikelDichte'] as num).toDouble(),
      windStaerke: (json['windStaerke'] as num).toDouble(),
      blitzEffekt: json['blitzEffekt'] as bool,
      leuchtenRadius: (json['leuchtenRadius'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'typ': typ.name,
        'intensitaet': intensitaet,
        // Color als ARGB-Integer serialisieren (dart:ui Color.value)
        'hauptfarbe': hauptfarbe.value,
        'nebenfarbe': nebenfarbe.value,
        'partikelDichte': partikelDichte,
        'windStaerke': windStaerke,
        'blitzEffekt': blitzEffekt,
        'leuchtenRadius': leuchtenRadius,
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmotionsWetterModel &&
        other.typ == typ &&
        other.intensitaet == intensitaet &&
        other.hauptfarbe == hauptfarbe &&
        other.nebenfarbe == nebenfarbe;
  }

  @override
  int get hashCode => Object.hash(typ, intensitaet, hauptfarbe, nebenfarbe);

  @override
  String toString() =>
      'EmotionsWetterModel(typ: ${typ.name}, intensitaet: '
      '${intensitaet.toStringAsFixed(2)}, blitzEffekt: $blitzEffekt, '
      'leuchtenRadius: $leuchtenRadius)';
}
