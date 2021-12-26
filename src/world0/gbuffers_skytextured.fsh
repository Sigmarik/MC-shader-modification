#version 120

#include "/lib/defines.glsl"

uniform float pixelSizeX;
uniform float pixelSizeY;
uniform ivec4 blendFunc;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D texture;
uniform vec3 cameraPosition;
uniform vec3 upPosition;
        vec3 upPosNorm = normalize(upPosition);

varying vec2 texcoord;
varying vec4 glcolor;

#include "/lib/math.glsl"

/*
//required for optifine's option parsing logic.
#ifdef CUSTOM_SKY_FIX
#endif
*/

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

	#if defined(INFINITE_OCEANS) && !defined(CUSTOM_SKY_FIX)
		//check for additive blending or an old optifine version which doesn't have the blendFunc uniform
		if ((blendFunc.x == 770 && blendFunc.y == 1) || (blendFunc.x == 0 && blendFunc.y == 0)) {
			vec2 tc = gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY);
			vec3 pos = normalize((gbufferProjectionInverse * vec4(tc * 2.0 - 1.0, 1.0, 1.0)).xyz);
			float upDot = dot(pos, upPosNorm) * square(max(cameraPosition.y, 256.0) / 256.0 + 1.0) * 0.5;
			color.rgb *= 1.0 - fogify(max(upDot, 0.0), 0.0625);
		}
	#endif

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}