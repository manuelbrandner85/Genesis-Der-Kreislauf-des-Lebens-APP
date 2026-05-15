/// Formatierungsfunktionen für GENESIS: Der Kreislauf des Lebens.
///
/// Diese Datei enthält alle reinen Formatierungsfunktionen, die Rohdaten
/// in lesbare, spielkontext-gerechte Strings umwandeln. Alle Funktionen
/// sind pure (keine Seiteneffekte) und können überall im Spiel verwendet werden.
library formattierer;

import '../constants/karma_konstanten.dart';
import '../constants/zeitalter_konstanten.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// KARMA-FORMATIERUNG
// ═══════════════════════════════════════════════════════════════════════════════

/// Formatiert einen Karma-Wert als vorzeichenbehafteten String.
///
/// Positive Werte erhalten ein `+`-Zeichen. Negative behalten ihr `-`.
/// Dezimalstellen werden abgeschnitten (ganzzahlige Ausgabe).
///
/// Beispiele:
/// ```dart
/// karmaWertFormatieren(75.4)   // → "+75"
/// karmaWertFormatieren(-23.0)  // → "-23"
/// karmaWertFormatieren(0.0)    // → "+0"
/// ```
String karmaWertFormatieren(double wert) {
  final gerundet = wert.round();
  return gerundet >= 0 ? '+$gerundet' : '$gerundet';
}

/// Formatiert einen Karma-Wert mit einer optionalen Einheit.
///
/// Beispiele:
/// ```dart
/// karmaWertMitEinheitFormatieren(42.0)   // → "+42 Karma"
/// karmaWertMitEinheitFormatieren(-15.5)  // → "-16 Karma"
/// ```
String karmaWertMitEinheitFormatieren(double wert) =>
    '${karmaWertFormatieren(wert)} Karma';

/// Gibt eine beschreibende Kategorie für einen Karma-Wert zurück.
///
/// Beispiele:
/// - `85.0`  → `"Heilig"`
/// - `50.0`  → `"Tugendhaft"`
/// - `15.0`  → `"Wohlwollend"`
/// - `0.0`   → `"Ausgeglichen"`
/// - `-15.0` → `"Zweifelhaft"`
/// - `-50.0` → `"Verdorben"`
/// - `-85.0` → `"Böse"`
String karmaKategorieFormatieren(double wert) {
  if (wert >= 80.0) return 'Heilig';
  if (wert >= 50.0) return 'Tugendhaft';
  if (wert >= 20.0) return 'Wohlwollend';
  if (wert >= -19.9) return 'Ausgeglichen';
  if (wert >= -49.9) return 'Zweifelhaft';
  if (wert >= -79.9) return 'Verdorben';
  return 'Böse';
}

/// Formatiert einen Karma-Änderungswert mit Präfix und Kontext.
///
/// Beispiele:
/// ```dart
/// karmaAenderungFormatieren(10.0, 'Mitgefühl')   // → "+10 Mitgefühl"
/// karmaAenderungFormatieren(-5.0, 'Ehrlichkeit') // → "-5 Ehrlichkeit"
/// ```
String karmaAenderungFormatieren(double aenderung, String dimensionsName) =>
    '${karmaWertFormatieren(aenderung)} $dimensionsName';

// ═══════════════════════════════════════════════════════════════════════════════
// ALTER-FORMATIERUNG
// ═══════════════════════════════════════════════════════════════════════════════

/// Formatiert ein Alter in Jahren als lesbaren deutschen String.
///
/// Berücksichtigt korrekte Singular/Plural-Formen.
///
/// Beispiele:
/// ```dart
/// alterFormatieren(0)   // → "Neugeboren"
/// alterFormatieren(1)   // → "1 Jahr"
/// alterFormatieren(7)   // → "7 Jahre"
/// alterFormatieren(42)  // → "42 Jahre"
/// alterFormatieren(100) // → "100 Jahre"
/// ```
String alterFormatieren(int alter) {
  if (alter <= 0) return 'Neugeboren';
  if (alter == 1) return '1 Jahr';
  return '$alter Jahre';
}

