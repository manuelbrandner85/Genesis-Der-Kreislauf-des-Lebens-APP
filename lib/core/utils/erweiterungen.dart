/// Dart-Erweiterungsmethoden für GENESIS: Der Kreislauf des Lebens.
///
/// Diese Datei enthält alle Extension-Methoden, die das Arbeiten mit
/// Standard-Dart-Typen im Spielkontext vereinfachen. Erweiterungen für
/// [double], [String], [List], [Duration] und [DateTime] sind enthalten.
library erweiterungen;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_konstanten.dart';
import '../constants/karma_konstanten.dart';
import '../constants/zeitalter_konstanten.dart';
import '../theme/app_farben.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ERWEITERUNGEN FÜR double
// ═══════════════════════════════════════════════════════════════════════════════

/// Nützliche Erweiterungen für [double]-Werte im Spielkontext.
extension DoubleSpielErweiterungen on double {
  // ── Karma-Hilfsmethoden ──────────────────────────────────────────────────

  /// Konvertiert einen Karma-Wert [-100, +100] in einen Prozentwert [0.0, 1.0].
  ///
  /// Dabei entspricht:
  /// - `-100.0` → `0.0` (vollständig negativ)
  /// - `0.0`   → `0.5` (neutral)
  /// - `+100.0` → `1.0` (vollständig positiv)
  double karmaZuProzent() =>
      ((this - kMinKarma) / (kMaxKarma - kMinKarma)).clamp(0.0, 1.0);

  /// Gibt `true` zurück, wenn dieser Karma-Wert positiv (> 0) ist.
  bool get istKarmaPositiv => this > kNeutralKarma;

  /// Gibt `true` zurück, wenn dieser Karma-Wert negativ (< 0) ist.
  bool get istKarmaNegativ => this < kNeutralKarma;

  /// Gibt `true` zurück, wenn dieser Karma-Wert neutral (== 0) ist.
  bool get istKarmaNeutral => this == kNeutralKarma;

  /// Gibt die passende Karma-Farbe aus [AppFarben] zurück.
  /// Positiv → grün, Neutral → gelb, Negativ → rot.
  Color zuKarmaFarbe() => AppFarben.fuerKarmaWert(this);

  /// Gibt die interpolierte Karma-Farbe als Farbverlauf zurück.
  /// [0.0] = rot, [0.5] = gelb, [1.0] = grün (normierter t-Wert).
  Color zuInterpolierterKarmaFarbe() =>
      AppFarben.karmaFarbeInterpoliert(karmaZuProzent());

  /// Begrenzt diesen Wert auf den gültigen Karma-Bereich [-100, +100].
  double karmaBegrenzt() => clamp(kMinKarma, kMaxKarma);

  // ── Allgemeine Hilfsmethoden ─────────────────────────────────────────────

  /// Gibt `true` zurück, wenn der Wert positiv (> 0) ist.
  bool get istPositiv => this > 0.0;

  /// Gibt `true` zurück, wenn der Wert negativ (< 0) ist.
  bool get istNegativ => this < 0.0;

  /// Gibt den Wert als formatierter Karma-String zurück (z. B. "+75" oder "-23").
  String zuKarmaString() => this >= 0
      ? '+${toStringAsFixed(0)}'
      : toStringAsFixed(0);

  /// Rundet auf [stellen] Dezimalstellen und gibt einen lesbaren String zurück.
  String zuAnzeige([int stellen = 1]) => toStringAsFixed(stellen);

  /// Normiert den Wert linear von [vonMin, vonMax] nach [zuMin, zuMax].
  double normieren({
    required double vonMin,
    required double vonMax,
    double zuMin = 0.0,
    double zuMax = 1.0,
  }) {
    if (vonMax == vonMin) return zuMin;
    final normiert = (this - vonMin) / (vonMax - vonMin);
    return (zuMin + normiert * (zuMax - zuMin)).clamp(zuMin, zuMax);
  }

