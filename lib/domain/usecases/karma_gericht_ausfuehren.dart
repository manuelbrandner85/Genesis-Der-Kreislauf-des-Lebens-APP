// karma_gericht_ausfuehren.dart
// UseCase: Führt das automatische Karma-Gericht nach dem Tod durch.
// Läuft vollständig ohne Spielereingabe – alle Entscheidungen werden
// algorithmisch auf Basis der gesammelten Erinnerungen und Gedanken getroffen.

import 'package:genesis_kreislauf_des_lebens/data/models/erinnerung_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/gedanke_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';
import 'package:genesis_kreislauf_des_lebens/domain/repositories/spiel_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KarmaGerichtErgebnis – Rückgabeobjekt des Karma-Gerichts
// ─────────────────────────────────────────────────────────────────────────────

/// Enthält alle Ergebnisse des automatischen Karma-Gerichts nach dem Tod.
class KarmaGerichtErgebnis {
  /// Das Jenseitsreich, das der Seele zugewiesen wurde.
  final JenseitsReich zugewiesenesReich;

  /// Die 1–3 prägendsten Erinnerungen, die das Gericht ausgewählt hat.
  final List<ErinnerungModel> ausgewaehlteErinnerungen;

  /// Gedanken, die ins nächste Leben mitgetragen werden (1–3).
  final List<GedankeModel> mitgenommeneGedanken;

  /// Gedanken, die losgelassen und nicht mitgetragen werden.
  final List<GedankeModel> losgelasseneGedanken;

  /// Narrativer Text für die Darstellung der Karma-Gericht-Sequenz.
  final String narrativerMoment;

  /// Das finale Karma-Profil am Ende dieses Lebens.
  final KarmaProfilModel finalesKarma;

