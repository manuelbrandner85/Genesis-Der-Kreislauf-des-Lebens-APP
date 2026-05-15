// power_up.dart
// Power-Up-Komponenten für das Spermium-Rennen.
// Fünf verschiedene Typen mit visuellen Effekten und Spielmechaniken.

import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PowerUpTyp – Enum der verfügbaren Power-Up-Arten
// ─────────────────────────────────────────────────────────────────────────────

/// Die fünf Power-Up-Typen mit ihren Spielauswirkungen.
enum PowerUpTyp {
  /// Roter Kreis – kraftPowerUps++, kurzzeitig schneller (2 Sekunden)
  kraft,

  /// Blauer Kreis – intelligenzPowerUps++, zukünftige Hindernisse werden angezeigt
  intelligenz,

  /// Grüner Kreis – empathiePowerUps++, KI-Gegner in der Nähe werden verlangsamt
  empathie,

  /// Goldener Kreis – Unverwundbarkeit für 3 Sekunden
  schild,

  /// Weißer Kreis – Geschwindigkeitsboost für 2 Sekunden
  boost,
}

// ─────────────────────────────────────────────────────────────────────────────
// Erweiterung: Farb- und Textinformationen
// ─────────────────────────────────────────────────────────────────────────────

extension PowerUpTypErweiterung on PowerUpTyp {
  /// Primärfarbe des Power-Ups
  Color get farbe {
    switch (this) {
      case PowerUpTyp.kraft:
        return const Color(0xFFFF3333);
      case PowerUpTyp.intelligenz:
        return const Color(0xFF3399FF);
      case PowerUpTyp.empathie:
        return const Color(0xFF33FF66);
      case PowerUpTyp.schild:
        return const Color(0xFFFFD700);
      case PowerUpTyp.boost:
        return Colors.white;
    }
  }

  /// Glow-Farbe (etwas heller/transparenter)
  Color get glowFarbe {
    switch (this) {
      case PowerUpTyp.kraft:
        return const Color(0xFFFF6666);
      case PowerUpTyp.intelligenz:
        return const Color(0xFF66BBFF);
      case PowerUpTyp.empathie:
        return const Color(0xFF66FF99);
      case PowerUpTyp.schild:
        return const Color(0xFFFFE44D);
      case PowerUpTyp.boost:
        return const Color(0xFFCCEEFF);
    }
  }

