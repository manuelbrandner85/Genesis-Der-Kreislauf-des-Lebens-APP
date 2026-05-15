// rennen_ergebnis.dart
// Datenmodell für das Ergebnis des Spermium-Rennens in Phase 1.
// Berechnet aus dem Spielverlauf die Basis-Attribute für den neuen Charakter.

// ─────────────────────────────────────────────────────────────────────────────
// RoutenTyp – die drei möglichen Routen im Rennen
// ─────────────────────────────────────────────────────────────────────────────

/// Die drei wählbaren Routen bei Distanz 400 im Rennen.
/// Jede Route legt das Hauptattribut des neuen Charakters fest.
enum RoutenTyp {
  /// Rote Route – stärkt Kraft und Ausdauer
  kraft,

  /// Blaue Route – stärkt Intelligenz und Intuition
  intelligenz,

  /// Grüne Route – stärkt Empathie und Kreativität
  empathie,
}

// ─────────────────────────────────────────────────────────────────────────────
// Erweiterungsmethoden für RoutenTyp
// ─────────────────────────────────────────────────────────────────────────────

extension RoutenTypErweiterung on RoutenTyp {
  /// Anzeigename der Route auf Deutsch
  String get anzeigeName {
    switch (this) {
      case RoutenTyp.kraft:
        return 'Kraft';
      case RoutenTyp.intelligenz:
        return 'Intelligenz';
      case RoutenTyp.empathie:
        return 'Empathie';
    }
  }

