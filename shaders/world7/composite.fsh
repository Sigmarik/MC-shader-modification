#version 120

#define BRIGHT_WATER //Overrides light levels under water to be higher
//#define CROSS_PROCESS //Opposite of desaturation, makes everything more vibrant and saturated.
//#define CUBIC_CHUNKS //Disables black fog/sky colors below Y=0
#define DYNAMIC_LIGHTS //Holding blocks that emit light will light up their surroundings
#define FOG_DISTANCE_MULTIPLIER_TF 0.25 //How far away fog starts to appear in the twilight forest [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.2 2.4 2.6 2.8 3.0 3.5 4.0 4.5 5.0 6.0 7.0 8.0 9.0 10.0]
#define FOG_ENABLED_TF //Enables fog in the twilight forest
#define TF_AURORAS //Adds auroras to the sky in the twilight forest
#define TF_SKY_FIX //Enable this if the sky looks wrong in the twilight forest
#define UNDERWATER_FOG //Applies fog to water
//#define VANILLA_LIGHTMAP //Uses vanilla light colors instead of custom ones. Requires optifine 1.12.2 HD_U_D1 or later!
#define VIGNETTE //Reduces the brightness of dynamic light around edges the of your screen
#define WATER_ABSORB_B 0.10 //Blue component of the water absorption color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define WATER_ABSORB_G 0.05 //Green component of the water absorption color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define WATER_ABSORB_R 0.20 //Red component of the water absorption color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define WATER_SCATTER_B 0.50 //Blue component of the water fog color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define WATER_SCATTER_G 0.40 //Green component of the water fog color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define WATER_SCATTER_R 0.05 //Red component of the water fog color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]

uniform float blindness;
uniform float far;
uniform float frameTimeCounter;
uniform float nightVision;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float screenBrightness;
uniform int isEyeInWater;
bool inWater = isEyeInWater == 1; //quicker to type
uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D gaux3;
uniform sampler2D gaux4;
uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + gbufferModelViewInverse[3].xyz; //because cameraPosition isn't actually the position of the camera -_-
uniform vec3 fogColor;
uniform vec3 skyColor;

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying vec2 texcoord;
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

/*
because this has to be defined in the .fsh stage in order for optifine to recognize it:
uniform float centerDepthSmooth;

const float eyeBrightnessHalflife = 20.0;
const float centerDepthHalflife   =  1.0;

const int gcolorFormat    = RGBA16;
const int compositeFormat = RGBA16;
const int gaux3Format     = RGBA16;
const int gnormalFormat   = RGB16;
*/

const int noiseTextureResolution = 64;
const float invNoiseRes = 1.0 / float(noiseTextureResolution);

float square(float x)        { return x * x; } //faster than pow().

float interpolateSmooth1(float x) { return x * x * (3.0 - 2.0 * x); }

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
}

vec3 calcMainLightColor(inout float blocklight, inout float skylight, inout float heldlight, in float dist) {
	#ifdef VANILLA_LIGHTMAP
		vec3 lightclr = texture2D(gaux4, vec2(blocklight, skylight)).rgb;
	#endif

	skylight *= skylight;
	blocklight = square(max(blocklight - skylight * 0.5, 0.0));

	#ifndef VANILLA_LIGHTMAP
		vec3 lightclr = vec3(0.0);
		lightclr += mix(vec3(1.0, 0.5, 0.15), vec3(1.0, 0.85, 0.7), eyeBrightnessSmooth.x / 240.0) * blocklight; //blocklight
		lightclr += mix(skyColor, vec3(1.0), skylight) * skylight; //skylight
		lightclr += clamp(nightVision, 0.0, 1.0) * 0.5 + clamp(screenBrightness, 0.0, 1.0) * 0.1;
	#endif

	#ifdef DYNAMIC_LIGHTS
		float d = dist * heldLightDistModifier;
		if (d < heldLightColor.a * 2.0) {
			heldlight = heldLightColor.a / square(d + 3.0) * (heldLightColor.a * 2.0 - d) / ((skylight + blocklight) * 64.0 + heldLightColor.a);
			#ifdef VIGNETTE
				heldlight *= (1.0 - length(gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY) - 0.5)); //helps reduce the "circle that follows you" effect by making held lights darker towards the edge of your screen
			#endif
			lightclr += heldLightColor.rgb * heldlight;
		}
	#endif

	return lightclr;
}

