#include <flutter/runtime_effect.glsl>

// ─────────────────────────────────────────────────────────────────────────────
// GENESIS: Der Kreislauf des Lebens – Tunnel-Rennen Fragment Shader
// Erzeugt den pulsierenden biologischen Tunnel für das Spermium-Rennen (Phase 1).
// Simuliert organische Tunnel-Wände mit Peristaltik-Bewegung.
// ─────────────────────────────────────────────────────────────────────────────

uniform float uTime;           // Verstrichene Zeit in Sekunden
uniform vec2  uResolution;     // Bildschirmauflösung
uniform float uGeschwindigkeit; // Scroll-Geschwindigkeit (0.0–3.0)
uniform float uDistanz;        // Zurückgelegte Distanz (0.0–1.0)
uniform vec3  uTunnelFarbe;    // RGB-Farbe der Tunnel-Wände
uniform float uPulsStaerke;    // Stärke der Peristaltik-Bewegung (0.0–1.0)

out vec4 fragColor;

// ─────────────────────────────────────────────────────────────────────────────
// Hilfsfunktionen
// ─────────────────────────────────────────────────────────────────────────────

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tunnel-Profil: gibt die Tunnelbreite an einer Y-Position zurück
// ─────────────────────────────────────────────────────────────────────────────

float tunnelProfil(float y, float zeit) {
    // Peristaltische Wellen-Bewegung der Tunnel-Wände
    float welle1 = sin(y * 3.0 + zeit * uGeschwindigkeit) * 0.08;
    float welle2 = sin(y * 7.0 + zeit * uGeschwindigkeit * 1.5 + 1.2) * 0.04;
    float puls   = sin(zeit * 2.0) * uPulsStaerke * 0.05;
    return 0.35 + welle1 + welle2 + puls;
}

// ─────────────────────────────────────────────────────────────────────────────
// Haupt-Shader
// ─────────────────────────────────────────────────────────────────────────────

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;

    // Koordinaten zentrieren (0.5, 0.5 = Mitte)
    vec2 zentriert = uv - vec2(0.5, 0.5);

    // Aspect-Ratio ausgleichen
    float aspekt = uResolution.x / uResolution.y;
    zentriert.x *= aspekt;

    // ── 1. Tunnel-Wände ───────────────────────────────────────────────────────
    // Die Tunnel-Breite variiert je nach Y-Position (Peristaltik)
    float tunnelBreite = tunnelProfil(uv.y * 5.0, uTime);

    // Abstand vom Zentrum (nur horizontal)
    float abstandVomZentrum = abs(zentriert.x / aspekt);

    // Wanddicke mit weichem Rand
    float wandFaktor = smoothstep(tunnelBreite - 0.02, tunnelBreite, abstandVomZentrum);

    // ── 2. Organische Wandtextur ──────────────────────────────────────────────
    // Biologische Textur: Kapillarmuster, Gewebefasern
    float textur = noise(uv * 8.0 + vec2(uTime * 0.1, uTime * uGeschwindigkeit * 0.3));
    textur += noise(uv * 16.0 + vec2(uTime * 0.15, uTime * uGeschwindigkeit * 0.5)) * 0.5;
    textur /= 1.5;

    // ── 3. Tiefenwirkung durch Scrolling ─────────────────────────────────────
    // Streifen im Hintergrund erzeugen Bewegungsgefühl
    float streifen = fract(uv.y * 20.0 - uTime * uGeschwindigkeit * 2.0);
    float streifenGlow = smoothstep(0.95, 1.0, streifen) * 0.15;

    // ── 4. Biolumineszenz-Effekt ──────────────────────────────────────────────
    // Leuchtende Punkte an den Wänden wie Biolumineszenz
    float bio = noise(uv * 25.0 + vec2(0.0, uTime * 0.2));
    float bioGlow = pow(bio, 8.0) * wandFaktor;

    // ── 5. Farbe zusammensetzen ───────────────────────────────────────────────
    vec3 tunnelWandFarbe = uTunnelFarbe * textur;
    vec3 hintergrundFarbe = vec3(0.05, 0.02, 0.08); // Dunkles Magenta/Schwarz

    // Tunnel-Inneres (klarer, heller) vs. Außen (dunkle Wände)
    vec3 innenFarbe = hintergrundFarbe + vec3(streifenGlow * 0.5, streifenGlow * 0.3, streifenGlow);

    // Wand-Bereich
    vec3 wandFarbe = mix(tunnelWandFarbe * 0.7, tunnelWandFarbe, textur);
    wandFarbe += vec3(bioGlow * 0.3, bioGlow * 0.6, bioGlow); // Biolumineszenz

    // Endmischung: innen → Wand
    vec3 finalFarbe = mix(innenFarbe, wandFarbe, wandFaktor);

    // ── 6. Distanz-Effekt ─────────────────────────────────────────────────────
    // Je näher am Ziel, desto heller wird der Tunnel (Licht am Ende)
    float lichtAmEnde = uDistanz * 0.3;
    finalFarbe += vec3(lichtAmEnde * 0.8, lichtAmEnde * 0.6, lichtAmEnde * 0.4);

    // ── 7. Vignetteneffekt ────────────────────────────────────────────────────
    float vignette = 1.0 - length(zentriert) * 0.5;
    finalFarbe *= clamp(vignette, 0.0, 1.0);

    fragColor = vec4(finalFarbe, 1.0);
}
