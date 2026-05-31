// soundtrack_provider.dart
// Layered-Audio-System mit just_audio und Riverpod für GENESIS: Der Kreislauf des Lebens.
// Unterstützt mehrere Audio-Schichten (Basis, Emotion, Spannung, Ambiente),
// die sich dynamisch an Spielphase und emotionalen Zustand anpassen.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/emotions_wetter_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: SoundtrackSchicht – die vier Audio-Layer des Layered-Audio-Systems
// ─────────────────────────────────────────────────────────────────────────────
enum SoundtrackSchicht {
  /// Basis-Layer – phasenspezifische Grundmusik, immer aktiv
  basis,

  /// Emotions-Layer – dynamisch basierend auf Emotionswetter
  emotion,

  /// Spannungs-Layer – bei Entscheidungsmomenten und Krisen
  spannung,

  /// Ambiente-Layer – atmosphärische Hintergrundklänge
  ambiente,
}

// ─────────────────────────────────────────────────────────────────────────────
// SoundtrackZustand – unveränderlicher Zustand des Audio-Systems
// ─────────────────────────────────────────────────────────────────────────────

/// Repräsentiert den vollständigen Zustand des Soundtrack-Systems.
class SoundtrackZustand {
  /// Gibt an, ob das Soundtrack-System gerade aktiv abspielt
  final bool laeuft;

  /// Globale Lautstärke (0.0 = stumm, 1.0 = volle Lautstärke)
  final double lautstaerke;

  /// Die aktuelle Spielphase (bestimmt den Basis-Track)
  final GamePhase aktuellePhase;

  /// Der aktuelle emotionale Wettertyp (bestimmt den Emotions-Layer)
  final EmotionsWetterTyp aktuellesWetter;

  /// Individuelle Lautstärken pro Schicht (ermöglicht dynamisches Einblenden)
  final Map<SoundtrackSchicht, double> schichtLautstaerken;

  /// Gibt an, ob das System stummgeschaltet ist
  final bool istStumm;

  /// Gibt an, ob gerade eine Überblendung stattfindet
  final bool istInUeberblendung;

