// entstehungs_controller.dart
// Verbindet das Flame-Spiel mit dem Riverpod-State nach Abschluss des Rennens.
// Schreibt die Route-Attribute in den genetischen Code des Charakters
// und navigiert zur nächsten Phase.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/game/entstehung/rennen_ergebnis.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_zustand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EntstehungsController
// ─────────────────────────────────────────────────────────────────────────────

/// Verarbeitet das Rennen-Ergebnis und überführt es in den Spielzustand.
///
/// Wird vom [EntstehungSpielScreen] aufgerufen sobald das Rennen beendet ist.
/// Verbindet die Flame-Spiellogik mit dem Riverpod-Providersystem.
class EntstehungsController {
  // Privater Konstruktor – nur statische Methoden
  const EntstehungsController._();

  // ─────────────────────────────────────────────────────────────────────────
  // Rennen abschließen
  // ─────────────────────────────────────────────────────────────────────────

  /// Verarbeitet das Rennen-Ergebnis, aktualisiert den Spielzustand
  /// und navigiert zu Phase 2.
  ///
  /// [ref] – Riverpod-Referenz zum Lesen/Schreiben von Providern
  /// [ergebnis] – Das Ergebnis des abgeschlossenen Rennens
  /// [context] – BuildContext für Navigation mit GoRouter
  static Future<void> rennenAbschliessen(
    WidgetRef ref,
    RennenErgebnis ergebnis,
    BuildContext context,
  ) async {
    try {
      // 1. Attribute aus dem Rennergebnis berechnen
      final attribute = ergebnis.attributeBerechnen();

      // 2. Aktuellen Spielzustand lesen
      final spielNotifier = ref.read(spielProvider.notifier);
      final spielZustand = ref.read(spielProvider);

      // 3. Genetischen Code mit neuen Attributen aktualisieren
      if (spielZustand.aktuellerZyklus != null) {
        final aktuellerZyklus = spielZustand.aktuellerZyklus!;

        // Genetischen Code aus dem Zyklus holen
        final alterCode = aktuellerZyklus.genetischerCode;

        // Neue Basisattribute aus dem Rennergebnis einsetzen
        final neuerCode = alterCode.copyWith(
          basisAttribute: {
            ...alterCode.basisAttribute,
            ...attribute, // Rennen-Attribute überschreiben die Zufallsattribute
          },
          // Hauptattribut aktiviert entsprechendes Gen
          aktivierteGene: _geneAktualisieren(
            alterCode.aktivierteGene,
            ergebnis.gewaehltRoute,
          ),
        );

        // Zyklus mit neuem genetischen Code in den Zustand übernehmen
        // und speichern – vorher wurde das Rennergebnis verworfen.
        final aktualisiertZyklus = aktuellerZyklus.copyWith(
          genetischerCode: neuerCode,
        );
        await spielNotifier.zyklusAktualisieren(aktualisiertZyklus);
      }

      // 4. Spielphase auf "Formung" (Phase 2) wechseln
      await spielNotifier.phasWechseln(GamePhase.formung);

      // 5. Zur Phase 2 navigieren
      if (context.mounted) {
        context.go(AppRouten.phase2);
      }
    } catch (fehler) {
      // Fehler loggen und trotzdem navigieren
      debugPrint(
        '[EntstehungsController] Fehler beim Abschließen: $fehler',
      );

      // Fallback: trotzdem navigieren
      if (context.mounted) {
        context.go(AppRouten.phase2);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Hilfsmethoden
  // ─────────────────────────────────────────────────────────────────────────

  /// Aktiviert das zur Route passende Gen
  static List<String> _geneAktualisieren(
    List<String> aktiveGene,
    RoutenTyp route,
  ) {
    final neueGene = List<String>.from(aktiveGene);

    // Route → Gen-Zuordnung
    final routenGen = switch (route) {
      RoutenTyp.kraft => 'gen_widerstand',
      RoutenTyp.intelligenz => 'gen_logik',
      RoutenTyp.empathie => 'gen_einfuehlsam',
    };

    if (!neueGene.contains(routenGen)) {
      neueGene.add(routenGen);
    }

    return neueGene;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Ergebnis-Zusammenfassung
  // ─────────────────────────────────────────────────────────────────────────

  /// Gibt eine lesbare Zusammenfassung des Rennergebnisses zurück.
  ///
  /// Kann für Debug-Ausgaben oder Bestätigungs-Screens verwendet werden.
  static String ergebnisBeschreibung(RennenErgebnis ergebnis) {
    final attribute = ergebnis.attributeBerechnen();
    final buffer = StringBuffer();

    buffer.writeln('=== RENNEN ABGESCHLOSSEN ===');
    buffer.writeln('Route: ${ergebnis.gewaehltRoute.anzeigeName}');
    buffer.writeln('Platzierung: ${ergebnis.endPlatzierung}');
    buffer.writeln(
      'PowerUps: Kraft=${ergebnis.eingesammelteKraftPowerUps}, '
      'Intel=${ergebnis.eingesammelteIntelligenzPowerUps}, '
      'Empathie=${ergebnis.eingesammelteEmpathiePowerUps}',
    );
    buffer.writeln('Leben am Ende: ${ergebnis.lebenAmEnde}/3');
    buffer.writeln('');
    buffer.writeln('--- BERECHNETE ATTRIBUTE ---');
    for (final eintrag in attribute.entries) {
      buffer.writeln(
        '${eintrag.key}: ${eintrag.value.toStringAsFixed(1)}',
      );
    }

    return buffer.toString();
  }
}

