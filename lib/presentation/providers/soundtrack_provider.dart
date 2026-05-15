// soundtrack_provider.dart
// Layered-Audio-System mit Riverpod für GENESIS: Der Kreislauf des Lebens.
// Der SoundtrackNotifier erstellt einen einzigartigen, dynamischen Soundtrack,
// der sich an Karma-Profil, Spielphase und emotionalen Zustand anpasst.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genesis_spiel/data/models/karma_profil_model.dart';
import 'package:genesis_spiel/data/models/emotions_wetter_model.dart';
import 'package:genesis_spiel/core/constants/app_konstanten.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: SoundtrackSchicht – die verschiedenen Audio-Layer des Soundsystems
// ─────────────────────────────────────────────────────────────────────────────
enum SoundtrackSchicht {
  /// Basis-Layer – immer aktiv, unabhängig vom Spielzustand
  basis,

  /// Karma-positiver Layer – bei positivem Gesamt-Karma aktiv
  karma_positiv,

  /// Karma-negativer Layer – bei negativem Gesamt-Karma aktiv
  karma_negativ,

  /// Freude-Layer – bei hohem Glückswert aktiv
  emotion_freude,

  /// Trauer-Layer – bei Melancholie oder Verlustzuständen aktiv
  emotion_trauer,

  /// Spannungs-Layer – bei Entscheidungsmomenten oder Krisen aktiv
  spannung,

  /// Stille-Layer – für kontemplative Momente und Pausen
  stille,

  /// Kosmischer Layer – für Phase 8 (Vermächtnis) und Phase 9 (Tod)
  kosmisch,
}

// ─────────────────────────────────────────────────────────────────────────────
// SoundtrackZustand – unveränderlicher Zustand des Audio-Systems
// ─────────────────────────────────────────────────────────────────────────────
class SoundtrackZustand {
  /// Liste aller aktuell abgespielten Musik-Layer (Dateinamen)
  final List<String> aktiveTracks;

  /// Globale Lautstärke (0.0 = stumm, 1.0 = volle Lautstärke)
  final double lautstaerke;

  /// Name des aktuell dominanten Musik-Themas
  final String aktuellesThema;

  /// Gibt an, ob das gesamte Audiosystem stummgeschaltet ist
  final bool istStumm;

  /// Individuelle Lautstärke pro Musik-Layer (Schlüssel: Schicht-Name, Wert: 0.0–1.0)
  final Map<String, double> schichtLautstaerken;

  /// Aktuelle Spielphase, die den Soundtrack beeinflusst
  final GamePhase aktuellePhase;

  /// Gibt an, ob eine Überblendung zwischen Tracks läuft
  final bool istInUeberblendung;

  /// Dauer der aktuellen Überblendung in Millisekunden
  final int ueberblendungsDauerMs;

