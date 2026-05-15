/// Zentrale App-Konstanten für GENESIS: Der Kreislauf des Lebens.
///
/// Diese Datei enthält alle unveränderlichen Werte, die im gesamten Spiel
/// verwendet werden: App-Metadaten, Hive-Box-Bezeichner, Animations-Dauern
/// sowie die vollständige Definition der neun Spielphasen.
library app_konstanten;

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// APP-METADATEN
// ═══════════════════════════════════════════════════════════════════════════════

/// Vollständiger Anzeigename des Spiels.
const String kAppName = 'GENESIS: Der Kreislauf des Lebens';

/// Kurztitel für kompakte UI-Elemente (z. B. AppBar, Tabs).
const String kAppKurzname = 'GENESIS';

/// Aktuelle Versionsnummer (SemVer).
const String kVersion = '0.1.0';

/// Build-Nummer, wird beim Publizieren hochgezählt.
const int kBuildNummer = 1;

/// Copyright-Hinweis.
const String kUrheberrecht = '© 2024 Genesis Studio. Alle Rechte vorbehalten.';

// ═══════════════════════════════════════════════════════════════════════════════
// HIVE-BOX-BEZEICHNER
// ═══════════════════════════════════════════════════════════════════════════════
// Jede Box entspricht einer logischen Datentabelle in der lokalen Datenbank.
// Änderungen an diesen Strings erfordern eine Datenmigration.

/// Box für das permanente Spielerprofil (Seelen-Ebene).
const String kBoxSpielerProfil = 'spielerProfil';

/// Box für alle abgeschlossenen und laufenden Lebenszyklen.
const String kBoxZyklen = 'zyklen';

/// Box für Erinnerungen – emotionale Schlüsselmomente aus vergangenen Leben.
const String kBoxErinnerungen = 'erinnerungen';

/// Box für Gedanken – innere Monologe und Entscheidungsreflexionen.
const String kBoxGedanken = 'gedanken';

/// Box für alle Beziehungen (NPC-Verbindungen über alle Leben hinweg).
const String kBoxBeziehungen = 'beziehungen';

/// Box für Spieleinstellungen (Audio, Grafik, Sprache, Steuerung).
const String kBoxEinstellungen = 'einstellungen';

/// Box für Errungenschaften und Meilensteine.
const String kBoxErrungenschaften = 'errungenschaften';

/// Box für die Karma-Historie (chronologisches Protokoll aller Karma-Ereignisse).
const String kBoxKarmaHistorie = 'karmaHistorie';

// ═══════════════════════════════════════════════════════════════════════════════
// HIVE-TYPE-IDs
// ═══════════════════════════════════════════════════════════════════════════════
// TypeIds müssen einmalig und stabil bleiben – niemals nachträglich ändern!

/// TypeId für das SpielerProfil-Modell.
const int kTypeIdSpielerProfil = 0;

/// TypeId für den Lebenszyklus.
const int kTypeIdLebenszyklus = 1;

/// TypeId für eine Erinnerung.
const int kTypeIdErinnerung = 2;

/// TypeId für einen Gedanken.
const int kTypeIdGedanke = 3;

/// TypeId für eine Beziehung.
const int kTypeIdBeziehung = 4;

/// TypeId für ein Karma-Ereignis.
const int kTypeIdKarmaEreignis = 5;

/// TypeId für eine Errungenschaft.
const int kTypeIdErrungenschaft = 6;

/// TypeId für das GamePhase-Enum.
const int kTypeIdGamePhase = 10;

/// TypeId für das Zeitalter-Enum.
const int kTypeIdZeitalter = 11;

/// TypeId für das KarmaDimension-Enum.
const int kTypeIdKarmaDimension = 12;

// ═══════════════════════════════════════════════════════════════════════════════
// SPIELMECHANIK-KONSTANTEN
// ═══════════════════════════════════════════════════════════════════════════════

/// Maximale Anzahl an Erinnerungen, die ein Spieler gleichzeitig tragen kann
/// (übersteigen führt zum "Vergessen" der ältesten Erinnerungen).
const int kMaxErinnerungen = 12;

