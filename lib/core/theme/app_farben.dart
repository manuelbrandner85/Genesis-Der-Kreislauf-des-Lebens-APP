/// Vollständiges Farbschema für GENESIS: Der Kreislauf des Lebens.
///
/// Alle Farben sind als statische Konstanten in der [AppFarben]-Klasse
/// definiert und werden game-weit einheitlich verwendet. Das Farbschema
/// folgt einem dunklen, mystischen Stil mit kosmischen Akzenten.
library app_farben;

import 'package:flutter/material.dart';

/// Zentrale Farbkonstanten für das gesamte GENESIS-Spiel.
///
/// Verwendung: `AppFarben.goldGlanz`, `AppFarben.karmaPositiv` usw.
abstract final class AppFarben {
  // Privater Konstruktor – diese Klasse ist nicht instantiierbar.
  AppFarben._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMÄRFARBEN – Das kosmische Grundpalette
  // ═══════════════════════════════════════════════════════════════════════════

  /// Tiefstes Schwarz des Kosmos – Haupthintergrundfarbe.
  /// Verwendet für Screen-Hintergründe und dunkle Panels.
  static const Color kosmischSchwarz = Color(0xFF0A0A0F);

  /// Tiefes Nachtblau – zweite Hintergrundebene, Navigation.
  static const Color tiefesBlau = Color(0xFF0D1B2A);

  /// Mystisches Lila – Primärfarbe für interaktive Elemente, Aura-Effekte.
  /// Symbolisiert die übernatürliche, spirituelle Natur des Spiels.
  static const Color mystischLila = Color(0xFF2D1B69);

  /// Goldener Glanz – Akzentfarbe für Überschriften, Highlights, Karma-Glow.
  /// Repräsentiert göttliche Energie und höchstes Karma.
  static const Color goldGlanz = Color(0xFFFFD700);

  /// Helles Gold für Hover-/Focus-Zustände (10 % heller als [goldGlanz]).
  static const Color goldHell = Color(0xFFFFE44D);

  /// Dunkles Gold für gedrückte Zustände (20 % dunkler als [goldGlanz]).
  static const Color goldDunkel = Color(0xFFCC9E00);

  /// Kosmisches Violett – Übergangsfarbe zwischen [tiefesBlau] und [mystischLila].
  static const Color kosmischViolett = Color(0xFF1A0F3C);

  /// Nebelgrau – für inaktive, verblasste oder vergangene Elemente.
  static const Color nebelGrau = Color(0xFF3A3A4A);

  // ═══════════════════════════════════════════════════════════════════════════
  // KARMA-FARBEN – Visualisierung des moralischen Zustands
  // ═══════════════════════════════════════════════════════════════════════════

  /// Karma-Positiv-Farbe – für gute Entscheidungen und Karma-Zuwächse.
  static const Color karmaPositiv = Color(0xFF4CAF50);

  /// Helles Karma-Positiv – für Glow-Effekte um positive Karma-Anzeigen.
  static const Color karmaPositivHell = Color(0xFF81C784);

  /// Karma-Neutral-Farbe – für ausgeglichene/mittlere Karma-Werte.
  static const Color karmaNeutral = Color(0xFFFFC107);

  /// Karma-Negativ-Farbe – für schlechte Entscheidungen und Karma-Verluste.
  static const Color karmaNegatv = Color(0xFFF44336);

  /// Dunkles Karma-Negativ – für Glow-Effekte um negative Karma-Anzeigen.
  static const Color karmaNegativDunkel = Color(0xFFB71C1C);

  // ═══════════════════════════════════════════════════════════════════════════
  // JENSEITS-REICH-FARBEN – Charakterfarben der fünf Reiche
  // ═══════════════════════════════════════════════════════════════════════════

  /// Elysium – Sanftes Himmelblau, himmlisch und rein.
  /// Für das höchste Karma-Reich: ewiger Frieden.
  static const Color reichElysium = Color(0xFF87CEEB);

  /// Elysium-Glow – leuchtende Variante für Partikel und Aura-Effekte.
  static const Color reichElysiumGlow = Color(0xFFB0E8FF);

  /// Harmonia – Sanftes Grasgrün, natürlich und ausgewogen.
  /// Für das positive mittlere Reich.
  static const Color reichHarmonia = Color(0xFF90EE90);

  /// Harmonia-Glow – hellere Variante für Aura-Effekte.
  static const Color reichHarmoniaGlow = Color(0xFFB8F5B8);

  /// Limbus – Neutrales Mittelgrau, nebelig und unbestimmt.
  /// Für das neutrale Zwischenreich.
  static const Color reichLimbus = Color(0xFF808080);

  /// Limbus-Glow – etwas helleres Grau für Partikel-Effekte.
  static const Color reichLimbusGlow = Color(0xFFAAAAAA);

