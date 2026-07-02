// phase9_schoepfung_screen.dart
// Phase 9 – Die Schöpfung: Das Universum formen.
// In drei Schritten erschafft die Seele eine neue Welt, bestimmt ihre
// Gesetze und gibt der nächsten Inkarnation ein Vermächtnis mit.
// Danach schließt sich der Kreislauf.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/karma_profil_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/karma_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/koerper_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

/// Phase 9 – Die Schöpfung.
///
/// Der finale Akt des Kreislaufs: Die Seele wird zur Schöpferin und legt
/// die Bedingungen für ihr nächstes Leben fest.
class Phase9SchoepfungScreen extends ConsumerStatefulWidget {
  const Phase9SchoepfungScreen({super.key});

  @override
  ConsumerState<Phase9SchoepfungScreen> createState() =>
      _Phase9SchoepfungScreenState();
}

class _Phase9SchoepfungScreenState extends ConsumerState<Phase9SchoepfungScreen>
    with SingleTickerProviderStateMixin {
  /// Aktueller Schritt (0 = Welt, 1 = Gesetze, 2 = Vermächtnis).
  int _schritt = 0;

  /// Gewählte Welt und Gesetz (Index, -1 = noch nicht gewählt).
  int _gewaehlteWelt = -1;
  int _gewaehltesGesetz = -1;

  /// Vermächtnis-Text für die nächste Seele.
  final TextEditingController _vermaechtnisController = TextEditingController();

  /// Rotierende Galaxie.
  late final AnimationController _galaxieController;

  // ── Auswahl-Daten ─────────────────────────────────────────────────────────

  static const List<_Wahl> _welten = [
    _Wahl('Wasserplanet', Icons.water, 'Ozeane voller Möglichkeiten'),
    _Wahl('Wüstenplanet', Icons.wb_sunny, 'Überleben formt Stärke'),
    _Wahl('Waldplanet', Icons.forest, 'Natur im Gleichgewicht'),
    _Wahl('Eisplanet', Icons.ac_unit, 'Kälte gebiert Klarheit'),
  ];

  static const List<_Wahl> _gesetze = [
    _Wahl('Mitgefühl regiert', Icons.favorite, '+Mitgefühl für nächste Seele'),
    _Wahl('Stärke regiert', Icons.fitness_center, '+Mut für nächste Seele'),
    _Wahl('Weisheit regiert', Icons.auto_awesome,
        '+Weisheit für nächste Seele'),
    _Wahl('Chaos regiert', Icons.shuffle, 'Zufällige Karma-Boni'),
  ];

  @override
  void initState() {
    super.initState();
    _galaxieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _galaxieController.dispose();
    _vermaechtnisController.dispose();
    super.dispose();
  }

  /// Wendet das gewählte Gesetz als Karma-Bonus für die nächste Seele an.
  void _gesetzAnwenden(int index) {
    final notifier = ref.read(karmaProvider.notifier);
    switch (index) {
      case 0:
        notifier.dimensionAendern(KarmaDimension.mitgefuehl, 10);
        break;
      case 1:
        notifier.dimensionAendern(KarmaDimension.mut, 10);
        break;
      case 2:
        notifier.dimensionAendern(KarmaDimension.weisheit, 10);
        break;
      case 3:
        // Chaos: zufällige Boni auf zwei Dimensionen.
        final r = math.Random();
        final dims = KarmaDimension.values.toList()..shuffle(r);
        notifier.dimensionAendern(dims[0], (5 + r.nextInt(8)).toDouble());
        notifier.dimensionAendern(dims[1], (5 + r.nextInt(8)).toDouble());
        break;
    }
  }

  /// Nächster Schritt bzw. Abschluss der Schöpfung.
  ///
  /// Am Ende schließt sich der Kreislauf wirklich: Der Zyklus wird im
  /// SpielProvider abgeschlossen und die nächste Inkarnation gestartet
  /// (Schöpfer-Bonus: 40 % Karma-Erbe). Der Karma-Bonus aus [_gesetzAnwenden]
  /// wirkt dabei bereits VOR dem Abschluss auf das kumulative Karma.
  Future<void> _weiter() async {
    if (_schritt < 2) {
      setState(() => _schritt++);
      return;
    }

    // Der Kreislauf schließt sich: Zyklus abschließen, neues Leben erzeugen.
    await ref
        .read(spielProvider.notifier)
        .zyklusAbschliessenUndNeuStarten(karmaErbeFaktor: 0.4);

    if (!mounted) return;

    // Fehlerfall: Meldung anzeigen, keine Navigation
    final spiel = ref.read(spielProvider);
    final fehler = spiel.fehlerMeldung;
    if (fehler != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(fehler)),
      );
      return;
    }

    // Karma-Provider auf das Erbe-Karma des neuen Zyklus setzen
    final profil = spiel.spielerProfil;
    if (profil != null) {
      ref.read(karmaProvider.notifier).karmaSetzen(profil.kumulativesKarma);
    }
    // Körper-Simulation auf den Geburtszustand zurücksetzen
    ref.read(koerperProvider.notifier).zuruecksetzen();

    // Das neue Leben beginnt in Phase 1.
    context.go('/phase/1');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: Stack(
        children: [
          // Phasen-Artwork-Hintergrund
          const Positioned.fill(
            child: PhasenHintergrund(phase: GamePhase.schoepfung),
          ),

          // Rotierende Galaxie im Hintergrund.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _galaxieController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _GalaxiePainter(rotation: _galaxieController.value),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _baueKopf(),
                  const SizedBox(height: 24),
                  Expanded(child: _baueSchrittInhalt()),
                  const SizedBox(height: 16),
                  _baueWeiterButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Kopfbereich mit Schrittanzeige ────────────────────────────────────────

  Widget _baueKopf() {
    return Column(
      children: [
        Text(
          'PHASE IX · SCHÖPFUNG',
          style: AppTextStyles.beschriftung.copyWith(letterSpacing: 4),
        ),
        const SizedBox(height: 8),
        Text(
          'Schritt ${_schritt + 1}/3',
          style: AppTextStyles.koerperKlein.copyWith(
            color: AppFarben.textSekundaer,
          ),
        ),
      ],
    );
  }

  Widget _baueSchrittInhalt() {
    switch (_schritt) {
      case 0:
        return _baueWahlListe(
          frage: 'Welche Welt erschaffst du?',
          optionen: _welten,
          gewaehlt: _gewaehlteWelt,
          beiWahl: (i) => setState(() => _gewaehlteWelt = i),
        );
      case 1:
        return _baueWahlListe(
          frage: 'Welche Gesetze gelten?',
          optionen: _gesetze,
          gewaehlt: _gewaehltesGesetz,
          beiWahl: (i) {
            setState(() => _gewaehltesGesetz = i);
            _gesetzAnwenden(i);
          },
        );
      default:
        return _baueVermaechtnis();
    }
  }

  // ── Schritt 1 & 2: Karten-Auswahl ─────────────────────────────────────────

  Widget _baueWahlListe({
    required String frage,
    required List<_Wahl> optionen,
    required int gewaehlt,
    required ValueChanged<int> beiWahl,
  }) {
    return Column(
      key: ValueKey(frage),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          frage,
          textAlign: TextAlign.center,
          style: AppTextStyles.ueberschrift3.copyWith(
            color: AppFarben.text,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: optionen.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final wahl = optionen[i];
              final aktiv = gewaehlt == i;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => beiWahl(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: aktiv
                          ? AppFarben.mystischLila.withValues(alpha: 0.6)
                          : AppFarben.oberflaeche.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: aktiv
                            ? AppFarben.goldGlanz
                            : AppFarben.mystischLila.withValues(alpha: 0.4),
                        width: aktiv ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppFarben.kosmischSchwarz
                                .withValues(alpha: 0.5),
                          ),
                          child: Icon(
                            wahl.icon,
                            color: aktiv
                                ? AppFarben.goldGlanz
                                : AppFarben.textSekundaer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wahl.name,
                                style: AppTextStyles.beschriftung.copyWith(
                                  color: aktiv
                                      ? AppFarben.goldGlanz
                                      : AppFarben.text,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                wahl.beschreibung,
                                style: AppTextStyles.koerperKlein.copyWith(
                                  color: AppFarben.textSekundaer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (aktiv)
                          const Icon(Icons.check_circle,
                              color: AppFarben.goldGlanz),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  // ── Schritt 3: Vermächtnis ────────────────────────────────────────────────

  Widget _baueVermaechtnis() {
    return Column(
      key: const ValueKey('vermaechtnis'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Vermächtnis',
          textAlign: TextAlign.center,
          style: AppTextStyles.ueberschrift3.copyWith(
            color: AppFarben.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Was gibst du der nächsten Seele mit?',
          textAlign: TextAlign.center,
          style: AppTextStyles.koerperKlein.copyWith(
            color: AppFarben.textSekundaer,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _vermaechtnisController,
          maxLength: 80,
          maxLines: 3,
          style: const TextStyle(
            fontFamily: 'Cinzel',
            color: AppFarben.goldGlanz,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
          cursorColor: AppFarben.goldGlanz,
          decoration: InputDecoration(
            hintText: 'z.B. Vertraue dir selbst...',
            hintStyle: TextStyle(
              fontFamily: 'Cinzel',
              color: AppFarben.goldGlanz.withValues(alpha: 0.35),
              fontSize: 15,
            ),
            counterStyle: const TextStyle(color: AppFarben.textSekundaer),
            filled: true,
            fillColor: AppFarben.oberflaeche.withValues(alpha: 0.6),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppFarben.goldGlanz.withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppFarben.goldGlanz,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  // ── Weiter-/Abschluss-Button ──────────────────────────────────────────────

  Widget _baueWeiterButton() {
    // Schritt darf erst beendet werden, wenn eine Wahl getroffen wurde.
    final bool freigegeben;
    switch (_schritt) {
      case 0:
        freigegeben = _gewaehlteWelt >= 0;
        break;
      case 1:
        freigegeben = _gewaehltesGesetz >= 0;
        break;
      default:
        freigegeben = true;
    }

    final letzterSchritt = _schritt == 2;

    return ElevatedButton(
      onPressed: freigegeben ? _weiter : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppFarben.goldGlanz,
        foregroundColor: AppFarben.kosmischSchwarz,
        disabledBackgroundColor: AppFarben.textDeaktiviert,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        letzterSchritt ? 'DER KREISLAUF SCHLIESST SICH' : 'WEITER',
        style: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

/// Eine Schöpfungs-Option (Welt oder Gesetz).
class _Wahl {
  final String name;
  final IconData icon;
  final String beschreibung;

  const _Wahl(this.name, this.icon, this.beschreibung);
}

/// Zeichnet eine langsam rotierende Spiralgalaxie.
class _GalaxiePainter extends CustomPainter {
  final double rotation;

  _GalaxiePainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final basisWinkel = rotation * math.pi * 2;
    final maxRadius = size.shortestSide * 0.55;

    // Leuchtender Kern.
    final kern = Paint()
      ..shader = RadialGradient(
        colors: [
          AppFarben.goldGlanz.withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: maxRadius * 0.4),
      );
    canvas.drawCircle(center, maxRadius * 0.4, kern);

    // Drei Spiralarme aus vielen kleinen Sternpunkten.
    const arme = 3;
    const punkteProArm = 90;
    for (var arm = 0; arm < arme; arm++) {
      final armVersatz = (arm / arme) * math.pi * 2;
      for (var i = 0; i < punkteProArm; i++) {
        final t = i / punkteProArm;
        final radius = t * maxRadius;
        // Logarithmische Spirale.
        final winkel = basisWinkel + armVersatz + t * 5.0;
        final pos = Offset(
          center.dx + math.cos(winkel) * radius,
          center.dy + math.sin(winkel) * radius,
        );
        final alpha = (1 - t) * 0.8;
        final farbe = Color.lerp(
          AppFarben.goldGlanz,
          AppFarben.mystischLila,
          t,
        )!;
        final paint = Paint()
          ..color = farbe.withValues(alpha: alpha.clamp(0.0, 1.0));
        canvas.drawCircle(pos, 1.5 + (1 - t) * 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxiePainter old) =>
      old.rotation != rotation;
}
