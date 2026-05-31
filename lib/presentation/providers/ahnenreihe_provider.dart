// ahnenreihe_provider.dart
// Riverpod-Provider für die Ahnenreihe der Seele.
// Verwaltet alle Vorfahren-Daten, Freischaltung und epigenetische Effekte.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:genesis_kreislauf_des_lebens/data/models/ahnenreihe_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hive-Box-Name
// ─────────────────────────────────────────────────────────────────────────────

const String _kAhnenreiheBox = 'ahnenreihe';

// ─────────────────────────────────────────────────────────────────────────────
// AhnenreiheNotifier
// ─────────────────────────────────────────────────────────────────────────────

/// StateNotifier für die Seelen-Ahnenreihe.
/// Hält den Stammbaum und berechnet kumulative epigenetische Effekte.
class AhnenreiheNotifier extends StateNotifier<AhnenreiheModel?> {
  AhnenreiheNotifier() : super(null);

  Box<Map>? _box;

  // ───────────────────────────────────────────────────────────────────────────
  // Initialisierung
  // ───────────────────────────────────────────────────────────────────────────

  /// Lädt die Ahnenreihe für eine Seele aus Hive.
  Future<void> laden(String seelencodeId) async {
    _box ??= await Hive.openBox<Map>(_kAhnenreiheBox);

    final roh = _box!.get('ahnenreihe_$seelencodeId');
    if (roh != null) {
      state = AhnenreiheModel.fromJson(Map<String, dynamic>.from(roh));
    } else {
      state = AhnenreiheModel.leer(seelencodeId);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Ahnen hinzufügen
  // ───────────────────────────────────────────────────────────────────────────

  /// Registriert einen abgeschlossenen Lebenszyklus als neuen Ahnen-Eintrag.
  Future<void> zyklusAlsAhnenEintragen({
    required String name,
    required Zeitalter zeitalter,
    required KarmaProfilModel karmaSnapshot,
    required JenseitsReich jenseitsReich,
    required int sterbealter,
    required int zyklusNummer,
    List<String> schluessel_ereignisse = const [],
    String? letzteWorte,
    Map<String, double> epigenetischeVererbung = const {},
  }) async {
    if (state == null) return;

    final neuerAhn = AhnenEintrag.erstellen(
      name: name,
      zeitalter: zeitalter,
      karmaSnapshot: karmaSnapshot,
      jenseitsReich: jenseitsReich,
      sterbealter: sterbealter,
      zyklusNummer: zyklusNummer,
      schluessel_ereignisse: schluessel_ereignisse,
      letzteWorte: letzteWorte,
      epigenetischeVererbung: epigenetischeVererbung,
    );

    state = state!.mitNeuemAhnen(neuerAhn);
    await _speichern();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Berechnungen
  // ───────────────────────────────────────────────────────────────────────────

  /// Gibt die kumulierten epigenetischen Effekte aller Vorfahren zurück.
  Map<String, double> get kumulierteEpigenetik =>
      state?.kumulierteEpigenetik ?? {};

  /// Ob die Ahnenreihe freigeschaltet ist (ab 3 abgeschlossenen Zyklen).
  bool get istFreigeschaltet => state?.istFreigeschaltet ?? false;

  // ───────────────────────────────────────────────────────────────────────────
  // Persistenz
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _speichern() async {
    if (state == null) return;
    _box ??= await Hive.openBox<Map>(_kAhnenreiheBox);
    await _box!.put(
      'ahnenreihe_${state!.seelencodeId}',
      state!.toJson(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider für die Ahnenreihe der aktiven Seele.
final ahnenreiheProvider =
    StateNotifierProvider<AhnenreiheNotifier, AhnenreiheModel?>(
  (ref) => AhnenreiheNotifier(),
);

/// Abgeleiteter Provider: Ist die Ahnenreihe freigeschaltet?
final ahnenreiheFreigeschaltetProvider = Provider<bool>((ref) {
  final ahnenreihe = ref.watch(ahnenreiheProvider);
  return ahnenreihe?.istFreigeschaltet ?? false;
});

/// Abgeleiteter Provider: Kumulierte epigenetische Effekte aller Vorfahren.
final epigenetikEffekteProvider = Provider<Map<String, double>>((ref) {
  final ahnenreihe = ref.watch(ahnenreiheProvider);
  return ahnenreihe?.kumulierteEpigenetik ?? {};
});
