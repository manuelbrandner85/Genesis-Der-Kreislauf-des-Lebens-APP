// Soundtrack Engine für GENESIS: Der Kreislauf des Lebens
// Generiert einen einzigartigen persönlichen Soundtrack basierend auf
// Entscheidungen. Layered Audio System mit mehreren Schichten.

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/emotions_wetter_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: SoundtrackSchicht
// ─────────────────────────────────────────────────────────────────────────────

/// Die vier Schichten des Layered Audio Systems.
enum SoundtrackSchicht {
  /// Basis-Melodie – immer aktiv, phasenabhängig
  basis,

  /// Emotions-Schicht – passt sich dem Emotions-Wetter an
  emotion,

  /// Spannungs-Schicht – bei Prüfungen und Entscheidungen
  spannung,

  /// Ambient-Schicht – Umgebungsgeräusche des Zeitalters
  ambiente,
}

// ─────────────────────────────────────────────────────────────────────────────
// Model: SoundtrackProfil
// ─────────────────────────────────────────────────────────────────────────────

/// Das persönliche Soundtrack-Profil des Spielers.
/// Basiert auf Entscheidungen und wird am Ende exportierbar.
class SoundtrackProfil {
  /// Dominante musikalische Stimmung basierend auf Karma-Profil
  final SoundtrackStimmung dominanteStimmung;

  /// Intensitätswert (0.0-1.0) – beeinflusst Orchestrierung
  final double intensitaet;

  /// Anzahl gespielte Zyklen – mehr Zyklen = komplexerer Soundtrack
  final int zyklusKomplexitaet;

  /// Ob Dur (positives Karma) oder Moll (negatives Karma) dominiert
  final bool isDurTonart;

  /// Exportierbare Playlist-Tracks (Dateinamen)
  final List<String> playlistTracks;

  const SoundtrackProfil({
    required this.dominanteStimmung,
    required this.intensitaet,
    required this.zyklusKomplexitaet,
    required this.isDurTonart,
    this.playlistTracks = const [],
  });

