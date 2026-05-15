// ki_spermium.dart
// KI-Gegner für das Spermium-Rennen. Simuliert 50 konkurrierende Spermien
// mit individuellen Geschwindigkeitsvariationen und einfachen Bewegungsmustern.

import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KiSpermium – einzelner KI-Gegner
// ─────────────────────────────────────────────────────────────────────────────

/// Ein KI-gesteuertes Spermium das gegen den Spieler antritt.
///
/// Bewegt sich mit leichten Zufallsvariationen und einer individuellen
/// Geschwindigkeit. Dient primär der Platzierungs-Berechnung.
class KiSpermium extends PositionComponent with HasPaint {
  // ─────────────────────────────────────────────────────────────────────────
  // Eigenschaften
  // ─────────────────────────────────────────────────────────────────────────

  /// Y-Position im normalisierten Raum (-1 bis 1), wird in Pixel umgerechnet
  double yPosition;

  /// Multiplikator gegenüber der Basisgeschwindigkeit (0.85–1.15)
  final double geschwindigkeitsModifikator;

  /// Zurückgelegte Distanz des KI-Spermiums (0–1000)
  double distanz;

  /// Ist true sobald das Ziel (Distanz 1000) erreicht wurde
  bool istFertig;

  /// Zeitpunkt des Zieleingangs in Sekunden (null wenn nicht fertig)
  double? zielzeit;

  /// Individuelle Farbe (leicht variiert, alle halb-transparent weiß)
  final Color _farbe;

  /// Schweif-Länge für die visuelle Animation
  final double _schweifLaenge;

  // Interne Zustandsvariablen
  double _animationsTimer = 0.0;
  double _zielY = 0.0; // Aktuelle Y-Zielposition in normalisiertem Raum
  double _yChangeTimer = 0.0;
  double _yChangePeriode = 0.0;
  final math.Random _zufall;

  KiSpermium({
    required int index,
    required this.yPosition,
    required this.geschwindigkeitsModifikator,
    this.distanz = 0.0,
    this.istFertig = false,
  })  : _farbe = Colors.white.withValues(
              alpha: 0.3 + (index % 5) * 0.06,
            ),
        _schweifLaenge = 8.0 + (index % 4) * 2.0,
        _zufall = math.Random(index * 42 + 7),
        super(
          size: Vector2(12, 12),
          anchor: Anchor.center,
        ) {
    // Zufällige Anfangs-Y-Periode für natürliche Bewegung
    _zielY = yPosition;
    _yChangePeriode = 1.5 + _zufall.nextDouble() * 2.5;
    _zielY = (yPosition + (_zufall.nextDouble() - 0.5) * 0.4)
        .clamp(-0.85, 0.85);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    if (istFertig) return;

    _animationsTimer += dt;
    _yChangeTimer += dt;

    // Distanz vorantreiben (mit individuellem Modifikator)
    // Die Distanz wird hier nicht direkt verwendet –
    // sie wird vom EntstehungsSpiel über distanz-Eigenschaft gesetzt.

    // Periodisch neue Y-Zielposition setzen (Schlängeln)
    if (_yChangeTimer >= _yChangePeriode) {
      _yChangeTimer = 0.0;
      _yChangePeriode = 1.5 + _zufall.nextDouble() * 2.5;
      _zielY = (yPosition + (_zufall.nextDouble() - 0.5) * 0.5)
          .clamp(-0.85, 0.85);
    }

    // Sanft zur Zielposition gleiten (lerp)
    yPosition += (_zielY - yPosition) * dt * 2.0;

    // Bildschirmposition aktualisieren
    _aktualisierePosition();
  }

  /// Berechnet die Bildschirmposition aus der normalisierten Y-Position.
  void _aktualisierePosition() {
    // Bildschirmgröße wird indirekt über den Spielbereich berechnet
    // Position wird vom EntstehungsSpiel gesetzt
  }

