shader_type canvas_item;

uniform vec4 bg_color : source_color;
uniform vec4 fg_color : source_color;
uniform float amount;

void fragment() {
	if (UV.x < amount) {
		COLOR = fg_color;
	}
	else {
		COLOR = bg_color;
	}
}
