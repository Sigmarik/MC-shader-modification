#version 120

#include "/lib/defines.glsl"

uniform float aspectRatio;
uniform float blindness;
uniform float far;
uniform float frameTimeCounter;
uniform float nightVision;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float screenBrightness;
uniform int isEyeInWater;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D composite;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D gaux2;
uniform sampler2D gaux4;
#define lightmap gaux4
uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + gbufferModelViewInverse[3].xyz; //because cameraPosition isn't actually the position of the camera -_-
uniform vec3 fogColor;

#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
	varying float dofDistance; //Un-projected centerDepthSmooth
#endif
#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.
#ifdef VOID_CLOUDS
	varying vec4 voidCloudInsideColor; //Color to render over your entire screen when inside a void cloud.
#endif

/*
//required on older versions of optifine for its option-parsing logic:
#ifdef BLUR_ENABLED
#endif
*/

#include "/lib/noiseres.glsl"

#include "/lib/goldenOffsets.glsl"

#include "/lib/math.glsl"

#include "lib/calcMainLightColor.glsl"

#include "/lib/noiseLOD.glsl"

#ifdef VOID_CLOUDS
	#include "/lib/hue.glsl"

	#include "lib/drawVoidClouds.glsl"
#endif

void main() {
	#include "/lib/lavaOverlay.glsl"

	vec2 tc = texcoord;

	vec3 normal = texture2D(gnormal, tc).rgb * 2.0 - 1.0;
	int id = int(texture2D(gaux2, tc).b * 10.0 + 0.1);

	vec3 pos = vec3(tc, texture2D(depthtex0, tc).r);
	bool nothingInFrontOfSky = pos.z == 1.0;
	vec4 v = gbufferProjectionInverse * vec4(pos * 2.0 - 1.0, 1.0);
	pos = v.xyz / v.w;
	float dist = length(pos);

	vec3 worldPos = (gbufferModelViewInverse * vec4(pos, 1.0)).xyz + cameraPosition;

	float blur = 0.0;

	#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
		blur = interpolateSmooth1(min(abs(dist - dofDistance) / dofDistance, 1.0)) * float(DOF_STRENGTH);
	#endif

	#ifdef VOID_CLOUDS
		bool isTCOffset = false; //tracks weather or not void cloud positions need to be re-calculated due to water/ice refractions
	#endif

	if (id == 1) { //water
		#if defined(BLUR_ENABLED) && WATER_BLUR != 0
			blur = max(blur, WATER_BLUR);
		#endif

		#ifdef WATER_REFRACT
			vec3 newPos = worldPos;
			ivec2 swizzles;
			if (abs(normal.y) > 0.1) { //top/bottom surface
				if (abs(normal.y) < 0.999) newPos.xz -= normalize(normal.xz) * frameTimeCounter * 3.0;
				swizzles = ivec2(0, 2);
			}
			else {
				newPos.y += frameTimeCounter * 4.0;
				if (abs(normal.x) < 0.02) swizzles = ivec2(0, 1);
				else swizzles = ivec2(2, 1);
			}

			vec2 offset = waterNoiseLOD(vec2(newPos[swizzles[0]], newPos[swizzles[1]]), dist) / 64.0; //witchcraft.
			tc += vec2(offset.x, offset.y * aspectRatio) / max(dist * 0.0625, 1.0);

			#ifdef VOID_CLOUDS
				isTCOffset = true;
			#endif
		#endif
	}
	else if (id == 2) { //stained glass
		#if defined(BLUR_ENABLED) && GLASS_BLUR != 0
			blur = max(blur, float(GLASS_BLUR));
		#endif
	}
	else if (id == 3 || id == 4) { //ice and held ice
		#if defined(BLUR_ENABLED) && ICE_BLUR != 0
			blur = max(blur, float(ICE_BLUR));
		#endif

		#ifdef ICE_REFRACT
			vec3 offset;
			if (id == 3) {
				vec2 coord = (abs(normal.y) < 0.001 ? vec2(worldPos.x + worldPos.z, worldPos.y) : worldPos.xz);
				offset = iceNoiseLOD(coord * 256.0, dist) / 128.0;
			}
			else {
				vec2 coord = gl_FragCoord.xy + 0.5;
				offset = iceNoise(coord * 0.5) / 128.0;
			}

			vec2 newtc = tc + vec2(offset.x, offset.y * aspectRatio);
			vec3 newnormal = texture2D(gnormal, newtc).xyz * 2.0 - 1.0;
			if (dot(normal, newnormal) > 0.9) {
				tc = newtc;

				#ifdef VOID_CLOUDS
					isTCOffset = true;
				#endif
			}
		#endif
	}

	dist /= far;

	if (id != int(texture2D(gaux2, tc).b * 10.0 + 0.1)) {
		tc = texcoord;
		#ifdef VOID_CLOUDS
			isTCOffset = false;
		#endif
	}

	#ifdef VOID_CLOUDS
		float cloudDiff = VOID_CLOUD_HEIGHT - eyePosition.y;
		vec3 baseCloudPos = worldPos - eyePosition;
		float cloudDist;
		vec4 cloudclr = vec4(0.0);
		//don't render clouds below you if you're below them, and vise versa.
		bool cloudy = sign(cloudDiff) == sign(baseCloudPos.y);

		if (cloudy) {
			//calculate base cloud plane position
			baseCloudPos = normalize(baseCloudPos);
			baseCloudPos = vec3(baseCloudPos.xz / baseCloudPos.y * cloudDiff, cloudDiff).xzy;
			cloudDist = lengthSquared3(baseCloudPos) * 0.999; //avoid z-fighting by making clouds a little bit closer
			float opacityModifier = -1.0;
			//additional logic if there's terrain in front of the clouds (used for fake volumetric effects)
			if (!nothingInFrontOfSky && square(dist * far) < cloudDist) {
				opacityModifier = abs(worldPos.y - VOID_CLOUD_HEIGHT) / 4.0;
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
						opacityModifier = abs(worldpos1.y - VOID_CLOUD_HEIGHT) / 4.0;
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
				if (isTCOffset && square(dist * far) < cloudDist) { //re-calculate position to account for water refraction.
					baseCloudPos = normalize((gbufferModelViewInverse * (gbufferProjectionInverse * vec4(tc * 2.0 - 1.0, 1.0, 1.0))).xyz);
					baseCloudPos = vec3(baseCloudPos.xz / baseCloudPos.y * cloudDiff, cloudDiff).xzy;
					//not re-calculating distance because it's not really all that necessary.
				}
				cloudDist = sqrt(cloudDist) / far;
				cloudclr = drawVoidClouds(baseCloudPos, opacityModifier); //opacityModifier is -1.0 when not applying volumetric effects

				if (cloudclr.a > 0.001) {
					if (opacityModifier > 0.001 && opacityModifier < 0.999) { //in the fadeout range
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

	vec3 color = texture2D(gcolor, tc).rgb;
	vec4 transparent = texture2D(composite, tc);
	float transparentAlpha = texture2D(gcolor, tc).a; //using gcolor to store composite's alpha.

	if (transparentAlpha > 0.0) {
		#ifdef VOID_CLOUDS
			if (cloudy && dist < cloudDist) color = mix(color, cloudclr.rgb, cloudclr.a);
		#endif

		#ifdef ALT_GLASS
			if (id == 2) {
				vec3 transColor = transparent.rgb / transparentAlpha;
				color *= transColor * (2.0 - transColor); //min(transColor * 2.0, 1.0); //because the default colors are too dark to be used.

				float blocklight = texture2D(gaux2, tc).r;
				float heldlight = 0.0;

				color = min(color + transColor * calcMainLightColor(blocklight, heldlight, dist) * 0.125 * (1.0 - blindness), 1.0);

				#ifdef FOG_ENABLED_END
					color.rgb = mix(fogColor, color.rgb, fogify(dist, FOG_DISTANCE_MULTIPLIER_END));
				#endif
			}
			else {
		#endif
				color = mix(color, transparent.rgb / transparentAlpha, transparentAlpha);
		#ifdef ALT_GLASS
			}
		#endif
	}
	#ifdef VOID_CLOUDS
		else if (cloudy) {
			if (dist < cloudDist || id != 1) color = mix(color, cloudclr.rgb, cloudclr.a);
		}

		if (cloudy && (id == 1 || transparentAlpha > 0.001) && dist > cloudDist) color = mix(color, cloudclr.rgb, cloudclr.a);
		color = mix(color, voidCloudInsideColor.rgb, voidCloudInsideColor.a);
	#endif

	#if defined(BLUR_ENABLED) && UNDERWATER_BLUR != 0
		if (isEyeInWater == 1) blur = float(UNDERWATER_BLUR);
	#endif

	#ifdef BLUR_ENABLED
		blur /= 256.0;
	#endif

	color *= color * -0.5 + 1.5; //mix(vec3(1.5), vec3(1.0), color);

/* DRAWBUFFERS:6 */
	gl_FragData[0] = vec4(color, 1.0 - blur); //gcolor
}