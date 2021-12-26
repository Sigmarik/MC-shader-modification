#version 120

#include "/lib/defines.glsl"

uniform float blindness;
uniform float far;
uniform float frameTimeCounter;
uniform float nightVision;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float screenBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D depthtex1;
uniform sampler2D gaux1;
uniform sampler2D gaux3;
uniform sampler2D gaux4;
#define lightmap gaux4
uniform sampler2D gcolor;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
uniform vec3 fogColor;

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

/*
because this has to be defined in the .fsh stage in order for optifine to recognize it:
uniform float centerDepthSmooth;

const float eyeBrightnessHalflife = 20.0;
const float centerDepthHalflife   =  1.0;

const int gaux3Format     = RGBA16;
const int gcolorFormat    = RGBA16;
const int compositeFormat = RGBA16;
const int gnormalFormat   = RGB16;
*/

#include "/lib/noiseres.glsl"

#include "/lib/math.glsl"

#include "lib/calcMainLightColor.glsl"

#include "lib/calcFogColor.glsl"

void main() {
	vec2 tc = texcoord;

	vec3 pos1 = vec3(tc, texture2D(depthtex1, tc).r);
	bool sky = pos1.z == 1.0;
	vec4 v1 = gbufferProjectionInverse * vec4(pos1 * 2.0 - 1.0, 1.0);
	pos1 = v1.xyz / v1.w;
	float dist1 = length(pos1) / far;

	vec3 color = texture2D(gcolor, tc).rgb;

	#ifdef FOG_ENABLED_NETHER
		vec3 worldPos = (gbufferModelViewInverse * vec4(pos1, 1.0)).xyz;
		vec3 fogclr = calcFogColor(normalize(worldPos));
	#else
		vec3 fogclr = fogColor;
	#endif

	if (sky) {
		color = fogclr * (1.0 - blindness);
	}
	else {
		vec4 aux = texture2D(gaux1, tc);
		float blocklight = aux.r;
		float heldlight = 0.0;

		color *= calcMainLightColor(blocklight, heldlight, dist1);

		vec2 lmcoord = aux.rg;

		#include "lib/crossprocess.glsl"

		#ifdef FOG_ENABLED_NETHER
			color = mix(fogclr, color, exp2(dist1 * exp2(abs(worldPos.y + cameraPosition.y - 128.0) * -0.03125 + 4.0) * -FOG_DISTANCE_MULTIPLIER_NETHER));
		#endif

		if (blindness > 0.0) color *= interpolateSmooth1(max(1.0 - dist1 * far * 0.2, 0.0)) * 0.5 * blindness + (1.0 - blindness);
	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, texture2D(gaux3, texcoord).r); //gcolor
}