// karma_anzeige.dart
// Karma-Anzeige-Widget für GENESIS: Der Kreislauf des Lebens.
// Visualisiert die 6 Karma-Dimensionen als animierte Balken.
// Jede Dimension zeigt den Namen, einen farbigen Balken und den aktuellen Wert.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum: KarmaAnzeigeTyp
// ─────────────────────────────────────────────────────────────────────────────

/// Legt fest, wie das Karma-Anzeige-Widget dargestellt wird.
enum KarmaAnzeigeTyp {
  /// Kompaktansicht: alle 6 Dimensionen als schmale Zeilen untereinander.
  kompakt,

  /// Einzelansicht: eine Dimension groß mit detaillierter Beschriftung.
  einzeln,
}

// ─────────────────────────────────────────────────────────────────────────────
// KarmaAnzeige
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt das Karma-Profil als visuelle Balkendiagramme an.
///
/// Im [KarmaAnzeigeTyp.kompakt]-Modus werden alle sechs Dimensionen
/// als schmale animierte Balken untereinander dargestellt.
///
/// Im [KarmaAnzeigeTyp.einzeln]-Modus wird nur [einzelneDimension] angezeigt,
/// dafür groß und mit zusätzlichem Kontext.
///
/// Beispiel:
/// ```dart
/// KarmaAnzeige(
///   karmaProfil: spielerProfil.karmaProfil,
///   anzeigeTyp: KarmaAnzeigeTyp.kompakt,
/// )
/// ```
class KarmaAnzeige extends StatelessWidget {
  /// Das Karma-Profil, das angezeigt werden soll.
  final KarmaProfilModel karmaProfil;

  /// Darstellungsmodus (Standard: kompakt).
  final KarmaAnzeigeTyp anzeigeTyp;

  /// Nur im [KarmaAnzeigeTyp.einzeln]-Modus: welche Dimension groß angezeigt wird.
  final KarmaDimension? einzelneDimension;

  /// Gibt an, ob die Balken beim ersten Aufbau animiert einblenden sollen.
  final bool animiert;

  const KarmaAnzeige({
    super.key,
    required this.karmaProfil,
    this.anzeigeTyp = KarmaAnzeigeTyp.kompakt,
    this.einzelneDimension,
    this.animiert = true,
  });

  @override
  Widget build(BuildContext context) {
    if (anzeigeTyp == KarmaAnzeigeTyp.einzeln) {
      final dim = einzelneDimension ?? KarmaDimension.mitgefuehl;
      return _EinzelDimensionsAnzeige(
        dimension: dim,
        wert: _wertFuerDimension(dim),
        animiert: animiert,
      );
    }

    // Kompaktansicht: alle 6 Dimensionen
    return _KompaktAnzeige(
      karmaProfil: karmaProfil,
      animiert: animiert,
    );
  }

