#version 120

#include "/lib/defines.glsl"

uniform float adjustedTime;
uniform float blindness;
uniform float day;
uniform float far;
uniform float night;
uniform float nightVision;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float rainStrength;
uniform float screenBrightness;
uniform float sunset;
uniform float wetness;
uniform int isEyeInWater;
uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D gaux3;
uniform sampler2D gaux4; //lightmap
#define lightmap gaux4
uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + gbufferModelViewInverse[3].xyz; //because cameraPosition isn't actually the position of the camera -_-
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition;
        vec3 sunPosNorm = normalize(sunPosition);
uniform vec3 upPosition;
        vec3 upPosNorm = normalize(upPosition);

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
varying vec3 shadowColor; //Color of shadows. Sky-colored, to simulate indirect lighting.
varying vec3 skyLightColor; //Color of sky light. Is usually white during the day, and very dark blue at night.
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

/*
because this has to be defined in the .fsh stage in order for optifine to recognize it:
uniform float centerDepthSmooth;

const float eyeBrightnessHalflife = 20.0;
const float wetnessHalflife = 250.0;
const float drynessHalflife = 60.0;
const float centerDepthHalflife = 1.0;

const int gcolorFormat = RGBA16;
const int compositeFormat = RGBA16;
const int gaux3Format = RGBA16;
const int gnormalFormat = RGB16;
*/

const float actualSeaLevel = SEA_LEVEL - 0.1111111111111111; //water source blocks are 8/9'ths of a block tall, so SEA_LEVEL - 1/9.

#include "/lib/noiseres.glsl"

#include "lib/colorConstants.glsl"

#include "/lib/math.glsl"

#include "lib/calcMainLightColor.glsl"

#include "lib/calcFogColor.glsl"

#include "lib/calcUnderwaterFogColor.glsl"

void main() {
	vec2 tc = texcoord;

	vec3 pos = vec3(tc, texture2D(depthtex0, tc).r);
	bool nothingInFrontOfSky = pos.z == 1.0;
	vec4 v = gbufferProjectionInverse * vec4(pos * 2.0 - 1.0, 1.0);
	pos = v.xyz / v.w;
	float dist = length(pos);
	vec3 posNorm = pos / dist;
	dist /= far;

	vec3 pos1 = vec3(tc, texture2D(depthtex1, tc).r);
	bool sky = pos1.z == 1.0;
	vec4 v1 = gbufferProjectionInverse * vec4(pos1 * 2.0 - 1.0, 1.0);
	pos1 = v1.xyz / v1.w;
	float dist1 = length(pos1) / far;

	vec3 color = texture2D(gcolor, tc).rgb;
	vec4 aux = texture2D(gaux1, tc);

	vec4 aux2 = texture2D(gaux2, tc);
	vec4 normal = texture2D(gnormal, tc);
	normal.xyz = normal.xyz * 2.0 - 1.0;
	bool water = int(aux2.b * 10.0 + 0.1) == 1; //only ID I'm actually checking for in this stage.
	bool inWater = isEyeInWater == 1; //quicker to type.

	float underwaterEyeBrightness = eyeBrightnessSmooth.y / 240.0;
	#ifdef BRIGHT_WATER
		underwaterEyeBrightness = underwaterEyeBrightness * 0.5 + 0.5;
	#endif

	if (!sky) {
		float skylight = aux.g;
		float blocklight = aux.r;
		float heldlight = 0.0;

		#ifdef BRIGHT_WATER
			if      ( water && !inWater) skylight = mix(skylight, skylight * 0.5 + 0.5, aux2.g); //max(skylight, aux2.g * 0.5);
			else if (!water &&  inWater) skylight = skylight * 0.5 + 0.5;
		#endif

		color *= calcMainLightColor(blocklight, skylight, heldlight, dist1);

		vec2 lmcoord = aux.rg;

		#include "lib/desaturate.glsl"

		#include "/lib/crossprocess.glsl"

		//!water && !inWater = white fog in stage 1
		//!water &&  inWater = blue fog
		// water && !inWater = blue fog in stage 1 then white fog in stage 2
		// water &&  inWater = white fog in stage 1 then blue fog in stage 2

		//if water xor  inwater then blue fog
		//if water ==   inwater then white fog (stage 1)
		//if water and  inwater then blue fog
		//if water and !inwater then white fog (stage 2)

		#ifdef UNDERWATER_FOG
			if      (water && !inWater) color = calcUnderwaterFogColor(color, dist1 - dist, aux2.g * aux2.g);
			else if (!water && inWater) color = calcUnderwaterFogColor(color, dist1, underwaterEyeBrightness);
		#endif

		#ifdef FOG_ENABLED_OVERWORLD
			if (water == inWater) {
				float d = water ? dist1 - dist : dist1;
				d += wetness * eyeBrightnessSmooth.y * 0.00125 - 0.2; //wetness * 0.3 * eyeBrightness / 240.0 - 0.2
				if (d > 0.0) {
					float y = (gbufferModelViewInverse * vec4(pos1, 0.0)).y + eyePosition.y;
					d = fogify(d * (rainStrength + 1.0) * exp2(1.5 - y * 0.015625), FOG_DISTANCE_MULTIPLIER_OVERWORLD);
					float actualEyeBrightness = eyeBrightness.y / 240.0;
					#ifdef BRIGHT_WATER
						if (inWater) actualEyeBrightness = actualEyeBrightness * 0.5 + 0.5;
					#endif
					color = mix(calcFogColor(posNorm) * min(max(aux.g, actualEyeBrightness) * 2.0, 1.0), color, d);
				}
			}
		#endif

		if (blindness > 0.0) color.rgb *= interpolateSmooth1(max(1.0 - dist1 * far * 0.2, 0.0)) * 0.5 * blindness + (1.0 - blindness);
	}
	else {
		aux2.g = 0.96875;
		if (eyePosition.y < actualSeaLevel) {
			if (inWater) {
				#ifdef INFINITE_OCEANS
					if (aux.a < 0.02) color = aux2.a < 0.02 ? calcUnderwaterFogColorInfinity(underwaterEyeBrightness) : calcFogColor(posNorm);
					else if (aux2.a < 0.02) {
						aux2.b = 0.1;
						normal = vec4(0.0, -1.0, 0.0, 1.0);
						water = true;
					}
				#else
					if (nothingInFrontOfSky) color = calcUnderwaterFogColorInfinity(underwaterEyeBrightness);
				#endif
			}
			#ifdef INFINITE_OCEANS
				else if (aux.a < 0.02) color = calcFogColor(posNorm) + texture2D(noisetex, gl_FragCoord.xy * invNoiseRes).rgb * 0.00390625; //dither to match the sky
			#endif
		}
		else {
			#ifdef INFINITE_OCEANS
				if (aux.a < 0.02 && aux2.a < 0.02) { //bottom half of sky
					color = calcUnderwaterFogColorInfinity(0.9384765625); //(31 / 32) ^ 2
					aux2.b = 0.1;
					normal = vec4(0.0, 1.0, 0.0, 1.0);
					water = true;
				}
				else
			#endif
					if (water && !inWater) color = calcUnderwaterFogColorInfinity(aux2.g * aux2.g);
		}

		color *= 1.0 - blindness;
	}

/* DRAWBUFFERS:025 */
	gl_FragData[0] = vec4(color, texture2D(gaux3, texcoord).r); //gcolor, storing transparency data in alpha channel
	gl_FragData[1] = normal * 0.5 + 0.5; //gnormal
	gl_FragData[2] = aux2; //gaux2
}