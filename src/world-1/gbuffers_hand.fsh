#version 120

#include "/lib/defines.glsl"

uniform float blindness;
uniform float far;
uniform float nightVision;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float screenBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform sampler2D lightmap;
uniform sampler2D texture;

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying float mcentity; //ID data of block currently being rendered.
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
varying vec3 normal;
varying vec4 glcolor;
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

#include "/lib/math.glsl"

#include "lib/calcMainLightColor.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

	int id = int(mcentity);

	#ifdef ALT_GLASS
		bool lightable = true;
	#endif

	if (id == 2) { //stained glass
		if (color.a > THRESHOLD_ALPHA) {
			color.a = 1.0;//1.0 - (1.0 - color.a) * 0.5; //make borders more opaque
			id = 0;
		}
		#ifdef ALT_GLASS
			else lightable = false; //don't apply lighting effects to the center of glass when ALT_GLASS is enabled
		#endif
	}

	#ifdef ALT_GLASS
		if (lightable) {
	#endif
			float blocklight = lmcoord.x;
			float heldlight = 0.0;

			color.rgb *= calcMainLightColor(blocklight, heldlight, 2.0 / far);

			#include "lib/crossprocess.glsl"

			if (blindness > 0.0) color.rgb *= 0.5 * blindness + (1.0 - blindness);

	#ifdef ALT_GLASS
		}
	#endif

/* DRAWBUFFERS:3562 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(lmcoord, id * 0.1, 1.0); //gaux2
	gl_FragData[2] = vec4(1.0, 0.0, 0.0, color.a); //gaux3
	gl_FragData[3] = vec4(normal, 1.0); //gnormal
}