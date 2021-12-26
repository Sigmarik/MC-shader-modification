#version 120

#include "/lib/defines.glsl"

attribute vec3 mc_Entity;

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
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition;
        vec3 sunPosNorm = normalize(sunPosition);

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying float mcentity; //ID data of block currently being rendered.
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
varying vec3 normal;
varying vec3 pos;
varying vec3 shadowColor; //Color of shadows. Sky-colored, to simulate indirect lighting.
varying vec3 skyLightColor; //Color of sky light. Is usually white during the day, and very dark blue at night.
varying vec4 glcolor;
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

#include "/lib/noiseres.glsl"

#include "/lib/calcHeldLightColor.glsl"

#if WATER_WAVE_STRENGTH != 0
	float waterWave(vec2 pos) {
		pos *= invNoiseRes;
		float offset = 0.875;
		offset += cos(texture2D(noisetex, pos / 20.0).r * 25.0 + frameTimeCounter * 2.0) * 0.5;
		offset += cos(texture2D(noisetex, pos / 15.0).r * 12.5 + frameTimeCounter * 3.0) * 0.375;
		return offset * (float(WATER_WAVE_STRENGTH) / 100.0 / 1.75);
	}
#endif

void main() {
	pos      = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor  =  gl_Color;
	mcentity = 0.1;

	//Using IDs above 10000 to represent all blocks that I care about
	//if the ID is less than 10000, then I don't need to do extra logic to see if it has special effects.
	if (mc_Entity.x > 10000.0) {
		int id = int(mc_Entity.x) - 10000;
		if (id == 9) { //water
			mcentity = 1.1;
			#if WATER_WAVE_STRENGTH != 0
				vec3 worldPos = pos + cameraPosition;
				if (worldPos.y <= SEA_LEVEL + 0.01 && worldPos.y >= SEA_LEVEL - 0.99) {
					pos.y -= waterWave(worldPos.xz + 0.5) * fract(worldPos.y - 0.01); // + 0.5 to avoid sharp edges in lava displacement when the coords are on the edge of a noisetex pixel
				}
			#endif
		}
		else if (id == 10) mcentity = 2.1; //stained glass
		else if (id == 11) mcentity = 3.1; //ice
	}

	#include "/lib/heldlightData.glsl"

	#include "lib/colors.glsl"

	normal = gl_NormalMatrix * gl_Normal;
	#include "lib/glmult.glsl"
	normal = gl_Normal * 0.5 + 0.5;

	pos = (gbufferModelView * vec4(pos, 1.0)).xyz;
	gl_Position = gl_ProjectionMatrix * vec4(pos, 1.0);
}