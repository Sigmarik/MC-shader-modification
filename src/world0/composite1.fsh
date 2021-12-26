#version 120

#include "/lib/defines.glsl"

uniform float adjustedTime;
uniform float aspectRatio;
uniform float blindness;
uniform float day;
uniform float far;
uniform float frameTimeCounter;
uniform float night;
uniform float nightVision;
uniform float phase;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float rainStrength;
uniform float screenBrightness;
uniform float sunset;
uniform float wetness;
uniform int isEyeInWater;
uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D composite;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D gaux4;
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

#ifdef CLOUDS
	varying float cloudDensityModifier; //Random fluctuations every few minutes.
#endif
#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
	varying float dofDistance; //Un-projected centerDepthSmooth
#endif
varying float eyeAdjust; //How much brighter to make the world
#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
#ifdef CLOUDS
	varying vec3 cloudColor; //Color of the side of clouds facing away from the sun.
	varying vec3 cloudIlluminationColor; //Color of the side of clouds facing towards the sun.
#endif
varying vec3 shadowColor; //Color of shadows. Sky-colored, to simulate indirect lighting.
varying vec3 skyLightColor; //Color of sky light. Is usually white during the day, and very dark blue at night.
#ifdef CLOUDS
	varying vec4 cloudInsideColor; //Color to render over your entire screen when inside a cloud.
#endif
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

/*
//required on older versions of optifine for its option-parsing logic.
#ifdef BLUR_ENABLED
#endif
*/

const float actualSeaLevel = SEA_LEVEL - 0.1111111111111111; //water source blocks are 8/9'ths of a block tall, so SEA_LEVEL - 1/9.

#include "/lib/noiseres.glsl"

#include "/lib/goldenOffsets.glsl"

#include "lib/colorConstants.glsl"

#include "/lib/math.glsl"

#include "lib/calcMainLightColor.glsl"

#include "/lib/noiseLOD.glsl"

#include "lib/calcSkyColorBasic.glsl"

#include "lib/calcFogColor.glsl"

#include "lib/calcUnderwaterFogColor.glsl"

#ifdef CLOUDS
	#ifdef OLD_CLOUDS
		#include "lib/drawClouds_old.glsl"
	#else
		#include "lib/drawClouds.glsl"
	#endif
#endif

