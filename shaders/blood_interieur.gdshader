shader_type canvas_item;

uniform float quantite;
uniform vec3 modulate;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (UV.y > 1.-quantite) {
		color.rgb = modulate;
	} else {
		color.a = 0.0;
	}
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