vec3 calcFogColor(vec3 pos) {
	#ifndef CUBIC_CHUNKS
		if (cameraPosition.y < -gbufferModelViewInverse[3][1]) return vec3(0.0);
	#endif

	return mix(skyColor, fogColor, fogify(max(dot(pos, gbufferModelView[1].xyz), 0.0), 0.0625));
}

vec3 calcUnderwaterFogColor(vec3 color, float dist, float brightness) {
	dist *= far; //use absolute distance, not relative distance

	vec3 absorb = exp2(-dist * vec3(WATER_ABSORB_R, WATER_ABSORB_G, WATER_ABSORB_B));
	vec3 scatter = vec3(WATER_SCATTER_R, WATER_SCATTER_G, WATER_SCATTER_B) * (1.0 - absorb) * brightness;
	return color * absorb + scatter;
}

vec3 calcUnderwaterFogColorInfinity(float brightness) {
	//simpler algorithm for the special case where distance = infinity (for looking at unobstructed sky while underwater)
	return vec3(WATER_SCATTER_R, WATER_SCATTER_G, WATER_SCATTER_B) * brightness;
}

vec3 hue(float h) {
	h = fract(h) * 6.0;
	return clamp(
		vec3(
			abs(h - 3.0) - 1.0,
			2.0 - abs(h - 2.0),
			2.0 - abs(h - 4.0)
		),
		0.0,
		1.0
	);
}

