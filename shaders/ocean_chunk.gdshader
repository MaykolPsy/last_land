shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_never;

uniform vec4 out_color : source_color = vec4(0.0, 0.2, 1.0, 1.0);
uniform float amount : hint_range(0.05, 1.0) = 0.4;
uniform float beer_factor : hint_range(0.0, 10.0, 0.1) = 0.2;
uniform float alpha : hint_range(0.0, 1.0) = 0.55;
uniform sampler2D depth_texture : hint_depth_texture;

float generateOffset(float x, float z, float val1, float val2, float time) {
	float speed = 1.0;
	float radiansX = ((mod(x + z * x * val1, amount) / amount) + (time * speed) * mod(x * 0.8 + z, 1.5)) * 6.28318;
	float radiansZ = ((mod(val2 * (z * x + x * z), amount) / amount) + (time * speed) * 2.0 * mod(x, 2.0)) * 6.28318;
	return amount * 0.5 * (sin(radiansZ) + cos(radiansX));
}

void vertex() {
	// Usar coordenada global para que no haya costura entre chunks
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	float xd = generateOffset(world_pos.x, world_pos.z, 0.2, 0.1, TIME + 0.1);
	float yd = generateOffset(world_pos.x, world_pos.z, 0.1, 0.3, TIME + 0.1);
	float zd = generateOffset(world_pos.x, world_pos.z, 0.15, 0.02, TIME + 0.1);

	vec3 displaced_world = world_pos + vec3(xd, yd, zd);

	// Regresar a local
	VERTEX = (inverse(MODEL_MATRIX) * vec4(displaced_world, 1.0)).xyz;
}

void fragment() {
	METALLIC = 0.3;
	SPECULAR = 0.15;
	ROUGHNESS = 0.35;
	ALBEDO = out_color.rgb;

	float d = texture(depth_texture, SCREEN_UV).r;
	d = d * 2.0 - 1.0;
	d = PROJECTION_MATRIX[3][2] / (d + PROJECTION_MATRIX[2][2]);

	float absorb = exp(-max(d, 0.0) * beer_factor);
	float depth_alpha = 1.0 - absorb;

	ALPHA = clamp(alpha + depth_alpha * 0.5, 0.0, 1.0);
}