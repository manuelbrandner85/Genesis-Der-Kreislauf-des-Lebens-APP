/// Zeitalter-Konstanten für GENESIS: Der Kreislauf des Lebens.
///
/// Diese Datei definiert alle historischen Zeitalter, in denen das Spiel
/// stattfinden kann. Jedes Zeitalter besitzt eigene Karrierepfade,
/// sozialen Aufstiegschancen und einen charakteristischen Zeitgeist.
library zeitalter_konstanten;

// ═══════════════════════════════════════════════════════════════════════════════
// ZEITALTER (ENUM)
// ═══════════════════════════════════════════════════════════════════════════════

/// Die fünf spielbaren Zeitalter in GENESIS.
///
/// Die Zeitalter bestimmen die Kulisse, verfügbare Karrierepfade, gesellschaft-
/// liche Strukturen und den Schwierigkeitsgrad des sozialen Aufstiegs.
/// Sie werden zufällig oder durch besondere Karma-Ereignisse zugewiesen.
enum Zeitalter {
  // ── Mittelalter ─────────────────────────────────────────────────────────────
  /// Epoche der Ritter, Klöster und feudalen Hierarchien.
  /// Strenge Standesordnung, religiöse Dominanz, begrenzte soziale Mobilität.
  mittelalter(
    anzeigeName: 'Das Mittelalter',
    zeitraum: '500–1400 n. Chr.',
    zeitgeist:
        'Gott, Kirche und Schwert bestimmen das Schicksal. Ehre und '
        'Pflicht stehen über dem Einzelnen. Die Welt ist rau, aber '
        'reich an Legenden und tiefer Gemeinschaft.',
    verfuegbareKarrieren: [
      'Ritter',
      'Kleriker / Mönch',
      'Händler',
      'Bauer',
      'Schmied / Handwerker',
      'Bard / Troubadour',
      'Heilerin / Kräuterfrau',
      'Adliger',
      'Söldner',
      'Schreiber / Gelehrter',
    ],
    sozialeAufstiegsChance: 0.15,
    startvermoegen: 50,
    bildungszugang: 0.20,
    religioeserEinfluss: 0.90,
    technologischerStand: 0.10,
    hintergrundBild: 'assets/images/zeitalter/mittelalter_bg.jpg',
    musikThema: 'assets/audio/musik/mittelalter_ambient.mp3',
  ),

  // ── Renaissance ─────────────────────────────────────────────────────────────
  /// Epoche des Humanismus, der Kunst und des Aufblühens der Wissenschaften.
  /// Wissen wird neu bewertet, Individualität gewinnt an Bedeutung.
  renaissance(
    anzeigeName: 'Die Renaissance',
    zeitraum: '1400–1600 n. Chr.',
    zeitgeist:
        'Der Mensch rückt in den Mittelpunkt. Kunst, Wissenschaft und '
        'Philosophie erblühen. Entdeckungsreisen eröffnen neue Welten – '
        'und neue Möglichkeiten für Aufstieg und Fall.',
    verfuegbareKarrieren: [
      'Künstler / Maler',
      'Gelehrter / Humanist',
      'Kaufmann / Bankier',
      'Seefahrer / Entdecker',
      'Architekt',
      'Alchemist',
      'Diplomat',
      'Drucker / Verleger',
      'Adliger',
      'Arzt / Chirurg',
    ],
    sozialeAufstiegsChance: 0.28,
    startvermoegen: 120,
    bildungszugang: 0.45,
    religioeserEinfluss: 0.60,
    technologischerStand: 0.30,
    hintergrundBild: 'assets/images/zeitalter/renaissance_bg.jpg',
    musikThema: 'assets/audio/musik/renaissance_ambient.mp3',
  ),

