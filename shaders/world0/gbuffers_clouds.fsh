#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec3 normal;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	if (color.a < 0.1) discard; //shouldn't be necessary, but still is for some reason.

/* DRAWBUFFERS:2563 */
	gl_FragData[0] = vec4(normal, 1.0); //gnormal
	gl_FragData[1] = vec4(0.0, 1.0, 0.0, 1.0); //gaux2
	gl_FragData[2] = vec4(1.0, 0.0, 0.0, color.a); //gaux3
	gl_FragData[3] = color; //gcolor
}