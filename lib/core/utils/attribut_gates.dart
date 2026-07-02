// attribut_gates.dart
// Hilfsfunktionen zum Prüfen von Attribut-Voraussetzungen (Gates).
// Entscheidungen/Optionen können Mindestwerte der Basis-Attribute
// des genetischen Codes verlangen (z. B. "Intelligenz ≥ 60").

import 'package:genesis_kreislauf_des_lebens/data/models/genetischer_code_model.dart';

/// Prüft, ob die Basis-Attribute des genetischen Codes die Anforderungen erfüllen.
///
/// [anforderungen]: Attributschlüssel → Mindestwert
/// (z. B. `{'intelligenz': 60}`). Ein im Code fehlendes Attribut zählt als 0.
bool erfuelltVoraussetzungen(
  Map<String, num> anforderungen,
  GenetischerCodeModel code,
) {
  for (final anforderung in anforderungen.entries) {
    final wert = code.basisAttribute[anforderung.key] ?? 0.0;
    if (wert < anforderung.value.toDouble()) {
      return false;
    }
  }
  return true;
}

/// Formatiert Anforderungen als lesbaren UI-Text, z. B. "Intelligenz ≥ 60".
///
/// Mehrere Anforderungen werden mit ", " verbunden.
String voraussetzungenText(Map<String, num> anforderungen) {
  if (anforderungen.isEmpty) return 'Keine Voraussetzungen';
  return anforderungen.entries
      .map((e) => '${_attributAnzeigename(e.key)} ≥ ${_zahlText(e.value)}')
      .join(', ');
}

/// Deutscher Anzeigename eines Attributschlüssels.
String _attributAnzeigename(String schluessel) {
  return switch (schluessel) {
    'kraft' => 'Kraft',
    'intelligenz' => 'Intelligenz',
    'empathie' => 'Empathie',
    'kreativitaet' => 'Kreativität',
    'ausdauer' => 'Ausdauer',
    'intuition' => 'Intuition',
    _ => schluessel.isEmpty
        ? schluessel
        : schluessel[0].toUpperCase() + schluessel.substring(1),
  };
}

/// Formatiert ganze Zahlen ohne Nachkommastellen ("60" statt "60.0").
String _zahlText(num wert) {
  if (wert is int || wert == wert.roundToDouble()) {
    return wert.round().toString();
  }
  return wert.toString();
}
