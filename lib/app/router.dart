// GoRouter-Konfiguration für GENESIS
// Definiert alle Routen und Navigationslogik des Spiels

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_spiel/presentation/screens/splash_screen.dart';
import 'package:genesis_spiel/presentation/screens/haupt_menue_screen.dart';
import 'package:genesis_spiel/presentation/screens/neues_spiel_screen.dart';

// Routen-Pfade als Konstanten – vermeidet Tippfehler
class AppRouten {
  static const String splash = '/';
  static const String hauptMenue = '/hauptmenue';
  static const String neuesSpiel = '/neues-spiel';
  static const String spielLaden = '/spiel-laden';
  static const String phase1 = '/phase/1';
  static const String phase2 = '/phase/2';
  static const String phase3 = '/phase/3';
  static const String phase4 = '/phase/4';
  static const String phase5 = '/phase/5';
  static const String phase6 = '/phase/6';
  static const String phase7 = '/phase/7';
  static const String phase8 = '/phase/8';
  static const String phase9 = '/phase/9';
  static const String sterbeSequenz = '/sterbe-sequenz';
  static const String karmaGericht = '/karma-gericht';
  static const String bibliothek = '/bibliothek';
  static const String jenseitsReich = '/jenseits/:reich';

  /// Gibt den Pfad für eine bestimmte Lebensphase zurück
  static String phase(int nummer) => '/phase/$nummer';

  /// Gibt den Pfad für ein bestimmtes Jenseits-Reich zurück
  static String jenseits(String reich) => '/jenseits/$reich';
}

// Platzhalter-Screens für noch nicht implementierte Phasen
// Diese werden später durch die vollständigen Implementierungen ersetzt

class _PhasePlatzhalterScreen extends StatelessWidget {
  final String phaseName;
  final String phaseBeschreibung;
  final String naechsteRoute;

  const _PhasePlatzhalterScreen({
    required this.phaseName,
    required this.phaseBeschreibung,
    required this.naechsteRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        title: Text(phaseName),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFD700),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Phasen-Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 2,
                  ),
                  color: const Color(0xFF0A0A2E),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFD700),
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              // Phasenname
              Text(
                phaseName,
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Phasenbeschreibung
              Text(
                phaseBeschreibung,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  color: Color(0xFF9090BB),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Weiter-Button
              ElevatedButton(
                onPressed: () => context.go(naechsteRoute),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF050510),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
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

// Platzhalter für SpielLaden-Screen
class _SpielLadenScreen extends StatelessWidget {
  const _SpielLadenScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        title: const Text('Gespeichertes Leben laden'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFD700),
      ),
      body: const Center(
        child: Text(
          'Keine gespeicherten Leben gefunden.',
          style: TextStyle(
            fontFamily: 'Lato',
            color: Color(0xFF9090BB),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Platzhalter für Sterbe-Sequenz
class _SterbeSequenzScreen extends StatelessWidget {
  const _SterbeSequenzScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '...',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 48,
                color: Color(0xFFFFD700),
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Das Leben endet.\nDas Bewusstsein bleibt.',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                color: Color(0xFF9090BB),
                height: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: () => context.go(AppRouten.karmaGericht),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A0DAD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'VOR DAS KARMA-GERICHT',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Platzhalter für Karma-Gericht
class _KarmaGerichtScreen extends StatelessWidget {
  const _KarmaGerichtScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        title: const Text('Das Karma-Gericht'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFD700),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.balance,
              color: Color(0xFFFFD700),
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'KARMA-GERICHT',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 32,
                color: Color(0xFFFFD700),
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dein Leben wird gewogen.\nJede Entscheidung zählt.',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                color: Color(0xFF9090BB),
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.go(AppRouten.jenseits('limbus')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF050510),
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
    );
  }
}

// Platzhalter für Bibliothek
class _BibliothekScreen extends StatelessWidget {
  const _BibliothekScreen();

  @override
  Widget build(BuildContext context) {
    // Bibliothek-Einträge – werden später aus Hive geladen
    final eintraege = [
      {'titel': 'Das erste Leben', 'status': 'Abgeschlossen'},
      {'titel': 'Zeitalter der Ritter', 'status': 'Entdeckt'},
      {'titel': 'Kosmische Weisheiten', 'status': 'Gesperrt'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        title: const Text('Bibliothek der Seelen'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFD700),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: eintraege.length,
        itemBuilder: (context, index) {
          final eintrag = eintraege[index];
          return Card(
            color: const Color(0xFF1A1A3E),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.book, color: Color(0xFFFFD700)),
              title: Text(
                eintrag['titel']!,
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  color: Color(0xFFE8E8FF),
                ),
              ),
              subtitle: Text(
                eintrag['status']!,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  color: Color(0xFF9090BB),
                ),
              ),
              trailing: eintrag['status'] == 'Gesperrt'
                  ? const Icon(Icons.lock, color: Color(0xFF444466))
                  : const Icon(Icons.chevron_right, color: Color(0xFFFFD700)),
            ),
          );
        },
      ),
    );
  }
}