  // ── Industriezeitalter ──────────────────────────────────────────────────────
  /// Epoche der Dampfmaschinen, Fabriken und sozialen Umbrüche.
  /// Kapitalismus, Arbeiterbewegung und technischer Fortschritt prägen die Zeit.
  industriezeitalter(
    anzeigeName: 'Das Industriezeitalter',
    zeitraum: '1760–1900 n. Chr.',
    zeitgeist:
        'Dampf und Stahl verändern die Welt. Fabriken wachsen, Städte '
        'platzen aus allen Nähten. Wer clever und rücksichtslos genug ist, '
        'kann ein Imperium aufbauen – oder darin zerrieben werden.',
    verfuegbareKarrieren: [
      'Fabrikarbeiter',
      'Ingenieur / Erfinder',
      'Industrieller / Unternehmer',
      'Arzt',
      'Journalist / Schriftsteller',
      'Politiker / Aktivist',
      'Eisenbahner',
      'Bergmann',
      'Kaufmann / Händler',
      'Wissenschaftler',
    ],
    sozialeAufstiegsChance: 0.35,
    startvermoegen: 200,
    bildungszugang: 0.60,
    religioeserEinfluss: 0.35,
    technologischerStand: 0.55,
    hintergrundBild: 'assets/images/zeitalter/industriezeitalter_bg.jpg',
    musikThema: 'assets/audio/musik/industrie_ambient.mp3',
  ),

  // ── Moderne ─────────────────────────────────────────────────────────────────
  /// Die zeitgenössische Welt des 20./21. Jahrhunderts.
  /// Globalisierung, digitale Revolution, maximale persönliche Freiheit.
  moderne(
    anzeigeName: 'Die Moderne',
    zeitraum: '1900–2050 n. Chr.',
    zeitgeist:
        'Die Welt ist ein globales Dorf. Informationen fließen frei, '
        'Möglichkeiten sind grenzenlos – und die Ablenkungen ebenso. '
        'Wer bist du wirklich in einer Gesellschaft, die alles fordert?',
    verfuegbareKarrieren: [
      'Softwareentwickler / Programmierer',
      'Arzt / Therapeutin',
      'Lehrer / Bildungsforscherin',
      'Unternehmer / Startup-Gründer',
      'Künstler / Influencer',
      'Wissenschaftler / Forscher',
      'Journalist / Dokumentarfilmer',
      'Sozialarbeiter / NGO-Aktivist',
      'Manager / Führungskraft',
      'Handwerker / Meisterbetrieb',
    ],
    sozialeAufstiegsChance: 0.50,
    startvermoegen: 500,
    bildungszugang: 0.85,
    religioeserEinfluss: 0.15,
    technologischerStand: 0.80,
    hintergrundBild: 'assets/images/zeitalter/moderne_bg.jpg',
    musikThema: 'assets/audio/musik/moderne_ambient.mp3',
  ),

  // ── Zukunft ─────────────────────────────────────────────────────────────────
  /// Eine spekulativ-dystopische oder utopische Zukunftswelt.
  /// KI, Genetik und interplanetare Zivilisation stellen alte Werte infrage.
  zukunft(
    anzeigeName: 'Die Zukunft',
    zeitraum: '2050–2200 n. Chr.',
    zeitgeist:
        'Die Menschheit steht an einer Weggabelung. Unsterblichkeit, '
        'künstliche Bewusstseine und Terraforming sind Realität. '
        'Doch was bedeutet es noch, menschlich zu sein?',
    verfuegbareKarrieren: [
      'KI-Ethiker / Bewusstseins-Forscher',
      'Genmodifikations-Ingenieur',
      'Terraforming-Architektin',
      'Interplanetarer Händler',
      'Digitaler Schamane / Hacker',
      'Synthetik-Therapeut',
      'Kolonie-Gouverneur',
      'Augmentierungschirurgin',
      'Öko-Ingenieur / Klimaarchitekt',
      'Friedensbewahrer / Mediator',
    ],
    sozialeAufstiegsChance: 0.45,
    startvermoegen: 1000,
    bildungszugang: 0.95,
    religioeserEinfluss: 0.05,
    technologischerStand: 0.99,
    hintergrundBild: 'assets/images/zeitalter/zukunft_bg.jpg',
    musikThema: 'assets/audio/musik/zukunft_ambient.mp3',
  );

