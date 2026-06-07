shader_type spatial;

render_mode
	cull_disabled,
	depth_draw_opaque;

uniform vec4 deep_color =
	vec4(0.20, 0.65, 0.70, 1.0);

uniform vec4 shallow_color =
	vec4(0.60, 0.95, 0.90, 1.0);

uniform float wave_speed = 0.20;
uniform float wave_height = 0.05;
uniform float wave_frequency = 1.0;

uniform float fresnel_power = 5.0;

void vertex()
{
	float wave1 =
		sin(VERTEX.x * 0.35 + TIME * 0.40);

	float wave2 =
		cos(VERTEX.z * 0.28 + TIME * 0.25);

	float wave3 =
		sin((VERTEX.x + VERTEX.z) * 0.22 + TIME * 0.18);

	VERTEX.y +=
		(wave1 * 0.35) +
		(wave2 * 0.25) +
		(wave3 * 0.15);
}

void fragment()
{
	ALBEDO = deep_color.rgb;

	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}