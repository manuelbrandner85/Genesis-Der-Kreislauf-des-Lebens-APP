// hive_dienst.dart
// Zentraler Hive-Datenbankdienst für GENESIS: Der Kreislauf des Lebens.
// Verwaltet alle lokalen Persistenzoperationen über typisierte Hive-Boxen.

import 'package:hive_flutter/hive_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Box-Namen als Konstanten
// ─────────────────────────────────────────────────────────────────────────────

/// Box-Name für das Spielerprofil (Seelen-Ebene). [HiveDienst.spielstandBox]
const String kSpielerProfilBox = 'spielerProfil';

/// Box-Name für alle Lebenszyklen. [HiveDienst.zyklenBox]
const String kZyklenBox = 'zyklen';

/// Box-Name für emotionale Erinnerungen. [HiveDienst.erinnerungenBox]
const String kErinnerungenBox = 'erinnerungen';

/// Box-Name für innere Gedanken des Charakters. [HiveDienst.gedankenBox]
const String kGedankenBox = 'gedanken';

/// Box-Name für soziale Beziehungen. [HiveDienst.beziehungenBox]
const String kBeziehungenBox = 'beziehungen';

/// Box-Name für getroffene Entscheidungen. [HiveDienst.entscheidungenBox]
const String kEntscheidungenBox = 'entscheidungen';

/// Box-Name für Konsequenzen aus Entscheidungen. [HiveDienst.konsequenzenBox]
const String kKonsequenzenBox = 'konsequenzen';

/// Box-Name für Spieleinstellungen.
const String kEinstellungenBox = 'einstellungen';

/// Box-Name für Bibliotheks-Einträge.
const String kBibliothekBox = 'bibliothek';

// ─────────────────────────────────────────────────────────────────────────────
// HiveDienst
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton-Dienst für alle Hive-Datenbankoperationen.
///
/// Alle CRUD-Operationen arbeiten mit [Map<String, dynamic>] als
/// serialisiertes Format – die Modellklassen übernehmen die Konvertierung.
///
/// Zugriff entweder über [HiveDienst.instanz] oder über den
/// factory-Konstruktor [HiveDienst()].
class HiveDienst {
  // Privater Konstruktor – Singleton-Muster
  HiveDienst._intern();

  /// Die einzige Instanz dieses Dienstes (über factory-Konstruktor erreichbar).
  static final HiveDienst _instanz = HiveDienst._intern();

  /// Die einzige Instanz dieses Dienstes (benannter Zugriff).
  static HiveDienst get instanz => _instanz;

  /// Factory-Konstruktor für den Singleton-Zugriff via [HiveDienst()].
  factory HiveDienst() => _instanz;

  // ── Box-Namen als statische Konstanten ────────────────────────────────────
  static const String spielstandBox = kSpielerProfilBox;
  static const String zyklenBox = kZyklenBox;
  static const String gedankenBox = kGedankenBox;
  static const String erinnerungenBox = kErinnerungenBox;
  static const String einstellungenBox = kEinstellungenBox;
  static const String bibliothekBox = kBibliothekBox;

  // Interne Box-Referenzen (werden in [initialisieren] geöffnet)
  static late Box<Map> _spielerProfilBox;
  static late Box<Map> _zyklenBox;
  static late Box<Map> _erinnerungenBox;
  static late Box<Map> _gedankenBox;
  static late Box<Map> _beziehungenBox;
  static late Box<Map> _entscheidungenBox;
  static late Box<Map> _konsequenzenBox;
  static late Box<dynamic> _einstellungenBox;
  static late Box<Map> _bibliothekBox;

  // ───────────────────────────────────────────────────────────────────────────
  // Initialisierung
  // ───────────────────────────────────────────────────────────────────────────

