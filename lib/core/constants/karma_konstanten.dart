/// Karma-Konstanten für GENESIS: Der Kreislauf des Lebens.
///
/// Diese Datei definiert alle Karma-bezogenen Konstanten: Dimensionen,
/// Wertebereiche, Schwellenwerte für die fünf Jenseits-Reiche und
/// Karma-Gewichtungen für die Jenseits-Berechnung.
library karma_konstanten;

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// KARMA-WERTEBEREICHE
// ═══════════════════════════════════════════════════════════════════════════════

/// Unterster möglicher Karma-Wert je Dimension.
const double kMinKarma = -100.0;

/// Höchster möglicher Karma-Wert je Dimension.
const double kMaxKarma = 100.0;

/// Neutraler Karma-Startpunkt.
const double kNeutralKarma = 0.0;

/// Kleinstmögliche Karma-Änderung (für Micro-Entscheidungen).
const double kMinKarmaAenderung = 0.5;

/// Größte mögliche Karma-Änderung in einer Einzelentscheidung.
const double kMaxKarmaAenderung = 25.0;

// ═══════════════════════════════════════════════════════════════════════════════
// JENSEITS-REICH SCHWELLENWERTE (basierend auf Gesamt-Durchschnitt)
// ═══════════════════════════════════════════════════════════════════════════════

/// Elysium-Schwelle: Durchschnitt aller Dimensionen >= 60 → höchstes Jenseits-Reich.
const double kElysiumSchwelle = 60.0;

/// Harmonia-Schwelle: Durchschnitt >= 20 → positives Reich.
const double kHarmoniaSchwelle = 20.0;

/// Limbus-Bereich: zwischen -20 und +20 (inklusive) → neutrales Reich.
/// (Kein eigener Wert nötig – wird durch die anderen Schwellen definiert.)

/// Shadowlands-Schwelle: Durchschnitt <= -20 → negatives Reich.
const double kShadowlandsSchwelle = -20.0;

/// Abyssus-Schwelle: Durchschnitt <= -60 → niedrigstes, dunklestes Reich.
const double kAbyssusSchwelle = -60.0;

// ═══════════════════════════════════════════════════════════════════════════════
// KARMA-DIMENSIONEN (ENUM)
// ═══════════════════════════════════════════════════════════════════════════════

/// Die sechs Karma-Dimensionen, die die moralische Seele des Charakters formen.
///
/// Jede Dimension reicht von -100 (negativ/dunkel) bis +100 (positiv/hell).
/// Der Durchschnitt aller sechs Dimensionen bestimmt das Jenseits-Reich.
enum KarmaDimension {
  // ── Mitgefühl ───────────────────────────────────────────────────────────────
  /// Positiv: Mitgefühl, Empathie, Fürsorge für andere.
  /// Negativ: Grausamkeit, Kälte, Gleichgültigkeit gegenüber Leid.
  mitgefuehl(
    anzeigeName: 'Mitgefühl',
    positivBeschreibung: 'Empathie & Fürsorge',
    negativBeschreibung: 'Grausamkeit & Kälte',
    gewichtung: 1.2,
    ikonPfad: 'assets/images/icons/karma_mitgefuehl.png',
    farbHex: 0xFFE91E63, // Rosa / Pink
  ),

  // ── Ehrlichkeit ─────────────────────────────────────────────────────────────
  /// Positiv: Wahrheit, Aufrichtigkeit, Transparenz.
  /// Negativ: Lüge, Betrug, Manipulation.
  ehrlichkeit(
    anzeigeName: 'Ehrlichkeit',
    positivBeschreibung: 'Wahrheit & Aufrichtigkeit',
    negativBeschreibung: 'Lüge & Betrug',
    gewichtung: 1.0,
    ikonPfad: 'assets/images/icons/karma_ehrlichkeit.png',
    farbHex: 0xFF2196F3, // Blau
  ),

  // ── Mut ─────────────────────────────────────────────────────────────────────
  /// Positiv: Tapferkeit, Standhaftigkeit, Courage angesichts von Gefahr.
  /// Negativ: Feigheit, Duckmäusertum, Verrat aus Angst.
  mut(
    anzeigeName: 'Mut',
    positivBeschreibung: 'Tapferkeit & Courage',
    negativBeschreibung: 'Feigheit & Verrat',
    gewichtung: 0.9,
    ikonPfad: 'assets/images/icons/karma_mut.png',
    farbHex: 0xFFFF9800, // Orange
  ),

