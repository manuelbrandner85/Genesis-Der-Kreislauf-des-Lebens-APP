#include <flutter/runtime_effect.glsl>

// ─────────────────────────────────────────────────────────────────────────────
// GENESIS: Der Kreislauf des Lebens – Karma-Glow Fragment Shader
// Erzeugt ein auraartig leuchtendes Karma-Profil um Charakter-Widgets.
// Sechs Dimensionen strahlen gleichzeitig und überlagern sich.
// ─────────────────────────────────────────────────────────────────────────────

uniform float uTime;           // Verstrichene Zeit in Sekunden
uniform vec2  uResolution;     // Bildschirmauflösung
uniform float uMitgefuehl;     // -100 bis +100
uniform float uEhrlichkeit;    // -100 bis +100
uniform float uMut;            // -100 bis +100
uniform float uGrosszuegigkeit;// -100 bis +100
uniform float uWeisheit;       // -100 bis +100
uniform float uLiebe;          // -100 bis +100
uniform float uIntensitaet;    // Gesamt-Effektstärke (0.0–1.0)

out vec4 fragColor;

// ─────────────────────────────────────────────────────────────────────────────
// Karma-Farben pro Dimension
// ─────────────────────────────────────────────────────────────────────────────

vec3 dimensionFarbe(float wert, vec3 positivFarbe, vec3 negativFarbe) {
    float t = (wert + 100.0) / 200.0; // 0.0 (negativ) bis 1.0 (positiv)
    return mix(negativFarbe, positivFarbe, t);
}

// ─────────────────────────────────────────────────────────────────────────────
// Glow-Ring um die Bildschirmmitte
// ─────────────────────────────────────────────────────────────────────────────

float glowRing(vec2 uv, vec2 mitte, float radius, float breite) {
    float dist = length(uv - mitte);
    return smoothstep(radius + breite, radius, dist) *
           smoothstep(radius - breite * 2.0, radius, dist);
}

// ─────────────────────────────────────────────────────────────────────────────
// Haupt-Shader
// ─────────────────────────────────────────────────────────────────────────────

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    vec2 mitte = vec2(0.5, 0.5);

    // Aspect-Ratio-korrigierte Koordinaten
    float aspekt = uResolution.x / uResolution.y;
    vec2 uvKorr = vec2((uv.x - 0.5) * aspekt, uv.y - 0.5);

    vec3 gesamtFarbe = vec3(0.0);
    float gesamtAlpha = 0.0;

    // ── Karma-Dimensionen als überlagernde Aura-Ringe ─────────────────────────

    // Mitgefühl: grün ↔ dunkelrot
    float m_norm = (uMitgefuehl + 100.0) / 200.0;
    float m_glow = glowRing(uvKorr, vec2(0.0), 0.40 + sin(uTime * 0.8) * 0.02, 0.06);
    vec3 m_farbe = mix(vec3(0.5, 0.0, 0.0), vec3(0.2, 0.9, 0.4), m_norm);
    gesamtFarbe += m_farbe * m_glow * abs(uMitgefuehl) / 100.0;
    gesamtAlpha = max(gesamtAlpha, m_glow * m_norm * 0.5);

    // Ehrlichkeit: gold ↔ trüb
    float e_norm = (uEhrlichkeit + 100.0) / 200.0;
    float e_glow = glowRing(uvKorr, vec2(0.0), 0.35 + cos(uTime * 0.6 + 1.0) * 0.02, 0.05);
    vec3 e_farbe = mix(vec3(0.3, 0.3, 0.1), vec3(1.0, 0.85, 0.1), e_norm);
    gesamtFarbe += e_farbe * e_glow * abs(uEhrlichkeit) / 100.0;
    gesamtAlpha = max(gesamtAlpha, e_glow * e_norm * 0.4);

    // Mut: orange ↔ blassgrau
    float mu_norm = (uMut + 100.0) / 200.0;
    float mu_glow = glowRing(uvKorr, vec2(0.0), 0.30 + sin(uTime * 1.0 + 2.0) * 0.025, 0.055);
    vec3 mu_farbe = mix(vec3(0.2, 0.2, 0.2), vec3(1.0, 0.5, 0.0), mu_norm);
    gesamtFarbe += mu_farbe * mu_glow * abs(uMut) / 100.0;
    gesamtAlpha = max(gesamtAlpha, mu_glow * mu_norm * 0.45);

    // Großzügigkeit: türkis ↔ dunkelviolett
    float g_norm = (uGrosszuegigkeit + 100.0) / 200.0;
    float g_glow = glowRing(uvKorr, vec2(0.0), 0.45 + cos(uTime * 0.7 + 3.0) * 0.015, 0.065);
    vec3 g_farbe = mix(vec3(0.25, 0.0, 0.35), vec3(0.0, 0.85, 0.85), g_norm);
    gesamtFarbe += g_farbe * g_glow * abs(uGrosszuegigkeit) / 100.0;
    gesamtAlpha = max(gesamtAlpha, g_glow * g_norm * 0.35);

    // Weisheit: hellviolett ↔ dunkelbraun
    float w_norm = (uWeisheit + 100.0) / 200.0;
    float w_glow = glowRing(uvKorr, vec2(0.0), 0.50 + sin(uTime * 0.5 + 4.0) * 0.02, 0.07);
    vec3 w_farbe = mix(vec3(0.3, 0.15, 0.0), vec3(0.7, 0.4, 1.0), w_norm);
    gesamtFarbe += w_farbe * w_glow * abs(uWeisheit) / 100.0;
    gesamtAlpha = max(gesamtAlpha, w_glow * w_norm * 0.4);

    // Liebe: rosarot ↔ kalt blau
    float l_norm = (uLiebe + 100.0) / 200.0;
    float l_glow = glowRing(uvKorr, vec2(0.0), 0.55 + cos(uTime * 0.9 + 5.0) * 0.02, 0.06);
    vec3 l_farbe = mix(vec3(0.0, 0.1, 0.4), vec3(1.0, 0.2, 0.5), l_norm);
    gesamtFarbe += l_farbe * l_glow * abs(uLiebe) / 100.0;
    gesamtAlpha = max(gesamtAlpha, l_glow * l_norm * 0.45);

    // ── Zentrales Leuchten (positives Gesamt-Karma) ───────────────────────────
    float gesamt = (uMitgefuehl + uEhrlichkeit + uMut +
                    uGrosszuegigkeit + uWeisheit + uLiebe) / 6.0;
    float zentralGlow = exp(-length(uvKorr) * 8.0) * max(gesamt, 0.0) / 100.0;
    gesamtFarbe += vec3(1.0, 0.9, 0.7) * zentralGlow * 0.3;

    // ── Intensität und Transparenz ────────────────────────────────────────────
    gesamtAlpha = gesamtAlpha * uIntensitaet;
    gesamtFarbe = gesamtFarbe * uIntensitaet;

    fragColor = vec4(gesamtFarbe, clamp(gesamtAlpha, 0.0, 0.85));
}
