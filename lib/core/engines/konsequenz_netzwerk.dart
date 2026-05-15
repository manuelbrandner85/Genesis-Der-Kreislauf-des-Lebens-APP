// konsequenz_netzwerk.dart
// Verarbeitet das Ausbreiten von Entscheidungsfolgen über Zeit und Phasen.
// Das Netzwerk verwaltet sofortige, verzögerte und generationelle Konsequenzen
// und berechnet Echo-Entscheidungen, die in späteren Zyklen zurückkehren.

import 'package:uuid/uuid.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/konsequenz_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/entscheidung_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KonsequenzNetzwerk – Laufzeit-Engine für Konsequenzausbreitung
// ─────────────────────────────────────────────────────────────────────────────

/// Verwaltet alle aktiven, ausstehenden und eingetretenen Konsequenzen
/// eines Lebenszyklus.
///
/// Das Netzwerk arbeitet als In-Memory-Graph: Konsequenzen werden über
/// [konsequenzenRegistrieren] hinzugefügt und über [alterSimulieren]
/// zu den passenden Zeitpunkten ausgelöst.
class KonsequenzNetzwerk {
  // Interne Liste aller registrierten Konsequenzen dieses Zyklus
  final List<KonsequenzModel> _aktiveKonsequenzen = [];

  // Alter, in dem der Zyklus begonnen hat (Referenzpunkt für Verzögerungen)
  int _startAlter = 0;

  // ───────────────────────────────────────────────────────────────────────────
  // Initialisierung
  // ───────────────────────────────────────────────────────────────────────────