  /// Gibt den numerischen Wert der angegebenen Karma-Dimension zurück.
  double _wertFuerDimension(KarmaDimension dim) {
    switch (dim) {
      case KarmaDimension.mitgefuehl:
        return karmaProfil.mitgefuehl;
      case KarmaDimension.ehrlichkeit:
        return karmaProfil.ehrlichkeit;
      case KarmaDimension.mut:
        return karmaProfil.mut;
      case KarmaDimension.grosszuegigkeit:
        return karmaProfil.grosszuegigkeit;
      case KarmaDimension.weisheit:
        return karmaProfil.weisheit;
      case KarmaDimension.liebe:
        return karmaProfil.liebe;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kompaktansicht: alle 6 Dimensionen untereinander
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt alle sechs Karma-Dimensionen als kompakte animierte Zeilen.
class _KompaktAnzeige extends StatelessWidget {
  final KarmaProfilModel karmaProfil;
  final bool animiert;

  const _KompaktAnzeige({
    required this.karmaProfil,
    required this.animiert,
  });

  @override
  Widget build(BuildContext context) {
    // Dimensionen mit Namen und Werten zusammenstellen
    final dimensionen = [
      (
        dim: KarmaDimension.mitgefuehl,
        positivName: 'Mitgefühl',
        negativName: 'Grausamkeit',
        wert: karmaProfil.mitgefuehl,
      ),
      (
        dim: KarmaDimension.ehrlichkeit,
        positivName: 'Ehrlichkeit',
        negativName: 'Täuschung',
        wert: karmaProfil.ehrlichkeit,
      ),
      (
        dim: KarmaDimension.mut,
        positivName: 'Mut',
        negativName: 'Feigheit',
        wert: karmaProfil.mut,
      ),
      (
        dim: KarmaDimension.grosszuegigkeit,
        positivName: 'Großzügigkeit',
        negativName: 'Gier',
        wert: karmaProfil.grosszuegigkeit,
      ),
      (
        dim: KarmaDimension.weisheit,
        positivName: 'Weisheit',
        negativName: 'Ignoranz',
        wert: karmaProfil.weisheit,
      ),
      (
        dim: KarmaDimension.liebe,
        positivName: 'Liebe',
        negativName: 'Gleichgültigkeit',
        wert: karmaProfil.liebe,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: dimensionen.asMap().entries.map((eintrag) {
        final index = eintrag.key;
        final d = eintrag.value;

        // Angezeigter Name je nach Tendenz des Wertes
        final angezeigterName =
            d.wert >= 0 ? d.positivName : d.negativName;

        Widget zeile = _KarmaBalkenZeile(
          name: angezeigterName,
          wert: d.wert,
          istKompakt: true,
        );

        if (animiert) {
          zeile = zeile
              .animate(delay: Duration(milliseconds: 60 * index))
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0, duration: 350.ms);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: zeile,
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Einzelansicht: eine Dimension groß
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt eine einzelne Karma-Dimension groß mit Label, Balken und Beschriftung.
class _EinzelDimensionsAnzeige extends StatelessWidget {
  final KarmaDimension dimension;
  final double wert;
  final bool animiert;

  const _EinzelDimensionsAnzeige({
    required this.dimension,
    required this.wert,
    required this.animiert,
  });

  String get _positivName {
    switch (dimension) {
      case KarmaDimension.mitgefuehl:
        return 'Mitgefühl';
      case KarmaDimension.ehrlichkeit:
        return 'Ehrlichkeit';
      case KarmaDimension.mut:
        return 'Mut';
      case KarmaDimension.grosszuegigkeit:
        return 'Großzügigkeit';
      case KarmaDimension.weisheit:
        return 'Weisheit';
      case KarmaDimension.liebe:
        return 'Liebe';
    }
  }

  String get _negativName {
    switch (dimension) {
      case KarmaDimension.mitgefuehl:
        return 'Grausamkeit';
      case KarmaDimension.ehrlichkeit:
        return 'Täuschung';
      case KarmaDimension.mut:
        return 'Feigheit';
      case KarmaDimension.grosszuegigkeit:
        return 'Gier';
      case KarmaDimension.weisheit:
        return 'Ignoranz';
      case KarmaDimension.liebe:
        return 'Gleichgültigkeit';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget inhalt = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Positiv/Negativ-Label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _negativName,
              style: AppTextStyles.beschriftung.copyWith(
                color: AppFarben.karmaNegatv,
              ),
            ),
            Text(
              _positivName,
              style: AppTextStyles.beschriftung.copyWith(
                color: AppFarben.karmaPositiv,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Großer Balken
        _KarmaBalkenZeile(
          name: wert >= 0 ? _positivName : _negativName,
          wert: wert,
          istKompakt: false,
        ),

        const SizedBox(height: 8),

        // Numerischer Wert in der Mitte
        Center(
          child: Text(
            '${wert >= 0 ? '+' : ''}${wert.toStringAsFixed(1)}',
            style: AppTextStyles.spielStatusWert.copyWith(
              color: AppFarben.fuerKarmaWert(wert),
              fontSize: 32,
            ),
          ),
        ),
      ],
    );

    if (animiert) {
      inhalt = inhalt
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(begin: const Offset(0.95, 0.95), duration: 500.ms);
    }

    return inhalt;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Karma-Balken-Zeile
// ─────────────────────────────────────────────────────────────────────────────

/// Eine einzelne Zeile mit Name, Balken und Wert für eine Karma-Dimension.
///
/// Der Balken hat die Mitte als Nullpunkt:
/// - Positive Werte füllen die rechte Hälfte
/// - Negative Werte füllen die linke Hälfte
class _KarmaBalkenZeile extends StatelessWidget {
  final String name;
  final double wert; // -100 bis +100
  final bool istKompakt;

  const _KarmaBalkenZeile({
    required this.name,
    required this.wert,
    required this.istKompakt,
  });

  /// Berechnet die Balkenfarbe anhand des Karma-Werts.
  Color get _balkenFarbe => AppFarben.fuerKarmaWert(wert);

  /// Normalisierter Wert (0.0 = -100, 0.5 = 0, 1.0 = +100).
  double get _normiert => (wert + 100.0) / 200.0;

  @override
  Widget build(BuildContext context) {
    final namensBreite = istKompakt ? 90.0 : 110.0;
    final balkenHoehe = istKompakt ? 6.0 : 12.0;
    final wertBreite = istKompakt ? 36.0 : 50.0;

    return Row(
      children: [
        // Name der Dimension (links)
        SizedBox(
          width: namensBreite,
          child: Text(
            name,
            style: istKompakt
                ? AppTextStyles.beschriftung
                : AppTextStyles.koerperKleinFett,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: 8),

        // Balken (Mitte = Nullpunkt)
        Expanded(
          child: _ZweipolBalken(
            normiert: _normiert,
            farbe: _balkenFarbe,
            hoehe: balkenHoehe,
          ),
        ),

        const SizedBox(width: 8),

        // Numerischer Wert (rechts)
        SizedBox(
          width: wertBreite,
          child: Text(
            '${wert >= 0 ? '+' : ''}${wert.toStringAsFixed(0)}',
            style: (istKompakt
                    ? AppTextStyles.beschriftung
                    : AppTextStyles.koerperKleinFett)
                .copyWith(color: _balkenFarbe),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Zweipoliger Balken (Mitte = 0)
// ─────────────────────────────────────────────────────────────────────────────

/// Rendert einen Balken mit Mittelpunkt als Nullpunkt.
/// Werte links der Mitte = negativ (rot), rechts = positiv (grün).
class _ZweipolBalken extends StatelessWidget {
  final double normiert; // 0.0 – 1.0 (0.5 = Mitte/null)
  final Color farbe;
  final double hoehe;

  const _ZweipolBalken({
    required this.normiert,
    required this.farbe,
    required this.hoehe,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gesamtBreite = constraints.maxWidth;
        final mitteX = gesamtBreite / 2;

        // Abstand vom Mittelpunkt (-1.0 bis +1.0)
        final abstand = (normiert - 0.5) * 2.0;
        final balkenBreite = (abstand.abs() * mitteX).clamp(0.0, mitteX);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Hintergrundbalken (gesamte Breite)
            Container(
              height: hoehe,
              decoration: BoxDecoration(
                color: AppFarben.nebelGrau.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(hoehe / 2),
              ),
            ),

            // Mittellinie
            Positioned(
              left: mitteX - 0.5,
              child: Container(
                width: 1,
                height: hoehe * 1.5,
                color: AppFarben.nebelGrau.withValues(alpha: 0.8),
              ),
            ),

            // Farbiger Balken (links oder rechts der Mitte)
            Positioned(
              left: abstand >= 0 ? mitteX : mitteX - balkenBreite,
              child: Container(
                width: balkenBreite,
                height: hoehe,
                decoration: BoxDecoration(
                  color: farbe,
                  borderRadius: BorderRadius.circular(hoehe / 2),
                  boxShadow: [
                    BoxShadow(
                      color: farbe.withValues(alpha: 0.4),
                      blurRadius: 4,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
