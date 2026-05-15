// Trauma & Dämonen Engine für GENESIS: Der Kreislauf des Lebens
// Verwaltet innere Dämonen (Angst, Gier, Zorn, Eifersucht, Trägheit) als
// erlebbare Gegner in Traumsequenzen. Ignorierte Dämonen werden stärker.

import 'dart:math';

import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: DaemonenTyp – die fünf inneren Dämonen
// ─────────────────────────────────────────────────────────────────────────────

enum DaemonenTyp {
  /// Angst – entsteht durch traumatische Erlebnisse, wächst bei Vermeidung
  angst,

  /// Gier – entsteht durch Verlust oder Mangel, wächst bei Besitzstreben
  gier,

  /// Zorn – entsteht durch Ungerechtigkeit, wächst bei Unterdrückung
  zorn,

  /// Eifersucht – entsteht durch Vergleiche, wächst bei Unsicherheit
  eifersucht,

  /// Trägheit – entsteht durch Resignation, wächst bei Bequemlichkeit
  traegheit,
}

// ─────────────────────────────────────────────────────────────────────────────
// Model: InnererDaemon
// ─────────────────────────────────────────────────────────────────────────────

/// Ein innerer Dämon des Charakters mit Stärke und Herkunft.
class InnererDaemon {
  final String id;
  final DaemonenTyp typ;

  /// Stärke des Dämons (0.0 bis 1.0). Wächst wenn ignoriert.
  final double staerke;

  /// Anzahl der Konfrontationen (Kämpfe oder Verhandlungen)
  final int konfrontationsAnzahl;

  /// Ob der Dämon besiegt/integriert wurde
  final bool istBesiegtOderIntegriert;

  /// Gedanken die diesen Dämon nähren
  final List<String> naehrenderGedankenIds;

  /// Ob dieser Dämon durch Sucht entstanden ist
  final bool durchSuchtEntstanden;

  const InnererDaemon({
    required this.id,
    required this.typ,
    required this.staerke,
    this.konfrontationsAnzahl = 0,
    this.istBesiegtOderIntegriert = false,
    this.naehrenderGedankenIds = const [],
    this.durchSuchtEntstanden = false,
  });

  InnererDaemon copyWith({
    double? staerke,
    int? konfrontationsAnzahl,
    bool? istBesiegtOderIntegriert,
    List<String>? naehrenderGedankenIds,
  }) {
    return InnererDaemon(
      id: id,
      typ: typ,
      staerke: staerke ?? this.staerke,
      konfrontationsAnzahl: konfrontationsAnzahl ?? this.konfrontationsAnzahl,
      istBesiegtOderIntegriert:
          istBesiegtOderIntegriert ?? this.istBesiegtOderIntegriert,
      naehrenderGedankenIds: naehrenderGedankenIds ?? this.naehrenderGedankenIds,
      durchSuchtEntstanden: durchSuchtEntstanden,
    );
  }

  /// Name des Dämons für die Anzeige
  String get anzeigeName => switch (typ) {
        DaemonenTyp.angst => 'Der Schatten der Angst',
        DaemonenTyp.gier => 'Der Hunger der Gier',
        DaemonenTyp.zorn => 'Die Flamme des Zorns',
        DaemonenTyp.eifersucht => 'Der grüne Schleier der Eifersucht',
        DaemonenTyp.traegheit => 'Die Schwere der Trägheit',
      };

  /// Beschreibung was diesen Dämon auslöst
  String get ausloeseBeschreibung => switch (typ) {
        DaemonenTyp.angst =>
          'Tritt auf wenn du Situationen vermeidest die dich an traumatische Erlebnisse erinnern.',
        DaemonenTyp.gier =>
          'Wächst wenn du besitzgierig handelst oder Angst vor Verlust hast.',
        DaemonenTyp.zorn =>
          'Entlädt sich wenn Ungerechtigkeit unausgesprochen bleibt.',
        DaemonenTyp.eifersucht =>
          'Flüstert wenn andere haben was du dir wünschst.',
        DaemonenTyp.traegheit =>
          'Lähmt dich wenn der Weg zu lang und der Erfolg zu fern erscheint.',
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'typ': typ.name,
        'staerke': staerke,
        'konfrontationsAnzahl': konfrontationsAnzahl,
        'istBesiegtOderIntegriert': istBesiegtOderIntegriert,
        'naehrenderGedankenIds': naehrenderGedankenIds,
        'durchSuchtEntstanden': durchSuchtEntstanden,
      };