  const KarmaGerichtErgebnis({
    required this.zugewiesenesReich,
    required this.ausgewaehlteErinnerungen,
    required this.mitgenommeneGedanken,
    required this.losgelasseneGedanken,
    required this.narrativerMoment,
    required this.finalesKarma,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// KarmaGerichtAusfuehren UseCase
// ─────────────────────────────────────────────────────────────────────────────

/// UseCase: Automatisches Karma-Gericht nach dem Tod eines Charakters.
///
/// Das Gericht analysiert vollständig alle Erinnerungen und Gedanken eines
/// Lebens und trifft algorithmisch folgende Entscheidungen:
/// 1. Erinnerungen nach Intensität, Wiederholung und offenem Status analysieren
/// 2. 1–3 prägende Erinnerungen auswählen (offen vs. abgeschlossen)
/// 3. Mitgenommene Gedanken bestimmen (Tiefe und Unabgeschlossenheit)
/// 4. Jenseits-Reich auf Basis des finalen Karma-Profils berechnen
/// 5. Narrativen Moment für die Sequenz generieren
class KarmaGerichtAusfuehren {
  final SpielRepository _repository;

  /// Maximale Anzahl an Erinnerungen, die das Gericht auswählt.
  static const int _maxAusgewaehlteErinnerungen = 3;

  /// Maximale Anzahl an Gedanken, die ins nächste Leben mitgenommen werden.
  static const int _maxMitgenommeneGedanken = 3;

  /// Intensitätsschwelle: Nur Erinnerungen ab diesem Wert werden berücksichtigt.
  static const double _erinnerungsIntensitaetsSchwelle = 0.4;

  /// Erstellt den UseCase mit dem benötigten [SpielRepository].
  const KarmaGerichtAusfuehren({required SpielRepository repository})
      : _repository = repository;

  // ───────────────────────────────────────────────────────────────────────────
  // Haupt-Methode: ausfuehren
  // ───────────────────────────────────────────────────────────────────────────

  /// Führt das Karma-Gericht vollständig durch und gibt das Ergebnis zurück.
  ///
  /// - [abgeschlossenerZyklus]: Der soeben beendete Lebenszyklus.
  /// - [alleErinnerungen]: Alle gesammelten Erinnerungen dieses Lebens.
  /// - [alleGedanken]: Alle Gedanken, die in diesem Leben entstanden sind.
  Future<KarmaGerichtErgebnis> ausfuehren({
    required ZyklusModel abgeschlossenerZyklus,
    required List<ErinnerungModel> alleErinnerungen,
    required List<GedankeModel> alleGedanken,
  }) async {
    // ── Schritt 1: Erinnerungen analysieren ──────────────────────────────────
    final relevanteErinnerungen = _relevanteErinnerungenFiltern(
        alleErinnerungen);

    // ── Schritt 2: 1–3 prägende Erinnerungen auswählen ──────────────────────
    // Sortierung: offene, unerledigte Erinnerungen zuerst (nicht gut/schlecht)
    final ausgewaehlteErinnerungen =
        _praegendeErinnerungenAuswaehlen(relevanteErinnerungen);

    // Ausgewählte Erinnerungen als Karma-Gericht-Erinnerungen markieren
    final markierteErinnerungen = <ErinnerungModel>[];
    for (final erinnerung in ausgewaehlteErinnerungen) {
      final markiert = erinnerung.copyWith(istKarmaGericht: true);
      await _repository.erinnerungSpeichern(
          markiert, abgeschlossenerZyklus.id);
      markierteErinnerungen.add(markiert);
    }

    // ── Schritt 3: Mitgenommene Gedanken bestimmen ───────────────────────────
    final mitgenommeneGedanken =
        _mitgenommeneGedankenBestimmen(alleGedanken);
    final losgelasseneGedanken = alleGedanken
        .where((g) => !mitgenommeneGedanken.contains(g))
        .toList();

    // Mitgenommene Gedanken im Speicher markieren
    for (final gedanke in mitgenommeneGedanken) {
      final markiert = gedanke.copyWith(wirdMitgenommen: true);
      await _repository.gedankeSpeichern(markiert);
    }

    // ── Schritt 4: Jenseits-Reich berechnen ──────────────────────────────────
    final finalesKarma = abgeschlossenerZyklus.karmaAmEnde;
    final zugewiesenesReich = finalesKarma.jenseitsReich;

    // ── Schritt 5: Narrativen Moment generieren ───────────────────────────────
    final narrativerMoment = _narrativenMomentGenerieren(
      zyklus: abgeschlossenerZyklus,
      ausgewaehlteErinnerungen: markierteErinnerungen,
      mitgenommeneGedanken: mitgenommeneGedanken,
      reich: zugewiesenesReich,
      karma: finalesKarma,
    );

    // ── Abschluss: Zyklus als abgeschlossen markieren ────────────────────────
    // (Das Persistieren des Zyklus obliegt dem aufrufenden Provider/UseCase)

    return KarmaGerichtErgebnis(
      zugewiesenesReich: zugewiesenesReich,
      ausgewaehlteErinnerungen: markierteErinnerungen,
      mitgenommeneGedanken: mitgenommeneGedanken,
      losgelasseneGedanken: losgelasseneGedanken,
      narrativerMoment: narrativerMoment,
      finalesKarma: finalesKarma,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Private Hilfsmethoden
  // ───────────────────────────────────────────────────────────────────────────

  /// Filtert Erinnerungen nach dem Intensitätsschwellenwert.
  /// Nur emotional bedeutsame Erinnerungen kommen ins Karma-Gericht.
  List<ErinnerungModel> _relevanteErinnerungenFiltern(
      List<ErinnerungModel> alle) {
    return alle
        .where((e) =>
            e.emotionaleIntensitaet >= _erinnerungsIntensitaetsSchwelle)
        .toList();
  }

  /// Wählt 1–3 prägende Erinnerungen für das Karma-Gericht aus.
  ///
  /// Auswahlkriterien (kein Gut/Schlecht-Urteil):
  /// - Offene, unerledigte Erinnerungen werden bevorzugt
  /// - Sehr hohe Intensität = höhere Priorität
  /// - Bei Gleichstand entscheidet das Alter (jüngere werden bevorzugt)
  List<ErinnerungModel> _praegendeErinnerungenAuswaehlen(
      List<ErinnerungModel> relevant) {
    if (relevant.isEmpty) return [];

    // Sortierungsfunktion: offene Erinnerungen zuerst, dann nach Intensität
    final sortiert = List<ErinnerungModel>.from(relevant)
      ..sort((a, b) {
        // Offene Erinnerungen vor abgeschlossenen
        final offenA = !a.istMitgenommen ? 1 : 0;
        final offenB = !b.istMitgenommen ? 1 : 0;
        if (offenA != offenB) return offenB.compareTo(offenA);

        // Bei Gleichstand: höhere Intensität zuerst
        return b.emotionaleIntensitaet.compareTo(a.emotionaleIntensitaet);
      });

    // Maximal 3 Erinnerungen auswählen
    return sortiert.take(_maxAusgewaehlteErinnerungen).toList();
  }

  /// Bestimmt, welche Gedanken ins nächste Leben mitgetragen werden.
  ///
  /// Auswahlkriterien:
  /// - Gedanken mit hoher Intensität werden bevorzugt
  /// - Nicht abgeschlossene (offene) Gedanken werden bevorzugt
  /// - Traumata und toxische Gedanken werden mitgenommen, um aufgelöst zu werden
  List<GedankeModel> _mitgenommeneGedankenBestimmen(
      List<GedankeModel> alle) {
    if (alle.isEmpty) return [];

    // Gedanken nach Mitnahme-Priorität sortieren
    final sortiert = List<GedankeModel>.from(alle)
      ..sort((a, b) {
        // Bereits als mitgenommen markierte Gedanken bevorzugen
        if (a.wirdMitgenommen != b.wirdMitgenommen) {
          return a.wirdMitgenommen ? -1 : 1;
        }
        // Offene (nicht abgeschlossene) Gedanken bevorzugen
        if (a.istAbgeschlossen != b.istAbgeschlossen) {
          return a.istAbgeschlossen ? 1 : -1;
        }
        // Traumata und toxische Gedanken bevorzugen (müssen aufgelöst werden)
        final aIstWichtig =
            (a.typ == GedankenTyp.trauma || a.istGiftig) ? 1 : 0;
        final bIstWichtig =
            (b.typ == GedankenTyp.trauma || b.istGiftig) ? 1 : 0;
        if (aIstWichtig != bIstWichtig) {
          return bIstWichtig.compareTo(aIstWichtig);
        }
        // Höhere Intensität bevorzugen
        return b.intensitaet.compareTo(a.intensitaet);
      });

    return sortiert.take(_maxMitgenommeneGedanken).toList();
  }

  /// Generiert einen narrativen Beschreibungstext für das Karma-Gericht.
  ///
  /// Der Text passt sich an das Jenseitsreich und die ausgewählten
  /// Erinnerungen an und erschafft einen atmosphärischen Übergangsmoment.
  String _narrativenMomentGenerieren({
    required ZyklusModel zyklus,
    required List<ErinnerungModel> ausgewaehlteErinnerungen,
    required List<GedankeModel> mitgenommeneGedanken,
    required JenseitsReich reich,
    required KarmaProfilModel karma,
  }) {
    // Zeitalter-spezifische Einleitung
    final zeitalterText = zyklus.zeitalter.zeitgeist.split('.').first;

    // Erinnerungstexte zusammenstellen
    final erinnerungsBeschreibung = ausgewaehlteErinnerungen.isEmpty
        ? 'Keine prägenden Momente hinterlassen.'
        : ausgewaehlteErinnerungen
            .map((e) => '"${e.titel}"')
            .join(', ');

    // Jenseitsreich-spezifischer Schluss
    final reichText = switch (reich) {
      JenseitsReich.elysium =>
        'Die Seele leuchtet hell – das Elysium öffnet seine Tore.',
      JenseitsReich.harmonia =>
        'Ein Lächeln liegt auf dem Gesicht – Harmonia wartet.',
      JenseitsReich.limbus =>
        'Im Grau des Zwischenreichs wartet die nächste Inkarnation.',
      JenseitsReich.shadowlands =>
        'Schatten umhüllen die Seele – die Shadowlands fordern Buße.',
      JenseitsReich.abyssus =>
        'Tiefe Dunkelheit – der Abyssus verschlingt, was nicht aufgelöst wurde.',
    };

    return 'In einer Welt, die von "${zeitalterText.trim()}" geprägt war, '
        'endete dieses Leben im Alter von ${zyklus.sterbealter} Jahren.\n\n'
        'Das kosmische Gericht wählt: $erinnerungsBeschreibung\n\n'
        '$reichText\n\n'
        'Karma-Durchschnitt: ${karma.durchschnitt.toStringAsFixed(1)}';
  }
}
