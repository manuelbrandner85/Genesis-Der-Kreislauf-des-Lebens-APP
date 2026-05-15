// router.dart
// GoRouter-Konfiguration für GENESIS: Der Kreislauf des Lebens.
// Definiert alle Routen, Navigationslogik, Phasen-Guards und Redirect-Logik.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/presentation/screens/splash_screen.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/screens/haupt_menue_screen.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/screens/neues_spiel_screen.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/screens/bibliothek_screen.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/screens/einstellungen_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Routen-Pfade als Konstanten
// ─────────────────────────────────────────────────────────────────────────────

/// Alle Routen-Pfade als unveränderliche Konstanten.
///
/// Verwendung: `context.go(AppRouten.hauptMenue)` statt Magic Strings.
abstract final class AppRouten {
  AppRouten._();

  /// Splash-Screen – Einstieg beim App-Start
  static const String splash = '/';

  /// Hauptmenü – zentraler Navigations-Hub
  static const String hauptMenue = '/hauptmenue';

  /// Neues Spiel starten – Name, Seelen-Code, Zeitalter wählen
  static const String neuesSpiel = '/neues-spiel';

  /// Gespeicherte Spielstände laden
  static const String spielLaden = '/spiel-laden';

  // ── Lebensphasen ──────────────────────────────────────────────────────────

  /// Phase 1 – Entstehung: Das Spermium-Rennen (Arcade-Minispiel)
  static const String phase1 = '/phase/1';

  /// Phase 2 – Formung: Embryonalentwicklung und erste Bewusstseinsmomente
  static const String phase2 = '/phase/2';

  /// Phase 3 – Kindheit: Alter 3–12, erste Charakterformung
  static const String phase3 = '/phase/3';

  /// Phase 4 – Jugend: Alter 13–18, Identitätsfindung und erste Liebe
  static const String phase4 = '/phase/4';

  /// Phase 5 – Erwachsen: Alter 19–40, Karriere und Beziehungen
  static const String phase5 = '/phase/5';

  /// Phase 6 – Reife: Alter 41–65, Weisheit und gesellschaftlicher Einfluss
  static const String phase6 = '/phase/6';

  /// Phase 7 – Jenseits-Vorbereitung: Alter 66+, Akzeptanz und Vermächtnis
  static const String phase7 = '/phase/7';

  /// Phase 8 – Kosmisch: Nach dem Tod, Übergang ins Jenseits
  static const String phase8 = '/phase/8';

  /// Phase 9 – Schöpfung: Entscheidung über nächste Inkarnation
  static const String phase9 = '/phase/9';

  // ── Spezial-Screens ───────────────────────────────────────────────────────

  /// Sterbe-Sequenz – cineastischer Übergang nach dem Tod
  static const String sterbeSequenz = '/sterbe-sequenz';

  /// Karma-Gericht – Auswertung des gelebten Lebens
  static const String karmaGericht = '/karma-gericht';

  /// Bibliothek – gesammelte Erkenntnisse und freigeschaltete Inhalte
  static const String bibliothek = '/bibliothek';

  /// Einstellungen – Audio, Steuerung, Sprache, Daten
  static const String einstellungen = '/einstellungen';

  /// Jenseits-Reich – verschiedene Bereiche nach dem Tod (:reich = Parameter)
  static const String jenseitsReich = '/jenseits/:reich';

  // ── Hilfsmethoden ─────────────────────────────────────────────────────────

  /// Gibt den vollständigen Pfad für eine Lebensphase zurück.
  /// [nummer] muss im Bereich 1–9 liegen.
  static String phase(int nummer) => '/phase/$nummer';

  /// Gibt den vollständigen Pfad für ein Jenseits-Reich zurück.
  /// Gültige Werte: 'limbus', 'elysium', 'harmonia', 'shadowlands', 'abyssus'
  static String jenseits(String reich) => '/jenseits/$reich';
}

// ─────────────────────────────────────────────────────────────────────────────
// Platzhalter-Screen für noch nicht vollständig implementierte Phasen
// ─────────────────────────────────────────────────────────────────────────────

