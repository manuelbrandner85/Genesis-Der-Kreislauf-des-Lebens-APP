// neues_spiel_screen.dart
// Neues-Spiel-Screen für GENESIS: Der Kreislauf des Lebens.
// Führt den Spieler durch einen 3-Schritt-Wizard:
// Schritt 1: Name eingeben
// Schritt 2: Zeitalter wählen
// Schritt 3: Bestätigung und Seelen-Code-Anzeige

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis_kreislauf_des_lebens/app/router.dart';
import 'package:genesis_kreislauf_des_lebens/core/constants/app_konstanten.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_farben.dart';
import 'package:genesis_kreislauf_des_lebens/core/theme/app_text_styles.dart';
import 'package:genesis_kreislauf_des_lebens/data/models/zyklus_model.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/providers/spiel_provider.dart';
import 'package:genesis_kreislauf_des_lebens/presentation/widgets/phasen_hintergrund.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Datenmodell: Zeitalter
// ─────────────────────────────────────────────────────────────────────────────

/// Repräsentiert ein auswählbares historisches Zeitalter.
class _Zeitalter {
  final String id;
  final String name;
  final String zeitraum;
  final String beschreibung;
  final IconData icon;
  final Color farbe;

  const _Zeitalter({
    required this.id,
    required this.name,
    required this.zeitraum,
    required this.beschreibung,
    required this.icon,
    required this.farbe,
  });
}