// Platzhalter für Jenseits-Reich
class _JenseitsReichScreen extends StatelessWidget {
  final String reichName;

  const _JenseitsReichScreen({required this.reichName});

  /// Gibt den Anzeigenamen für ein Jenseits-Reich zurück
  String _getReichAnzeigename() {
    switch (reichName) {
      case 'limbus':
        return 'Der Limbus';
      case 'elysium':
        return 'Das Elysium';
      case 'tartarus':
        return 'Der Tartarus';
      case 'nirvana':
        return 'Das Nirvana';
      case 'purgatorium':
        return 'Das Purgatorium';
      default:
        return reichName.toUpperCase();
    }
  }

  /// Gibt die Farbe für ein Jenseits-Reich zurück
  Color _getReichFarbe() {
    switch (reichName) {
      case 'limbus':
        return const Color(0xFF9090BB);
      case 'elysium':
        return const Color(0xFFFFD700);
      case 'tartarus':
        return const Color(0xFFF44336);
      case 'nirvana':
        return const Color(0xFF4CAF50);
      case 'purgatorium':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              _getReichFarbe().withValues(alpha: 0.1),
              const Color(0xFF050510),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getReichAnzeigename(),
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _getReichFarbe(),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Du befindest dich im Jenseits.\nEin neues Leben wartet.',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  color: Color(0xFF9090BB),
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () => context.go(AppRouten.hauptMenue),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF050510),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'NEU GEBOREN WERDEN',
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
    );
  }
}

