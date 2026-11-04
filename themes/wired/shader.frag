#version 300 es
// Wired: Roehrenmonitor. Feine Scanlines, Phosphor-Leuchten, leichter Farbversatz,
// abgedunkelte Raender. Keine echte Woelbung (Mausklicks blieben sonst nicht deckungsgleich)
// und keine Zeit-Uniform (sonst zeichnet Hyprland dauernd neu).
// Umschalten: Super+Shift+G. In Vollbild-Spielen automatisch aus (hypr/theme.lua).
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float SCANLINE = 0.13;   // Abdunklung jeder 3. Pixelzeile
const float GLOW = 0.22;       // Staerke des Phosphor-Leuchtens
const float ABERRATION = 0.6;  // Farbversatz in Pixeln
const float VIGNETTE = 0.28;   // Abdunklung zu den Ecken

void main() {
    vec2 px = 1.0 / vec2(textureSize(tex, 0));

    // Leichter Farbversatz: Rot nach rechts, Blau nach links
    vec3 col;
    col.r = texture(tex, v_texcoord + vec2(ABERRATION * px.x, 0.0)).r;
    col.g = texture(tex, v_texcoord).g;
    col.b = texture(tex, v_texcoord - vec2(ABERRATION * px.x, 0.0)).b;

    // Phosphor-Leuchten: helle Nachbarn strahlen etwas ueber
    vec3 blur = vec3(0.0);
    blur += texture(tex, v_texcoord + vec2( 2.0,  0.0) * px).rgb;
    blur += texture(tex, v_texcoord + vec2(-2.0,  0.0) * px).rgb;
    blur += texture(tex, v_texcoord + vec2( 0.0,  2.0) * px).rgb;
    blur += texture(tex, v_texcoord + vec2( 0.0, -2.0) * px).rgb;
    blur *= 0.25;
    col += GLOW * max(blur - 0.35, 0.0) * vec3(0.75, 1.0, 0.8);

    // Scanlines
    if (mod(gl_FragCoord.y, 3.0) < 1.0) {
        col *= 1.0 - SCANLINE;
    }

    // Vignette
    vec2 d = v_texcoord - 0.5;
    col *= 1.0 - VIGNETTE * dot(d, d) * 2.2;

    fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