/// Formatiert ein Alter mit Lebensphasen-Bezeichnung.
///
/// Beispiele:
/// ```dart
/// alterMitPhaseFormatieren(8)  // → "8 Jahre (Kindheit)"
/// alterMitPhaseFormatieren(25) // → "25 Jahre (Aufbruch)"
/// ```
String alterMitPhaseFormatieren(int alter) {
  final basis = alterFormatieren(alter);
  final phase = _phaseNameFuerAlter(alter);
  if (phase.isEmpty) return basis;
  return '$basis ($phase)';
}

/// Interne Hilfsfunktion: gibt den Phasennamen für ein Alter zurück.
String _phaseNameFuerAlter(int alter) {
  if (alter == 0) return 'Geburt';
  if (alter <= 12) return 'Kindheit';
  if (alter <= 17) return 'Jugend';
  if (alter <= 25) return 'Aufbruch';
  if (alter <= 45) return 'Blüte';
  if (alter <= 55) return 'Prüfung';
  if (alter <= 70) return 'Weisheit';
  if (alter <= 85) return 'Vermächtnis';
  return 'Letzte Jahre';
}

// ═══════════════════════════════════════════════════════════════════════════════
// ZEITALTER-DATUM-FORMATIERUNG
// ═══════════════════════════════════════════════════════════════════════════════

/// Formatiert ein Spieljahr für das angegebene [zeitalter] als lesbaren String.
///
/// Passt den Datumsformat-Stil dem historischen Kontext des Zeitalters an.
///
/// Beispiele:
/// ```dart
/// zeitalterDatumFormatieren(1347, Zeitalter.mittelalter)
///   // → "Anno Domini 1347"
///
/// zeitalterDatumFormatieren(1487, Zeitalter.renaissance)
///   // → "Anno Domini 1487"
///
/// zeitalterDatumFormatieren(1879, Zeitalter.industriezeitalter)
///   // → "Im Jahre 1879 n. Chr."
///
/// zeitalterDatumFormatieren(2041, Zeitalter.moderne)
///   // → "2041 n. Chr."
///
/// zeitalterDatumFormatieren(2089, Zeitalter.zukunft)
///   // → "Systemzyklus 2089"
/// ```
String zeitalterDatumFormatieren(int jahr, Zeitalter zeitalter) {
  if (jahr <= 0) {
    final absolutJahr = jahr.abs();
    return 'Anno $absolutJahr v. Chr.';
  }

  switch (zeitalter) {
    case Zeitalter.mittelalter:
      return 'Anno Domini $jahr';
    case Zeitalter.renaissance:
      return 'Anno Domini $jahr';
    case Zeitalter.industriezeitalter:
      return 'Im Jahre $jahr n. Chr.';
    case Zeitalter.moderne:
      return '$jahr n. Chr.';
    case Zeitalter.zukunft:
      return 'Systemzyklus $jahr';
  }
}

/// Formatiert einen Zeitraum als Bereich (von–bis) für das [zeitalter].
///
/// Beispiel:
/// ```dart
/// zeitalterZeitraumFormatieren(1350, 1410, Zeitalter.mittelalter)
///   // → "Anno Domini 1350 – 1410"
/// ```
String zeitalterZeitraumFormatieren(
  int startJahr,
  int endJahr,
  Zeitalter zeitalter,
) {
  final start = zeitalterDatumFormatieren(startJahr, zeitalter);
  final endBasis = zeitalterDatumFormatieren(endJahr, zeitalter);

  // Für kompaktere Darstellung nur Jahreszahl am Ende
  return '$start – $endJahr';
}

// ═══════════════════════════════════════════════════════════════════════════════
// GEDANKEN-TEXT-FORMATIERUNG
// ═══════════════════════════════════════════════════════════════════════════════

