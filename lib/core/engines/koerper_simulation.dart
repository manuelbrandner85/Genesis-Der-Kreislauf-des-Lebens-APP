// Körper-Simulation Engine für GENESIS: Der Kreislauf des Lebens
// Simuliert Organe, Gesundheit, Ernährung, Krankheiten und Todesursachen.
// Krankheiten sind logische Folgen des Lebensstils – die Todesursache wird berechnet.

import 'dart:math';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: OrganSystem
// ─────────────────────────────────────────────────────────────────────────────

enum OrganSystem {
  herz,     // Herzgesundheit – beeinflusst durch Sport und Stress
  lunge,    // Lungengesundheit – beeinflusst durch Rauchen und Aktivität
  gehirn,   // Mentale Gesundheit – beeinflusst durch Bildung und Trauma
  leber,    // Lebergesundheit – beeinflusst durch Alkohol und Ernährung
  magen,    // Verdauung – beeinflusst durch Ernährung und Stress
  immunsystem, // Widerstandskraft – beeinflusst durch Schlaf und Ernährung
  bewegungsapparat, // Knochen und Muskeln – beeinflusst durch Aktivität
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum: Krankheit
// ─────────────────────────────────────────────────────────────────────────────

enum Krankheit {
  herzinfarkt,
  schlaganfall,
  lungenkrebs,
  depression,
  diabetes,
  leberzirrhose,
  arthritis,
  demenz,
  burnout,
  sucht,
}

// ─────────────────────────────────────────────────────────────────────────────
// Model: KoerperZustand
// ─────────────────────────────────────────────────────────────────────────────

/// Der körperliche Zustand des Charakters zu einem Zeitpunkt.
class KoerperZustand {
  /// Gesundheit der einzelnen Organsysteme (0.0-100.0)
  final Map<OrganSystem, double> organGesundheit;

  /// Aktive Krankheiten und ihr Schweregrad (0.0-1.0)
  final Map<Krankheit, double> aktiveKrankheiten;

  /// Allgemeiner Gesundheitswert (0.0-100.0) – Durchschnitt aller Organe
  double get gesamtGesundheit {
    if (organGesundheit.isEmpty) return 100;
    return organGesundheit.values.reduce((a, b) => a + b) /
        organGesundheit.length;
  }

  /// Geschätztes Maximalalter basierend auf aktuellem Zustand
  final int schaetzungMaximalAlter;

  /// Ob der Charakter an einer Krankheit leidet
  bool get istKrank => aktiveKrankheiten.isNotEmpty;

  const KoerperZustand({
    required this.organGesundheit,
    this.aktiveKrankheiten = const {},
    required this.schaetzungMaximalAlter,
  });

  /// Standard-Zustand bei Geburt: alle Organe auf 100%
  factory KoerperZustand.beiGeburt() {
    return KoerperZustand(
      organGesundheit: {
        for (final organ in OrganSystem.values) organ: 100.0,
      },
      schaetzungMaximalAlter: 75 + Random().nextInt(30), // 75-105 Jahre
    );
  }

  KoerperZustand copyWith({
    Map<OrganSystem, double>? organGesundheit,
    Map<Krankheit, double>? aktiveKrankheiten,
    int? schaetzungMaximalAlter,
  }) {
    return KoerperZustand(
      organGesundheit: organGesundheit ?? this.organGesundheit,
      aktiveKrankheiten: aktiveKrankheiten ?? this.aktiveKrankheiten,
      schaetzungMaximalAlter:
          schaetzungMaximalAlter ?? this.schaetzungMaximalAlter,
    );
  }

  Map<String, dynamic> toJson() => {
        'organGesundheit':
            organGesundheit.map((k, v) => MapEntry(k.name, v)),
        'aktiveKrankheiten':
            aktiveKrankheiten.map((k, v) => MapEntry(k.name, v)),
        'schaetzungMaximalAlter': schaetzungMaximalAlter,
      };