  /// Initialisiert Hive und öffnet alle erforderlichen Boxen.
  ///
  /// Muss vor der ersten Nutzung aufgerufen werden (typisch in main()).
  static Future<void> initialisieren() async {
    // Hive für Flutter initialisieren (setzt das Datenverzeichnis)
    await Hive.initFlutter();

    // Alle Boxen gleichzeitig öffnen für schnelleres Startup
    final ergebnisse = await Future.wait([
      Hive.openBox<Map>(kSpielerProfilBox),
      Hive.openBox<Map>(kZyklenBox),
      Hive.openBox<Map>(kErinnerungenBox),
      Hive.openBox<Map>(kGedankenBox),
      Hive.openBox<Map>(kBeziehungenBox),
      Hive.openBox<Map>(kEntscheidungenBox),
      Hive.openBox<Map>(kKonsequenzenBox),
      Hive.openBox(kEinstellungenBox),
      Hive.openBox<Map>(kBibliothekBox),
    ]);

    _spielerProfilBox = ergebnisse[0] as Box<Map>;
    _zyklenBox = ergebnisse[1] as Box<Map>;
    _erinnerungenBox = ergebnisse[2] as Box<Map>;
    _gedankenBox = ergebnisse[3] as Box<Map>;
    _beziehungenBox = ergebnisse[4] as Box<Map>;
    _entscheidungenBox = ergebnisse[5] as Box<Map>;
    _konsequenzenBox = ergebnisse[6] as Box<Map>;
    _einstellungenBox = ergebnisse[7] as Box<dynamic>;
    _bibliothekBox = ergebnisse[8] as Box<Map>;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SpielerProfil CRUD
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert ein Spielerprofil unter seiner ID.
  Future<void> spielerProfilSpeichern(Map<String, dynamic> profil) async {
    final id = profil['id'] as String;
    await _spielerProfilBox.put(id, profil);
  }

  /// Lädt ein einzelnes Spielerprofil anhand seiner ID.
  /// Gibt [null] zurück, wenn kein Eintrag gefunden wurde.
  Future<Map<String, dynamic>?> spielerProfilLaden(String id) async {
    final rohdaten = _spielerProfilBox.get(id);
    if (rohdaten == null) return null;
    return Map<String, dynamic>.from(rohdaten);
  }

  /// Lädt alle gespeicherten Spielerprofile.
  Future<List<Map<String, dynamic>>> alleSpielerProfileLaden() async {
    return _spielerProfilBox.values
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  /// Löscht ein Spielerprofil anhand seiner ID.
  Future<void> spielerProfilLoeschen(String id) async {
    await _spielerProfilBox.delete(id);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Zyklus CRUD
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert einen Lebenszyklus unter seiner ID.
  Future<void> zyklusSpeichern(Map<String, dynamic> zyklus) async {
    final id = zyklus['id'] as String;
    await _zyklenBox.put(id, zyklus);
  }

  /// Lädt einen einzelnen Lebenszyklus anhand seiner ID.
  /// Gibt [null] zurück, wenn kein Eintrag gefunden wurde.
  Future<Map<String, dynamic>?> zyklusLaden(String id) async {
    final rohdaten = _zyklenBox.get(id);
    if (rohdaten == null) return null;
    return Map<String, dynamic>.from(rohdaten);
  }

  /// Lädt alle Lebenszyklen, die einem bestimmten Spielerprofil zugeordnet sind.
  Future<List<Map<String, dynamic>>> alleZyklenFuerProfil(
      String profilId) async {
    return _zyklenBox.values
        .map((m) => Map<String, dynamic>.from(m))
        .where((m) => m['profilId'] == profilId)
        .toList();
  }

  /// Löscht einen Lebenszyklus anhand seiner ID.
  Future<void> zyklusLoeschen(String id) async {
    await _zyklenBox.delete(id);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Erinnerung CRUD
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert eine Erinnerung und verknüpft sie mit einem Zyklus.
  ///
  /// Die [zyklusId] wird als Feld in der Erinnerungs-Map gesetzt,
  /// damit spätere Abfragen nach Zyklus filtern können.
  Future<void> erinnerungSpeichern(
      Map<String, dynamic> erinnerung, String zyklusId) async {
    final daten = Map<String, dynamic>.from(erinnerung);
    daten['zyklusId'] = zyklusId;
    final id = daten['id'] as String;
    await _erinnerungenBox.put(id, daten);
  }

  /// Lädt alle Erinnerungen eines bestimmten Lebenszyklus.
  /// Sortierung: aufsteigend nach Alter (älteste zuerst).
  Future<List<Map<String, dynamic>>> erinnerungenFuerZyklus(
      String zyklusId) async {
    final liste = _erinnerungenBox.values
        .map((m) => Map<String, dynamic>.from(m))
        .where((m) => m['zyklusId'] == zyklusId)
        .toList();

    // Nach Alter sortieren (aufsteigend)
    liste.sort((a, b) =>
        (a['alter'] as int? ?? 0).compareTo(b['alter'] as int? ?? 0));
    return liste;
  }

  /// Löscht eine Erinnerung anhand ihrer ID.
  Future<void> erinnerungLoeschen(String id) async {
    await _erinnerungenBox.delete(id);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Gedanke CRUD
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert einen Gedanken in der Datenbank.
  Future<void> gedankeSpeichern(Map<String, dynamic> gedanke) async {
    final id = gedanke['id'] as String;
    await _gedankenBox.put(id, gedanke);
  }

  /// Lädt alle Gedanken eines bestimmten Lebenszyklus.
  /// Filtert nach dem Feld 'herkunftZyklusId' in den Gedanken-Daten.
  Future<List<Map<String, dynamic>>> gedankenFuerZyklus(
      String zyklusId) async {
    return _gedankenBox.values
        .map((m) => Map<String, dynamic>.from(m))
        .where((m) => m['herkunftZyklusId'] == zyklusId)
        .toList();
  }

  /// Löscht einen Gedanken anhand seiner ID.
  Future<void> gedankeLoeschen(String id) async {
    await _gedankenBox.delete(id);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Entscheidung CRUD
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert eine getroffene Entscheidung.
  ///
  /// Die [zyklusId] wird als Feld in der Entscheidungs-Map gesetzt.
  Future<void> entscheidungSpeichern(Map<String, dynamic> entscheidung) async {
    final id = entscheidung['id'] as String;
    await _entscheidungenBox.put(id, entscheidung);
  }

  /// Lädt alle Entscheidungen eines bestimmten Lebenszyklus.
  Future<List<Map<String, dynamic>>> entscheidungenFuerZyklus(
      String zyklusId) async {
    return _entscheidungenBox.values
        .map((m) => Map<String, dynamic>.from(m))
        .where((m) => m['zyklusId'] == zyklusId)
        .toList();
  }

  /// Löscht eine Entscheidung anhand ihrer ID.
  Future<void> entscheidungLoeschen(String id) async {
    await _entscheidungenBox.delete(id);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Konsequenz CRUD
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert eine Konsequenz (sofortig oder verzögert).
  Future<void> konsequenzSpeichern(Map<String, dynamic> konsequenz) async {
    final id = konsequenz['id'] as String;
    await _konsequenzenBox.put(id, konsequenz);
  }

  /// Lädt alle fälligen Konsequenzen für einen Zyklus und ein bestimmtes Alter.
  ///
  /// Eine Konsequenz gilt als fällig, wenn:
  /// - Sie zum angegebenen [zyklusId] gehört
  /// - Ihr 'faelligAlter' <= [aktuellesAlter]
  /// - Sie noch nicht ausgelöst wurde ('istAusgeloest' == false)
  Future<List<Map<String, dynamic>>> faelligeKonsequenzen(
      String zyklusId, int aktuellesAlter) async {
    return _konsequenzenBox.values
        .map((m) => Map<String, dynamic>.from(m))
        .where((m) =>
            m['zyklusId'] == zyklusId &&
            (m['faelligAlter'] as int? ?? 0) <= aktuellesAlter &&
            (m['istAusgeloest'] as bool? ?? false) == false)
        .toList();
  }

  /// Markiert eine Konsequenz als ausgelöst.
  Future<void> konsequenzAlsAusgeloestMarkieren(String id) async {
    final rohdaten = _konsequenzenBox.get(id);
    if (rohdaten == null) return;
    final daten = Map<String, dynamic>.from(rohdaten);
    daten['istAusgeloest'] = true;
    await _konsequenzenBox.put(id, daten);
  }

  /// Löscht eine Konsequenz anhand ihrer ID.
  Future<void> konsequenzLoeschen(String id) async {
    await _konsequenzenBox.delete(id);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Beziehung CRUD
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert eine Beziehung zu einer NPC-Person.
  Future<void> beziehungSpeichern(Map<String, dynamic> beziehung) async {
    final id = beziehung['id'] as String;
    await _beziehungenBox.put(id, beziehung);
  }

  /// Lädt alle Beziehungen eines bestimmten Lebenszyklus.
  Future<List<Map<String, dynamic>>> beziehungenFuerZyklus(
      String zyklusId) async {
    return _beziehungenBox.values
        .map((m) => Map<String, dynamic>.from(m))
        .where((m) => m['zyklusId'] == zyklusId)
        .toList();
  }

  /// Löscht eine Beziehung anhand ihrer ID.
  Future<void> beziehungLoeschen(String id) async {
    await _beziehungenBox.delete(id);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Einstellungen CRUD
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert einen Einstellungswert unter dem angegebenen Schlüssel.
  Future<void> einstellungSetzen(String schluessel, dynamic wert) async {
    await _einstellungenBox.put(schluessel, wert);
  }

  /// Lädt einen Einstellungswert. Gibt [standard] zurück wenn nicht vorhanden.
  T? einstellungLaden<T>(String schluessel, {T? standard}) {
    final wert = _einstellungenBox.get(schluessel);
    if (wert == null) return standard;
    return wert as T?;
  }

  /// Löscht einen einzelnen Einstellungswert.
  Future<void> einstellungEntfernen(String schluessel) async {
    await _einstellungenBox.delete(schluessel);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Bibliothek CRUD
  // ───────────────────────────────────────────────────────────────────────────

  /// Speichert einen Bibliotheks-Eintrag (freigeschaltete Weisheiten, Texte, etc.).
  Future<void> bibliotheksEintragSpeichern(
      String schluessel, Map<String, dynamic> daten) async {
    await _bibliothekBox.put(schluessel, daten);
  }

  /// Lädt einen einzelnen Bibliotheks-Eintrag anhand seines Schlüssels.
  Map<String, dynamic>? bibliotheksEintragLaden(String schluessel) {
    final rohdaten = _bibliothekBox.get(schluessel);
    if (rohdaten == null) return null;
    return Map<String, dynamic>.from(rohdaten);
  }

  /// Lädt alle gespeicherten Bibliotheks-Einträge.
  Map<String, Map<String, dynamic>> alleBibliotheksEintraegeLaden() {
    return {
      for (final eintrag in _bibliothekBox.toMap().entries)
        eintrag.key as String: Map<String, dynamic>.from(eintrag.value as Map),
    };
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Verwaltung & Wartung
  // ───────────────────────────────────────────────────────────────────────────

  /// Löscht alle gespeicherten Daten aus allen Boxen.
  ///
  /// Nur für Tests und den "Neues Spiel"-Modus gedacht.
  Future<void> allesDatenLoeschen() async {
    await Future.wait([
      _spielerProfilBox.clear(),
      _zyklenBox.clear(),
      _erinnerungenBox.clear(),
      _gedankenBox.clear(),
      _beziehungenBox.clear(),
      _entscheidungenBox.clear(),
      _konsequenzenBox.clear(),
      _einstellungenBox.clear(),
      _bibliothekBox.clear(),
    ]);
  }

  /// Alias für [allesDatenLoeschen] – für "Gespeicherte Daten löschen"-Funktion
  /// in den Einstellungen verwendet.
  Future<void> allesLoeschen() => allesDatenLoeschen();

  /// Schließt alle Hive-Boxen sauber (für App-Beendigung).
  Future<void> allesSchliessen() async {
    await Hive.close();
  }

  /// Alias für [allesSchliessen].
  Future<void> schliessen() => allesSchliessen();

  /// Gibt die Gesamtanzahl gespeicherter Einträge aller Boxen zurück.
  /// Nützlich für Debug-Ausgaben und Statistiken.
  Map<String, int> datenbankStatistik() {
    return {
      'spielerProfile': _spielerProfilBox.length,
      'zyklen': _zyklenBox.length,
      'erinnerungen': _erinnerungenBox.length,
      'gedanken': _gedankenBox.length,
      'beziehungen': _beziehungenBox.length,
      'entscheidungen': _entscheidungenBox.length,
      'konsequenzen': _konsequenzenBox.length,
    };
  }
}
