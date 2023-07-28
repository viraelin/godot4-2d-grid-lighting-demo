shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

uniform sampler2D light_texture_0;

void fragment() {
	vec4 l0 = texture(light_texture_0, SCREEN_UV);
	vec4 c = texture(SCREEN_TEXTURE, UV);
	c *= l0;
	COLOR = c;
}
