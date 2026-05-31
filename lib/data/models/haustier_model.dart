// haustier_model.dart
// Modelliert Haustiere – Begleiter, die das Emotions-Wetter positiv beeinflussen
// und im Jenseits warten.

import 'package:uuid/uuid.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: HaustierArt
// ─────────────────────────────────────────────────────────────────────────────

/// Die verschiedenen Arten von Haustieren je nach Zeitalter
enum HaustierArt {
  /// Hund – treuer Begleiter durch alle Zeitalter
  hund,

  /// Katze – unabhängig, aber verbunden
  katze,

  /// Pferd – Zeitalter-abhängig: Mittelalter bis Moderne
  pferd,

  /// Exotisch – Papagei, Schlange, etc.
  exotisch,
}

// ─────────────────────────────────────────────────────────────────────────────
// HaustierModel – ein einzelnes Haustier
// ─────────────────────────────────────────────────────────────────────────────

/// Ein Haustier als emotionaler Begleiter des Charakters.
/// Haustiere warten im Jenseits und erscheinen als Flashback-Erinnerungen.
class HaustierModel {
  /// Eindeutige ID
  final String id;

  /// Name des Haustieres
  final String name;

  /// Art des Haustieres
  final HaustierArt art;

  /// Wie gut es dem Haustier geht (0.0 = krank, 1.0 = optimal)
  final double gesundheit;

  /// Emotionale Bindung zum Charakter (0.0–1.0)
  final double bindung;

  /// In welchem Zeitalter das Haustier gelebt hat
  final Zeitalter zeitalter;

  /// Ob das Haustier noch lebt
  final bool istLebendig;

  /// Persönlichkeitseigenschaft (z.B. "verspielt", "ruhig", "mutig")
  final String persoenlichkeit;

  const HaustierModel({
    required this.id,
    required this.name,
    required this.art,
    required this.gesundheit,
    required this.bindung,
    required this.zeitalter,
    required this.istLebendig,
    required this.persoenlichkeit,
  });

  factory HaustierModel.erstellen({
    required String name,
    required HaustierArt art,
    required Zeitalter zeitalter,
    String persoenlichkeit = 'verspielt',
  }) {
    return HaustierModel(
      id: const Uuid().v4(),
      name: name,
      art: art,
      gesundheit: 1.0,
      bindung: 0.3,
      zeitalter: zeitalter,
      istLebendig: true,
      persoenlichkeit: persoenlichkeit,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Bonus auf das Emotions-Wetter (Glück/Liebe)
  double get emotionsBonus => bindung * 0.15 * (istLebendig ? 1.0 : 0.3);

  /// Ob das Haustier im Jenseits wartend dargestellt wird
  bool get wartetImJenseits => !istLebendig && bindung > 0.5;

  // ───────────────────────────────────────────────────────────────────────────
  // Mutationsmethoden
  // ───────────────────────────────────────────────────────────────────────────

  HaustierModel copyWith({
    double? gesundheit,
    double? bindung,
    bool? istLebendig,
  }) {
    return HaustierModel(
      id: id,
      name: name,
      art: art,
      gesundheit: (gesundheit ?? this.gesundheit).clamp(0.0, 1.0),
      bindung: (bindung ?? this.bindung).clamp(0.0, 1.0),
      zeitalter: zeitalter,
      istLebendig: istLebendig ?? this.istLebendig,
      persoenlichkeit: persoenlichkeit,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'art': art.name,
        'gesundheit': gesundheit,
        'bindung': bindung,
        'zeitalter': zeitalter.name,
        'istLebendig': istLebendig,
        'persoenlichkeit': persoenlichkeit,
      };

  factory HaustierModel.fromJson(Map<String, dynamic> json) {
    return HaustierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      art: HaustierArt.values.firstWhere(
        (a) => a.name == json['art'],
        orElse: () => HaustierArt.hund,
      ),
      gesundheit: (json['gesundheit'] as num).toDouble(),
      bindung: (json['bindung'] as num).toDouble(),
      zeitalter: Zeitalter.values.firstWhere(
        (z) => z.name == json['zeitalter'],
        orElse: () => Zeitalter.moderne,
      ),
      istLebendig: json['istLebendig'] as bool,
      persoenlichkeit: json['persoenlichkeit'] as String,
    );
  }
}
