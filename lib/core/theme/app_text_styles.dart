/// Typography-System für GENESIS: Der Kreislauf des Lebens.
///
/// Alle Textstile verwenden ausschließlich die Schriftfamilien 'Cinzel'
/// (episch, historisch – für Überschriften) und 'Lato' (lesbar, modern –
/// für Fließtext). Die Stile sind auf das dunkle Spieldesign abgestimmt.
library app_text_styles;

import 'package:flutter/material.dart';
import 'app_farben.dart';

/// Zentrale Typografie-Konstanten für das gesamte GENESIS-Spiel.
///
/// Verwendung: `AppTextStyles.ueberschrift1`, `AppTextStyles.koerper` usw.
abstract final class AppTextStyles {
  // Privater Konstruktor – diese Klasse ist nicht instantiierbar.
  AppTextStyles._();

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHRIFTFAMILIEN-KONSTANTEN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Cinzel – Serifenschrift im Stil antiker Inschriften.
  /// Verwendet für alle Überschriften, Phasentitel, Jenseits-Reich-Namen.
  static const String schriftCinzel = 'Cinzel';

  /// Lato – Klare, humanistische Sans-Serif-Schrift.
  /// Verwendet für Fließtext, Beschreibungen, Dialoge, UI-Labels.
  static const String schriftLato = 'Lato';

  // ═══════════════════════════════════════════════════════════════════════════
  // ÜBERSCHRIFTEN – Cinzel, goldener Glanz, epische Präsenz
  // ═══════════════════════════════════════════════════════════════════════════