  /// Setzt das Startalter des Zyklus für relative Zeitberechnung.
  void startAlterSetzen(int alter) {
    _startAlter = alter;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Konsequenzen registrieren
  // ───────────────────────────────────────────────────────────────────────────

  /// Extrahiert und registriert alle Konsequenzen einer Entscheidung.
  ///
  /// Sofortige Konsequenzen (Typ [KonsequenzTyp.sofort]) werden mit
  /// [verzoegerungInJahren] == 0 gespeichert und beim nächsten
  /// [alterSimulieren]-Aufruf sofort ausgelöst.
  ///
  /// Verzögerte Konsequenzen erhalten ihre Verzögerung aus den
  /// [verzoegerteKonsequenzen]-Texten der gewählten Option.
  void konsequenzenRegistrieren(
    EntscheidungModel entscheidung,
    int optionIndex,
  ) {
    // Sicherheitsprüfung: Optionsindex muss gültig sein
    if (optionIndex < 0 || optionIndex >= entscheidung.optionen.length) return;

    const uuid = Uuid();
    final option = entscheidung.optionen[optionIndex];

    // ── Sofortige Konsequenzen ────────────────────────────────────────────
    for (int i = 0; i < option.sofortigeKonsequenzen.length; i++) {
      final konsequenz = KonsequenzModel(
        id: uuid.v4(),
        quelleEntscheidungId: entscheidung.id,
        beschreibung: option.sofortigeKonsequenzen[i],
        typ: KonsequenzTyp.sofort,
        verzoegerungInJahren: 0,
        verzoegerungInPhasen: null,
        istEingetreten: false,
        // Karma-Auswirkungen aus der Option extrahieren
        attributAuswirkungen: option.karmaAuswirkung.map(
          (dim, wert) => MapEntry(dim.name, wert),
        ),
        betroffeneBeziehungen: const [],
      );
      _aktiveKonsequenzen.add(konsequenz);
    }

    // ── Verzögerte Konsequenzen ───────────────────────────────────────────
    // Verzögerung wird aus dem Index abgeleitet: 1. Verzögerung = 5 Jahre,
    // 2. Verzögerung = 10 Jahre, 3. = 15 Jahre (gamedesign-sinnvoll)
    for (int i = 0; i < option.verzoegerteKonsequenzen.length; i++) {
      final verzoegerung = (i + 1) * 5; // 5, 10, 15 Jahre
      final konsequenz = KonsequenzModel(
        id: uuid.v4(),
        quelleEntscheidungId: entscheidung.id,
        beschreibung: option.verzoegerteKonsequenzen[i],
        typ: KonsequenzTyp.verzoegert,
        verzoegerungInJahren: verzoegerung,
        verzoegerungInPhasen: null,
        istEingetreten: false,
        attributAuswirkungen: option.karmaAuswirkung.map(
          (dim, wert) => MapEntry(dim.name, wert * 0.5), // Hälfte der Wirkung
        ),
        betroffeneBeziehungen: const [],
      );
      _aktiveKonsequenzen.add(konsequenz);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Alter simulieren
  // ───────────────────────────────────────────────────────────────────────────

  /// Prüft alle ausstehenden Konsequenzen und gibt alle zurück, die
  /// beim Erreichen von [neuesAlter] eintreten.
  ///
  /// Eine Konsequenz tritt ein, wenn:
  /// - Sie noch nicht eingetreten ist ([istEingetreten] == false)
  /// - Ihr Fälligkeitsalter ([_startAlter] + [verzoegerungInJahren]) erreicht ist
  ///
  /// Die eingetretenen Konsequenzen werden intern als ausgelöst markiert.
  List<KonsequenzModel> alterSimulieren(int neuesAlter, GamePhase phase) {
    final eingetretenJetzt = <KonsequenzModel>[];

    for (int i = 0; i < _aktiveKonsequenzen.length; i++) {
      final k = _aktiveKonsequenzen[i];
      if (k.istEingetreten) continue;

      // Fälligkeitsalter berechnen
      final faelligAlter = _startAlter + k.verzoegerungInJahren;

      // Tritt ein wenn aktuelles Alter das Fälligkeitsalter erreicht oder überschreitet
      if (neuesAlter >= faelligAlter) {
        // Als eingetreten markieren (immutable: neue Instanz erstellen)
        _aktiveKonsequenzen[i] = k.copyWith(istEingetreten: true);
        eingetretenJetzt.add(_aktiveKonsequenzen[i]);
      }
    }

    return eingetretenJetzt;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Echo-Entscheidung berechnen
  // ───────────────────────────────────────────────────────────────────────────

  /// Berechnet ein Echo einer vergangenen Entscheidung für einen späteren Zyklus.
  ///
  /// Ein Echo ist eine leicht veränderte Rückkehr einer signifikanten
  /// Entscheidungssituation – der Spieler bekommt eine zweite Chance,
  /// mit gewachsenem Bewusstsein anders zu wählen.
  ///
  /// - [originalEntscheidung]: Die Entscheidung, deren Echo berechnet wird
  /// - [zyklusNummer]: Der aktuelle Zyklus-Index (Echo erscheint frühestens ab Zyklus 2)
  ///
  /// Gibt [null] zurück, wenn kein sinnvolles Echo generiert werden kann.
  KonsequenzModel? echoBerechnen(
    EntscheidungModel originalEntscheidung,
    int zyklusNummer,
  ) {
    // Echos erscheinen frühestens im zweiten Lebenszyklus
    if (zyklusNummer < 2) return null;

    // Nur bereits getroffene Entscheidungen können Echo erzeugen
    if (!originalEntscheidung.istGetroffen) return null;

    // Keine Mikro-Entscheidungen (zu trivial für ein Echo)
    if (originalEntscheidung.istMikroEntscheidung) return null;

    const uuid = Uuid();

    // Echo-Konsequenz: Die ursprüngliche Entscheidung kehrt als neue Prüfung zurück.
    // Attributauswirkungen sind invertiert (zweite Chance bedeutet umgekehrtes Potential)
    final echoAttributAuswirkungen = <String, double>{};
    if (originalEntscheidung.gewaehltOption != null) {
      for (final eintrag
          in originalEntscheidung.gewaehltOption!.karmaAuswirkung.entries) {
        // Echo: Kleiner positiver Bonus als Hinweis auf die richtige Richtung
        echoAttributAuswirkungen[eintrag.key.name] =
            (eintrag.value * 0.25).clamp(-10.0, 10.0);
      }
    }

    return KonsequenzModel(
      id: 'echo_${originalEntscheidung.id}_zyklus_$zyklusNummer',
      quelleEntscheidungId: originalEntscheidung.id,
      beschreibung:
          'Ein Echo aus einem vergangenen Leben: "${originalEntscheidung.frage}" '
          'kehrt in anderer Form zurück. Deine Seele erinnert sich.',
      typ: KonsequenzTyp.generationell,
      verzoegerungInJahren: 0, // Sofortige Präsentation beim Auftreten
      verzoegerungInPhasen: null,
      istEingetreten: false,
      attributAuswirkungen: echoAttributAuswirkungen,
      betroffeneBeziehungen: const [],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Beziehungs-Einfluss berechnen
  // ───────────────────────────────────────────────────────────────────────────

  /// Berechnet den aggregierten Einfluss einer Liste von Konsequenzen
  /// auf bestehende Beziehungen.
  ///
  /// Gibt eine Map zurück: Beziehungs-ID → kumulierter Einfluss-Wert.
  /// Positive Werte stärken die Beziehung, negative schwächen sie.
  Map<String, double> beziehungsEinflussBerechnen(
    List<KonsequenzModel> konsequenzen,
  ) {
    final einfluss = <String, double>{};

    for (final konsequenz in konsequenzen) {
      for (final beziehungsId in konsequenz.betroffeneBeziehungen) {
        // Gesamtwirkung auf diese Beziehung als Durchschnitt der Attribute
        final durchschnittlicheWirkung =
            konsequenz.attributAuswirkungen.values.isEmpty
                ? 0.0
                : konsequenz.attributAuswirkungen.values
                        .fold(0.0, (sum, v) => sum + v) /
                    konsequenz.attributAuswirkungen.length;

        einfluss[beziehungsId] =
            (einfluss[beziehungsId] ?? 0.0) + durchschnittlicheWirkung;
      }
    }

    return einfluss;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Konsequenz manuell hinzufügen
  // ───────────────────────────────────────────────────────────────────────────

  /// Fügt eine fertig konstruierte [KonsequenzModel]-Instanz direkt hinzu.
  /// Nützlich zum Wiederherstellen des Netzwerks aus dem Hive-Speicher.
  void konsequenzHinzufuegen(KonsequenzModel konsequenz) {
    _aktiveKonsequenzen.add(konsequenz);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Konsequenz als eingetreten markieren
  // ───────────────────────────────────────────────────────────────────────────

  /// Markiert eine Konsequenz anhand ihrer ID als eingetreten.
  /// Nützlich zur Synchronisation mit dem persistenten Zustand.
  void alsEingetretenMarkieren(String konsequenzId) {
    final index = _aktiveKonsequenzen.indexWhere((k) => k.id == konsequenzId);
    if (index == -1) return;
    _aktiveKonsequenzen[index] =
        _aktiveKonsequenzen[index].copyWith(istEingetreten: true);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Netzwerk zurücksetzen
  // ───────────────────────────────────────────────────────────────────────────

  /// Löscht alle Konsequenzen des aktuellen Zyklus.
  /// Wird beim Start eines neuen Lebenszyklus aufgerufen.
  void zuruecksetzen() {
    _aktiveKonsequenzen.clear();
    _startAlter = 0;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Getter
  // ───────────────────────────────────────────────────────────────────────────

  /// Alle registrierten Konsequenzen (eingetreten und ausstehend)
  List<KonsequenzModel> get alleAktiven =>
      List.unmodifiable(_aktiveKonsequenzen);

  /// Nur bereits eingetretene Konsequenzen
  List<KonsequenzModel> get eingetreten =>
      _aktiveKonsequenzen.where((k) => k.istEingetreten).toList();

  /// Nur noch ausstehende Konsequenzen (noch nicht eingetreten)
  List<KonsequenzModel> get ausstehend =>
      _aktiveKonsequenzen.where((k) => !k.istEingetreten).toList();

  /// Gesamtanzahl aller registrierten Konsequenzen
  int get anzahl => _aktiveKonsequenzen.length;

  /// Anzahl noch ausstehender Konsequenzen
  int get anzahlAusstehend =>
      _aktiveKonsequenzen.where((k) => !k.istEingetreten).length;
}
