#version 120

#include "/lib/defines.glsl"

uniform float blindness;
uniform float far;
uniform float frameTimeCounter;
uniform float nightVision;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float screenBrightness;
uniform int isEyeInWater;
bool inWater = isEyeInWater == 1; //quicker to type
uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D gaux3;
uniform sampler2D gaux4;
#define lightmap gaux4
uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + gbufferModelViewInverse[3].xyz; //because cameraPosition isn't actually the position of the camera -_-
uniform vec3 fogColor;
uniform vec3 skyColor;

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying vec2 texcoord;
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

/*
because this has to be defined in the .fsh stage in order for optifine to recognize it:
uniform float centerDepthSmooth;

const float eyeBrightnessHalflife = 20.0;
const float centerDepthHalflife   =  1.0;

const int gcolorFormat    = RGBA16;
const int compositeFormat = RGBA16;
const int gaux3Format     = RGBA16;
const int gnormalFormat   = RGB16;
*/

#include "/lib/noiseres.glsl"

#include "/lib/math.glsl"

#include "lib/calcMainLightColor.glsl"

#include "lib/calcFogColor.glsl"

#include "lib/calcUnderwaterFogColor.glsl"

#include "/lib/hue.glsl"

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

	float skylight = aux.g;
	float blocklight = aux.r;
	float heldlight = 0.0;

	float underwaterEyeBrightness = eyeBrightnessSmooth.y / 240.0;
	#ifdef BRIGHT_WATER
		underwaterEyeBrightness = underwaterEyeBrightness * 0.5 + 0.5;
	#endif

	if (!sky) {
		#ifdef BRIGHT_WATER
			if      ( water && !inWater) skylight = max(skylight, aux2.g * 0.5);
			else if (!water &&  inWater) skylight = skylight * 0.5 + 0.5;
		#endif

		color *= calcMainLightColor(blocklight, skylight, heldlight, dist1);

		vec2 lmcoord = aux.rg;

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

		#ifdef FOG_ENABLED_TF
			if (water == inWater) {
				float d = (water ? dist1 - dist : dist1) - 0.2;
				if (d > 0.0) {
					float y = (gbufferModelViewInverse * vec4(pos1, 0.0)).y + eyePosition.y;
					d = fogify(d * exp2(1.5 - y * 0.015625), FOG_DISTANCE_MULTIPLIER_TF);
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
		if (water && !inWater) {
			color = calcUnderwaterFogColorInfinity(aux2.g * aux2.g);
		}
		else if (!water && inWater) {
			color = calcUnderwaterFogColorInfinity(underwaterEyeBrightness);
		}
		#ifdef TF_SKY_FIX
			else color = calcFogColor(posNorm);
		#endif

		#ifdef TF_AURORAS
			if (!water || inWater) {
				vec3 worldPos = normalize((gbufferModelViewInverse * vec4(pos, 0.0)).xyz);
				float auroraBrightness = 1.0 - abs(worldPos.y - 0.5) * 3.0;
				if (worldPos.y > 0.0 && auroraBrightness > 0.0) {
					vec2 auroraStart = worldPos.xz / worldPos.y * invNoiseRes;
					vec2 auroraStep = auroraStart * -0.5;
					float dither = fract(dot(gl_FragCoord.xy, vec2(0.25, 0.5))) * 0.0625;
					float time = frameTimeCounter * invNoiseRes;
					vec3 auroraColor = vec3(0.0);
					for (int i = 0; i < 16; i++) {
						vec2 auroraPos = (i * 0.0625 + dither) * auroraStep + auroraStart;
						float noise = 1.0 - abs(texture2D(noisetex, vec2(auroraPos.x * 0.5 + (time * 0.03125), auroraPos.y * 2.0)).r * 10.0 - 5.0); //primary noise layer, defines the overall shape of auroras
						if (noise > 0.0) {
							noise *= square(texture2D(noisetex, vec2(auroraPos.x * 16.0, auroraPos.y * 16.0 + (time * 0.5))).r * 2.0 - 1.0); //secondary noise layer, adds detail to the auroras
							auroraColor += hue(texture2D(noisetex, auroraPos * 3.0 + (time * 0.1875)).r * 0.5 + 0.35) * noise * square(1.0 - abs(float(i) * 0.125 - 1.0)); //tertiary noise layer, defines the color of the auroras
						}
					}
					color += sqrt(auroraColor) * 0.75 * interpolateSmooth1(auroraBrightness);
				}
			}
		#endif

		color *= 1.0 - blindness;
	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, texture2D(gaux3, texcoord).r); //gcolor, storing transparency data in alpha channel
}