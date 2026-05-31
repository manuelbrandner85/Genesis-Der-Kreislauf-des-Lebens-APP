// entstehungs_spiel.dart
// Haupt-FlameGame-Klasse für Phase 1: Das Spermium-Rennen.
// Orchestriert alle Komponenten, verwaltet Spielzustand und
// verarbeitet Spieler-Eingaben.

import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:genesis_kreislauf_des_lebens/game/entstehung/hindernis.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/ki_spermium.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/power_up.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/renn_strecke.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/rennen_ergebnis.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/spiel_hud.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/spieler_spermium.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EntstehungsSpielZustand – interner Spielzustand
// ─────────────────────────────────────────────────────────────────────────────

/// Die möglichen Zustände des Rennens
enum EntstehungsSpielZustand {
  /// Rennen läuft normal
  laufend,

  /// Routenwahl-Phase (Distanz ~400)
  routenWahl,

  /// Spiel pausiert
  pausiert,

  /// Spieler verloren (alle Leben verbraucht)
  spielVorbei,

  /// Rennen erfolgreich beendet (Distanz 1000 erreicht)
  rennenBeendet,
}

// ─────────────────────────────────────────────────────────────────────────────
// EntstehungsSpiel – Haupt-FlameGame
// ─────────────────────────────────────────────────────────────────────────────

