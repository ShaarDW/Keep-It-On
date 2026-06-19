shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float angle = atan(uv.x, uv.y);
	float normalized = (angle / (2.0 * PI)) + 0.5;
	
	if (normalized > progress) {
		discard;
	}
	
	COLOR = texture(TEXTURE, UV);
}