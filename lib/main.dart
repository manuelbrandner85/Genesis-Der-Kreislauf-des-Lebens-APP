// Einstiegspunkt der GENESIS-App
// Initialisiert Hive (lokale Datenbank), Flutter-Bindings und startet die Anwendung
// mit einem Riverpod ProviderScope für reaktives State-Management.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:genesis_spiel/app/genesis_app.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hive-Box-Namen als Konstanten – verhindert Tippfehler bei Zugriffen
// ─────────────────────────────────────────────────────────────────────────────

/// Box für den aktuellen Spielstand (Seelen-Daten, Phase, Karma)
const String kSpielstandBox = 'spielstand';

/// Box für Benutzer-Einstellungen (Lautstärke, Sprache, Barrierefreiheit)
const String kEinstellungenBox = 'einstellungen';

/// Box für die komplette Karma-Verlaufshistorie (alle Entscheidungen)
const String kKarmaHistorieBox = 'karma_historie';

/// Box für die Seelen-Zyklen-Statistik (Anzahl absolvierter Leben)
const String kSeelenZyklenBox = 'seelen_zyklen';

/// Box für freigeschaltete Bibliotheks-Einträge und Errungenschaften
const String kBibliothekBox = 'bibliothek';

// ─────────────────────────────────────────────────────────────────────────────
// App-Einstiegspunkt
// ─────────────────────────────────────────────────────────────────────────────

/// Hauptfunktion – startet die GENESIS-App
///
/// Initialisierungsreihenfolge:
/// 1. Flutter-Bindings sicherstellen (für async-Operationen vor runApp)
/// 2. Hive für Flutter-Dateisystem initialisieren
/// 3. Alle benötigten Hive-Boxen öffnen
/// 4. App mit ProviderScope (Riverpod) starten
void main() async {
  // Flutter-Bindings initialisieren – Pflicht vor async-Operationen
  WidgetsFlutterBinding.ensureInitialized();

  // Hive für Flutter initialisieren – nutzt das App-Dokumentverzeichnis
  // auf allen Plattformen (Android, iOS, Desktop)
  await Hive.initFlutter();

  // ── Hive-Boxen öffnen ────────────────────────────────────────────────────
  // Jede Box wird beim Start geöffnet und bleibt für die App-Laufzeit bereit.
  // Map-Boxen speichern serialisierte Dart-Objekte als JSON-ähnliche Strukturen.

  // Spielstand: Aktuelle Spieler-Daten (Name, Phase, Karma-Werte, Zeitalter)
  await Hive.openBox<Map>(kSpielstandBox);

  // Einstellungen: Persistente Benutzereinstellungen
  await Hive.openBox<Map>(kEinstellungenBox);

  // Karma-Historie: Chronologische Liste aller Karma-Änderungen
  await Hive.openBox<Map>(kKarmaHistorieBox);

  // Seelen-Zyklen: Zähler und Metadaten aller abgeschlossenen Leben
  await Hive.openBox<int>(kSeelenZyklenBox);

  // Bibliothek: Freigeschaltete Erkenntnisse, Zeitalter-Texte und Errungenschaften
  await Hive.openBox<Map>(kBibliothekBox);

  // ── App starten ──────────────────────────────────────────────────────────
  // ProviderScope ist der Wurzel-Container aller Riverpod-Provider.
  // Ohne ihn können keine Provider gelesen oder überwacht werden.
  runApp(const ProviderScope(child: GenesisApp()));
}
