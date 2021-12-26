#version 120

#include "/lib/defines.glsl"

uniform float blindness;
uniform float centerDepthSmooth;
uniform float far;
uniform float frameTimeCounter;
uniform int heldBlockLightValue;
uniform int heldItemId;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + vec3(0.0, gbufferModelViewInverse[3][1], 0.0);

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

#include "/lib/noiseres.glsl"

#include "/lib/goldenOffsets.glsl"

#include "/lib/math.glsl"

#include "/lib/calcHeldLightColor.glsl"

#ifdef VOID_CLOUDS
	#include "/lib/hue.glsl"

	#include "lib/drawVoidClouds.glsl"
#endif

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	#include "lib/colors.glsl"

	#include "/lib/heldlightData.glsl"

	#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
		vec4 v = gbufferProjectionInverse * vec4(0.0, 0.0, centerDepthSmooth * 2.0 - 1.0, 1.0);
		dofDistance = -v.z / v.w;
	#endif

	#ifdef VOID_CLOUDS
		float d = abs(eyePosition.y - VOID_CLOUD_HEIGHT) / 4.0;
		if (d < 1.0) {
			voidCloudInsideColor = drawVoidClouds(vec3(0.0, 1.0, 0.0), d);
			if (voidCloudInsideColor.a > 0.001) {
				if (d > 0.001 && d < 0.999) { //in the fadeout range
					//approximated cosine interpolation
					voidCloudInsideColor.a *= interpolateSmooth1(d);
					//if (d <= 0.5) voidCloudInsideColor.a *= 2.0 * d * d;
					//else voidCloudInsideColor.a *= -2.0 * d * d + 4.0 * d - 1.0;
					voidCloudInsideColor *= 0.9; //why am I doing this again?
				}
			}
		}
		else voidCloudInsideColor = vec4(0.0);
	#endif
}