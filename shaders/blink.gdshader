shader_type canvas_item;

uniform float speed;
uniform sampler2D tex;

void fragment() {
	float val = mod(speed * TIME, 1.0);
	vec2 uv = UV;
	uv.y *= 0.5;
	if(val > 0.3) {
		uv.y = 0.5;
	}
	COLOR = texture(tex, uv);
}
