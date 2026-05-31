// ahnenreihe_model.dart
// Repräsentiert die Ahnenreihe einer Seele über mehrere Zyklen.
// Ahnen können beobachtet aber nicht gespielt werden – sie sind Fundament.

import 'package:uuid/uuid.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AhnenEintrag – ein einzelner Vorfahre in der Seelenlinie
// ─────────────────────────────────────────────────────────────────────────────

/// Beschreibt einen Vorfahren aus einem früheren Lebenszyklus.
/// Ahnen können nur beobachtet werden – die Finalität jedes Lebens bleibt gewahrt.
class AhnenEintrag {
  /// Eindeutige ID dieses Ahnen-Eintrags
  final String id;

  /// Name des Vorfahren in diesem Leben
  final String name;

  /// Das Zeitalter, in dem dieser Vorfahr lebte
  final Zeitalter zeitalter;

  /// Karma-Profil am Ende des Lebens (Snapshot)
  final KarmaProfilModel karmaSnapshot;

  /// Das Jenseitsreich, das dieser Vorfahr erreichte
  final JenseitsReich jenseitsReich;

  /// Wie lange dieser Vorfahr lebte (Sterbealter)
  final int sterbealter;

  /// Besondere Errungenschaften oder Ereignisse dieses Lebens
  final List<String> schluessel_ereignisse;

  /// Letzte Worte – können von Nachkommen gelesen werden
  final String? letzteWorte;

  /// Epigenetische Auswirkungen auf nachfolgende Generationen
  final Map<String, double> epigenetischeVererbung;

  /// Zyklus-Nummer, in dem dieser Vorfahr lebte
  final int zyklusNummer;

  const AhnenEintrag({
    required this.id,
    required this.name,
    required this.zeitalter,
    required this.karmaSnapshot,
    required this.jenseitsReich,
    required this.sterbealter,
    required this.schluessel_ereignisse,
    this.letzteWorte,
    required this.epigenetischeVererbung,
    required this.zyklusNummer,
  });