/// Generischer Phasen-Screen für Phasen ohne eigene vollständige Implementierung.
///
/// Zeigt Phasenname, Beschreibung und einen Weiter-Button.
/// Wird durch die vollständigen Phasen-Implementierungen ersetzt.
class _PhasePlatzhalterScreen extends StatelessWidget {
  /// Anzeigename der Phase (z.B. "Phase II – Formung")
  final String phaseName;

  /// Atmosphärische Kurzbeschreibung der Phase
  final String phaseBeschreibung;

  /// Route, zu der der "Weiter"-Button navigiert
  final String naechsteRoute;

  const _PhasePlatzhalterScreen({
    required this.phaseName,
    required this.phaseBeschreibung,
    required this.naechsteRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Text(phaseName),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Phasen-Kreissymbol
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 2,
                  ),
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF2D1B69),
                      Color(0xFF0A0A0F),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFD700),
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),

              // Phasenname in goldener Cinzel-Schrift
              Text(
                phaseName,
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Beschreibung der Phase
              Text(
                phaseBeschreibung,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  color: Color(0xFF9CA3AF),
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Weiter-Button zur nächsten Phase oder zum Ziel-Screen
              ElevatedButton(
                onPressed: () => context.go(naechsteRoute),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF0A0A0F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'WEITER',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spiel-Laden-Screen (Platzhalter)
// ─────────────────────────────────────────────────────────────────────────────

/// Screen zum Laden gespeicherter Spielstände.
/// Zeigt alle in Hive gespeicherten Leben an.
class _SpielLadenScreen extends StatelessWidget {
  const _SpielLadenScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Gespeichertes Leben laden'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              color: Color(0xFF4B5563),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Keine gespeicherten Leben gefunden.',
              style: TextStyle(
                fontFamily: 'Lato',
                color: Color(0xFF9CA3AF),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Beginne ein neues Leben, um deine Seele zu formen.',
              style: TextStyle(
                fontFamily: 'Lato',
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => context.go(AppRouten.neuesSpiel),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFD700),
                side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: const Text(
                'NEUES LEBEN BEGINNEN',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sterbe-Sequenz-Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Cineastischer Übergangs-Screen nach dem Tod des Charakters.
///
/// Dunkles Design mit atmosphärischem Text und Übergang zum Karma-Gericht.
class _SterbeSequenzScreen extends StatelessWidget {
  const _SterbeSequenzScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Symbolische Auflösung
              const Text(
                '· · ·',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 48,
                  color: Color(0xFFFFD700),
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 40),

              // Atmosphärischer Sterbetext
              const Text(
                'Das Leben endet.',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 22,
                  color: Color(0xFFE8E8FF),
                  letterSpacing: 3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Das Bewusstsein bleibt.',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 18,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Die Seele trägt alles, was sie gelernt hat,\nin die Ewigkeit.',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.8,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),

              // Weiter zum Karma-Gericht
              ElevatedButton(
                onPressed: () => context.go(AppRouten.karmaGericht),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D1B69),
                  foregroundColor: const Color(0xFFE8E8FF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  side: const BorderSide(
                    color: Color(0xFF6A0DAD),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'VOR DAS KARMA-GERICHT',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Karma-Gericht-Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Screen für die Auswertung des gelebten Lebens.
///
/// Zeigt alle Karma-Dimensionen, das Gesamturteil und das zugewiesene
/// Jenseits-Reich. Öffnet den Weg zur nächsten Inkarnation.
class _KarmaGerichtScreen extends StatelessWidget {
  const _KarmaGerichtScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.8,
            colors: [
              Color(0xFF1A0F3C),
              Color(0xFF0A0A0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Waagen-Symbol für das Karma-Gericht
                  const Icon(
                    Icons.balance,
                    color: Color(0xFFFFD700),
                    size: 80,
                  ),
                  const SizedBox(height: 24),

                  // Titel des Karma-Gerichts
                  const Text(
                    'KARMA-GERICHT',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Die Waage der Seele',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Trennlinie
                  Container(
                    width: 200,
                    height: 1,
                    color: const Color(0xFF2D1B69),
                  ),
                  const SizedBox(height: 32),

                  // Gerichts-Text
                  const Text(
                    'Dein Leben wird gewogen.\nJede Entscheidung zählt.\nJede Tat hinterlässt eine Spur in der Ewigkeit.',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Urteil empfangen – weiter zum Jenseits-Reich
                  ElevatedButton(
                    onPressed: () =>
                        context.go(AppRouten.jenseits('limbus')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF0A0A0F),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'URTEIL EMPFANGEN',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bibliothek-Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Screen für die Bibliothek der Seelen.
///
/// Zeigt alle freigeschalteten Erkenntnisse, Zeitalter-Texte
/// und spirituellen Weisheiten aus abgeschlossenen Leben.
class _BibliothekScreen extends StatelessWidget {
  const _BibliothekScreen();

  @override
  Widget build(BuildContext context) {
    // Bibliotheks-Einträge – werden später dynamisch aus Hive geladen
    final eintraege = [
      {
        'titel': 'Das erste Leben',
        'beschreibung': 'Die Grundlagen des Kreislaufs',
        'status': 'Abgeschlossen',
        'icon': Icons.book,
      },
      {
        'titel': 'Zeitalter der Ritter',
        'beschreibung': 'Ehre, Mut und feudale Pflicht',
        'status': 'Entdeckt',
        'icon': Icons.shield,
      },
      {
        'titel': 'Kosmische Weisheiten',
        'beschreibung': 'Geheimnisse jenseits des Lebens',
        'status': 'Gesperrt',
        'icon': Icons.auto_awesome,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Bibliothek der Seelen'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: eintraege.length,
        itemBuilder: (context, index) {
          final eintrag = eintraege[index];
          final istGesperrt = eintrag['status'] == 'Gesperrt';

          return Card(
            color: const Color(0xFF111827),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: istGesperrt
                    ? const Color(0xFF1F2937)
                    : const Color(0xFF2D1B69),
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: istGesperrt
                      ? const Color(0xFF1F2937)
                      : const Color(0xFF1A0F3C),
                ),
                child: Icon(
                  eintrag['icon'] as IconData,
                  color: istGesperrt
                      ? const Color(0xFF4B5563)
                      : const Color(0xFFFFD700),
                  size: 22,
                ),
              ),
              title: Text(
                eintrag['titel'] as String,
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  color: istGesperrt
                      ? const Color(0xFF4B5563)
                      : const Color(0xFFF9FAFB),
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                eintrag['beschreibung'] as String,
                style: TextStyle(
                  fontFamily: 'Lato',
                  color: istGesperrt
                      ? const Color(0xFF374151)
                      : const Color(0xFF9CA3AF),
                  fontSize: 13,
                ),
              ),
              trailing: Icon(
                istGesperrt ? Icons.lock : Icons.chevron_right,
                color: istGesperrt
                    ? const Color(0xFF374151)
                    : const Color(0xFFFFD700),
              ),
              onTap: istGesperrt ? null : () {},
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Jenseits-Reich-Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Screen für das Jenseits-Reich nach dem Karma-Urteil.
///
/// Empfängt den Reich-Namen als URL-Parameter und passt
/// Farben, Text und Atmosphäre dynamisch an.
class _JenseitsReichScreen extends StatelessWidget {
  /// Name des Jenseits-Reiches (URL-Parameter :reich)
  final String reichName;

  const _JenseitsReichScreen({required this.reichName});

  /// Gibt den deutschen Anzeigenamen des Reiches zurück.
  String _getReichAnzeigename() {
    switch (reichName.toLowerCase()) {
      case 'limbus':
        return 'Der Limbus';
      case 'elysium':
        return 'Das Elysium';
      case 'harmonia':
        return 'Das Harmonia';
      case 'shadowlands':
        return 'Die Shadowlands';
      case 'abyssus':
        return 'Der Abyssus';
      default:
        return reichName.toUpperCase();
    }
  }

  /// Gibt die charakteristische Farbe des Reiches zurück.
  Color _getReichFarbe() {
    switch (reichName.toLowerCase()) {
      case 'limbus':
        return const Color(0xFF808080);
      case 'elysium':
        return const Color(0xFF87CEEB);
      case 'harmonia':
        return const Color(0xFF90EE90);
      case 'shadowlands':
        return const Color(0xFF4B0082);
      case 'abyssus':
        return const Color(0xFF8B0000);
      default:
        return const Color(0xFFFFD700);
    }
  }

  /// Gibt die atmosphärische Beschreibung des Reiches zurück.
  String _getReichBeschreibung() {
    switch (reichName.toLowerCase()) {
      case 'limbus':
        return 'Das Reich des Übergangs.\nUnentschiedene Seelen verweilen hier\nim ewigen Grau zwischen den Welten.';
      case 'elysium':
        return 'Das Reich ewiger Harmonie.\nNur reinste Seelen ruhen hier\nin vollkommener Erleuchtung.';
      case 'harmonia':
        return 'Das Reich der Ausgeglichenen.\nGute Seelen finden hier Ruhe,\nnatürliche Schönheit und wohlverdiente Freude.';
      case 'shadowlands':
        return 'Das Reich der Schatten.\nSeelen mit negativem Karma büßen hier\nihre Taten in ewiger Dunkelheit.';
      case 'abyssus':
        return 'Der tiefste Abgrund.\nNur die schwärzesten Seelen werden\nhier in ewiger Qual gefangen.';
      default:
        return 'Du befindest dich im Jenseits.\nEin neues Leben wartet.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reichFarbe = _getReichFarbe();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              reichFarbe.withValues(alpha: 0.12),
              const Color(0xFF0A0A0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reich-Symbol
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: reichFarbe.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      gradient: RadialGradient(
                        colors: [
                          reichFarbe.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.brightness_5,
                      color: reichFarbe,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Reich-Name
                  Text(
                    _getReichAnzeigename(),
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: reichFarbe,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Beschreibung des Reiches
                  Text(
                    _getReichBeschreibung(),
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),

                  // Neu geboren werden – zurück zum Hauptmenü
                  ElevatedButton(
                    onPressed: () => context.go(AppRouten.hauptMenue),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF0A0A0F),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'NEU GEBOREN WERDEN',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GoRouter-Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Riverpod-Provider für den GoRouter.
///
/// Der Router wird einmalig erstellt und im ProviderScope gecacht.
/// Alle Routen, Guards und Fehlerbehandlung sind hier konfiguriert.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Startroute: immer mit dem Splash-Screen beginnen
    initialLocation: AppRouten.splash,

    // Globaler Fehler-Handler für unbekannte Routen
    errorBuilder: (context, state) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'ROUTE NICHT GEFUNDEN',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 20,
                    color: Color(0xFFFFD700),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.uri.toString(),
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go(AppRouten.hauptMenue),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF0A0A0F),
                  ),
                  child: const Text(
                    'ZURÜCK ZUM HAUPTMENÜ',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },

    routes: [
      // ── Basis-Routen ──────────────────────────────────────────────────

      /// Splash-Screen – Intro mit Animation, lädt alle Assets
      GoRoute(
        path: AppRouten.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      /// Hauptmenü – zentraler Navigations-Hub mit Partikeleffekten
      GoRoute(
        path: AppRouten.hauptMenue,
        name: 'hauptMenue',
        builder: (context, state) => const HauptMenueScreen(),
      ),

      /// Neues Spiel – Namenseingabe, Seelen-Code, Zeitalter-Auswahl
      GoRoute(
        path: AppRouten.neuesSpiel,
        name: 'neuesSpiel',
        builder: (context, state) => const NeuesSpielScreen(),
      ),

      /// Spiel laden – gespeicherte Spielstände anzeigen
      GoRoute(
        path: AppRouten.spielLaden,
        name: 'spielLaden',
        builder: (context, state) => const _SpielLadenScreen(),
      ),

      // ── Lebensphasen ──────────────────────────────────────────────────

      /// Phase 1 – Entstehung: Spermium-Rennen (Arcade-Minispiel)
      GoRoute(
        path: AppRouten.phase1,
        name: 'phase1',
        // Phase 1 ist immer zugänglich – Startphase, kein Guard nötig
        redirect: (context, state) => null,
        builder: (context, state) => const _PhasePlatzhalterScreen(
          phaseName: 'Phase I – Entstehung',
          phaseBeschreibung:
              'Der Wettlauf ums Leben beginnt.\n'
              'Millionen von Seelen streben nach der Eizelle.\n'
              'Nur eine wird geboren.',
          naechsteRoute: AppRouten.phase2,
        ),
      ),

      /// Phase 2 – Formung: Embryonalentwicklung, erste Bewusstseinsmomente
      GoRoute(
        path: AppRouten.phase2,
        name: 'phase2',
        redirect: _phasenGuard(2),
        builder: (context, state) => const _PhasePlatzhalterScreen(
          phaseName: 'Phase II – Formung',
          phaseBeschreibung:
              'Neun Monate der Stille.\n'
              'Ein Körper entsteht aus dem Nichts.\n'
              'Das Bewusstsein erwacht langsam.',
          naechsteRoute: AppRouten.phase3,
        ),
      ),

      /// Phase 3 – Kindheit: Alter 3–12, Charakterformung durch Entscheidungen
      GoRoute(
        path: AppRouten.phase3,
        name: 'phase3',
        redirect: _phasenGuard(3),
        builder: (context, state) => const _PhasePlatzhalterScreen(
          phaseName: 'Phase III – Kindheit',
          phaseBeschreibung:
              'Die Welt ist neu und voller Wunder.\n'
              'Jede Entscheidung formt den Charakter.\n'
              'Das Karma beginnt zu wachsen.',
          naechsteRoute: AppRouten.phase4,
        ),
      ),

      /// Phase 4 – Jugend: Alter 13–18, Identitätsfindung und erste Liebe
      GoRoute(
        path: AppRouten.phase4,
        name: 'phase4',
        redirect: _phasenGuard(4),
        builder: (context, state) => const _PhasePlatzhalterScreen(
          phaseName: 'Phase IV – Jugend',
          phaseBeschreibung:
              'Zwischen Kind und Erwachsenem.\n'
              'Wer bin ich? Wo gehöre ich hin?\n'
              'Die ersten großen Entscheidungen.',
          naechsteRoute: AppRouten.phase5,
        ),
      ),

      /// Phase 5 – Erwachsen: Alter 19–40, Karriere und gesellschaftliche Rolle
      GoRoute(
        path: AppRouten.phase5,
        name: 'phase5',
        redirect: _phasenGuard(5),
        builder: (context, state) => const _PhasePlatzhalterScreen(
          phaseName: 'Phase V – Erwachsen',
          phaseBeschreibung:
              'Die Welt erwartet deine Beiträge.\n'
              'Liebe, Arbeit, Verantwortung – alles auf einmal.\n'
              'Welches Erbe willst du hinterlassen?',
          naechsteRoute: AppRouten.phase6,
        ),
      ),

      /// Phase 6 – Reife: Alter 41–65, Weisheit und gesellschaftlicher Einfluss
      GoRoute(
        path: AppRouten.phase6,
        name: 'phase6',
        redirect: _phasenGuard(6),
        builder: (context, state) => const _PhasePlatzhalterScreen(
          phaseName: 'Phase VI – Reife',
          phaseBeschreibung:
              'Die Früchte des Lebens reifen.\n'
              'Weisheit ersetzt Impulsivität.\n'
              'Was bleibt von dem, was du aufgebaut hast?',
          naechsteRoute: AppRouten.phase7,
        ),
      ),

      /// Phase 7 – Jenseits-Vorbereitung: Alter 66+, Akzeptanz und Vermächtnis
      GoRoute(
        path: AppRouten.phase7,
        name: 'phase7',
        redirect: _phasenGuard(7),
        builder: (context, state) => const _PhasePlatzhalterScreen(
          phaseName: 'Phase VII – Jenseits-Vorbereitung',
          phaseBeschreibung:
              'Das Ende nähert sich.\n'
              'Alles wird klar in der Stille des Alters.\n'
              'Frieden oder Reue – du entscheidest.',
          naechsteRoute: AppRouten.sterbeSequenz,
        ),
      ),

      /// Phase 8 – Kosmisch: Rückblick nach dem Tod, Übergang ins Jenseits
      GoRoute(
        path: AppRouten.phase8,
        name: 'phase8',
        redirect: _phasenGuard(8),
        builder: (context, state) => const _PhasePlatzhalterScreen(
          phaseName: 'Phase VIII – Kosmische Reise',
          phaseBeschreibung:
              'Zwischen den Welten.\n'
              'Das Leben erscheint wie ein Traum.\n'
              'Die kosmische Wahrheit offenbart sich.',
          naechsteRoute: AppRouten.phase9,
        ),
      ),

      /// Phase 9 – Schöpfung: Einfluss auf die nächste Inkarnation
      GoRoute(
        path: AppRouten.phase9,
        name: 'phase9',
        redirect: _phasenGuard(9),
        builder: (context, state) => const _PhasePlatzhalterScreen(
          phaseName: 'Phase IX – Schöpfung',
          phaseBeschreibung:
              'Der Kreislauf schließt sich.\n'
              'Du kannst nun das nächste Leben formen.\n'
              'Was gibst du der nächsten Seele mit?',
          naechsteRoute: AppRouten.hauptMenue,
        ),
      ),

      // ── Spezial-Screens ───────────────────────────────────────────────

      /// Sterbe-Sequenz – cineastischer Übergang nach dem Tod
      GoRoute(
        path: AppRouten.sterbeSequenz,
        name: 'sterbeSequenz',
        builder: (context, state) => const _SterbeSequenzScreen(),
      ),

      /// Karma-Gericht – Lebensauswertung und Jenseits-Zuweisung
      GoRoute(
        path: AppRouten.karmaGericht,
        name: 'karmaGericht',
        builder: (context, state) => const _KarmaGerichtScreen(),
      ),

      /// Bibliothek – freigeschaltete Erkenntnisse und Zeitalter-Texte
      GoRoute(
        path: AppRouten.bibliothek,
        name: 'bibliothek',
        builder: (context, state) => const BibliothekScreen(),
      ),

      /// Einstellungen – Audio, Steuerung, Sprache, Daten
      GoRoute(
        path: AppRouten.einstellungen,
        name: 'einstellungen',
        builder: (context, state) => const EinstellungenScreen(),
      ),

      /// Jenseits-Reich – atmosphärischer Screen je nach Karma-Urteil
      /// URL-Parameter :reich z.B. 'limbus', 'elysium', 'harmonia', etc.
      GoRoute(
        path: AppRouten.jenseitsReich,
        name: 'jenseitsReich',
        builder: (context, state) {
          // Reich-Parameter aus der URL extrahieren (Fallback: limbus)
          final reich = state.pathParameters['reich'] ?? 'limbus';
          return _JenseitsReichScreen(reichName: reich);
        },
      ),
    ],
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Phasen-Guard
// ─────────────────────────────────────────────────────────────────────────────

/// Erstellt eine GoRouter-Redirect-Funktion als Guard für Lebensphasen.
///
/// Verhindert das Überspringen von Phasen durch direkte URL-Eingabe.
/// Phasen sind nur zugänglich, wenn die vorherige Phase abgeschlossen ist.
///
/// [phase] – die Phasennummer, für die der Guard gilt (2–9)
///
/// TODO: Implementierung mit SpielZustandProvider verbinden, sobald
/// der Provider verfügbar ist. Dann SpielZustand.hoechsteFreigeschaltetPhase
/// prüfen und bei Verletzung zu AppRouten.hauptMenue umleiten.
GoRouterRedirect _phasenGuard(int phase) {
  return (BuildContext context, GoRouterState state) {
    // Phasen-Zugriffslogik:
    // Aktuell sind alle Phasen zugänglich (Entwicklungsphase).
    // Produktions-Implementierung:
    // ─────────────────────────────────────────────────────
    // final container = ProviderScope.containerOf(context);
    // final spielZustand = container.read(spielZustandProvider);
    // if (spielZustand.hoechsteFreigeschaltetPhase < phase) {
    //   return AppRouten.hauptMenue; // Weiterleitung wenn Phase gesperrt
    // }
    return null; // Null = keine Weiterleitung, Phase zugänglich
  };
}
