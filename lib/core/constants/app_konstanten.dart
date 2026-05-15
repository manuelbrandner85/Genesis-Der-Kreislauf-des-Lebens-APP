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
/// Jede Phase repräsentiert einen Lebensabschnitt mit eigener Mechanik,
/// verfügbaren Entscheidungen und Karma-Multiplikatoren. Die Phasen
/// durchläuft der Charakter chronologisch – von der Geburt bis zum Tod.
enum GamePhase {
  // ── Phase 1: Die Geburt ──────────────────────────────────────────────────
  /// Ankunft in der Welt. Familie, Zeitalter und erste Talente werden bestimmt.
  /// Keine aktiven Entscheidungen – rein erzählerisch mit Karma-Startwert.
  geburt(
    nummer: 1,
    anzeigeName: 'Die Geburt',
    beschreibung:
        'Eine neue Seele erblickt das Licht der Welt. Familie, '
        'Zeitalter und die ersten Talente werden vom Schicksal bestimmt.',
    karmaMultiplikator: 0.5,
    minAlter: 0,
    maxAlter: 0,
    istEntscheidungsPhase: false,
  ),

  // ── Phase 2: Die Kindheit ────────────────────────────────────────────────
  /// Erste Prägungen. Spielerische Entscheidungen formen Grundcharakter.
  /// Karma-Auswirkungen sind gedämpft (Kinder handeln aus Unwissenheit).
  kindheit(
    nummer: 2,
    anzeigeName: 'Die Kindheit',
    beschreibung:
        'Die ersten Jahre formen den Charakter. Spielerische Neugier, '
        'erste Freundschaften und unschuldige Entscheidungen.',
    karmaMultiplikator: 0.7,
    minAlter: 1,
    maxAlter: 12,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 3: Die Jugend ──────────────────────────────────────────────────
  /// Identitätsfindung, erste Liebe, Lehrzeit oder Schule.
  /// Mittlerer Karma-Multiplikator – Bewusstsein wächst.
  jugend(
    nummer: 3,
    anzeigeName: 'Die Jugend',
    beschreibung:
        'Zwischen Kindheit und Erwachsensein. Erste große Entscheidungen '
        'über Werte, Freundschaft und den eigenen Weg.',
    karmaMultiplikator: 0.9,
    minAlter: 13,
    maxAlter: 17,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 4: Der Aufbruch ────────────────────────────────────────────────
  /// Berufswahl, Auszug, erste Eigenverantwortung. Hohe Karma-Aktivität.
  aufbruch(
    nummer: 4,
    anzeigeName: 'Der Aufbruch',
    beschreibung:
        'Die Welt öffnet sich. Karriere, Reisen, neue Beziehungen – '
        'der erste große Schritt in die Eigenverantwortung.',
    karmaMultiplikator: 1.0,
    minAlter: 18,
    maxAlter: 25,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 5: Die Blüte ───────────────────────────────────────────────────
  /// Hochphase des Lebens. Familie, Karriere-Gipfel, tiefe Beziehungen.
  /// Höchster Karma-Multiplikator – voll verantwortliche Entscheidungen.
  bluetePunkt(
    nummer: 5,
    anzeigeName: 'Die Blüte',
    beschreibung:
        'Die goldene Zeit des Lebens. Liebe, Familie, Beruf und '
        'gesellschaftliche Verantwortung verlangen alles.',
    karmaMultiplikator: 1.2,
    minAlter: 26,
    maxAlter: 45,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 6: Die Prüfung ─────────────────────────────────────────────────
  /// Krise, Verlust, Wendepunkt. Bewährt sich der Charakter im Dunkel?
  pruefung(
    nummer: 6,
    anzeigeName: 'Die Prüfung',
    beschreibung:
        'Das Leben stellt auf die Probe. Verlust, Scheitern oder Versuchung – '
        'wie reagiert die Seele, wenn alles wackelt?',
    karmaMultiplikator: 1.3,
    minAlter: 30,
    maxAlter: 55,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 7: Die Weisheit ────────────────────────────────────────────────
  /// Rückblick, Weitergabe, Vermächtnis. Karma-Auswirkungen stark durch
  /// Weisheit und Reflexion – sowohl positiv als auch negativ möglich.
  weisheit(
    nummer: 7,
    anzeigeName: 'Die Weisheit',
    beschreibung:
        'Die Jahre bringen Klarheit. Was hat das Leben gelehrt? '
        'Wissen und Erfahrung werden weitergegeben.',
    karmaMultiplikator: 1.1,
    minAlter: 50,
    maxAlter: 70,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 8: Das Vermächtnis ─────────────────────────────────────────────
  /// Letzte große Entscheidungen: Wie soll man erinnert werden?
  /// Was hinterlässt man der Welt?
  vermaechtnis(
    nummer: 8,
    anzeigeName: 'Das Vermächtnis',
    beschreibung:
        'Was bleibt? Die letzte Gelegenheit, den eigenen Fußabdruck '
        'in der Welt zu hinterlassen – oder zu tilgen.',
    karmaMultiplikator: 1.0,
    minAlter: 65,
    maxAlter: 85,
    istEntscheidungsPhase: true,
  ),

  // ── Phase 9: Der Tod ─────────────────────────────────────────────────────
  /// Abschluss des Lebenszyklus. Letzter innerer Monolog, Karma-Abrechnung,
  /// Übergang ins Jenseits. Keine Entscheidungen mehr möglich.
  tod(
    nummer: 9,
    anzeigeName: 'Der Tod',
    beschreibung:
        'Der Vorhang fällt. Das Leben wird zur Erinnerung. '
        'Die Seele tritt vor das kosmische Gericht des Karma.',
    karmaMultiplikator: 0.0,
    minAlter: 1,
    maxAlter: 120,
    istEntscheidungsPhase: false,
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
  bool get istLetztPhase => this == GamePhase.tod;

  /// Gibt zurück, ob dies die erste Phase des Lebens ist.
  bool get istErstePhase => this == GamePhase.geburt;

  /// Findet eine Phase anhand ihrer Nummer (1–9).
  /// Gibt [geburt] zurück, wenn keine Übereinstimmung gefunden.
  static GamePhase vonNummer(int nummer) {
    return GamePhase.values.firstWhere(
      (p) => p.nummer == nummer,
      orElse: () => GamePhase.geburt,
    );
  }

  /// Gibt alle Phasen zurück, in denen aktiv entschieden wird.
  static List<GamePhase> get entscheidungsPhasen =>
      GamePhase.values.where((p) => p.istEntscheidungsPhase).toList();
}