  // ── Konstruktor ────────────────────────────────────────────────────────────
  const Zeitalter({
    required this.anzeigeName,
    required this.zeitraum,
    required this.zeitgeist,
    required this.verfuegbareKarrieren,
    required this.sozialeAufstiegsChance,
    required this.startvermoegen,
    required this.bildungszugang,
    required this.religioeserEinfluss,
    required this.technologischerStand,
    required this.hintergrundBild,
    required this.musikThema,
  });

  // ── Felder ─────────────────────────────────────────────────────────────────

  /// Lesbarer Anzeige-Name des Zeitalters auf Deutsch.
  final String anzeigeName;

  /// Historischer Zeitraum als lesbarer String (z. B. "500–1400 n. Chr.").
  final String zeitraum;

  /// Atmosphärische Beschreibung des Zeitgeistes (3–4 Sätze für Ladebildschirm).
  final String zeitgeist;

  /// Liste aller in diesem Zeitalter verfügbaren Karrierepfade.
  final List<String> verfuegbareKarrieren;

  /// Wahrscheinlichkeit (0.0–1.0) eines erfolgreichen sozialen Aufstiegs.
  /// Höhere Werte = mobilere Gesellschaft.
  final double sozialeAufstiegsChance;

  /// Startvermögen in Spielwährung zu Beginn eines Lebens in diesem Zeitalter.
  final int startvermoegen;

  /// Zugang zu formaler Bildung (0.0 = kein Zugang, 1.0 = universell verfügbar).
  final double bildungszugang;

  /// Stärke des religiösen / spirituellen Einflusses auf das Alltagsleben.
  final double religioeserEinfluss;

  /// Allgemeines Technologie-Niveau (0.0 = primitiv, 1.0 = hochentwickelt).
  final double technologischerStand;

  /// Pfad zum Hintergrundbild dieses Zeitalters.
  final String hintergrundBild;

  /// Pfad zum Ambient-Musik-Thema dieses Zeitalters.
  final String musikThema;

  // ── Hilfsmethoden ──────────────────────────────────────────────────────────

  /// Gibt eine zufällige Karriere aus den verfügbaren Karrierepfaden zurück.
  /// Benötigt einen [zufall]-Wert zwischen 0 und [verfuegbareKarrieren.length - 1].
  String zufaelligeKarriere(int zufallsIndex) {
    if (verfuegbareKarrieren.isEmpty) return 'Unbekannt';
    return verfuegbareKarrieren[
        zufallsIndex.clamp(0, verfuegbareKarrieren.length - 1)];
  }

  /// Gibt zurück, ob in diesem Zeitalter Bildung leicht zugänglich ist.
  bool get hatGuteBildungschancen => bildungszugang >= 0.6;

  /// Gibt zurück, ob Religion eine prägende Kraft in diesem Zeitalter ist.
  bool get istReligioesPraegend => religioeserEinfluss >= 0.5;

  /// Beschreibung der sozialen Mobilität für UI-Anzeige.
  String get mobilitaetsBeschreibung {
    if (sozialeAufstiegsChance >= 0.45) return 'Hohe soziale Mobilität';
    if (sozialeAufstiegsChance >= 0.25) return 'Mittlere soziale Mobilität';
    return 'Strenge Ständegesellschaft';
  }

  /// Findet ein Zeitalter anhand seines Anzeige-Namens.
  /// Gibt [moderne] zurück, wenn kein Treffer gefunden.
  static Zeitalter vonName(String name) {
    return Zeitalter.values.firstWhere(
      (z) => z.anzeigeName.toLowerCase().contains(name.toLowerCase()),
      orElse: () => Zeitalter.moderne,
    );
  }