  factory KoerperZustand.fromJson(Map<String, dynamic> json) {
    final organMap =
        (json['organGesundheit'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(
        OrganSystem.values.firstWhere((o) => o.name == k),
        (v as num).toDouble(),
      ),
    );

    final krankheitMap =
        (json['aktiveKrankheiten'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(
        Krankheit.values.firstWhere((kr) => kr.name == k),
        (v as num).toDouble(),
      ),
    );

    return KoerperZustand(
      organGesundheit: organMap,
      aktiveKrankheiten: krankheitMap,
      schaetzungMaximalAlter: json['schaetzungMaximalAlter'] as int? ?? 80,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Engine: KoerperSimulation
// ─────────────────────────────────────────────────────────────────────────────

/// Simuliert die körperliche Entwicklung und Verschlechterung über ein Leben.
class KoerperSimulation {
  final Random _zufall;

  KoerperSimulation({Random? zufall}) : _zufall = zufall ?? Random();

  // ─────────────────────────────────────────────────────────────────────────
  // Lebensstil-Auswirkungen
  // ─────────────────────────────────────────────────────────────────────────

  /// Aktualisiert den Körperzustand basierend auf einem Lebensjahr.
  KoerperZustand jahrSimulieren({
    required KoerperZustand aktuell,
    required int alter,
    required LebensstilParameter lebensstil,
    required List<String> aktivierteGene,
    required List<String> krankheitsrisiken,
  }) {
    var neueGesundheit =
        Map<OrganSystem, double>.from(aktuell.organGesundheit);

    // Altersbedingte Abnahme (ab 40 beschleunigt)
    final altersFaktor = alter > 40 ? 0.5 + (alter - 40) * 0.05 : 0.3;

    for (final organ in OrganSystem.values) {
      double veraenderung = -altersFaktor; // Natürlicher Alterungsprozess

      // Lebensstil-Einflüsse pro Organ
      veraenderung += _lebensstilEinfluss(organ, lebensstil);

      // Gen-Einflüsse
      veraenderung += _genEinfluss(organ, aktivierteGene);

      neueGesundheit[organ] = (neueGesundheit[organ]! + veraenderung).clamp(0, 100);
    }

    // Krankheitsrisiken prüfen
    final neueKrankheiten =
        Map<Krankheit, double>.from(aktuell.aktiveKrankheiten);
    _krankheitsRisikenPruefen(
      neueGesundheit,
      neueKrankheiten,
      krankheitsrisiken,
      lebensstil,
    );

    return aktuell.copyWith(
      organGesundheit: neueGesundheit,
      aktiveKrankheiten: neueKrankheiten,
    );
  }

  /// Berechnet die wahrscheinlichste Todesursache.
  String todesUrsacheBerechnen(KoerperZustand zustand, int alter) {
    if (zustand.aktiveKrankheiten.isNotEmpty) {
      // Tod durch stärkste Krankheit
      final schwersteKrankheit = zustand.aktiveKrankheiten.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      return _krankheitZuText(schwersteKrankheit.key);
    }

    // Schwächstes Organ bestimmt Todesursache
    final schwaechtesOrgan = zustand.organGesundheit.entries
        .reduce((a, b) => a.value < b.value ? a : b);

    return _organZuTodesursache(schwaechtesOrgan.key, alter);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Methoden
  // ─────────────────────────────────────────────────────────────────────────

  double _lebensstilEinfluss(OrganSystem organ, LebensstilParameter ls) {
    return switch (organ) {
      OrganSystem.herz =>
        (ls.sportStunden * 0.1) - (ls.stressLevel * 0.15) -
            (ls.raucht ? 0.2 : 0) + (ls.schlafStunden > 7 ? 0.1 : -0.1),
      OrganSystem.lunge =>
        (ls.sportStunden * 0.05) - (ls.raucht ? 0.5 : 0) -
            (ls.passivRaucht ? 0.15 : 0),
      OrganSystem.gehirn =>
        (ls.bildungsStunden * 0.1) - (ls.stressLevel * 0.1) +
            (ls.meditiert ? 0.15 : 0) - (ls.substanzKonsum * 0.1),
      OrganSystem.leber =>
        -(ls.alkoholKonsum * 0.3) - (ls.substanzKonsum * 0.2) +
            (ls.gesundeErnaehrung ? 0.1 : -0.05),
      OrganSystem.magen =>
        (ls.gesundeErnaehrung ? 0.1 : -0.1) - (ls.stressLevel * 0.05),
      OrganSystem.immunsystem =>
        (ls.gesundeErnaehrung ? 0.15 : -0.1) +
            (ls.schlafStunden > 7 ? 0.1 : -0.15) - (ls.stressLevel * 0.1),
      OrganSystem.bewegungsapparat =>
        (ls.sportStunden * 0.15) - (ls.sitzendeTaetigkeit ? 0.1 : 0),
    };
  }

  double _genEinfluss(OrganSystem organ, List<String> aktivierteGene) {
    double einfluss = 0;
    if (aktivierteGene.contains('gen_herzstaerke') &&
        organ == OrganSystem.herz) {
      einfluss += 0.2;
    }
    if (aktivierteGene.contains('gen_lungenkraft') &&
        organ == OrganSystem.lunge) {
      einfluss += 0.2;
    }
    if (aktivierteGene.contains('gen_immunstaerke') &&
        organ == OrganSystem.immunsystem) {
      einfluss += 0.2;
    }
    if (aktivierteGene.contains('gen_stressresistenz') &&
        organ == OrganSystem.gehirn) {
      einfluss += 0.15;
    }
    return einfluss;
  }

  void _krankheitsRisikenPruefen(
    Map<OrganSystem, double> gesundheit,
    Map<Krankheit, double> krankheiten,
    List<String> risiken,
    LebensstilParameter ls,
  ) {
    // Herzinfarkt-Risiko
    if (gesundheit[OrganSystem.herz]! < 40 && !krankheiten.containsKey(Krankheit.herzinfarkt)) {
      if (_zufall.nextDouble() < 0.2) {
        krankheiten[Krankheit.herzinfarkt] = 0.7;
      }
    }
    // Depression-Risiko
    if (gesundheit[OrganSystem.gehirn]! < 50 && ls.stressLevel > 0.7) {
      if (_zufall.nextDouble() < 0.15) {
        krankheiten[Krankheit.depression] =
            (krankheiten[Krankheit.depression] ?? 0) + 0.1;
      }
    }
    // Lungenkrebs-Risiko (nur bei starken Rauchern)
    if (ls.raucht && risiken.contains('Lungenempfindlichkeit')) {
      if (_zufall.nextDouble() < 0.05) {
        krankheiten[Krankheit.lungenkrebs] = 0.5;
      }
    }
  }

  String _krankheitZuText(Krankheit krankheit) => switch (krankheit) {
        Krankheit.herzinfarkt => 'Herzinfarkt',
        Krankheit.schlaganfall => 'Schlaganfall',
        Krankheit.lungenkrebs => 'Lungenkrebs',
        Krankheit.depression => 'Schwere Depression',
        Krankheit.diabetes => 'Diabetes-Komplikationen',
        Krankheit.leberzirrhose => 'Leberversagen',
        Krankheit.arthritis => 'Schwere Arthritis',
        Krankheit.demenz => 'Demenz',
        Krankheit.burnout => 'Totales Burnout',
        Krankheit.sucht => 'Suchterkrankung',
      };

  String _organZuTodesursache(OrganSystem organ, int alter) {
    if (alter > 85) return 'Hohes Alter – der Körper ruhte sich aus';
    return switch (organ) {
      OrganSystem.herz => 'Herzversagen',
      OrganSystem.lunge => 'Lungenversagen',
      OrganSystem.gehirn => 'Schlaganfall',
      OrganSystem.leber => 'Leberversagen',
      OrganSystem.immunsystem => 'Infektion',
      _ => 'Natürliches Versagen der Organe',
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model: LebensstilParameter
// ─────────────────────────────────────────────────────────────────────────────

/// Parameter die den Lebensstil eines Jahres beschreiben.
class LebensstilParameter {
  final double sportStunden;      // 0-7 Stunden pro Woche
  final double stressLevel;       // 0.0-1.0
  final bool raucht;
  final bool passivRaucht;
  final double alkoholKonsum;     // 0.0-1.0 (Intensität)
  final double substanzKonsum;    // 0.0-1.0
  final bool gesundeErnaehrung;
  final double schlafStunden;     // 4-10 Stunden pro Nacht
  final bool meditiert;
  final double bildungsStunden;   // 0-8 Stunden pro Woche
  final bool sitzendeTaetigkeit;  // Bürojob etc.

  const LebensstilParameter({
    this.sportStunden = 3,
    this.stressLevel = 0.3,
    this.raucht = false,
    this.passivRaucht = false,
    this.alkoholKonsum = 0.1,
    this.substanzKonsum = 0,
    this.gesundeErnaehrung = true,
    this.schlafStunden = 7.5,
    this.meditiert = false,
    this.bildungsStunden = 2,
    this.sitzendeTaetigkeit = false,
  });

  /// Standard-Lebensstil für einen gesunden Erwachsenen
  factory LebensstilParameter.standard() => const LebensstilParameter();
}