  /// Gibt zurück, ob dieser Wert im geschlossenen Intervall [min, max] liegt.
  bool liegtIn(double min, double max) => this >= min && this <= max;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERWEITERUNGEN FÜR String
// ═══════════════════════════════════════════════════════════════════════════════

/// Nützliche Erweiterungen für [String]-Werte im Spielkontext.
extension StringSpielErweiterungen on String {
  // ── Spielkontext-Konvertierungen ─────────────────────────────────────────

  /// Konvertiert einen String zum passenden [GamePhase]-Enum-Wert.
  ///
  /// Vergleich ist case-insensitiv auf [GamePhase.anzeigeName].
  /// Gibt [GamePhase.geburt] zurück, wenn keine Übereinstimmung gefunden.
  GamePhase zuGamePhase() {
    final gesucht = toLowerCase().trim();
    return GamePhase.values.firstWhere(
      (phase) =>
          phase.anzeigeName.toLowerCase() == gesucht ||
          phase.name.toLowerCase() == gesucht,
      orElse: () => GamePhase.geburt,
    );
  }

  /// Konvertiert einen String zum passenden [Zeitalter]-Enum-Wert.
  /// Gibt [Zeitalter.moderne] zurück, wenn keine Übereinstimmung gefunden.
  Zeitalter zuZeitalter() {
    final gesucht = toLowerCase().trim();
    return Zeitalter.values.firstWhere(
      (z) =>
          z.anzeigeName.toLowerCase().contains(gesucht) ||
          z.name.toLowerCase() == gesucht,
      orElse: () => Zeitalter.moderne,
    );
  }

  // ── Text-Transformationen ────────────────────────────────────────────────

  /// Schreibt den ersten Buchstaben groß (Großschreibung).
  ///
  /// Beispiel: `"hallo welt".grossSchreiben()` → `"Hallo welt"`
  String grossSchreiben() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Schreibt jeden Wortanfang groß (Titelschreibung).
  ///
  /// Beispiel: `"hallo schöne welt".allesGrossSchreiben()` → `"Hallo Schöne Welt"`
  String allesGrossSchreiben() {
    if (isEmpty) return this;
    return split(' ')
        .map((wort) => wort.isEmpty ? wort : wort.grossSchreiben())
        .join(' ');
  }

  /// Bricht den Text nach [maxZeichen] Zeichen mit einem Zeilenumbruch um.
  ///
  /// Bricht an Wortgrenzen um, um zerrissene Wörter zu vermeiden.
  /// Wenn ein einzelnes Wort länger als [maxZeichen] ist, wird es trotzdem
  /// auf der nächsten Zeile gestartet.
  ///
  /// Beispiel: `"Hallo Welt".zeilenUmbruchBei(5)` → `"Hallo\nWelt"`
  String zeilenUmbruchBei(int maxZeichen) {
    if (length <= maxZeichen) return this;

    final woerter = split(' ');
    final buffer = StringBuffer();
    int zeilenLaenge = 0;

    for (int i = 0; i < woerter.length; i++) {
      final wort = woerter[i];
      final wortLaenge = wort.length;

      if (zeilenLaenge == 0) {
        // Erste Wort der Zeile
        buffer.write(wort);
        zeilenLaenge = wortLaenge;
      } else if (zeilenLaenge + 1 + wortLaenge <= maxZeichen) {
        // Passt noch in die aktuelle Zeile
        buffer.write(' $wort');
        zeilenLaenge += 1 + wortLaenge;
      } else {
        // Neue Zeile beginnen
        buffer.write('\n$wort');
        zeilenLaenge = wortLaenge;
      }
    }

    return buffer.toString();
  }