/// Kürzt einen Gedanken-Text auf maximal [maxLaenge] Zeichen.
///
/// Bei Kürzung wird an einer Wortgrenze abgeschnitten und `"..."` angehängt.
/// Der ursprüngliche Text wird nicht verändert, wenn er kürzer ist.
///
/// Beispiele:
/// ```dart
/// gedankenTextKuerzen("Ich frage mich, ob das Leben einen Sinn hat.", 25)
///   // → "Ich frage mich, ob das..."
///
/// gedankenTextKuerzen("Kurz.", 100)
///   // → "Kurz."
/// ```
String gedankenTextKuerzen(String text, int maxLaenge) {
  if (maxLaenge <= 0) return '...';
  final bereinigt = text.trim();
  if (bereinigt.length <= maxLaenge) return bereinigt;

  // Abschneiden an Wortgrenze
  final kandidat = bereinigt.substring(0, maxLaenge);
  final letzterLeerzeichen = kandidat.lastIndexOf(' ');

  if (letzterLeerzeichen <= 0) {
    // Kein Leerzeichen gefunden – hartes Abschneiden
    return '${bereinigt.substring(0, maxLaenge.clamp(3, maxLaenge) - 3)}...';
  }

  return '${kandidat.substring(0, letzterLeerzeichen)}...';
}

/// Formatiert einen Gedanken-Text als Zitat mit Anführungszeichen.
///
/// Beispiel:
/// ```dart
/// gedankenAlsZitat("Warum bin ich hier?") // → "»Warum bin ich hier?«"
/// ```
String gedankenAlsZitat(String text) =>
    '»${text.trim()}«';

/// Gibt den ersten Satz eines Gedanken-Textes zurück.
///
/// Trennt am ersten Punkt, Ausrufezeichen oder Fragezeichen.
/// Gibt den gesamten Text zurück, wenn kein Satzende gefunden.
String gedankenErsterSatz(String text) {
  final bereinigt = text.trim();
  final match = RegExp(r'[.!?]').firstMatch(bereinigt);
  if (match == null) return bereinigt;
  return bereinigt.substring(0, match.end).trim();
}

// ═══════════════════════════════════════════════════════════════════════════════
// BEZIEHUNGS-FORMATIERUNG
// ═══════════════════════════════════════════════════════════════════════════════

/// Konvertiert eine Beziehungsstärke in eine lesbare Beschreibung.
///
/// [staerke] ist ein normierter Wert zwischen -1.0 (tiefe Feindschaft)
/// und +1.0 (tiefe Vertrautheit). 0.0 bedeutet Neutralität.
///
/// Stufenweite Beschreibungen:
/// - `>= 0.80` → `"Seelenverbunden"`
/// - `>= 0.60` → `"Enge Vertrauensperson"`
/// - `>= 0.40` → `"Enger Freund / Enge Freundin"`
/// - `>= 0.20` → `"Guter Bekannter / Gute Bekannte"`
/// - `>= 0.05` → `"Flüchtiger Bekannter"`
/// - `>= -0.05`→ `"Neutrale Beziehung"`
/// - `>= -0.20`→ `"Gespannte Beziehung"`
/// - `>= -0.40`→ `"Rivale / Rivalin"`
/// - `>= -0.60`→ `"Feind / Feindin"`
/// - `< -0.60` → `"Erzfeind / Erzfeindin"`
String beziehungsStaerkeZuText(double staerke) {
  final begrenzt = staerke.clamp(-1.0, 1.0);

  if (begrenzt >= 0.80) return 'Seelenverbunden';
  if (begrenzt >= 0.60) return 'Enge Vertrauensperson';
  if (begrenzt >= 0.40) return 'Enger Freund / Enge Freundin';
  if (begrenzt >= 0.20) return 'Guter Bekannter / Gute Bekannte';
  if (begrenzt >= 0.05) return 'Flüchtiger Bekannter';
  if (begrenzt >= -0.04) return 'Neutrale Beziehung';
  if (begrenzt >= -0.20) return 'Gespannte Beziehung';
  if (begrenzt >= -0.40) return 'Rivale / Rivalin';
  if (begrenzt >= -0.60) return 'Feind / Feindin';
  return 'Erzfeind / Erzfeindin';
}

