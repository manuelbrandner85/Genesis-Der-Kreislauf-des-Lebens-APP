// Genetischer Code Generator für GENESIS: Der Kreislauf des Lebens
// Generiert einzigartige DNA-Codes bei der Entstehung, mischt Elterncodes
// und simuliert epigenetische Veränderungen durch Verhalten über Generationen.

import 'dart:math';
import 'package:uuid/uuid.dart';

import 'package:genesis_kreislauf_des_lebens/data/models/genetischer_code_model.dart';

/// Generiert und verwaltet genetische Codes für Charaktere.
///
/// Der Seelen-Code bleibt über alle Wiedergeburten gleich.
/// Der Körper-Code ändert sich mit jeder Inkarnation.
/// Epigenetische Veränderungen durch Verhalten beeinflussen Nachkommen.
class GenetischerCodeGenerator {
  final Random _zufall;
  final Uuid _uuid;

  GenetischerCodeGenerator({Random? zufall})
      : _zufall = zufall ?? Random(),
        _uuid = const Uuid();

  // ─────────────────────────────────────────────────────────────────────────
  // Basis-Attribute und ihre Wertebereiche
  // ─────────────────────────────────────────────────────────────────────────

  static const List<String> _basisAttributNamen = [
    'kraft',        // Körperliche Stärke und Ausdauer
    'intelligenz',  // Lernfähigkeit und analytisches Denken
    'empathie',     // Einfühlungsvermögen und emotionale Intelligenz
    'kreativitaet', // Kreative Problemlösung und künstlerische Ader
    'ausdauer',     // Durchhaltevermögen bei Rückschlägen
    'intuition',    // Instinktives Gespür für Situationen
    'charisma',     // Natürliche Ausstrahlung und Überzeugungskraft
    'geschicklichkeit', // Feinmotorik und Koordination
  ];

  static const List<String> _alleGene = [
    // Gesundheits-Gene (können durch Lebensstil aktiviert werden)
    'gen_herzstaerke',      // Aktiviert durch Sport: bessere Herzgesundheit
    'gen_lungenkraft',      // Aktiviert durch Ausdauertraining
    'gen_immunstaerke',     // Aktiviert durch gesunde Ernährung
    'gen_stressresistenz',  // Aktiviert durch Meditation
    // Krankheits-Gene (Risikogene, nicht zwingend aktiv)
    'gen_herzrisiko',       // Aktiviert durch Rauchen/Stress
    'gen_lungenrisiko',     // Aktiviert durch Rauchen
    'gen_angstneigung',     // Aktiviert durch chronischen Stress
    'gen_suchtneigung',     // Aktiviert durch Substanzkonsum
    // Talent-Gene (versteckte Potenziale)
    'gen_musik_talent',     // Enthüllt durch musikalische Auseinandersetzung
    'gen_malerei_talent',   // Enthüllt durch kreative Arbeit
    'gen_empathie_talent',  // Enthüllt durch tiefe zwischenmenschliche Bindungen
    'gen_fuehrungs_talent', // Enthüllt durch Verantwortungsübernahme
    'gen_heilungs_talent',  // Enthüllt durch Fürsorge für andere
    'gen_sprach_talent',    // Enthüllt durch Sprachenlernen
    'gen_sport_talent',     // Enthüllt durch körperliche Aktivität
    'gen_wissenschaft_talent', // Enthüllt durch intellektuelle Neugier
  ];

