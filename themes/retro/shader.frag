#version 300 es
// Bernstein-CRT: Roehrenmonitor mit leichtem Bernstein-Stich. Helligkeit wird auf eine
// Bernstein-Rampe abgebildet und nur schwach beigemischt (MIX; 1.0 = rein monochrom,
// wirkt dann wie ein Gelbfilter), dazu dezente Scanlines und Vignette.
// Umschalten: Super+Shift+G. In Vollbild-Spielen automatisch aus (hypr/theme.lua).
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float MIX = 0.12;        // Anteil Bernstein-Monochrom (Rest: Originalfarbe)
const float SCANLINE = 0.10;
const float VIGNETTE = 0.22;

const vec3 DARK  = vec3(0.075, 0.063, 0.043);  // #13100b
const vec3 AMBER = vec3(0.910, 0.639, 0.239);  // #e8a33d
const vec3 HOT   = vec3(1.000, 0.902, 0.700);  // fast weisses Bernstein

void main() {
    vec4 src = texture(tex, v_texcoord);
    float l = dot(src.rgb, vec3(0.299, 0.587, 0.114));

    // Rampe: dunkel -> Bernstein -> heisses Bernstein
    vec3 mono = l < 0.6 ? mix(DARK, AMBER, l / 0.6) : mix(AMBER, HOT, (l - 0.6) / 0.4);
    vec3 col = mix(src.rgb, mono, MIX);

    if (mod(gl_FragCoord.y, 3.0) < 1.0) {
        col *= 1.0 - SCANLINE;
    }

    vec2 d = v_texcoord - 0.5;
    col *= 1.0 - VIGNETTE * dot(d, d) * 2.2;

    fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
