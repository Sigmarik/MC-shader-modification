#version 120

varying vec2 texcoord;
varying vec3 normal;
varying vec4 glcolor;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	gl_Position = ftransform();
	glcolor = gl_Color;
	normal = gl_Normal * 0.5 + 0.5;
}