  const SoundtrackZustand({
    required this.aktiveTracks,
    required this.lautstaerke,
    required this.aktuellesThema,
    required this.istStumm,
    required this.schichtLautstaerken,
    required this.aktuellePhase,
    required this.istInUeberblendung,
    required this.ueberblendungsDauerMs,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Standard-Startzustand
  // ───────────────────────────────────────────────────────────────────────────

  /// Erstellt den initialen Soundtrack-Zustand beim Spielstart
  static SoundtrackZustand initial() => const SoundtrackZustand(
        aktiveTracks: [],
        lautstaerke: 0.8,
        aktuellesThema: 'basis',
        istStumm: false,
        schichtLautstaerken: {},
        aktuellePhase: GamePhase.geburt,
        istInUeberblendung: false,
        ueberblendungsDauerMs: 2000,
      );

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  SoundtrackZustand copyWith({
    List<String>? aktiveTracks,
    double? lautstaerke,
    String? aktuellesThema,
    bool? istStumm,
    Map<String, double>? schichtLautstaerken,
    GamePhase? aktuellePhase,
    bool? istInUeberblendung,
    int? ueberblendungsDauerMs,
  }) {
    return SoundtrackZustand(
      aktiveTracks: aktiveTracks ?? this.aktiveTracks,
      lautstaerke: lautstaerke ?? this.lautstaerke,
      aktuellesThema: aktuellesThema ?? this.aktuellesThema,
      istStumm: istStumm ?? this.istStumm,
      schichtLautstaerken: schichtLautstaerken ?? this.schichtLautstaerken,
      aktuellePhase: aktuellePhase ?? this.aktuellePhase,
      istInUeberblendung: istInUeberblendung ?? this.istInUeberblendung,
      ueberblendungsDauerMs:
          ueberblendungsDauerMs ?? this.ueberblendungsDauerMs,
    );
  }

  @override
  String toString() =>
      'SoundtrackZustand(thema: $aktuellesThema, '
      'aktiveTracks: ${aktiveTracks.length}, '
      'lautstaerke: ${lautstaerke.toStringAsFixed(2)}, '
      'istStumm: $istStumm)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Soundtrack-Konfiguration: Tracks pro Phase und Schicht
// ─────────────────────────────────────────────────────────────────────────────

/// Liefert den Dateinamen des Basis-Tracks für eine gegebene Spielphase.
String _basisTrackFuerPhase(GamePhase phase) {
  switch (phase) {
    case GamePhase.geburt:
      return 'assets/audio/musik/basis_geburt.mp3';
    case GamePhase.kindheit:
      return 'assets/audio/musik/basis_kindheit.mp3';
    case GamePhase.jugend:
      return 'assets/audio/musik/basis_jugend.mp3';
    case GamePhase.aufbruch:
      return 'assets/audio/musik/basis_aufbruch.mp3';
    case GamePhase.bluetePunkt:
      return 'assets/audio/musik/basis_bluete.mp3';
    case GamePhase.pruefung:
      return 'assets/audio/musik/basis_pruefung.mp3';
    case GamePhase.weisheit:
      return 'assets/audio/musik/basis_weisheit.mp3';
    case GamePhase.vermaechtnis:
      return 'assets/audio/musik/basis_vermaechtnis.mp3';
    case GamePhase.tod:
      return 'assets/audio/musik/basis_tod.mp3';
  }
}

/// Liefert die Lautstärke einer Soundtrack-Schicht basierend auf Karma und Emotion.
double _schichtLautstaerkeBerechnen(
  SoundtrackSchicht schicht,
  KarmaProfilModel karma,
  EmotionsWetterTyp wetterTyp,
) {
  switch (schicht) {
    case SoundtrackSchicht.basis:
      // Basis-Layer immer auf voller Lautstärke
      return 1.0;

    case SoundtrackSchicht.karma_positiv:
      // Layer wird stärker bei positiverem Karma-Durchschnitt
      final avg = karma.durchschnitt;
      if (avg <= 0) return 0.0;
      return (avg / 100.0).clamp(0.0, 1.0);

    case SoundtrackSchicht.karma_negativ:
      // Layer wird stärker bei negativem Karma-Durchschnitt
      final avg = karma.durchschnitt;
      if (avg >= 0) return 0.0;
      return (-avg / 100.0).clamp(0.0, 1.0);

    case SoundtrackSchicht.emotion_freude:
      // Freude-Layer bei Sonnenschein oder warmem Leuchten
      return (wetterTyp == EmotionsWetterTyp.sonnenschein ||
              wetterTyp == EmotionsWetterTyp.warmesLeuchten)
          ? 0.75
          : 0.0;

    case SoundtrackSchicht.emotion_trauer:
      // Trauer-Layer bei Regen oder Nebel
      return (wetterTyp == EmotionsWetterTyp.regen ||
              wetterTyp == EmotionsWetterTyp.nebel)
          ? 0.7
          : 0.0;

    case SoundtrackSchicht.spannung:
      // Spannungs-Layer bei Gewitter oder Sturm
      return (wetterTyp == EmotionsWetterTyp.gewitter ||
              wetterTyp == EmotionsWetterTyp.sturm)
          ? 0.85
          : 0.0;

    case SoundtrackSchicht.stille:
      // Stille-Layer bei klarem Wetter (kontemplative Momente)
      return wetterTyp == EmotionsWetterTyp.klar ? 0.5 : 0.0;

    case SoundtrackSchicht.kosmisch:
      // Kosmischer Layer bei spirituellem Wetter
      return wetterTyp == EmotionsWetterTyp.kosmisch ? 0.9 : 0.0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SoundtrackNotifier – verwaltet den dynamischen Layered-Soundtrack
// ─────────────────────────────────────────────────────────────────────────────
class SoundtrackNotifier extends StateNotifier<SoundtrackZustand> {
  SoundtrackNotifier() : super(SoundtrackZustand.initial());

  // ───────────────────────────────────────────────────────────────────────────
  // Öffentliche Methoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Aktualisiert den Soundtrack basierend auf Karma-Profil und emotionalem Wetter.
  /// Berechnet für jede Schicht die passende Lautstärke und wählt aktive Tracks.
  void soundtrackAktualisieren({
    required KarmaProfilModel karma,
    required EmotionsWetterModel wetter,
    required GamePhase phase,
  }) {
    // Neue Schicht-Lautstärken berechnen
    final neueLautstaerken = <String, double>{};
    final aktiveTracks = <String>[];

    // Basis-Track immer einschalten
    final basisTrack = _basisTrackFuerPhase(phase);
    aktiveTracks.add(basisTrack);
    neueLautstaerken[SoundtrackSchicht.basis.name] = 1.0;

    // Alle weiteren Schichten dynamisch berechnen
    for (final schicht in SoundtrackSchicht.values) {
      if (schicht == SoundtrackSchicht.basis) continue;

      final lautstaerke = _schichtLautstaerkeBerechnen(
        schicht,
        karma,
        wetter.typ,
      );

      neueLautstaerken[schicht.name] = lautstaerke;

      // Track zur Aktivliste hinzufügen, wenn Lautstärke > 0
      if (lautstaerke > 0.0) {
        final trackPfad = _trackPfadFuerSchicht(schicht, phase);
        if (trackPfad != null) {
          aktiveTracks.add(trackPfad);
        }
      }
    }

    // Thema-Namen bestimmen (kosmisch und Vermächtnis/Tod haben Priorität)
    final thema = _themaNameBestimmen(phase, karma, wetter.typ);

    state = state.copyWith(
      aktiveTracks: aktiveTracks,
      schichtLautstaerken: neueLautstaerken,
      aktuellesThema: thema,
      aktuellePhase: phase,
    );
  }

  /// Wechselt zur nächsten Spielphase und blendet den Soundtrack über.
  /// Die Überblendung dauert standardmäßig 2 Sekunden.
  void phasenWechsel(GamePhase neuePhase) {
    state = state.copyWith(
      aktuellePhase: neuePhase,
      istInUeberblendung: true,
      aktuellesThema: _basisThemaFuerPhase(neuePhase),
    );

    // Nach der Überblendungsdauer Flag zurücksetzen
    Future.delayed(
      Duration(milliseconds: state.ueberblendungsDauerMs),
      () {
        if (mounted) {
          state = state.copyWith(istInUeberblendung: false);
        }
      },
    );
  }

  /// Setzt die globale Lautstärke (0.0 bis 1.0).
  void lautstaerkeSetzen(double neueLautstaerke) {
    state = state.copyWith(
      lautstaerke: neueLautstaerke.clamp(0.0, 1.0),
    );
  }

  /// Schaltet den Stummschaltungsmodus um.
  void stummschaltenUmschalten() {
    state = state.copyWith(istStumm: !state.istStumm);
  }

  /// Spielt den finalen Akkord beim Tod – basierend auf dem Karma-Profil des Lebens.
  /// Der Akkord reflektiert den moralischen Charakter der verstorbenen Seele.
  void finalenAkkordSpielen(KarmaProfilModel karmaAmEnde) {
    final avg = karmaAmEnde.durchschnitt;

    // Finalen Akkord-Track basierend auf Karma-Niveau auswählen
    String akkordTrack;
    if (avg >= 60.0) {
      // Erleuchteter Abschluss – hohe, helle Töne
      akkordTrack = 'assets/audio/musik/akkord_elysium.mp3';
    } else if (avg >= 20.0) {
      // Harmonischer Abschluss – warme, wohlklingende Akkorde
      akkordTrack = 'assets/audio/musik/akkord_harmonia.mp3';
    } else if (avg >= -20.0) {
      // Neutraler Abschluss – gedämpfte, nachdenkliche Töne
      akkordTrack = 'assets/audio/musik/akkord_limbus.mp3';
    } else if (avg >= -60.0) {
      // Dunkler Abschluss – tiefe, schwere Akkorde
      akkordTrack = 'assets/audio/musik/akkord_shadowlands.mp3';
    } else {
      // Abyssaler Abschluss – dissonante, beunruhigende Töne
      akkordTrack = 'assets/audio/musik/akkord_abyssus.mp3';
    }

    // Finalen Akkord als einzigen aktiven Track setzen
    state = state.copyWith(
      aktiveTracks: [akkordTrack],
      aktuellesThema: 'finaler_akkord',
      schichtLautstaerken: {
        SoundtrackSchicht.kosmisch.name: 1.0,
      },
    );
  }

  /// Setzt alle Audio-Schichten zurück (z.B. beim Start eines neuen Lebens).
  void zuruecksetzen() {
    state = SoundtrackZustand.initial();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Private Hilfsmethoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Liefert den Track-Pfad für eine gegebene Schicht und Phase.
  String? _trackPfadFuerSchicht(SoundtrackSchicht schicht, GamePhase phase) {
    final phaseName = phase.name;
    switch (schicht) {
      case SoundtrackSchicht.karma_positiv:
        return 'assets/audio/musik/karma_positiv_$phaseName.mp3';
      case SoundtrackSchicht.karma_negativ:
        return 'assets/audio/musik/karma_negativ_$phaseName.mp3';
      case SoundtrackSchicht.emotion_freude:
        return 'assets/audio/musik/emotion_freude.mp3';
      case SoundtrackSchicht.emotion_trauer:
        return 'assets/audio/musik/emotion_trauer.mp3';
      case SoundtrackSchicht.spannung:
        return 'assets/audio/musik/spannung_$phaseName.mp3';
      case SoundtrackSchicht.stille:
        return 'assets/audio/musik/stille_ambient.mp3';
      case SoundtrackSchicht.kosmisch:
        return 'assets/audio/musik/kosmisch_ambient.mp3';
      case SoundtrackSchicht.basis:
        return null; // Wird separat behandelt
    }
  }

  /// Bestimmt den Namen des aktuellen Themas basierend auf Phase und Zustand.
  String _themaNameBestimmen(
    GamePhase phase,
    KarmaProfilModel karma,
    EmotionsWetterTyp wetterTyp,
  ) {
    // Kosmische Phasen haben höchste Priorität
    if (phase == GamePhase.tod || phase == GamePhase.vermaechtnis) {
      return 'kosmisch_${phase.name}';
    }
    // Spirituelles Wetter
    if (wetterTyp == EmotionsWetterTyp.kosmisch) {
      return 'kosmisch_moment';
    }
    // Karma-basiertes Thema
    final avg = karma.durchschnitt;
    if (avg >= 40.0) return '${phase.name}_hell';
    if (avg <= -40.0) return '${phase.name}_dunkel';
    return phase.name;
  }

  /// Liefert das Basis-Thema-Präfix für eine Phase.
  String _basisThemaFuerPhase(GamePhase phase) => phase.name;
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Globaler Soundtrack-Provider – steuert das gesamte Musik-System des Spiels
final soundtrackProvider =
    StateNotifierProvider<SoundtrackNotifier, SoundtrackZustand>(
  (ref) => SoundtrackNotifier(),
);

/// Bequemlichkeits-Provider: Gibt nur die aktuelle Liste der aktiven Tracks zurück
final aktiveSoundtrackTracksProvider = Provider<List<String>>(
  (ref) => ref.watch(soundtrackProvider).aktiveTracks,
);

/// Bequemlichkeits-Provider: Gibt die globale Lautstärke zurück
final soundtrackLautstaerkeProvider = Provider<double>(
  (ref) => ref.watch(soundtrackProvider).lautstaerke,
);

/// Bequemlichkeits-Provider: Gibt zurück, ob das System stummgeschaltet ist
final soundtrackIstStummProvider = Provider<bool>(
  (ref) => ref.watch(soundtrackProvider).istStumm,
);

/// Bequemlichkeits-Provider: Gibt die Schicht-Lautstärken zurück
final schichtLautstaerkenProvider = Provider<Map<String, double>>(
  (ref) => ref.watch(soundtrackProvider).schichtLautstaerken,
);