  factory AhnenEintrag.erstellen({
    required String name,
    required Zeitalter zeitalter,
    required KarmaProfilModel karmaSnapshot,
    required JenseitsReich jenseitsReich,
    required int sterbealter,
    required int zyklusNummer,
    List<String> schluessel_ereignisse = const [],
    String? letzteWorte,
    Map<String, double> epigenetischeVererbung = const {},
  }) {
    return AhnenEintrag(
      id: const Uuid().v4(),
      name: name,
      zeitalter: zeitalter,
      karmaSnapshot: karmaSnapshot,
      jenseitsReich: jenseitsReich,
      sterbealter: sterbealter,
      schluessel_ereignisse: schluessel_ereignisse,
      letzteWorte: letzteWorte,
      epigenetischeVererbung: epigenetischeVererbung,
      zyklusNummer: zyklusNummer,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Ob dieser Vorfahr ein hohes Karma-Profil hatte (Elysium/Harmonia)
  bool get warTugendreich =>
      jenseitsReich == JenseitsReich.elysium ||
      jenseitsReich == JenseitsReich.harmonia;

  /// Ob dieser Vorfahr ein eher dunkles Karma-Profil hatte
  bool get warDunkel =>
      jenseitsReich == JenseitsReich.shadowlands ||
      jenseitsReich == JenseitsReich.abyssus;

  /// Durchschnittliches Karma dieses Vorfahren
  double get karmaScore => karmaSnapshot.durchschnitt;

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'zeitalter': zeitalter.name,
        'karmaSnapshot': karmaSnapshot.toJson(),
        'jenseitsReich': jenseitsReich.name,
        'sterbealter': sterbealter,
        'schluessel_ereignisse': schluessel_ereignisse,
        'letzteWorte': letzteWorte,
        'epigenetischeVererbung': epigenetischeVererbung,
        'zyklusNummer': zyklusNummer,
      };

  factory AhnenEintrag.fromJson(Map<String, dynamic> json) {
    return AhnenEintrag(
      id: json['id'] as String,
      name: json['name'] as String,
      zeitalter: Zeitalter.values.firstWhere(
        (z) => z.name == json['zeitalter'],
        orElse: () => Zeitalter.moderne,
      ),
      karmaSnapshot: KarmaProfilModel.fromJson(
        Map<String, dynamic>.from(json['karmaSnapshot'] as Map),
      ),
      jenseitsReich: JenseitsReich.values.firstWhere(
        (r) => r.name == json['jenseitsReich'],
        orElse: () => JenseitsReich.limbus,
      ),
      sterbealter: json['sterbealter'] as int,
      schluessel_ereignisse:
          List<String>.from(json['schluessel_ereignisse'] as List),
      letzteWorte: json['letzteWorte'] as String?,
      epigenetischeVererbung: Map<String, double>.from(
        (json['epigenetischeVererbung'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      zyklusNummer: json['zyklusNummer'] as int,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AhnenreiheModel – der vollständige Stammbaum der Seele
// ─────────────────────────────────────────────────────────────────────────────

/// Der Stammbaum aller Vorfahren einer Seele über alle Zyklen hinweg.
///
/// Ahnen können nur beobachtet und analysiert werden.
/// Das Spielen eigener Vorfahren ist nicht möglich (Finalitätsprinzip).
class AhnenreiheModel {
  /// Alle registrierten Ahnen, chronologisch (älteste zuerst)
  final List<AhnenEintrag> ahnen;

  /// ID der Spieler-Seele, zu der diese Ahnenreihe gehört
  final String seelencodeId;

  const AhnenreiheModel({
    required this.ahnen,
    required this.seelencodeId,
  });

  factory AhnenreiheModel.leer(String seelencodeId) => AhnenreiheModel(
        ahnen: const [],
        seelencodeId: seelencodeId,
      );

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Gesamtanzahl der Vorfahren
  int get anzahlAhnen => ahnen.length;

  /// Ob die Ahnenreihe freigeschaltet ist (ab 3 abgeschlossenen Zyklen)
  bool get istFreigeschaltet => anzahlAhnen >= 3;

  /// Der gesamte epigenetische Einfluss aller Ahnen kumuliert
  Map<String, double> get kumulierteEpigenetik {
    final kumuliert = <String, double>{};
    for (final ahn in ahnen) {
      for (final entry in ahn.epigenetischeVererbung.entries) {
        kumuliert[entry.key] =
            (kumuliert[entry.key] ?? 0.0) + entry.value;
      }
    }
    return kumuliert;
  }

  /// Durchschnittliches Karma aller Vorfahren
  double get durchschnittlichesAhnenKarma {
    if (ahnen.isEmpty) return 0.0;
    return ahnen.map((a) => a.karmaScore).reduce((a, b) => a + b) /
        ahnen.length;
  }

  /// Die Verteilung der Jenseitsreiche in der Ahnenreihe
  Map<JenseitsReich, int> get reichVerteilung {
    final verteilung = <JenseitsReich, int>{};
    for (final ahn in ahnen) {
      verteilung[ahn.jenseitsReich] =
          (verteilung[ahn.jenseitsReich] ?? 0) + 1;
    }
    return verteilung;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Mutationsmethoden (return neue Instanz)
  // ───────────────────────────────────────────────────────────────────────────

  /// Fügt einen neuen Ahnen-Eintrag hinzu.
  AhnenreiheModel mitNeuemAhnen(AhnenEintrag neuerAhn) => AhnenreiheModel(
        ahnen: [...ahnen, neuerAhn],
        seelencodeId: seelencodeId,
      );

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'ahnen': ahnen.map((a) => a.toJson()).toList(),
        'seelencodeId': seelencodeId,
      };

  factory AhnenreiheModel.fromJson(Map<String, dynamic> json) {
    return AhnenreiheModel(
      ahnen: (json['ahnen'] as List)
          .map((e) => AhnenEintrag.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      seelencodeId: json['seelencodeId'] as String,
    );
  }
}
