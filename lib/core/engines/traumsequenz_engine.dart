// Traumsequenz Engine für GENESIS: Der Kreislauf des Lebens
// Generiert nächtliche Traumsequenzen: Verarbeitung, Prophezeiung,
// frühere-Leben-Erinnerungen und surreale Mini-Games.

import 'dart:math';

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/erinnerung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: TraumTyp
// ─────────────────────────────────────────────────────────────────────────────

enum TraumTyp {
  /// Verarbeitung aktueller Ereignisse
  verarbeitung,

  /// Prophetischer Traum – andeutet zukünftige Ereignisse (verschwommen)
  prophetisch,

  /// Erinnerung aus früheren Leben (nur ab 2. Zyklus)
  fruehereLebenErinnerung,

  /// Surreales Mini-Game
  surrealeMiniGame,

  /// Albtraum mit innerem Dämon
  albtraum,

  /// Parallelzeitlinie – was wäre wenn
  parallelzeitlinie,
}

// ─────────────────────────────────────────────────────────────────────────────
// Model: Traumsequenz
// ─────────────────────────────────────────────────────────────────────────────

/// Eine nächtliche Traumsequenz des Charakters.
class Traumsequenz {
  final String id;
  final TraumTyp typ;
  final String titel;
  final String beschreibung;

  /// Visuelle Atmosphäre (Farb-Codes für Shader-Effekte)
  final TraumAtmosphaere atmosphaere;

  /// Verbundene Erinnerung falls verarbeitend
  final String? erinnerungsId;

  /// Prophetischer Hinweis (vage, unscharf)
  final String? prophezeiung;

  /// Ob dieser Traum eine spielbare Sequenz enthält
  final bool istSpielbar;

  /// Dauer in Sekunden (15-90)
  final int dauerSekunden;

  /// Karma-Auswirkung wenn der Traum gut endet
  final Map<String, double> karmaBonus;

