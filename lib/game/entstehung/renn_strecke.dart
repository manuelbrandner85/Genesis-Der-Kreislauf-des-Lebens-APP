// renn_strecke.dart
// Tunnel-Hintergrund und Streckenverlauf für das Spermium-Rennen.
// Scrollender kosmischer Tunnel mit Tiefenwirkung und Route-Wahl-Overlay.

import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:genesis_kreislauf_des_lebens/game/entstehung/rennen_ergebnis.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RennStrecke – scrollender Tunnel-Hintergrund
// ─────────────────────────────────────────────────────────────────────────────

/// Zeichnet den scrollenden Tunnel-Hintergrund des Rennens.
///
/// Besteht aus:
/// - Wandstreifen oben und unten (20% der Höhe)
/// - Scrollenden Tiefenlinien (Tunneleffekt)
/// - Kosmischem Hintergrundgradienten
/// - Route-Wahl-Overlay bei Distanz 400
class RennStrecke extends Component with HasGameRef {
  // ─────────────────────────────────────────────────────────────────────────
  // Eigenschaften
  // ─────────────────────────────────────────────────────────────────────────

  /// Aktuelle Scrollgeschwindigkeit (wird von EntstehungsSpiel aktualisiert)
  double scrollGeschwindigkeit;

  /// Aktuelle Spielerdistanz (0–1000)
  double aktuelleDistanz;

  /// True wenn die Route bereits gewählt wurde
  bool routeGewaehlt = false;

  /// Die gewählte Route (wird nach Auswahl gesetzt)
  RoutenTyp? gewaehltRoute;

  /// Callback wenn eine Route gewählt wurde
  void Function(RoutenTyp route)? onRouteGewaehlt;

  // Interne Variablen
  double _scrollOffset = 0.0;
  double _tiefenLinienAbstand = 80.0;
  double _routeWahlTimer = 0.0;
  bool _routeWahlAktiv = false;
  double _routeWahlAlpha = 0.0; // Fade-in der Routenwahl

  // Partikel-System für den kosmischen Hintergrund
  final List<_HintergrundPartikel> _partikel = [];
  final math.Random _zufall = math.Random(9999);

