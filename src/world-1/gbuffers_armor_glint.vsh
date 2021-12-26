#version 120

#include "/lib/defines.glsl"

uniform float frameTimeCounter;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 pos;
varying vec4 glcolor;

void main() {
	pos = (gl_ModelViewMatrix * gl_Vertex).xyz;

	#ifdef IDLE_HANDS
		if (gl_ProjectionMatrix[2][2] > -0.5) {
			pos.xy += sin(frameTimeCounter * vec2(1.6, 1.2)) * (sign(gl_ModelViewMatrix[3][0] + 0.3125) * 0.015625);
			gl_Position = gl_ProjectionMatrix * vec4(pos, 1.0);
		}
		else
	#endif
	gl_Position = ftransform();

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor  =  gl_Color;
}