  const Traumsequenz({
    required this.id,
    required this.typ,
    required this.titel,
    required this.beschreibung,
    required this.atmosphaere,
    this.erinnerungsId,
    this.prophezeiung,
    this.istSpielbar = false,
    required this.dauerSekunden,
    this.karmaBonus = const {},
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum: TraumAtmosphaere
// ─────────────────────────────────────────────────────────────────────────────

enum TraumAtmosphaere {
  /// Warmgolden – ruhige Verarbeitung
  warmgolden,

  /// Nebelgrau – prophetischer Traum
  nebelgrau,

  /// Kosmischviolett – frühere Leben
  kosmischviolett,

  /// Surrealbunt – Phantasie-Mini-Game
  surrealbunt,

  /// Dunkelrot – Albtraum mit Dämon
  dunkelrot,

  /// Eisblau – Parallelzeitlinie
  eisblau,
}

// ─────────────────────────────────────────────────────────────────────────────
// Engine: TraumsequenzEngine
// ─────────────────────────────────────────────────────────────────────────────

/// Generiert nächtliche Traumsequenzen basierend auf dem aktuellen Spielzustand.
class TraumsequenzEngine {
  final Random _zufall;

  TraumsequenzEngine({Random? zufall}) : _zufall = zufall ?? Random();

  // ─────────────────────────────────────────────────────────────────────────
  // Öffentliche Methoden
  // ─────────────────────────────────────────────────────────────────────────

  /// Generiert die Traumsequenz für eine Nacht.
  ///
  /// Berücksichtigt: aktuelle Phase, Zyklusnummer, Gedanken-Inventar,
  /// letzte Erinnerungen und aktive Dämonen.
  Traumsequenz traumGenerieren({
    required GamePhase aktuellePhase,
    required int zyklusNummer,
    required List<GedankeModel> aktuelleGedanken,
    required List<ErinnerungModel> letzteErinnerungen,
    required bool hatAktiveDaemonen,
    required double daemonenStaerke,
  }) {
    // Traumtyp-Wahrscheinlichkeiten bestimmen
    final gewichte = _traumGewichteBerechnen(
      phase: aktuellePhase,
      zyklusNummer: zyklusNummer,
      hatDaemonen: hatAktiveDaemonen,
      daemonenStaerke: daemonenStaerke,
    );

    final typ = _gewichtetenTypWaehlen(gewichte);

    return _traumErstellen(
      typ: typ,
      aktuellePhase: aktuellePhase,
      zyklusNummer: zyklusNummer,
      aktuelleGedanken: aktuelleGedanken,
      letzteErinnerungen: letzteErinnerungen,
    );
  }

  /// Gibt zurück ob eine Traumsequenz heute Nacht gespielt werden soll.
  /// Nicht jede Nacht ist ein spielbarer Traum.
  bool sollTraumGespieltWerden(GamePhase phase) {
    final wahrscheinlichkeit = switch (phase) {
      GamePhase.kindheit => 0.3,
      GamePhase.jugend => 0.4,
      GamePhase.erwachsen => 0.2,
      GamePhase.reife => 0.5, // Ältere Menschen träumen intensiver
      _ => 0.25,
    };
    return _zufall.nextDouble() < wahrscheinlichkeit;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Methoden
  // ─────────────────────────────────────────────────────────────────────────

  Map<TraumTyp, double> _traumGewichteBerechnen({
    required GamePhase phase,
    required int zyklusNummer,
    required bool hatDaemonen,
    required double daemonenStaerke,
  }) {
    return {
      TraumTyp.verarbeitung: 40,
      TraumTyp.prophetisch: 20,
      // Frühere-Leben-Erinnerungen nur ab 2. Zyklus
      TraumTyp.fruehereLebenErinnerung: zyklusNummer > 1 ? 20 : 0,
      TraumTyp.surrealeMiniGame: 15,
      // Albträume stärker wenn Dämonen aktiv
      TraumTyp.albtraum: hatDaemonen ? 30 * daemonenStaerke : 5,
      // Parallelzeitlinien häufiger im Alter
      TraumTyp.parallelzeitlinie: phase == GamePhase.reife ? 25 : 10,
    };
  }

  TraumTyp _gewichtetenTypWaehlen(Map<TraumTyp, double> gewichte) {
    final gesamtGewicht = gewichte.values.reduce((a, b) => a + b);
    var zufallswert = _zufall.nextDouble() * gesamtGewicht;

    for (final eintrag in gewichte.entries) {
      zufallswert -= eintrag.value;
      if (zufallswert <= 0) return eintrag.key;
    }

    return TraumTyp.verarbeitung;
  }

  Traumsequenz _traumErstellen({
    required TraumTyp typ,
    required GamePhase aktuellePhase,
    required int zyklusNummer,
    required List<GedankeModel> aktuelleGedanken,
    required List<ErinnerungModel> letzteErinnerungen,
  }) {
    final id = 'traum_${typ.name}_${DateTime.now().millisecondsSinceEpoch}';

    return switch (typ) {
      TraumTyp.verarbeitung => _verarbeitungsTraum(id, letzteErinnerungen),
      TraumTyp.prophetisch => _prophetischerTraum(id, aktuellePhase),
      TraumTyp.fruehereLebenErinnerung =>
        _fruehereLebenTraum(id, zyklusNummer),
      TraumTyp.surrealeMiniGame => _surrealesMinigame(id),
      TraumTyp.albtraum => _albtraum(id),
      TraumTyp.parallelzeitlinie => _parallelzeitlinie(id, aktuellePhase),
    };
  }

  Traumsequenz _verarbeitungsTraum(
    String id,
    List<ErinnerungModel> erinnerungen,
  ) {
    final letzteErinnerung = erinnerungen.isNotEmpty ? erinnerungen.last : null;

    return Traumsequenz(
      id: id,
      typ: TraumTyp.verarbeitung,
      titel: 'Echos des Tages',
      beschreibung: letzteErinnerung != null
          ? 'Die Bilder des Tages kommen zurück. ${letzteErinnerung.titel} erscheint verwandelt, '
              'seltsam und doch vertraut. Dein Geist sortiert, was er noch nicht versteht.'
          : 'In der Stille des Schlafs ordnet sich das Chaos des Tages. '
              'Bilder, Worte, Gesichter – alles fließt ineinander.',
      atmosphaere: TraumAtmosphaere.warmgolden,
      erinnerungsId: letzteErinnerung?.id,
      istSpielbar: false,
      dauerSekunden: 20 + _zufall.nextInt(20),
    );
  }

  Traumsequenz _prophetischerTraum(String id, GamePhase phase) {
    final prophezeiungen = [
      'Eine Kreuzung liegt vor dir. Beide Wege führen ans Ziel – aber zu verschiedenen Zielen.',
      'Jemand wird dich um Hilfe bitten. Was du antwortest, bleibt länger als du denkst.',
      'Ein Verlust kommt. Aber im Verlieren liegt etwas versteckt.',
      'Die Person die du morgen triffst, wird dich verändern.',
      'Eine Entscheidung die du vergessen hast, wird dich bald einholen.',
    ];

    return Traumsequenz(
      id: id,
      typ: TraumTyp.prophetisch,
      titel: 'Verschwommene Ahnung',
      beschreibung: 'Bilder flackern durch die Dunkelheit – zu schnell um sie zu greifen, '
          'zu klar um sie zu vergessen. Du weißt: etwas kommt. Was genau, '
          'bleibt im Nebel.',
      atmosphaere: TraumAtmosphaere.nebelgrau,
      prophezeiung: prophezeiungen[_zufall.nextInt(prophezeiungen.length)],
      istSpielbar: _zufall.nextDouble() > 0.7, // 30% spielbar
      dauerSekunden: 15 + _zufall.nextInt(15),
    );
  }

  Traumsequenz _fruehereLebenTraum(String id, int zyklusNummer) {
    return Traumsequenz(
      id: id,
      typ: TraumTyp.fruehereLebenErinnerung,
      titel: 'Déjà-vu aus einer anderen Zeit',
      beschreibung: 'Ein Gesicht das du nicht kennst, aber erkennst. '
          'Eine Sprache die du nie gelernt hast, die du aber verstehst. '
          'Für ${1 + _zufall.nextInt(2)} Sekunden bist du jemand anderes – '
          'und doch vollkommen du selbst.',
      atmosphaere: TraumAtmosphaere.kosmischviolett,
      istSpielbar: zyklusNummer > 2, // Spielbar ab 3. Zyklus
      dauerSekunden: 10 + _zufall.nextInt(10),
      karmaBonus: {'weisheit': 2.0},
    );
  }

  Traumsequenz _surrealesMinigame(String id) {
    final minigames = [
      ('Wolkenlaufen', 'Du läufst über Wolken. Jeder Schritt formt sie neu. Was erschaffst du?'),
      ('Der sprechende Baum', 'Ein uralter Baum stellt Fragen. Deine Antworten wachsen als Äste.'),
      ('Die Spiegelwelt', 'Dein Spiegelbild verhält sich anders als du. Wer ist das Spiegelbild?'),
      ('Der umgekehrte Regen', 'Regen fällt nach oben. Du lernst das Fallen zu genießen.'),
    ];

    final (titel, beschreibung) = minigames[_zufall.nextInt(minigames.length)];

    return Traumsequenz(
      id: id,
      typ: TraumTyp.surrealeMiniGame,
      titel: titel,
      beschreibung: beschreibung,
      atmosphaere: TraumAtmosphaere.surrealbunt,
      istSpielbar: true,
      dauerSekunden: 30 + _zufall.nextInt(30),
      karmaBonus: {'kreativitaet': 3.0},
    );
  }

  Traumsequenz _albtraum(String id) {
    return Traumsequenz(
      id: id,
      typ: TraumTyp.albtraum,
      titel: 'Das was du fliehst',
      beschreibung: 'Im Dunkel des Schlafs tritt es hervor – jenes Ding '
          'das du bei Tag nicht anschaust. Es hat kein Gesicht, '
          'aber du kennst es. Es ist von dir.',
      atmosphaere: TraumAtmosphaere.dunkelrot,
      istSpielbar: true, // Kampf oder Verhandlung mit Dämon
      dauerSekunden: 45 + _zufall.nextInt(30),
    );
  }

  Traumsequenz _parallelzeitlinie(String id, GamePhase phase) {
    return Traumsequenz(
      id: id,
      typ: TraumTyp.parallelzeitlinie,
      titel: 'Das andere Leben',
      beschreibung: 'Für ${30 + _zufall.nextInt(30)} Sekunden lebst du ein anderes Leben. '
          'Eine Entscheidung die du anders getroffen hast. '
          'Du weißt nicht ob es besser ist – nur anders.',
      atmosphaere: TraumAtmosphaere.eisblau,
      istSpielbar: _zufall.nextDouble() > 0.5,
      dauerSekunden: 30 + _zufall.nextInt(60),
      karmaBonus: {'weisheit': 5.0, 'empathie': 3.0},
    );
  }
}