  /// Shadowlands – Tiefes Dunkelviolett / Indigo, bedrohlich und düster.
  /// Für das negativ-dunkle Reich.
  static const Color reichShadowlands = Color(0xFF4B0082);

  /// Shadowlands-Glow – lila Schimmer für atmosphärische Effekte.
  static const Color reichShadowlandsGlow = Color(0xFF7B1FA2);

  /// Abyssus – Tiefstes Dunkelrot / Karmesin, Qual und Finsternis.
  /// Für das tiefste, dunkelste Reich.
  static const Color reichAbyssus = Color(0xFF8B0000);

  /// Abyssus-Glow – dunkelroter Schimmer für bedrohliche Effekte.
  static const Color reichAbyssusGlow = Color(0xFFD32F2F);

  // ═══════════════════════════════════════════════════════════════════════════
  // PHASEN-FARBEN – Visuelle Identität der 9 Lebensphasen
  // ═══════════════════════════════════════════════════════════════════════════

  /// Phase 1 – Geburt: Reines Weiß, Unschuld, neues Leben.
  static const Color phaseGeburt = Color(0xFFF5F5F5);

  /// Phase 2 – Kindheit: Zartes Hellblau, Unbeschwertheit, Neugierde.
  static const Color phaseKindheit = Color(0xFF81D4FA);

  /// Phase 3 – Jugend: Lebhaftes Orange, Energie, Rebellion.
  static const Color phaseJugend = Color(0xFFFFB74D);

  /// Phase 4 – Aufbruch: Dynamisches Türkis, Aufbruchsstimmung, Freiheit.
  static const Color phaseAufbruch = Color(0xFF4DD0E1);

  /// Phase 5 – Blüte: Sattes Gold, Fülle, Lebenshöhepunkt.
  static const Color phaseBluete = Color(0xFFFFD700);

  /// Phase 6 – Prüfung: Intensives Rot, Konflikt, Krise, Leidenschaft.
  static const Color phasePruefung = Color(0xFFEF5350);

  /// Phase 7 – Weisheit: Sanftes Lila, Würde, Reflexion, Tiefe.
  static const Color phaseWeisheit = Color(0xFFBA68C8);

  /// Phase 8 – Vermächtnis: Warmes Bernstein, Hinterlassenschaft, Abschluss.
  static const Color phaseVermaechtnis = Color(0xFFFFB300);

  /// Phase 9 – Tod: Tiefes Dunkelblau-Schwarz, Übergang, Würde, Stille.
  static const Color phaseTod = Color(0xFF1A237E);

  // ═══════════════════════════════════════════════════════════════════════════
  // EMOTIONS-WETTER-FARBEN – Emotionaler Zustand des Charakters
  // ═══════════════════════════════════════════════════════════════════════════
  // Das "Emotions-Wetter" beschreibt den aktuellen Gefühlszustand als
  // atmosphärisches Farbklima (beeinflusst Beleuchtung und Partikel-Systeme).

  /// Glück – warmes Sonnengold, freudige Leichtigkeit.
  static const Color emotionGlueck = Color(0xFFFFD700);

  /// Depression – dunkles Dunkelblau, Schwermut, innere Leere.
  static const Color emotionDepression = Color(0xFF4169E1);

  /// Wut – intensives Feuerrot-Orange, unkontrollierte Energie.
  static const Color emotionWut = Color(0xFFFF4500);

  /// Verliebt – leuchtendes Heißrosa, romantische Wärme, Herzschlag.
  static const Color emotionVerliebt = Color(0xFFFF69B4);

  /// Spirituell – tiefes Violett, transzendente Stille, Erleuchtung.
  static const Color emotionSpirituell = Color(0xFF9400D3);

  /// Angst – kühles Blaugrau, Lähmung, Ungewissheit.
  static const Color emotionAngst = Color(0xFF607D8B);

  /// Trauer – dunkles Blaugrau, ruhiger Schmerz, Abschied.
  static const Color emotionTrauer = Color(0xFF455A64);

  /// Stolz – warmes Bernstein-Gold, Selbstachtung, Stärke.
  static const Color emotionStolz = Color(0xFFFFA000);

  /// Gleichmut – neutrales Warmgrau, innere Ruhe, Balance.
  static const Color emotionGleichmut = Color(0xFF9E9E9E);

  // ═══════════════════════════════════════════════════════════════════════════
  // UI-SYSTEMFARBEN – Allgemeine Interface-Elemente
  // ═══════════════════════════════════════════════════════════════════════════

  /// Haupthintergrundfarbe – entspricht [kosmischSchwarz].
  static const Color hintergrund = kosmischSchwarz;

  /// Sekundäre Hintergrundfarbe für Screens und Panels.
  static const Color hintergrundSekundaer = tiefesBlau;

  /// Oberflächenfarbe für Karten, Dialoge und erhöhte Elemente.
  static const Color oberflaeche = Color(0xFF111827);