/// Anzahl der Karma-Dimensionen (entspricht KarmaDimension.values.length).
const int kAnzahlKarmaDimensionen = 6;

/// Standard-Startkapital in Spielwährung (Goldmünzen o. Ä.).
const int kStartkapital = 100;

/// Maximale Beziehungen, die ein Charakter gleichzeitig pflegen kann.
const int kMaxBeziehungen = 20;

/// Wahrscheinlichkeit (0.0–1.0) für ein zufälliges Schicksals-Ereignis pro Spielzug.
const double kSchicksalsWahrscheinlichkeit = 0.15;

/// Anzahl der Lebenszyklen, nach denen ein Jenseits-Urteil erzwungen wird.
const int kMaxLebenszyklen = 10;

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATIONS-DAUERN
// ═══════════════════════════════════════════════════════════════════════════════

/// Sehr kurze Micro-Animation (Tipp-Feedback, Highlight).
const Duration kAnimationSehnell = Duration(milliseconds: 150);

/// Standard-UI-Übergang (Buttons, Karten-Flip).
const Duration kAnimationStandard = Duration(milliseconds: 300);

/// Mittellange Animation (Phasenübergang, Modal-Einblendung).
const Duration kAnimationMittel = Duration(milliseconds: 600);

/// Lange, dramatische Animation (Zeitalter-Übergang, Tod-Sequenz).
const Duration kAnimationLang = Duration(milliseconds: 1200);

/// Epische Fade-In-Animation (Spielstart, Jenseits-Sequenz).
const Duration kAnimationEpisch = Duration(milliseconds: 2500);

/// Dauer einer Karma-Puls-Animation.
const Duration kKarmaPulsDauer = Duration(milliseconds: 800);

/// Dauer der Einblendung einer Gedankenblase.
const Duration kGedankenblasenDauer = Duration(milliseconds: 400);

/// Dauer für das Einblenden eines Phasen-Titels.
const Duration kPhasenTitelDauer = Duration(milliseconds: 900);

/// Wartezeit vor dem automatischen Weiterspielen nach einer Cutscene.
const Duration kAutoCutsceneWarte = Duration(seconds: 4);

// ═══════════════════════════════════════════════════════════════════════════════
// UI-LAYOUT-KONSTANTEN
// ═══════════════════════════════════════════════════════════════════════════════

/// Standard-Padding für Bildschirmränder.
const EdgeInsets kBildschirmPadding = EdgeInsets.symmetric(
  horizontal: 20.0,
  vertical: 16.0,
);

/// Standard-Innenabstand für Karten/Panels.
const EdgeInsets kKartenPadding = EdgeInsets.all(16.0);

/// Kompakter Innenabstand für kleine Widgets.
const EdgeInsets kKompaktPadding = EdgeInsets.all(8.0);

/// Eckenradius für Karten.
const double kKartenRadius = 12.0;

/// Eckenradius für Buttons.
const double kButtonRadius = 8.0;

/// Eckenradius für Dialog-Fenster.
const double kDialogRadius = 16.0;

/// Mindesthöhe für primäre Action-Buttons.
const double kButtonHoehe = 52.0;

/// Breite der Karma-Fortschrittsleiste.
const double kKarmaBarBreite = 280.0;

/// Höhe der Karma-Fortschrittsleiste.
const double kKarmaBarHoehe = 8.0;

// ═══════════════════════════════════════════════════════════════════════════════
// SPIELPHASEN (ENUM)
// ═══════════════════════════════════════════════════════════════════════════════

