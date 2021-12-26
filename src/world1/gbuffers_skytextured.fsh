#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;

void main() {
/* DRAWBUFFERS:0 */
	gl_FragData[0] = texture2D(texture, texcoord) * glcolor; //gcolor
}