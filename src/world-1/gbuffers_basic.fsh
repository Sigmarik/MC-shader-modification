#version 120

varying vec2 lmcoord;
varying vec3 glcolor;

void main() {
/* DRAWBUFFERS:04 */
	gl_FragData[0] = vec4(glcolor, 1.0); //gcolor
	gl_FragData[1] = vec4(lmcoord, 1.0, 1.0); //gaux1
}