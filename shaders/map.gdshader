shader_type spatial;
render_mode cull_disabled;

uniform sampler2D fragment_image;
uniform sampler2D map_image;

void fragment() {
	vec4 map_tex = texture(map_image, UV);
	vec4 frag_tex = texture(fragment_image, UV);
	//Combines textures. Multiplication to make map brighter and stand out more
	ALBEDO = mix(map_tex.rgb, frag_tex.rgb, 0.5) * 2.0;
	//Makes sure only fraction is visible
	ALPHA = frag_tex.a;
}