/// Die neun Phasen eines Lebens in GENESIS.
///
/// Jede Phase repräsentiert einen Lebensabschnitt mit eigener Spielmechanik.
/// Phase 1-6: Das Leben (Spielphasen), Phase 7: Jenseits, 8-9: Meta-Phasen.
enum GamePhase {
  // ── Phase 1: Die Entstehung ──────────────────────────────────────────────
  /// Spermium-Rennen mit Arcade-Mechanik in der Flame Engine.
  /// Die gewählte Route bestimmt die Basis-Attribute des gesamten Lebens.
  entstehung(
    nummer: 1,
    anzeigeName: 'Die Entstehung',
    beschreibung:
        'Das Rennen um das Leben. Millionen Konkurrenten – nur einer erreicht das Ziel. '
        'Deine Route bestimmt deine Basis-Attribute für dieses Leben.',
    karmaMultiplikator: 0.3,
    minAlter: 0,
    maxAlter: 0,
    istEntscheidungsPhase: false,
  ),

  // ── Phase 2: Die Formung ─────────────────────────────────────────────────
  /// Embryo-Phase mit Puzzle-Aufbau-Mechanik.
  /// Organe platzieren, Verbindungen herstellen, Herzschlag-Rhythmus.
  formung(
    nummer: 2,
    anzeigeName: 'Die Formung',
    beschreibung:
        'Der Körper entsteht. Puzzle für Puzzle, Organ für Organ. '
        'Die Geburt als cinematischer Moment ins Licht.',
    karmaMultiplikator: 0.4,
    minAlter: 0,
    maxAlter: 0,
    istEntscheidungsPhase: false,
  ),