  /// Kürzt den Text auf [maxLaenge] Zeichen und fügt "..." an.
  /// Gibt den unveränderten String zurück, wenn er kürzer ist.
  String kuerzenAuf(int maxLaenge, {String suffix = '...'}) {
    if (length <= maxLaenge) return this;
    if (maxLaenge <= suffix.length) return suffix.substring(0, maxLaenge);
    return '${substring(0, maxLaenge - suffix.length)}$suffix';
  }

  /// Entfernt führende und nachfolgende Leerzeichen und normiert mehrfache
  /// Leerzeichen zwischen Wörtern zu einfachen Leerzeichen.
  String bereinigen() => trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Gibt `true` zurück, wenn der String leer oder nur aus Whitespace besteht.
  bool get istLeerOderLeerzeichen => trim().isEmpty;

  /// Gibt `true` zurück, wenn der String eine gültige Spieler-ID ist
  /// (UUID-Format, 36 Zeichen mit Bindestrichen).
  bool get istGueltigeSpielerId =>
      RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
              caseSensitive: false)
          .hasMatch(this);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERWEITERUNGEN FÜR List<T>
// ═══════════════════════════════════════════════════════════════════════════════

/// Nützliche Erweiterungen für [List]-Typen im Spielkontext.
extension ListSpielErweiterungen<T> on List<T> {
  // ── Zufälligkeits-Methoden ───────────────────────────────────────────────

  /// Gibt ein zufälliges Element aus dieser Liste zurück.
  ///
  /// Wirft [StateError], wenn die Liste leer ist.
  /// Für deterministische Tests kann ein [zufallsGenerator] übergeben werden.
  T zufaelligesElement([math.Random? zufallsGenerator]) {
    if (isEmpty) throw StateError('Kann kein zufälliges Element aus einer leeren Liste wählen.');
    final zufaellig = zufallsGenerator ?? math.Random();
    return this[zufaellig.nextInt(length)];
  }

  /// Gibt ein zufälliges Element zurück, oder [fallback] wenn die Liste leer ist.
  T zufaelligesElementOder(T fallback, [math.Random? zufallsGenerator]) {
    if (isEmpty) return fallback;
    final zufaellig = zufallsGenerator ?? math.Random();
    return this[zufaellig.nextInt(length)];
  }

  /// Gibt eine neue, zufällig gemischte Kopie dieser Liste zurück.
  /// Die ursprüngliche Liste wird nicht verändert.
  List<T> gemischt([math.Random? zufallsGenerator]) {
    final kopie = List<T>.from(this);
    final zufaellig = zufallsGenerator ?? math.Random();
    // Fisher-Yates-Algorithmus für faire Mischung
    for (int i = kopie.length - 1; i > 0; i--) {
      final j = zufaellig.nextInt(i + 1);
      final temp = kopie[i];
      kopie[i] = kopie[j];
      kopie[j] = temp;
    }
    return kopie;
  }

  // ── Listen-Hilfsmethoden ─────────────────────────────────────────────────

  /// Gibt die ersten [anzahl] Elemente zurück (ohne Fehler bei kürzerer Liste).
  List<T> ersteBis(int anzahl) =>
      length <= anzahl ? this : sublist(0, anzahl);

  /// Gibt die letzten [anzahl] Elemente zurück (ohne Fehler bei kürzerer Liste).
  List<T> letzteBis(int anzahl) =>
      length <= anzahl ? this : sublist(length - anzahl);

  /// Teilt die Liste in Gruppen der Größe [gruppenGroesse] auf.
  ///
  /// Beispiel: `[1,2,3,4,5].inGruppen(2)` → `[[1,2], [3,4], [5]]`
  List<List<T>> inGruppen(int gruppenGroesse) {
    if (gruppenGroesse <= 0) return [List<T>.from(this)];
    final ergebnis = <List<T>>[];
    for (int i = 0; i < length; i += gruppenGroesse) {
      ergebnis.add(sublist(i, (i + gruppenGroesse).clamp(0, length)));
    }
    return ergebnis;
  }

