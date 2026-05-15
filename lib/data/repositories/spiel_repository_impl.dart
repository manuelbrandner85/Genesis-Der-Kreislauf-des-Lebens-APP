// spiel_repository_impl.dart
// Konkrete Implementierung des SpielRepository-Interfaces.
// Verwendet den HiveDienst als lokalen Datenspeicher und führt alle
// JSON-Serialisierungen über die Modellklassen durch.

import 'package:genesis_kreislauf_des_lebens/data/local/hive_dienst.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/beziehung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/erinnerung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/entscheidung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/konsequenz_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/spieler_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';
import 'package:genesis_kreislauf_des_lebens/domain/repositories/spiel_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SpielRepositoryImpl
// ─────────────────────────────────────────────────────────────────────────────

/// Hive-basierte Implementierung des [SpielRepository].
///
/// Alle Lese- und Schreiboperationen delegieren an den [HiveDienst],
/// der als einzelne Quelle der Wahrheit für persistente Spielzustände dient.
class SpielRepositoryImpl implements SpielRepository {
  /// Referenz auf den zentralen Hive-Datenbankdienst.
  final HiveDienst _hiveDienst;

  /// Erstellt eine neue Instanz mit dem übergebenen [HiveDienst].
  const SpielRepositoryImpl({required HiveDienst hiveDienst})
      : _hiveDienst = hiveDienst;

  // ───────────────────────────────────────────────────────────────────────────
  // Spieler-Profil
  // ───────────────────────────────────────────────────────────────────────────

  /// Lädt ein Spielerprofil anhand seiner ID aus dem lokalen Speicher.
  /// Gibt [null] zurück, wenn kein Profil mit dieser ID gefunden wurde.
  @override
  Future<SpielerProfilModel?> profilLaden(String id) async {
    final json = await _hiveDienst.spielerProfilLaden(id);
    if (json == null) return null;
    return SpielerProfilModel.fromJson(json);
  }

  /// Serialisiert das Profil und speichert es im Hive-Speicher.
  @override
  Future<void> profilSpeichern(SpielerProfilModel profil) async {
    await _hiveDienst.spielerProfilSpeichern(profil.toJson());
  }

  /// Lädt alle gespeicherten Spielerprofile und wandelt sie in Modelle um.
  @override
  Future<List<SpielerProfilModel>> alleProfileLaden() async {
    final rohliste = await _hiveDienst.alleSpielerProfileLaden();
    return rohliste
        .map((json) => SpielerProfilModel.fromJson(json))
        .toList();
  }