/// Gibt ein einzelnes, kompaktes Etikett für die Beziehungsstärke zurück.
///
/// Beispiele:
/// - `0.9`  → `"Seelenverwandt"`
/// - `0.5`  → `"Freund"`
/// - `0.0`  → `"Neutral"`
/// - `-0.5` → `"Feind"`
/// - `-0.9` → `"Erzfeind"`
String beziehungsEtikett(double staerke) {
  final begrenzt = staerke.clamp(-1.0, 1.0);
  if (begrenzt >= 0.75) return 'Seelenverwandt';
  if (begrenzt >= 0.35) return 'Freund';
  if (begrenzt >= -0.10) return 'Neutral';
  if (begrenzt >= -0.50) return 'Rivale';
  return 'Erzfeind';
}

/// Formatiert den Beziehungsfortschritt als Prozent-String.
///
/// [staerke] zwischen -1.0 und +1.0 → normiert auf 0–100 %.
/// Beispiel: `0.5` → `"75%"` (da Mitte bei 50 %)
String beziehungsFortschritt(double staerke) {
  final normiert = ((staerke.clamp(-1.0, 1.0) + 1.0) / 2.0 * 100).round();
  return '$normiert%';
}

// ═══════════════════════════════════════════════════════════════════════════════
// VERMÖGENS-FORMATIERUNG
// ═══════════════════════════════════════════════════════════════════════════════

/// Formatiert ein Vermögen in Spielwährung als lesbaren String.
///
/// Ab 1.000 werden Punkte als Tausender-Trenner eingefügt.
/// Die Währungsbezeichnung passt sich dem [zeitalter] an.
///
/// Beispiele:
/// ```dart
/// vermoegensFormatieren(50, Zeitalter.mittelalter)        // → "50 Münzen"
/// vermoegensFormatieren(1500, Zeitalter.renaissance)      // → "1.500 Dukaten"
/// vermoegensFormatieren(25000, Zeitalter.industriezeitalter) // → "25.000 Mark"
/// vermoegensFormatieren(100000, Zeitalter.moderne)        // → "100.000 €"
/// vermoegensFormatieren(5000000, Zeitalter.zukunft)       // → "5.000.000 Credits"
/// ```
String vermoegensFormatieren(int betrag, Zeitalter zeitalter) {
  final formatiert = _zahlMitTrennzeichen(betrag);
  final waehrung = _waehrungFuerZeitalter(zeitalter);
  return '$formatiert $waehrung';
}