  // ── Phase 3: Die Kindheit ────────────────────────────────────────────────
  /// Discovery-Exploration. Krabbeln → Laufen → Rennen.
  /// Erste moralische Entscheidungen mit gedämpftem Karma-Effekt.
  kindheit(
    nummer: 3,
    anzeigeName: 'Die Kindheit',
    beschreibung:
        'Die Welt beginnt verschwommen und wird langsam schärfer. '
        'Erste Freundschaften, Sprache und moralische Weichenstellungen.',
    karmaMultiplikator: 0.6,
    minAlter: 0,
    maxAlter: 12,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 4: Die Jugend ──────────────────────────────────────────────────
  /// Social-Simulation mit Strategie. Cliquen, erste Liebe, Identität.
  /// Skill-Tree für Bildung, Sport, Kunst und Soziales.
  jugend(
    nummer: 4,
    anzeigeName: 'Die Jugend',
    beschreibung:
        'Schule, Freundschaft, erste Liebe und Identitätsfindung. '
        'Das Cliquen-System und schwieriger werdende Entscheidungen.',
    karmaMultiplikator: 0.9,
    minAlter: 13,
    maxAlter: 18,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 5: Das Erwachsenenalter ────────────────────────────────────────
  /// Vollständige Lebenssimulation. 50+ Karrierepfade, Beziehungen,
  /// Familiengründung, Finanzen, mentale Gesundheit, Zufallsereignisse.
  erwachsen(
    nummer: 5,
    anzeigeName: 'Das Erwachsenenalter',
    beschreibung:
        'Die volle Komplexität des Lebens: Karriere, Familie, Finanzen, '
        'Reisen, Krankheit, Lottogewinn und die großen Krisen.',
    karmaMultiplikator: 1.2,
    minAlter: 19,
    maxAlter: 50,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 6: Die Reife ───────────────────────────────────────────────────
  /// Legacy-Strategie. Gesundheit als zentrale Ressource.
  /// Wissen weitergeben, Flashbacks, Tod auf dem Sterbebett.
  reife(
    nummer: 6,
    anzeigeName: 'Die Reife',
    beschreibung:
        'Wissen weitergeben, Loslassen lernen. Gesundheit wird zur '
        'wichtigsten Ressource. Die letzte Entscheidung auf dem Sterbebett.',
    karmaMultiplikator: 1.1,
    minAlter: 51,
    maxAlter: 120,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 7: Das Jenseits ────────────────────────────────────────────────
  /// 5 Reiche basierend auf dem Karma-Profil. Geister-Modus, Karma-Gericht,
  /// Verlorene Seelen helfen, Wettkampf der Seelen.
  jenseits(
    nummer: 7,
    anzeigeName: 'Das Jenseits',
    beschreibung:
        'Fünf Reiche warten. Elysium, Harmonia, Limbus, Shadowlands oder Abyssus – '
        'dein Karma entscheidet wohin. Das ist kein Ende.',
    karmaMultiplikator: 0.5,
    minAlter: 0,
    maxAlter: 0,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 8: Das Kosmische Bewusstsein ───────────────────────────────────
  /// Nach genug Zyklen erreichbar. Die Bibliothek offenbart sich vollständig.
  /// Vorbereitung für den Schöpfungsmodus.
  kosmisch(
    nummer: 8,
    anzeigeName: 'Kosmisches Bewusstsein',
    beschreibung:
        'Nach vielen Leben: Die Muster werden sichtbar. Die Seele erkennt '
        'den Kreislauf. Die Schöpfung wartet.',
    karmaMultiplikator: 0.0,
    minAlter: 0,
    maxAlter: 0,
    istEntscheidungsPhase: false,
  ),

  // ── Phase 9: Die Schöpfung ───────────────────────────────────────────────
  /// Geheimes Endgame. Eigene Welten erschaffen in denen andere leben können.
  /// Regeln, Zeitalter und Herausforderungen selbst designen.
  schoepfung(
    nummer: 9,
    anzeigeName: 'Die Schöpfung',
    beschreibung:
        'Das geheime Endgame. Erschaffe eigene Welten, setze Regeln '
        'und werde selbst zum Schöpfer des nächsten Kreislaufs.',
    karmaMultiplikator: 0.0,
    minAlter: 0,
    maxAlter: 0,
    istEntscheidungsPhase: true,
  );

  // ── Konstruktor ────────────────────────────────────────────────────────────

  const GamePhase({
    required this.nummer,
    required this.anzeigeName,
    required this.beschreibung,
    required this.karmaMultiplikator,
    required this.minAlter,
    required this.maxAlter,
    required this.istEntscheidungsPhase,
  });

  // ── Felder ─────────────────────────────────────────────────────────────────

  /// Phasennummer (1–9), entspricht der chronologischen Reihenfolge.
  final int nummer;

  /// Lesbarer Name für UI-Darstellung (Deutsch).
  final String anzeigeName;

  /// Kurzbeschreibung der Phase für Tooltip / Ladebildschirm.
  final String beschreibung;

  /// Multiplikator für Karma-Änderungen in dieser Phase.
  /// > 1.0 = Entscheidungen wirken stärker; < 1.0 = gedämpft.
  final double karmaMultiplikator;

  /// Unteres Altersende (inklusive) dieser Phase.
  final int minAlter;

  /// Oberes Altersende (inklusive) dieser Phase.
  final int maxAlter;

  /// Gibt an, ob der Spieler in dieser Phase aktiv Entscheidungen trifft.
  final bool istEntscheidungsPhase;

  // ── Hilfsmethoden ─────────────────────────────────────────────────────────

  /// Liefert die nächste Phase oder [null] wenn [tod] die letzte ist.
  GamePhase? get naechstePhase {
    final naechsteIndex = index + 1;
    if (naechsteIndex >= GamePhase.values.length) return null;
    return GamePhase.values[naechsteIndex];
  }

  /// Gibt zurück, ob dies die letzte Phase des Lebens ist.
  bool get istLetztPhase => this == GamePhase.jenseits;

  /// Gibt zurück, ob dies die erste Phase des Lebens ist.
  bool get istErstePhase => this == GamePhase.entstehung;

  /// Findet eine Phase anhand ihrer Nummer (1–9).
  /// Gibt [geburt] zurück, wenn keine Übereinstimmung gefunden.
  static GamePhase vonNummer(int nummer) {
    return GamePhase.values.firstWhere(
      (p) => p.nummer == nummer,
      orElse: () => GamePhase.entstehung,
    );
  }

  /// Gibt alle Phasen zurück, in denen aktiv entschieden wird.
  static List<GamePhase> get entscheidungsPhasen =>
      GamePhase.values.where((p) => p.istEntscheidungsPhase).toList();
}