  // ── Großzügigkeit ───────────────────────────────────────────────────────────
  /// Positiv: Freigebigkeit, Teilen, uneigennütziges Geben.
  /// Negativ: Gier, Geiz, Ausbeutung anderer.
  grosszuegigkeit(
    anzeigeName: 'Großzügigkeit',
    positivBeschreibung: 'Freigebigkeit & Teilen',
    negativBeschreibung: 'Gier & Geiz',
    gewichtung: 1.0,
    ikonPfad: 'assets/images/icons/karma_grosszuegigkeit.png',
    farbHex: 0xFF4CAF50, // Grün
  ),

  // ── Weisheit ────────────────────────────────────────────────────────────────
  /// Positiv: Klugheit, Besonnenheit, weise Entscheidungen für das Gemeinwohl.
  /// Negativ: Ignoranz, Arroganz, unüberlegtes Handeln mit Folgeschäden.
  weisheit(
    anzeigeName: 'Weisheit',
    positivBeschreibung: 'Klugheit & Besonnenheit',
    negativBeschreibung: 'Ignoranz & Arroganz',
    gewichtung: 1.1,
    ikonPfad: 'assets/images/icons/karma_weisheit.png',
    farbHex: 0xFF9C27B0, // Lila
  ),

  // ── Liebe ───────────────────────────────────────────────────────────────────
  /// Positiv: Tiefe Zuneigung, Hingabe, bedingungslose Liebe.
  /// Negativ: Gleichgültigkeit, emotionale Kälte, Ablehnung von Verbindungen.
  liebe(
    anzeigeName: 'Liebe',
    positivBeschreibung: 'Hingabe & Zuneigung',
    negativBeschreibung: 'Gleichgültigkeit & Kälte',
    gewichtung: 1.3,
    ikonPfad: 'assets/images/icons/karma_liebe.png',
    farbHex: 0xFFFF4081, // Tief-Rosa
  );

  // ── Konstruktor ────────────────────────────────────────────────────────────
  const KarmaDimension({
    required this.anzeigeName,
    required this.positivBeschreibung,
    required this.negativBeschreibung,
    required this.gewichtung,
    required this.ikonPfad,
    required this.farbHex,
  });

  // ── Felder ─────────────────────────────────────────────────────────────────

  /// Lesbarer Anzeige-Name auf Deutsch.
  final String anzeigeName;

  /// Beschreibung des positiven Pols dieser Dimension.
  final String positivBeschreibung;

  /// Beschreibung des negativen Pols dieser Dimension.
  final String negativBeschreibung;

  /// Gewichtungsfaktor für die Jenseits-Berechnung (> 1.0 = stärker gewichtet).
  final double gewichtung;

  /// Pfad zum Dimensions-Icon in den Assets.
  final String ikonPfad;

  /// Farbe dieser Dimension als ARGB-Hex-Wert für direkte Color-Konstruktion.
  final int farbHex;

  // ── Hilfsmethoden ──────────────────────────────────────────────────────────

  /// Gibt die Flutter-Farbe dieser Dimension zurück.
  Color get farbe => Color(farbHex);

  /// Gibt den Anzeigenamen der positiven oder negativen Seite zurück,
  /// basierend auf dem übergebenen [wert].
  String polBeschreibung(double wert) =>
      wert >= 0 ? positivBeschreibung : negativBeschreibung;

  /// Gibt zurück, ob diese Dimension bei [wert] positiv ist.
  bool istPositivBei(double wert) => wert >= kNeutralKarma;