  factory InnererDaemon.fromJson(Map<String, dynamic> json) => InnererDaemon(
        id: json['id'] as String,
        typ: DaemonenTyp.values.firstWhere((t) => t.name == json['typ']),
        staerke: (json['staerke'] as num).toDouble(),
        konfrontationsAnzahl: json['konfrontationsAnzahl'] as int? ?? 0,
        istBesiegtOderIntegriert:
            json['istBesiegtOderIntegriert'] as bool? ?? false,
        naehrenderGedankenIds:
            List<String>.from(json['naehrenderGedankenIds'] as List? ?? []),
        durchSuchtEntstanden: json['durchSuchtEntstanden'] as bool? ?? false,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Engine: TraumaDaemonenEngine
// ─────────────────────────────────────────────────────────────────────────────

/// Verwaltet die inneren Dämonen des Charakters.
///
/// Dämonen entstehen durch traumatische Gedanken und Erlebnisse.
/// In Traumsequenzen kann man mit ihnen kämpfen oder verhandeln.
/// Ignorierte Dämonen werden stärker und beeinflussen Entscheidungsoptionen.
class TraumaDaemonenEngine {
  final List<InnererDaemon> _daemonen = [];
  final Random _zufall;

  TraumaDaemonenEngine({Random? zufall}) : _zufall = zufall ?? Random();

  // ─────────────────────────────────────────────────────────────────────────
  // Daemon-Entstehung
  // ─────────────────────────────────────────────────────────────────────────

  /// Prüft ob ein Gedanke einen neuen Dämon entstehen lässt oder einen bestehenden stärkt.
  void gedankeVerarbeiten(GedankeModel gedanke) {
    if (!gedanke.istGiftig && gedanke.intensitaet < 0.6) return;

    // Bestimme welcher Dämon durch diesen Gedanken genährt wird
    final daemonenTyp = _gedankeZuDaemon(gedanke);
    if (daemonenTyp == null) return;

    final bestehender = _daemonenDesTyps(daemonenTyp);

    if (bestehender != null) {
      // Bestehenden Dämon stärken
      _daemonenAktualisieren(
        bestehender.copyWith(
          staerke: (bestehender.staerke + gedanke.intensitaet * 0.1).clamp(0, 1),
          naehrenderGedankenIds: [
            ...bestehender.naehrenderGedankenIds,
            gedanke.id,
          ],
        ),
      );
    } else {
      // Neuen Dämon erschaffen wenn Intensität hoch genug
      if (gedanke.intensitaet >= 0.7) {
        _daemonen.add(InnererDaemon(
          id: 'daemon_${daemonenTyp.name}_${DateTime.now().millisecondsSinceEpoch}',
          typ: daemonenTyp,
          staerke: gedanke.intensitaet * 0.5,
          naehrenderGedankenIds: [gedanke.id],
        ));
      }
    }
  }

  /// Simuliert das nächtliche Wachstum ignorierter Dämonen.
  void nachtSimulieren() {
    for (int i = 0; i < _daemonen.length; i++) {
      if (!_daemonen[i].istBesiegtOderIntegriert) {
        // Ignorierte Dämonen wachsen jede Nacht um 0-3%
        final wachstum = _zufall.nextDouble() * 0.03;
        _daemonen[i] = _daemonen[i].copyWith(
          staerke: (_daemonen[i].staerke + wachstum).clamp(0, 1),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Traumsequenz-Interaktion
  // ─────────────────────────────────────────────────────────────────────────

  /// Kämpft gegen einen Dämon in einer Traumsequenz.
  /// Kampf reduziert Stärke stark aber lässt Narbe zurück.
  KampfErgebnis daemonBekaempfen(String daemonId, double spielerStaerke) {
    final index = _daemonen.indexWhere((d) => d.id == daemonId);
    if (index == -1) return KampfErgebnis.nichtGefunden;

    final daemon = _daemonen[index];
    final erfolgschance = (spielerStaerke - daemon.staerke * 0.7).clamp(0, 1);

    if (_zufall.nextDouble() < erfolgschance) {
      // Sieg: Dämon stark geschwächt
      _daemonen[index] = daemon.copyWith(
        staerke: (daemon.staerke * 0.3).clamp(0, 1),
        konfrontationsAnzahl: daemon.konfrontationsAnzahl + 1,
        istBesiegtOderIntegriert: daemon.staerke * 0.3 < 0.1,
      );
      return KampfErgebnis.sieg;
    } else {
      // Niederlage: Dämon wächst durch den Kampf
      _daemonen[index] = daemon.copyWith(
        staerke: (daemon.staerke + 0.1).clamp(0, 1),
        konfrontationsAnzahl: daemon.konfrontationsAnzahl + 1,
      );
      return KampfErgebnis.niederlage;
    }
  }

  /// Verhandelt mit einem Dämon – nachhaltiger aber schwieriger.
  /// Integration eliminiert den Dämon vollständig, hinterlässt aber keine Narbe.
  VerhandlungsErgebnis daemonVerhandeln(
    String daemonId,
    double empathie,
    double weisheit,
  ) {
    final index = _daemonen.indexWhere((d) => d.id == daemonId);
    if (index == -1) return VerhandlungsErgebnis.nichtGefunden;

    final daemon = _daemonen[index];
    // Verhandlung braucht Empathie und Weisheit
    final erfolgschance = ((empathie + weisheit) / 200 - daemon.staerke * 0.5).clamp(0, 0.9);

    if (_zufall.nextDouble() < erfolgschance) {
      // Integration: Dämon wird zur Stärke
      _daemonen[index] = daemon.copyWith(
        istBesiegtOderIntegriert: true,
        staerke: 0,
        konfrontationsAnzahl: daemon.konfrontationsAnzahl + 1,
      );
      return VerhandlungsErgebnis.integration;
    } else {
      return VerhandlungsErgebnis.gescheitert;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Getter und Abfragen
  // ─────────────────────────────────────────────────────────────────────────

  List<InnererDaemon> get alleDaemonen => List.unmodifiable(_daemonen);

  List<InnererDaemon> get aktiveDaemonen =>
      _daemonen.where((d) => !d.istBesiegtOderIntegriert).toList();

  List<InnererDaemon> get starkeDaemonen =>
      _daemonen.where((d) => d.staerke > 0.7 && !d.istBesiegtOderIntegriert).toList();

  /// Der stärkste aktive Dämon – erscheint in der Jenseits-Prüfung.
  InnererDaemon? get letztePruefung {
    if (aktiveDaemonen.isEmpty) return null;
    return aktiveDaemonen.reduce((a, b) => a.staerke > b.staerke ? a : b);
  }

  /// Gesamtstärke aller aktiven Dämonen (beeinflusst Entscheidungsoptionen).
  double get gesamtDaemonenStaerke {
    if (aktiveDaemonen.isEmpty) return 0;
    return aktiveDaemonen.map((d) => d.staerke).reduce((a, b) => a + b) /
        aktiveDaemonen.length;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Hilfsmethoden
  // ─────────────────────────────────────────────────────────────────────────

  DaemonenTyp? _gedankeZuDaemon(GedankeModel gedanke) {
    if (gedanke.typ == GedankenTyp.angst) return DaemonenTyp.angst;
    if (gedanke.typ == GedankenTyp.trauma) {
      // Trauma kann verschiedene Dämonen auslösen
      return DaemonenTyp.values[_zufall.nextInt(DaemonenTyp.values.length)];
    }
    // Gier-Gedanken (sehr hohe Intensität bei Wunsch-Gedanken)
    if (gedanke.typ == GedankenTyp.wunsch && gedanke.intensitaet > 0.8) {
      return DaemonenTyp.gier;
    }
    return null;
  }

  InnererDaemon? _daemonenDesTyps(DaemonenTyp typ) {
    try {
      return _daemonen.firstWhere((d) => d.typ == typ && !d.istBesiegtOderIntegriert);
    } catch (_) {
      return null;
    }
  }

  void _daemonenAktualisieren(InnererDaemon aktualisiert) {
    final index = _daemonen.indexWhere((d) => d.id == aktualisiert.id);
    if (index != -1) _daemonen[index] = aktualisiert;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ergebnis-Enums
// ─────────────────────────────────────────────────────────────────────────────

enum KampfErgebnis { sieg, niederlage, nichtGefunden }

enum VerhandlungsErgebnis { integration, gescheitert, nichtGefunden }
