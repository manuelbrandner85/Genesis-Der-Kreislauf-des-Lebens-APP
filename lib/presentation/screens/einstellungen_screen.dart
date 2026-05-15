// einstellungen_screen.dart
// Einstellungs-Screen für GENESIS: Der Kreislauf des Lebens.
// Bietet Lautstärke-Regler, haptisches Feedback, Sprachinfo und Daten-Management.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Einstellungs-Provider (lokaler State)
// ─────────────────────────────────────────────────────────────────────────────

/// Lokaler StateNotifier für Einstellungswerte.
class _EinstellungenNotifier extends StateNotifier<_EinstellungenState> {
  _EinstellungenNotifier()
      : super(const _EinstellungenState(
          musikLautstaerke: 70,
          effekteLautstaerke: 80,
          haptischFeedback: true,
        ));

  void musikLautstaerkeAendern(double wert) {
    state = state.copyWith(musikLautstaerke: wert.round());
  }

  void effekteLautstaerkeAendern(double wert) {
    state = state.copyWith(effekteLautstaerke: wert.round());
  }

  void haptischFeedbackUmschalten(bool wert) {
    state = state.copyWith(haptischFeedback: wert);
  }
}

/// Unveränderlicher Zustand der Einstellungen.
class _EinstellungenState {
  final int musikLautstaerke;    // 0–100
  final int effekteLautstaerke;  // 0–100
  final bool haptischFeedback;

  const _EinstellungenState({
    required this.musikLautstaerke,
    required this.effekteLautstaerke,
    required this.haptischFeedback,
  });

  _EinstellungenState copyWith({
    int? musikLautstaerke,
    int? effekteLautstaerke,
    bool? haptischFeedback,
  }) {
    return _EinstellungenState(
      musikLautstaerke: musikLautstaerke ?? this.musikLautstaerke,
      effekteLautstaerke: effekteLautstaerke ?? this.effekteLautstaerke,
      haptischFeedback: haptischFeedback ?? this.haptischFeedback,
    );
  }
}

