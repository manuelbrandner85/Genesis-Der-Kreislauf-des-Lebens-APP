// zyklus_model.dart
// Repräsentiert einen vollständigen Lebenszyklus (Inkarnation) des Spielers.
// Ein Zyklus umfasst alle Ereignisse, Entscheidungen und Beziehungen eines
// einzelnen Lebens – vom Zeitalter bis zum Sterbealter.

import 'package:uuid/uuid.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/genetischer_code_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/beziehung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/entscheidung_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: JenseitsReich – das Jenseits, das das Karma-Profil bestimmt
// ─────────────────────────────────────────────────────────────────────────────
enum JenseitsReich {
  /// Höchstes Jenseitsreich – für Seelen mit sehr hohem positivem Karma
  elysium,

  /// Harmonisches Jenseitsreich – für ausgeglichen positive Seelen
  harmonia,

  /// Neutrales Zwischenreich – für unentschiedene Seelen
  limbus,

  /// Düsteres Schattenreich – für überwiegend negative Seelen
  shadowlands,

  /// Tiefstes Jenseitsreich – für Seelen mit stark negativem Karma
  abyssus,
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum: Zeitalter – das historische Zeitalter eines Lebenszyklus
// ─────────────────────────────────────────────────────────────────────────────
enum Zeitalter {
  /// Das Mittelalter – geprägt von Feudalismus, Religion und ritterlichen Werten
  mittelalter,

  /// Die Renaissance – Aufblühen von Kunst, Wissenschaft und Humanismus
  renaissance,

  /// Das Industriezeitalter – Dampfmaschinen, Klassengesellschaft, Arbeiterbewegung
  industriezeitalter,

  /// Die Moderne – Technologie, Globalisierung, individuelle Freiheit
  moderne,

  /// Die Zukunft – Post-Humanismus, KI, interstellare Zivilisation
  zukunft,
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum: TodesArt – wie das Leben endet
// ─────────────────────────────────────────────────────────────────────────────
enum TodesArt {
  /// Ein friedlicher Tod im Alter
  natuerlich,

  /// Tod durch eine schwere Krankheit
  krankheit,

  /// Tod durch einen unvorhergesehenen Unfall
  unfall,

  /// Tod durch eine bewusste Aufopferung für andere
  heldentod,

  /// Sanftes Einschlafen – ruhiger, friedlicher Tod
  schlaf,

  /// Sonstiger, nicht kategorisierter Todesumstand
  sonstiges,
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum: SozialeKlasse – gesellschaftliche Ausgangslage bei der Geburt
// ─────────────────────────────────────────────────────────────────────────────
enum SozialeKlasse {
  /// Armut, eingeschränkte Möglichkeiten, harter Überlebenskampf
  unterschicht,

  /// Stabile Verhältnisse mit moderaten Chancen
  mittelschicht,

  /// Reichtum, Privilegien und gesellschaftlicher Einfluss
  oberschicht,
}

// ─────────────────────────────────────────────────────────────────────────────
// ZyklusModel – ein kompletter Lebenszyklus
// ─────────────────────────────────────────────────────────────────────────────
// @JsonSerializable() – JSON-Serialisierung ist manuell implementiert
class ZyklusModel {
  /// Eindeutige ID dieses Lebenszyklus
  final String id;

  /// Laufende Nummer dieses Zyklus (1 = erstes Leben, 2 = zweites Leben, ...)
  final int zyklusNummer;

  /// ID des Spielerprofils, zu dem dieser Zyklus gehört
  final String spielerProfilId;

  /// Historisches Zeitalter dieses Lebens
  final Zeitalter zeitalter;

  /// Soziale Klasse, in die der Charakter hineingeboren wurde
  final SozialeKlasse startKlasse;

  /// Genetischer Code des Charakters in diesem Zyklus
  final GenetischerCodeModel genetischerCode;

  /// Das kumulative Karma-Profil am Ende dieses Zyklus
  final KarmaProfilModel karmaAmEnde;

  /// IDs aller Erinnerungen, die in diesem Zyklus gesammelt wurden
  final List<String> erinnerungsIds;

  /// IDs aller Gedanken, die in diesem Zyklus entstanden sind
  final List<String> gedankenIds;

  /// Alle Beziehungen, die in diesem Zyklus gepflegt wurden
  final List<BeziehungModel> beziehungen;

  /// Alle Entscheidungen, die in diesem Zyklus getroffen wurden
  final List<EntscheidungModel> getroffeneEntscheidungen;