  static const List<String> _moeglicheKrankheitsrisiken = [
    'Herz-Kreislauf-Schwäche',
    'Lungenempfindlichkeit',
    'Depressionsneigung',
    'Allergien',
    'Diabetes-Risiko',
    'Migräne-Neigung',
    'Gelenkprobleme',
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Öffentliche Methoden
  // ─────────────────────────────────────────────────────────────────────────

  /// Generiert einen komplett neuen genetischen Code für eine neue Seele.
  /// Der Seelen-Code ist einzigartig und bleibt über alle Zyklen erhalten.
  GenetischerCodeModel neuenCodeGenerieren() {
    final seelencodeId = _uuid.v4();
    final koerpercode = _uuid.v4();

    // Basis-Attribute zufällig im mittleren Bereich (30-80)
    final basisAttribute = <String, double>{};
    final maximalAttribute = <String, double>{};

    for (final attribut in _basisAttributNamen) {
      final basisWert = 30.0 + _zufall.nextDouble() * 50.0;
      basisAttribute[attribut] = basisWert;
      // Maximales Potential liegt 15-30 Punkte über dem Basiswert
      maximalAttribute[attribut] = (basisWert + 15 + _zufall.nextDouble() * 15).clamp(0, 100);
    }

    // 3-5 Gene sind initial aktiv (positive Startbedingungen)
    final anzahlAktiv = 3 + _zufall.nextInt(3);
    final geneKopie = List<String>.from(_alleGene)..shuffle(_zufall);
    final aktivierteGene = geneKopie.take(anzahlAktiv).toList();
    final schlafendeGene = geneKopie.skip(anzahlAktiv).toList();

    // 0-2 Krankheitsrisiken (je nach Glück)
    final anzahlRisiken = _zufall.nextInt(3);
    final risiken = List<String>.from(_moeglicheKrankheitsrisiken)
      ..shuffle(_zufall);
    final krankheitsrisiken = risiken.take(anzahlRisiken).toList();

    // 1-3 versteckte Talente (aus den Talent-Genen)
    final talentGene = schlafendeGene.where((g) => g.contains('_talent')).toList()
      ..shuffle(_zufall);
    final versteckteTalente = talentGene.take(1 + _zufall.nextInt(3)).toList();

    return GenetischerCodeModel(
      seelencodeId: seelencodeId,
      koerpercode: koerpercode,
      basisAttribute: basisAttribute,
      maximalAttribute: maximalAttribute,
      aktivierteGene: aktivierteGene,
      schlafendeGene: schlafendeGene,
      krankheitsrisiken: krankheitsrisiken,
      versteckteTalente: versteckteTalente,
      epigenetischeVeraenderungen: {},
    );
  }

  /// Generiert einen Wiedergeburts-Code: gleicher Seelen-Code, neuer Körper.
  /// Epigenetische Veränderungen aus dem vorherigen Leben werden teilweise übertragen.
  GenetischerCodeModel wiedergeburtsCodeGenerieren(
    GenetischerCodeModel vorherigeLeben,
    Map<String, double> epigenetischeVeraenderungen,
  ) {
    final basisCode = neuenCodeGenerieren();

    // Seelen-Code bleibt identisch
    // Epigenetische Einflüsse aus dem Vorleben modifizieren die Attribute
    final angepassteAttribute = Map<String, double>.from(basisCode.basisAttribute);

    for (final eintrag in epigenetischeVeraenderungen.entries) {
      if (angepassteAttribute.containsKey(eintrag.key)) {
        // Epigenetische Übertragung: 30% des Wertes
        angepassteAttribute[eintrag.key] =
            (angepassteAttribute[eintrag.key]! + eintrag.value * 0.3).clamp(0, 100);
      }
    }

    return GenetischerCodeModel(
      seelencodeId: vorherigeLeben.seelencodeId, // Seele bleibt gleich
      koerpercode: const Uuid().v4(),             // Neuer Körper
      basisAttribute: angepassteAttribute,
      maximalAttribute: basisCode.maximalAttribute,
      aktivierteGene: basisCode.aktivierteGene,
      schlafendeGene: basisCode.schlafendeGene,
      krankheitsrisiken: _krankheitsrisikenVererben(
        vorherigeLeben.krankheitsrisiken,
        basisCode.krankheitsrisiken,
      ),
      versteckteTalente: basisCode.versteckteTalente,
      epigenetischeVeraenderungen: {},
    );
  }

  /// Mischt zwei Eltern-Codes für ein Kind (50/50 genetische Vererbung).
  GenetischerCodeModel kindCodeErstellen(
    GenetischerCodeModel elternteil1,
    GenetischerCodeModel elternteil2,
  ) {
    final kindAttribute = <String, double>{};
    final kindMaximal = <String, double>{};

    for (final attribut in _basisAttributNamen) {
      final wert1 = elternteil1.basisAttribute[attribut] ?? 50.0;
      final wert2 = elternteil2.basisAttribute[attribut] ?? 50.0;
      final max1 = elternteil1.maximalAttribute[attribut] ?? 80.0;
      final max2 = elternteil2.maximalAttribute[attribut] ?? 80.0;

      // Zufällige Gewichtung: 40-60% von jedem Elternteil
      final gewichtung = 0.4 + _zufall.nextDouble() * 0.2;
      kindAttribute[attribut] = (wert1 * gewichtung + wert2 * (1 - gewichtung))
          .clamp(10, 90); // Kinder haben modifizierte Attribute

      kindMaximal[attribut] = (max1 * 0.5 + max2 * 0.5 + 5).clamp(0, 100);
    }

    // Gene: Kombination beider Elternteile + eigene Mutation
    final alleElternGene = {
      ...elternteil1.aktivierteGene,
      ...elternteil2.aktivierteGene,
    }.toList();
    alleElternGene.shuffle(_zufall);

    final kindAktivGene = alleElternGene.take(
      (alleElternGene.length * 0.6).round(),
    ).toList();

    return GenetischerCodeModel(
      seelencodeId: const Uuid().v4(), // Eigene neue Seele
      koerpercode: const Uuid().v4(),
      basisAttribute: kindAttribute,
      maximalAttribute: kindMaximal,
      aktivierteGene: kindAktivGene,
      schlafendeGene: _alleGene.where((g) => !kindAktivGene.contains(g)).toList(),
      krankheitsrisiken: _krankheitsrisikenVererben(
        elternteil1.krankheitsrisiken,
        elternteil2.krankheitsrisiken,
      ),
      versteckteTalente: _talenteLottery(),
      epigenetischeVeraenderungen: {},
    );
  }

  /// Berechnet epigenetische Veränderungen durch Lebensstil-Entscheidungen.
  /// Wird am Ende eines Lebens aufgerufen und beeinflusst die nächste Generation.
  Map<String, double> epigenetikBerechnen({
    required bool raucher,
    required bool sportlich,
    required bool meditiert,
    required bool chronicStress,
    required bool gesundeErnaehrung,
    required bool substanzAbhaengig,
  }) {
    final veraenderungen = <String, double>{};

    if (raucher) {
      veraenderungen['gen_lungenrisiko'] = 15.0;
      veraenderungen['gen_herzrisiko'] = 10.0;
      veraenderungen['ausdauer'] = -10.0;
    }
    if (sportlich) {
      veraenderungen['gen_herzstaerke'] = 12.0;
      veraenderungen['gen_lungenkraft'] = 8.0;
      veraenderungen['kraft'] = 8.0;
      veraenderungen['ausdauer'] = 10.0;
    }
    if (meditiert) {
      veraenderungen['gen_stressresistenz'] = 15.0;
      veraenderungen['gen_angstneigung'] = -8.0;
      veraenderungen['intuition'] = 6.0;
    }
    if (chronicStress) {
      veraenderungen['gen_angstneigung'] = 12.0;
      veraenderungen['gen_herzrisiko'] = 8.0;
      veraenderungen['intelligenz'] = -5.0;
    }
    if (gesundeErnaehrung) {
      veraenderungen['gen_immunstaerke'] = 10.0;
      veraenderungen['ausdauer'] = 5.0;
    }
    if (substanzAbhaengig) {
      veraenderungen['gen_suchtneigung'] = 20.0;
      veraenderungen['intelligenz'] = -8.0;
      veraenderungen['empathie'] = -5.0;
    }

    return veraenderungen;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Hilfsmethoden
  // ─────────────────────────────────────────────────────────────────────────

  /// Vererbt Krankheitsrisiken: 50% Chance je Risiko weitergegeben zu werden.
  List<String> _krankheitsrisikenVererben(
    List<String> risiken1,
    List<String> risiken2,
  ) {
    final kombiniert = {...risiken1, ...risiken2};
    return kombiniert.where((_) => _zufall.nextDouble() > 0.5).toList();
  }

  /// Zufällige Talent-Lotterie: 1-3 versteckte Talente.
  List<String> _talenteLottery() {
    final talentGene = _alleGene.where((g) => g.contains('_talent')).toList()
      ..shuffle(_zufall);
    return talentGene.take(1 + _zufall.nextInt(3)).toList();
  }
}
