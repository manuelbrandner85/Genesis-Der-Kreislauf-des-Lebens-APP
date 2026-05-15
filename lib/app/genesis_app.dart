// genesis_app.dart
// Haupt-App-Widget für GENESIS: Der Kreislauf des Lebens.
// Konfiguriert MaterialApp.router mit dunklem Thema, GoRouter-Navigation,
// Lokalisierung (Deutsch) und Gaming-optimierten Systemüberlagerungen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Schriftarten-Konstanten
// ─────────────────────────────────────────────────────────────────────────────

/// Hilfklasse für die im Spiel verwendeten Schriftfamilien.
class AppSchriften {
  AppSchriften._();

  /// Cinzel – epische Serifenschrift für Überschriften, Menüs und Phasennamen.
  static const String cinzel = 'Cinzel';

  /// Lato – humanistische Sans-Serif für lesbare Fließtexte und Beschreibungen.
  static const String lato = 'Lato';
}

// ─────────────────────────────────────────────────────────────────────────────
// App-Thema
// ─────────────────────────────────────────────────────────────────────────────

/// Zentrales Theme-Objekt für die Gaming-App.
///
/// Das dunkle Thema wird einmal bei App-Start erzeugt und
/// unveränderlich für die gesamte Laufzeit genutzt.
class AppTheme {
  AppTheme._();

  /// Erstellt das dunkle Gaming-Thema mit kosmischer Farbpalette.
  ///
  /// Verwendet Material 3, goldene Primärfarben, Cinzel-Schrift für
  /// Überschriften und Lato für Fließtexte.
  static ThemeData dunkelThema() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ── Farbschema ──────────────────────────────────────────────────────
      // Kosmisch dunkel mit goldenen Akzenten und mystischen Purpur-Tönen
      colorScheme: const ColorScheme.dark(
        primary: AppFarben.goldGlanz,
        primaryContainer: AppFarben.goldDunkel,
        secondary: AppFarben.mystischLila,
        secondaryContainer: AppFarben.kosmischViolett,
        surface: AppFarben.oberflaeche,
        surfaceContainerHighest: AppFarben.oberflaecheErhoben,
        error: AppFarben.fehler,
        onPrimary: AppFarben.kosmischSchwarz,
        onSecondary: AppFarben.text,
        onSurface: AppFarben.text,
        onError: Colors.white,
      ),

      // Scaffold-Hintergrund: tiefstes Kosmisch-Schwarz
      scaffoldBackgroundColor: AppFarben.kosmischSchwarz,

      // ── AppBar ──────────────────────────────────────────────────────────
      // Transparent für Gaming-Ästhetik – kein trennender Balken
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppFarben.text,
        titleTextStyle: TextStyle(
          fontFamily: AppSchriften.cinzel,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppFarben.goldGlanz,
          letterSpacing: 2.0,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppFarben.kosmischSchwarz,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // ── Text-Thema ──────────────────────────────────────────────────────
      // Cinzel für alle Überschriften (Display, Headline)
      // Lato für alle Fließtexte (Body, Label)
      textTheme: const TextTheme(
        // Große Display-Überschriften (z.B. "GENESIS"-Logo)
        displayLarge: TextStyle(
          fontFamily: AppSchriften.cinzel,
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: AppFarben.goldGlanz,
          letterSpacing: 4.0,
        ),
        displayMedium: TextStyle(
          fontFamily: AppSchriften.cinzel,
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: AppFarben.goldGlanz,
          letterSpacing: 3.0,
        ),
        displaySmall: TextStyle(
          fontFamily: AppSchriften.cinzel,
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: AppFarben.goldGlanz,
          letterSpacing: 2.0,
        ),
        // Abschnitts-Überschriften
        headlineLarge: TextStyle(
          fontFamily: AppSchriften.cinzel,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppFarben.text,
          letterSpacing: 1.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: AppSchriften.cinzel,
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: AppFarben.text,
          letterSpacing: 1.0,
        ),
        headlineSmall: TextStyle(
          fontFamily: AppSchriften.cinzel,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppFarben.text,
        ),
        // Karten-Titel
        titleLarge: TextStyle(
          fontFamily: AppSchriften.lato,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppFarben.text,
          letterSpacing: 0.5,
        ),
        titleMedium: TextStyle(
          fontFamily: AppSchriften.lato,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppFarben.text,
        ),
        titleSmall: TextStyle(
          fontFamily: AppSchriften.lato,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppFarben.textSekundaer,
        ),
        // Fließtexte und Beschreibungen
        bodyLarge: TextStyle(
          fontFamily: AppSchriften.lato,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppFarben.text,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppSchriften.lato,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppFarben.text,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: AppSchriften.lato,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppFarben.textSekundaer,
          height: 1.4,
        ),
        // Button-Labels und kleine Beschriftungen
        labelLarge: TextStyle(
          fontFamily: AppSchriften.cinzel,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppFarben.kosmischSchwarz,
          letterSpacing: 1.5,
        ),
        labelMedium: TextStyle(
          fontFamily: AppSchriften.lato,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppFarben.textSekundaer,
          letterSpacing: 1.0,
        ),
        labelSmall: TextStyle(
          fontFamily: AppSchriften.lato,
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: AppFarben.textDeaktiviert,
          letterSpacing: 0.8,
        ),
      ),

      // ── Button-Themen ───────────────────────────────────────────────────
      // Primäre Buttons: Gold mit dunklem Text (Call-to-Action)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppFarben.goldGlanz,
          foregroundColor: AppFarben.kosmischSchwarz,
          elevation: 8,
          shadowColor: AppFarben.goldGlanz.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontFamily: AppSchriften.cinzel,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
      ),