/// Das Spermium-Rennen-Minigame für Phase 1: Die Entstehung.
///
/// Implementiert als [FlameGame] mit:
/// - [HasCollisionDetection] für Hindernis- und PowerUp-Kollisionen
/// - [TapCallbacks] für Touch-/Klick-Steuerung
///
/// Steuerung:
/// - Linke Bildschirmhälfte tippen → nach oben bewegen
/// - Rechte Bildschirmhälfte tippen → nach unten bewegen
/// - Bei Routenwahl: linkes/mittleres/rechtes Drittel → Route wählen
class EntstehungsSpiel extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  // ─────────────────────────────────────────────────────────────────────────
  // Haupt-Komponenten
  // ─────────────────────────────────────────────────────────────────────────

  /// Spieler-Spermium
  late SpielCharakter spieler;

  /// Tunnel-Hintergrund und Route-Wahl
  late RennStrecke rennStrecke;

  /// HUD-Overlay mit Platz, Distanz, Leben
  late SpielHUD hud;

  /// Hindernisse-Generator
  late HindernisGenerator hindernisGenerator;

  /// Power-Up-Spawner
  late PowerUpSpawner powerUpSpawner;

  /// KI-Gegner-Verwaltung
  late KiSpermiumManager kiManager;

  // ─────────────────────────────────────────────────────────────────────────
  // Spielzustand
  // ─────────────────────────────────────────────────────────────────────────

  /// Zurückgelegte Distanz (0–1000)
  double distanz = 0.0;

  /// Aktuelle Scrollgeschwindigkeit in px/s
  double geschwindigkeit = 150.0;

  /// Aktuelle Platzierung (1 = Erster)
  int platzierung = 1;

  /// Aktueller Spielzustand
  EntstehungsSpielZustand spielZustand = EntstehungsSpielZustand.laufend;

  // PowerUp-Zähler für Attributberechnung
  int kraftPowerUps = 0;
  int intelligenzPowerUps = 0;
  int empathiePowerUps = 0;

  // Route-Gewählt-Anzeige-Timer
  double _routeAnzeigeTimer = 0.0;

  // Callback wenn das Rennen beendet ist (Ergebnis weitergeben)
  void Function(RennenErgebnis ergebnis)? onRennenBeendet;

  // Callback für Spielzustands-Änderungen (z.B. für Pause-Button)
  void Function(EntstehungsSpielZustand zustand)? onZustandGeaendert;

  // ─────────────────────────────────────────────────────────────────────────
  // Lebenszyklus: onLoad
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Kamera auf Spielgröße fixieren
    camera.viewfinder.anchor = Anchor.topLeft;

    // 1. Tunnel-Hintergrund (muss zuerst gerendert werden)
    rennStrecke = RennStrecke(
      scrollGeschwindigkeit: geschwindigkeit,
      aktuelleDistanz: distanz,
    );
    rennStrecke.onRouteGewaehlt = _routeGewaehlt;
    world.add(rennStrecke);

    // 2. KI-Gegner-Manager (hinter dem Spieler)
    kiManager = KiSpermiumManager();
    world.add(kiManager);

    // 3. Spieler-Spermium (horizontal zentriert, vertikal mittig im Spielbereich)
    spieler = SpielCharakter();
    spieler.position = Vector2(
      size.x * 0.25, // Links positioniert (Spieler sieht Hindernisse von rechts kommen)
      size.y * 0.5,
    );
    spieler.onLebenVerloren = _lebenVerloren;
    spieler.onSpielVorbei = _spielVorbei;
    spieler.onPowerUpEingesammelt = powerUpRegistrieren;
    world.add(spieler);

    // 4. Hindernisse-Generator
    hindernisGenerator = HindernisGenerator(
      scrollGeschwindigkeit: geschwindigkeit,
      distanz: distanz,
    );
    world.add(hindernisGenerator);

    // 5. PowerUp-Spawner
    powerUpSpawner = PowerUpSpawner(
      scrollGeschwindigkeit: geschwindigkeit,
      distanz: distanz,
    );
    world.add(powerUpSpawner);

    // 6. HUD (wird als Camera-Overlay gerendert, nicht im World)
    hud = SpielHUD();
    camera.viewport.add(hud);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update-Schleife
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    // Bei Pause oder Spielende: keine Updates
    if (spielZustand == EntstehungsSpielZustand.pausiert ||
        spielZustand == EntstehungsSpielZustand.spielVorbei ||
        spielZustand == EntstehungsSpielZustand.rennenBeendet) {
      return;
    }

    // Distanz vorantreiben
    distanz += geschwindigkeit * dt;

    // Geschwindigkeit langsam erhöhen (Beschleunigung 5px/s²)
    geschwindigkeit += dt * 5.0;

    // Maximale Geschwindigkeit begrenzen
    if (geschwindigkeit > 500.0) geschwindigkeit = 500.0;

    // Kraft-PowerUp: +50 Geschwindigkeit
    if (spieler.effektAktiv(PowerUpTyp.kraft)) {
      geschwindigkeit += dt * 25.0;
    }

    // Boost-PowerUp: +80 Geschwindigkeit
    if (spieler.effektAktiv(PowerUpTyp.boost)) {
      geschwindigkeit += dt * 40.0;
    }

    // Scrollgeschwindigkeit an Komponenten weitergeben
    _aktualisierScrollGeschwindigkeit();

    // KI-Gegner-Distanzen aktualisieren
    kiManager.aktualisierDistanzen(geschwindigkeit * 0.85, dt);

    // Visuelle Positionen der KI-Gegner aktualisieren
    kiManager.aktualisiereVisuellPosition(distanz, size.x, size.y);

    // Platzierung berechnen
    platzierung = kiManager.berechneSpielersPlatzierung(distanz);

    // Route-Wahl bei Distanz 400
    if (distanz >= 400 &&
        spielZustand == EntstehungsSpielZustand.laufend &&
        !rennStrecke.routeGewaehlt) {
      spielZustand = EntstehungsSpielZustand.routenWahl;
      onZustandGeaendert?.call(spielZustand);
    }

    // Routenwahl-Anzeige-Timer
    if (rennStrecke.routeGewaehlt) {
      _routeAnzeigeTimer += dt;
    }

    // Rennen bei Distanz 1000 beenden
    if (distanz >= 1000.0 &&
        spielZustand != EntstehungsSpielZustand.rennenBeendet) {
      _rennenBeendet();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Scrollgeschwindigkeit synchronisieren
  // ─────────────────────────────────────────────────────────────────────────

  void _aktualisierScrollGeschwindigkeit() {
    rennStrecke.scrollGeschwindigkeit = geschwindigkeit;
    rennStrecke.aktuelleDistanz = distanz;
    hindernisGenerator.scrollGeschwindigkeit = geschwindigkeit;
    hindernisGenerator.distanz = distanz;
    powerUpSpawner.scrollGeschwindigkeit = geschwindigkeit;
    powerUpSpawner.distanz = distanz;

    // Auch alle bestehenden Hindernisse und PowerUps aktualisieren
    for (final child in world.children) {
      if (child is Hindernis) {
        child.scrollGeschwindigkeit = geschwindigkeit;
      } else if (child is PowerUp) {
        child.scrollGeschwindigkeit = geschwindigkeit;
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tap-Eingaben
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    if (spielZustand == EntstehungsSpielZustand.pausiert ||
        spielZustand == EntstehungsSpielZustand.rennenBeendet ||
        spielZustand == EntstehungsSpielZustand.spielVorbei) {
      return;
    }

    final tapX = event.canvasPosition.x;
    final tapY = event.canvasPosition.y;

    // Route-Wahl: Bildschirm in Drittel aufteilen
    if (spielZustand == EntstehungsSpielZustand.routenWahl &&
        !rennStrecke.routeGewaehlt) {
      if (tapX < size.x / 3) {
        rennStrecke.routeWaehlen(RoutenTyp.kraft);
      } else if (tapX < size.x * 2 / 3) {
        rennStrecke.routeWaehlen(RoutenTyp.intelligenz);
      } else {
        rennStrecke.routeWaehlen(RoutenTyp.empathie);
      }
      return;
    }

    // Normale Steuerung: linke Hälfte = rauf, rechte Hälfte = runter
    if (tapX < size.x / 2) {
      spieler.bewegeNachOben();
    } else {
      spieler.bewegeNachUnten();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Ereignis-Handler
  // ─────────────────────────────────────────────────────────────────────────

  /// Wird aufgerufen wenn der Spieler ein Leben verliert
  void _lebenVerloren(int verbleibendeLeben) {
    // Empathie-PowerUp: KI-Gegner verlangsamen
    if (spieler.effektAktiv(PowerUpTyp.empathie)) {
      kiManager.verlangsamNaheGegner(distanz);
    }
  }

  /// Wird aufgerufen wenn alle Leben verbraucht sind
  void _spielVorbei() {
    spielZustand = EntstehungsSpielZustand.spielVorbei;
    onZustandGeaendert?.call(spielZustand);

    // Spiel trotzdem beenden (mit schlechterer Platzierung)
    Future.delayed(const Duration(seconds: 2), () {
      if (spielZustand == EntstehungsSpielZustand.spielVorbei) {
        _rennenBeendet();
      }
    });
  }

  /// Wird aufgerufen wenn eine Route gewählt wurde
  void _routeGewaehlt(RoutenTyp route) {
    // PowerUps zählen
    switch (route) {
      case RoutenTyp.kraft:
        kraftPowerUps += 2; // Bonus für Routenwahl
      case RoutenTyp.intelligenz:
        intelligenzPowerUps += 2;
      case RoutenTyp.empathie:
        empathiePowerUps += 2;
    }

    // Zurück zu normaler Spielphase
    spielZustand = EntstehungsSpielZustand.laufend;
    onZustandGeaendert?.call(spielZustand);
  }

  /// Beendet das Rennen und erstellt das Ergebnis
  void _rennenBeendet() {
    spielZustand = EntstehungsSpielZustand.rennenBeendet;
    onZustandGeaendert?.call(spielZustand);

    // Standard-Route wenn keine gewählt (höchster PowerUp-Wert)
    RoutenTyp finalRoute;
    if (rennStrecke.gewaehltRoute != null) {
      finalRoute = rennStrecke.gewaehltRoute!;
    } else if (kraftPowerUps >= intelligenzPowerUps &&
        kraftPowerUps >= empathiePowerUps) {
      finalRoute = RoutenTyp.kraft;
    } else if (intelligenzPowerUps >= empathiePowerUps) {
      finalRoute = RoutenTyp.intelligenz;
    } else {
      finalRoute = RoutenTyp.empathie;
    }

    final ergebnis = RennenErgebnis(
      gewaehltRoute: finalRoute,
      endPlatzierung: platzierung,
      eingesammelteKraftPowerUps: kraftPowerUps,
      eingesammelteIntelligenzPowerUps: intelligenzPowerUps,
      eingesammelteEmpathiePowerUps: empathiePowerUps,
      lebenAmEnde: spieler.leben.clamp(0, 3),
      endGeschwindigkeit: geschwindigkeit,
    );

    onRennenBeendet?.call(ergebnis);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Öffentliche Steuerungsmethoden
  // ─────────────────────────────────────────────────────────────────────────

  /// Pausiert oder setzt das Spiel fort
  void pauseUmschalten() {
    if (spielZustand == EntstehungsSpielZustand.pausiert) {
      spielZustand = EntstehungsSpielZustand.laufend;
      resumeEngine();
    } else if (spielZustand == EntstehungsSpielZustand.laufend ||
        spielZustand == EntstehungsSpielZustand.routenWahl) {
      spielZustand = EntstehungsSpielZustand.pausiert;
      pauseEngine();
    }
    onZustandGeaendert?.call(spielZustand);
  }

  /// Gibt zurück ob das Spiel pausiert ist
  bool get istPausiert =>
      spielZustand == EntstehungsSpielZustand.pausiert;

  /// Registriert einen gesammelten PowerUp-Typ für die Attributberechnung
  void powerUpRegistrieren(PowerUpTyp typ) {
    switch (typ) {
      case PowerUpTyp.kraft:
        kraftPowerUps++;
      case PowerUpTyp.intelligenz:
        intelligenzPowerUps++;
      case PowerUpTyp.empathie:
        empathiePowerUps++;
      case PowerUpTyp.schild:
      case PowerUpTyp.boost:
        break; // Keine Attributzählung
    }
  }
}