  RennStrecke({
    this.scrollGeschwindigkeit = 150.0,
    this.aktuelleDistanz = 0.0,
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Lebenszyklus
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _erstellePartikel();
  }

  void _erstellePartikel() {
    // 80 Hintergrundpartikel für kosmisches Feeling
    for (int i = 0; i < 80; i++) {
      _partikel.add(_HintergrundPartikel(
        x: _zufall.nextDouble(),
        y: _zufall.nextDouble(),
        groesse: 0.8 + _zufall.nextDouble() * 1.5,
        helligkeit: 0.2 + _zufall.nextDouble() * 0.5,
        geschwindigkeit: 0.3 + _zufall.nextDouble() * 0.7,
      ));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    // Scroll-Offset vorantreiben
    _scrollOffset =
        (_scrollOffset + scrollGeschwindigkeit * dt) % _tiefenLinienAbstand;

    // Partikel bewegen
    for (final partikel in _partikel) {
      partikel.x -= partikel.geschwindigkeit * scrollGeschwindigkeit * dt /
          gameRef.size.x;
      if (partikel.x < -0.02) {
        partikel.x = 1.02;
        partikel.y = _zufall.nextDouble();
      }
    }

    // Route-Wahl aktivieren bei Distanz ~400
    if (!routeGewaehlt && aktuelleDistanz >= 400 && !_routeWahlAktiv) {
      _routeWahlAktiv = true;
      _routeWahlTimer = 0.0;
    }

    if (_routeWahlAktiv && !routeGewaehlt) {
      _routeWahlTimer += dt;
      // Fade-in der Route-Wahl (0.5 Sekunden)
      _routeWahlAlpha = (_routeWahlTimer / 0.5).clamp(0.0, 1.0);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final screenBreite = gameRef.size.x;
    final screenHoehe = gameRef.size.y;

    // 1. Kosmischer Hintergrund
    _zeichneHintergrund(canvas, screenBreite, screenHoehe);

    // 2. Hintergrundpartikel (Sterne)
    _zeichnePartikel(canvas, screenBreite, screenHoehe);

    // 3. Tiefenwirkung (scrollende Linien)
    _zeichneTiefenLinien(canvas, screenBreite, screenHoehe);

    // 4. Tunnelwände oben und unten
    _zeichneTunnelWaende(canvas, screenBreite, screenHoehe);

    // 5. Route-Wahl-Overlay (wenn aktiv)
    if (_routeWahlAktiv && !routeGewaehlt) {
      _zeichneRouteWahl(canvas, screenBreite, screenHoehe);
    }
  }

  void _zeichneHintergrund(
      Canvas canvas, double breite, double hoehe) {
    // Dunkelblau-lila Hintergrundgradient
    final farben = [
      const Color(0xFF050510),
      const Color(0xFF0A0818),
      const Color(0xFF0D0A20),
    ];

    // Einfacher Hintergrundverlauf
    final rect = Rect.fromLTWH(0, 0, breite, hoehe);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: farben,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill,
    );
  }

  void _zeichnePartikel(Canvas canvas, double breite, double hoehe) {
    for (final partikel in _partikel) {
      canvas.drawCircle(
        Offset(partikel.x * breite, partikel.y * hoehe),
        partikel.groesse,
        Paint()
          ..color = Colors.white.withValues(alpha: partikel.helligkeit)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _zeichneTiefenLinien(Canvas canvas, double breite, double hoehe) {
    // Scrollende vertikale Linien simulieren Tunnelbewegung
    final spielbereichOben = hoehe * 0.2;
    final spielbereichUnten = hoehe * 0.8;
    final spielbereichHoehe = spielbereichUnten - spielbereichOben;

    // Horizontale Tiefenlinien (von rechts nach links scrollend)
    int anzahlLinien = (breite / _tiefenLinienAbstand).ceil() + 2;

    for (int i = 0; i < anzahlLinien; i++) {
      final x = breite - (i * _tiefenLinienAbstand - _scrollOffset);
      if (x < -_tiefenLinienAbstand || x > breite + _tiefenLinienAbstand) {
        continue;
      }

      // Alpha variiert mit Abstand (Tiefenwirkung)
      final alpha = 0.06 + 0.04 * math.sin(i * 0.5);

      canvas.drawLine(
        Offset(x, spielbereichOben),
        Offset(x, spielbereichUnten),
        Paint()
          ..color = const Color(0xFF4A6FA5).withValues(alpha: alpha)
          ..strokeWidth = 0.8,
      );
    }

    // Perspektiv-Linien zur Mitte (Tunnel-Illusion)
    final midX = breite / 2;
    final midY = hoehe / 2;
    const anzahlPerspektivLinien = 8;

    for (int i = 0; i < anzahlPerspektivLinien; i++) {
      final t = i / anzahlPerspektivLinien.toDouble();
      final startX = t * breite;

      canvas.drawLine(
        Offset(startX, spielbereichOben),
        Offset(midX, midY),
        Paint()
          ..color =
              const Color(0xFF3A5FA5).withValues(alpha: 0.04)
          ..strokeWidth = 0.5,
      );

      canvas.drawLine(
        Offset(startX, spielbereichUnten),
        Offset(midX, midY),
        Paint()
          ..color =
              const Color(0xFF3A5FA5).withValues(alpha: 0.04)
          ..strokeWidth = 0.5,
      );
    }
  }

  void _zeichneTunnelWaende(Canvas canvas, double breite, double hoehe) {
    final wandHoehe = hoehe * 0.2;

    // Obere Wand
    final obenRect = Rect.fromLTWH(0, 0, breite, wandHoehe);
    canvas.drawRect(
      obenRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0F3C),
            Color(0xFF120A28),
          ],
        ).createShader(obenRect)
        ..style = PaintingStyle.fill,
    );

    // Untere Wand
    final untenRect = Rect.fromLTWH(0, hoehe - wandHoehe, breite, wandHoehe);
    canvas.drawRect(
      untenRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF1A0F3C),
            Color(0xFF120A28),
          ],
        ).createShader(untenRect)
        ..style = PaintingStyle.fill,
    );

