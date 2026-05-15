// emotions_wetter_widget.dart
// Emotions-Wetter-Overlay für GENESIS: Der Kreislauf des Lebens.
// Zeigt halbtransparente Partikel-Overlays basierend auf dem aktuellen
// EmotionsWetterTyp des Charakters, ohne externe Shader-Pakete.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/emotions_wetter_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Datenmodell: einzelnes Partikel
// ─────────────────────────────────────────────────────────────────────────────

/// Repräsentiert ein einzelnes Partikel im Emotions-Wetter-System.
class _Partikel {
  double x;       // Aktuelle X-Position (0.0 – 1.0, relativ zu Größe)
  double y;       // Aktuelle Y-Position (0.0 – 1.0 + Überlauffläche)
  final double groesse;      // Partikelgröße in Pixeln
  final double geschwindigkeit; // Fallgeschwindigkeit (relativ)
  final double horizontalDrift; // Horizontale Drift-Geschwindigkeit
  double opazitaet;   // Aktuelle Transparenz (0.0 – 1.0)
  final double phasewert;    // Zufällige Anfangsphase für individuelle Animation
  final bool istBlitz;        // Nur bei Gewitter: Blitz-Partikel
  double blitzTimer;          // Countdown bis zum nächsten Blitz (Sekunden)

