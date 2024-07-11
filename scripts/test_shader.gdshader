//Original shadertoy source: https://www.shadertoy.com/view/mtfBRr
//Credits to Leon Denise
//https://leon196.github.io/
//(@leondenise): https://twitter.com/leondenise
shader_type canvas_item;

uniform vec2 R = vec2(.8, .6);
uniform float scale = 0.2;
uniform float speed = 0.02;
uniform vec3 direction = vec3(1,1,0);
uniform float distortion = 0.5;
uniform float layers = 2.;
uniform float shades = 2;
uniform int steps = 4;

uniform vec3 tint = vec3(0.2,0.2,1.);

float gyroid (vec3 seed) { return dot(sin(seed),cos(seed.yzx)); }

float fbm (vec3 seed)
{
    float result = 0., a = .4;
    for (int i = 0; i < steps; ++i, a /= 2.) {
        seed += direction + TIME*speed*0.01/a;
        seed.z += result*distortion;
        result += gyroid(seed/a)*a;
    }
    return result;
}

void fragment()
{
    vec2 p = (2.*UV-R)/R.y;
    float shape = fbm(vec3(p*scale, 0.));
    float gradient = fract(shape*layers);
    float shade = round(pow(gradient, 1)*shades)/shades;
    vec3 color = mix(tint*mix(0,0,gradient), vec3(1), shade);
    COLOR = vec4(color,1.0);
}