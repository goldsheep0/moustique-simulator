shader_type canvas_item;

uniform float process;

void fragment() {
	float color_gb = -2.*UV.y - (process * 3.)+3.;
	COLOR = vec4(1, color_gb, color_gb, 1);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