/// Liste aller 5 spielbaren Zeitalter.
const List<_Zeitalter> _alleZeitalter = [
  _Zeitalter(
    id: 'mittelalter',
    name: 'Mittelalter',
    zeitraum: '500 – 1400 n.Chr.',
    beschreibung:
        'Glaube und Ordnung prägen alles Leben. Ritter, Priester und Händler kämpfen um Einfluss. Die Kirche hält die Welt zusammen.',
    icon: Icons.shield,
    farbe: Color(0xFF8B6914),
  ),
  _Zeitalter(
    id: 'renaissance',
    name: 'Renaissance',
    zeitraum: '1400 – 1600 n.Chr.',
    beschreibung:
        'Kunst, Wissenschaft und Humanismus erwachen. Florenz leuchtet. Machiavelli schreibt. Die Welt beginnt, sich selbst neu zu erfinden.',
    icon: Icons.palette,
    farbe: Color(0xFF8B3A8B),
  ),
  _Zeitalter(
    id: 'industriezeitalter',
    name: 'Industriezeitalter',
    zeitraum: '1760 – 1900 n.Chr.',
    beschreibung:
        'Dampfmaschinen verändern die Welt. Arbeiter und Kapitalisten kämpfen um Macht. Fortschritt hat seinen Preis.',
    icon: Icons.factory,
    farbe: Color(0xFF3A5F8B),
  ),
  _Zeitalter(
    id: 'moderne',
    name: 'Moderne',
    zeitraum: '1900 – 2000 n.Chr.',
    beschreibung:
        'Weltkriege, Ideologien und technologischer Wandel. Das Individuum sucht seinen Platz in einer zerrissenen Welt.',
    icon: Icons.location_city,
    farbe: Color(0xFF3A8B5F),
  ),
  _Zeitalter(
    id: 'zukunft',
    name: 'Zukunft',
    zeitraum: '2100 – 2300 n.Chr.',
    beschreibung:
        'Künstliche Intelligenz, Kolonialisierung des Weltraums, und die Frage: Was bedeutet es noch, Mensch zu sein?',
    icon: Icons.rocket_launch,
    farbe: Color(0xFF4B3A8B),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Neues-Spiel-Screen
// ─────────────────────────────────────────────────────────────────────────────

/// 3-Schritt-Wizard für das Starten eines neuen Lebens.
class NeuesSpielScreen extends ConsumerStatefulWidget {
  const NeuesSpielScreen({super.key});

  @override
  ConsumerState<NeuesSpielScreen> createState() => _NeuesSpielScreenState();
}

class _NeuesSpielScreenState extends ConsumerState<NeuesSpielScreen>
    with TickerProviderStateMixin {
  // ── Wizard-Zustand ─────────────────────────────────────────────────────────
  int _aktuellerSchritt = 1; // 1, 2 oder 3
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  String _gewaehlterZeitalterID = '';
  String _seelenCode = '';

  /// Verhindert Doppel-Starts, während das Profil angelegt wird.
  bool _startetSpiel = false;

  // Animation für Schrittübergänge
  late final AnimationController _uebergangController;

  @override
  void initState() {
    super.initState();
    _uebergangController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _uebergangController.dispose();
    super.dispose();
  }

  // ── Seelen-Code generieren ─────────────────────────────────────────────────

  /// Generiert einen zufälligen 6-stelligen hexadezimalen Seelen-Code.
  String _generiereSeelenCode() {
    final rng = math.Random();
    const zeichen = '0123456789ABCDEF';
    return List.generate(6, (_) => zeichen[rng.nextInt(zeichen.length)]).join();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _weiter() {
    if (_aktuellerSchritt == 1) {
      if (_nameController.text.trim().isEmpty) {
        _zeigeFehler('Bitte gib einen Namen ein.');
        return;
      }
    } else if (_aktuellerSchritt == 2) {
      if (_gewaehlterZeitalterID.isEmpty) {
        _zeigeFehler('Bitte wähle ein Zeitalter.');
        return;
      }
      // Seelen-Code erst beim Übergang zu Schritt 3 generieren
      _seelenCode = _generiereSeelenCode();
    }

    if (_aktuellerSchritt < 3) {
      _uebergangController.forward(from: 0);
      setState(() => _aktuellerSchritt++);
    }
  }

  void _zurueck() {
    if (_aktuellerSchritt > 1) {
      _uebergangController.forward(from: 0);
      setState(() => _aktuellerSchritt--);
    } else {
      context.go(AppRouten.hauptMenue);
    }
  }

  /// Legt das Spielerprofil samt erstem Lebenszyklus an und startet Phase 1.
  ///
  /// Vorher wurde hier nur navigiert, ohne Name und Zeitalter zu speichern –
  /// alle nachfolgenden Screens liefen dadurch ohne Profil ins Leere.
  Future<void> _spielStarten() async {
    if (_startetSpiel) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _aktuellerSchritt = 1);
      _zeigeFehler('Bitte gib einen Namen ein.');
      return;
    }

    // Lokale Zeitalter-ID auf das Domänen-Enum abbilden
    final zeitalter = Zeitalter.values.firstWhere(
      (z) => z.name == _gewaehlterZeitalterID,
      orElse: () => Zeitalter.moderne,
    );

    setState(() => _startetSpiel = true);
    HapticFeedback.mediumImpact();

    await ref.read(spielProvider.notifier).neuesSpielStarten(name, zeitalter);

    if (!mounted) return;

    final fehler = ref.read(spielProvider).fehlerMeldung;
    if (fehler != null) {
      setState(() => _startetSpiel = false);
      _zeigeFehler(fehler);
      return;
    }

    context.go(AppRouten.phase1);
  }

  void _zeigeFehler(String nachricht) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nachricht,
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

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFarben.kosmischSchwarz,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PhasenHintergrund(
            phase: GamePhase.kosmisch,
            abdunkelung: 0.6,
          ),
          Container(
            // Halbtransparente Färbung, damit das Kosmos-Artwork sichtbar bleibt
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.4,
                colors: [
                  AppFarben.kosmischViolett.withValues(alpha: 0.35),
                  AppFarben.kosmischSchwarz.withValues(alpha: 0.55),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ── Kopfzeile ────────────────────────────────────────────────
                  _Kopfzeile(
                    aktuellerSchritt: _aktuellerSchritt,
                    onZurueck: _zurueck,
                  ),

                  const SizedBox(height: 8),

                  // ── Fortschrittsanzeige ──────────────────────────────────────
                  _Fortschrittsanzeige(aktuellerSchritt: _aktuellerSchritt),

                  const SizedBox(height: 24),

                  // ── Schrittinhalt ────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _schrittWidget(),
                      ),
                    ),
                  ),

                  // ── Navigations-Buttons ──────────────────────────────────────
                  _NavigationsButtons(
                    aktuellerSchritt: _aktuellerSchritt,
                    onWeiter: _weiter,
                    onZurueck: _zurueck,
                    onStart: _spielStarten,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gibt das Widget für den aktuellen Wizard-Schritt zurück.
  Widget _schrittWidget() {
    switch (_aktuellerSchritt) {
      case 1:
        return _Schritt1Name(
          key: const ValueKey(1),
          controller: _nameController,
          focusNode: _nameFocusNode,
          onFertig: _weiter,
        );
      case 2:
        return _Schritt2Zeitalter(
          key: const ValueKey(2),
          gewaehlterID: _gewaehlterZeitalterID,
          onAusgewaehlt: (id) =>
              setState(() => _gewaehlterZeitalterID = id),
        );
      case 3:
        return _Schritt3Bestaetigung(
          key: const ValueKey(3),
          name: _nameController.text.trim(),
          zeitalterID: _gewaehlterZeitalterID,
          seelenCode: _seelenCode,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kopfzeile
// ─────────────────────────────────────────────────────────────────────────────

class _Kopfzeile extends StatelessWidget {
  final int aktuellerSchritt;
  final VoidCallback onZurueck;

  const _Kopfzeile({
    required this.aktuellerSchritt,
    required this.onZurueck,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Zurück-Button
          IconButton(
            onPressed: onZurueck,
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: AppFarben.goldGlanz,
            tooltip: 'Zurück',
          ),

          const Spacer(),

          // Titel
          Text(
            'Neues Leben',
            style: AppTextStyles.ueberschrift3.copyWith(
              color: AppFarben.goldGlanz,
              fontSize: 18,
            ),
          ),

          const Spacer(),

          // Schrittanzeige
          Text(
            '$aktuellerSchritt / 3',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.textSekundaer,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fortschrittsanzeige
// ─────────────────────────────────────────────────────────────────────────────

class _Fortschrittsanzeige extends StatelessWidget {
  final int aktuellerSchritt;

  const _Fortschrittsanzeige({required this.aktuellerSchritt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: List.generate(3, (index) {
          final schritt = index + 1;
          final istAktiv = schritt == aktuellerSchritt;
          final istAbgeschlossen = schritt < aktuellerSchritt;

          return Expanded(
            child: Row(
              children: [
                // Schrittkreis
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: istAbgeschlossen
                        ? AppFarben.karmaPositiv
                        : (istAktiv
                            ? AppFarben.goldGlanz
                            : AppFarben.nebelGrau.withValues(alpha: 0.4)),
                    border: Border.all(
                      color: istAktiv
                          ? AppFarben.goldGlanz
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: istAktiv
                        ? [
                            BoxShadow(
                              color: AppFarben.goldGlanz.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: istAbgeschlossen
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '$schritt',
                            style: AppTextStyles.beschriftung.copyWith(
                              color: istAktiv
                                  ? AppFarben.kosmischSchwarz
                                  : AppFarben.textSekundaer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                // Verbindungslinie (nicht nach dem letzten Schritt)
                if (index < 2)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 2,
                      color: istAbgeschlossen
                          ? AppFarben.karmaPositiv.withValues(alpha: 0.6)
                          : AppFarben.nebelGrau.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schritt 1: Name eingeben
// ─────────────────────────────────────────────────────────────────────────────

class _Schritt1Name extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  /// Wird bei Enter/Fertig auf der Tastatur aufgerufen (weiter zu Schritt 2).
  final VoidCallback? onFertig;

  const _Schritt1Name({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onFertig,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Schritt-Titel
        Text(
          'Wer bist du?',
          style: AppTextStyles.ueberschrift2.copyWith(fontSize: 28),
        )
            .animate()
            .fadeIn(duration: 500.ms),

        const SizedBox(height: 8),

        Text(
          'Gib deiner Seele einen Namen. Dieser Name begleitet dich durch alle Zyklen.',
          style: AppTextStyles.koerperKlein,
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 100.ms),

        const SizedBox(height: 40),

        // Name-Eingabefeld
        Text(
          'DEIN NAME',
          style: AppTextStyles.beschriftungGross.copyWith(
            color: AppFarben.goldDunkel,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLength: 24,
          style: AppTextStyles.ueberschrift3.copyWith(
            color: AppFarben.text,
            fontSize: 22,
          ),
          decoration: InputDecoration(
            hintText: 'z.B. Maximilian',
            hintStyle: AppTextStyles.ueberschrift3.copyWith(
              color: AppFarben.textTertiaer,
              fontSize: 22,
            ),
            counterStyle: AppTextStyles.beschriftung.copyWith(
              color: AppFarben.textTertiaer,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppFarben.goldDunkel,
                width: 1.5,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppFarben.goldGlanz,
                width: 2,
              ),
            ),
            filled: false,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(24),
          ],
          textCapitalization: TextCapitalization.words,
          // Tastatur öffnet sich sofort – kein zusätzlicher Tipp nötig
          autofocus: true,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.done,
          onSubmitted: onFertig == null ? null : (_) => onFertig!(),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.1, end: 0, duration: 350.ms),

        const SizedBox(height: 48),

        // Hinweis-Text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppFarben.kosmischViolett.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppFarben.goldGlanz.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppFarben.goldGlanz,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Dieser Name wird in der Seelenbibliothek gespeichert und begleitet alle deine zukünftigen Inkarnationen.',
                  style: AppTextStyles.koerperKlein.copyWith(
                    color: AppFarben.textSekundaer,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 400.ms),

        const SizedBox(height: 40),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schritt 2: Zeitalter wählen
// ─────────────────────────────────────────────────────────────────────────────

class _Schritt2Zeitalter extends StatelessWidget {
  final String gewaehlterID;
  final ValueChanged<String> onAusgewaehlt;

  const _Schritt2Zeitalter({
    super.key,
    required this.gewaehlterID,
    required this.onAusgewaehlt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        Text(
          'Wähle dein Zeitalter',
          style: AppTextStyles.ueberschrift2.copyWith(fontSize: 26),
        )
            .animate()
            .fadeIn(duration: 500.ms),

        const SizedBox(height: 8),

        Text(
          'Das Zeitalter bestimmt deine Welt, deine Möglichkeiten und die Herausforderungen deines Lebens.',
          style: AppTextStyles.koerperKlein,
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 100.ms),

        const SizedBox(height: 24),

        // Zeitalter-Karten
        ...List.generate(_alleZeitalter.length, (index) {
          final zeitalter = _alleZeitalter[index];
          final istGewaehlt = gewaehlterID == zeitalter.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ZeitalterKarte(
              zeitalter: zeitalter,
              istGewaehlt: istGewaehlt,
              onTap: () => onAusgewaehlt(zeitalter.id),
            )
                .animate(delay: Duration(milliseconds: 80 * index))
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.05, end: 0, duration: 350.ms),
          );
        }),

        const SizedBox(height: 24),
      ],
    );
  }
}

/// Eine einzelne Zeitalter-Karte in der Auswahlliste.
class _ZeitalterKarte extends StatelessWidget {
  final _Zeitalter zeitalter;
  final bool istGewaehlt;
  final VoidCallback onTap;

  const _ZeitalterKarte({
    required this.zeitalter,
    required this.istGewaehlt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: istGewaehlt
              ? zeitalter.farbe.withValues(alpha: 0.15)
              : AppFarben.oberflaeche,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: istGewaehlt
                ? zeitalter.farbe.withValues(alpha: 0.8)
                : AppFarben.trenner,
            width: istGewaehlt ? 2 : 1,
          ),
          boxShadow: istGewaehlt
              ? [
                  BoxShadow(
                    color: zeitalter.farbe.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon mit Kreis-Hintergrund
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: zeitalter.farbe.withValues(
                  alpha: istGewaehlt ? 0.3 : 0.15,
                ),
              ),
              child: Icon(
                zeitalter.icon,
                color: istGewaehlt ? zeitalter.farbe : AppFarben.textSekundaer,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zeitalter-Name
                  Row(
                    children: [
                      Text(
                        zeitalter.name,
                        style: AppTextStyles.koerperKleinFett.copyWith(
                          color: istGewaehlt
                              ? zeitalter.farbe
                              : AppFarben.text,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        zeitalter.zeitraum,
                        style: AppTextStyles.beschriftung.copyWith(
                          color: AppFarben.textTertiaer,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Beschreibung
                  Text(
                    zeitalter.beschreibung,
                    style: AppTextStyles.beschriftung.copyWith(
                      color: istGewaehlt
                          ? AppFarben.textSekundaer
                          : AppFarben.textTertiaer,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Auswahl-Indikator
            if (istGewaehlt)
              Icon(
                Icons.check_circle,
                color: zeitalter.farbe,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schritt 3: Bestätigung & Seelen-Code
// ─────────────────────────────────────────────────────────────────────────────

class _Schritt3Bestaetigung extends StatelessWidget {
  final String name;
  final String zeitalterID;
  final String seelenCode;

  const _Schritt3Bestaetigung({
    super.key,
    required this.name,
    required this.zeitalterID,
    required this.seelenCode,
  });

  /// Gibt den Zeitalter-Namen für eine ID zurück.
  String _zeitalterName() {
    return _alleZeitalter
        .firstWhere(
          (z) => z.id == zeitalterID,
          orElse: () => _alleZeitalter.first,
        )
        .name;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),

        // Kosmisches Symbol
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppFarben.goldGlanz.withValues(alpha: 0.6),
              width: 2,
            ),
            gradient: RadialGradient(
              colors: [
                AppFarben.goldGlanz.withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
          child: const Icon(
            Icons.all_inclusive,
            color: AppFarben.goldGlanz,
            size: 40,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.7, 0.7), duration: 500.ms),

        const SizedBox(height: 24),

        Text(
          'Deine Seele ist bereit',
          style: AppTextStyles.ueberschrift2.copyWith(fontSize: 24),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 200.ms),

        const SizedBox(height: 8),

        Text(
          'Überprüfe deine Auswahl und beginne dein Leben.',
          style: AppTextStyles.koerperKlein,
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 300.ms),

        const SizedBox(height: 32),

        // Seelen-Code (das Herzstück)
        _SeelenCodeAnzeige(seelenCode: seelenCode),

        const SizedBox(height: 32),

        // Zusammenfassung in einer Karte
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppFarben.oberflaeche,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppFarben.goldGlanz.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _ZusammenfassungsZeile(
                label: 'NAME',
                wert: name.isEmpty ? '(Kein Name)' : name,
                icon: Icons.person_outline,
              ),
              const Divider(color: AppFarben.trenner, height: 24),
              _ZusammenfassungsZeile(
                label: 'ZEITALTER',
                wert: _zeitalterName(),
                icon: Icons.history_edu,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 600.ms),

        const SizedBox(height: 32),

        Text(
          '"Jedes Leben ist eine einzigartige Chance,\ndie Seele zu formen."',
          style: AppTextStyles.zitat.copyWith(
            color: AppFarben.textTertiaer,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 800.ms),

        const SizedBox(height: 40),
      ],
    );
  }
}

/// Zeigt den generierten Seelen-Code prominent an.
class _SeelenCodeAnzeige extends StatelessWidget {
  final String seelenCode;

  const _SeelenCodeAnzeige({required this.seelenCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppFarben.goldGlanz.withValues(alpha: 0.12),
            AppFarben.kosmischViolett.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppFarben.goldGlanz.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppFarben.goldGlanz.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'SEELEN-CODE',
            style: AppTextStyles.beschriftungGross.copyWith(
              color: AppFarben.goldDunkel,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            seelenCode,
            style: AppTextStyles.spielStatusWert.copyWith(
              fontSize: 36,
              letterSpacing: 8,
              shadows: [
                Shadow(
                  color: AppFarben.goldGlanz.withValues(alpha: 0.6),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Einzigartiger Identifikator deiner Seele',
            style: AppTextStyles.beschriftung.copyWith(
              color: AppFarben.textTertiaer,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 500.ms);
  }
}

/// Eine Zeile in der Zusammenfassungs-Karte.
class _ZusammenfassungsZeile extends StatelessWidget {
  final String label;
  final String wert;
  final IconData icon;

  const _ZusammenfassungsZeile({
    required this.label,
    required this.wert,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppFarben.goldGlanz, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.beschriftungGross.copyWith(
                color: AppFarben.textTertiaer,
              ),
            ),
            Text(
              wert,
              style: AppTextStyles.koerperKleinFett.copyWith(
                color: AppFarben.text,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigations-Buttons
// ─────────────────────────────────────────────────────────────────────────────

/// Zeigt "Zurück"- und "Weiter"/"Das Leben beginnt..."-Buttons.
class _NavigationsButtons extends StatelessWidget {
  final int aktuellerSchritt;
  final VoidCallback onWeiter;
  final VoidCallback onZurueck;
  final VoidCallback onStart;

  const _NavigationsButtons({
    required this.aktuellerSchritt,
    required this.onWeiter,
    required this.onZurueck,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          // Zurück-Button (sekundär)
          if (aktuellerSchritt > 1)
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: onZurueck,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppFarben.textSekundaer,
                  side: const BorderSide(
                    color: AppFarben.nebelGrau,
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'Zurück',
                  style: AppTextStyles.buttonSekundaer.copyWith(
                    color: AppFarben.textSekundaer,
                  ),
                ),
              ),
            ),

          if (aktuellerSchritt > 1) const SizedBox(width: 12),

          // Weiter / Start-Button (primär)
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: aktuellerSchritt < 3 ? onWeiter : onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppFarben.goldGlanz,
                foregroundColor: AppFarben.kosmischSchwarz,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: Text(
                aktuellerSchritt < 3 ? 'Weiter' : 'Das Leben beginnt...',
                style: AppTextStyles.buttonPrimaer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
