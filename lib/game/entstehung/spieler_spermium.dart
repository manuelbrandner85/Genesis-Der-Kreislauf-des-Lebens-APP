// spieler_spermium.dart
// Der Spieler-Charakter im Spermium-Rennen.
// Animiertes Spermium mit Kollisionsbehandlung, Power-Up-Effekten und
// visuellen Zustandsanzeigen (Blinken bei Treffer, Schild-Aura etc.).

import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:genesis_kreislauf_des_lebens/game/entstehung/hindernis.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/power_up.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SpielCharakter – Spieler-Spermium
// ─────────────────────────────────────────────────────────────────────────────

/// Das vom Spieler gesteuerte Spermium.
///
/// Reagiert auf Tipp-Eingaben (oben/unten), sammelt Power-Ups auf und
/// wird bei Hindernisberührung kurz unverwundbar (Blink-Effekt).
class SpielCharakter extends PositionComponent
    with HasPaint, CollisionCallbacks, HasGameRef {
  // ─────────────────────────────────────────────────────────────────────────
  // Bewegungs-Eigenschaften
  // ─────────────────────────────────────────────────────────────────────────

  /// Ziel-Y-Position im normalisierten Raum (-1 bis 1)
  double zielY = 0.0;

  /// Aktuelle Y-Position im normalisierten Raum
  double aktuelleY = 0.0;

  /// Schwimmgeschwindigkeit: wie schnell zum Ziel interpoliert wird
  double schwimmGeschwindigkeit = 3.5;

  // ─────────────────────────────────────────────────────────────────────────
  // Zustandsvariablen
  // ─────────────────────────────────────────────────────────────────────────

  /// Aktuelle Leben (0–3)
  int leben = 3;

  /// True wenn gerade unverwundbar (nach Treffer)
  bool istUnverwundbar = false;

  /// Aktive Effekte mit verbleibender Zeit
  final Map<PowerUpTyp, double> _aktiveEffekte = {};

  // Blink-Zustand nach Treffer
  double _unverwundbarTimer = 0.0;
  static const double _unverwundbarDauer = 2.0; // Sekunden
  bool _sichtbar = true;
  double _blinkTimer = 0.0;

  // Animations-Timer für Schweif
  double _animationsTimer = 0.0;

  // Schild-Aura-Pulsation
  double _schildPuls = 0.0;

  // Callback wenn Leben verloren → von EntstehungsSpiel gesetzt
  void Function(int verbleibendeLeben)? onLebenVerloren;

  // Callback wenn alle Leben verbraucht
  void Function()? onSpielVorbei;

  // Callback wenn PowerUp eingesammelt → zur Attributzählung im Hauptspiel
  void Function(PowerUpTyp typ)? onPowerUpEingesammelt;

  // ─────────────────────────────────────────────────────────────────────────
  // Lebenszyklus
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2(22, 22);
    anchor = Anchor.center;

    // Kreisförmige Hitbox (etwas kleiner als visuell, für faireres Gameplay)
    add(CircleHitbox(
      radius: 9,
      anchor: Anchor.center,
      collisionType: CollisionType.active,
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Steuerung
  // ─────────────────────────────────────────────────────────────────────────

  /// Bewegt das Spermium nach oben
  void bewegeNachOben() {
    zielY = (zielY - 0.3).clamp(-0.9, 0.9);
  }

  /// Bewegt das Spermium nach unten
  void bewegeNachUnten() {
    zielY = (zielY + 0.3).clamp(-0.9, 0.9);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Power-Up-Effekte
  // ─────────────────────────────────────────────────────────────────────────

  /// Wendet einen Power-Up-Effekt auf den Spieler an.
  /// Wird als Callback von [PowerUp.einsammeln] aufgerufen.
  void powerUpAnwenden(PowerUpTyp typ) {
    // Hauptspiel über eingesammelten PowerUp informieren
    onPowerUpEingesammelt?.call(typ);

    switch (typ) {
      case PowerUpTyp.kraft:
        // 2 Sekunden Geschwindigkeitsboost (wird im Hauptspiel verarbeitet)
        _aktiveEffekte[PowerUpTyp.kraft] = 2.0;
      case PowerUpTyp.intelligenz:
        // 4 Sekunden Hindernisvorschau
        _aktiveEffekte[PowerUpTyp.intelligenz] = 4.0;
      case PowerUpTyp.empathie:
        // 3 Sekunden Empathie-Aura
        _aktiveEffekte[PowerUpTyp.empathie] = 3.0;
      case PowerUpTyp.schild:
        // 3 Sekunden Unverwundbarkeit
        _aktiveEffekte[PowerUpTyp.schild] = 3.0;
        istUnverwundbar = true;
      case PowerUpTyp.boost:
        // 2 Sekunden voller Boost
        _aktiveEffekte[PowerUpTyp.boost] = 2.0;
    }
  }

  /// Prüft ob ein bestimmter Effekt gerade aktiv ist
  bool effektAktiv(PowerUpTyp typ) {
    return (_aktiveEffekte[typ] ?? 0.0) > 0.0;
  }

  /// Gibt die verbleibende Zeit eines Effekts zurück (0 wenn inaktiv)
  double effektVerbleibend(PowerUpTyp typ) {
    return _aktiveEffekte[typ] ?? 0.0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update-Schleife
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    _animationsTimer += dt;

    // Y-Position sanft interpolieren (lerp zur Zielposition)
    aktuelleY +=
        (zielY - aktuelleY) * (1.0 - math.exp(-schwimmGeschwindigkeit * dt));

    // Bildschirmposition aktualisieren
    _aktualisiereSpielPosition();

    // Unverwundbarkeits-Timer
    if (istUnverwundbar) {
      _unverwundbarTimer += dt;
      _blinkTimer += dt;

      // Blinken: alle 0.1s Sichtbarkeit wechseln
      if (_blinkTimer >= 0.1) {
        _blinkTimer = 0.0;
        _sichtbar = !_sichtbar;
      }

      // Unverwundbarkeit beenden (außer wenn Schild-PowerUp aktiv)
      if (_unverwundbarTimer >= _unverwundbarDauer &&
          !effektAktiv(PowerUpTyp.schild)) {
        istUnverwundbar = false;
        _unverwundbarTimer = 0.0;
        _sichtbar = true;
      }
    }

    // Aktive Effekte herunterzählen
    final abgelaufeneEffekte = <PowerUpTyp>[];
    for (final eintrag in _aktiveEffekte.entries) {
      final neueZeit = eintrag.value - dt;
      if (neueZeit <= 0.0) {
        abgelaufeneEffekte.add(eintrag.key);
        // Schild-PowerUp: Unverwundbarkeit deaktivieren
        if (eintrag.key == PowerUpTyp.schild) {
          istUnverwundbar = false;
          _sichtbar = true;
        }
      } else {
        _aktiveEffekte[eintrag.key] = neueZeit;
      }
    }
    for (final abgelaufen in abgelaufeneEffekte) {
      _aktiveEffekte.remove(abgelaufen);
    }

    // Schild-Pulsation
    _schildPuls += dt * 4.0;
  }

  /// Berechnet die Bildschirmposition aus der normalisierten Y-Koordinate.
  void _aktualisiereSpielPosition() {
    final screenHoehe = gameRef.size.y;
    final spielBereichOben = screenHoehe * 0.2;
    final spielBereichHoehe = screenHoehe * 0.6;

    // Normalisierte Y (-1 bis 1) → Bildschirmkoordinate
    position.y =
        spielBereichOben + (aktuelleY + 1.0) / 2.0 * spielBereichHoehe;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Kollisions-Behandlung
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Hindernis) {
      _hindernisGetroffen(other);
    } else if (other is PowerUp) {
      // Callback-Variante: vermeidet zirkulären Import
      other.einsammeln(powerUpAnwenden);
    }
  }

  void _hindernisGetroffen(Hindernis hindernis) {
    // Strömung: Spieler wird seitlich abgelenkt, kein Schaden
    if (hindernis.typ == HindernisTyp.stroemung) {
      final ablenkung = hindernis.stroemungsRichtung * 0.25;
      zielY = (zielY + ablenkung).clamp(-0.9, 0.9);
      return;
    }

    // Unverwundbar: kein Schaden
    if (istUnverwundbar) return;

    // Leben abziehen
    leben--;
    istUnverwundbar = true;
    _unverwundbarTimer = 0.0;
    _blinkTimer = 0.0;

    onLebenVerloren?.call(leben);

    if (leben <= 0) {
      onSpielVorbei?.call();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Nicht zeichnen wenn gerade geblinkt wird
    if (!_sichtbar) return;

    final mitte = size / 2;
    final zentrum = Offset(mitte.x, mitte.y);

    // Schild-Aura wenn aktiv
    if (effektAktiv(PowerUpTyp.schild)) {
      final schildAlpha =
          (0.4 + 0.2 * math.sin(_schildPuls)).clamp(0.0, 1.0);
      canvas.drawCircle(
        zentrum,
        16,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: schildAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        zentrum,
        18,
        Paint()
          ..color =
              const Color(0xFFFFD700).withValues(alpha: schildAlpha * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Kraft-Aura (rötlicher Glow)
    if (effektAktiv(PowerUpTyp.kraft) || effektAktiv(PowerUpTyp.boost)) {
      canvas.drawCircle(
        zentrum,
        13,
        Paint()
          ..color = const Color(0xFFFF6666).withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // Schweif zeichnen (sinusförmig, zeigt Richtung der Bewegung)
    _zeichneSchweif(canvas, zentrum);

    // Haupt-Glow
    canvas.drawCircle(
      zentrum,
      13,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Hauptkörper (weißer Kreis mit leichtem Glow)
    canvas.drawCircle(
      zentrum,
      10,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.92)
        ..style = PaintingStyle.fill,
    );

    // Akzent-Highlight (Tiefenwirkung)
    canvas.drawCircle(
      Offset(zentrum.dx - 3, zentrum.dy - 3),
      3.5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );

    // Kern-Punkt (Zellkern)
    canvas.drawCircle(
      zentrum,
      4,
      Paint()
        ..color = const Color(0xFFD0D0FF).withValues(alpha: 0.8)
        ..style = PaintingStyle.fill,
    );
  }

  void _zeichneSchweif(Canvas canvas, Offset zentrum) {
    // Schweif-Segmente mit abnehmender Deckkraft
    final schweifLaenge = 20.0;
    const segmente = 5;

    for (int i = 0; i < segmente; i++) {
      final t = (i + 1) / segmente.toDouble();
      final schwingung = math.sin(_animationsTimer * 9.0 + t * 3.0) * 4.0;

      final startX = zentrum.dx - 8;
      final endX = zentrum.dx - 8 - schweifLaenge * t;
      final endY = zentrum.dy + schwingung;

      canvas.drawLine(
        i == 0
            ? Offset(startX, zentrum.dy)
            : Offset(
                zentrum.dx - 8 - schweifLaenge * ((i - 1) / segmente),
                zentrum.dy +
                    math.sin(
                          _animationsTimer * 9.0 +
                              ((i - 1) / segmente) * 3.0,
                        ) *
                        4.0,
              ),
        Offset(endX, endY),
        Paint()
          ..color = Colors.white
              .withValues(alpha: (0.7 - t * 0.6).clamp(0.0, 1.0))
          ..strokeWidth = (2.5 - t * 2.0).clamp(0.3, 2.5)
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}
