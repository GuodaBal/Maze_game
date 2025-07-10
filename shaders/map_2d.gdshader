shader_type canvas_item;

uniform sampler2D fragment_image;

void fragment() {
	vec4 frag_tex = texture(fragment_image, UV);
	//Combines textures
	COLOR.rgb = COLOR.rgb + frag_tex.rgb;
	//Makes sure only fraction is visible
	COLOR.a = frag_tex.a;
}