void main() {
	#include "/lib/lavaOverlay.glsl"

	vec2 tc = texcoord;

	vec3 oldaux2 = texture2D(gaux2, texcoord).rgb;
	int id = int(oldaux2.b * 10.0 + 0.1);
	vec3 normal = texture2D(gnormal, texcoord).xyz * 2.0 - 1.0;

	vec3 pos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
	bool nothingInFrontOfSky = pos.z == 1.0;
	vec4 v = gbufferProjectionInverse * vec4(pos * 2.0 - 1.0, 1.0);
	pos = v.xyz / v.w;

	float dist = length(pos);
	vec3 posNorm = pos / dist;

	vec3 worldPos = (gbufferModelViewInverse * vec4(pos, 1.0)).xyz + cameraPosition;

	#ifdef REFLECT
		float reflective = 0.0;
	#endif

	#ifdef CLOUDS
		bool isTCOffset = false; //tracks weather or not cloud positions need to be re-calculated due to water/ice refractions
	#endif

	float blur = 0.0;

	#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
		blur = interpolateSmooth1(min(abs(dist - dofDistance) / dofDistance, 1.0)) * DOF_STRENGTH;
	#endif

	#if defined(BLUR_ENABLED) && WATER_BLUR != 0
		float waterBlur = float(WATER_BLUR); //slightly more dynamic than other types of blur, as high fog density will decrease this value, and being near a reflection of the sun will increase it.
	#endif

	if (id == 1) { //water
		#ifdef REFLECT
			reflective = 0.5;
		#endif

		#ifdef INFINITE_OCEANS
			if (nothingInFrontOfSky) {
				worldPos -= eyePosition; //convert back to eye-space

				float diff = actualSeaLevel - eyePosition.y;
				worldPos = normalize(worldPos);
				worldPos = vec3(worldPos.xz * (diff / worldPos.y), diff).xzy;
				dist = length(worldPos);
				worldPos += eyePosition;
			}
		#endif

		#if defined(WATER_REFRACT) || (defined(WATER_NORMALS) && defined(REFLECT))
			vec3 newPos = worldPos;
			ivec2 swizzles;
			float multiplier = 1.0;
			if (abs(normal.y) > 0.1) { //top/bottom surface
				if (abs(normal.y) < 0.999) newPos.xz -= normalize(normal.xz) * (frameTimeCounter * 3.0);
				else multiplier = (oldaux2.g * (0.75 - night * 0.375) + 0.25) + (oldaux2.g * min(rainStrength, wetness) * 1.5);
				swizzles = ivec2(0, 2);
			}
			else {
				newPos.y += frameTimeCounter * 4.0;
				if (abs(normal.x) < 0.02) swizzles = ivec2(0, 1);
				else swizzles = ivec2(2, 1);
			}

			vec2 offset = waterNoiseLOD(vec2(newPos[swizzles[0]], newPos[swizzles[1]]), dist) * (multiplier * 0.015625); //witchcraft.
			#ifdef WATER_NORMALS
				normal[swizzles[0]] += offset[0] * 4.0;
				normal[swizzles[1]] += offset[1] * 4.0;
				normal = normalize(normal);
			#endif

			#ifdef WATER_REFRACT
				tc += vec2(offset.x, offset.y * aspectRatio) / max(dist * 0.0625, 1.0);

				#ifdef CLOUDS
					isTCOffset = true;
				#endif
			#endif
		#endif
	}
	else if (id == 2) { //stained glass
		#ifdef REFLECT
			reflective = 0.25;
		#endif

		#if defined(BLUR_ENABLED) && GLASS_BLUR != 0
			blur = max(blur, float(GLASS_BLUR));
		#endif
	}
	else if (id == 3 || id == 4) { //ice and held ice
		#ifdef REFLECT
			reflective = 0.25;
		#endif

		#if defined(BLUR_ENABLED) && ICE_BLUR != 0
			blur = max(blur, float(ICE_BLUR));
		#endif

		#if defined(ICE_REFRACT) || (defined(ICE_NORMALS) && defined(REFLECT))
			vec3 offset;
			if (id == 3) {
				vec2 coord = (abs(normal.y) < 0.001 ? vec2(worldPos.x + worldPos.z, worldPos.y) : worldPos.xz);
				offset = iceNoiseLOD(coord * 256.0, dist) * 0.0078125;
			}
			else {
				vec2 coord = gl_FragCoord.xy + 0.5;
				offset = iceNoise(coord * 0.5) * 0.0078125;
			}

			#ifdef ICE_REFRACT
				vec2 newtc = tc + vec2(offset.x, offset.y * aspectRatio);
				vec3 newnormal = texture2D(gnormal, newtc).xyz * 2.0 - 1.0;
				if (dot(normal, newnormal) > 0.9) { //don't offset on the edges of ice
					tc = newtc;

					#ifdef CLOUDS
						isTCOffset = true;
					#endif
				}
			#endif

			#ifdef ICE_NORMALS
				normal = normalize(normal + offset * 8.0);
			#endif
		#endif
	}

	vec3 aux2 = texture2D(gaux2, tc).rgb;
	if (abs(aux2.b - oldaux2.b) > 0.02) {
		tc = texcoord;
		aux2 = texture2D(gaux2, tc).rgb;

		#ifdef CLOUDS
			isTCOffset = false;
		#endif
	}

	vec4 c = texture2D(gcolor, tc);
	vec3 color = c.rgb;
	float transparentAlpha = c.a; //using gcolor to store composite's alpha
	vec4 transparent = texture2D(composite, tc); //transparency of closest object to the camera

	#if defined(BLUR_ENABLED) && UNDERWATER_BLUR != 0
		if (isEyeInWater == 1) blur = float(UNDERWATER_BLUR);
	#endif

	#ifdef CLOUDS
		float cloudDiff = CLOUD_HEIGHT - eyePosition.y;
		vec3 baseCloudPos = worldPos - eyePosition;
		float cloudDist;
		vec4 cloudclr = vec4(0.0);
		//don't render clouds below you if you're below them, and vise versa. also don't render them in the void. (unless you have cubic chunks installed)
		#ifdef CUBIC_CHUNKS
			bool cloudy = sign(cloudDiff) == sign(baseCloudPos.y);
		#else
			bool cloudy = eyePosition.y > 0.0 && sign(cloudDiff) == sign(baseCloudPos.y);
		#endif

		if (cloudy) {
			//calculate base cloud plane position
			baseCloudPos = normalize(baseCloudPos);
			baseCloudPos = vec3(baseCloudPos.xz * (cloudDiff / baseCloudPos.y), cloudDiff).xzy;
			cloudDist = lengthSquared3(baseCloudPos) * 0.999; //avoid z-fighting by making clouds a little bit closer
			float opacityModifier = -1.0;
			//additional logic if there's terrain in front of the clouds (used for fake volumetric effects)
			if (!nothingInFrontOfSky && dist * dist < cloudDist) {
				opacityModifier = abs(worldPos.y - CLOUD_HEIGHT) / 4.0;
				if (opacityModifier < 1.0) { //maximum cloud density
					baseCloudPos = worldPos - eyePosition;
					cloudDist = lengthSquared3(baseCloudPos) * 0.999;
				}
				else { //pos is outside range of fake volumetric effects, check pos1 next.
					opacityModifier = -1.0;
					vec3 pos1 = vec3(tc, texture2D(depthtex1, tc).r);
					if (pos1.z < 1.0) { //opaque object exists here
						vec4 v1 = gbufferProjectionInverse * vec4(pos1 * 2.0 - 1.0, 1.0);
						pos1 = v1.xyz / v1.w;
						vec3 worldpos1 = (gbufferModelViewInverse * vec4(pos1, 1.0)).xyz + cameraPosition;
						opacityModifier = abs(worldpos1.y - CLOUD_HEIGHT) / 4.0;
						if (opacityModifier < 1.0 && lengthSquared3(pos1) < cloudDist) { //within volumetric range
							baseCloudPos = worldpos1 - eyePosition;
							cloudDist = lengthSquared3(baseCloudPos) * 0.999;
						}
						else opacityModifier = -1.0;
						cloudy = lengthSquared3(pos1) > cloudDist; //true if there's clouds between the terrain and the transparent thing
					} //opaque object exists here too
				} //pos is outside range of fake volumetric effects, check pos1 next.
			} //something in front of terrain

			if (cloudy) {
				if (isTCOffset && dist * dist < cloudDist) { //re-calculate position to account for water refraction.
					baseCloudPos = normalize((gbufferModelViewInverse * (gbufferProjectionInverse * vec4(tc * 2.0 - 1.0, 1.0, 1.0))).xyz);
					baseCloudPos = vec3(baseCloudPos.xz / baseCloudPos.y * cloudDiff, cloudDiff).xzy;
					//not re-calculating distance because it's not really all that necessary.
				}
				cloudDist = sqrt(cloudDist) / far;
				cloudclr = drawClouds(baseCloudPos, posNorm, opacityModifier, false);

				cloudclr.a *= 64.0 / (lengthSquared2(baseCloudPos.xz / baseCloudPos.y) + 64.0); //reduce opacity in the distance

				if (cloudclr.a > 0.001) {
					if (opacityModifier > 0.0 && opacityModifier < 1.0) { //in the fadeout range
						//approximated cosine interpolation
						cloudclr.a *= interpolateSmooth1(opacityModifier);
						//if (opacityModifier <= 0.5) cloudclr.a *= 2.0 * opacityModifier * opacityModifier;
						//else cloudclr.a *= -2.0 * opacityModifier * opacityModifier + 4.0 * opacityModifier - 1.0;
					}
				}
				else cloudy = false; //no need to render clouds that don't exist at this location
			}
		}
	#endif

	dist /= far;

	if (transparentAlpha > 0.001) {
		#ifdef CLOUDS
			if (cloudy && dist < cloudDist) color = mix(color, cloudclr.rgb, cloudclr.a);
		#endif

		#ifdef ALT_GLASS
			if (id == 2) {
				vec3 transColor = transparent.rgb / transparentAlpha;
				color *= transColor * (2.0 - transColor); //min(transColor * 2.0, 1.0); //because the default colors are too dark to be used.

				float skylight = aux2.g;
				float blocklight = aux2.r;
				float heldlight = 0.0;

				color += transColor * calcMainLightColor(blocklight, skylight, heldlight, dist) * 0.125 * (1.0 - blindness);
			}
			else
		#endif
				color = mix(color, transparent.rgb / transparentAlpha, transparentAlpha);
	}
	#ifdef CLOUDS
		else if (cloudy && (/* dist < cloudDist || */ id != 1 || isEyeInWater == 1)) color = mix(color, cloudclr.rgb, cloudclr.a);
	#endif

	#ifdef REFLECT
		reflective *= aux2.g * aux2.g * (1.0 - blindness);
		vec3 reflectedPos;
		if (isEyeInWater == 0 && reflective > 0.001) { //sky reflections
			vec3 newnormal = (gbufferModelView * vec4(normal, 0.0)).xyz;
			reflectedPos = reflect(posNorm, newnormal);
			vec3 skyclr = calcSkyColor(reflectedPos);
			float posDot = dot(-posNorm, newnormal);
			color += skyclr * square(square(1.0 - max(posDot, 0.0))) * reflective;
		}
	#endif

	if (id > 0) { //everything that I've currently assigned effects to so far needs fog to be done in this stage.
		if (isEyeInWater == 1) {
			#ifdef UNDERWATER_FOG
				float actualEyeBrightness = eyeBrightnessSmooth.y / 240.0;
				#ifdef BRIGHT_WATER
					actualEyeBrightness = actualEyeBrightness * 0.5 + 0.5;
				#endif
				color = calcUnderwaterFogColor(color, dist, actualEyeBrightness) * (1.0 - blindness);
			#endif
		}
		else {
			#ifdef FOG_ENABLED_OVERWORLD
				float d = dist + wetness * eyeBrightnessSmooth.y * 0.00125 - 0.2; //wetness * 0.3 * eyeBrightness / 240.0 - 0.2
				if (d > 0.0) {
					d = fogify(d * (rainStrength + 1.0) * exp2(1.5 - worldPos.y * 0.015625), FOG_DISTANCE_MULTIPLIER_OVERWORLD);
					vec3 fogclr = calcFogColor(posNorm);
					fogclr += texture2D(noisetex, gl_FragCoord.xy * invNoiseRes).rgb * 0.00390625; //dither to match sky
					color = mix(fogclr * min(max(aux2.g * 2.0, eyeBrightness.y / 120.0), 1.0) * (1.0 - blindness), color, d);
					#if defined(BLUR_ENABLED) && WATER_BLUR != 0
						waterBlur *= d;
					#endif
				}
			#endif
		}
	}

	//sun reflections bypasses fog.
	#ifdef REFLECT
		reflective *= day * day * (1.0 - rainStrength);
		if (isEyeInWater == 0 && reflective > 0.001) {
			vec3 sunColor = mix(vec3(2.0, 1.0, 0.5), vec3(1.0, 0.9, 0.8), day);
			float sunDot = dot(reflectedPos, sunPosNorm);
			float reflectionAmt = 0.00003 / square(1.001 - sunDot);

			color += sunColor * reflectionAmt * reflective;

			#if defined(BLUR_ENABLED) && WATER_BLUR != 0
				waterBlur = clamp((sunDot - 0.75) * 16.0, waterBlur, WATER_BLUR); //no more than WATER_BLUR, and no less than what it was originally.
			#endif
		}
	#endif

	color = min(color, 1.0); //reflections (and possibly other things) can go above maximum brightness

	#ifdef CLOUDS
		if (cloudy && (id == 1 || transparentAlpha > 0.001) && dist > cloudDist) color = mix(color, cloudclr.rgb, cloudclr.a);
		color = mix(color, cloudInsideColor.rgb, cloudInsideColor.a);
	#endif

	#if defined(BLUR_ENABLED) && RAIN_BLUR != 0
		if (wetness > 0.001) {
			float skylight = texture2D(gaux1, tc).g;

			float heightModifier = 1.0;

			#ifdef CLOUDS
				heightModifier = fogify(max(eyePosition.y - CLOUD_HEIGHT, 0.0), 6.25); //less rain blur above cloud height
			#endif

			blur += wetness * heightModifier * float(RAIN_BLUR) * (nothingInFrontOfSky ? 0.5 : min(max(eyeBrightnessSmooth.y / 120.0, skylight * 2.0), 1.0) * dist);
		}
	#endif

	#if defined(BLUR_ENABLED) && WATER_BLUR != 0
		if (id == 1 && isEyeInWater == 0) blur += waterBlur;
	#endif

	#ifdef BLUR_ENABLED
		blur /= 256.0;
	#endif

	color *= mix(vec3(eyeAdjust), vec3(1.0), color);

/* DRAWBUFFERS:6 */
	gl_FragData[0] = vec4(color, 1.0 - blur); //gaux3
}