  /// Gibt alle Zeitalter in chronologischer Reihenfolge zurück.
  static List<Zeitalter> get chronologisch => [
        Zeitalter.mittelalter,
        Zeitalter.renaissance,
        Zeitalter.industriezeitalter,
        Zeitalter.moderne,
        Zeitalter.zukunft,
      ];
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOZIALE KLASSEN
// ═══════════════════════════════════════════════════════════════════════════════

/// Soziale Klassen, die in allen Zeitaltern existieren (unterschiedlich benannt).
///
/// Die Klasse bestimmt Startbedingungen, Zugang zu Karrierepfaden und
/// die Grundwahrscheinlichkeit für sozialen Auf- oder Abstieg.
enum SozialeKlasse {
  /// Unterste Schicht: Bettler, Leibeigene, Obdachlose.
  unterschicht(
    anzeigeName: 'Unterschicht',
    startVermoegenMultiplikator: 0.2,
    bildungsModifikator: -0.30,
    beschreibung: 'Das harte Leben von ganz unten.',
  ),

  /// Arbeitende Bevölkerung: Handwerker, Bauern, einfache Arbeiter.
  arbeiterklasse(
    anzeigeName: 'Arbeiterklasse',
    startVermoegenMultiplikator: 0.6,
    bildungsModifikator: -0.10,
    beschreibung: 'Fleißige Hände, knapper Lohn.',
  ),

  /// Kaufleute, Handwerksmeister, mittlere Beamte.
  mittelklasse(
    anzeigeName: 'Mittelklasse',
    startVermoegenMultiplikator: 1.0,
    bildungsModifikator: 0.0,
    beschreibung: 'Stabile Verhältnisse mit Aufstiegspotenzial.',
  ),

  /// Wohlhabende Kaufleute, hohe Beamte, freie Gelehrte.
  obereMittelklasse(
    anzeigeName: 'Obere Mittelklasse',
    startVermoegenMultiplikator: 2.0,
    bildungsModifikator: 0.20,
    beschreibung: 'Privilegien und Einfluss – mit Pflichten.',
  ),

  /// Adel, reiche Industrielle, hohe Geistlichkeit, Politikelite.
  oberschicht(
    anzeigeName: 'Oberschicht',
    startVermoegenMultiplikator: 5.0,
    bildungsModifikator: 0.40,
    beschreibung: 'Geburt ins Privileg – oder erkämpfter Aufstieg.',
  );

  // ── Konstruktor ────────────────────────────────────────────────────────────
  const SozialeKlasse({
    required this.anzeigeName,
    required this.startVermoegenMultiplikator,
    required this.bildungsModifikator,
    required this.beschreibung,
  });

  // ── Felder ─────────────────────────────────────────────────────────────────

  /// Lesbarer Anzeige-Name der sozialen Klasse.
  final String anzeigeName;

  /// Multiplikator auf das Zeitalter-Startvermögen (< 1.0 = weniger, > 1.0 = mehr).
  final double startVermoegenMultiplikator;

  /// Additiver Modifikator auf den Bildungszugang des Zeitalters.
  final double bildungsModifikator;

  /// Kurze beschreibende Zeile für UI.
  final String beschreibung;

  // ── Hilfsmethoden ──────────────────────────────────────────────────────────

  /// Effektiver Bildungszugang für diese Klasse in einem gegebenen [zeitalter].
  double effektiverBildungszugang(Zeitalter zeitalter) =>
      (zeitalter.bildungszugang + bildungsModifikator).clamp(0.0, 1.0);

  /// Effektives Startvermögen für diese Klasse in einem gegebenen [zeitalter].
  int effektivesStartvermoegen(Zeitalter zeitalter) =>
      (zeitalter.startvermoegen * startVermoegenMultiplikator).round();

  /// Gibt die nächsthöhere soziale Klasse zurück (oder [oberschicht] wenn bereits oben).
  SozialeKlasse get naechsteKlasse {
    final idx = SozialeKlasse.values.indexOf(this);
    if (idx >= SozialeKlasse.values.length - 1) return SozialeKlasse.oberschicht;
    return SozialeKlasse.values[idx + 1];
  }

  /// Gibt die nächstniedrigere soziale Klasse zurück (oder [unterschicht] wenn bereits unten).
  SozialeKlasse get vorherigeKlasse {
    final idx = SozialeKlasse.values.indexOf(this);
    if (idx <= 0) return SozialeKlasse.unterschicht;
    return SozialeKlasse.values[idx - 1];
  }
}
