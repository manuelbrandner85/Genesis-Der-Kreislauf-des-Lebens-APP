// spieler_profil_model.dart
// Repräsentiert das permanente Spielerprofil auf Seelen-Ebene.
// Das Profil bleibt über alle Lebenszyklen hinweg bestehen und
// speichert den übergreifenden Fortschritt der ewigen Seele.

import 'package:uuid/uuid.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SpielerProfilModel – das übergreifende Seelenprofil des Spielers
// ─────────────────────────────────────────────────────────────────────────────
// @JsonSerializable() – JSON-Serialisierung ist manuell implementiert
class SpielerProfilModel {
  /// Permanente Seelen-UUID – ändert sich niemals, über alle Zyklen identisch
  final String id;

  /// Der Anzeigename des Spielers (kann geändert werden)
  final String anzeigeName;

  /// Die Nummer des aktuell laufenden Lebenszyklus
  final int aktuellerZyklusNummer;

  /// ID des aktuell aktiven Lebenszyklus
  final String aktuellerZyklusId;

  /// Das kumulative Karma-Profil über alle gespielten Zyklen hinweg
  final KarmaProfilModel kumulativesKarma;

  /// IDs aller gespielten Lebenszyklen (in chronologischer Reihenfolge)
  final List<String> zyklusIds;

  /// Gedanken, die aus dem letzten Karma-Gericht ins nächste Leben mitgenommen werden
  final List<GedankeModel> mitgenommeneGedanken;

  /// Alle gesammelten Erkenntnisse und freigeschalteten Inhalte der Bibliothek
  final Map<String, dynamic> bibliotheksDaten;

  /// Anzahl freigeschalteter Weisheiten aus vergangenen Leben
  final int freigeschalteteWeisheiten;

  /// Gibt an, ob der Spieler kosmisches Bewusstsein (höchste Stufe) erreicht hat
  final bool kosmischesBewusstseinErreicht;

  /// Gibt an, ob der Schöpfungsmodus freigeschaltet ist (nach Erreichen von Elysium)
  final bool schoepfungsModus;

  /// Zeitstempel der Erstanlage dieses Profils
  final DateTime erstellt;

  /// Zeitstempel des letzten Spieltags
  final DateTime letzterSpieltag;

