// genetischer_code_model.dart
// Repräsentiert den genetischen Code eines Charakters.
// Die Seelen-UUID bleibt über alle Wiedergeburten gleich,
// während der Körpercode sich mit jeder Inkarnation ändert.

import 'dart:math';
import 'package:uuid/uuid.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Konstanten: Basis-Attributnamen
// ─────────────────────────────────────────────────────────────────────────────

/// Alle gültigen Basis-Attribut-Schlüssel
const List<String> kBasisAttributSchluessel = [
  'kraft',
  'intelligenz',
  'empathie',
  'kreativitaet',
  'ausdauer',
  'intuition',
];

/// Vordefinierte Gene, die durch bestimmte Verhaltensweisen aktiviert werden können
const List<String> kMoeglicheGene = [
  'gen_heilung',        // Natürliche Heilfähigkeiten
  'gen_einfuehlsam',   // Tiefes Einfühlungsvermögen
  'gen_fuehrerschaft',  // Angeborene Führungsstärke
  'gen_kreativ',        // Außergewöhnliche Kreativität
  'gen_widerstand',     // Hohe Widerstandsfähigkeit
  'gen_intuition',      // Überdurchschnittliche Intuition
  'gen_kommunikation',  // Natürliches Kommunikationstalent
  'gen_logik',          // Ausgeprägtes logisches Denken
  'gen_mut',            // Angeborener Mut
  'gen_mitgefuehl',     // Tiefsitzendes Mitgefühl
];

/// Mögliche Krankheitsrisiken im genetischen Code
const List<String> kMoeglicheKrankheitsrisiken = [
  'herzkrankheit_risiko',
  'depression_anfaelligkeit',
  'diabetes_neigung',
  'arthritis_risiko',
  'sehschwaeche',
  'hoerprobleme',
];

// ─────────────────────────────────────────────────────────────────────────────
// GenetischerCodeModel
// ─────────────────────────────────────────────────────────────────────────────
// @JsonSerializable() – JSON-Serialisierung ist manuell implementiert
class GenetischerCodeModel {
  /// Seelen-UUID – bleibt über alle Wiedergeburten identisch
  final String seelencodeId;

  /// Körper-UUID – ändert sich mit jeder neuen Inkarnation
  final String koerpercode;

  /// Basis-Attribute des Charakters (Schlüssel: Attributname, Wert: 0.0–100.0)
  /// Gültige Schlüssel: kraft, intelligenz, empathie, kreativitaet, ausdauer, intuition
  final Map<String, double> basisAttribute;

  /// Genetische Obergrenzen der Attribute (durch Gene bestimmt)
  final Map<String, double> maximalAttribute;

  /// Gene, die durch Verhaltensweisen und Erlebnisse aktiviert wurden
  final List<String> aktivierteGene;

  /// Gene, die noch nicht aktiviert wurden (schlummern im Code)
  final List<String> schlafendeGene;

  /// Genetische Krankheitsrisiken dieses Charakters
  final List<String> krankheitsrisiken;

  /// Talente, die erst durch bestimmte Erlebnisse enthüllt werden
  final List<String> versteckteTalente;

  /// Epigenetische Veränderungen durch Lebensstil (Wert: -1.0 bis +1.0)
  final Map<String, double> epigenetischeVeraenderungen;