  /// Kurzer Name für HUD-Anzeige
  String get kurzName {
    switch (this) {
      case PowerUpTyp.kraft:
        return 'KRAFT';
      case PowerUpTyp.intelligenz:
        return 'INTEL';
      case PowerUpTyp.empathie:
        return 'EMPA';
      case PowerUpTyp.schild:
        return 'SCHILD';
      case PowerUpTyp.boost:
        return 'BOOST';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PowerUp – Flame-Komponente
// ─────────────────────────────────────────────────────────────────────────────

/// Ein einsammelbares Power-Up im Spermium-Rennen.
///
/// Dreht sich langsam und pulsiert optisch. Wird von rechts nach links
/// gescrollt und beim Einsammeln durch den Spieler ausgelöst.
class PowerUp extends PositionComponent
    with HasPaint, CollisionCallbacks, HasGameRef {
  // ─────────────────────────────────────────────────────────────────────────
  // Eigenschaften
  // ─────────────────────────────────────────────────────────────────────────

  /// Typ des Power-Ups
  final PowerUpTyp typ;

  /// Aktuelle Scrollgeschwindigkeit
  double scrollGeschwindigkeit;

  // Interne Zustandsvariablen
  double _animationsTimer = 0.0;
  bool _eingesammelt = false;
  double _partikelTimer = 0.0;
  bool _zeigePartikel = false;
  final List<_PartikelPunkt> _partikel = [];

  PowerUp({
    required Vector2 position,
    required this.typ,
    required this.scrollGeschwindigkeit,
  }) : super(
          position: position,
          size: Vector2.all(32),
          anchor: Anchor.center,
        );

  // ─────────────────────────────────────────────────────────────────────────
  // Lebenszyklus
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Kreisförmige Hitbox
    add(CircleHitbox(radius: 16, anchor: Anchor.center));

    // Sanftes Pulsieren durch Skalierungseffekt
    add(
      ScaleEffect.by(
        Vector2.all(1.15),
        EffectController(
          duration: 0.8,
          reverseDuration: 0.8,
          infinite: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    if (_eingesammelt) {
      // Partikel animieren
      _partikelTimer += dt;
      for (final partikel in _partikel) {
        partikel.aktualisieren(dt);
      }
      if (_partikelTimer > 0.5) {
        removeFromParent();
      }
      return;
    }

    _animationsTimer += dt;

    // Von rechts nach links scrollen
    position.x -= scrollGeschwindigkeit * dt;

    // Entfernen wenn außerhalb des Bildschirms links
    if (position.x < -80) {
      removeFromParent();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final mitte = size / 2;
    final zentrum = Offset(mitte.x, mitte.y);
    final pulsation = 0.7 + 0.3 * math.sin(_animationsTimer * 3.5);

    if (_zeigePartikel) {
      // Partikel-Burst beim Einsammeln
      for (final partikel in _partikel) {
        canvas.drawCircle(
          Offset(mitte.x + partikel.x, mitte.y + partikel.y),
          partikel.groesse,
          Paint()
            ..color = typ.farbe.withValues(alpha: partikel.alpha)
            ..style = PaintingStyle.fill,
        );
      }
      return;
    }

    // Äußerer Glow-Ring
    canvas.drawCircle(
      zentrum,
      18,
      Paint()
        ..color = typ.glowFarbe.withValues(alpha: 0.35 * pulsation)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Hauptkörper
    canvas.drawCircle(
      zentrum,
      15,
      Paint()
        ..color = typ.farbe.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );

    // Innerer heller Kern
    canvas.drawCircle(
      Offset(zentrum.dx - 4, zentrum.dy - 4),
      5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );

    // Rand
    canvas.drawCircle(
      zentrum,
      15,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Typ-Symbol in der Mitte
    _zeichneTypSymbol(canvas, zentrum);
  }

  /// Zeichnet ein kleines Symbol das den Typ anzeigt
  void _zeichneTypSymbol(Canvas canvas, Offset zentrum) {
    switch (typ) {
      case PowerUpTyp.kraft:
        // Blitzpfeil
        final pfad = Path()
          ..moveTo(zentrum.dx + 2, zentrum.dy - 7)
          ..lineTo(zentrum.dx - 2, zentrum.dy - 1)
          ..lineTo(zentrum.dx + 1, zentrum.dy - 1)
          ..lineTo(zentrum.dx - 2, zentrum.dy + 7)
          ..lineTo(zentrum.dx + 3, zentrum.dy + 0)
          ..lineTo(zentrum.dx - 1, zentrum.dy + 0)
          ..close();
        canvas.drawPath(
          pfad,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.85)
            ..style = PaintingStyle.fill,
        );

      case PowerUpTyp.intelligenz:
        // Kleines Stern-Symbol
        for (int i = 0; i < 4; i++) {
          final winkel = i * math.pi / 2;
          canvas.drawLine(
            zentrum,
            Offset(
              zentrum.dx + math.cos(winkel) * 7,
              zentrum.dy + math.sin(winkel) * 7,
            ),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.85)
              ..strokeWidth = 2
              ..strokeCap = StrokeCap.round,
          );
        }
        canvas.drawCircle(
          zentrum,
          2.5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );

      case PowerUpTyp.empathie:
        // Herzform
        final pfad = Path();
        pfad.moveTo(zentrum.dx, zentrum.dy + 5);
        pfad.cubicTo(
          zentrum.dx - 8,
          zentrum.dy - 2,
          zentrum.dx - 8,
          zentrum.dy - 8,
          zentrum.dx,
          zentrum.dy - 4,
        );
        pfad.cubicTo(
          zentrum.dx + 8,
          zentrum.dy - 8,
          zentrum.dx + 8,
          zentrum.dy - 2,
          zentrum.dx,
          zentrum.dy + 5,
        );
        canvas.drawPath(
          pfad,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.85)
            ..style = PaintingStyle.fill,
        );

      case PowerUpTyp.schild:
        // Schildform
        final pfad = Path()
          ..moveTo(zentrum.dx, zentrum.dy - 7)
          ..lineTo(zentrum.dx + 6, zentrum.dy - 4)
          ..lineTo(zentrum.dx + 6, zentrum.dy + 1)
          ..lineTo(zentrum.dx, zentrum.dy + 7)
          ..lineTo(zentrum.dx - 6, zentrum.dy + 1)
          ..lineTo(zentrum.dx - 6, zentrum.dy - 4)
          ..close();
        canvas.drawPath(
          pfad,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );

      case PowerUpTyp.boost:
        // Doppelpfeil nach rechts
        final pfad1 = Path()
          ..moveTo(zentrum.dx - 5, zentrum.dy - 5)
          ..lineTo(zentrum.dx + 2, zentrum.dy)
          ..lineTo(zentrum.dx - 5, zentrum.dy + 5);
        final pfad2 = Path()
          ..moveTo(zentrum.dx + 1, zentrum.dy - 5)
          ..lineTo(zentrum.dx + 8, zentrum.dy)
          ..lineTo(zentrum.dx + 1, zentrum.dy + 5);
        final strichPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(pfad1, strichPaint);
        canvas.drawPath(pfad2, strichPaint);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Einsammeln
  // ─────────────────────────────────────────────────────────────────────────

  /// Wird aufgerufen wenn der Spieler dieses Power-Up berührt.
  ///
  /// [onEingesammelt] – Callback mit dem PowerUpTyp (vermeidet zirkulären Import).
  /// Löst den Partikel-Burst aus und entfernt das Power-Up.
  void einsammeln(void Function(PowerUpTyp typ) onEingesammelt) {
    if (_eingesammelt) return;
    _eingesammelt = true;

    // Effekt über Callback weitergeben
    onEingesammelt(typ);

    // Partikel-Burst erstellen (16 Partikel)
    final zufall = math.Random();
    for (int i = 0; i < 16; i++) {
      final winkel = zufall.nextDouble() * math.pi * 2;
      final geschwindigkeit = 30.0 + zufall.nextDouble() * 70.0;
      _partikel.add(_PartikelPunkt(
        xGeschwindigkeit: math.cos(winkel) * geschwindigkeit,
        yGeschwindigkeit: math.sin(winkel) * geschwindigkeit,
        groesse: 2.0 + zufall.nextDouble() * 3.0,
      ));
    }

    _zeigePartikel = true;

    // Skalierungseffekte entfernen
    removeWhere((c) => c is ScaleEffect);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Partikel-Hilfsobjekt für den Einsammel-Burst
// ─────────────────────────────────────────────────────────────────────────────

class _PartikelPunkt {
  double x = 0;
  double y = 0;
  double alpha = 1.0;
  final double groesse;
  final double xGeschwindigkeit;
  final double yGeschwindigkeit;

  _PartikelPunkt({
    required this.groesse,
    required this.xGeschwindigkeit,
    required this.yGeschwindigkeit,
  });

  void aktualisieren(double dt) {
    x += xGeschwindigkeit * dt;
    y += yGeschwindigkeit * dt;
    alpha = (alpha - dt * 2.0).clamp(0.0, 1.0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PowerUpSpawner – erzeugt Power-Ups periodisch
// ─────────────────────────────────────────────────────────────────────────────

/// Spawnt periodisch Power-Ups und fügt sie dem Spielfeld hinzu.
class PowerUpSpawner extends Component with HasGameRef {
  double _timer = 0.0;
  double _intervall = 3.5;
  double scrollGeschwindigkeit;
  double distanz;

  final math.Random _zufall = math.Random();

  PowerUpSpawner({
    this.scrollGeschwindigkeit = 150.0,
    this.distanz = 0.0,
  });

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    // Intervall leicht variieren
    _intervall = 3.0 + _zufall.nextDouble() * 2.0;

    if (_timer >= _intervall) {
      _timer = 0.0;
      _powerUpErstellen();
    }
  }

  void _powerUpErstellen() {
    final screenHoehe = gameRef.size.y;
    final screenBreite = gameRef.size.x;

    // Position innerhalb des Spielbereichs (ohne Wandzonen)
    final spielBereichOben = screenHoehe * 0.22;
    final spielBereichUnten = screenHoehe * 0.78;
    final yPos = spielBereichOben +
        _zufall.nextDouble() * (spielBereichUnten - spielBereichOben);

    // Typ zufällig wählen (gleichmäßige Verteilung der Typen)
    final typIndex = _zufall.nextInt(PowerUpTyp.values.length);
    final typ = PowerUpTyp.values[typIndex];

    gameRef.add(PowerUp(
      position: Vector2(screenBreite + 50, yPos),
      typ: typ,
      scrollGeschwindigkeit: scrollGeschwindigkeit,
    ));
  }
}
