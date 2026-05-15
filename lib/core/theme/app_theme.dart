/// App-Theme-Konfiguration für GENESIS: Der Kreislauf des Lebens.
///
/// Definiert das globale MaterialApp-Dark-Theme mit dem kosmisch-mystischen
/// Farbschema von [AppFarben] und der Typografie von [AppTextStyles].
/// Alle Widget-Themes (Buttons, Karten, Dialoge, Inputs) sind hier zentral
/// konfiguriert.
library app_theme;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_farben.dart';
import 'app_text_styles.dart';

/// Globale Theme-Konfiguration für das GENESIS-Spiel.
///
/// Verwendung in der MaterialApp:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.dunkelTheme,
///   darkTheme: AppTheme.dunkelTheme,
///   themeMode: ThemeMode.dark,
/// )
/// ```
abstract final class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // HAUPT-DARK-THEME
  // ═══════════════════════════════════════════════════════════════════════════

  /// Das einzige, vollständig konfigurierte Dark-Theme des Spiels.
  static ThemeData get dunkelTheme {
    // ColorScheme als Grundlage für alle Material-3-Komponenten
    const colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppFarben.goldGlanz,
      onPrimary: AppFarben.kosmischSchwarz,
      primaryContainer: AppFarben.kosmischViolett,
      onPrimaryContainer: AppFarben.goldGlanz,
      secondary: AppFarben.mystischLila,
      onSecondary: AppFarben.text,
      secondaryContainer: Color(0xFF3D2B8A),
      onSecondaryContainer: AppFarben.text,
      tertiary: AppFarben.phaseAufbruch,
      onTertiary: AppFarben.kosmischSchwarz,
      error: AppFarben.fehler,
      onError: AppFarben.text,
      errorContainer: AppFarben.fehlerHintergrund,
      onErrorContainer: AppFarben.fehler,
      surface: AppFarben.oberflaeche,
      onSurface: AppFarben.text,
      surfaceContainerHighest: AppFarben.oberflaecheErhoben,
      onSurfaceVariant: AppFarben.textSekundaer,
      outline: AppFarben.nebelGrau,
      outlineVariant: AppFarben.trenner,
      shadow: AppFarben.kosmischSchwarz,
      scrim: AppFarben.scrim,
      inverseSurface: AppFarben.text,
      onInverseSurface: AppFarben.kosmischSchwarz,
      inversePrimary: AppFarben.goldDunkel,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,

      // ── Scaffold ──────────────────────────────────────────────────────────
      scaffoldBackgroundColor: AppFarben.hintergrund,

      // ── Typography ────────────────────────────────────────────────────────
      fontFamily: AppTextStyles.schriftLato,
      textTheme: _textTheme,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: _appBarTheme,

      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: _elevatedButtonTheme,

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: _outlinedButtonTheme,

      // ── TextButton ────────────────────────────────────────────────────────
      textButtonTheme: _textButtonTheme,

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: _cardTheme,

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: _dialogTheme,

      // ── BottomSheet ───────────────────────────────────────────────────────
      bottomSheetTheme: _bottomSheetTheme,

      // ── InputDecoration ───────────────────────────────────────────────────
      inputDecorationTheme: _inputDecorationTheme,

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppFarben.trenner,
        thickness: 1.0,
        space: 1.0,
      ),

      // ── ProgressIndicator ─────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppFarben.goldGlanz,
        linearTrackColor: AppFarben.nebelGrau,
        circularTrackColor: AppFarben.nebelGrau,
      ),

      // ── Slider ────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: AppFarben.goldGlanz,
        inactiveTrackColor: AppFarben.nebelGrau,
        thumbColor: AppFarben.goldGlanz,
        overlayColor: AppFarben.goldGlanz.withAlpha(30),
        valueIndicatorColor: AppFarben.kosmischViolett,
        valueIndicatorTextStyle: AppTextStyles.beschriftung.copyWith(
          color: AppFarben.goldGlanz,
        ),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppFarben.oberflaecheErhoben,
        selectedColor: AppFarben.mystischLila,
        disabledColor: AppFarben.nebelGrau.withAlpha(80),
        labelStyle: AppTextStyles.beschriftung,
        secondaryLabelStyle: AppTextStyles.beschriftung.copyWith(
          color: AppFarben.goldGlanz,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: AppFarben.nebelGrau, width: 0.5),
        ),
        secondarySelectedColor: AppFarben.goldGlanz,
        checkmarkColor: AppFarben.goldGlanz,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppFarben.oberflaecheErhoben,
        contentTextStyle: AppTextStyles.koerperKlein,
        actionTextColor: AppFarben.goldGlanz,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6.0,
      ),

      // ── Tooltip ───────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppFarben.oberflaecheErhoben,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: AppFarben.nebelGrau,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppFarben.kosmischSchwarz.withAlpha(180),
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        textStyle: AppTextStyles.beschriftung,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppFarben.mystischLila.withAlpha(60),
        textColor: AppFarben.text,
        iconColor: AppFarben.textSekundaer,
        titleTextStyle: AppTextStyles.koerper,
        subtitleTextStyle: AppTextStyles.koerperKlein,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),

      // ── Icon ──────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppFarben.textSekundaer,
        size: 24.0,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppFarben.goldGlanz,
        size: 24.0,
      ),

      // ── Switch & Checkbox & Radio ─────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppFarben.goldGlanz;
          }
          return AppFarben.nebelGrau;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppFarben.goldGlanz.withAlpha(80);
          }
          return AppFarben.nebelGrau.withAlpha(80);
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppFarben.goldGlanz;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppFarben.kosmischSchwarz),
        side: const BorderSide(color: AppFarben.nebelGrau, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppFarben.goldGlanz;
          }
          return AppFarben.nebelGrau;
        }),
      ),

      // ── TabBar ────────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppFarben.goldGlanz,
        unselectedLabelColor: AppFarben.textSekundaer,
        labelStyle: AppTextStyles.koerperKleinFett,
        unselectedLabelStyle: AppTextStyles.koerperKlein,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppFarben.goldGlanz,
            width: 2.0,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppFarben.trenner,
      ),

      // ── NavigationBar ─────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppFarben.tiefesBlau,
        indicatorColor: AppFarben.mystischLila.withAlpha(100),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.beschriftung.copyWith(
              color: AppFarben.goldGlanz,
            );
          }
          return AppTextStyles.beschriftung;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppFarben.goldGlanz,
              size: 24.0,
            );
          }
          return const IconThemeData(
            color: AppFarben.textSekundaer,
            size: 24.0,
          );
        }),
      ),

      // ── SystemUI Overlay ──────────────────────────────────────────────────
      // Statusleiste und Navigationsleiste werden dunkel gehalten.
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE THEME-KONFIGURATIONEN
  // ═══════════════════════════════════════════════════════════════════════════

  /// TextTheme – Material-3-kompatible Typografie-Zuordnung.
  static TextTheme get _textTheme => TextTheme(
        displayLarge: AppTextStyles.ueberschrift1,
        displayMedium: AppTextStyles.ueberschrift2,
        displaySmall: AppTextStyles.ueberschrift3,
        headlineLarge: AppTextStyles.ueberschrift3,
        headlineMedium: AppTextStyles.ueberschrift4,
        headlineSmall: AppTextStyles.phasenTitel,
        titleLarge: AppTextStyles.spielStatus,
        titleMedium: AppTextStyles.koerperGross,
        titleSmall: AppTextStyles.koerper,
        bodyLarge: AppTextStyles.koerperGross,
        bodyMedium: AppTextStyles.koerper,
        bodySmall: AppTextStyles.koerperKlein,
        labelLarge: AppTextStyles.buttonPrimaer,
        labelMedium: AppTextStyles.beschriftung,
        labelSmall: AppTextStyles.mikro,
      );

  /// AppBar-Theme – transparent mit goldenem Titel.
  static AppBarTheme get _appBarTheme => AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppFarben.text,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppFarben.kosmischSchwarz,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.ueberschrift4,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppFarben.goldGlanz,
          size: 24.0,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppFarben.goldGlanz,
          size: 24.0,
        ),
      );

  /// ElevatedButton-Theme – goldene Primärfarbe auf kosmisch-schwarzem Hintergrund.
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppFarben.goldGlanz,
          foregroundColor: AppFarben.kosmischSchwarz,
          disabledBackgroundColor: AppFarben.nebelGrau.withAlpha(120),
          disabledForegroundColor: AppFarben.textDeaktiviert,
          elevation: 4.0,
          shadowColor: AppFarben.goldGlanz.withAlpha(60),
          minimumSize: const Size(120.0, 52.0),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: AppTextStyles.buttonPrimaer,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppFarben.overlayHover;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppFarben.overlayGedrueckt;
            }
            return null;
          }),
        ),
      );

  /// OutlinedButton-Theme – goldener Rahmen, transparenter Hintergrund.
  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppFarben.goldGlanz,
          disabledForegroundColor: AppFarben.textDeaktiviert,
          minimumSize: const Size(120.0, 52.0),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          side: const BorderSide(color: AppFarben.goldGlanz, width: 1.5),
          textStyle: AppTextStyles.buttonSekundaer.copyWith(
            color: AppFarben.goldGlanz,
          ),
        ).copyWith(
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(
                color: AppFarben.textDeaktiviert,
                width: 1.0,
              );
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return const BorderSide(
                color: AppFarben.goldHell,
                width: 2.0,
              );
            }
            return const BorderSide(color: AppFarben.goldGlanz, width: 1.5);
          }),
        ),
      );

  /// TextButton-Theme – minimal, lila Akzent.
  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppFarben.mystischLila.withAlpha(220),
          disabledForegroundColor: AppFarben.textDeaktiviert,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          textStyle: AppTextStyles.buttonSekundaer,
        ),
      );

  /// Card-Theme – dunkle Oberfläche mit subtiler Erhöhung und Rahmen.
  static CardThemeData get _cardTheme => CardThemeData(
        color: AppFarben.oberflaeche,
        shadowColor: AppFarben.kosmischSchwarz.withAlpha(200),
        elevation: 4.0,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(
            color: Color(0xFF1F2937),
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      );

  /// Dialog-Theme – dunkles Modal mit goldenen Akzenten.
  static DialogThemeData get _dialogTheme => DialogThemeData(
        backgroundColor: AppFarben.oberflaeche,
        surfaceTintColor: Colors.transparent,
        elevation: 16.0,
        shadowColor: AppFarben.kosmischSchwarz,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(
            color: AppFarben.nebelGrau,
            width: 0.5,
          ),
        ),
        titleTextStyle: AppTextStyles.ueberschrift3.copyWith(
          color: AppFarben.goldGlanz,
          fontSize: 22.0,
        ),
        contentTextStyle: AppTextStyles.koerper,
        actionsPadding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        alignment: Alignment.center,
      );

  /// BottomSheet-Theme – dunkle Modalfolie von unten.
  static BottomSheetThemeData get _bottomSheetTheme =>
      const BottomSheetThemeData(
        backgroundColor: AppFarben.oberflaeche,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppFarben.oberflaeche,
        modalElevation: 16.0,
        elevation: 8.0,
        dragHandleColor: AppFarben.nebelGrau,
        dragHandleSize: Size(40.0, 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        clipBehavior: Clip.antiAlias,
      );

  /// InputDecoration-Theme – dunkle Felder mit goldenem Fokus-Rand.
  static InputDecorationTheme get _inputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppFarben.oberflaecheErhoben,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppFarben.nebelGrau, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppFarben.nebelGrau, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide:
              const BorderSide(color: AppFarben.goldGlanz, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppFarben.fehler, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppFarben.fehler, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: AppFarben.textDeaktiviert,
            width: 0.5,
          ),
        ),
        labelStyle: AppTextStyles.koerperKlein,
        hintStyle: AppTextStyles.koerperKlein.copyWith(
          color: AppFarben.textTertiaer,
        ),
        errorStyle: AppTextStyles.beschriftung.copyWith(
          color: AppFarben.fehler,
        ),
        helperStyle: AppTextStyles.beschriftung,
        prefixIconColor: AppFarben.textSekundaer,
        suffixIconColor: AppFarben.textSekundaer,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // HILFSMETHODEN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Erstellt einen BoxDecoration-Standard für erhöhte Spielkarten.
  static BoxDecoration kartenDecoration({
    Color? rahmenFarbe,
    double radius = 12.0,
    double elevation = 1.0,
  }) =>
      BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: rahmenFarbe ?? AppFarben.nebelGrau,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppFarben.kosmischSchwarz.withAlpha((elevation * 100).round()),
            blurRadius: elevation * 8.0,
            offset: Offset(0, elevation * 2.0),
          ),
        ],
      );

  /// Erstellt einen leuchtenden Glow-BoxDecoration für Jenseits-Reiche.
  static BoxDecoration jenseitsGlowDecoration(Color reichFarbe) => BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: reichFarbe.withAlpha(180), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: reichFarbe.withAlpha(60),
            blurRadius: 20.0,
            spreadRadius: 2.0,
          ),
        ],
      );

  /// SystemUI-Overlay für Game-Screens (maximale Immersion, dunkle Statusleiste).
  static void systemUiImmersivaAnwenden() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppFarben.kosmischSchwarz,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }
}