  /// Überschrift 1 – Haupttitel auf Splash- und Menü-Screens.
  /// Größte Textstufe, maximale epische Wirkung.
  /// Verwendung: App-Titel "GENESIS", Jenseits-Reich-Ankündigungen.
  static const TextStyle ueberschrift1 = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 48.0,
    fontWeight: FontWeight.w700,
    color: AppFarben.goldGlanz,
    letterSpacing: 4.0,
    height: 1.15,
    shadows: [
      Shadow(
        color: Color(0x99FFD700), // Goldener Glow-Schatten
        blurRadius: 12.0,
        offset: Offset(0, 0),
      ),
    ],
  );

  /// Überschrift 2 – Bildschirmtitel, Kapitelnamen, Zeitalter-Ankündigungen.
  static const TextStyle ueberschrift2 = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 36.0,
    fontWeight: FontWeight.w600,
    color: AppFarben.goldGlanz,
    letterSpacing: 3.0,
    height: 1.2,
    shadows: [
      Shadow(
        color: Color(0x66FFD700),
        blurRadius: 8.0,
        offset: Offset(0, 0),
      ),
    ],
  );

  /// Überschrift 3 – Abschnittstittel, Karten-Header, Dialog-Titel.
  static const TextStyle ueberschrift3 = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: AppFarben.text,
    letterSpacing: 2.0,
    height: 1.25,
  );

  /// Überschrift 4 – Unterabschnitte, Listen-Header, Panel-Titel.
  static const TextStyle ueberschrift4 = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppFarben.text,
    letterSpacing: 1.5,
    height: 1.3,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // KÖRPERTEXT – Lato, gut lesbar auf dunklem Hintergrund
  // ═══════════════════════════════════════════════════════════════════════════

  /// Körpertext Groß – für wichtige Spielbeschreibungen, Intro-Texte.
  static const TextStyle koerperGross = TextStyle(
    fontFamily: schriftLato,
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
    color: AppFarben.text,
    letterSpacing: 0.3,
    height: 1.6,
  );

  /// Körpertext – Standard-Lesegröße für Dialoge, Beschreibungen, Ereignisse.
  static const TextStyle koerper = TextStyle(
    fontFamily: schriftLato,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppFarben.text,
    letterSpacing: 0.2,
    height: 1.55,
  );

  /// Körpertext Kursiv – für innere Monologe, Gedanken, Erinnerungen.
  static const TextStyle koerperKursiv = TextStyle(
    fontFamily: schriftLato,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppFarben.textSekundaer,
    letterSpacing: 0.2,
    height: 1.6,
  );

  /// Körpertext Klein – für Kurzinfos, Tooltips, Nebentext.
  static const TextStyle koerperKlein = TextStyle(
    fontFamily: schriftLato,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppFarben.textSekundaer,
    letterSpacing: 0.1,
    height: 1.5,
  );

  /// Körpertext Klein Fett – für hervorgehobenen Nebentext, Labels.
  static const TextStyle koerperKleinFett = TextStyle(
    fontFamily: schriftLato,
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    color: AppFarben.text,
    letterSpacing: 0.3,
    height: 1.5,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BESCHRIFTUNGEN & LABELS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Beschriftung – für Formularfelder, Chip-Labels, Icon-Beschriftungen.
  static const TextStyle beschriftung = TextStyle(
    fontFamily: schriftLato,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppFarben.textSekundaer,
    letterSpacing: 0.5,
    height: 1.4,
  );

  /// Beschriftung Großbuchstaben – für Kategoriebezeichnungen, Status-Chips.
  static const TextStyle beschriftungGross = TextStyle(
    fontFamily: schriftLato,
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    color: AppFarben.textSekundaer,
    letterSpacing: 1.2,
    height: 1.4,
  );

  /// Mikro-Text – für rechtliche Hinweise, Versionsnummern, minimalste Labels.
  static const TextStyle mikro = TextStyle(
    fontFamily: schriftLato,
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
    color: AppFarben.textTertiaer,
    letterSpacing: 0.3,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPIEL-SPEZIFISCHE STILE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Spielstatus-Anzeige – für Karma-Werte, Alter, Vermögen im HUD.
  /// Groß, fett, gut lesbar beim schnellen Überblick.
  static const TextStyle spielStatus = TextStyle(
    fontFamily: schriftLato,
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: AppFarben.text,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Spielstatus Wert – der eigentliche Zahlenwert im HUD (z. B. "+75").
  static const TextStyle spielStatusWert = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    color: AppFarben.goldGlanz,
    letterSpacing: 1.0,
    height: 1.2,
  );

  /// Phasentitel – angezeigt beim Phasenübergang (z. B. "Die Blüte").
  /// Cinzel mit dramatischem Letter-Spacing für Cutscene-Wirkung.
  static const TextStyle phasenTitel = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    color: AppFarben.goldGlanz,
    letterSpacing: 5.0,
    height: 1.2,
    shadows: [
      Shadow(
        color: Color(0x80FFD700),
        blurRadius: 16.0,
        offset: Offset(0, 2),
      ),
      Shadow(
        color: Color(0x40000000),
        blurRadius: 4.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  /// Jenseits-Titel – für die Ankündigung des Jenseits-Reiches nach dem Tod.
  static const TextStyle jenseitsTitel = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 40.0,
    fontWeight: FontWeight.w700,
    color: AppFarben.text,
    letterSpacing: 6.0,
    height: 1.15,
  );

  /// Entscheidungstext – für Entscheidungsoptionen im Spiel (A/B/C-Auswahl).
  static const TextStyle entscheidung = TextStyle(
    fontFamily: schriftLato,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    color: AppFarben.text,
    letterSpacing: 0.2,
    height: 1.5,
  );

  /// Gedankentext – für den inneren Monolog und philosophische Reflexionen.
  /// Kursiv und leicht gedämpft für eine träumerische Wirkung.
  static const TextStyle gedanke = TextStyle(
    fontFamily: schriftLato,
    fontSize: 15.0,
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.italic,
    color: AppFarben.textSekundaer,
    letterSpacing: 0.3,
    height: 1.65,
  );

  /// NPC-Dialogtext – für Gespräche mit Nicht-Spieler-Charakteren.
  static const TextStyle npcDialog = TextStyle(
    fontFamily: schriftLato,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppFarben.text,
    letterSpacing: 0.1,
    height: 1.6,
  );

  /// NPC-Name – der Name des sprechenden NPCs über dem Dialogtext.
  static const TextStyle npcName = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppFarben.goldGlanz,
    letterSpacing: 1.5,
    height: 1.3,
  );

  /// Karma-Änderungs-Text – "+15 Karma" oder "-8 Karma" als Popup.
  static const TextStyle karmaAenderung = TextStyle(
    fontFamily: schriftLato,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.2,
    // Farbe wird dynamisch gesetzt (positiv/negativ)
  );

  /// Zeitalter-Bezeichnung – subtile Anzeige des aktuellen Zeitalters.
  static const TextStyle zeitalterBezeichnung = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    color: AppFarben.textSekundaer,
    letterSpacing: 2.5,
    height: 1.3,
  );

  /// Button-Text Primär – für Haupt-Action-Buttons.
  static const TextStyle buttonPrimaer = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    color: AppFarben.kosmischSchwarz,
    letterSpacing: 1.5,
    height: 1.0,
  );

  /// Button-Text Sekundär – für sekundäre Buttons und Textlinks.
  static const TextStyle buttonSekundaer = TextStyle(
    fontFamily: schriftLato,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppFarben.text,
    letterSpacing: 0.5,
    height: 1.0,
  );

  /// Erinnerungs-Titel – für Überschriften von Erinnerungs-Karten.
  static const TextStyle erinnerungsTitel = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppFarben.goldGlanz,
    letterSpacing: 1.0,
    height: 1.3,
  );

  /// Zitat / Motto – für epische Zitate auf Ladebildschirmen.
  static const TextStyle zitat = TextStyle(
    fontFamily: schriftCinzel,
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppFarben.textSekundaer,
    letterSpacing: 0.5,
    height: 1.7,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HILFSMETHODEN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gibt den [koerper]-Stil mit einer benutzerdefinierten [farbe] zurück.
  static TextStyle koerperMitFarbe(Color farbe) =>
      koerper.copyWith(color: farbe);

  /// Gibt den [spielStatus]-Stil mit einer benutzerdefinierten [farbe] zurück.
  static TextStyle spielStatusMitFarbe(Color farbe) =>
      spielStatus.copyWith(color: farbe);

  /// Gibt den [karmaAenderung]-Stil mit der korrekten Karma-Farbe zurück.
  /// Positiver Wert → [AppFarben.karmaPositiv], negativer → [AppFarben.karmaNegatv].
  static TextStyle karmaAenderungMitWert(double wert) => karmaAenderung.copyWith(
        color: wert >= 0 ? AppFarben.karmaPositiv : AppFarben.karmaNegatv,
      );

  /// Gibt den [ueberschrift3]-Stil mit einer benutzerdefinierten Phasenfarbe zurück.
  static TextStyle phasenTitelMitFarbe(Color farbe) =>
      phasenTitel.copyWith(color: farbe);
}