  _Partikel({
    required this.x,
    required this.y,
    required this.groesse,
    required this.geschwindigkeit,
    required this.horizontalDrift,
    required this.opazitaet,
    required this.phasewert,
    this.istBlitz = false,
    this.blitzTimer = 0,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// EmotionsWetterWidget
// ─────────────────────────────────────────────────────────────────────────────

/// Halbtransparentes Partikel-Overlay, das über dem Spielinhalt liegt.
///
/// Je nach [EmotionsWetterTyp] werden unterschiedliche Partikel animiert:
/// - [EmotionsWetterTyp.sonnenschein]: goldene Partikel schweben langsam
/// - [EmotionsWetterTyp.regen]: blaue Striche fallen schnell
/// - [EmotionsWetterTyp.gewitter]: dunkle Atmosphäre mit gelegentlichen Blitzen
/// - [EmotionsWetterTyp.kosmisch]: violette Sterne-Partikel
/// - [EmotionsWetterTyp.warmesLeuchten]: rosa-goldene Herzchen-Partikel
/// - [EmotionsWetterTyp.nebel]: weiße Partikel driften langsam
/// - [EmotionsWetterTyp.sturm]: schnelle dunkle Partikel
/// - [EmotionsWetterTyp.klar]: sehr wenige, helle Partikel
///
/// Beispiel:
/// ```dart
/// Stack(
///   children: [
///     SpielInhalt(),
///     EmotionsWetterWidget(wetterModell: aktuellesWetter),
///   ],
/// )
/// ```
class EmotionsWetterWidget extends StatefulWidget {
  /// Das aktuelle Emotions-Wetter-Modell.
  final EmotionsWetterModel wetterModell;

  /// Gibt an, ob das Overlay aktiv ist.
  final bool istAktiv;

  const EmotionsWetterWidget({
    super.key,
    required this.wetterModell,
    this.istAktiv = true,
  });

  @override
  State<EmotionsWetterWidget> createState() => _EmotionsWetterWidgetState();
}

class _EmotionsWetterWidgetState extends State<EmotionsWetterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Partikel> _partikel;
  final math.Random _rng = math.Random();

  // Zeitstempel des letzten Frame für Delta-Time-Berechnung
  double _letzteZeit = 0;

  @override
  void initState() {
    super.initState();
    _partikel = _erstellePartikel();

    _controller = AnimationController(
      vsync: this,
      // 30 FPS für Partikelanimation (ausreichend für diesen Effekt)
      duration: const Duration(hours: 1),
    )..addListener(_aktualisierePartikel);

    if (widget.istAktiv) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(EmotionsWetterWidget old) {
    super.didUpdateWidget(old);
    // Partikel neu generieren wenn sich der Wettertyp ändert
    if (old.wetterModell.typ != widget.wetterModell.typ ||
        old.wetterModell.intensitaet != widget.wetterModell.intensitaet) {
      _partikel = _erstellePartikel();
    }
    // Animation starten/stoppen je nach isAktiv
    if (widget.istAktiv && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.istAktiv && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Partikel-Erzeugung ──────────────────────────────────────────────────────

  /// Erstellt die Partikel basierend auf dem aktuellen Wettertyp.
  List<_Partikel> _erstellePartikel() {
    final typ = widget.wetterModell.typ;
    final intensitaet = widget.wetterModell.intensitaet;

    // Anzahl Partikel je nach Intensität und Typ
    final anzahl = _partikelAnzahl(typ, intensitaet);

    return List.generate(anzahl, (i) {
      return _erstelleEinzelPartikel(typ, intensitaet, i);
    });
  }

  /// Berechnet die optimale Partikelanzahl.
  int _partikelAnzahl(EmotionsWetterTyp typ, double intensitaet) {
    switch (typ) {
      case EmotionsWetterTyp.sonnenschein:
        return (20 * intensitaet).round().clamp(5, 25);
      case EmotionsWetterTyp.regen:
        return (80 * intensitaet).round().clamp(20, 100);
      case EmotionsWetterTyp.gewitter:
        return (50 * intensitaet).round().clamp(15, 60) + 2; // +2 für Blitze
      case EmotionsWetterTyp.warmesLeuchten:
        return (15 * intensitaet).round().clamp(5, 20);
      case EmotionsWetterTyp.kosmisch:
        return (30 * intensitaet).round().clamp(10, 40);
      case EmotionsWetterTyp.nebel:
        return (25 * intensitaet).round().clamp(8, 30);
      case EmotionsWetterTyp.sturm:
        return (100 * intensitaet).round().clamp(30, 120);
      case EmotionsWetterTyp.klar:
        return 8;
    }
  }

  /// Erstellt ein einzelnes Partikel mit typ-spezifischen Eigenschaften.
  _Partikel _erstelleEinzelPartikel(
      EmotionsWetterTyp typ, double intensitaet, int index) {
    switch (typ) {
      // Sonnenschein: goldene, langsam schwebende Punkte
      case EmotionsWetterTyp.sonnenschein:
        return _Partikel(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          groesse: 2.0 + _rng.nextDouble() * 3.0,
          geschwindigkeit: 0.03 + _rng.nextDouble() * 0.04,
          horizontalDrift: (_rng.nextDouble() - 0.5) * 0.02,
          opazitaet: 0.4 + _rng.nextDouble() * 0.5,
          phasewert: _rng.nextDouble() * math.pi * 2,
        );

      // Regen: blaue dünne Striche, schnell fallend
      case EmotionsWetterTyp.regen:
        return _Partikel(
          x: _rng.nextDouble(),
          y: _rng.nextDouble() * 1.2 - 0.2,
          groesse: 1.0 + _rng.nextDouble() * 0.5,
          geschwindigkeit: 0.3 + _rng.nextDouble() * 0.4,
          horizontalDrift: widget.wetterModell.windStaerke * 0.04,
          opazitaet: 0.3 + _rng.nextDouble() * 0.4,
          phasewert: _rng.nextDouble() * math.pi * 2,
        );

      // Gewitter: dunkle Partikel + Blitze
      case EmotionsWetterTyp.gewitter:
        final istBlitz = index < 2; // Ersten 2 Partikel als Blitze
        return _Partikel(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          groesse: istBlitz ? 3.0 : 1.5 + _rng.nextDouble() * 1.0,
          geschwindigkeit: istBlitz ? 0 : 0.2 + _rng.nextDouble() * 0.3,
          horizontalDrift: widget.wetterModell.windStaerke * 0.05,
          opazitaet: istBlitz ? 0.0 : 0.2 + _rng.nextDouble() * 0.3,
          phasewert: _rng.nextDouble() * math.pi * 2,
          istBlitz: istBlitz,
          blitzTimer: _rng.nextDouble() * 3 + 2, // 2–5 Sekunden bis Blitz
        );

      // Warmes Leuchten: rosa-goldene Partikel
      case EmotionsWetterTyp.warmesLeuchten:
        return _Partikel(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          groesse: 2.5 + _rng.nextDouble() * 4.0,
          geschwindigkeit: 0.015 + _rng.nextDouble() * 0.025,
          horizontalDrift: (_rng.nextDouble() - 0.5) * 0.015,
          opazitaet: 0.3 + _rng.nextDouble() * 0.4,
          phasewert: _rng.nextDouble() * math.pi * 2,
        );

      // Kosmisch: violette Sterne-Partikel
      case EmotionsWetterTyp.kosmisch:
        return _Partikel(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          groesse: 1.0 + _rng.nextDouble() * 3.5,
          geschwindigkeit: 0.008 + _rng.nextDouble() * 0.015,
          horizontalDrift: (_rng.nextDouble() - 0.5) * 0.005,
          opazitaet: 0.2 + _rng.nextDouble() * 0.6,
          phasewert: _rng.nextDouble() * math.pi * 2,
        );

      // Nebel: große, sehr transparente Partikel
      case EmotionsWetterTyp.nebel:
        return _Partikel(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          groesse: 8.0 + _rng.nextDouble() * 12.0,
          geschwindigkeit: 0.005 + _rng.nextDouble() * 0.01,
          horizontalDrift: (_rng.nextDouble() - 0.5) * 0.008,
          opazitaet: 0.05 + _rng.nextDouble() * 0.12,
          phasewert: _rng.nextDouble() * math.pi * 2,
        );

      // Sturm: schnelle, mittlere dunkle Partikel
      case EmotionsWetterTyp.sturm:
        return _Partikel(
          x: _rng.nextDouble(),
          y: _rng.nextDouble() * 1.2 - 0.2,
          groesse: 1.5 + _rng.nextDouble() * 2.0,
          geschwindigkeit: 0.4 + _rng.nextDouble() * 0.5,
          horizontalDrift: widget.wetterModell.windStaerke * 0.08,
          opazitaet: 0.25 + _rng.nextDouble() * 0.35,
          phasewert: _rng.nextDouble() * math.pi * 2,
        );

      // Klar: wenige, helle Partikel
      case EmotionsWetterTyp.klar:
        return _Partikel(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          groesse: 1.5 + _rng.nextDouble() * 2.0,
          geschwindigkeit: 0.01 + _rng.nextDouble() * 0.015,
          horizontalDrift: (_rng.nextDouble() - 0.5) * 0.005,
          opazitaet: 0.15 + _rng.nextDouble() * 0.25,
          phasewert: _rng.nextDouble() * math.pi * 2,
        );
    }
  }

  // ── Partikel-Aktualisierung ─────────────────────────────────────────────────

  void _aktualisierePartikel() {
    final jetzt = _controller.value * 3600; // In Sekunden umrechnen
    final delta = jetzt - _letzteZeit;
    _letzteZeit = jetzt;

    // Delta-Time für flüssige Animation
    if (delta <= 0 || delta > 0.1) return;

    setState(() {
      for (final partikel in _partikel) {
        if (partikel.istBlitz) {
          _aktualisiereBlitz(partikel, delta);
          continue;
        }
        _bewegePartikel(partikel, delta);
      }
    });
  }

  /// Bewegt ein normales Partikel und setzt es bei Bildschirmende zurück.
  void _bewegePartikel(_Partikel partikel, double delta) {
    partikel.y += partikel.geschwindigkeit * delta;
    partikel.x += partikel.horizontalDrift * delta;

    // Horizontale Begrenzung
    if (partikel.x < -0.05) partikel.x = 1.05;
    if (partikel.x > 1.05) partikel.x = -0.05;

    // Zurück nach oben wenn unten herausgefallen
    if (partikel.y > 1.1) {
      partikel.y = -0.1;
      partikel.x = _rng.nextDouble();
    }

    // Flimmernde Opazität für kosmische/sonnenschein-Partikel
    final typ = widget.wetterModell.typ;
    if (typ == EmotionsWetterTyp.kosmisch ||
        typ == EmotionsWetterTyp.sonnenschein ||
        typ == EmotionsWetterTyp.klar) {
      final neuePhase = (partikel.phasewert + delta * 1.5) % (math.pi * 2);
      partikel.opazitaet =
          (0.2 + 0.5 * ((math.sin(neuePhase) + 1) / 2)).clamp(0.1, 1.0);
    }
  }

  /// Steuert die Blitz-Animation für Gewitter.
  void _aktualisiereBlitz(_Partikel partikel, double delta) {
    partikel.blitzTimer -= delta;

    if (partikel.blitzTimer <= 0) {
      // Blitz aufleuchten lassen
      partikel.opazitaet = 0.85;
      partikel.x = _rng.nextDouble();
      // Nächsten Blitz in 3–7 Sekunden planen
      partikel.blitzTimer = 3.0 + _rng.nextDouble() * 4.0;
    } else {
      // Blitz langsam verblassen
      partikel.opazitaet = (partikel.opazitaet - delta * 3.0).clamp(0.0, 1.0);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!widget.istAktiv) return const SizedBox.shrink();

    return IgnorePointer(
      // Overlay soll keine Touch-Events blockieren
      child: CustomPaint(
        painter: _WetterPainter(
          partikel: _partikel,
          wetterModell: widget.wetterModell,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter: WetterPainter
// ─────────────────────────────────────────────────────────────────────────────

/// Zeichnet alle Partikel auf den Canvas.
class _WetterPainter extends CustomPainter {
  final List<_Partikel> partikel;
  final EmotionsWetterModel wetterModell;

  _WetterPainter({
    required this.partikel,
    required this.wetterModell,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Atmosphärisches Hintergrund-Overlay (sehr subtil)
    _zeichneAtmosphaere(canvas, size);

    // Alle Partikel zeichnen
    for (final p in partikel) {
      _zeichnePartikel(canvas, size, p);
    }
  }

  /// Zeichnet eine leichte atmosphärische Einfärbung.
  void _zeichneAtmosphaere(Canvas canvas, Size size) {
    final intensitaet = wetterModell.intensitaet;

    Color atmoFarbe;
    double atmoOpazitaet;

    switch (wetterModell.typ) {
      case EmotionsWetterTyp.gewitter:
      case EmotionsWetterTyp.sturm:
        atmoFarbe = const Color(0xFF0A0A1A);
        atmoOpazitaet = 0.25 * intensitaet;
      case EmotionsWetterTyp.sonnenschein:
      case EmotionsWetterTyp.warmesLeuchten:
        atmoFarbe = AppFarben.goldGlanz;
        atmoOpazitaet = 0.04 * intensitaet;
      case EmotionsWetterTyp.kosmisch:
        atmoFarbe = const Color(0xFF2D0050);
        atmoOpazitaet = 0.10 * intensitaet;
      case EmotionsWetterTyp.regen:
        atmoFarbe = const Color(0xFF152030);
        atmoOpazitaet = 0.15 * intensitaet;
      case EmotionsWetterTyp.nebel:
        atmoFarbe = const Color(0xFFB0BEC5);
        atmoOpazitaet = 0.08 * intensitaet;
      case EmotionsWetterTyp.klar:
        return; // Kein Atmosphären-Overlay bei klarem Wetter
    }

    final paint = Paint()
      ..color = atmoFarbe.withValues(alpha: atmoOpazitaet.clamp(0.0, 0.35))
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  /// Zeichnet ein einzelnes Partikel typ-spezifisch.
  void _zeichnePartikel(Canvas canvas, Size size, _Partikel p) {
    final x = p.x * size.width;
    final y = p.y * size.height;
    final farbe = _partikelFarbe(p).withValues(alpha: p.opazitaet.clamp(0.0, 1.0));
    final paint = Paint()..color = farbe;

    switch (wetterModell.typ) {
      // Regen & Sturm: dünne Linien
      case EmotionsWetterTyp.regen:
      case EmotionsWetterTyp.sturm:
        paint.strokeWidth = p.groesse;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(x, y),
          Offset(
            x + wetterModell.windStaerke * 4,
            y + p.groesse * 8,
          ),
          paint,
        );

      // Gewitter: Blitze als gezackte Linien, normale als Punkte
      case EmotionsWetterTyp.gewitter:
        if (p.istBlitz && p.opazitaet > 0.01) {
          _zeichneBlitz(canvas, size, p, paint);
        } else if (!p.istBlitz) {
          paint.style = PaintingStyle.fill;
          canvas.drawCircle(Offset(x, y), p.groesse, paint);
        }

      // Alle anderen: runde Partikel
      default:
        paint.style = PaintingStyle.fill;
        // Bei kosmischen Partikeln: Sternform (4-Punkt)
        if (wetterModell.typ == EmotionsWetterTyp.kosmisch &&
            p.groesse > 2.5) {
          _zeichneStern(canvas, Offset(x, y), p.groesse, paint);
        } else {
          canvas.drawCircle(Offset(x, y), p.groesse, paint);
        }
    }
  }

  /// Zeichnet einen vereinfachten Blitz als gezackte Linie.
  void _zeichneBlitz(
      Canvas canvas, Size size, _Partikel p, Paint paint) {
    paint.strokeWidth = 2.0;
    paint.style = PaintingStyle.stroke;

    final startX = p.x * size.width;
    const startY = 0.0;
    final hoehe = size.height * 0.4;

    final path = Path();
    path.moveTo(startX, startY);
    path.lineTo(startX - 15, hoehe * 0.35);
    path.lineTo(startX + 8, hoehe * 0.35);
    path.lineTo(startX - 12, hoehe * 0.7);
    path.lineTo(startX + 5, hoehe * 0.7);
    path.lineTo(startX - 8, hoehe);

    canvas.drawPath(path, paint);

    // Glow-Effekt um den Blitz
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: p.opazitaet * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glowPaint);
  }

  /// Zeichnet eine einfache 4-Punkt-Sternform.
  void _zeichneStern(Canvas canvas, Offset mitte, double radius, Paint paint) {
    final path = Path();
    final kleinerRadius = radius * 0.4;

    for (int i = 0; i < 8; i++) {
      final winkel = i * math.pi / 4;
      final r = i.isEven ? radius : kleinerRadius;
      final punkt = Offset(
        mitte.dx + r * math.cos(winkel),
        mitte.dy + r * math.sin(winkel),
      );
      if (i == 0) {
        path.moveTo(punkt.dx, punkt.dy);
      } else {
        path.lineTo(punkt.dx, punkt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Gibt die Partikelfarbe je nach Wettertyp zurück.
  Color _partikelFarbe(_Partikel p) {
    if (p.istBlitz) return Colors.white;

    switch (wetterModell.typ) {
      case EmotionsWetterTyp.sonnenschein:
        return AppFarben.goldGlanz;
      case EmotionsWetterTyp.regen:
        return AppFarben.emotionDepression;
      case EmotionsWetterTyp.gewitter:
        return const Color(0xFF4A4A6A);
      case EmotionsWetterTyp.warmesLeuchten:
        return AppFarben.emotionVerliebt;
      case EmotionsWetterTyp.kosmisch:
        return AppFarben.emotionSpirituell;
      case EmotionsWetterTyp.nebel:
        return const Color(0xFFB0BEC5);
      case EmotionsWetterTyp.sturm:
        return const Color(0xFF37474F);
      case EmotionsWetterTyp.klar:
        return AppFarben.reichElysiumGlow;
    }
  }

  @override
  bool shouldRepaint(_WetterPainter old) =>
      old.partikel != partikel ||
      old.wetterModell.typ != wetterModell.typ ||
      old.wetterModell.intensitaet != wetterModell.intensitaet;
}