  /// Setzt die Bildschirmposition basierend auf Spielbereichsgröße.
  void setzePosition(Vector2 spielerPosition, double screenHoehe) {
    // KI-Gegner werden verstreut über die gesamte Bildschirmbreite angezeigt
    // Ihre X-Position zeigt ihre relative Distanz zum Spieler
    final spielBereichOben = screenHoehe * 0.2;
    final spielBereichHoehe = screenHoehe * 0.6;
    final neuesY = spielBereichOben +
        (yPosition + 1.0) / 2.0 * spielBereichHoehe;
    position.y = neuesY;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (istFertig) return;

    final mitte = size / 2;
    final zentrum = Offset(mitte.x, mitte.y);

    // Schweif-Animation (sinusförmige Bewegung)
    final schweifWinkel = math.sin(_animationsTimer * 8.0) * 0.4;

    // Schweif zeichnen (mehrere Segmente für Tiefenwirkung)
    for (int i = 0; i < 3; i++) {
      final t = (i + 1) / 3.0;
      final schweifX = -_schweifLaenge * t;
      final schweifY = math.sin(_animationsTimer * 8.0 + t * 2) * 3.0;

      canvas.drawLine(
        Offset(zentrum.dx - 4, zentrum.dy),
        Offset(zentrum.dx + schweifX, zentrum.dy + schweifY),
        Paint()
          ..color = _farbe.withValues(alpha: _farbe.a * (1.0 - t * 0.6))
          ..strokeWidth = 1.5 - t * 0.8
          ..strokeCap = StrokeCap.round,
      );
    }

    // Kopf des Spermiums (kleiner weißer Kreis)
    canvas.drawCircle(
      Offset(zentrum.dx + 2, zentrum.dy),
      4.5,
      Paint()
        ..color = _farbe
        ..style = PaintingStyle.fill,
    );

    // Akzent-Highlight
    canvas.drawCircle(
      Offset(zentrum.dx + 1, zentrum.dy - 1),
      1.5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KiSpermiumManager – verwaltet alle 50 KI-Gegner
// ─────────────────────────────────────────────────────────────────────────────

/// Verwaltet die 50 KI-Gegner und berechnet deren Distanzen.
///
/// Gibt dem [EntstehungsSpiel] die nötigen Informationen zur
/// Platzierungsberechnung.
class KiSpermiumManager extends Component with HasGameRef {
  final List<KiSpermium> kiGegner = [];

  // Gesamtspielzeit für Fertigkeitsberechnungen
  double _spielzeit = 0.0;

  final math.Random _zufall = math.Random(12345);

  // ─────────────────────────────────────────────────────────────────────────
  // Lebenszyklus
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _erstelleKiGegner();
  }

  void _erstelleKiGegner() {
    // 50 KI-Gegner mit unterschiedlichen Eigenschaften erstellen
    for (int i = 0; i < 50; i++) {
      final ki = KiSpermium(
        index: i,
        yPosition: (_zufall.nextDouble() * 2.0 - 1.0) * 0.8,
        geschwindigkeitsModifikator: 0.85 + _zufall.nextDouble() * 0.30,
      );
      kiGegner.add(ki);
      add(ki);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    _spielzeit += dt;

    final screenHoehe = gameRef.size.y;
    final screenBreite = gameRef.size.x;

    for (final ki in kiGegner) {
      if (!ki.istFertig) {
        // KI-Distanz mit individuellem Modifikator vorantreiben
        // Basisgeschwindigkeit wird extern gesetzt
        ki.setzePosition(Vector2.zero(), screenHoehe);

        // X-Position zeigt relative Distanz zum Spieler
        // Wird vom EntstehungsSpiel gesetzt
      }
    }
  }

  /// Aktualisiert alle KI-Distanzen basierend auf Basisgeschwindigkeit.
  void aktualisierDistanzen(double basisGeschwindigkeit, double dt) {
    for (final ki in kiGegner) {
      if (!ki.istFertig) {
        ki.distanz +=
            basisGeschwindigkeit * ki.geschwindigkeitsModifikator * dt;
        if (ki.distanz >= 1000.0) {
          ki.istFertig = true;
          ki.zielzeit = _spielzeit;
        }
      }
    }
  }

  /// Aktualisiert die visuelle X-Position der KI-Gegner relativ zum Spieler.
  void aktualisiereVisuellPosition(
      double spielerDistanz, double screenBreite, double screenHoehe) {
    for (final ki in kiGegner) {
      if (!ki.istFertig) {
        // Relative Distanz zum Spieler → X-Position
        final relativeDistanz = ki.distanz - spielerDistanz;
        // Skalierung: 200 Distanzeinheiten = halbe Bildschirmbreite
        final xOffset = relativeDistanz * (screenBreite / 400.0);
        ki.position.x =
            (screenBreite / 2.0 + xOffset).clamp(-20.0, screenBreite + 20.0);

        // Y-Position im Spielbereich
        final spielBereichOben = screenHoehe * 0.2;
        final spielBereichHoehe = screenHoehe * 0.6;
        ki.position.y = spielBereichOben +
            (ki.yPosition + 1.0) / 2.0 * spielBereichHoehe;
      } else {
        // Fertige KI-Gegner außerhalb des Bildschirms ausblenden
        ki.position.x = -100;
      }
    }
  }

  /// Berechnet die aktuelle Platzierung des Spielers.
  ///
  /// Zählt wie viele KI-Gegner eine größere Distanz zurückgelegt haben.
  int berechneSpielersPlatzierung(double spielerDistanz) {
    int vornelieger = 0;
    for (final ki in kiGegner) {
      if (ki.distanz > spielerDistanz) {
        vornelieger++;
      }
    }
    // Platzierung = Anzahl Gegner vor dem Spieler + 1
    return vornelieger + 1;
  }

  /// Verlangsamt alle KI-Gegner in der Nähe des Spielers (Empathie-PowerUp).
  void verlangsamNaheGegner(double spielerDistanz, {double radius = 100.0}) {
    for (final ki in kiGegner) {
      if ((ki.distanz - spielerDistanz).abs() < radius) {
        // Kurze Verlangsamung simulieren (5% langsamer für kurze Zeit)
        ki.distanz -= radius * 0.05;
      }
    }
  }
}
