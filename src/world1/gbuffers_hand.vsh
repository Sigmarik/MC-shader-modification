#version 120

#include "/lib/defines.glsl"

uniform float far;
uniform float frameTimeCounter;
uniform int heldBlockLightValue;
uniform int heldItemId;
uniform int heldItemId2;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferProjection;
uniform sampler2D noisetex;

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying float mcentity; //ID data of block currently being rendered.
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
varying vec3 normal;
varying vec4 glcolor;
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

#include "/lib/noiseres.glsl"

#include "/lib/calcHeldLightColor.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

	#ifdef IDLE_HANDS
		vec4 pos = gl_ModelViewMatrix * gl_Vertex;
		if (heldItemId != 359 && heldItemId2 != 359) { //no hand sway when holding a map.
			pos.xy += sin(frameTimeCounter * vec2(1.6, 1.2)) * (sign(gl_ModelViewMatrix[3][0] + 0.3125) * 0.015625);
		}
		gl_Position = gl_ProjectionMatrix * pos;
	#else
		gl_Position = ftransform();
	#endif

	normal = normalize(gl_Normal) * 0.5 + 0.5;
	glcolor = gl_Color;
	glcolor.rgb *= min(normalize(gl_NormalMatrix * gl_Normal).y * 0.375 + 0.625 + heldBlockLightValue / 30.0, 1.25);

	#include "lib/colors.glsl"

	#include "/lib/heldlightData.glsl"

	int heldItem = gl_ModelViewMatrix[3][0] > -0.3125 ? heldItemId : heldItemId2;
	if (heldItem == 95 || heldItem == 160) mcentity = 2.1; //stained glass
	else if (heldItem == 79) mcentity = 4.1; //ice
	else mcentity = 0.0;
}