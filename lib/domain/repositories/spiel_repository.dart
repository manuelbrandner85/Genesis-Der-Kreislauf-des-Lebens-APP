// spiel_repository.dart
// Abstraktes Repository-Interface für alle Spielzustand-Datenzugriffe.
// Definiert den Vertrag zwischen Domain- und Datenschicht.

import 'package:genesis_spiel/data/models/beziehung_model.dart';
import 'package:genesis_spiel/data/models/erinnerung_model.dart';
import 'package:genesis_spiel/data/models/entscheidung_model.dart';
import 'package:genesis_spiel/data/models/gedanke_model.dart';
import 'package:genesis_spiel/data/models/konsequenz_model.dart';
import 'package:genesis_spiel/data/models/spieler_profil_model.dart';
import 'package:genesis_spiel/data/models/zyklus_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SpielRepository – abstrakte Schnittstelle
// ─────────────────────────────────────────────────────────────────────────────

/// Definiert alle Datenzugriffsoperationen für das Spiel.
///
/// Implementierungen können Hive (lokal), Supabase (Cloud) oder
/// In-Memory-Speicher (Tests) verwenden – die Domain-Schicht
/// ist von diesen Details entkoppelt.
abstract class SpielRepository {
  // ───────────────────────────────────────────────────────────────────────────
  // Spieler-Profil
  // ───────────────────────────────────────────────────────────────────────────

  /// Lädt ein Spielerprofil anhand seiner ID.
  /// Gibt [null] zurück, wenn kein Profil gefunden wurde.
  Future<SpielerProfilModel?> profilLaden(String id);

  /// Speichert oder aktualisiert ein Spielerprofil.
  Future<void> profilSpeichern(SpielerProfilModel profil);

  /// Lädt alle vorhandenen Spielerprofile (für die Profilauswahl).
  Future<List<SpielerProfilModel>> alleProfileLaden();

  /// Löscht ein Spielerprofil und alle zugehörigen Daten.
  Future<void> profilLoeschen(String id);

  // ───────────────────────────────────────────────────────────────────────────
  // Zyklus
  // ───────────────────────────────────────────────────────────────────────────

  /// Lädt einen einzelnen Lebenszyklus anhand seiner ID.
  /// Gibt [null] zurück, wenn kein Zyklus gefunden wurde.
  Future<ZyklusModel?> zyklusLaden(String id);

  /// Speichert oder aktualisiert einen Lebenszyklus.
  Future<void> zyklusSpeichern(ZyklusModel zyklus);

  /// Lädt alle Lebenszyklen, die einem bestimmten Profil zugeordnet sind.
  /// Sortierung: aufsteigend nach Zyklusnummer.
  Future<List<ZyklusModel>> zyklenFuerProfil(String profilId);

  // ───────────────────────────────────────────────────────────────────────────
  // Entscheidungen
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert eine getroffene Entscheidung und verknüpft sie mit einem Zyklus.
  Future<void> entscheidungSpeichern(
      EntscheidungModel entscheidung, String zyklusId);

  /// Lädt alle Entscheidungen eines bestimmten Lebenszyklus.
  Future<List<EntscheidungModel>> entscheidungenLaden(String zyklusId);

  // ───────────────────────────────────────────────────────────────────────────
  // Konsequenzen
  // ───────────────────────────────────────────────────────────────────────────

  /// Fügt eine neue Konsequenz (sofortig oder verzögert) hinzu.
  Future<void> konsequenzHinzufuegen(KonsequenzModel konsequenz);

  /// Lädt alle Konsequenzen, die für einen Zyklus und ein bestimmtes
  /// Alter fällig sind (Alter >= faelligAlter und noch nicht ausgelöst).
  Future<List<KonsequenzModel>> faelligeKonsequenzenLaden(
      String zyklusId, int alter);

  /// Markiert eine Konsequenz als eingetreten.
  Future<void> konsequenzAlsEingetretenMarkieren(String konsequenzId);

  // ───────────────────────────────────────────────────────────────────────────
  // Erinnerungen
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert eine emotionale Erinnerung und verknüpft sie mit einem Zyklus.
  Future<void> erinnerungSpeichern(
      ErinnerungModel erinnerung, String zyklusId);

  /// Lädt alle Erinnerungen eines bestimmten Lebenszyklus.
  /// Sortierung: aufsteigend nach Alter.
  Future<List<ErinnerungModel>> erinnerungenLaden(String zyklusId);

  // ───────────────────────────────────────────────────────────────────────────
  // Gedanken
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert einen inneren Gedanken des Charakters.
  Future<void> gedankeSpeichern(GedankeModel gedanke);

  /// Lädt alle Gedanken, die einem bestimmten Lebenszyklus zugeordnet sind.
  Future<List<GedankeModel>> gedankenFuerZyklus(String zyklusId);

  // ───────────────────────────────────────────────────────────────────────────
  // Beziehungen
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert eine Beziehung und verknüpft sie mit einem Zyklus.
  Future<void> beziehungSpeichern(BeziehungModel beziehung, String zyklusId);

  /// Lädt alle Beziehungen eines bestimmten Lebenszyklus.
  Future<List<BeziehungModel>> beziehungenLaden(String zyklusId);
}
