#version 120

#include "/lib/defines.glsl"

uniform float blindness;
uniform float far;
uniform float nightVision;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float screenBrightness;
uniform sampler2D lightmap;
uniform sampler2D texture;
uniform vec3 fogColor;

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying float mcentity; //ID data of block currently being rendered.
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
varying vec3 normal;
varying vec3 pos;
varying vec4 glcolor;
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

#include "/lib/math.glsl"

#include "lib/calcMainLightColor.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

	int id = int(mcentity);

	#ifdef CLEAR_WATER
		if (id == 1) {
			color.a = 0.0;
		}
		else {
	#endif
		float dist = length(pos) / far;

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
				float blocklight = lmcoord.x;
				float heldlight = 0.0;

				color.rgb *= calcMainLightColor(blocklight, heldlight, dist);

				#include "lib/desaturate.glsl"

				#ifdef FOG_ENABLED_END
					color.rgb = mix(fogColor, color.rgb, fogify(dist, FOG_DISTANCE_MULTIPLIER_END));
				#endif

				if (blindness > 0.0) color.rgb *= interpolateSmooth1(max(1.0 - dist * far * 0.2, 0.0)) * 0.5 * blindness + (1.0 - blindness);

		#ifdef ALT_GLASS
			}
		#endif
	#ifdef CLEAR_WATER
		}
	#endif

/* DRAWBUFFERS:2563 */
	gl_FragData[0] = vec4(normal, 1.0); //gnormal
	gl_FragData[1] = vec4(lmcoord, id * 0.1, 1.0); //gaux2
	gl_FragData[2] = vec4(1.0, 0.0, 0.0, color.a); //gaux3
	gl_FragData[3] = color; //gcolor
}