  /// Löscht das Profil mit der angegebenen ID aus dem Hive-Speicher.
  @override
  Future<void> profilLoeschen(String id) async {
    await _hiveDienst.spielerProfilLoeschen(id);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Zyklus
  // ───────────────────────────────────────────────────────────────────────────

  /// Lädt einen einzelnen Lebenszyklus anhand seiner ID.
  /// Gibt [null] zurück, wenn kein Zyklus mit dieser ID vorhanden ist.
  @override
  Future<ZyklusModel?> zyklusLaden(String id) async {
    final json = await _hiveDienst.zyklusLaden(id);
    if (json == null) return null;
    return ZyklusModel.fromJson(json);
  }

  /// Serialisiert den Zyklus und speichert ihn dauerhaft im Hive-Speicher.
  @override
  Future<void> zyklusSpeichern(ZyklusModel zyklus) async {
    await _hiveDienst.zyklusSpeichern(zyklus.toJson());
  }

  /// Lädt alle Lebenszyklen, die dem übergebenen Profil zugeordnet sind.
  /// Die Rückgabeliste ist nach Zyklusnummer aufsteigend sortiert.
  @override
  Future<List<ZyklusModel>> zyklenFuerProfil(String profilId) async {
    final rohliste = await _hiveDienst.alleZyklenFuerProfil(profilId);
    final zyklen = rohliste
        .map((json) => ZyklusModel.fromJson(json))
        .toList();

    // Aufsteigend nach Zyklusnummer sortieren (ältestes Leben zuerst)
    zyklen.sort((a, b) => a.zyklusNummer.compareTo(b.zyklusNummer));
    return zyklen;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Entscheidungen
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert eine Entscheidung und verknüpft sie mit dem angegebenen Zyklus.
  /// Die zyklusId wird als Metadatum in der serialisierten Map hinterlegt.
  @override
  Future<void> entscheidungSpeichern(
      EntscheidungModel entscheidung, String zyklusId) async {
    // zyklusId als Verknüpfungsfeld hinzufügen
    final json = entscheidung.toJson();
    json['zyklusId'] = zyklusId;
    await _hiveDienst.entscheidungSpeichern(json);
  }

  /// Lädt alle Entscheidungen, die in einem bestimmten Zyklus getroffen wurden.
  @override
  Future<List<EntscheidungModel>> entscheidungenLaden(String zyklusId) async {
    final rohliste =
        await _hiveDienst.entscheidungenFuerZyklus(zyklusId);
    return rohliste
        .map((json) => EntscheidungModel.fromJson(json))
        .toList();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Konsequenzen
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert eine neue Konsequenz (sofortig oder verzögert).
  @override
  Future<void> konsequenzHinzufuegen(KonsequenzModel konsequenz) async {
    await _hiveDienst.konsequenzSpeichern(konsequenz.toJson());
  }

  /// Lädt alle Konsequenzen, die für den angegebenen Zyklus und das aktuelle
  /// Alter fällig sind (noch nicht eingetreten und Alter erreicht).
  @override
  Future<List<KonsequenzModel>> faelligeKonsequenzenLaden(
      String zyklusId, int alter) async {
    final rohliste =
        await _hiveDienst.faelligeKonsequenzen(zyklusId, alter);
    return rohliste
        .map((json) => KonsequenzModel.fromJson(json))
        .toList();
  }

  /// Markiert eine Konsequenz als eingetreten (ausgelöst) im Hive-Speicher.
  @override
  Future<void> konsequenzAlsEingetretenMarkieren(
      String konsequenzId) async {
    await _hiveDienst.konsequenzAlsAusgeloestMarkieren(konsequenzId);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Erinnerungen
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert eine emotionale Erinnerung und verknüpft sie mit dem Zyklus.
  @override
  Future<void> erinnerungSpeichern(
      ErinnerungModel erinnerung, String zyklusId) async {
    await _hiveDienst.erinnerungSpeichern(erinnerung.toJson(), zyklusId);
  }

  /// Lädt alle Erinnerungen eines Zyklus, aufsteigend nach Alter sortiert.
  @override
  Future<List<ErinnerungModel>> erinnerungenLaden(String zyklusId) async {
    final rohliste =
        await _hiveDienst.erinnerungenFuerZyklus(zyklusId);
    return rohliste
        .map((json) => ErinnerungModel.fromJson(json))
        .toList();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Gedanken
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert einen inneren Gedanken des Charakters im Hive-Speicher.
  @override
  Future<void> gedankeSpeichern(GedankeModel gedanke) async {
    await _hiveDienst.gedankeSpeichern(gedanke.toJson());
  }

  /// Lädt alle Gedanken, die einem bestimmten Lebenszyklus zugeordnet sind.
  @override
  Future<List<GedankeModel>> gedankenFuerZyklus(String zyklusId) async {
    final rohliste = await _hiveDienst.gedankenFuerZyklus(zyklusId);
    return rohliste
        .map((json) => GedankeModel.fromJson(json))
        .toList();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Beziehungen
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert eine Beziehung und verknüpft sie mit dem angegebenen Zyklus.
  @override
  Future<void> beziehungSpeichern(
      BeziehungModel beziehung, String zyklusId) async {
    final json = beziehung.toJson();
    json['zyklusId'] = zyklusId;
    await _hiveDienst.beziehungSpeichern(json);
  }

  /// Lädt alle Beziehungen, die in einem bestimmten Lebenszyklus bestehen.
  @override
  Future<List<BeziehungModel>> beziehungenLaden(String zyklusId) async {
    final rohliste =
        await _hiveDienst.beziehungenFuerZyklus(zyklusId);
    return rohliste
        .map((json) => BeziehungModel.fromJson(json))
        .toList();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Verwaltung
  // ───────────────────────────────────────────────────────────────────────────

  /// Löscht alle gespeicherten Spielstände – delegiert an [HiveDienst.allesDatenLoeschen].
  @override
  Future<void> allesZuruecksetzen() async {
    await _hiveDienst.allesDatenLoeschen();
  }
}
