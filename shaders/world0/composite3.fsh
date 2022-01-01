#version 120


#define HEIGHT_FOG_ENABLED 1 //Turns exponential fog on and off. [1 0]
#define HEIGHT_FOG_SEA_LEVEL 60 //Fog sea level. [-64 -60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150]
#define HEIGHT_FOG_DISTORTION -0.02 //Defines how sharp for transition is. [-0.01 -0.02 -0.03 -0.05 -0.1 -0.2 -0.4 -0.7 -1]
#define HEIGHT_FOG_DENCITY 0.5 //General height fog dencity multiplyer. [0.1 0.3 0.5 0.7 1.0 1.2 1.3 1.5 1.7 2.0 2.5 3.0 3.5 5.0]
#define HEIGHT_FOG_CAVE_FIX 1 //Tryes to disable height fog in caves [0 1]
#define H_FOG_FIX_SIGM_K -10.0 //Sigmoid coefficient. It is a bit hard to explain, just tweak it and see what happens in caves. [-1.0 -2.0 -5.0 -10.0 -15.0 -20.0]

varying vec2 texcoord;

uniform vec3 cameraPosition;
uniform sampler2D depthtex0;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

const float fog_k = -0.02;

#if HEIGHT_FOG_ENABLED

#if HEIGHT_FOG_CAVE_FIX == 1
uniform ivec2 eyeBrightness;
#endif

float fog_dencity(float height) {
    return pow(2.718, HEIGHT_FOG_DISTORTION * (height - HEIGHT_FOG_SEA_LEVEL));
}

float sum_dencity(float height) {
    return (1.0 / HEIGHT_FOG_DISTORTION) * pow(2.718, HEIGHT_FOG_DISTORTION * (height - HEIGHT_FOG_SEA_LEVEL));
}

void main() {
    float depth = texture2D(depthtex0, texcoord).r;
    vec3 view_pos = vec3(texcoord, depth) * 2.0 - 1.0;
    vec4 wpos = gbufferProjectionInverse * vec4(view_pos, 1.0);
    vec3 view_space = wpos.xyz / wpos.w;
    vec4 world_space = gbufferModelViewInverse * vec4(view_space, 1.0);
    float height_end = world_space.y + cameraPosition.y;
    float max_h = max(cameraPosition.y, height_end);
    float min_h = min(cameraPosition.y, height_end);
    if(max_h == min_h) {
        max_h += 0.01;
    }
    float mean_dencity = (sum_dencity(max_h) - sum_dencity(min_h)) / (max_h - min_h);
    float dencity = min(400.0, mean_dencity * length(world_space));
    #if HEIGHT_FOG_CAVE_FIX
    dencity /= 1 + pow(2.718, H_FOG_FIX_SIGM_K * (eyeBrightness.y - 14.0/15.0));
    #endif
    /* DRAWBUFFERS:8 */
    gl_FragData[0] = vec4(HEIGHT_FOG_DENCITY * dencity / 100);
    //gl_FradData[0] = vec4(depth / 100.0, 0.0, 0.0, 1.0);
}
#endif
#if HEIGHT_FOG_ENABLED == 0
void main(){
    /* DRAWBUFFERS:8 */
    gl_FragData[0] = vec4(0.0, 0.0, 0.0, 0.0);
}
#endif