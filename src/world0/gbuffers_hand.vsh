#version 120

#include "/lib/defines.glsl"

uniform float adjustedTime;
uniform float day;
uniform float far;
uniform float frameTimeCounter;
uniform float night;
uniform float phase;
uniform float rainStrength;
uniform float sunset;
uniform int heldBlockLightValue;
uniform int heldItemId;
uniform int heldItemId2;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferProjection;
uniform sampler2D noisetex;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition;
		vec3 sunPosNorm = normalize(sunPosition);

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying float id; //ID data of block currently being rendered.
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
varying vec3 normal;
varying vec3 shadowColor; //Color of shadows. Sky-colored, to simulate indirect lighting.
varying vec3 skyLightColor; //Color of sky light. Is usually white during the day, and very dark blue at night.
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

	glcolor = gl_Color;
	#include "/lib/heldlightData.glsl"

	int heldItem = gl_ModelViewMatrix[3][0] > -0.3125 ? heldItemId : heldItemId2;
	if (heldItem == 95 || heldItem == 160) id = 0.2; //stained glass
	else if (heldItem == 79) id = 0.4; //ice
	else id = 0.0;

	//note: apparently gl_Normal is NOT automaticaly normalized when rendering the hand.
	//this causes issues with reflections on held objects
	//as such, we need to normalize it manually.
	normal = normalize(gl_NormalMatrix * gl_Normal);
	#include "lib/glmult.glsl"
	normal = normalize(gl_Normal) * 0.5 + 0.5;

	#include "lib/colors.glsl"
}