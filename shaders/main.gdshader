shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform vec2 center = vec2(0.5, 0.5);
uniform float radius = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 color = texture(SCREEN_TEXTURE, uv);
	
	// Compensamos el aspecto ratio para que sea circular
	float aspect = 1080.0 / 1920.0;
	vec2 diff = uv - center;
	diff.x /= aspect;
	float dist = length(diff);
	
	if (dist < radius) {
		COLOR = vec4(1.0 - color.rgb, 1.0);
	} else {
		COLOR = color;
	}
}