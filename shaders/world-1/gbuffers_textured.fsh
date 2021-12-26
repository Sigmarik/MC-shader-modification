#version 120

uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
/* DRAWBUFFERS:04 */
	gl_FragData[0] = texture2D(texture, texcoord) * glcolor; //gcolor
	gl_FragData[1] = vec4(lmcoord, 1.0, 1.0); //gaux1
}