/// Interne Hilfsfunktion: formatiert eine Zahl mit Tausender-Trennpunkten.
String _zahlMitTrennzeichen(int zahl) {
  final str = zahl.abs().toString();
  final buffer = StringBuffer();
  int zaehler = 0;

  for (int i = str.length - 1; i >= 0; i--) {
    if (zaehler > 0 && zaehler % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
    zaehler++;
  }

  final ergebnis = buffer.toString().split('').reversed.join();
  return zahl < 0 ? '-$ergebnis' : ergebnis;
}

/// Interne Hilfsfunktion: gibt die Währungsbezeichnung für ein Zeitalter zurück.
String _waehrungFuerZeitalter(Zeitalter zeitalter) {
  switch (zeitalter) {
    case Zeitalter.mittelalter:
      return 'Münzen';
    case Zeitalter.renaissance:
      return 'Dukaten';
    case Zeitalter.industriezeitalter:
      return 'Mark';
    case Zeitalter.moderne:
      return '€';
    case Zeitalter.zukunft:
      return 'Credits';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// KARMA-DIMENSIONS-FORMATIERUNG
// ═══════════════════════════════════════════════════════════════════════════════

/// Gibt die polarisierte Beschreibung einer Karma-Dimension für einen Wert zurück.
///
/// Positive Werte → positive Pol-Beschreibung, negative → negative.
///
/// Beispiel:
/// ```dart
/// dimensionsPolFormatieren(KarmaDimension.mitgefuehl, 50.0)
///   // → "Empathie & Fürsorge"
/// dimensionsPolFormatieren(KarmaDimension.mitgefuehl, -30.0)
///   // → "Grausamkeit & Kälte"
/// ```
String dimensionsPolFormatieren(KarmaDimension dimension, double wert) =>
    dimension.polBeschreibung(wert);

/// Gibt ein vollständiges Karma-Profil-Label zurück.
///
/// Beispiel: `"Mitgefühl: +65 (Empathie & Fürsorge)"`
String dimensionsLabelFormatieren(KarmaDimension dimension, double wert) {
  final wertStr = karmaWertFormatieren(wert);
  final pol = dimensionsPolFormatieren(dimension, wert);
  return '${dimension.anzeigeName}: $wertStr ($pol)';
}

// ═══════════════════════════════════════════════════════════════════════════════
// JENSEITS-REICH-FORMATIERUNG
// ═══════════════════════════════════════════════════════════════════════════════

/// Formatiert den Wiedergeburts-Bonus eines Jenseits-Reiches als lesbaren String.
///
/// Beispiele:
/// ```dart
/// wiedergeburtsBonusFormatieren(25.0)   // → "+25 Karma-Bonus"
/// wiedergeburtsBonusFormatieren(-10.0)  // → "-10 Karma-Malus"
/// wiedergeburtsBonusFormatieren(0.0)    // → "Kein Karma-Bonus"
/// ```
String wiedergeburtsBonusFormatieren(double bonus) {
  if (bonus == 0.0) return 'Kein Karma-Bonus';
  final wertStr = karmaWertFormatieren(bonus);
  return '$wertStr ${bonus >= 0 ? "Karma-Bonus" : "Karma-Malus"}';
}

/// Gibt eine kurze Zusammenfassung des Jenseits-Reiches zurück.
///
/// Beispiel:
/// ```dart
/// jenseitsReichSummaryFormatieren(JenseitsReich.elysium, 85.0)
///   // → "Elysium • Ø +85 • +25 Karma-Bonus"
/// ```
String jenseitsReichSummaryFormatieren(
    JenseitsReich reich, double durchschnitt) {
  final durchschnittStr = karmaWertFormatieren(durchschnitt);
  final bonusStr = wiedergeburtsBonusFormatieren(reich.wiedergeburtsBonus);
  return '${reich.anzeigeName} • Ø $durchschnittStr • $bonusStr';
}

// ═══════════════════════════════════════════════════════════════════════════════
// SPIELZEIT-FORMATIERUNG
// ═══════════════════════════════════════════════════════════════════════════════

/// Formatiert eine Spielzeit-Dauer (in Minuten) als lesbaren String.
///
/// Beispiele:
/// ```dart
/// spielzeitFormatieren(45)   // → "45 Minuten"
/// spielzeitFormatieren(90)   // → "1 Stunde 30 Minuten"
/// spielzeitFormatieren(120)  // → "2 Stunden"
/// ```
String spielzeitFormatieren(int minuten) {
  if (minuten < 0) return 'Unbekannt';
  if (minuten == 0) return 'Weniger als 1 Minute';

  final stunden = minuten ~/ 60;
  final restMinuten = minuten % 60;

  if (stunden == 0) {
    return '$minuten ${minuten == 1 ? "Minute" : "Minuten"}';
  }
  if (restMinuten == 0) {
    return '$stunden ${stunden == 1 ? "Stunde" : "Stunden"}';
  }
  return '$stunden ${stunden == 1 ? "Stunde" : "Stunden"} '
      '$restMinuten ${restMinuten == 1 ? "Minute" : "Minuten"}';
}

/// Formatiert eine Anzahl von Lebenszyklen als lesbaren String.
///
/// Beispiele:
/// ```dart
/// zyklenFormatieren(1)   // → "1 Leben"
/// zyklenFormatieren(5)   // → "5 Leben"
/// zyklenFormatieren(10)  // → "10 Leben"
/// ```
String zyklenFormatieren(int anzahl) =>
    '$anzahl ${anzahl == 1 ? "Leben" : "Leben"}'; // Plural gleich Singular auf Deutsch

/// Formatiert eine Prozentzahl als lesbaren String mit %-Zeichen.
///
/// Beispiele:
/// ```dart
/// prozentFormatieren(0.75)   // → "75%"
/// prozentFormatieren(1.0)    // → "100%"
/// prozentFormatieren(0.333)  // → "33%"
/// ```
String prozentFormatieren(double wert, {int stellen = 0}) {
  final prozent = (wert * 100).clamp(0.0, 100.0);
  if (stellen == 0) return '${prozent.round()}%';
  return '${prozent.toStringAsFixed(stellen)}%';
}
