#version 120

#include "/lib/defines.glsl"

uniform float night;
uniform float rainStrength;
uniform vec3 sunPosition;
        vec3 sunPosNorm = normalize(sunPosition);

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	gl_Position = ftransform();
	glcolor = gl_Color;

	//not pre-normalized for item frames with maps in them
	vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
	#include "lib/glmult.glsl"
}