      // Sekundäre Buttons: Transparent mit goldenem Rand
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppFarben.goldGlanz,
          side: const BorderSide(color: AppFarben.goldGlanz, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),

      // ── Karten-Thema ────────────────────────────────────────────────────
      // Dunkle Karten mit subtilen kosmischen Rändern
      cardTheme: CardTheme(
        color: AppFarben.oberflaecheErhoben,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: Color(0xFF2A2A5A),
            width: 1,
          ),
        ),
      ),

      // ── Eingabefelder ───────────────────────────────────────────────────
      // Dunkel gefüllt mit goldenen Fokus-Rändern
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppFarben.oberflaecheErhoben,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppFarben.kosmischViolett),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppFarben.kosmischViolett,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppFarben.goldGlanz, width: 2),
        ),
        labelStyle: const TextStyle(color: AppFarben.textSekundaer),
        hintStyle: const TextStyle(color: AppFarben.textDeaktiviert),
        prefixIconColor: AppFarben.goldGlanz,
        suffixIconColor: AppFarben.textSekundaer,
      ),

      // ── Trennlinie ──────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A5A),
        thickness: 1,
      ),

      // ── Icon-Thema ──────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppFarben.goldGlanz,
        size: 24,
      ),

      // ── Snackbar-Thema ──────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppFarben.oberflaecheErhoben,
        contentTextStyle: const TextStyle(
          fontFamily: AppSchriften.lato,
          color: AppFarben.text,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GenesisApp – Haupt-App-Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Haupt-App-Widget – ConsumerWidget für Riverpod-Integration.
///
/// Konfiguriert:
/// - Vollbild-Gaming-Modus (Edge-to-Edge, nur Hochformat)
/// - Kosmisches Dunkel-Thema mit AppTheme.dunkelThema()
/// - GoRouter für deklarative URL-basierte Navigation
/// - Lokalisierung: Deutsch (primär), Englisch (Fallback)
/// - Debug-Banner ausgeblendet
class GenesisApp extends ConsumerWidget {
  const GenesisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GoRouter aus dem Riverpod-Provider beziehen
    final router = ref.watch(routerProvider);

    // ── Vollbild-Gaming-Konfiguration ────────────────────────────────────
    // Edge-to-Edge: App nutzt den gesamten Bildschirm inkl. Statusleiste
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    // Ausrichtung: Nur Hochformat – typisch für mobile Spiele
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Systemüberlagerungen: Statusleiste transparent, Navigationsleiste dunkel
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppFarben.kosmischSchwarz,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp.router(
      // App-Titel (wird im Task-Switcher angezeigt)
      title: 'GENESIS: Der Kreislauf des Lebens',

      // Debug-Banner deaktivieren – sieht in einem epischen Spiel unpassend aus
      debugShowCheckedModeBanner: false,

      // Dunkles kosmisches Thema als einziges Thema
      theme: AppTheme.dunkelThema(),
      darkTheme: AppTheme.dunkelThema(),
      themeMode: ThemeMode.dark,

      // GoRouter-Integration über routerConfig
      routerConfig: router,

      // ── Lokalisierung ──────────────────────────────────────────────────
      // Primärsprache: Deutsch – alle UI-Texte sind auf Deutsch verfasst
      locale: const Locale('de', 'DE'),
      supportedLocales: const [
        Locale('de', 'DE'), // Deutsch (Deutschland) – Primärsprache
        Locale('en', 'US'), // Englisch (USA) – Fallback
      ],
    );
  }
}
