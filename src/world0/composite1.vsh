#version 120

#include "/lib/defines.glsl"

uniform float adjustedTime;
uniform float blindness;
uniform float centerDepthSmooth;
uniform float day;
uniform float far;
uniform float frameTimeCounter;
uniform float night;
uniform float phase;
uniform float rainStrength;
uniform float sunset;
uniform float wetness;
uniform int heldBlockLightValue;
uniform int heldItemId;
uniform int isEyeInWater;
uniform int worldDay;
uniform int worldTime;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + vec3(0.0, gbufferModelViewInverse[3][1], 0.0);
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition;
        vec3 sunPosNorm = normalize(sunPosition);

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

#include "/lib/noiseres.glsl"

#include "/lib/goldenOffsets.glsl"

#include "/lib/math.glsl"

#include "/lib/calcHeldLightColor.glsl"

#ifdef CLOUDS
	#ifdef OLD_CLOUDS
		#include "lib/drawClouds_old.glsl"
	#else
		#include "lib/drawClouds.glsl"
	#endif
#endif

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	#ifdef EYE_ADJUST
		#ifdef BRIGHT_WATER
			eyeAdjust = 3.0 - 1.5 * max(eyeBrightnessSmooth.x / 240.0, (isEyeInWater == 1 ? eyeBrightnessSmooth.y / 480.0 + 0.5 : eyeBrightnessSmooth.y / 240.0) * (1.0 - night));
		#else
			eyeAdjust = 3.0 - 1.5 * max(eyeBrightnessSmooth.x / 240.0, (eyeBrightnessSmooth.y / 240.0) * (1.0 - night));
		#endif
	#else
		eyeAdjust = 1.5;
	#endif

	#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
		vec4 v = gbufferProjectionInverse * vec4(0.0, 0.0, centerDepthSmooth * 2.0 - 1.0, 1.0);
		dofDistance = -v.z / v.w;
	#endif

	#ifdef CLOUDS
		if (wetness < 0.999) {
			//avoid some floating point precision errors on old worlds by modulus-ing the world day.
			//normally I'd just do the modulo on ints instead of floats, but if I've learned anything about GLSL, it's that it really doesn't like ints.
			//as such, I'll cast worldDay to a float instead in hopes that it won't randomly break on someone else's GPU.
			float randTime = (mod(float(worldDay), float(noiseTextureResolution)) + worldTime / 24000.0) * 5.0;
			randTime = floor(randTime) + interpolateSmooth1(fract(randTime)) + 0.5;
			cloudDensityModifier = ((texture2D(noisetex, vec2(randTime, 0.5) * invNoiseRes).r * 2.0 - 1.0) * CLOUD_DENSITY_VARIANCE + CLOUD_DENSITY_AVERAGE) * (1.0 - wetness);
			//float r0 = texelFetch2D(noisetex, ivec2(int(randTime)     % noiseTextureResolution, 0), 0).r;
			//float r1 = texelFetch2D(noisetex, ivec2(int(randTime + 1) % noiseTextureResolution, 0), 0).r;
			//cloudDensityModifier = (mix(r0, r1, interpolateSmooth1(fract(randTime))) * 3.0 - 1.5) * (1.0 - wetness);
		}
		else {
			cloudDensityModifier = 0.0;
		}

		cloudColor             = mix(vec3(0.48, 0.5, 0.55) * day, fogColor * 0.5, wetness);
		cloudIlluminationColor = mix(vec3(1.0, 1.0, 1.0), vec3(0.45, 0.5, 0.6), wetness) * day;

		if (sunset > 0.001) {
			vec3 sunsetColor = clamp(vec3(SUNSET_COEFFICIENT_RED, SUNSET_COEFFICIENT_GREEN, SUNSET_COEFFICIENT_BLUE) + (0.2 - adjustedTime), 0.0, 1.0);
			cloudIlluminationColor = mix(cloudIlluminationColor, sunsetColor, sunset * (1.0 - wetness * 0.5));
		}

		float d = abs(eyePosition.y - CLOUD_HEIGHT) / 4.0;
		if (d < 1.0) {
			cloudInsideColor = drawClouds(vec3(0.0), vec3(0.0), d, true);
			if (cloudInsideColor.a > 0.001) {
				if (d > 0.001 && d < 0.999) cloudInsideColor.a *= interpolateSmooth1(d); //in the fadeout range
			}
		}
		else {
			cloudInsideColor = vec4(0.0);
		}
	#endif

	#include "/lib/heldlightData.glsl"

	#include "lib/colors.glsl"
}