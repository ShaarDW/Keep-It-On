shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 text_color = texture(TEXTURE, UV);
	
	// Invertimos el color del texto según el fondo
	if (text_color.a > 0.1) {
		COLOR = vec4(1.0 - screen_color.rgb, text_color.a);
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}