/// Riverpod-Provider für den Einstellungs-Zustand.
final _einstellungenProvider =
    StateNotifierProvider<_EinstellungenNotifier, _EinstellungenState>(
  (ref) => _EinstellungenNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// EinstellungenScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Einstellungs-Screen des Spiels.
class EinstellungenScreen extends ConsumerWidget {
  const EinstellungenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final einstellungen = ref.watch(_einstellungenProvider);
    final notifier = ref.read(_einstellungenProvider.notifier);

    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppFarben.kosmischViolett.withValues(alpha: 0.5),
              AppFarben.kosmischSchwarz,
            ],
            stops: const [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Kopfzeile ────────────────────────────────────────────────
              _EinstellungenKopfzeile(
                onZurueck: () => context.go(AppRouten.hauptMenue),
              ),

              // ── Inhalt ───────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sektion: Audio
                      _AbschnittsTitel(titel: 'Audio'),

                      // Musik-Lautstärke
                      _LautstaerkeEinstellung(
                        label: 'Musik',
                        icon: Icons.music_note_outlined,
                        wert: einstellungen.musikLautstaerke,
                        onGeaendert: notifier.musikLautstaerkeAendern,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 100.ms),

                      const SizedBox(height: 16),

                      // Effekte-Lautstärke
                      _LautstaerkeEinstellung(
                        label: 'Effekte',
                        icon: Icons.surround_sound_outlined,
                        wert: einstellungen.effekteLautstaerke,
                        onGeaendert: notifier.effekteLautstaerkeAendern,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 200.ms),

                      const SizedBox(height: 28),

                      // Sektion: Steuerung
                      _AbschnittsTitel(titel: 'Steuerung'),

                      // Haptisches Feedback
                      _SchalterEinstellung(
                        label: 'Haptisches Feedback',
                        beschreibung:
                            'Vibration bei Entscheidungen und Ereignissen',
                        icon: Icons.vibration,
                        wert: einstellungen.haptischFeedback,
                        onGeaendert: notifier.haptischFeedbackUmschalten,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 300.ms),

                      const SizedBox(height: 28),

                      // Sektion: Sprache
                      _AbschnittsTitel(titel: 'Sprache'),

                      _InfoEinstellung(
                        label: 'Sprache',
                        wert: 'Deutsch',
                        icon: Icons.language,
                        hinweis: 'Weitere Sprachen folgen in späteren Versionen',
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 400.ms),

                      const SizedBox(height: 28),

                      // Sektion: Über das Spiel
                      _AbschnittsTitel(titel: 'Über das Spiel'),

                      _InfoEinstellung(
                        label: 'Version',
                        wert: '0.1.0',
                        icon: Icons.info_outline,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 500.ms),

                      const SizedBox(height: 16),

                      _InfoEinstellung(
                        label: 'Entwickler',
                        wert: 'GENESIS Studio',
                        icon: Icons.code,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 550.ms),

                      const SizedBox(height: 32),

                      // Sektion: Daten
                      _AbschnittsTitel(titel: 'Daten'),

                      // Gespeicherte Daten löschen
                      _DatenLoeschenButton(
                        onBestaetigt: () => _dateiLoeschen(context),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 650.ms),

                      const SizedBox(height: 40),

                      // Copyright
                      Center(
                        child: Text(
                          '© 2024 GENESIS. Alle Rechte vorbehalten.',
                          style: AppTextStyles.mikro,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 700.ms),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wird nach der Bestätigung des Lösch-Dialogs aufgerufen.
  Future<void> _dateiLoeschen(BuildContext context) async {
    // Hier später: HiveDienst.allesDaten loeschen aufrufen
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alle Daten wurden gelöscht.',
            style: AppTextStyles.koerperKlein.copyWith(
              color: AppFarben.text,
            ),
          ),
          backgroundColor: AppFarben.fehlerHintergrund,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: AppFarben.fehler, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kopfzeile
// ─────────────────────────────────────────────────────────────────────────────

class _EinstellungenKopfzeile extends StatelessWidget {
  final VoidCallback onZurueck;

  const _EinstellungenKopfzeile({required this.onZurueck});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onZurueck,
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: AppFarben.goldGlanz,
          ),
          const SizedBox(width: 8),
          Text(
            'Einstellungen',
            style: AppTextStyles.ueberschrift3.copyWith(
              color: AppFarben.goldGlanz,
              fontSize: 20,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms),
          const Spacer(),
          const Icon(
            Icons.settings,
            color: AppFarben.goldDunkel,
            size: 22,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Abschnitts-Titel
// ─────────────────────────────────────────────────────────────────────────────

class _AbschnittsTitel extends StatelessWidget {
  final String titel;

  const _AbschnittsTitel({required this.titel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            titel.toUpperCase(),
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.goldDunkel,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppFarben.goldGlanz.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lautstärke-Einstellung
// ─────────────────────────────────────────────────────────────────────────────

/// Slider-basierte Lautstärke-Einstellung mit Icon, Label und Prozentwert.
class _LautstaerkeEinstellung extends StatelessWidget {
  final String label;
  final IconData icon;
  final int wert; // 0–100
  final ValueChanged<double> onGeaendert;

  const _LautstaerkeEinstellung({
    required this.label,
    required this.icon,
    required this.wert,
    required this.onGeaendert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppFarben.trenner,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppFarben.goldGlanz, size: 18),
              const SizedBox(width: 10),
              Text(label, style: AppTextStyles.koerperKleinFett),
              const Spacer(),
              Text(
                '$wert%',
                style: AppTextStyles.spielStatusWert.copyWith(
                  fontSize: 16,
                  color: wert > 0
                      ? AppFarben.goldGlanz
                      : AppFarben.textTertiaer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppFarben.goldGlanz,
              inactiveTrackColor: AppFarben.nebelGrau.withValues(alpha: 0.4),
              thumbColor: AppFarben.goldGlanz,
              overlayColor: AppFarben.goldGlanz.withValues(alpha: 0.15),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 18),
              trackHeight: 3,
            ),
            child: Slider(
              value: wert.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: onGeaendert,
            ),
          ),
          // Lautstärke-Beschriftungen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Stumm', style: AppTextStyles.mikro),
              Text('Mittel', style: AppTextStyles.mikro),
              Text('Laut', style: AppTextStyles.mikro),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schalter-Einstellung (Switch)
// ─────────────────────────────────────────────────────────────────────────────

/// Switch-basierte Einstellung mit Label und optionaler Beschreibung.
class _SchalterEinstellung extends StatelessWidget {
  final String label;
  final String? beschreibung;
  final IconData icon;
  final bool wert;
  final ValueChanged<bool> onGeaendert;

  const _SchalterEinstellung({
    required this.label,
    this.beschreibung,
    required this.icon,
    required this.wert,
    required this.onGeaendert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppFarben.trenner, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppFarben.goldGlanz, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.koerperKleinFett),
                if (beschreibung != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    beschreibung!,
                    style: AppTextStyles.beschriftung.copyWith(
                      color: AppFarben.textTertiaer,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: wert,
            onChanged: onGeaendert,
            activeColor: AppFarben.goldGlanz,
            activeTrackColor: AppFarben.goldGlanz.withValues(alpha: 0.3),
            inactiveThumbColor: AppFarben.nebelGrau,
            inactiveTrackColor: AppFarben.nebelGrau.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info-Einstellung (nur Anzeige, nicht änderbar)
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt eine nicht-änderbare Einstellung (reine Information).
class _InfoEinstellung extends StatelessWidget {
  final String label;
  final String wert;
  final IconData icon;
  final String? hinweis;

  const _InfoEinstellung({
    required this.label,
    required this.wert,
    required this.icon,
    this.hinweis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppFarben.oberflaeche,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppFarben.trenner, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppFarben.goldGlanz, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: AppTextStyles.koerperKleinFett),
              ),
              Text(
                wert,
                style: AppTextStyles.koerperKlein.copyWith(
                  color: AppFarben.textSekundaer,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.lock_outline,
                size: 14,
                color: AppFarben.textTertiaer,
              ),
            ],
          ),
          if (hinweis != null) ...[
            const SizedBox(height: 6),
            Text(
              hinweis!,
              style: AppTextStyles.mikro.copyWith(
                color: AppFarben.textTertiaer,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daten löschen Button
// ─────────────────────────────────────────────────────────────────────────────

/// Button zum Löschen aller gespeicherten Spielstände mit Bestätigungs-Dialog.
class _DatenLoeschenButton extends StatelessWidget {
  final VoidCallback onBestaetigt;

  const _DatenLoeschenButton({required this.onBestaetigt});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _zeigeDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: AppFarben.fehlerHintergrund,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppFarben.fehler.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.delete_outline,
              color: AppFarben.fehler,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gespeicherte Daten löschen',
                    style: AppTextStyles.koerperKleinFett.copyWith(
                      color: AppFarben.fehler,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Alle Leben, Karma-Daten und Fortschritte werden gelöscht',
                    style: AppTextStyles.beschriftung.copyWith(
                      color: AppFarben.fehler.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppFarben.fehler.withValues(alpha: 0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Zeigt den Bestätigungs-Dialog.
  Future<void> _zeigeDialog(BuildContext context) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      barrierColor: AppFarben.scrim,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppFarben.oberflaecheErhoben,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppFarben.fehler.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        // Dialog-Titel
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppFarben.fehler, size: 22),
            const SizedBox(width: 10),
            Text(
              'Daten löschen',
              style: AppTextStyles.ueberschrift4.copyWith(
                color: AppFarben.fehler,
                fontSize: 18,
              ),
            ),
          ],
        ),
        // Dialog-Inhalt
        content: Text(
          'Möchtest du wirklich alle gespeicherten Daten löschen?\n\n'
          'Diese Aktion kann nicht rückgängig gemacht werden. '
          'Alle Leben, Karma-Profile und die Seelenbibliothek werden '
          'unwiederbringlich gelöscht.',
          style: AppTextStyles.koerperKlein,
        ),
        actions: [
          // Abbrechen
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Abbrechen',
              style: AppTextStyles.buttonSekundaer.copyWith(
                color: AppFarben.textSekundaer,
              ),
            ),
          ),
          // Löschen bestätigen
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppFarben.fehler,
              foregroundColor: AppFarben.text,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Löschen',
              style: AppTextStyles.buttonPrimaer.copyWith(
                color: AppFarben.text,
              ),
            ),
          ),
        ],
      ),
    );

    if (bestaetigt == true) {
      onBestaetigt();
    }
  }
}