  const SpielerProfilModel({
    required this.id,
    required this.anzeigeName,
    required this.aktuellerZyklusNummer,
    required this.aktuellerZyklusId,
    required this.kumulativesKarma,
    required this.zyklusIds,
    required this.mitgenommeneGedanken,
    required this.bibliotheksDaten,
    required this.freigeschalteteWeisheiten,
    required this.kosmischesBewusstseinErreicht,
    required this.schoepfungsModus,
    required this.erstellt,
    required this.letzterSpieltag,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Factory: Neues Spielerprofil anlegen
  // ───────────────────────────────────────────────────────────────────────────

  /// Erstellt ein frisches Spielerprofil für einen neuen Spieler.
  /// Die Seelen-UUID wird einmalig generiert und niemals überschrieben.
  static SpielerProfilModel neu(String name) {
    const uuid = Uuid();
    final jetzt = DateTime.now();
    final seelenId = uuid.v4();
    // Platzhalter-ZyklusId – wird beim Start des ersten Zyklus ersetzt
    final ersterZyklusId = uuid.v4();

    return SpielerProfilModel(
      id: seelenId,
      anzeigeName: name,
      aktuellerZyklusNummer: 1,
      aktuellerZyklusId: ersterZyklusId,
      kumulativesKarma: KarmaProfilModel.neutral(),
      zyklusIds: [ersterZyklusId],
      mitgenommeneGedanken: const [],
      bibliotheksDaten: const {},
      freigeschalteteWeisheiten: 0,
      kosmischesBewusstseinErreicht: false,
      schoepfungsModus: false,
      erstellt: jetzt,
      letzterSpieltag: jetzt,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Gesamtzahl der abgeschlossenen Lebenszyklen
  int get anzahlAbgeschlossenerZyklen =>
      (zyklusIds.length - 1).clamp(0, zyklusIds.length);

  /// Das aktuelle Jenseitsreich, das dem kumulativen Karma entspricht
  JenseitsReich get aktuellesJenseitsReich =>
      kumulativesKarma.jenseitsReich;

  /// Karma-Durchschnittswert über alle Dimensionen
  double get karmaDurchschnitt => kumulativesKarma.durchschnitt;

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  SpielerProfilModel copyWith({
    String? id,
    String? anzeigeName,
    int? aktuellerZyklusNummer,
    String? aktuellerZyklusId,
    KarmaProfilModel? kumulativesKarma,
    List<String>? zyklusIds,
    List<GedankeModel>? mitgenommeneGedanken,
    Map<String, dynamic>? bibliotheksDaten,
    int? freigeschalteteWeisheiten,
    bool? kosmischesBewusstseinErreicht,
    bool? schoepfungsModus,
    DateTime? erstellt,
    DateTime? letzterSpieltag,
  }) {
    return SpielerProfilModel(
      id: id ?? this.id,
      anzeigeName: anzeigeName ?? this.anzeigeName,
      aktuellerZyklusNummer:
          aktuellerZyklusNummer ?? this.aktuellerZyklusNummer,
      aktuellerZyklusId: aktuellerZyklusId ?? this.aktuellerZyklusId,
      kumulativesKarma: kumulativesKarma ?? this.kumulativesKarma,
      zyklusIds: zyklusIds ?? this.zyklusIds,
      mitgenommeneGedanken:
          mitgenommeneGedanken ?? this.mitgenommeneGedanken,
      bibliotheksDaten: bibliotheksDaten ?? this.bibliotheksDaten,
      freigeschalteteWeisheiten:
          freigeschalteteWeisheiten ?? this.freigeschalteteWeisheiten,
      kosmischesBewusstseinErreicht:
          kosmischesBewusstseinErreicht ?? this.kosmischesBewusstseinErreicht,
      schoepfungsModus: schoepfungsModus ?? this.schoepfungsModus,
      erstellt: erstellt ?? this.erstellt,
      letzterSpieltag: letzterSpieltag ?? this.letzterSpieltag,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  factory SpielerProfilModel.fromJson(Map<String, dynamic> json) {
    return SpielerProfilModel(
      id: json['id'] as String,
      anzeigeName: json['anzeigeName'] as String,
      aktuellerZyklusNummer: json['aktuellerZyklusNummer'] as int,
      aktuellerZyklusId: json['aktuellerZyklusId'] as String,
      kumulativesKarma: KarmaProfilModel.fromJson(
          json['kumulativesKarma'] as Map<String, dynamic>),
      zyklusIds: List<String>.from(json['zyklusIds'] as List),
      mitgenommeneGedanken: (json['mitgenommeneGedanken'] as List)
          .map((g) => GedankeModel.fromJson(g as Map<String, dynamic>))
          .toList(),
      bibliotheksDaten:
          Map<String, dynamic>.from(json['bibliotheksDaten'] as Map),
      freigeschalteteWeisheiten: json['freigeschalteteWeisheiten'] as int,
      kosmischesBewusstseinErreicht:
          json['kosmischesBewusstseinErreicht'] as bool,
      schoepfungsModus: json['schoepfungsModus'] as bool,
      erstellt: DateTime.parse(json['erstellt'] as String),
      letzterSpieltag: DateTime.parse(json['letzterSpieltag'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'anzeigeName': anzeigeName,
        'aktuellerZyklusNummer': aktuellerZyklusNummer,
        'aktuellerZyklusId': aktuellerZyklusId,
        'kumulativesKarma': kumulativesKarma.toJson(),
        'zyklusIds': zyklusIds,
        'mitgenommeneGedanken':
            mitgenommeneGedanken.map((g) => g.toJson()).toList(),
        'bibliotheksDaten': bibliotheksDaten,
        'freigeschalteteWeisheiten': freigeschalteteWeisheiten,
        'kosmischesBewusstseinErreicht': kosmischesBewusstseinErreicht,
        'schoepfungsModus': schoepfungsModus,
        'erstellt': erstellt.toIso8601String(),
        'letzterSpieltag': letzterSpieltag.toIso8601String(),
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpielerProfilModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SpielerProfilModel(id: $id, anzeigeName: "$anzeigeName", '
      'aktuellerZyklusNummer: $aktuellerZyklusNummer, '
      'kosmischesBewusstseinErreicht: $kosmischesBewusstseinErreicht)';
}