  /// Erhöhte Oberflächenfarbe (leicht heller als [oberflaeche]).
  static const Color oberflaecheErhoben = Color(0xFF1F2937);

  /// Primäre Textfarbe – hohes Kontrast-Weiß auf dunklem Hintergrund.
  static const Color text = Color(0xFFF9FAFB);

  /// Sekundäre Textfarbe – gedämpftes Hellgrau für Untertitel und Beschriftungen.
  static const Color textSekundaer = Color(0xFF9CA3AF);

  /// Tertiäre Textfarbe – noch stärker gedämpft für Hints und Platzhalter.
  static const Color textTertiaer = Color(0xFF6B7280);

  /// Deaktivierte Textfarbe für inaktive Elemente.
  static const Color textDeaktiviert = Color(0xFF4B5563);

  /// Trennlinienfarbe – subtile Linie für Listentrennungen.
  static const Color trenner = Color(0xFF1F2937);

  /// Primäre Fehlerfarbe – für Fehlermeldungen und Warn-Toasts.
  static const Color fehler = Color(0xFFEF4444);

  /// Heller Fehlerhintergrund – für Fehler-Banner und Alert-Boxen.
  static const Color fehlerHintergrund = Color(0xFF1F0A0A);

  /// Erfolgsfarbe – für positive Rückmeldungen und Bestätigungen.
  static const Color erfolg = Color(0xFF22C55E);

  /// Heller Erfolgshintergrund – für Erfolgs-Banner.
  static const Color erfolgHintergrund = Color(0xFF0A1F10);

  /// Warnfarbe – für wichtige Hinweise (nicht kritisch).
  static const Color warnung = Color(0xFFF59E0B);

  /// Heller Warnhintergrund.
  static const Color warnungHintergrund = Color(0xFF1F1508);

  /// Informationsfarbe – für neutrale Informations-Toasts.
  static const Color info = Color(0xFF3B82F6);

  /// Heller Infohintergrund.
  static const Color infoHintergrund = Color(0xFF080F1F);

  // ═══════════════════════════════════════════════════════════════════════════
  // OVERLAYS & SCRIM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Halbdurchsichtiger dunkler Scrim für Modals und Dialoge.
  static const Color scrim = Color(0xCC000000);

  /// Leichter Overlay für Hover-Effekte (5 % Weiß).
  static const Color overlayHover = Color(0x0DFFFFFF);

  /// Mittlerer Overlay für gedrückte Zustände (10 % Weiß).
  static const Color overlayGedrueckt = Color(0x1AFFFFFF);

  /// Fokus-Overlay für Tastatur-Navigation (15 % Gold-Tint).
  static const Color overlayFokus = Color(0x26FFD700);

  // ═══════════════════════════════════════════════════════════════════════════
  // HILFSMETHODEN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gibt die Phasenfarbe für eine gegebene Phasennummer (1–9) zurück.
  /// Gibt [nebelGrau] zurück, wenn die Nummer außerhalb des Bereichs liegt.
  static Color fuerPhaseNummer(int nummer) {
    const phasenFarben = [
      phaseGeburt,       // 1
      phaseKindheit,     // 2
      phaseJugend,       // 3
      phaseAufbruch,     // 4
      phaseBluete,       // 5
      phasePruefung,     // 6
      phaseWeisheit,     // 7
      phaseVermaechtnis, // 8
      phaseTod,          // 9
    ];
    if (nummer < 1 || nummer > 9) return nebelGrau;
    return phasenFarben[nummer - 1];
  }

  /// Gibt die Karma-Farbe für einen gegebenen Karma-Wert zurück.
  /// Positiv → [karmaPositiv], Neutral → [karmaNeutral], Negativ → [karmaNegatv].
  static Color fuerKarmaWert(double wert) {
    if (wert > 15.0) return karmaPositiv;
    if (wert < -15.0) return karmaNegatv;
    return karmaNeutral;
  }

  /// Interpoliert eine Farbe zwischen [karmaNegatv] und [karmaPositiv]
  /// basierend auf einem normierten [t]-Wert (0.0 = negativ, 1.0 = positiv).
  static Color karmaFarbeInterpoliert(double t) {
    final begrenzt = t.clamp(0.0, 1.0);
    if (begrenzt < 0.5) {
      return Color.lerp(karmaNegatv, karmaNeutral, begrenzt * 2.0) ??
          karmaNeutral;
    }
    return Color.lerp(karmaNeutral, karmaPositiv, (begrenzt - 0.5) * 2.0) ??
        karmaPositiv;
  }

  /// Gibt eine leicht transparente Variante der übergebenen [farbe] zurück.
  /// [alpha] = 0–255 (Standard: 128 = 50 % Deckkraft).
  static Color mitAlpha(Color farbe, int alpha) =>
      farbe.withAlpha(alpha.clamp(0, 255));
}
