#version 300 es
// Wired: tube monitor. Fine scanlines, phosphor glow, slight color fringing,
// darkened edges. No real curvature (mouse clicks would no longer line up)
// and no time uniform (otherwise Hyprland redraws constantly).
// Toggle: Super+Shift+G. Off automatically in fullscreen games (hypr/theme.lua).
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float SCANLINE = 0.13;   // darkening of every 3rd pixel row
const float GLOW = 0.22;       // strength of the phosphor glow
const float ABERRATION = 0.6;  // color fringing in pixels
const float VIGNETTE = 0.28;   // darkening towards the corners

void main() {
    vec2 px = 1.0 / vec2(textureSize(tex, 0));

    // Slight color fringing: red to the right, blue to the left
    vec3 col;
    col.r = texture(tex, v_texcoord + vec2(ABERRATION * px.x, 0.0)).r;
    col.g = texture(tex, v_texcoord).g;
    col.b = texture(tex, v_texcoord - vec2(ABERRATION * px.x, 0.0)).b;

    // Phosphor glow: bright neighbors bleed over a little
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
