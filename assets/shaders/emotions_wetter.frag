#include <flutter/runtime_effect.glsl>

// ─────────────────────────────────────────────────────────────────────────────
// GENESIS: Der Kreislauf des Lebens – Emotions-Wetter Fragment Shader
// Erzeugt eine dynamische atmosphärische Überlagerung basierend auf dem
// emotionalen Zustand des Charakters. Alle Parameter werden per Uniform
// vom Dart-Code (ShaderWetterWidget) zur Laufzeit übergeben.
// ─────────────────────────────────────────────────────────────────────────────

// Uniforms vom Dart-Code übergeben
uniform float uTime;           // Verstrichene Zeit in Sekunden (für Animationen)
uniform vec2  uResolution;     // Bildschirmauflösung in Pixeln (Breite, Höhe)
uniform vec4  uHauptfarbe;     // RGBA der dominanten Emotions-Farbe
uniform vec4  uNebenfarbe;     // RGBA der sekundären Akzentfarbe
uniform float uIntensitaet;    // Gesamtstärke des Effekts (0.0 bis 1.0)
uniform float uPartikelDichte; // Anzahl-Faktor der Partikel (0.0 bis 1.0)
uniform float uWindStaerke;    // Seitliche Verschiebung der Partikel (0.0 bis 1.0)
uniform float uBlitz;          // Gewitter-Blitz aktiv: 1.0 = ja, 0.0 = nein
uniform float uLeuchtRadius;   // Radius des kosmischen Leuchtens (in UV-Einheiten, 0.0 = aus)

// Ausgabe-Farbe des Fragments
out vec4 fragColor;

// ─────────────────────────────────────────────────────────────────────────────
// Hilfsfunktionen
// ─────────────────────────────────────────────────────────────────────────────

/// Pseudo-Zufallszahl aus 2D-Koordinaten.
/// Wird für positions- und zeitbasierte Variation der Partikel verwendet.
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

/// Glatter Rausch-Wert für organische, nicht-lineare Bewegungen.
/// Interpoliert zwischen vier Gitterpunkten mittels Smoothstep.
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Vier Eckpunkte des Gitterzelle
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Kubische Hermite-Interpolation (Smoothstep)
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x)
         + (c - a) * u.y * (1.0 - u.x)
         + (d - b) * u.x * u.y;
}

// ─────────────────────────────────────────────────────────────────────────────
// Haupt-Shader
// ─────────────────────────────────────────────────────────────────────────────

void main() {
    // UV-Koordinaten normieren (0.0 links-oben bis 1.0 rechts-unten)
    vec2 uv = FlutterFragCoord().xy / uResolution;

    // Akkumulierter Farbwert für dieses Fragment
    vec4 col = vec4(0.0);

    // ── 1. Basis-Atmosphäre ───────────────────────────────────────────────────
    // Vertikaler Gradient: Hauptfarbe unten stark, oben transparent.
    // Erzeugt eine bodennahe emotionale Einfärbung der Szene.
    float atmo = smoothstep(1.0, 0.0, uv.y) * uIntensitaet * 0.4;
    col += uHauptfarbe * atmo;

    // ── 2. Partikel-System ────────────────────────────────────────────────────
    // Bis zu 20 Partikel fallen/schweben je nach Wetterzustand.
    // Wind schiebt Partikel seitwärts, Fallgeschwindigkeit variiert.
    float partikelAnzahl = floor(uPartikelDichte * 20.0);

    for (float i = 0.0; i < 20.0; i++) {
        // Schleife nur bis zur berechneten Partikelanzahl
        if (i >= partikelAnzahl) break;

        // Einzigartiger zufälliger Versatz pro Partikel
        float offset = random(vec2(i, 0.0));

        // Partikelposition animiert:
        // X: horizontale Drift durch Wind + individueller Versatz
        // Y: Fallen von oben nach unten mit partikelspezifischer Geschwindigkeit
        vec2 pos = vec2(
            fract(offset + uTime * 0.05 * uWindStaerke),
            fract(offset * 2.3 + uTime * (0.1 + offset * 0.1))
        );

        // Abstand vom aktuellen Fragment zum Partikel-Mittelpunkt
        float dist = length(uv - pos);

        // Weiches Partikel-Licht (Kreis mit Smoothstep-Rand)
        float partikel = smoothstep(0.015, 0.0, dist);
        col += uNebenfarbe * partikel * 0.8;
    }

    // ── 3. Kosmisches Leuchten ────────────────────────────────────────────────
    // Radialer Glow von der Bildschirmmitte für spirituelle/transzendente Zustände.
    // Aktiv wenn uLeuchtRadius > 0.0 (z. B. bei EmotionsWetterTyp.kosmisch).
    if (uLeuchtRadius > 0.0) {
        // Abstand vom Bildschirmzentrum (UV-Raum, daher 0.5/0.5)
        float distMitte = length(uv - vec2(0.5, 0.5));

        // Sanfter Glow-Kreis: volle Intensität im Zentrum, Null am Rand
        float glow = smoothstep(uLeuchtRadius, 0.0, distMitte) * uIntensitaet;
        col += uHauptfarbe * glow * 0.5;
    }

    // ── 4. Gewitter-Blitz ─────────────────────────────────────────────────────
    // Horizontale helle Linie, die bei Gewitterzustand kurz aufleuchtet.
    // uBlitz = 1.0 aktiviert den Blitz, uTime steuert die Blitz-Position.
    if (uBlitz > 0.5) {
        // Zufällige vertikale Blitzposition (wechselt ~3× pro Sekunde)
        float blitzY = random(vec2(floor(uTime * 3.0), 1.0));

        // Sehr dünne horizontale Linie am Blitz-Y-Wert
        float blitzLinie = smoothstep(0.003, 0.0, abs(uv.y - blitzY));

        // Weiß-Gelbliche Blitzfarbe mit voller Opazität
        col += vec4(1.0, 1.0, 0.9, 1.0) * blitzLinie * uBlitz;
    }

    // ── 5. Organisches Rauschen ───────────────────────────────────────────────
    // Fügt leichtes Rauschen auf die Hauptfarbe auf, damit der Atmosphäreneffekt
    // nicht zu gleichmäßig wirkt – erzeugt einen lebendigen, wolkigen Look.
    float rauschen = noise(uv * 4.0 + uTime * 0.1) * 0.08 * uIntensitaet;
    col.rgb += uHauptfarbe.rgb * rauschen;

    // ── 6. Alpha begrenzen ────────────────────────────────────────────────────
    // Das Overlay bleibt unter 0.7 Opazität, damit der Spielinhalt darunter
    // stets sichtbar und lesbar bleibt.
    col.a = min(col.a + atmo * 0.5, 0.7);

    fragColor = col;
}