  const SoundtrackZustand({
    required this.laeuft,
    required this.lautstaerke,
    required this.aktuellePhase,
    required this.aktuellesWetter,
    required this.schichtLautstaerken,
    required this.istStumm,
    required this.istInUeberblendung,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Standard-Startzustand
  // ───────────────────────────────────────────────────────────────────────────

  /// Erstellt den initialen Soundtrack-Zustand beim Spielstart.
  static SoundtrackZustand initial() => const SoundtrackZustand(
        laeuft: false,
        lautstaerke: 0.8,
        aktuellePhase: GamePhase.entstehung,
        aktuellesWetter: EmotionsWetterTyp.klar,
        schichtLautstaerken: {
          SoundtrackSchicht.basis: 1.0,
          SoundtrackSchicht.emotion: 0.0,
          SoundtrackSchicht.spannung: 0.0,
          SoundtrackSchicht.ambiente: 0.3,
        },
        istStumm: false,
        istInUeberblendung: false,
      );

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  SoundtrackZustand copyWith({
    bool? laeuft,
    double? lautstaerke,
    GamePhase? aktuellePhase,
    EmotionsWetterTyp? aktuellesWetter,
    Map<SoundtrackSchicht, double>? schichtLautstaerken,
    bool? istStumm,
    bool? istInUeberblendung,
  }) {
    return SoundtrackZustand(
      laeuft: laeuft ?? this.laeuft,
      lautstaerke: lautstaerke ?? this.lautstaerke,
      aktuellePhase: aktuellePhase ?? this.aktuellePhase,
      aktuellesWetter: aktuellesWetter ?? this.aktuellesWetter,
      schichtLautstaerken: schichtLautstaerken ?? this.schichtLautstaerken,
      istStumm: istStumm ?? this.istStumm,
      istInUeberblendung: istInUeberblendung ?? this.istInUeberblendung,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Gibt die effektive Lautstärke zurück (0.0 wenn stummgeschaltet).
  double get effektiveLautstaerke => istStumm ? 0.0 : lautstaerke;

  @override
  String toString() =>
      'SoundtrackZustand(laeuft: $laeuft, phase: ${aktuellePhase.name}, '
      'wetter: ${aktuellesWetter.name}, lautstaerke: $lautstaerke, '
      'stumm: $istStumm)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Audio-Pfad-Hilfsfunktionen
// ─────────────────────────────────────────────────────────────────────────────

/// Gibt den Asset-Pfad des Basis-Tracks für eine Spielphase zurück.
String _basisTrackPfad(GamePhase phase) {
  return switch (phase) {
    GamePhase.entstehung => 'assets/audio/musik/basis_geburt.mp3',
    GamePhase.formung => 'assets/audio/musik/basis_geburt.mp3',
    GamePhase.kindheit => 'assets/audio/musik/basis_kindheit.mp3',
    GamePhase.jugend => 'assets/audio/musik/basis_jugend.mp3',
    GamePhase.erwachsen => 'assets/audio/musik/basis_bluete.mp3',
    GamePhase.reife => 'assets/audio/musik/basis_weisheit.mp3',
    GamePhase.jenseits => 'assets/audio/musik/basis_tod.mp3',
  };
}

/// Gibt den Asset-Pfad des Emotions-Tracks für einen Wettertyp zurück.
/// Gibt null zurück, wenn für diesen Typ kein spezifischer Track existiert.
String? _emotionsTrackPfad(EmotionsWetterTyp wetter) {
  return switch (wetter) {
    EmotionsWetterTyp.sonnenschein =>
      'assets/audio/musik/emotion_freude.mp3',
    EmotionsWetterTyp.warmesLeuchten =>
      'assets/audio/musik/emotion_liebe.mp3',
    EmotionsWetterTyp.regen => 'assets/audio/musik/emotion_trauer.mp3',
    EmotionsWetterTyp.nebel => 'assets/audio/musik/emotion_melancholie.mp3',
    EmotionsWetterTyp.gewitter => 'assets/audio/musik/emotion_spannung.mp3',
    EmotionsWetterTyp.sturm => 'assets/audio/musik/emotion_sturm.mp3',
    EmotionsWetterTyp.kosmisch => 'assets/audio/musik/emotion_kosmisch.mp3',
    EmotionsWetterTyp.klar => null, // kein separater Emotions-Track bei klarem Wetter
  };
}

/// Gibt den Asset-Pfad des Ambiente-Tracks für eine Spielphase zurück.
String _ambienteTrackPfad(GamePhase phase) {
  return switch (phase) {
    GamePhase.entstehung || GamePhase.kindheit =>
      'assets/audio/ambient/kindheit_ambient.mp3',
    GamePhase.jugend || GamePhase.erwachsen =>
      'assets/audio/ambient/jugend_ambient.mp3',
    GamePhase.erwachsen || GamePhase.reife =>
      'assets/audio/ambient/erwachsen_ambient.mp3',
    GamePhase.reife || GamePhase.reife =>
      'assets/audio/ambient/alter_ambient.mp3',
    GamePhase.jenseits => 'assets/audio/ambient/jenseits_ambient.mp3',
  };
}

/// Berechnet die Lautstärke des Emotions-Layers basierend auf dem Wettertyp.
double _emotionsLautstaerke(EmotionsWetterTyp wetter) {
  return switch (wetter) {
    EmotionsWetterTyp.klar => 0.0,      // Kein Emotions-Layer bei klarem Wetter
    EmotionsWetterTyp.sonnenschein => 0.6,
    EmotionsWetterTyp.warmesLeuchten => 0.7,
    EmotionsWetterTyp.regen => 0.65,
    EmotionsWetterTyp.nebel => 0.5,
    EmotionsWetterTyp.gewitter => 0.75,
    EmotionsWetterTyp.sturm => 0.85,
    EmotionsWetterTyp.kosmisch => 0.9,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// SoundtrackNotifier – verwaltet das Layered-Audio-System mit just_audio
// ─────────────────────────────────────────────────────────────────────────────

/// StateNotifier für das dynamische Layered-Soundtrack-System.
///
/// Verwendet [just_audio] für hochqualitatives Streaming und sanfte Überblendungen.
/// Jede Audio-Schicht hat einen eigenen [AudioPlayer] für unabhängige Lautstärkekontrolle.
class SoundtrackNotifier extends StateNotifier<SoundtrackZustand> {
  SoundtrackNotifier() : super(SoundtrackZustand.initial()) {
    _spielerInitialisieren();
  }

  // ── Audio-Spieler pro Schicht ──────────────────────────────────────────────
  final AudioPlayer _basisSpieler = AudioPlayer();
  final AudioPlayer _emotionsSpieler = AudioPlayer();
  final AudioPlayer _spannungsSpieler = AudioPlayer();
  final AudioPlayer _ambienteSpieler = AudioPlayer();
  final AudioPlayer _effektSpieler = AudioPlayer();

  // Timer für Überblendungen
  Timer? _ueberblendungsTimer;

  // ───────────────────────────────────────────────────────────────────────────
  // Initialisierung
  // ───────────────────────────────────────────────────────────────────────────

  /// Konfiguriert alle Audio-Spieler mit Loop-Modus für Hintergrundmusik.
  void _spielerInitialisieren() {
    // Alle Hintergrund-Spieler im Endlos-Loop laufen lassen
    _basisSpieler.setLoopMode(LoopMode.one);
    _emotionsSpieler.setLoopMode(LoopMode.one);
    _spannungsSpieler.setLoopMode(LoopMode.one);
    _ambienteSpieler.setLoopMode(LoopMode.one);
    // Effekt-Spieler läuft einmalig
    _effektSpieler.setLoopMode(LoopMode.off);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Öffentliche Methoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Lädt und spielt die passende Musik für eine Spielphase ab.
  ///
  /// Überlädt alle aktiven Schichten mit phasenspezifischen Tracks.
  /// Basis- und Ambiente-Layer werden sofort aktualisiert.
  Future<void> phaseAbspielen(GamePhase phase) async {
    if (!mounted) return;

    state = state.copyWith(
      aktuellePhase: phase,
      istInUeberblendung: true,
    );

    try {
      // Basis-Track laden und abspielen
      final basisPfad = _basisTrackPfad(phase);
      await _basisSpieler.setAsset(basisPfad);
      await _basisSpieler.setVolume(
        state.effektiveLautstaerke *
            (state.schichtLautstaerken[SoundtrackSchicht.basis] ?? 1.0),
      );
      await _basisSpieler.play();

      // Ambiente-Track laden und abspielen (leiser)
      final ambientePfad = _ambienteTrackPfad(phase);
      await _ambienteSpieler.setAsset(ambientePfad);
      await _ambienteSpieler.setVolume(
        state.effektiveLautstaerke *
            (state.schichtLautstaerken[SoundtrackSchicht.ambiente] ?? 0.3),
      );
      await _ambienteSpieler.play();

      // Spannungs-Track phasenspezifisch laden (Pruefung und Tod haben Priorität)
      if (phase == GamePhase.reife || phase == GamePhase.jenseits) {
        await _spannungsSpieler
            .setAsset('assets/audio/musik/spannung_${phase.name}.mp3');
        await _spannungsSpieler.setVolume(
          state.effektiveLautstaerke * 0.5,
        );
        await _spannungsSpieler.play();
      } else {
        await _spannungsSpieler.stop();
      }
    } catch (fehler) {
      // Audio-Fehler sind nicht spielunterbrechend (Stille ist akzeptabel)
      // In Production-Build: Fehler loggen
    }

    if (mounted) {
      state = state.copyWith(
        laeuft: true,
        istInUeberblendung: false,
      );
    }
  }

  /// Überlädt den Emotions-Layer basierend auf dem aktuellen Wettertyp.
  ///
  /// Der Übergang erfolgt durch sanftes Einblenden des neuen Tracks.
  Future<void> wetterSchichtAktualisieren(EmotionsWetterTyp wetter) async {
    if (!mounted) return;

    state = state.copyWith(aktuellesWetter: wetter);

    final emotionsPfad = _emotionsTrackPfad(wetter);
    final zielLautstaerke = _emotionsLautstaerke(wetter);

    try {
      if (emotionsPfad != null && zielLautstaerke > 0.0) {
        // Neuen Emotions-Track laden (falls nicht bereits geladen)
        await _emotionsSpieler.setAsset(emotionsPfad);

        // Sanft einblenden: von 0 auf Ziel-Lautstärke
        await _emotionsSpieler.setVolume(0.0);
        await _emotionsSpieler.play();
        await _schichtEinblenden(
          _emotionsSpieler,
          zielLautstaerke * state.effektiveLautstaerke,
          const Duration(milliseconds: 1500),
        );
      } else {
        // Emotions-Schicht ausblenden und stoppen
        await _schichtAusblenden(
          _emotionsSpieler,
          const Duration(milliseconds: 1500),
        );
      }
    } catch (_) {
      // Fehler beim Wetter-Übergang sind nicht kritisch
    }

    // Schicht-Lautstärken im Zustand aktualisieren
    if (mounted) {
      final neueSchichtLautstaerken =
          Map<SoundtrackSchicht, double>.from(state.schichtLautstaerken);
      neueSchichtLautstaerken[SoundtrackSchicht.emotion] = zielLautstaerke;

      state = state.copyWith(schichtLautstaerken: neueSchichtLautstaerken);
    }
  }

  /// Setzt die globale Lautstärke (0.0–1.0) für alle Schichten.
  void lautstaerkeSetzen(double wert) {
    final begrenzterWert = wert.clamp(0.0, 1.0);
    state = state.copyWith(lautstaerke: begrenzterWert);

    // Lautstärke aller aktiven Spieler aktualisieren
    final lautstaerken = state.schichtLautstaerken;
    _basisSpieler.setVolume(
        begrenzterWert * (lautstaerken[SoundtrackSchicht.basis] ?? 1.0));
    _emotionsSpieler.setVolume(
        begrenzterWert * (lautstaerken[SoundtrackSchicht.emotion] ?? 0.0));
    _spannungsSpieler.setVolume(
        begrenzterWert * (lautstaerken[SoundtrackSchicht.spannung] ?? 0.0));
    _ambienteSpieler.setVolume(
        begrenzterWert * (lautstaerken[SoundtrackSchicht.ambiente] ?? 0.3));
  }

  /// Schaltet den Stummschaltungsmodus um.
  void stummschaltenUmschalten() {
    state = state.copyWith(istStumm: !state.istStumm);
    lautstaerkeSetzen(state.lautstaerke);
  }

  /// Spielt einen einmaligen Soundeffekt ab (UI-Feedback, Ereignis-Sounds).
  ///
  /// [pfad] – Asset-Pfad des Soundeffekts (z.B. 'assets/audio/sfx/karma_plus.mp3')
  Future<void> soundeffektAbspielen(String pfad) async {
    if (state.istStumm) return;

    try {
      await _effektSpieler.setAsset(pfad);
      await _effektSpieler.setVolume(state.lautstaerke);
      await _effektSpieler.seek(Duration.zero);
      await _effektSpieler.play();
    } catch (_) {
      // Soundeffekt-Fehler sind nicht spielunterbrechend
    }
  }

  /// Pausiert alle aktiven Musik-Schichten.
  Future<void> pausieren() async {
    await Future.wait([
      _basisSpieler.pause(),
      _emotionsSpieler.pause(),
      _spannungsSpieler.pause(),
      _ambienteSpieler.pause(),
    ]);
    if (mounted) state = state.copyWith(laeuft: false);
  }

  /// Setzt alle pausierten Musik-Schichten fort.
  Future<void> fortsetzen() async {
    // Nur Spieler fortsetzen, die tatsächlich Schichten mit Lautstärke > 0 haben
    final lautstaerken = state.schichtLautstaerken;
    final futures = <Future>[];

    if ((lautstaerken[SoundtrackSchicht.basis] ?? 0.0) > 0.0) {
      futures.add(_basisSpieler.play());
    }
    if ((lautstaerken[SoundtrackSchicht.emotion] ?? 0.0) > 0.0) {
      futures.add(_emotionsSpieler.play());
    }
    if ((lautstaerken[SoundtrackSchicht.spannung] ?? 0.0) > 0.0) {
      futures.add(_spannungsSpieler.play());
    }
    if ((lautstaerken[SoundtrackSchicht.ambiente] ?? 0.0) > 0.0) {
      futures.add(_ambienteSpieler.play());
    }

    await Future.wait(futures);
    if (mounted) state = state.copyWith(laeuft: true);
  }

  /// Setzt das gesamte Audio-System auf den Anfangszustand zurück.
  Future<void> zuruecksetzen() async {
    _ueberblendungsTimer?.cancel();
    await Future.wait([
      _basisSpieler.stop(),
      _emotionsSpieler.stop(),
      _spannungsSpieler.stop(),
      _ambienteSpieler.stop(),
      _effektSpieler.stop(),
    ]);
    if (mounted) state = SoundtrackZustand.initial();
  }

  @override
  void dispose() {
    _ueberblendungsTimer?.cancel();
    _basisSpieler.dispose();
    _emotionsSpieler.dispose();
    _spannungsSpieler.dispose();
    _ambienteSpieler.dispose();
    _effektSpieler.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Private Hilfsmethoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Blendet einen Audio-Spieler sanft auf eine Ziellautstärke ein.
  Future<void> _schichtEinblenden(
    AudioPlayer spieler,
    double zielLautstaerke,
    Duration dauer,
  ) async {
    const schritte = 15;
    final schrittDauer =
        Duration(milliseconds: dauer.inMilliseconds ~/ schritte);
    final schrittGroesse = zielLautstaerke / schritte;

    for (int i = 1; i <= schritte; i++) {
      if (!mounted) return;
      await Future.delayed(schrittDauer);
      await spieler.setVolume((schrittGroesse * i).clamp(0.0, 1.0));
    }
  }

  /// Blendet einen Audio-Spieler sanft aus und stoppt ihn danach.
  Future<void> _schichtAusblenden(AudioPlayer spieler, Duration dauer) async {
    final startLautstaerke = spieler.volume;
    const schritte = 15;
    final schrittDauer =
        Duration(milliseconds: dauer.inMilliseconds ~/ schritte);
    final schrittGroesse = startLautstaerke / schritte;

    for (int i = 1; i <= schritte; i++) {
      if (!mounted) return;
      await Future.delayed(schrittDauer);
      final neueLautstaerke = (startLautstaerke - schrittGroesse * i).clamp(0.0, 1.0);
      await spieler.setVolume(neueLautstaerke);
    }

    await spieler.stop();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Soundtrack-Provider – steuert das gesamte Layered-Audio-System.
///
/// Nutzt [just_audio] für hochqualitatives Streaming und sanfte Überblendungen.
final soundtrackProvider =
    StateNotifierProvider<SoundtrackNotifier, SoundtrackZustand>((ref) {
  return SoundtrackNotifier();
});

// ─────────────────────────────────────────────────────────────────────────────
// Bequemlichkeits-Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Gibt die globale Lautstärke zurück.
final soundtrackLautstaerkeProvider = Provider<double>((ref) {
  return ref.watch(soundtrackProvider).lautstaerke;
});

/// Gibt zurück, ob das Soundtrack-System gerade aktiv ist.
final soundtrackLaeuftProvider = Provider<bool>((ref) {
  return ref.watch(soundtrackProvider).laeuft;
});

/// Gibt zurück, ob das System stummgeschaltet ist.
final soundtrackIstStummProvider = Provider<bool>((ref) {
  return ref.watch(soundtrackProvider).istStumm;
});

/// Gibt die Schicht-Lautstärken-Map zurück.
final schichtLautstaerkenProvider =
    Provider<Map<SoundtrackSchicht, double>>((ref) {
  return ref.watch(soundtrackProvider).schichtLautstaerken;
});

/// Gibt den aktuellen Wettertyp im Soundtrack-System zurück.
final soundtrackWetterProvider = Provider<EmotionsWetterTyp>((ref) {
  return ref.watch(soundtrackProvider).aktuellesWetter;
});

/// Gibt zurück, ob eine Überblendung aktiv ist.
final soundtrackInUeberblendungProvider = Provider<bool>((ref) {
  return ref.watch(soundtrackProvider).istInUeberblendung;
});
