// karma_profil_model.dart
// Repräsentiert das 6-dimensionale Karma-Profil eines Charakters.
// Jede Dimension reicht von -100 (negativ) bis +100 (positiv).

import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: KarmaDimension – die sechs Karma-Achsen des Spiels
// ─────────────────────────────────────────────────────────────────────────────
enum KarmaDimension {
  mitgefuehl,   // Mitgefühl (+) vs. Grausamkeit (-)
  ehrlichkeit,  // Ehrlichkeit (+) vs. Täuschung (-)
  mut,          // Mut (+) vs. Feigheit (-)
  grosszuegigkeit, // Großzügigkeit (+) vs. Gier (-)
  weisheit,     // Weisheit (+) vs. Ignoranz (-)
  liebe,        // Liebe (+) vs. Gleichgültigkeit (-)
}

// ─────────────────────────────────────────────────────────────────────────────
// KarmaProfilModel – unveränderliche Klasse mit manueller copyWith-Implementierung
// ─────────────────────────────────────────────────────────────────────────────
// @JsonSerializable() – JSON-Serialisierung ist manuell implementiert
class KarmaProfilModel {
  /// Mitgefühl/Grausamkeit-Achse (-100 bis +100)
  final double mitgefuehl;

  /// Ehrlichkeit/Täuschung-Achse (-100 bis +100)
  final double ehrlichkeit;

  /// Mut/Feigheit-Achse (-100 bis +100)
  final double mut;

  /// Großzügigkeit/Gier-Achse (-100 bis +100)
  final double grosszuegigkeit;

  /// Weisheit/Ignoranz-Achse (-100 bis +100)
  final double weisheit;

  /// Liebe/Gleichgültigkeit-Achse (-100 bis +100)
  final double liebe;

  const KarmaProfilModel({
    required this.mitgefuehl,
    required this.ehrlichkeit,
    required this.mut,
    required this.grosszuegigkeit,
    required this.weisheit,
    required this.liebe,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Durchschnittswert aller sechs Karma-Dimensionen
  double get durchschnitt =>
      (mitgefuehl + ehrlichkeit + mut + grosszuegigkeit + weisheit + liebe) /
      6.0;

  /// Die Karma-Dimension mit dem höchsten absoluten Wert
  KarmaDimension get dominanteDimension {
    final werte = {
      KarmaDimension.mitgefuehl: mitgefuehl.abs(),
      KarmaDimension.ehrlichkeit: ehrlichkeit.abs(),
      KarmaDimension.mut: mut.abs(),
      KarmaDimension.grosszuegigkeit: grosszuegigkeit.abs(),
      KarmaDimension.weisheit: weisheit.abs(),
      KarmaDimension.liebe: liebe.abs(),
    };
    return werte.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// Das Jenseitsreich, das auf Basis des Karma-Profils berechnet wird
  JenseitsReich get jenseitsReich => jenseitsReichBerechnen();

  // ───────────────────────────────────────────────────────────────────────────
  // Neutrales Profil – alle Dimensionen auf 0.0
  // ───────────────────────────────────────────────────────────────────────────

  /// Erstellt ein neutrales Karma-Profil mit allen Werten auf 0.0
  static KarmaProfilModel neutral() => const KarmaProfilModel(
        mitgefuehl: 0.0,
        ehrlichkeit: 0.0,
        mut: 0.0,
        grosszuegigkeit: 0.0,
        weisheit: 0.0,
        liebe: 0.0,
      );

  // ───────────────────────────────────────────────────────────────────────────
  // Methoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Aktualisiert eine einzelne Karma-Dimension und gibt eine neue Instanz zurück.
  /// Der Wert wird auf den Bereich [-100, +100] begrenzt.
  KarmaProfilModel dimensionAktualisieren(
      KarmaDimension dim, double wert) {
    // Wert auf den gültigen Bereich begrenzen
    final begrenzt = wert.clamp(-100.0, 100.0);
    return copyWith(
      mitgefuehl: dim == KarmaDimension.mitgefuehl ? begrenzt : mitgefuehl,
      ehrlichkeit:
          dim == KarmaDimension.ehrlichkeit ? begrenzt : ehrlichkeit,
      mut: dim == KarmaDimension.mut ? begrenzt : mut,
      grosszuegigkeit:
          dim == KarmaDimension.grosszuegigkeit ? begrenzt : grosszuegigkeit,
      weisheit: dim == KarmaDimension.weisheit ? begrenzt : weisheit,
      liebe: dim == KarmaDimension.liebe ? begrenzt : liebe,
    );
  }

  /// Berechnet das Jenseitsreich anhand des Gesamt-Karma-Durchschnitts
  /// und der dominanten Dimension.
  JenseitsReich jenseitsReichBerechnen() {
    final avg = durchschnitt;

    // Elysium: Sehr hohes positives Karma über alle Dimensionen
    if (avg >= 60.0) return JenseitsReich.elysium;

    // Harmonia: Positives Karma, ausgeglichen
    if (avg >= 20.0) return JenseitsReich.harmonia;

    // Abyssus: Stark negatives Karma
    if (avg <= -60.0) return JenseitsReich.abyssus;

    // Shadowlands: Negatives Karma
    if (avg <= -20.0) return JenseitsReich.shadowlands;

    // Limbus: Ausgeglichenes oder neutrales Karma
    return JenseitsReich.limbus;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  KarmaProfilModel copyWith({
    double? mitgefuehl,
    double? ehrlichkeit,
    double? mut,
    double? grosszuegigkeit,
    double? weisheit,
    double? liebe,
  }) {
    return KarmaProfilModel(
      mitgefuehl: mitgefuehl ?? this.mitgefuehl,
      ehrlichkeit: ehrlichkeit ?? this.ehrlichkeit,
      mut: mut ?? this.mut,
      grosszuegigkeit: grosszuegigkeit ?? this.grosszuegigkeit,
      weisheit: weisheit ?? this.weisheit,
      liebe: liebe ?? this.liebe,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  factory KarmaProfilModel.fromJson(Map<String, dynamic> json) {
    return KarmaProfilModel(
      mitgefuehl: (json['mitgefuehl'] as num).toDouble(),
      ehrlichkeit: (json['ehrlichkeit'] as num).toDouble(),
      mut: (json['mut'] as num).toDouble(),
      grosszuegigkeit: (json['grosszuegigkeit'] as num).toDouble(),
      weisheit: (json['weisheit'] as num).toDouble(),
      liebe: (json['liebe'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'mitgefuehl': mitgefuehl,
        'ehrlichkeit': ehrlichkeit,
        'mut': mut,
        'grosszuegigkeit': grosszuegigkeit,
        'weisheit': weisheit,
        'liebe': liebe,
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KarmaProfilModel &&
        other.mitgefuehl == mitgefuehl &&
        other.ehrlichkeit == ehrlichkeit &&
        other.mut == mut &&
        other.grosszuegigkeit == grosszuegigkeit &&
        other.weisheit == weisheit &&
        other.liebe == liebe;
  }

  @override
  int get hashCode => Object.hash(
        mitgefuehl,
        ehrlichkeit,
        mut,
        grosszuegigkeit,
        weisheit,
        liebe,
      );

  @override
  String toString() =>
      'KarmaProfilModel(mitgefuehl: $mitgefuehl, ehrlichkeit: $ehrlichkeit, '
      'mut: $mut, grosszuegigkeit: $grosszuegigkeit, weisheit: $weisheit, '
      'liebe: $liebe, durchschnitt: ${durchschnitt.toStringAsFixed(1)})';
}