  /// Gibt ein zufälliges Teilliste mit [anzahl] Elementen zurück.
  List<T> zufaelligeAuswahl(int anzahl, [math.Random? zufallsGenerator]) {
    if (anzahl >= length) return List<T>.from(this);
    return gemischt(zufallsGenerator).ersteBis(anzahl);
  }

  /// Gibt `true` zurück, wenn [element] in der Liste ist (null-sicher).
  bool enthaelt(T element) => contains(element);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERWEITERUNGEN FÜR Duration
// ═══════════════════════════════════════════════════════════════════════════════

/// Nützliche Erweiterungen für [Duration]-Werte im Spielkontext.
extension DurationSpielErweiterungen on Duration {
  // ── Formatierungsmethoden ────────────────────────────────────────────────

  /// Formatiert die Duration als lesbare Spielzeit im Format "X Jahre Y Monate".
  ///
  /// Die Duration wird als gelebte Spielzeit interpretiert (1 Day ≈ 1 Monat).
  /// - `Duration(days: 36)` → `"3 Jahre"`
  /// - `Duration(days: 14)` → `"1 Jahr 2 Monate"`
  /// - `Duration(days: 8)`  → `"8 Monate"`
  String zuAnzeige() {
    final gesamtMonate = inDays; // 1 Spieltag ≈ 1 Monat
    final jahre = gesamtMonate ~/ 12;
    final monate = gesamtMonate % 12;

    if (jahre == 0 && monate == 0) return 'Weniger als 1 Monat';

    final teile = <String>[];
    if (jahre > 0) {
      teile.add('$jahre ${jahre == 1 ? "Jahr" : "Jahre"}');
    }
    if (monate > 0) {
      teile.add('$monate ${monate == 1 ? "Monat" : "Monate"}');
    }

    return teile.join(' ');
  }

  /// Gibt die Duration als `"X Stunden Y Minuten"` zurück (für echte Zeit).
  String zuEchtZeitAnzeige() {
    final stunden = inHours;
    final minuten = inMinutes.remainder(60);
    final sekunden = inSeconds.remainder(60);

    if (stunden > 0) {
      return '$stunden ${stunden == 1 ? "Stunde" : "Stunden"}'
          '${minuten > 0 ? " $minuten ${minuten == 1 ? "Minute" : "Minuten"}" : ""}';
    }
    if (minuten > 0) {
      return '$minuten ${minuten == 1 ? "Minute" : "Minuten"}'
          '${sekunden > 0 ? " $sekunden ${sekunden == 1 ? "Sekunde" : "Sekunden"}" : ""}';
    }
    return '$sekunden ${sekunden == 1 ? "Sekunde" : "Sekunden"}';
  }

  /// Gibt zurück, ob diese Duration kürzer als [andere] ist.
  bool istKuerzerAls(Duration andere) => this < andere;

  /// Gibt zurück, ob diese Duration länger als [andere] ist.
  bool istLaengerAls(Duration andere) => this > andere;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERWEITERUNGEN FÜR DateTime
// ═══════════════════════════════════════════════════════════════════════════════

/// Nützliche Erweiterungen für [DateTime]-Werte im Spielkontext.
extension DateTimeSpielErweiterungen on DateTime {
  // ── Zeitalter-spezifische Formatierung ───────────────────────────────────

  /// Formatiert dieses Datum als Spielzeit für das angegebene [zeitalter].
  ///
  /// Die Ausgabe passt sich dem Zeitgeist des Zeitalters an:
  /// - Mittelalter: `"Im Jahre des Herrn 1347"`
  /// - Renaissance: `"Anno Domini 1487"`
  /// - Industriezeitalter: `"Im Jahre 1879"`
  /// - Moderne: `"2043 n. Chr."`
  /// - Zukunft: `"Systemzeit 2089"`
  String zuSpielZeit(Zeitalter zeitalter) {
    switch (zeitalter) {
      case Zeitalter.mittelalter:
        return 'Im Jahre des Herrn $year';
      case Zeitalter.renaissance:
        return 'Anno Domini $year';
      case Zeitalter.industriezeitalter:
        return 'Im Jahre $year';
      case Zeitalter.moderne:
        return '$year n. Chr.';
      case Zeitalter.zukunft:
        return 'Systemzyklus $year';
    }
  }