  /// Findet eine KarmaDimension anhand ihres Anzeige-Namens.
  /// Gibt [mitgefuehl] zurück, wenn keine Übereinstimmung gefunden.
  static KarmaDimension vonName(String name) {
    return KarmaDimension.values.firstWhere(
      (d) => d.anzeigeName.toLowerCase() == name.toLowerCase(),
      orElse: () => KarmaDimension.mitgefuehl,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// JENSEITS-REICHE (ENUM)
// ═══════════════════════════════════════════════════════════════════════════════

/// Die fünf Jenseits-Reiche, in die eine Seele nach dem Tod eingeht.
///
/// Das Reich wird durch den gewichteten Durchschnitt aller Karma-Dimensionen
/// bestimmt. Je höher der Durchschnitt, desto strahlender das Reich.
enum JenseitsReich {
  // ── Elysium ─────────────────────────────────────────────────────────────────
  /// Das höchste Reich. Nur Seelen mit außerordentlichem positivem Karma
  /// (Durchschnitt >= 60) gelangen hierher. Ewiger Frieden und Erleuchtung.
  elysium(
    anzeigeName: 'Elysium',
    beschreibung:
        'Das Reich ewiger Harmonie. Nur reinste Seelen ruhen hier '
        'in vollkommener Erleuchtung und vollständigem Frieden.',
    farbHex: 0xFF87CEEB, // Sanftes Himmelblau
    schwelleMin: 60.0,
    schwelleMax: 100.0,
    wiedergeburtsBonus: 25.0,
    musikThema: 'assets/audio/musik/elysium_theme.mp3',
  ),

  // ── Harmonia ────────────────────────────────────────────────────────────────
  /// Positives Reich für gute Seelen (Durchschnitt 20–59).
  /// Leichte Welt, grüne Hügel, ruhige Gewässer.
  harmonia(
    anzeigeName: 'Harmonia',
    beschreibung:
        'Das Reich der Ausgeglichenen. Gute Seelen finden hier '
        'Ruhe, natürliche Schönheit und wohlverdiente Freude.',
    farbHex: 0xFF90EE90, // Helles Grün
    schwelleMin: 20.0,
    schwelleMax: 59.9,
    wiedergeburtsBonus: 10.0,
    musikThema: 'assets/audio/musik/harmonia_theme.mp3',
  ),

  // ── Limbus ──────────────────────────────────────────────────────────────────
  /// Neutrales Reich für unentschiedene Seelen (Durchschnitt -19 bis +19).
  /// Nebelhafte Zwischenwelt – weder Leid noch Freude.
  limbus(
    anzeigeName: 'Limbus',
    beschreibung:
        'Das Reich des Übergangs. Unentschiedene Seelen verweilen hier '
        'im ewigen Grau, bevor das nächste Leben beginnt.',
    farbHex: 0xFF808080, // Neutrales Grau
    schwelleMin: -19.9,
    schwelleMax: 19.9,
    wiedergeburtsBonus: 0.0,
    musikThema: 'assets/audio/musik/limbus_theme.mp3',
  ),

  // ── Shadowlands ─────────────────────────────────────────────────────────────
  /// Dunkles Reich für negative Seelen (Durchschnitt -60 bis -20).
  /// Schatten, Kälte und Reue bestimmen das Erleben.
  shadowlands(
    anzeigeName: 'Shadowlands',
    beschreibung:
        'Das Reich der Schatten. Seelen mit negativem Karma büßen hier '
        'ihre Taten in ewiger Dunkelheit und Reue.',
    farbHex: 0xFF4B0082, // Dunkelviolett / Indigo
    schwelleMin: -59.9,
    schwelleMax: -20.0,
    wiedergeburtsBonus: -10.0,
    musikThema: 'assets/audio/musik/shadowlands_theme.mp3',
  ),

  // ── Abyssus ─────────────────────────────────────────────────────────────────
  /// Das tiefste, dunkelste Reich (Durchschnitt <= -60).
  /// Nur die schwärzesten Seelen werden hierher verbannt.
  abyssus(
    anzeigeName: 'Abyssus',
    beschreibung:
        'Der tiefste Abgrund. Seelen voller Finsternis werden hier '
        'in ewiger Qual gefangen – bis das Karma sich wendet.',
    farbHex: 0xFF8B0000, // Dunkelrot / Karmesin
    schwelleMin: -100.0,
    schwelleMax: -60.0,
    wiedergeburtsBonus: -25.0,
    musikThema: 'assets/audio/musik/abyssus_theme.mp3',
  );

  // ── Konstruktor ────────────────────────────────────────────────────────────
  const JenseitsReich({
    required this.anzeigeName,
    required this.beschreibung,
    required this.farbHex,
    required this.schwelleMin,
    required this.schwelleMax,
    required this.wiedergeburtsBonus,
    required this.musikThema,
  });

  // ── Felder ─────────────────────────────────────────────────────────────────

  /// Anzeige-Name des Reiches auf Deutsch.
  final String anzeigeName;

  /// Atmosphärische Beschreibung des Reiches.
  final String beschreibung;

  /// Charakteristische Farbe des Reiches als ARGB-Hex.
  final int farbHex;

  /// Unterer Karma-Schwellenwert (inklusive) für dieses Reich.
  final double schwelleMin;

  /// Oberer Karma-Schwellenwert (inklusive) für dieses Reich.
  final double schwelleMax;

  /// Karma-Bonus/Malus (+/-) auf den Startkarma des nächsten Lebens.
  final double wiedergeburtsBonus;

  /// Pfad zur Hintergrundmusik dieses Reiches.
  final String musikThema;

  // ── Hilfsmethoden ──────────────────────────────────────────────────────────

  /// Gibt die Flutter-Farbe dieses Reiches zurück.
  Color get farbe => Color(farbHex);

  /// Gibt zurück, ob der angegebene [durchschnitt] in dieses Reich fällt.
  bool passztZuDurchschnitt(double durchschnitt) =>
      durchschnitt >= schwelleMin && durchschnitt <= schwelleMax;

  /// Ermittelt das passende Jenseits-Reich für einen gegebenen Karma-Durchschnitt.
  /// Gibt [limbus] zurück, wenn kein Reich exakt passt (Fallback).
  static JenseitsReich fuerDurchschnitt(double durchschnitt) {
    // Elysium prüfen (höchster Rang zuerst)
    if (durchschnitt >= kElysiumSchwelle) return JenseitsReich.elysium;
    // Harmonia
    if (durchschnitt >= kHarmoniaSchwelle) return JenseitsReich.harmonia;
    // Abyssus (tiefster Rang)
    if (durchschnitt <= kAbyssusSchwelle) return JenseitsReich.abyssus;
    // Shadowlands
    if (durchschnitt <= kShadowlandsSchwelle) return JenseitsReich.shadowlands;
    // Limbus als neutraler Fallback
    return JenseitsReich.limbus;
  }

  /// Gibt zurück, ob dieses Reich als "positiv" gilt (Elysium oder Harmonia).
  bool get istPositiv =>
      this == JenseitsReich.elysium || this == JenseitsReich.harmonia;

  /// Gibt zurück, ob dieses Reich als "negativ" gilt (Shadowlands oder Abyssus).
  bool get istNegativ =>
      this == JenseitsReich.shadowlands || this == JenseitsReich.abyssus;

  /// Gibt zurück, ob dieses Reich neutral ist (Limbus).
  bool get istNeutral => this == JenseitsReich.limbus;
}

// ═══════════════════════════════════════════════════════════════════════════════
// KARMA-GEWICHTUNGEN FÜR JENSEITS-BERECHNUNG
// ═══════════════════════════════════════════════════════════════════════════════

/// Gewichtungsmap für die sechs Karma-Dimensionen bei der Jenseits-Berechnung.
///
/// Der gewichtete Durchschnitt wird berechnet als:
/// Σ(Wert_i × Gewicht_i) / Σ(Gewicht_i)
const Map<KarmaDimension, double> kKarmaGewichtungen = {
  KarmaDimension.mitgefuehl: 1.2,
  KarmaDimension.ehrlichkeit: 1.0,
  KarmaDimension.mut: 0.9,
  KarmaDimension.grosszuegigkeit: 1.0,
  KarmaDimension.weisheit: 1.1,
  KarmaDimension.liebe: 1.3,
};

/// Summe aller Gewichtungsfaktoren (für normierte Durchschnittsberechnung).
/// Wird als Divisor in der gewichteten Mittelwertformel verwendet.
const double kGewichtungsSumme = 1.2 + 1.0 + 0.9 + 1.0 + 1.1 + 1.3; // = 6.5

// ═══════════════════════════════════════════════════════════════════════════════
// KARMA-HILFSFUNKTIONEN
// ═══════════════════════════════════════════════════════════════════════════════

/// Berechnet den gewichteten Karma-Durchschnitt aus einer Map von Dimension → Wert.
///
/// [werte] muss alle sechs [KarmaDimension]-Einträge enthalten.
/// Gibt 0.0 zurück, wenn die Map leer oder unvollständig ist.
double gewichtetenDurchschnittBerechnen(Map<KarmaDimension, double> werte) {
  if (werte.isEmpty) return 0.0;

  double gewichtetesSumme = 0.0;
  double gewichtSumme = 0.0;

  for (final eintrag in werte.entries) {
    final gewicht = kKarmaGewichtungen[eintrag.key] ?? 1.0;
    gewichtetesSumme += eintrag.value * gewicht;
    gewichtSumme += gewicht;
  }

  if (gewichtSumme == 0.0) return 0.0;
  return (gewichtetesSumme / gewichtSumme).clamp(kMinKarma, kMaxKarma);
}

/// Begrenzt einen Karma-Wert auf den gültigen Bereich [kMinKarma, kMaxKarma].
double karmaBegrenzen(double wert) => wert.clamp(kMinKarma, kMaxKarma);

/// Gibt zurück, ob ein Karma-Wert im positiven Bereich liegt.
bool istKarmaPositiv(double wert) => wert > kNeutralKarma;

/// Gibt zurück, ob ein Karma-Wert im negativen Bereich liegt.
bool istKarmaNegativ(double wert) => wert < kNeutralKarma;

/// Normiert einen Karma-Wert auf den Bereich [0.0, 1.0] für Fortschrittsanzeigen.
/// 0.0 = -100, 0.5 = 0, 1.0 = +100
double karmaNormieren(double wert) =>
    ((wert - kMinKarma) / (kMaxKarma - kMinKarma)).clamp(0.0, 1.0);
