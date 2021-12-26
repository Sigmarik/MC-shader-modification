#version 120

#define ALT_GLASS //Uses alternate blending method for stained glass which looks more like real stained glass
#define AMBIENT_LIGHT_COLOR_NETHER_BLUE 0.05 //Blue component of the ambient light color in the nether [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define AMBIENT_LIGHT_COLOR_NETHER_GREEN 0.10 //Green component of the ambient light color in the nether [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define AMBIENT_LIGHT_COLOR_NETHER_RED 0.20 //Red component of the ambient light color in the nether [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define CLEAR_WATER //Overwrites water texture to be completely transparent
//#define CROSS_PROCESS //Opposite of desaturation, makes everything more vibrant and saturated.
#define DYNAMIC_LIGHTS //Holding blocks that emit light will light up their surroundings
#define FOG_DISTANCE_MULTIPLIER_NETHER 1.0 //How much overall fog there is in the nether [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.2 2.4 2.6 2.8 3.0 3.5 4.0 4.5 5.0 6.0 7.0 8.0 9.0 10.0]
#define FOG_ENABLED_NETHER //Enables fog in the nether
#define THRESHOLD_ALPHA 0.6 //Anything above this opacity counts as part of the border of stained glass, and will not apply blur/reflection effects [0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95]
//#define VANILLA_LIGHTMAP //Uses vanilla light colors instead of custom ones. Requires optifine 1.12.2 HD_U_D1 or later!
#define VIGNETTE //Reduces the brightness of dynamic light around edges the of your screen

uniform float blindness;
uniform float far;
uniform float frameTimeCounter;
uniform float nightVision;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float screenBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform sampler2D lightmap;
uniform sampler2D noisetex;
uniform sampler2D texture;
uniform vec3 cameraPosition;
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

const int noiseTextureResolution = 64;
const float invNoiseRes = 1.0 / float(noiseTextureResolution);

float square(float x)        { return x * x; } //faster than pow().

float interpolateSmooth1(float x) { return x * x * (3.0 - 2.0 * x); }

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
}

vec3 calcMainLightColor(inout float blocklight, inout float heldlight, in float dist) {
	#ifdef VANILLA_LIGHTMAP
		vec3 lightclr = texture2D(lightmap, vec2(blocklight, 0.98675)).rgb; //31/32 is the maximum light level in vanilla
	#endif

	blocklight *= blocklight;

	#ifndef VANILLA_LIGHTMAP
		vec3 lightclr = vec3(0.0);
		lightclr += blockLightColor * blocklight; //blocklight
		lightclr += vec3(AMBIENT_LIGHT_COLOR_NETHER_RED, AMBIENT_LIGHT_COLOR_NETHER_GREEN, AMBIENT_LIGHT_COLOR_NETHER_BLUE); //skylight
		lightclr += clamp(nightVision, 0.0, 1.0) * 0.5 + clamp(screenBrightness, 0.0, 1.0) * 0.1;
	#endif

	#ifdef DYNAMIC_LIGHTS
		float d = dist * heldLightDistModifier;
		if (d < heldLightColor.a * 2.0) {
			heldlight = heldLightColor.a / square(d + 2.0) * 0.75 * (heldLightColor.a * 2.0 - d) / (blocklight * 32.0 + heldLightColor.a);
			#ifdef VIGNETTE
				heldlight *= (1.0 - length(gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY) - 0.5)); //helps reduce the "circle that follows you" effect by making held lights darker towards the edge of your screen
			#endif
			lightclr += heldLightColor.rgb * heldlight;
		}
	#endif

	return lightclr;
}

#ifdef FOG_ENABLED_NETHER
	vec3 calcFogColor(vec3 pos) {
		float n = square(texture2D(noisetex, frameTimeCounter * vec2(0.21562, 0.19361) * invNoiseRes).r) - 0.1;
		if (n > 0.0) {
			vec3 brightFog = vec3(fogColor.r * (n + 1.0), mix(fogColor.g, fogColor.r, n), fogColor.b);
			return mix(fogColor, brightFog, fogify(pos.y, 0.125));
		}
		else {
			return fogColor;
		}
	}
#endif

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

					#ifdef CROSS_PROCESS
						vec3 ambientCrossColor = vec3(1.3, 1.0, 0.8);
						vec3 blockCrossColor = mix(vec3(1.3, 1.4, 1.0), vec3(1.2, 1.1, 1.0), eyeBrightnessSmooth.x / 240.0);
						vec3 finalCrossColor = mix(ambientCrossColor, blockCrossColor, lmcoord.x);
						color.rgb = clamp(color.rgb * finalCrossColor - vec3(color.g + color.b, color.r + color.b, color.r + color.g) * 0.1, 0.0, 1.0);
					#endif

					#ifdef FOG_ENABLED_NETHER
						color.rgb = mix(calcFogColor(pos / (dist * far)), color.rgb, exp2(dist * exp2(abs(pos.y + cameraPosition.y - 128.0) * -0.03125 + 4.0) * -FOG_DISTANCE_MULTIPLIER_NETHER));
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