  /// Alter, in dem der Charakter in diesem Zyklus gestorben ist
  final int sterbealter;

  /// Art des Todes
  final TodesArt todesArt;

  /// Die letzten Worte des Charakters (null = keine aufgezeichnet)
  final String? letzteWorte;

  /// Ein hinterlassener Brief für die Nachwelt (null = nicht geschrieben)
  final String? vermaechtnisBrief;

  /// Die aktuelle Spielphase in diesem Zyklus
  final GamePhase aktuellePhase;

  /// Gibt an, ob dieser Zyklus vollständig abgeschlossen ist
  final bool abgeschlossen;

  /// Gedanken, die aus dem Karma-Gericht ins nächste Leben mitgenommen werden
  final List<GedankeModel> mitgenommeneGedanken;

  const ZyklusModel({
    required this.id,
    required this.zyklusNummer,
    required this.spielerProfilId,
    required this.zeitalter,
    required this.startKlasse,
    required this.genetischerCode,
    required this.karmaAmEnde,
    required this.erinnerungsIds,
    required this.gedankenIds,
    required this.beziehungen,
    required this.getroffeneEntscheidungen,
    required this.sterbealter,
    required this.todesArt,
    this.letzteWorte,
    this.vermaechtnisBrief,
    required this.aktuellePhase,
    required this.abgeschlossen,
    required this.mitgenommeneGedanken,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Factory: Neuen Zyklus starten
  // ───────────────────────────────────────────────────────────────────────────

  /// Erstellt einen neuen, frisch gestarteten Lebenszyklus.
  /// Der genetische Code wird automatisch neu generiert.
  static ZyklusModel starten({
    required String profilId,
    required Zeitalter zeitalter,
    required int zyklusNummer,
    SozialeKlasse? startKlasse,
  }) {
    const uuid = Uuid();

    // Soziale Klasse zufällig bestimmen, falls nicht vorgegeben
    final klasse = startKlasse ?? _zufaelligeSozialeKlasse();

    return ZyklusModel(
      id: uuid.v4(),
      zyklusNummer: zyklusNummer,
      spielerProfilId: profilId,
      zeitalter: zeitalter,
      startKlasse: klasse,
      genetischerCode: GenetischerCodeModel.generieren(),
      karmaAmEnde: KarmaProfilModel.neutral(),
      erinnerungsIds: const [],
      gedankenIds: const [],
      beziehungen: const [],
      getroffeneEntscheidungen: const [],
      sterbealter: 0,
      todesArt: TodesArt.natuerlich,
      aktuellePhase: GamePhase.entstehung,
      abgeschlossen: false,
      mitgenommeneGedanken: const [],
    );
  }

  /// Bestimmt eine zufällige soziale Klasse mit realistischer Verteilung.
  /// (Unterschicht 40%, Mittelschicht 45%, Oberschicht 15%)
  static SozialeKlasse _zufaelligeSozialeKlasse() {
    // Einfache Zufallsverteilung via Zeitstempel-Modulo
    final zufall = DateTime.now().microsecondsSinceEpoch % 100;
    if (zufall < 40) return SozialeKlasse.unterschicht;
    if (zufall < 85) return SozialeKlasse.mittelschicht;
    return SozialeKlasse.oberschicht;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Das Jenseitsreich, das dem Karma-Profil dieses Zyklus entspricht
  JenseitsReich get jenseitsReich => karmaAmEnde.jenseitsReich;

  /// Gesamtanzahl der Entscheidungen in diesem Zyklus
  int get anzahlEntscheidungen => getroffeneEntscheidungen.length;

  /// Anzahl der ungenutzten Parallelvorschauen (max. 5 pro Leben)
  int get verbleibendeParallelvorschauen {
    final genutzt = getroffeneEntscheidungen
        .where((e) => e.hatParallelvorschau)
        .length;
    return (5 - genutzt).clamp(0, 5);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  ZyklusModel copyWith({
    String? id,
    int? zyklusNummer,
    String? spielerProfilId,
    Zeitalter? zeitalter,
    SozialeKlasse? startKlasse,
    GenetischerCodeModel? genetischerCode,
    KarmaProfilModel? karmaAmEnde,
    List<String>? erinnerungsIds,
    List<String>? gedankenIds,
    List<BeziehungModel>? beziehungen,
    List<EntscheidungModel>? getroffeneEntscheidungen,
    int? sterbealter,
    TodesArt? todesArt,
    String? letzteWorte,
    String? vermaechtnisBrief,
    GamePhase? aktuellePhase,
    bool? abgeschlossen,
    List<GedankeModel>? mitgenommeneGedanken,
  }) {
    return ZyklusModel(
      id: id ?? this.id,
      zyklusNummer: zyklusNummer ?? this.zyklusNummer,
      spielerProfilId: spielerProfilId ?? this.spielerProfilId,
      zeitalter: zeitalter ?? this.zeitalter,
      startKlasse: startKlasse ?? this.startKlasse,
      genetischerCode: genetischerCode ?? this.genetischerCode,
      karmaAmEnde: karmaAmEnde ?? this.karmaAmEnde,
      erinnerungsIds: erinnerungsIds ?? this.erinnerungsIds,
      gedankenIds: gedankenIds ?? this.gedankenIds,
      beziehungen: beziehungen ?? this.beziehungen,
      getroffeneEntscheidungen:
          getroffeneEntscheidungen ?? this.getroffeneEntscheidungen,
      sterbealter: sterbealter ?? this.sterbealter,
      todesArt: todesArt ?? this.todesArt,
      letzteWorte: letzteWorte ?? this.letzteWorte,
      vermaechtnisBrief: vermaechtnisBrief ?? this.vermaechtnisBrief,
      aktuellePhase: aktuellePhase ?? this.aktuellePhase,
      abgeschlossen: abgeschlossen ?? this.abgeschlossen,
      mitgenommeneGedanken:
          mitgenommeneGedanken ?? this.mitgenommeneGedanken,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  factory ZyklusModel.fromJson(Map<String, dynamic> json) {
    return ZyklusModel(
      id: json['id'] as String,
      zyklusNummer: json['zyklusNummer'] as int,
      spielerProfilId: json['spielerProfilId'] as String,
      zeitalter: Zeitalter.values.byName(json['zeitalter'] as String),
      startKlasse:
          SozialeKlasse.values.byName(json['startKlasse'] as String),
      genetischerCode: GenetischerCodeModel.fromJson(
          json['genetischerCode'] as Map<String, dynamic>),
      karmaAmEnde: KarmaProfilModel.fromJson(
          json['karmaAmEnde'] as Map<String, dynamic>),
      erinnerungsIds:
          List<String>.from(json['erinnerungsIds'] as List),
      gedankenIds: List<String>.from(json['gedankenIds'] as List),
      beziehungen: (json['beziehungen'] as List)
          .map((b) => BeziehungModel.fromJson(b as Map<String, dynamic>))
          .toList(),
      getroffeneEntscheidungen: (json['getroffeneEntscheidungen'] as List)
          .map((e) =>
              EntscheidungModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      sterbealter: json['sterbealter'] as int,
      todesArt: TodesArt.values.byName(json['todesArt'] as String),
      letzteWorte: json['letzteWorte'] as String?,
      vermaechtnisBrief: json['vermaechtnisBrief'] as String?,
      aktuellePhase:
          GamePhase.values.byName(json['aktuellePhase'] as String),
      abgeschlossen: json['abgeschlossen'] as bool,
      mitgenommeneGedanken: (json['mitgenommeneGedanken'] as List)
          .map((g) => GedankeModel.fromJson(g as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'zyklusNummer': zyklusNummer,
        'spielerProfilId': spielerProfilId,
        'zeitalter': zeitalter.name,
        'startKlasse': startKlasse.name,
        'genetischerCode': genetischerCode.toJson(),
        'karmaAmEnde': karmaAmEnde.toJson(),
        'erinnerungsIds': erinnerungsIds,
        'gedankenIds': gedankenIds,
        'beziehungen': beziehungen.map((b) => b.toJson()).toList(),
        'getroffeneEntscheidungen':
            getroffeneEntscheidungen.map((e) => e.toJson()).toList(),
        'sterbealter': sterbealter,
        'todesArt': todesArt.name,
        'letzteWorte': letzteWorte,
        'vermaechtnisBrief': vermaechtnisBrief,
        'aktuellePhase': aktuellePhase.name,
        'abgeschlossen': abgeschlossen,
        'mitgenommeneGedanken':
            mitgenommeneGedanken.map((g) => g.toJson()).toList(),
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZyklusModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ZyklusModel(id: $id, zyklusNummer: $zyklusNummer, '
      'zeitalter: ${zeitalter.name}, sterbealter: $sterbealter, '
      'abgeschlossen: $abgeschlossen, jenseitsReich: ${jenseitsReich.name})';
}
