#version 120

uniform mat4 gbufferModelViewInverse;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 pos;
varying vec4 glcolor;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	gl_Position = ftransform();
	pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	glcolor = gl_Color;

	vec3 realNormal = (gbufferModelViewInverse * vec4(normalize(gl_NormalMatrix * gl_Normal), 0.0)).xyz;
	float glmult = dot(vec4(abs(realNormal.x), abs(realNormal.z), max(realNormal.y, 0.0), max(-realNormal.y, 0.0)), vec4(0.6, 0.8, 1.0, 0.5));
	glmult = mix(glmult, 1.0, lmcoord.x * lmcoord.x); //increase brightness when block light is high
	glcolor.rgb *= glmult;
}