  SoundtrackProfil copyWith({
    SoundtrackStimmung? dominanteStimmung,
    double? intensitaet,
    int? zyklusKomplexitaet,
    bool? isDurTonart,
    List<String>? playlistTracks,
  }) {
    return SoundtrackProfil(
      dominanteStimmung: dominanteStimmung ?? this.dominanteStimmung,
      intensitaet: intensitaet ?? this.intensitaet,
      zyklusKomplexitaet: zyklusKomplexitaet ?? this.zyklusKomplexitaet,
      isDurTonart: isDurTonart ?? this.isDurTonart,
      playlistTracks: playlistTracks ?? this.playlistTracks,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum: SoundtrackStimmung
// ─────────────────────────────────────────────────────────────────────────────

enum SoundtrackStimmung {
  /// Episch und heroisch – für Mut und Großzügigkeit
  episch,

  /// Melancholisch und tief – für Verlust und Reflexion
  melancholisch,

  /// Warm und liebevoll – für Liebe und Mitgefühl
  warmHerzlich,

  /// Mystisch und spirituell – für Weisheit und Jenseits
  mystisch,

  /// Spannungsvoll und dunkel – für Konflikte und Prüfungen
  dunkelSpannend,

  /// Leicht und verspielt – für Kindheit und Freude
  verspielt,
}

// ─────────────────────────────────────────────────────────────────────────────
// Engine: SoundtrackEngine
// ─────────────────────────────────────────────────────────────────────────────

/// Berechnet den persönlichen Soundtrack basierend auf Spielentscheidungen.
///
/// Das Layered Audio System kombiniert bis zu 4 Schichten:
/// Basis-Melodie + Emotions-Schicht + Spannungs-Schicht + Ambient.
class SoundtrackEngine {
  // ─────────────────────────────────────────────────────────────────────────
  // Audio-Dateipfade (Platzhalter für echte Asset-Dateien)
  // ─────────────────────────────────────────────────────────────────────────

  static const Map<GamePhase, Map<SoundtrackSchicht, String>> _phasenMusik = {
    GamePhase.entstehung: {
      SoundtrackSchicht.basis: 'assets/audio/musik/entstehung_basis.mp3',
      SoundtrackSchicht.ambiente: 'assets/audio/ambient/kosmisch.mp3',
    },
    GamePhase.formung: {
      SoundtrackSchicht.basis: 'assets/audio/musik/formung_basis.mp3',
      SoundtrackSchicht.ambiente: 'assets/audio/ambient/herzschlag.mp3',
    },
    GamePhase.kindheit: {
      SoundtrackSchicht.basis: 'assets/audio/musik/kindheit_basis.mp3',
      SoundtrackSchicht.emotion: 'assets/audio/musik/kindheit_freude.mp3',
      SoundtrackSchicht.ambiente: 'assets/audio/ambient/garten.mp3',
    },
    GamePhase.jugend: {
      SoundtrackSchicht.basis: 'assets/audio/musik/jugend_basis.mp3',
      SoundtrackSchicht.emotion: 'assets/audio/musik/jugend_emotion.mp3',
      SoundtrackSchicht.spannung: 'assets/audio/musik/jugend_spannung.mp3',
      SoundtrackSchicht.ambiente: 'assets/audio/ambient/schule.mp3',
    },
    GamePhase.erwachsen: {
      SoundtrackSchicht.basis: 'assets/audio/musik/erwachsen_basis.mp3',
      SoundtrackSchicht.emotion: 'assets/audio/musik/erwachsen_emotion.mp3',
      SoundtrackSchicht.spannung: 'assets/audio/musik/erwachsen_spannung.mp3',
      SoundtrackSchicht.ambiente: 'assets/audio/ambient/stadt.mp3',
    },
    GamePhase.reife: {
      SoundtrackSchicht.basis: 'assets/audio/musik/reife_basis.mp3',
      SoundtrackSchicht.emotion: 'assets/audio/musik/reife_nostalgie.mp3',
      SoundtrackSchicht.ambiente: 'assets/audio/ambient/natur_ruhig.mp3',
    },
    GamePhase.jenseits: {
      SoundtrackSchicht.basis: 'assets/audio/musik/jenseits_basis.mp3',
      SoundtrackSchicht.ambiente: 'assets/audio/ambient/jenseits_ambient.mp3',
    },
    GamePhase.kosmisch: {
      SoundtrackSchicht.basis: 'assets/audio/musik/kosmisch_basis.mp3',
      SoundtrackSchicht.ambiente: 'assets/audio/ambient/kosmos.mp3',
    },
    GamePhase.schoepfung: {
      SoundtrackSchicht.basis: 'assets/audio/musik/schoepfung_basis.mp3',
      SoundtrackSchicht.ambiente: 'assets/audio/ambient/schoepfung_ambient.mp3',
    },
  };

  static const Map<EmotionsWetterTyp, String> _wetterMusik = {
    EmotionsWetterTyp.sonnenschein: 'assets/audio/musik/wetter_glueck.mp3',
    EmotionsWetterTyp.regen: 'assets/audio/musik/wetter_melancholie.mp3',
    EmotionsWetterTyp.gewitter: 'assets/audio/musik/wetter_spannung.mp3',
    EmotionsWetterTyp.warmesLeuchten: 'assets/audio/musik/wetter_liebe.mp3',
    EmotionsWetterTyp.kosmisch: 'assets/audio/musik/wetter_spirituell.mp3',
    EmotionsWetterTyp.nebel: 'assets/audio/musik/wetter_nebel.mp3',
    EmotionsWetterTyp.sturm: 'assets/audio/musik/wetter_sturm.mp3',
    EmotionsWetterTyp.klar: 'assets/audio/musik/wetter_klar.mp3',
  };

  // ─────────────────────────────────────────────────────────────────────────
  // Öffentliche Methoden
  // ─────────────────────────────────────────────────────────────────────────

  /// Gibt alle aktiven Audio-Schichten für die aktuelle Situation zurück.
  Map<SoundtrackSchicht, String> aktiveSchichtenBerechnen({
    required GamePhase phase,
    required EmotionsWetterTyp wetter,
    required bool istPruefung,
  }) {
    final schichten = Map<SoundtrackSchicht, String>.from(
      _phasenMusik[phase] ?? {},
    );

    // Wetter überschreibt die Emotions-Schicht
    final wetterMusik = _wetterMusik[wetter];
    if (wetterMusik != null) {
      schichten[SoundtrackSchicht.emotion] = wetterMusik;
    }

    // Spannungs-Schicht bei Prüfungen
    if (istPruefung) {
      schichten[SoundtrackSchicht.spannung] =
          'assets/audio/musik/pruefung_spannung.mp3';
    }

    return schichten;
  }

  /// Berechnet das persönliche Soundtrack-Profil basierend auf Karma.
  SoundtrackProfil profilBerechnen({
    required double karmaDurchschnitt,
    required double dominanteDimensionWert,
    required int zyklusNummer,
  }) {
    final stimmung = _stimmungBerechnen(
      karmaDurchschnitt: karmaDurchschnitt,
      dominanteDimensionWert: dominanteDimensionWert,
    );

    return SoundtrackProfil(
      dominanteStimmung: stimmung,
      intensitaet: (dominanteDimensionWert.abs() / 100.0).clamp(0, 1),
      zyklusKomplexitaet: zyklusNummer,
      isDurTonart: karmaDurchschnitt >= 0,
    );
  }

  /// Gibt den Sterbe-Sequenz-Soundtrack basierend auf Todesart und Karma zurück.
  String sterbeSequenzSoundtrack({
    required double karmaDurchschnitt,
    required String todesArt,
  }) {
    if (karmaDurchschnitt > 60) {
      return 'assets/audio/musik/tod_frieden.mp3'; // Friedlicher Übergang
    } else if (karmaDurchschnitt > 20) {
      return 'assets/audio/musik/tod_nachdenklich.mp3';
    } else if (karmaDurchschnitt > -20) {
      return 'assets/audio/musik/tod_unentschlossen.mp3';
    } else {
      return 'assets/audio/musik/tod_schwer.mp3'; // Schwerer Abgang
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Methoden
  // ─────────────────────────────────────────────────────────────────────────

  SoundtrackStimmung _stimmungBerechnen({
    required double karmaDurchschnitt,
    required double dominanteDimensionWert,
  }) {
    if (karmaDurchschnitt > 60) return SoundtrackStimmung.episch;
    if (karmaDurchschnitt > 30) return SoundtrackStimmung.warmHerzlich;
    if (karmaDurchschnitt > 0) return SoundtrackStimmung.mystisch;
    if (karmaDurchschnitt > -30) return SoundtrackStimmung.melancholisch;
    return SoundtrackStimmung.dunkelSpannend;
  }
}
