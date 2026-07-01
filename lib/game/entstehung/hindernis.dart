// hindernis.dart
// Hindernisse im Spermium-Rennen. Verschiedene Typen mit unterschiedlichem
// Verhalten und visueller Darstellung über geometrische Formen (kein Sprite nötig).

import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HindernisTyp – Enum der verschiedenen Hindernisarten
// ─────────────────────────────────────────────────────────────────────────────

/// Die vier Hindernistypen im Rennen mit unterschiedlichen Spielmechaniken.
enum HindernisTyp {
  /// Große Zellstruktur (Eizell-Fragment) – muss umgangen werden
  zelle,

  /// Kleines Debris-Partikel – verursacht Schaden bei Berührung
  debris,

  /// Strömungspfeil – schiebt das Spermium seitlich ab
  stroemung,

  /// Horizontale Wandlinie mit Lücke – erzwingt präzises Steuern
  wand,
}

// ─────────────────────────────────────────────────────────────────────────────
// Hindernis – Flame-Komponente
// ─────────────────────────────────────────────────────────────────────────────

/// Ein Hindernis im Spermium-Rennen.
///
/// Wird vom [HindernisGenerator] erstellt und bewegt sich von rechts
/// nach links durch den Tunnel. Bei Bildschirmaustritt wird es entfernt.
class Hindernis extends PositionComponent
    with HasPaint, CollisionCallbacks, HasGameRef {
  // ─────────────────────────────────────────────────────────────────────────
  // Konstruktor und Eigenschaften
  // ─────────────────────────────────────────────────────────────────────────

  /// Art des Hindernisses bestimmt Aussehen und Verhalten
  final HindernisTyp typ;

  /// Aktuelle Scroll-Geschwindigkeit (wird von außen gesetzt)
  double scrollGeschwindigkeit;

  /// Strömungsrichtung: positiv = nach unten, negativ = nach oben (nur für typ.stroemung)
  final double stroemungsRichtung;

  // Interne Zustandsvariablen
  double _animationsTimer = 0.0;
  bool _istEntfernt = false;

  Hindernis({
    required Vector2 position,
    required this.typ,
    required this.scrollGeschwindigkeit,
    this.stroemungsRichtung = 1.0,
  }) : super(position: position) {
    // Größe je nach Typ setzen
    size = _groesseFuerTyp(typ);
    // Ankerpunkt zentrieren
    anchor = Anchor.center;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Hilfsmethode: Größe bestimmen
  // ─────────────────────────────────────────────────────────────────────────

  static Vector2 _groesseFuerTyp(HindernisTyp typ) {
    switch (typ) {
      case HindernisTyp.zelle:
        return Vector2(70, 70);
      case HindernisTyp.debris:
        return Vector2(20, 20);
      case HindernisTyp.stroemung:
        return Vector2(60, 40);
      case HindernisTyp.wand:
        // Volle Bildschirmbreite, wird in onLoad angepasst
        return Vector2(800, 18);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Lebenszyklus
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Kollisions-Hitbox je nach Typ hinzufügen
    switch (typ) {
      case HindernisTyp.zelle:
        add(CircleHitbox(radius: 35, anchor: Anchor.center));
      case HindernisTyp.debris:
        add(CircleHitbox(radius: 10, anchor: Anchor.center));
      case HindernisTyp.stroemung:
        // Strömung hat eine breite, flache Hitbox
        add(RectangleHitbox(
          size: Vector2(60, 30),
          anchor: Anchor.center,
        ));
      case HindernisTyp.wand:
        // Zwei separate Hitboxen für obere und untere Wandhälften
        // Die Lücke (ca. 80px) in der Mitte hat keine Hitbox
        final screenBreite = size.x;
        final lueckeBreite = 90.0;
        final wandBreite = (screenBreite - lueckeBreite) / 2;
        add(RectangleHitbox(
          size: Vector2(wandBreite, 18),
          position: Vector2(0, 0),
          anchor: Anchor.topLeft,
        ));
        add(RectangleHitbox(
          size: Vector2(wandBreite, 18),
          position: Vector2(wandBreite + lueckeBreite, 0),
          anchor: Anchor.topLeft,
        ));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update-Schleife
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    // Animationszeit vorantreiben
    _animationsTimer += dt;

    // Hindernis scrollt von rechts nach links
    position.x -= scrollGeschwindigkeit * dt;

    // Entfernen wenn links außerhalb des Bildschirms
    if (position.x < -150 && !_istEntfernt) {
      _istEntfernt = true;
      removeFromParent();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Zeichnen
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (typ) {
      case HindernisTyp.zelle:
        _zeichneZelle(canvas);
      case HindernisTyp.debris:
        _zeichneDebris(canvas);
      case HindernisTyp.stroemung:
        _zeichneStroemung(canvas);
      case HindernisTyp.wand:
        _zeichneWand(canvas);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Zeichenmethoden je Typ
  // ─────────────────────────────────────────────────────────────────────────

  /// Zeichnet eine Zelle (Eizell-Fragment): großer purpurner Kreis mit Kern
  void _zeichneZelle(Canvas canvas) {
    final mitte = size / 2;
    final zentrum = Offset(mitte.x, mitte.y);

    // Pulsierender Glow-Effekt
    final pulsation = 0.7 + 0.3 * math.sin(_animationsTimer * 2.0);

    // Äußerer Glow
    canvas.drawCircle(
      zentrum,
      35,
      Paint()
        ..color = const Color(0xFF6A0DAD).withValues(alpha: 0.25 * pulsation)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Hauptkörper der Zelle
    canvas.drawCircle(
      zentrum,
      32,
      Paint()
        ..color = const Color(0xFF4A0080).withValues(alpha: 0.85)
        ..style = PaintingStyle.fill,
    );

    // Zellmembran (hellerer Rand)
    canvas.drawCircle(
      zentrum,
      32,
      Paint()
        ..color = const Color(0xFF9B59B6).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Zellkern
    canvas.drawCircle(
      zentrum,
      12,
      Paint()
        ..color = const Color(0xFF7D3C98).withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );

    // Nukleolus (kleiner heller Punkt im Kern)
    canvas.drawCircle(
      Offset(zentrum.dx - 3, zentrum.dy - 3),
      4,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );
  }

  /// Zeichnet Debris: kleiner orangegelber Kreis mit Glow
  void _zeichneDebris(Canvas canvas) {
    final mitte = size / 2;
    final zentrum = Offset(mitte.x, mitte.y);

    // Rotation simulieren
    final winkel = _animationsTimer * 3.0;
    canvas.save();
    canvas.translate(zentrum.dx, zentrum.dy);
    canvas.rotate(winkel);
    canvas.translate(-zentrum.dx, -zentrum.dy);

    // Glow
    canvas.drawCircle(
      zentrum,
      12,
      Paint()
        ..color = const Color(0xFFFF6B00).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Kern
    canvas.drawCircle(
      zentrum,
      9,
      Paint()
        ..color = const Color(0xFFFF8C00)
        ..style = PaintingStyle.fill,
    );

    // Highlight
    canvas.drawCircle(
      Offset(zentrum.dx - 3, zentrum.dy - 3),
      3,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  /// Zeichnet eine Strömung: Pfeil der die Richtung anzeigt
  void _zeichneStroemung(Canvas canvas) {
    final mitte = size / 2;
    final pulsation = 0.5 + 0.5 * math.sin(_animationsTimer * 4.0);

    // Hintergrund-Glow der Strömung
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(mitte.x, mitte.y),
          width: 56,
          height: 28,
        ),
        const Radius.circular(8),
      ),
      Paint()
        ..color =
            const Color(0xFF00BFFF).withValues(alpha: 0.2 * pulsation)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Pfeilkörper
    final pfeilFarbe =
        const Color(0xFF00BFFF).withValues(alpha: 0.7 + 0.3 * pulsation);
    final pfeilPaint = Paint()
      ..color = pfeilFarbe
      ..style = PaintingStyle.fill;

    // Drei Pfeile nebeneinander zeichnen (zeigen die Strömungsrichtung)
    for (int i = 0; i < 3; i++) {
      final x = 8.0 + i * 18.0;
      final y = stroemungsRichtung > 0 ? 8.0 : 28.0;
      final spitzeY = stroemungsRichtung > 0 ? 28.0 : 8.0;

      final pfad = Path()
        ..moveTo(x + 6, y) // Basis links
        ..lineTo(x + 12, y) // Basis rechts
        ..lineTo(x + 9, spitzeY) // Spitze
        ..close();
      canvas.drawPath(pfad, pfeilPaint);
    }
  }

  /// Zeichnet eine Wand: horizontale Linie mit Lücke in der Mitte
  void _zeichneWand(Canvas canvas) {
    final screenBreite = size.x;
    final lueckeBreite = 90.0;
    final wandBreite = (screenBreite - lueckeBreite) / 2;
    final lueckeStart = wandBreite;

    final wandFarbe = const Color(0xFF3A7BD5);
    final glowFarbe = const Color(0xFF5B9BD5).withValues(alpha: 0.4);

    // Glow hinter der Wand
    canvas.drawRect(
      Rect.fromLTWH(0, -4, wandBreite, 26),
      Paint()
        ..color = glowFarbe
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRect(
      Rect.fromLTWH(lueckeStart + lueckeBreite, -4, wandBreite, 26),
      Paint()
        ..color = glowFarbe
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Linke Wandhälfte
    canvas.drawRect(
      Rect.fromLTWH(0, 0, wandBreite, 18),
      Paint()..color = wandFarbe,
    );

    // Rechte Wandhälfte
    canvas.drawRect(
      Rect.fromLTWH(lueckeStart + lueckeBreite, 0, wandBreite, 18),
      Paint()..color = wandFarbe,
    );

    // Leuchtende Randlinien
    final randPaint = Paint()
      ..color = const Color(0xFF7BBBFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(0, 0), Offset(wandBreite, 0), randPaint);
    canvas.drawLine(
      Offset(lueckeStart + lueckeBreite, 0),
      Offset(screenBreite, 0),
      randPaint,
    );

    // Lücken-Markierungen (Hinweispfeile)
    final hinweisfarbe =
        const Color(0xFF00FF88).withValues(alpha: 0.8);
    final hinweisPaint = Paint()
      ..color = hinweisfarbe
      ..style = PaintingStyle.fill;
    final lueckeMitte = lueckeStart + lueckeBreite / 2;
    final pfad = Path()
      ..moveTo(lueckeMitte - 12, 18)
      ..lineTo(lueckeMitte + 12, 18)
      ..lineTo(lueckeMitte, 4)
      ..close();
    canvas.drawPath(pfad, hinweisPaint);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HindernisGenerator – erstellt Hindernisse periodisch
// ─────────────────────────────────────────────────────────────────────────────

/// Generiert periodisch neue Hindernisse und fügt sie dem Spiel hinzu.
///
/// Passt die Generierungsrate und den Typ abhängig von der aktuellen
/// Spielergeschwindigkeit und Distanz an.
class HindernisGenerator extends Component with HasGameRef {
  // Zeitintervall zwischen neuen Hindernissen (Sekunden)
  double _timer = 0.0;
  double _intervall = 2.2;

  /// Aktuelle Scrollgeschwindigkeit (wird von außen aktualisiert)
  double scrollGeschwindigkeit;

  /// Aktuelle Spielerdistanz (beeinflusst Schwierigskeitsgrad)
  double distanz;

  final math.Random _zufall = math.Random();

  HindernisGenerator({
    this.scrollGeschwindigkeit = 150.0,
    this.distanz = 0.0,
  });

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    // Intervall nimmt mit Distanz ab (Schwierigkeit steigt)
    _intervall = (2.2 - distanz / 800.0).clamp(0.7, 2.2);

    if (_timer >= _intervall) {
      _timer = 0.0;
      _hindernisErstellen();
    }
  }

  void _hindernisErstellen() {
    final screenHoehe = gameRef.size.y;
    final screenBreite = gameRef.size.x;

    // Wandzone oben/unten (20% der Bildschirmhöhe)
    final spielbereichOben = screenHoehe * 0.2;
    final spielbereichUnten = screenHoehe * 0.8;
    final spielbereichMitte = spielbereichOben +
        _zufall.nextDouble() * (spielbereichUnten - spielbereichOben);

    // Hindernistyp zufällig wählen (mit Gewichtung)
    final typWert = _zufall.nextDouble();
    final HindernisTyp typ;
    if (distanz < 200) {
      // Zu Beginn: nur einfache Hindernisse
      typ = typWert < 0.6 ? HindernisTyp.debris : HindernisTyp.zelle;
    } else if (distanz < 400) {
      // Mittlere Distanz: Strömungen dazukommen
      if (typWert < 0.3) {
        typ = HindernisTyp.debris;
      } else if (typWert < 0.6) {
        typ = HindernisTyp.zelle;
      } else {
        typ = HindernisTyp.stroemung;
      }
    } else {
      // Spätes Spiel: alle Typen möglich
      if (typWert < 0.25) {
        typ = HindernisTyp.debris;
      } else if (typWert < 0.5) {
        typ = HindernisTyp.zelle;
      } else if (typWert < 0.75) {
        typ = HindernisTyp.stroemung;
      } else {
        typ = HindernisTyp.wand;
      }
    }

    // Position rechts außerhalb des Bildschirms
    final startX = screenBreite + 80;
    final startY = typ == HindernisTyp.wand
        ? screenHoehe / 2 // Wand immer in der Mitte vertikal
        : spielbereichMitte;

    // Strömungsrichtung zufällig wählen
    final stroemungsRichtung = _zufall.nextBool() ? 1.0 : -1.0;

    // Für Wände: volle Bildschirmbreite
    final hindernis = Hindernis(
      position: Vector2(startX, startY),
      typ: typ,
      scrollGeschwindigkeit: scrollGeschwindigkeit,
      stroemungsRichtung: stroemungsRichtung,
    );

    // Bei Wandtyp: Breite auf Bildschirmbreite setzen
    if (typ == HindernisTyp.wand) {
      hindernis.size = Vector2(screenBreite, 18);
    }

    gameRef.add(hindernis);
  }
}