/// Riverpod-Provider für den GoRouter
/// Stellt den Router im gesamten Widget-Baum zur Verfügung
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Startroute: Splash-Screen
    initialLocation: AppRouten.splash,

    // Fehler-Handler: Weiterleitung zum Hauptmenü bei unbekannter Route
    errorBuilder: (context, state) {
      return Scaffold(
        backgroundColor: const Color(0xFF050510),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFF44336),
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
                  color: Color(0xFF9090BB),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go(AppRouten.hauptMenue),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF050510),
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
      );
    },

    routes: [
      // ── Basis-Routen ────────────────────────────────────────────────────

      /// Splash-Screen: Zeigt das Genesis-Logo und lädt Assets
      GoRoute(
        path: AppRouten.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      /// Hauptmenü: Zentraler Hub mit allen Spieloptionen
      GoRoute(
        path: AppRouten.hauptMenue,
        name: 'hauptMenue',
        builder: (context, state) => const HauptMenueScreen(),
      ),

      /// Neues Spiel: Name eingeben, Seelen-Code erhalten, Zeitalter wählen
      GoRoute(
        path: AppRouten.neuesSpiel,
        name: 'neuesSpiel',
        builder: (context, state) => const NeuesSpielScreen(),
      ),

      /// Spiel laden: Gespeicherte Spielstände anzeigen
      GoRoute(
        path: AppRouten.spielLaden,
        name: 'spielLaden',
        builder: (context, state) => const _SpielLadenScreen(),
      ),

      // ── Lebensphasen ────────────────────────────────────────────────────

      /// Phase 1 – Entstehung: Das Spermium-Rennen
      /// Schnelles Arcade-Minispiel: Spermium navigiert zur Eizelle
      GoRoute(
        path: AppRouten.phase1,
        name: 'phase1',
        redirect: (context, state) {
          // Phase 1 ist immer zugänglich (Startphase)
          return null;
        },
        builder: (context, state) => const _PhasePlatzhalterScreen(
          phaseName: 'Phase I – Entstehung',
          phaseBeschreibung:
              'Der Wettlauf ums Leben beginnt.\n'
              'Millionen von Seelen streben nach der Eizelle.\n'
              'Nur eine wird geboren.',
          naechsteRoute: AppRouten.phase2,
        ),
      ),

      /// Phase 2 – Formung: Die Embryonalentwicklung
      /// Meditation und erste Bewusstseinsmomente
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

      /// Phase 3 – Kindheit: Alter 3-12
      /// Entscheidungsbasiertes Gameplay mit Kindheits-Events
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

      /// Phase 4 – Jugend: Alter 13-18
      /// Identitätsfindung, erste Liebe, Gruppendruck
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

      /// Phase 5 – Erwachsen: Alter 19-40
      /// Karriere, Beziehungen, gesellschaftliche Verantwortung
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

      /// Phase 6 – Reife: Alter 41-65
      /// Weisheit, Bilanz, gesellschaftlicher Einfluss
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

      /// Phase 7 – Jenseits-Vorbereitung: Alter 66+
      /// Akzeptanz, Vermächtnis, spirituelle Reife
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

      /// Phase 8 – Kosmisch: Nach dem Tod, Übergang ins Jenseits
      /// Rückblick auf das gelebte Leben
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

      /// Phase 9 – Schöpfung: Entscheidung über nächste Inkarnation
      /// Einfluss auf die nächste Spielrunde
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

      // ── Spezial-Screens ─────────────────────────────────────────────────

      /// Sterbe-Sequenz: Cineastischer Übergang nach dem Tod
      GoRoute(
        path: AppRouten.sterbeSequenz,
        name: 'sterbeSequenz',
        builder: (context, state) => const _SterbeSequenzScreen(),
      ),

      /// Karma-Gericht: Auswertung des gelebten Lebens
      GoRoute(
        path: AppRouten.karmaGericht,
        name: 'karmaGericht',
        builder: (context, state) => const _KarmaGerichtScreen(),
      ),

      /// Bibliothek: Gesammelte Erkenntnisse und freigeschaltete Inhalte
      GoRoute(
        path: AppRouten.bibliothek,
        name: 'bibliothek',
        builder: (context, state) => const _BibliothekScreen(),
      ),

      /// Jenseits-Reich: Verschiedene Bereiche nach dem Tod
      /// Parameter :reich z.B. 'limbus', 'elysium', 'tartarus', 'nirvana'
      GoRoute(
        path: AppRouten.jenseitsReich,
        name: 'jenseitsReich',
        builder: (context, state) {
          // Reich-Parameter aus der URL extrahieren
          final reich = state.pathParameters['reich'] ?? 'limbus';
          return _JenseitsReichScreen(reichName: reich);
        },
      ),
    ],
  );
});

/// Guard-Funktion für Lebensphasen
/// Verhindert das Überspringen von Phasen durch direkte URL-Eingabe
/// TODO: Implementierung mit SpielZustand-Provider wenn verfügbar
GoRouterRedirect _phasenGuard(int phase) {
  return (BuildContext context, GoRouterState state) {
    // Prüfen ob vorherige Phase abgeschlossen wurde
    // Hier wird später der SpielZustand-Provider eingebunden
    // Für jetzt: Alle Phasen zugänglich (Entwicklungsphase)
    // Beispiel-Implementierung für später:
    // final spielZustand = ref.read(spielZustandProvider);
    // if (spielZustand.hoechsteFreigeschaltetPhase < phase) {
    //   return AppRouten.hauptMenue; // Weiterleitung zum Hauptmenü
    // }
    return null; // Keine Weiterleitung – Phase zugänglich
  };
}
