// spiel_hud.dart
// HUD-Overlay für das Spermium-Rennen.
// Zeigt Platzierung, Distanz-Fortschritt, Leben, aktive PowerUps
// und das Route-Wahl-Overlay an.

import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:genesis_kreislauf_des_lebens/game/entstehung/entstehungs_spiel.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/power_up.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/rennen_ergebnis.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SpielHUD – HUD-Overlay-Komponente
// ─────────────────────────────────────────────────────────────────────────────

/// Das Heads-Up-Display des Spermium-Rennens.
///
/// Wird als Flame-Komponente über dem Spielfeld gerendert.
/// Liest alle Informationen direkt vom [EntstehungsSpiel].
class SpielHUD extends Component with HasGameRef<EntstehungsSpiel> {
  // ─────────────────────────────────────────────────────────────────────────
  // Interne Hilfsvariablen
  // ─────────────────────────────────────────────────────────────────────────

  double _animationsTimer = 0.0;

  // ─────────────────────────────────────────────────────────────────────────
  // Update
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    _animationsTimer += dt;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final screenBreite = gameRef.size.x;
    final screenHoehe = gameRef.size.y;

    // 1. Platzierungsanzeige (oben links)
    _zeichnePlatzierung(canvas, screenBreite);

    // 2. Distanz-Fortschrittsbalken (oben rechts)
    _zeichneDistanzBalken(canvas, screenBreite);

    // 3. Leben-Anzeige (unten mitte)
    _zeichneLeben(canvas, screenBreite, screenHoehe);

    // 4. PowerUp-Icons wenn aktiv
    _zeichneAktivePowerUps(canvas, screenBreite, screenHoehe);

    // 5. Geschwindigkeitsanzeige (unten rechts)
    _zeichneGeschwindigkeit(canvas, screenBreite, screenHoehe);

    // 6. Route-Wahl-Hinweis wenn aktiv
    if (gameRef.rennStrecke.routeWahlAktiv) {
      _zeichneRouteWahlHinweis(canvas, screenBreite, screenHoehe);
    }

