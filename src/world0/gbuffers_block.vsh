#version 120

#include "/lib/defines.glsl"

uniform float night;
uniform float rainStrength;
uniform vec3 sunPosition;
        vec3 sunPosNorm = normalize(sunPosition);

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 pos;
varying vec4 glcolor;

void main() {
	pos         = (gl_ModelViewMatrix  * gl_Vertex).xyz;
	gl_Position =  gl_ProjectionMatrix * vec4(pos, 1.0);
	texcoord    = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord     = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor     =  gl_Color;

	vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
	#include "lib/glmult.glsl"
}