void main() {
	vec2 tc = texcoord;

	vec3 pos = vec3(tc, texture2D(depthtex0, tc).r);
	bool nothingInFrontOfSky = pos.z == 1.0;
	vec4 v = gbufferProjectionInverse * vec4(pos * 2.0 - 1.0, 1.0);
	pos = v.xyz / v.w;
	float dist = length(pos);
	vec3 posNorm = pos / dist;
	dist /= far;

	vec3 pos1 = vec3(tc, texture2D(depthtex1, tc).r);
	bool sky = pos1.z == 1.0;
	vec4 v1 = gbufferProjectionInverse * vec4(pos1 * 2.0 - 1.0, 1.0);
	pos1 = v1.xyz / v1.w;
	float dist1 = length(pos1) / far;

	vec3 color = texture2D(gcolor, tc).rgb;
	vec4 aux = texture2D(gaux1, tc);

	vec4 aux2 = texture2D(gaux2, tc);
	vec4 normal = texture2D(gnormal, tc);
	normal.xyz = normal.xyz * 2.0 - 1.0;
	bool water = int(aux2.b * 10.0 + 0.1) == 1; //only ID I'm actually checking for in this stage.

	float skylight = aux.g;
	float blocklight = aux.r;
	float heldlight = 0.0;

	float underwaterEyeBrightness = eyeBrightnessSmooth.y / 240.0;
	#ifdef BRIGHT_WATER
		underwaterEyeBrightness = underwaterEyeBrightness * 0.5 + 0.5;
	#endif

	if (!sky) {
		#ifdef BRIGHT_WATER
			if      ( water && !inWater) skylight = max(skylight, aux2.g * 0.5);
			else if (!water &&  inWater) skylight = skylight * 0.5 + 0.5;
		#endif

		color *= calcMainLightColor(blocklight, skylight, heldlight, dist1);

		vec2 lmcoord = aux.rg;

		#ifdef CROSS_PROCESS
			vec3 skyCrossColor    = mix(mix(vec3(1.4, 1.2, 1.1), vec3(1.0, 1.1, 1.4), night), vec3(1.0), wetness); //cross processing color from the sun
			vec3 blockCrossColor  = mix(vec3(1.4, 1.0, 0.8), vec3(1.2, 1.1, 1.0), eyeBrightnessSmooth.x / 240.0); //cross processing color from block lights
			vec3 finalCrossColor  = mix(mix(vec3(1.0), skyCrossColor, lmcoord.y), blockCrossColor, lmcoord.x); //final cross-processing color (blockCrossColor takes priority over skyCrossColor)
			color.rgb = clamp(color.rgb * finalCrossColor - vec3(color.g + color.b, color.r + color.b, color.r + color.g) * 0.1, 0.0, 1.0);
		#endif

		//!water && !inWater = white fog in stage 1
		//!water &&  inWater = blue fog
		// water && !inWater = blue fog in stage 1 then white fog in stage 2
		// water &&  inWater = white fog in stage 1 then blue fog in stage 2

		//if water xor  inwater then blue fog
		//if water ==   inwater then white fog (stage 1)
		//if water and  inwater then blue fog
		//if water and !inwater then white fog (stage 2)

		#ifdef UNDERWATER_FOG
			if      (water && !inWater) color = calcUnderwaterFogColor(color, dist1 - dist, aux2.g * aux2.g);
			else if (!water && inWater) color = calcUnderwaterFogColor(color, dist1, underwaterEyeBrightness);
		#endif

		#ifdef FOG_ENABLED_TF
			if (water == inWater) {
				float d = (water ? dist1 - dist : dist1) - 0.2;
				if (d > 0.0) {
					float y = (gbufferModelViewInverse * vec4(pos1, 0.0)).y + eyePosition.y;
					d = fogify(d * exp2(1.5 - y * 0.015625), FOG_DISTANCE_MULTIPLIER_TF);
					float actualEyeBrightness = eyeBrightness.y / 240.0;
					#ifdef BRIGHT_WATER
						if (inWater) actualEyeBrightness = actualEyeBrightness * 0.5 + 0.5;
					#endif
					color = mix(calcFogColor(posNorm) * min(max(aux.g, actualEyeBrightness) * 2.0, 1.0), color, d);
				}
			}
		#endif

		if (blindness > 0.0) color.rgb *= interpolateSmooth1(max(1.0 - dist1 * far * 0.2, 0.0)) * 0.5 * blindness + (1.0 - blindness);
	}
	else {
		if (water && !inWater) {
			color = calcUnderwaterFogColorInfinity(aux2.g * aux2.g);
		}
		else if (!water && inWater) {
			color = calcUnderwaterFogColorInfinity(underwaterEyeBrightness);
		}
		#ifdef TF_SKY_FIX
			else color = calcFogColor(posNorm);
		#endif

		#ifdef TF_AURORAS
			if (!water || inWater) {
				vec3 worldPos = normalize((gbufferModelViewInverse * vec4(pos, 0.0)).xyz);
				float auroraBrightness = 1.0 - abs(worldPos.y - 0.5) * 3.0;
				if (worldPos.y > 0.0 && auroraBrightness > 0.0) {
					vec2 auroraStart = worldPos.xz / worldPos.y * invNoiseRes;
					vec2 auroraStep = auroraStart * -0.5;
					float dither = fract(dot(gl_FragCoord.xy, vec2(0.25, 0.5))) * 0.0625;
					float time = frameTimeCounter * invNoiseRes;
					vec3 auroraColor = vec3(0.0);
					for (int i = 0; i < 16; i++) {
						vec2 auroraPos = (i * 0.0625 + dither) * auroraStep + auroraStart;
						float noise = 1.0 - abs(texture2D(noisetex, vec2(auroraPos.x * 0.5 + (time * 0.03125), auroraPos.y * 2.0)).r * 10.0 - 5.0); //primary noise layer, defines the overall shape of auroras
						if (noise > 0.0) {
							noise *= square(texture2D(noisetex, vec2(auroraPos.x * 16.0, auroraPos.y * 16.0 + (time * 0.5))).r * 2.0 - 1.0); //secondary noise layer, adds detail to the auroras
							auroraColor += hue(texture2D(noisetex, auroraPos * 3.0 + (time * 0.1875)).r * 0.5 + 0.35) * noise * square(1.0 - abs(float(i) * 0.125 - 1.0)); //tertiary noise layer, defines the color of the auroras
						}
					}
					color += sqrt(auroraColor) * 0.75 * interpolateSmooth1(auroraBrightness);
				}
			}
		#endif

		color *= 1.0 - blindness;
	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, texture2D(gaux3, texcoord).r); //gcolor, storing transparency data in alpha channel
}