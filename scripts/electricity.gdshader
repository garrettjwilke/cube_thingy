shader_type canvas_item;

uniform int lightning_number = 5;
uniform vec2 amplitude = vec2(5.0,1.0);
uniform float offset = 0.45;
uniform float thickness = 0.08;
uniform float speed = 3.0;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_thickness = 0.016;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha : hint_range(0, 1) = 1.0;

// plot function 
float plot(vec2 st, float pct, float half_width){
  return  smoothstep( pct-half_width, pct, st.y) -
          smoothstep( pct, pct+half_width, st.y);
}

vec2 hash22(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1,311.7)),
              dot(uv, vec2(269.5,183.3)));
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, fuv);
    return mix(mix(dot(hash22(iuv + vec2(0.0,0.0)), fuv - vec2(0.0,0.0)),
                   dot(hash22(iuv + vec2(1.0,0.0)), fuv - vec2(1.0,0.0)), blur.x),
               mix(dot(hash22(iuv + vec2(0.0,1.0)), fuv - vec2(0.0,1.0)),
                   dot(hash22(iuv + vec2(1.0,1.0)), fuv - vec2(1.0,1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 n) {
    float total = 0.0, amp = 1.0;
    for (int i = 0; i < 7; i++) {
        total += noise(n) * amp;
        n += n;
        amp *= 0.5;
    }
    return total;
}


void fragment(){
	vec2 uv = UV;
	vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
	
	vec2 t ;
	float y ;
	float pct ;
	float buffer;	
	// add more lightning
	for ( int i = 0; i < lightning_number; i++){
		t = uv * amplitude + vec2(float(i), -float(i)) - TIME*speed;
		y = fbm(t)*offset;
		pct = plot(uv, y, thickness);
		buffer = plot(uv, y, glow_thickness);
		color += pct*base_color;
		color += buffer*glow_color;
	}
	
	color.a *= alpha;
	COLOR = color;
}