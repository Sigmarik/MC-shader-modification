#version 120

varying vec2 lmcoord;
varying vec3 glcolor;

void main() {
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	gl_Position = ftransform();
	glcolor = gl_Color.rgb;
}