    // 7. Gewählte Route anzeigen (kurz nach Wahl)
    if (gameRef.rennStrecke.routeGewaehlt &&
        gameRef.rennStrecke.gewaehltRoute != null) {
      _zeichneGewaehltRoute(
        canvas,
        screenBreite,
        screenHoehe,
        gameRef.rennStrecke.gewaehltRoute!,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Zeichenmethoden
  // ─────────────────────────────────────────────────────────────────────────

  void _zeichnePlatzierung(Canvas canvas, double screenBreite) {
    const x = 16.0;
    const y = 48.0;
    final platz = gameRef.platzierung;
    final platzFarbe = platz == 1 ? const Color(0xFFFFD700) : Colors.white;

    // Halbtransparenter Hintergrund
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 36, 200, 36),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    _zeichneText(
      canvas,
      'PLATZ  $platz',
      x + 8,
      y - 2,
      platzFarbe,
      16.0,
    );

    // "von 1.000.000" in kleiner Schrift
    _zeichneText(
      canvas,
      'von 1.000.000',
      x + 8,
      y + 16,
      Colors.white.withValues(alpha: 0.55),
      10.0,
    );
  }

  void _zeichneDistanzBalken(Canvas canvas, double screenBreite) {
    const balkenwBreite = 180.0;
    const balkenhHoehe = 12.0;
    final x = screenBreite - balkenwBreite - 16;
    const y = 44.0;

    // Fortschritt 0–1
    final fortschritt = (gameRef.distanz / 1000.0).clamp(0.0, 1.0);

    // Hintergrund des Balkens
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, balkenwBreite, balkenhHoehe),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    // Füllstand
    if (fortschritt > 0) {
      final fuelFarbe = _distanzFarbe(fortschritt);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, balkenwBreite * fortschritt, balkenhHoehe),
          const Radius.circular(6),
        ),
        Paint()..color = fuelFarbe,
      );
    }

    // Rahmen
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, balkenwBreite, balkenhHoehe),
        const Radius.circular(6),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Distanzzahl
    _zeichneText(
      canvas,
      '${gameRef.distanz.toInt()} / 1000',
      x + balkenwBreite / 2,
      y + balkenhHoehe + 12,
      Colors.white.withValues(alpha: 0.7),
      10.0,
      zentriert: true,
    );
  }

  void _zeichneLeben(Canvas canvas, double screenBreite, double screenHoehe) {
    const lebenRadius = 10.0;
    const abstand = 26.0;
    final startX = screenBreite / 2 - (3 * abstand - abstand / 2) / 2;
    final y = screenHoehe - 40.0;

    for (int i = 0; i < 3; i++) {
      final x = startX + i * abstand;
      final hatLeben = i < gameRef.spieler.leben;
      final pulsation = hatLeben
          ? 0.85 + 0.15 * math.sin(_animationsTimer * 3.0 + i * 1.0)
          : 1.0;

      if (hatLeben) {
        // Volles Herz (aktives Leben)
        canvas.drawCircle(
          Offset(x, y),
          lebenRadius * pulsation,
          Paint()
            ..color = const Color(0xFFFF4466).withValues(alpha: 0.9)
            ..maskFilter =
                const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawCircle(
          Offset(x, y),
          (lebenRadius - 2) * pulsation,
          Paint()..color = const Color(0xFFFF2244),
        );
      } else {
        // Leeres Herz (verlorenes Leben)
        canvas.drawCircle(
          Offset(x, y),
          lebenRadius,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  void _zeichneAktivePowerUps(
      Canvas canvas, double screenBreite, double screenHoehe) {
    final aktivePowerUps = PowerUpTyp.values
        .where((typ) => gameRef.spieler.effektAktiv(typ))
        .toList();

    if (aktivePowerUps.isEmpty) return;

    const iconGroesse = 28.0;
    const abstand = 36.0;
    final startX = 16.0;
    final y = screenHoehe - 90.0;

    for (int i = 0; i < aktivePowerUps.length; i++) {
      final typ = aktivePowerUps[i];
      final x = startX + i * abstand;
      final verbleibend = gameRef.spieler.effektVerbleibend(typ);

      // Icon-Hintergrund
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, iconGroesse, iconGroesse),
          const Radius.circular(6),
        ),
        Paint()
          ..color = typ.farbe.withValues(alpha: 0.25),
      );

      // Icon-Rahmen
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, iconGroesse, iconGroesse),
          const Radius.circular(6),
        ),
        Paint()
          ..color = typ.farbe.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Typ-Kürzel
      _zeichneText(
        canvas,
        typ.kurzName[0],
        x + iconGroesse / 2,
        y + iconGroesse / 2 - 4,
        typ.farbe,
        12.0,
        zentriert: true,
      );

      // Verbleibende Zeit als kleiner Balken unten im Icon
      final fortschritt = verbleibend / 3.0; // Annahme max 3s
      canvas.drawRect(
        Rect.fromLTWH(
          x + 2,
          y + iconGroesse - 5,
          (iconGroesse - 4) * fortschritt.clamp(0.0, 1.0),
          3,
        ),
        Paint()..color = typ.farbe.withValues(alpha: 0.9),
      );
    }
  }

  void _zeichneGeschwindigkeit(
      Canvas canvas, double screenBreite, double screenHoehe) {
    final geschw = gameRef.geschwindigkeit.toInt();
    final x = screenBreite - 16.0;
    final y = screenHoehe - 45.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 80, y - 12, 78, 28),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );

    _zeichneText(
      canvas,
      '$geschw px/s',
      x - 40,
      y + 2,
      const Color(0xFF88AAFF).withValues(alpha: 0.8),
      11.0,
      zentriert: true,
    );
  }

  void _zeichneRouteWahlHinweis(
      Canvas canvas, double screenBreite, double screenHoehe) {
    final pulsation =
        0.7 + 0.3 * math.sin(_animationsTimer * 4.0);

    _zeichneText(
      canvas,
      'WÄHLE DEINEN WEG!',
      screenBreite / 2,
      screenHoehe * 0.15,
      const Color(0xFFFFD700).withValues(alpha: pulsation),
      20.0,
      zentriert: true,
    );

    _zeichneText(
      canvas,
      'Tippe Links / Mitte / Rechts',
      screenBreite / 2,
      screenHoehe * 0.15 + 28,
      Colors.white.withValues(alpha: pulsation * 0.7),
      12.0,
      zentriert: true,
    );
  }

  void _zeichneGewaehltRoute(
    Canvas canvas,
    double screenBreite,
    double screenHoehe,
    RoutenTyp route,
  ) {
    // Kurze Anzeige der gewählten Route (nur die ersten 3 Sekunden nach Wahl)
    final farbe = _routeFarbe(route);

    _zeichneText(
      canvas,
      'Route: ${route.anzeigeName.toUpperCase()}',
      screenBreite / 2,
      screenHoehe * 0.88,
      farbe.withValues(alpha: 0.85),
      13.0,
      zentriert: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Hilfsmethoden
  // ─────────────────────────────────────────────────────────────────────────

  void _zeichneText(
    Canvas canvas,
    String text,
    double x,
    double y,
    Color farbe,
    double schriftgroesse, {
    bool zentriert = false,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: farbe,
          fontSize: schriftgroesse,
          fontFamily: 'Cinzel',
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offsetX = zentriert ? x - textPainter.width / 2 : x;
    textPainter.paint(canvas, Offset(offsetX, y));
  }

  Color _distanzFarbe(double fortschritt) {
    if (fortschritt < 0.4) return const Color(0xFF4488FF);
    if (fortschritt < 0.7) return const Color(0xFF44AAFF);
    if (fortschritt < 0.9) return const Color(0xFFFFAA44);
    return const Color(0xFFFFD700);
  }

  Color _routeFarbe(RoutenTyp route) {
    switch (route) {
      case RoutenTyp.kraft:
        return const Color(0xFFFF3333);
      case RoutenTyp.intelligenz:
        return const Color(0xFF3399FF);
      case RoutenTyp.empathie:
        return const Color(0xFF33FF66);
    }
  }
}
