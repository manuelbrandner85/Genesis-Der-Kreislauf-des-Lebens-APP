// spiel_laden_screen.dart
// Listet alle gespeicherten Spielerprofile aus Hive und lädt das gewählte
// Leben über den SpielNotifier. Danach geht es direkt in die Phase weiter,
// in der die Seele zuletzt stand.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/spieler_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

/// Screen zum Fortsetzen eines gespeicherten Lebens.
class SpielLadenScreen extends ConsumerStatefulWidget {
  const SpielLadenScreen({super.key});

  @override
  ConsumerState<SpielLadenScreen> createState() => _SpielLadenScreenState();
}

class _SpielLadenScreenState extends ConsumerState<SpielLadenScreen> {
  /// Alle gefundenen Profile (neueste zuerst).
  List<SpielerProfilModel> _profile = const [];

  bool _laedt = true;
  String? _ladeProfilId;

  @override
  void initState() {
    super.initState();
    _profileLaden();
  }

  /// Liest alle unter `profil_*` gespeicherten Profile aus der Spielstand-Box.
  Future<void> _profileLaden() async {
    try {
      final box = await Hive.openBox<Map>('spielstand');
      final gefunden = <SpielerProfilModel>[];

      for (final schluessel in box.keys) {
        if (schluessel is String && schluessel.startsWith('profil_')) {
          final roh = box.get(schluessel);
          if (roh == null) continue;
          try {
            gefunden.add(
              SpielerProfilModel.fromJson(Map<String, dynamic>.from(roh)),
            );
          } catch (_) {
            // Beschädigte Einträge überspringen statt den Screen zu crashen
          }
        }
      }

      // Zuletzt gespielte Leben zuerst anzeigen
      gefunden.sort((a, b) => b.letzterSpieltag.compareTo(a.letzterSpieltag));

      if (!mounted) return;
      setState(() {
        _profile = gefunden;
        _laedt = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _laedt = false);
    }
  }

  /// Lädt das gewählte Profil und springt in die aktuelle Lebensphase.
  Future<void> _profilFortsetzen(SpielerProfilModel profil) async {
    if (_ladeProfilId != null) return;
    setState(() => _ladeProfilId = profil.id);
    HapticFeedback.mediumImpact();

    await ref.read(spielProvider.notifier).spielerLaden(profil.id);
    if (!mounted) return;

    final zustand = ref.read(spielProvider);
    if (zustand.fehlerMeldung != null) {
      setState(() => _ladeProfilId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(zustand.fehlerMeldung!)),
      );
      return;
    }

    // In die Phase springen, in der das Leben zuletzt stand
    context.go('/phase/${zustand.aktuellePhase.nummer}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      appBar: AppBar(
        title: Text('Leben fortsetzen', style: AppTextStyles.ueberschrift3),
        backgroundColor: Colors.transparent,
        foregroundColor: AppFarben.goldGlanz,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhasenHintergrund(
            phase: GamePhase.kosmisch,
            abdunkelung: 0.6,
            mitKenBurns: false,
          ),
          SafeArea(
            child: _laedt
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppFarben.goldGlanz,
                      strokeWidth: 2,
                    ),
                  )
                : _profile.isEmpty
                    ? _KeineProfile(
                        onNeuesSpiel: () => context.go(AppRouten.neuesSpiel),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: _profile.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) => _ProfilKarte(
                          profil: _profile[i],
                          laedtGerade: _ladeProfilId == _profile[i].id,
                          onFortsetzen: () => _profilFortsetzen(_profile[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profil-Karte
// ─────────────────────────────────────────────────────────────────────────────

class _ProfilKarte extends StatelessWidget {
  final SpielerProfilModel profil;
  final bool laedtGerade;
  final VoidCallback onFortsetzen;

  const _ProfilKarte({
    required this.profil,
    required this.laedtGerade,
    required this.onFortsetzen,
  });

  @override
  Widget build(BuildContext context) {
    final karmaDurchschnitt = profil.kumulativesKarma.durchschnitt;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onFortsetzen,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppFarben.kosmischViolett.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppFarben.goldGlanz.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              // Seelen-Symbol
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppFarben.goldGlanz.withValues(alpha: 0.9),
                      AppFarben.goldDunkel.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profil.anzeigeName,
                      style: AppTextStyles.ueberschrift3
                          .copyWith(color: AppFarben.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zyklus ${profil.aktuellerZyklusNummer} · '
                      'Karma ${karmaDurchschnitt >= 0 ? '+' : ''}'
                      '${karmaDurchschnitt.toStringAsFixed(0)}',
                      style: AppTextStyles.koerperKlein
                          .copyWith(color: AppFarben.textSekundaer),
                    ),
                  ],
                ),
              ),
              laedtGerade
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppFarben.goldGlanz,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.play_arrow_rounded,
                      color: AppFarben.goldGlanz,
                      size: 30,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Leerer Zustand
// ─────────────────────────────────────────────────────────────────────────────

class _KeineProfile extends StatelessWidget {
  final VoidCallback onNeuesSpiel;

  const _KeineProfile({required this.onNeuesSpiel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              color: AppFarben.textTertiaer,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Keine gespeicherten Leben gefunden.',
              style: AppTextStyles.koerper
                  .copyWith(color: AppFarben.textSekundaer),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Beginne ein neues Leben, um deine Seele zu formen.',
              style: AppTextStyles.koerperKlein
                  .copyWith(color: AppFarben.textTertiaer),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextButton.icon(
              onPressed: onNeuesSpiel,
              icon: const Icon(Icons.auto_awesome,
                  color: AppFarben.goldGlanz),
              label: Text(
                'Neues Leben beginnen',
                style: AppTextStyles.koerper
                    .copyWith(color: AppFarben.goldGlanz),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
