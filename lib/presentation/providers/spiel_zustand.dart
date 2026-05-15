// spiel_zustand.dart
// Unveränderliche Zustandsklasse für den Hauptspielzustand von GENESIS.
// Kapselt alle relevanten Informationen über den aktuellen Spielverlauf –
// von Spielerprofil und aktivem Zyklus bis hin zur Ladeanzeige.

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/emotions_wetter_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/spieler_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SpielZustand – Haupt-Zustandsklasse (kein Provider, nur State-Klasse)
// ─────────────────────────────────────────────────────────────────────────────

/// Repräsentiert den vollständigen Zustand des laufenden Spiels.
///
/// Diese Klasse ist unveränderlich – alle Änderungen erzeugen eine neue Instanz
/// via [copyWith]. Der [SpielNotifier] verwaltet Zustandsübergänge.
class SpielZustand {
  /// Das aktuelle Spielerprofil (Seelen-Ebene, null = kein Profil geladen)
  final SpielerProfilModel? spielerProfil;

  /// Der aktive Lebenszyklus (null = kein Zyklus gestartet)
  final ZyklusModel? aktuellerZyklus;

  /// Die aktuelle Spielphase innerhalb des Lebenszyklus
  final GamePhase aktuellePhase;

  /// Das aktuelle Emotions-Wetter – steuert visuelle Shader und Partikel
  final EmotionsWetterModel emotionsWetter;

  /// Gibt an, ob gerade eine asynchrone Operation läuft (Laden, Speichern)
  final bool istLadend;

  /// Fehlermeldung bei Ausnahmen (null = kein Fehler)
  final String? fehlerMeldung;

  /// Gibt an, ob das Spiel aktiv läuft (nicht pausiert, nicht im Menü)
  final bool spielLaeuft;

  /// Das aktuelle Alter des Charakters im laufenden Zyklus (in Jahren)
  final int aktuellesAlter;

  const SpielZustand({
    required this.spielerProfil,
    required this.aktuellerZyklus,
    required this.aktuellePhase,
    required this.emotionsWetter,
    required this.istLadend,
    this.fehlerMeldung,
    required this.spielLaeuft,
    required this.aktuellesAlter,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Initial-Zustand
  // ───────────────────────────────────────────────────────────────────────────

  /// Erstellt den Standard-Anfangszustand beim Spielstart.
  /// Kein Profil, keine Phase, neutrales klares Wetter.
  factory SpielZustand.initial() => SpielZustand(
        spielerProfil: null,
        aktuellerZyklus: null,
        aktuellePhase: GamePhase.entstehung,
        emotionsWetter: EmotionsWetterModel.vonEmotion(
          glueck: 0.5,
          stress: 0.1,
          liebe: 0.4,
          spiritualitaet: 0.2,
        ),
        istLadend: false,
        fehlerMeldung: null,
        spielLaeuft: false,
        aktuellesAlter: 0,
      );

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnete Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Gibt an, ob ein Spielerprofil und ein aktiver Zyklus geladen sind
  bool get istBereit =>
      spielerProfil != null && aktuellerZyklus != null && !istLadend;

  /// Gibt an, ob sich der Charakter in einer Entscheidungsphase befindet
  bool get kannEntscheidungTreffen =>
      istBereit && spielLaeuft && aktuellePhase.istEntscheidungsPhase;

  // ───────────────────────────────────────────────────────────────────────────
  // copyWith
  // ───────────────────────────────────────────────────────────────────────────

  SpielZustand copyWith({
    SpielerProfilModel? spielerProfil,
    ZyklusModel? aktuellerZyklus,
    GamePhase? aktuellePhase,
    EmotionsWetterModel? emotionsWetter,
    bool? istLadend,
    String? fehlerMeldung,
    bool? spielLaeuft,
    int? aktuellesAlter,
    // Ermöglicht explizites Setzen auf null (z.B. Fehler löschen)
    bool fehlerLoeschen = false,
    bool profilLoeschen = false,
    bool zyklusLoeschen = false,
  }) {
    return SpielZustand(
      spielerProfil:
          profilLoeschen ? null : (spielerProfil ?? this.spielerProfil),
      aktuellerZyklus:
          zyklusLoeschen ? null : (aktuellerZyklus ?? this.aktuellerZyklus),
      aktuellePhase: aktuellePhase ?? this.aktuellePhase,
      emotionsWetter: emotionsWetter ?? this.emotionsWetter,
      istLadend: istLadend ?? this.istLadend,
      fehlerMeldung:
          fehlerLoeschen ? null : (fehlerMeldung ?? this.fehlerMeldung),
      spielLaeuft: spielLaeuft ?? this.spielLaeuft,
      aktuellesAlter: aktuellesAlter ?? this.aktuellesAlter,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Gleichheit & Darstellung
  // ───────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpielZustand &&
        other.spielerProfil == spielerProfil &&
        other.aktuellerZyklus == aktuellerZyklus &&
        other.aktuellePhase == aktuellePhase &&
        other.istLadend == istLadend &&
        other.spielLaeuft == spielLaeuft &&
        other.aktuellesAlter == aktuellesAlter &&
        other.fehlerMeldung == fehlerMeldung;
  }

  @override
  int get hashCode => Object.hash(
        spielerProfil,
        aktuellerZyklus,
        aktuellePhase,
        istLadend,
        spielLaeuft,
        aktuellesAlter,
        fehlerMeldung,
      );

  @override
  String toString() =>
      'SpielZustand(profil: ${spielerProfil?.anzeigeName}, '
      'phase: ${aktuellePhase.name}, alter: $aktuellesAlter, '
      'laeuft: $spielLaeuft, ladend: $istLadend, '
      'fehler: $fehlerMeldung)';
}
