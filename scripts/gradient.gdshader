shader_type canvas_item;

uniform vec4 start_color : source_color;
uniform vec4 end_color : source_color;

void fragment() {
    float t = UV.x;
    COLOR = mix(start_color, end_color, clamp(t, 0.0, 1.0));
}
