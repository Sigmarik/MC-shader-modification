#version 120

#include "/lib/defines.glsl"

uniform float frameTimeCounter;
uniform int blockEntityId;
uniform mat4 gbufferModelViewInverse;
uniform sampler2D gaux1; //Overworld texture
uniform sampler2D gaux2; //End island texture
uniform sampler2D noisetex;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 pos;
varying vec4 glcolor;

#include "/lib/noiseres.glsl"

#include "/lib/goldenOffsets.glsl"

#include "/lib/math.glsl"

#ifdef END_PORTAL_EFFECTS_NETHER
	#include "/lib/hue.glsl"

	#if END_PORTAL_BACKGROUND_NETHER == 2
		#include "/lib/endEffects.glsl"
	#endif

	#if END_PORTAL_CLOUDS_NETHER == 1
		#ifdef OLD_CLOUDS
			#include "/lib/fastDrawClouds_old.glsl"
		#else
			#include "/lib/fastDrawClouds.glsl"
		#endif
	#elif END_PORTAL_CLOUDS_NETHER == 2
		#include "/lib/fastDrawVoidClouds.glsl"
	#endif
#endif

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

	#ifdef END_PORTAL_EFFECTS_NETHER
		if (blockEntityId == 119) {
			vec3 worldPos = (gbufferModelViewInverse * vec4(pos, 1.0)).xyz;

			#include "lib/endPortalEffects.glsl"
		}
	#endif

/* DRAWBUFFERS:04 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(lmcoord, 1.0, 1.0); //gaux1
}