  const GenetischerCodeModel({
    required this.seelencodeId,
    required this.koerpercode,
    required this.basisAttribute,
    required this.maximalAttribute,
    required this.aktivierteGene,
    required this.schlafendeGene,
    required this.krankheitsrisiken,
    required this.versteckteTalente,
    required this.epigenetischeVeraenderungen,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Zufälligen Genetischen Code generieren
  // ───────────────────────────────────────────────────────────────────────────

  /// Generiert einen vollständig zufälligen genetischen Code für einen neuen Charakter.
  /// Die Seelen-UUID wird einmalig erstellt und über alle Zyklen beibehalten.
  static GenetischerCodeModel generieren() {
    final zufall = Random();
    const uuid = Uuid();

    // Zufällige Basis-Attribute (20–80 als sinnvoller Startbereich)
    final basis = <String, double>{};
    final maximal = <String, double>{};
    for (final attr in kBasisAttributSchluessel) {
      basis[attr] = 20.0 + zufall.nextDouble() * 60.0;
      // Maximalwert liegt 10–30 Punkte über dem Basiswert
      maximal[attr] = (basis[attr]! + 10.0 + zufall.nextDouble() * 20.0)
          .clamp(0.0, 100.0);
    }

    // Zufällige Gene aufteilen: 20–40% aktiv, Rest schlafend
    final alleGene = List<String>.from(kMoeglicheGene)..shuffle(zufall);
    final anzahlAktiv = (alleGene.length * (0.2 + zufall.nextDouble() * 0.2))
        .round();
    final aktiv = alleGene.sublist(0, anzahlAktiv);
    final schlafend = alleGene.sublist(anzahlAktiv);

    // 0–2 zufällige Krankheitsrisiken
    final risiken = List<String>.from(kMoeglicheKrankheitsrisiken)
      ..shuffle(zufall);
    final anzahlRisiken = zufall.nextInt(3); // 0, 1 oder 2
    final ausgewaehlteRisiken = risiken.sublist(0, anzahlRisiken);

    // 1–3 versteckte Talente (Teilmenge der schlafenden Gene)
    final talents = List<String>.from(schlafend)..shuffle(zufall);
    final anzahlTalente = 1 + zufall.nextInt(3);
    final versteckte =
        talents.sublist(0, anzahlTalente.clamp(0, talents.length));

    return GenetischerCodeModel(
      seelencodeId: uuid.v4(),
      koerpercode: uuid.v4(),
      basisAttribute: basis,
      maximalAttribute: maximal,
      aktivierteGene: aktiv,
      schlafendeGene: schlafend,
      krankheitsrisiken: ausgewaehlteRisiken,
      versteckteTalente: versteckte,
      epigenetischeVeraenderungen: {},
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Genetischen Code mit Partner mischen (für Kinder)
  // ───────────────────────────────────────────────────────────────────────────

  /// Mischt diesen genetischen Code mit dem eines Partners.
  /// Das Ergebnis ist ein neuer Kind-Code mit Merkmalen beider Elternteile.
  /// Die Seelen-UUID des Kindes wird neu generiert.
  GenetischerCodeModel mitPartnerMischen(GenetischerCodeModel partner) {
    final zufall = Random();
    const uuid = Uuid();

    // Attribute: 50/50 zufällige Mischung beider Elternteile
    final kindBasis = <String, double>{};
    final kindMaximal = <String, double>{};
    for (final attr in kBasisAttributSchluessel) {
      final elternWert = basisAttribute[attr] ?? 50.0;
      final partnerWert = partner.basisAttribute[attr] ?? 50.0;
      // Mittelwert mit leichter zufälliger Variation (±10%)
      final basis = (elternWert + partnerWert) / 2.0 +
          (zufall.nextDouble() - 0.5) * 20.0;
      kindBasis[attr] = basis.clamp(0.0, 100.0);

      final elternMax = maximalAttribute[attr] ?? 100.0;
      final partnerMax = partner.maximalAttribute[attr] ?? 100.0;
      kindMaximal[attr] = ((elternMax + partnerMax) / 2.0).clamp(0.0, 100.0);
    }

    // Gene: zufällige Auswahl aus dem Pool beider Elternteile
    final alleElternGene = {
      ...aktivierteGene,
      ...partner.aktivierteGene,
      ...schlafendeGene,
      ...partner.schlafendeGene,
    }.toList()
      ..shuffle(zufall);

    final anzahlAktiv = (alleElternGene.length * 0.3).round();
    final kindAktiv = alleElternGene.sublist(0, anzahlAktiv);
    final kindSchlafend = alleElternGene.sublist(anzahlAktiv);

    // Krankheitsrisiken: Vereinigung beider Elternteile (mit Wahrscheinlichkeit)
    final moeglicheRisiken = {
      ...krankheitsrisiken,
      ...partner.krankheitsrisiken,
    }.toList();
    final kindRisiken = moeglicheRisiken
        .where((_) => zufall.nextDouble() < 0.5) // 50% Übertragungsrate
        .toList();

    return GenetischerCodeModel(
      seelencodeId: uuid.v4(), // Neue Seele, neue UUID
      koerpercode: uuid.v4(),
      basisAttribute: kindBasis,
      maximalAttribute: kindMaximal,
      aktivierteGene: kindAktiv,
      schlafendeGene: kindSchlafend,
      krankheitsrisiken: kindRisiken,
      versteckteTalente: kindSchlafend.isNotEmpty
          ? [kindSchlafend[zufall.nextInt(kindSchlafend.length)]]
          : [],
      epigenetischeVeraenderungen: {},
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Gen aktivieren
  // ───────────────────────────────────────────────────────────────────────────

  /// Aktiviert ein schlafendes Gen und gibt eine neue Instanz zurück.
  /// Hat keine Wirkung, wenn das Gen bereits aktiv oder unbekannt ist.
  GenetischerCodeModel genAktivieren(String genName) {
    // Gen muss in den schlafenden Genen vorhanden sein
    if (!schlafendeGene.contains(genName)) return this;

    final neueSchlafend = List<String>.from(schlafendeGene)..remove(genName);
    final neueAktiv = List<String>.from(aktivierteGene)..add(genName);

    return copyWith(
      aktivierteGene: neueAktiv,
      schlafendeGene: neueSchlafend,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  GenetischerCodeModel copyWith({
    String? seelencodeId,
    String? koerpercode,
    Map<String, double>? basisAttribute,
    Map<String, double>? maximalAttribute,
    List<String>? aktivierteGene,
    List<String>? schlafendeGene,
    List<String>? krankheitsrisiken,
    List<String>? versteckteTalente,
    Map<String, double>? epigenetischeVeraenderungen,
  }) {
    return GenetischerCodeModel(
      seelencodeId: seelencodeId ?? this.seelencodeId,
      koerpercode: koerpercode ?? this.koerpercode,
      basisAttribute: basisAttribute ?? this.basisAttribute,
      maximalAttribute: maximalAttribute ?? this.maximalAttribute,
      aktivierteGene: aktivierteGene ?? this.aktivierteGene,
      schlafendeGene: schlafendeGene ?? this.schlafendeGene,
      krankheitsrisiken: krankheitsrisiken ?? this.krankheitsrisiken,
      versteckteTalente: versteckteTalente ?? this.versteckteTalente,
      epigenetischeVeraenderungen:
          epigenetischeVeraenderungen ?? this.epigenetischeVeraenderungen,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // JSON-Serialisierung
  // ───────────────────────────────────────────────────────────────────────────

  factory GenetischerCodeModel.fromJson(Map<String, dynamic> json) {
    return GenetischerCodeModel(
      seelencodeId: json['seelencodeId'] as String,
      koerpercode: json['koerpercode'] as String,
      basisAttribute: Map<String, double>.from(
        (json['basisAttribute'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      maximalAttribute: Map<String, double>.from(
        (json['maximalAttribute'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      aktivierteGene: List<String>.from(json['aktivierteGene'] as List),
      schlafendeGene: List<String>.from(json['schlafendeGene'] as List),
      krankheitsrisiken:
          List<String>.from(json['krankheitsrisiken'] as List),
      versteckteTalente:
          List<String>.from(json['versteckteTalente'] as List),
      epigenetischeVeraenderungen: Map<String, double>.from(
        (json['epigenetischeVeraenderungen'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'seelencodeId': seelencodeId,
        'koerpercode': koerpercode,
        'basisAttribute': basisAttribute,
        'maximalAttribute': maximalAttribute,
        'aktivierteGene': aktivierteGene,
        'schlafendeGene': schlafendeGene,
        'krankheitsrisiken': krankheitsrisiken,
        'versteckteTalente': versteckteTalente,
        'epigenetischeVeraenderungen': epigenetischeVeraenderungen,
      };

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GenetischerCodeModel &&
        other.seelencodeId == seelencodeId &&
        other.koerpercode == koerpercode;
  }

  @override
  int get hashCode => Object.hash(seelencodeId, koerpercode);

  @override
  String toString() =>
      'GenetischerCodeModel(seelencodeId: $seelencodeId, '
      'koerpercode: $koerpercode, '
      'aktivierteGene: ${aktivierteGene.length}, '
      'schlafendeGene: ${schlafendeGene.length})';
}