    // Leuchtende Randlinien der Wände
    final randPaint = Paint()
      ..color = const Color(0xFF3D1F8C).withValues(alpha: 0.9)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, wandHoehe),
      Offset(breite, wandHoehe),
      randPaint,
    );
    canvas.drawLine(
      Offset(0, hoehe - wandHoehe),
      Offset(breite, hoehe - wandHoehe),
      randPaint,
    );

    // Innerer Glow der Wandränder
    canvas.drawLine(
      Offset(0, wandHoehe),
      Offset(breite, wandHoehe),
      Paint()
        ..color = const Color(0xFF6A40C0).withValues(alpha: 0.25)
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawLine(
      Offset(0, hoehe - wandHoehe),
      Offset(breite, hoehe - wandHoehe),
      Paint()
        ..color = const Color(0xFF6A40C0).withValues(alpha: 0.25)
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _zeichneRouteWahl(Canvas canvas, double breite, double hoehe) {
    final alpha = _routeWahlAlpha;
    final midY = hoehe / 2;
    final spielbereichOben = hoehe * 0.2;
    final spielbereichUnten = hoehe * 0.8;

    // Halb-transparentes Overlay
    canvas.drawRect(
      Rect.fromLTWH(0, spielbereichOben, breite, spielbereichUnten - spielbereichOben),
      Paint()..color = Colors.black.withValues(alpha: 0.35 * alpha),
    );

    // Drei Routen-Abzweigungen
    final routenDaten = [
      (
        RoutenTyp.kraft,
        'KRAFT',
        const Color(0xFFFF3333),
        'Stärke & Ausdauer',
        breite * 0.2,
      ),
      (
        RoutenTyp.intelligenz,
        'INTEL',
        const Color(0xFF3399FF),
        'Geist & Intuition',
        breite * 0.5,
      ),
      (
        RoutenTyp.empathie,
        'EMPATHIE',
        const Color(0xFF33FF66),
        'Herz & Kreativität',
        breite * 0.8,
      ),
    ];

    for (final (_, name, farbe, beschreibung, xPos) in routenDaten) {
      _zeichneRoutenOption(
        canvas,
        xPos,
        midY,
        farbe,
        name,
        beschreibung,
        alpha,
      );
    }

    // Titel
    _zeichneText(
      canvas,
      'WÄHLE DEINEN WEG',
      breite / 2,
      spielbereichOben + 30,
      const Color(0xFFFFD700),
      18.0,
      alpha,
    );
  }

  void _zeichneRoutenOption(
    Canvas canvas,
    double x,
    double y,
    Color farbe,
    String name,
    String beschreibung,
    double alpha,
  ) {
    // Leuchtendes Portal / Tor
    canvas.drawCircle(
      Offset(x, y),
      40,
      Paint()
        ..color = farbe.withValues(alpha: 0.15 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );

    canvas.drawCircle(
      Offset(x, y),
      36,
      Paint()
        ..color = farbe.withValues(alpha: 0.08 * alpha)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      Offset(x, y),
      36,
      Paint()
        ..color = farbe.withValues(alpha: 0.7 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Inneres Symbol (Pfeil nach vorne)
    final pfeilPaint = Paint()
      ..color = farbe.withValues(alpha: 0.9 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(
      Offset(x - 12, y),
      Offset(x + 12, y),
      pfeilPaint,
    );
    canvas.drawLine(
      Offset(x + 2, y - 10),
      Offset(x + 12, y),
      pfeilPaint,
    );
    canvas.drawLine(
      Offset(x + 2, y + 10),
      Offset(x + 12, y),
      pfeilPaint,
    );

    // Name unter dem Kreis
    _zeichneText(canvas, name, x, y + 52, farbe, 14.0, alpha);
    _zeichneText(
        canvas, beschreibung, x, y + 72, Colors.white, 10.0, alpha * 0.7);
  }

  void _zeichneText(
    Canvas canvas,
    String text,
    double x,
    double y,
    Color farbe,
    double schriftgroesse,
    double alpha,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: farbe.withValues(alpha: alpha),
          fontSize: schriftgroesse,
          fontFamily: 'Cinzel',
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Hilfsmethoden
  // ─────────────────────────────────────────────────────────────────────────

  /// Gibt zurück ob die Route-Wahl gerade angezeigt wird
  bool get routeWahlAktiv => _routeWahlAktiv && !routeGewaehlt;

  /// Verarbeitet eine Route-Wahl durch den Spieler
  void routeWaehlen(RoutenTyp route) {
    if (routeGewaehlt) return;
    routeGewaehlt = true;
    gewaehltRoute = route;
    onRouteGewaehlt?.call(route);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hintergrundpartikel-Hilfsobjekt
// ─────────────────────────────────────────────────────────────────────────────

class _HintergrundPartikel {
  double x;
  double y;
  final double groesse;
  final double helligkeit;
  final double geschwindigkeit; // Relative Scrollgeschwindigkeit (0–1)

  _HintergrundPartikel({
    required this.x,
    required this.y,
    required this.groesse,
    required this.helligkeit,
    required this.geschwindigkeit,
  });
}
