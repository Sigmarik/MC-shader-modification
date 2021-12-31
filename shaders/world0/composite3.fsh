#version 120

varying vec2 texcoord;

uniform sampler2D depthtex0;
uniform mat4 gbufferModelViewInverse;

void main() {
    float depth = texture2D(depthtex0, texcoord).r;
    vec3 view_pos = vec3(texcoord, depth);
    /* DRAWBUFFERS:8 */
    gl_FragData[0] = texture2D(depthtex0, texcoord) / 100.0;
    //gl_FradData[0] = vec4(depth / 100.0, 0.0, 0.0, 1.0);
}