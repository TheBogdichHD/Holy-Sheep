shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform float FOV : hint_range(20, 120) = 75;

void vertex() {
    float scale = 1.0 / tan(FOV * 0.5 * PI / -180.0);
    
    PROJECTION_MATRIX[0][0] = scale / (-VIEWPORT_SIZE.x / VIEWPORT_SIZE.y);
    PROJECTION_MATRIX[1][1] = scale;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	DEPTH = 1.0 - (1.0 - FRAGCOORD.z) * 0.7;
}