  /// Beschreibung der Route und ihrer Auswirkungen
  String get beschreibung {
    switch (this) {
      case RoutenTyp.kraft:
        return 'Der Weg der Stärke – Kraft und Ausdauer dominieren.';
      case RoutenTyp.intelligenz:
        return 'Der Weg des Geistes – Intelligenz und Intuition leiten.';
      case RoutenTyp.empathie:
        return 'Der Weg des Herzens – Empathie und Kreativität blühen.';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RennenErgebnis – Datenmodell
// ─────────────────────────────────────────────────────────────────────────────

/// Hält alle relevanten Informationen über das abgeschlossene Spermium-Rennen.
///
/// Wird nach dem Rennen-Ende erstellt und an den [EntstehungsController]
/// übergeben, der daraus den genetischen Code des neuen Charakters berechnet.
class RennenErgebnis {
  /// Die gewählte Route (Kraft / Intelligenz / Empathie)
  final RoutenTyp gewaehltRoute;

  /// Endplatzierung im Rennen: 1 = Erster unter 1.000.000
  final int endPlatzierung;

  /// Anzahl eingesammelter Kraft-PowerUps (rot)
  final int eingesammelteKraftPowerUps;

  /// Anzahl eingesammelter Intelligenz-PowerUps (blau)
  final int eingesammelteIntelligenzPowerUps;

  /// Anzahl eingesammelter Empathie-PowerUps (grün)
  final int eingesammelteEmpathiePowerUps;

  /// Verbleibende Leben am Ende (0–3)
  final int lebenAmEnde;

  /// Endgeschwindigkeit als Bonus-Indikator
  final double endGeschwindigkeit;

  const RennenErgebnis({
    required this.gewaehltRoute,
    required this.endPlatzierung,
    required this.eingesammelteKraftPowerUps,
    required this.eingesammelteIntelligenzPowerUps,
    required this.eingesammelteEmpathiePowerUps,
    required this.lebenAmEnde,
    required this.endGeschwindigkeit,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Attribut-Berechnung
  // ───────────────────────────────────────────────────────────────────────────

  /// Berechnet die Basis-Attribute des neuen Charakters aus dem Rennergebnis.
  ///
  /// Berechnungsformel:
  /// - Hauptattribut der Route: Basis 60 + 5 pro thematischem PowerUp + 10 wenn Erster
  /// - Sekundäre Attribute: Basis 40 + 5 pro thematischem PowerUp
  /// - Bonus bei 3 verbleibenden Leben: +5 auf alle Attribute
  ///
  /// Gibt eine Map mit den sechs Basis-Attribut-Schlüsseln zurück.
  Map<String, double> attributeBerechnen() {
    // Erster-Bonus: +10 wenn Platz 1 erreicht
    final ersterBonus = endPlatzierung == 1 ? 10.0 : 0.0;

    // Leben-Bonus: +5 wenn alle 3 Leben überlebt
    final lebenBonus = lebenAmEnde == 3 ? 5.0 : 0.0;

    // Grundwerte je nach gewählter Route
    final double basisKraft;
    final double basisIntelligenz;
    final double basisEmpathie;
    final double basisKreativitaet;
    final double basisAusdauer;
    final double basisIntuition;

    switch (gewaehltRoute) {
      case RoutenTyp.kraft:
        // Kraft-Route: Kraft und Ausdauer sind Hauptattribute
        basisKraft = 60.0 +
            eingesammelteKraftPowerUps * 5.0 +
            ersterBonus +
            lebenBonus;
        basisAusdauer = 55.0 +
            eingesammelteKraftPowerUps * 3.0 +
            lebenBonus;
        basisIntelligenz = 40.0 +
            eingesammelteIntelligenzPowerUps * 5.0;
        basisEmpathie = 40.0 +
            eingesammelteEmpathiePowerUps * 5.0;
        basisKreativitaet = 35.0 +
            eingesammelteEmpathiePowerUps * 2.0;
        basisIntuition = 35.0 +
            eingesammelteIntelligenzPowerUps * 2.0;

      case RoutenTyp.intelligenz:
        // Intelligenz-Route: Intelligenz und Intuition sind Hauptattribute
        basisIntelligenz = 60.0 +
            eingesammelteIntelligenzPowerUps * 5.0 +
            ersterBonus +
            lebenBonus;
        basisIntuition = 55.0 +
            eingesammelteIntelligenzPowerUps * 3.0 +
            lebenBonus;
        basisKraft = 40.0 +
            eingesammelteKraftPowerUps * 5.0;
        basisEmpathie = 40.0 +
            eingesammelteEmpathiePowerUps * 5.0;
        basisKreativitaet = 45.0 +
            eingesammelteIntelligenzPowerUps * 2.0;
        basisAusdauer = 35.0 +
            eingesammelteKraftPowerUps * 2.0;

      case RoutenTyp.empathie:
        // Empathie-Route: Empathie und Kreativität sind Hauptattribute
        basisEmpathie = 60.0 +
            eingesammelteEmpathiePowerUps * 5.0 +
            ersterBonus +
            lebenBonus;
        basisKreativitaet = 55.0 +
            eingesammelteEmpathiePowerUps * 3.0 +
            lebenBonus;
        basisKraft = 40.0 +
            eingesammelteKraftPowerUps * 5.0;
        basisIntelligenz = 40.0 +
            eingesammelteIntelligenzPowerUps * 5.0;
        basisIntuition = 45.0 +
            eingesammelteEmpathiePowerUps * 2.0;
        basisAusdauer = 35.0 +
            eingesammelteKraftPowerUps * 2.0;
    }

    // Alle Werte auf 0–100 begrenzen
    return {
      'kraft': basisKraft.clamp(0.0, 100.0),
      'intelligenz': basisIntelligenz.clamp(0.0, 100.0),
      'empathie': basisEmpathie.clamp(0.0, 100.0),
      'kreativitaet': basisKreativitaet.clamp(0.0, 100.0),
      'ausdauer': basisAusdauer.clamp(0.0, 100.0),
      'intuition': basisIntuition.clamp(0.0, 100.0),
    };
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Hilfsmethoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Gibt eine lesbare Zusammenfassung des Ergebnisses zurück (für Debug/Log)
  @override
  String toString() {
    return 'RennenErgebnis('
        'route: ${gewaehltRoute.anzeigeName}, '
        'platz: $endPlatzierung, '
        'kraft: $eingesammelteKraftPowerUps, '
        'intelligenz: $eingesammelteIntelligenzPowerUps, '
        'empathie: $eingesammelteEmpathiePowerUps, '
        'leben: $lebenAmEnde)';
  }
}
