#version 120

#include "/lib/defines.glsl"

uniform float far;
uniform float frameTimeCounter;
uniform int heldBlockLightValue;
uniform int heldItemId;
uniform int isEyeInWayer;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D noisetex;

#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
	varying float dofDistance; //Un-projected centerDepthSmooth
#endif
varying float eyeAdjust;
#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying vec2 texcoord;
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

#include "/lib/noiseres.glsl"

#include "/lib/calcHeldLightColor.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	gl_Position = ftransform();

	#ifdef EYE_ADJUST
		eyeAdjust = 3.0 - 1.5 * max(eyeBrightnessSmooth.x / 240.0, (isEyeInWayer == 1 ? eyeBrightnessSmooth.y / 480.0 + 0.5 : eyeBrightnessSmooth.y / 240.0));
	#else
		eyeAdjust = 1.5;
	#endif

	#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
		vec4 v = gbufferProjectionInverse * vec4(0.0, 0.0, centerDepthSmooth * 2.0 - 1.0, 1.0);
		dofDistance = -v.z / v.w;
	#endif

	#include "/lib/heldlightData.glsl"
}