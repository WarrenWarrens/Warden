// GD ASCII Shader - full-screen ASCII post-process for Godot 4.
// Put it on a full-screen ColorRect inside a CanvasLayer drawn above your 3D scene.
shader_type canvas_item;

uniform sampler2D screen : hint_screen_texture, filter_nearest;
uniform sampler2D screen_blur : hint_screen_texture, filter_linear_mipmap;
// Contrast curve on brightness before it picks a character. Higher = darker mid-tones.
uniform float gamma : hint_range(0.1, 4.0, 0.01) = 1.55;
// Brightness multiplier. Higher = denser characters overall.
uniform float gain : hint_range(0.0, 5.0, 0.01) = 1.8;
// Fraction of cells replaced by random green glitch characters (animate it for effects).
uniform float corrupt : hint_range(0.0, 1.0, 0.01) = 0.0;
// Character size in screen pixels = 6 * cell_scale. Lower = more, smaller characters.
uniform int cell_scale : hint_range(1, 8) = 1;
// Strength of the soft color glow behind dark areas.
uniform float halo_strength : hint_range(0.0, 1.0, 0.01) = 0.15;

// " .:-=+*#%@" as 5x5 bitmaps, bit = x + 5 * y from the top-left
const int CHARS[10] = int[](0, 4194304, 131200, 14336, 459200, 145536, 703136, 11512810, 27070835, 31913518);

float glyph(int n, ivec2 ip) {
	if (ip.x > 4 || ip.y > 4) return 0.0;
	return float((n >> (ip.x + 5 * ip.y)) & 1);
}

void fragment() {
	// SCREEN_UV is top-left origin on every renderer; FRAGCOORD flips in Compatibility
	vec2 px = SCREEN_UV / SCREEN_PIXEL_SIZE;
	float size = 6.0 * float(cell_scale);
	vec2 cell = floor(px / size) * size + size * 0.5;
	vec3 col = texture(screen, cell * SCREEN_PIXEL_SIZE).rgb;
	float gray = pow(dot(col, vec3(0.3, 0.59, 0.11)), gamma) * gain;

	int c = int(clamp(gray, 0.0, 0.999) * 10.0);
	vec3 hue = col / max(max(col.r, col.g), max(col.b, 0.001));
	hue = clamp(mix(vec3(dot(hue, vec3(0.3, 0.59, 0.11))), hue, 1.5), 0.0, 1.0);
	vec3 halo = textureLod(screen_blur, SCREEN_UV, 5.0).rgb * (1.0 - smoothstep(0.02, 0.25, gray));
	float junk = fract(sin(dot(cell + floor(TIME * 15.0), vec2(12.9898, 78.233))) * 43758.5453);
	if (junk < corrupt) {
		c = int(fract(junk * 91.7) * 10.0);
		hue = vec3(0.2, 1.0, 0.35);
	}
	ivec2 ip = ivec2(mod(px, size) / float(cell_scale));
	COLOR = vec4(hue * glyph(CHARS[c], ip) + halo * halo_strength, 1.0);
}
