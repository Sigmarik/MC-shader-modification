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
uniform sampler2D lightmap;
uniform sampler2D texture;
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

#include "lib/colorConstants.glsl"

#include "/lib/math.glsl"

#include "lib/calcMainLightColor.glsl"

#include "lib/calcFogColor.glsl"

void main() {
	int id = int(mcentity);
	vec4 color = texture2D(texture, texcoord);

	#ifdef CLEAR_WATER
		if (id == 1) {
			color.a = 0.0;
		}
		else {
	#endif
		float dist = length(pos) / far;

		float skylight = lmcoord.y;
		float blocklight = lmcoord.x;
		float heldlight = 0.0;

		#ifdef BRIGHT_WATER
			if (isEyeInWater == 1) skylight = skylight * 0.5 + 0.5;
		#endif

		#ifdef ALT_GLASS
			bool applyEffects = true;
			if (id == 2) {
				if (color.a > THRESHOLD_ALPHA) {
					color.a = 1.0; //make borders opaque
					id = 0;
				}
				else {
					applyEffects = false; //don't apply lighting effects to the centers of glass
				}
			}
		#else
			if (id == 2 && color.a > THRESHOLD_ALPHA) id = 0;
		#endif

		#ifdef ALT_GLASS
			if (applyEffects) {
		#endif
				color *= glcolor;

				color.rgb *= calcMainLightColor(blocklight, skylight, heldlight, dist);

				#include "lib/desaturate.glsl"

				#include "/lib/crossprocess.glsl"

				if (blindness > 0.0) color.rgb *= interpolateSmooth1(max(1.0 - dist * far * 0.2, 0.0)) * 0.5 * blindness + (1.0 - blindness);

		#ifdef ALT_GLASS
			}
		#endif

		#ifdef FOG_ENABLED_OVERWORLD
			#ifdef ALT_GLASS //don't apply fog to glass when better glass is enabled, since this is done in composite1 instead
				if (id != 2) {
			#endif
				#ifndef CLEAR_WATER //already checked at the beginning if clear water is enabled, only needs to be re-checked if it's not.
					if (id != 1) { //water fog is handled in composite and composite1, to be compatible with infinite oceans
				#endif
						float d = dist + wetness * eyeBrightnessSmooth.y * 0.00125 - 0.2; //wetness * 0.3 * eyeBrightness / 240.0 - 0.2
						if (d > 0.0) {
							float y = (gbufferModelViewInverse * vec4(pos, 1.0)).y + cameraPosition.y;
							d = fogify(d * (rainStrength + 1.0) * exp2(1.5 - y * 0.015625), FOG_DISTANCE_MULTIPLIER_OVERWORLD);
							color.rgb = mix(calcFogColor(pos / (dist * far)) * min(max(lmcoord.y * 2.0, eyeBrightness.y / 120.0), 1.0) * (1.0 - blindness), color.rgb, d); //min(max(aux2.g, eyeBrightness.y), 1.0)
						}
				#ifndef CLEAR_WATER
					}
				#endif
			#ifdef ALT_GLASS
				}
			#endif
		#endif
	#ifdef CLEAR_WATER
		}
	#endif

/* DRAWBUFFERS:2563 */
	gl_FragData[0] = vec4(normal, 1.0); //gnormal, write to here first so that it won't discard other buffers when opacity is low
	gl_FragData[1] = vec4(lmcoord, id * 0.1, 1.0); //gaux2
	gl_FragData[2] = vec4(1.0, 0.0, 0.0, color.a); //gaux3
	gl_FragData[3] = color; //composite
}