  /// Gibt Monat und Jahr als lesbaren deutschen String zurück.
  /// Beispiel: `"März 1456"`
  String zuMonatJahr() {
    const monate = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return '${monate[month - 1]} $year';
  }

  /// Gibt das vollständige Datum auf Deutsch zurück.
  /// Beispiel: `"15. März 1456"`
  String zuVollemDatum() {
    const monate = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return '$day. ${monate[month - 1]} $year';
  }

  /// Gibt zurück, ob dieses Datum vor [andere] liegt.
  bool istVor(DateTime andere) => isBefore(andere);

  /// Gibt zurück, ob dieses Datum nach [andere] liegt.
  bool istNach(DateTime andere) => isAfter(andere);

  /// Berechnet das Alter in Jahren basierend auf dem aktuellen Datum.
  int alterInJahren() {
    final heute = DateTime.now();
    int alter = heute.year - year;
    if (heute.month < month ||
        (heute.month == month && heute.day < day)) {
      alter--;
    }
    return alter.clamp(0, 150);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERWEITERUNGEN FÜR int
// ═══════════════════════════════════════════════════════════════════════════════

/// Nützliche Erweiterungen für [int]-Werte im Spielkontext.
extension IntSpielErweiterungen on int {
  /// Gibt das Alter mit korrekter Einheit zurück.
  /// Beispiel: `1` → `"1 Jahr"`, `25` → `"25 Jahre"`
  String zuAlterString() =>
      this == 1 ? '1 Jahr' : '$this Jahre';

  /// Gibt den Wert als formatierten Geldbetrag zurück (mit Tausender-Trennzeichen).
  /// Beispiel: `1500` → `"1.500"`, `1000000` → `"1.000.000"`
  String zuGeldBetrag() {
    final str = abs().toString();
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
    return this < 0 ? '-$ergebnis' : ergebnis;
  }

  /// Gibt `true` zurück, wenn dieser Wert eine gültige Phasennummer (1–9) ist.
  bool get istGueltigePhaseNummer => this >= 1 && this <= 9;

  /// Gibt `true` zurück, wenn dieser Wert ein gültiges Spielalter (0–120) ist.
  bool get istGueltigesSpielAlter => this >= 0 && this <= 120;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERWEITERUNGEN FÜR Color
// ═══════════════════════════════════════════════════════════════════════════════

/// Nützliche Erweiterungen für [Color]-Werte im Spielkontext.
extension ColorSpielErweiterungen on Color {
  /// Gibt eine hellere Version dieser Farbe zurück.
  /// [faktor] zwischen 0.0 (unverändert) und 1.0 (weiß).
  Color aufgehellt(double faktor) {
    final begrenzt = faktor.clamp(0.0, 1.0);
    return Color.lerp(this, Colors.white, begrenzt) ?? this;
  }

  /// Gibt eine dunklere Version dieser Farbe zurück.
  /// [faktor] zwischen 0.0 (unverändert) und 1.0 (schwarz).
  Color abgedunkelt(double faktor) {
    final begrenzt = faktor.clamp(0.0, 1.0);
    return Color.lerp(this, Colors.black, begrenzt) ?? this;
  }

  /// Gibt diese Farbe mit dem angegebenen Alphakanal [alpha] (0–255) zurück.
  Color mitOpazitaet(int alpha) => withAlpha(alpha.clamp(0, 255));

  /// Gibt die Farbe als Hex-String zurück (z. B. `"#FFD700"`).
  String zuHexString() =>
      '#${value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';
}
