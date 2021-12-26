#version 120

#include "/lib/defines.glsl"

uniform float blindness;
uniform float far;
uniform float nightVision;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float screenBrightness;
uniform int isEyeInWater;
uniform ivec2 eyeBrightnessSmooth;
uniform sampler2D lightmap;
uniform sampler2D texture;
uniform vec3 skyColor;

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying float id; //ID data of block currently being rendered.
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 normal;
varying vec4 glcolor;
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

#include "/lib/math.glsl"

#include "lib/calcMainLightColor.glsl"

void main() {
	float realId = id;
	vec4 color = texture2D(texture, texcoord) * glcolor;

	float skylight = lmcoord.y;
	float blocklight = lmcoord.x;
	float heldlight = 0.0;

	#ifdef BRIGHT_WATER
		if (isEyeInWater == 1) skylight = skylight * 0.5 + 0.5;
	#endif

	#ifdef ALT_GLASS
		bool lightable = true;
	#endif

	if (abs(realId - 0.2) < 0.02) { //stained glass
		if (color.a > THRESHOLD_ALPHA) {
			color.a = 1.0; //make borders opaque
			realId = 0.0;
		}
		#ifdef ALT_GLASS
			else lightable = false; //don't apply lighting effects to the center of glass when ALT_GLASS is enabled
		#endif
	}

	#ifdef ALT_GLASS
		if (lightable) {
	#endif
			color.rgb *= calcMainLightColor(blocklight, skylight, heldlight, 1.0 / far);

			#include "/lib/crossprocess.glsl"

			if (blindness > 0) color.rgb *= 0.5 * blindness + (1.0 - blindness);

	#ifdef ALT_GLASS
		}
	#endif

/* DRAWBUFFERS:3562 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(lmcoord, realId, 1.0); //gaux2
	gl_FragData[2] = vec4(1.0, 0.0, 0.0, color.a); //gaux3
	gl_FragData[3] = vec4(normal, 1.0); //gnormal
}