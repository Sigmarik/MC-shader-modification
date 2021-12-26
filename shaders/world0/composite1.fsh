#version 120

#define ALT_GLASS //Uses alternate blending method for stained glass which looks more like real stained glass
#define BLUR_ENABLED //Is blur enabled at all?
#define BRIGHT_WATER //Overrides light levels under water to be higher
#define CLOUD_HEIGHT 256.0 //Y level of fancy clouds [128.0 144.0 160.0 176.0 192.0 208.0 224.0 240.0 256.0 272.0 288.0 304.0 320.0 336.0 352.0 368.0 384.0 400.0 416.0 432.0 448.0 464.0 480.0 496.0 512.0]
#define CLOUD_NORMALS //Dynamically light clouds based on weather they're facing towards or away from the sun. Mild performance impact!
#define CLOUDS //3D clouds (partially volumetric too). Mild performance impact!
//#define CROSS_PROCESS //Opposite of desaturation, makes everything more vibrant and saturated.
//#define CUBIC_CHUNKS //Disables black fog/sky colors below Y=0
#define DOF_STRENGTH 0 //Blurs things that are at a different distance than whatever's in the center of your screen [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define DYNAMIC_LIGHTS //Holding blocks that emit light will light up their surroundings
#define FOG_DISTANCE_MULTIPLIER_OVERWORLD 0.25 //How far away fog starts to appear in the overworld. [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.2 2.4 2.6 2.8 3.0 3.5 4.0 4.5 5.0 6.0 7.0 8.0 9.0 10.0]
#define FOG_ENABLED_OVERWORLD //Enables fog in the overworld. It is recommended to have this enabled if you also have infinite oceans enabled!
#define GLASS_BLUR 8 //Blurs things behind stained glass [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define ICE_BLUR 4 //Blurs things behind ice [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define ICE_NORMALS //Distorts things reflected by ice. Has no effect when reflections are disabled!
#define ICE_REFRACT //Distorts things behind ice
#define INFINITE_OCEANS //Simulates water out to the horizon instead of just your render distance.
//#define OLD_CLOUDS //Uses old cloud rendering method from earlier versions, for people who don't like pretty things.
#define RAIN_BLUR 10 //Blurs the world while raining [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define RAINBOWS //If enabled, rainbows will appear when the weather changes from rainy to clear
#define REFLECT //Reflects the sun/sky onto reflective surfaces. Does not add reflections of terrain!
#define SEA_LEVEL 63 //Sea level for infinite oceans. Change this if you use custom worldgen. [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256]
#define SUNSET_COEFFICIENT_BLUE 6.2 //Blue sunset coefficient. Higher values will result in the blue color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time. [6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 8.0]
#define SUNSET_COEFFICIENT_GREEN 6.7 //Green sunset coefficient. Higher values will result in the green color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time. [6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 8.0]
#define SUNSET_COEFFICIENT_RED 7.2 //Red sunset coefficient. Higher values will result in the red color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time. [6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 8.0]
#define UNDERWATER_BLUR 8 //Blurs the world while underwater [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define UNDERWATER_FOG //Applies fog to water
//#define VANILLA_LIGHTMAP //Uses vanilla light colors instead of custom ones. Requires optifine 1.12.2 HD_U_D1 or later!
#define VIGNETTE //Reduces the brightness of dynamic light around edges the of your screen
#define WATER_ABSORB_B 0.10 //Blue component of the water absorption color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define WATER_ABSORB_G 0.05 //Green component of the water absorption color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define WATER_ABSORB_R 0.20 //Red component of the water absorption color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define WATER_BLUR 4 //Blurs things behind water [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define WATER_NORMALS //Distorts things reflected by water. Has no effect when reflections are disabled!
#define WATER_REFRACT //Distorts things behind water
#define WATER_SCATTER_B 0.50 //Blue component of the water fog color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define WATER_SCATTER_G 0.40 //Green component of the water fog color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define WATER_SCATTER_R 0.05 //Red component of the water fog color [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]

uniform float adjustedTime;
uniform float aspectRatio;
uniform float blindness;
uniform float day;
uniform float far;
uniform float frameTimeCounter;
uniform float night;
uniform float nightVision;
uniform float phase;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float rainStrength;
uniform float screenBrightness;
uniform float sunset;
uniform float wetness;
uniform int isEyeInWater;
uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D composite;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D gaux4;
uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + gbufferModelViewInverse[3].xyz; //because cameraPosition isn't actually the position of the camera -_-
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition;
        vec3 sunPosNorm = normalize(sunPosition);
uniform vec3 upPosition;
        vec3 upPosNorm = normalize(upPosition);

#ifdef CLOUDS
	varying float cloudDensityModifier; //Random fluctuations every few minutes.
#endif
#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
	varying float dofDistance; //Un-projected centerDepthSmooth
#endif
varying float eyeAdjust; //How much brighter to make the world
#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
#ifdef CLOUDS
	varying vec3 cloudColor; //Color of the side of clouds facing away from the sun.
	varying vec3 cloudIlluminationColor; //Color of the side of clouds facing towards the sun.
#endif
varying vec3 shadowColor; //Color of shadows. Sky-colored, to simulate indirect lighting.
varying vec3 skyLightColor; //Color of sky light. Is usually white during the day, and very dark blue at night.
#ifdef CLOUDS
	varying vec4 cloudInsideColor; //Color to render over your entire screen when inside a cloud.
#endif
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

/*
//required on older versions of optifine for its option-parsing logic.
#ifdef BLUR_ENABLED
#endif
*/

const float actualSeaLevel = SEA_LEVEL - 0.1111111111111111; //water source blocks are 8/9'ths of a block tall, so SEA_LEVEL - 1/9.

const int noiseTextureResolution = 64;
const float invNoiseRes = 1.0 / float(noiseTextureResolution);

//sines and cosines of multiples of the golden angle (~2.4 radians)
const vec2 goldenOffset0 = vec2( 0.675490294261524, -0.73736887807832 ); //2.39996322972865332
const vec2 goldenOffset1 = vec2(-0.996171040864828,  0.087425724716963); //4.79992645945731
const vec2 goldenOffset2 = vec2( 0.793600751291696,  0.608438860978863); //7.19988968918596
const vec2 goldenOffset3 = vec2(-0.174181950379306, -0.98471348531543 ); //9.59985291891461
const vec2 goldenOffset4 = vec2(-0.53672805262632,   0.843755294812399); //11.9998161486433
const vec2 goldenOffset5 = vec2( 0.965715074375778, -0.259604304901489); //14.3997793783719
const vec2 goldenOffset6 = vec2(-0.887448429245268, -0.460907024713344); //16.7997426081006
const vec2 goldenOffset7 = vec2( 0.343038630874082,  0.939321296324125); //19.1997058378292
const vec2 goldenOffset8 = vec2( 0.38155640847493,  -0.924345556137807); //21.5996690675579
const vec2 goldenOffset9 = vec2(-0.905734272555614, -0.04619144594037 ); //23.9996322972865

#ifdef CROSS_PROCESS
	const vec3 MOON_GLOW_COLOR = vec3(0.075, 0.1,   0.2 ); //Mixed with sky color based on distance from moon
	const vec3 NIGHT_SKY_COLOR = vec3(0.02,  0.025, 0.05); //Added to sky color at night to avoid it being completely black
	const vec3 SUN_GLOW_COLOR  = vec3(1.0,   1.0,   1.0 ); //Mixed with sky color based on distance from sun
#else
	const vec3 MOON_GLOW_COLOR = vec3(0.1,   0.1,   0.2 ); //Mixed with sky color based on distance from moon
	const vec3 NIGHT_SKY_COLOR = vec3(0.025, 0.025, 0.05); //Added to sky color at night to avoid it being completely black
	const vec3 SUN_GLOW_COLOR  = vec3(0.8,   0.9,   1.0 ); //Mixed with sky color based on distance from sun
#endif

float square(float x)        { return x * x; } //faster than pow().
float lengthSquared2(vec2 v) { return dot(v, v); }
float lengthSquared3(vec3 v) { return dot(v, v); }

float interpolateSmooth1(float x) { return x * x * (3.0 - 2.0 * x); }
vec2  interpolateSmooth2(vec2 v)  { return v * v * (3.0 - 2.0 * v); }
vec3  interpolateSmooth3(vec3 v)  { return v * v * (3.0 - 2.0 * v); }

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
}

vec3 calcMainLightColor(inout float blocklight, inout float skylight, inout float heldlight, in float dist) {
	#ifdef VANILLA_LIGHTMAP
		vec3 lightclr = texture2D(gaux4, vec2(blocklight, skylight)).rgb;
	#endif

	skylight = skylight * skylight * (1.0 - rainStrength * 0.5);
	blocklight = square(max(blocklight - skylight * day * 0.5, 0.0));

	#ifndef VANILLA_LIGHTMAP
		vec3 lightclr = vec3(0.0);
		lightclr += blockLightColor * blocklight; //blocklight
		lightclr += mix(shadowColor, skyLightColor, skylight) * skylight; //skylight
		lightclr += clamp(nightVision, 0.0, 1.0) * 0.5 + clamp(screenBrightness, 0.0, 1.0) * 0.1;
	#endif

	#ifdef DYNAMIC_LIGHTS
		float d = dist * heldLightDistModifier;
		if (d < heldLightColor.a * 2.0) {
			heldlight = heldLightColor.a / square(d + 3.0) * (heldLightColor.a * 2.0 - d) / ((skylight * day + blocklight) * 64.0 + heldLightColor.a);
			#ifdef VIGNETTE
				heldlight *= (1.0 - length(gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY) - 0.5)); //helps reduce the "circle that follows you" effect by making held lights darker towards the edge of your screen
			#endif
			lightclr += heldLightColor.rgb * heldlight;
		}
	#endif

	return lightclr;
}

vec2 waterNoise(vec2 coord, float time) {
	coord *= invNoiseRes;

	vec2 noise = vec2(0.0);
	noise += (texture2D(noisetex, (coord + goldenOffset0 * time)      ).rg - 0.5);          //1.0 / 1.0
	noise += (texture2D(noisetex, (coord + goldenOffset1 * time) * 1.5).rg - 0.5) * 0.6666; //1.0 / 1.5
	noise += (texture2D(noisetex, (coord + goldenOffset2 * time) * 2.0).rg - 0.5) * 0.5;    //1.0 / 2.0
	noise += (texture2D(noisetex, (coord + goldenOffset3 * time) * 2.5).rg - 0.5) * 0.4;    //1.0 / 2.5
	noise += (texture2D(noisetex, (coord + goldenOffset4 * time) * 3.0).rg - 0.5) * 0.3333; //1.0 / 3.0
	noise += (texture2D(noisetex, (coord + goldenOffset5 * time) * 3.5).rg - 0.5) * 0.2857; //1.0 / 3.5
	noise += (texture2D(noisetex, (coord + goldenOffset6 * time) * 4.0).rg - 0.5) * 0.25;   //1.0 / 4.0
	return noise;
}

vec2 waterNoiseLOD(vec2 coord, float distance) {
	float lod = log2(distance * 0.0625); //level of detail
	float scale = floor(lod);
	coord *= exp2(-scale); //each time the distance doubles, so will the scale factor
	float middle = fract(lod);
	float time = frameTimeCounter * invNoiseRes * 2.0;

	vec2 noise1 = waterNoise(coord, time / max(scale, 1.0));
	vec2 noise2 = waterNoise(coord * 0.5, time / max(scale + 1.0, 1.0));

	return mix(noise1, noise2, interpolateSmooth1(middle));
}

vec3 iceNoise(vec2 coord) {
	coord *= invNoiseRes;

	vec3 noise = vec3(0.0);
	noise += texture2D(noisetex, coord        ).rgb;
	noise += texture2D(noisetex, coord * 0.5  ).rgb;
	noise += texture2D(noisetex, coord * 0.25 ).rgb;
	noise += texture2D(noisetex, coord * 0.125).rgb;
	noise -= 2.0; //0.5 * 4.0
	return noise;
}

vec3 iceNoiseLOD(vec2 coord, float distance) {
	float lod = log2(distance); //level of detail
	float scale = exp2(-floor(lod)); //each time the distance doubles, so will the scale factor
	coord *= scale;
	float middle = fract(lod);

	vec3 noise1 = iceNoise(coord      );
	vec3 noise2 = iceNoise(coord * 0.5);

	return mix(noise1, noise2, interpolateSmooth1(middle));
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, upPosNorm) * 2.0; //not much, what's up with you?
	bool top = upDot > 0.0;
	float sunDot = dot(pos, sunPosNorm) * 0.5 + 0.5;
	float rainCoefficient = max(rainStrength, wetness);
	vec3 color;
	vec3 skyclr = mix(skyColor, fogColor * 0.65, rainCoefficient);
	vec3 fogclr = fogColor * (1.0 - rainCoefficient * 0.5);

	if (top) {
		color = skyclr + NIGHT_SKY_COLOR * (1.0 - day) * (1.0 - rainStrength); //avoid pitch black sky at night
		if (day > 0.001) color = mix(color, SUN_GLOW_COLOR,  0.75 / ((1.0 - sunDot) * 16.0 + 1.0) * day   * (1.0 - rainStrength * 0.75)); //make the sun illuminate the sky around it
		else             color = mix(color, MOON_GLOW_COLOR, 0.75 / (       sunDot  * 16.0 + 1.0) * night * (1.0 - rainStrength       ) * phase); //make the moon illuminate the sky around it
	}
	else color = fogclr;

	if (sunset > 0.001 && rainCoefficient < 0.999) {
		vec3 sunsetColor = interpolateSmooth3(clamp(vec3(SUNSET_COEFFICIENT_RED, SUNSET_COEFFICIENT_GREEN, SUNSET_COEFFICIENT_BLUE) - adjustedTime + upDot + sunDot * 0.2 * (1.0 - night), 0.0, 1.0)); //main sunset gradient
		sunsetColor = mix(fogclr, sunsetColor, (sunDot * 0.5 + 0.5) * sunset * (1.0 - rainCoefficient)); //fade in at sunset and out when not looking at the sun
		color = mix(color, sunsetColor, fogify(upDot, 0.25)); //mix with final color based on how close we are to the horizon
	}
	else if (top) color = mix(color, fogclr, fogify(upDot, 0.25));

	return color;
}

vec3 calcFogColor(vec3 pos) {
	#ifndef CUBIC_CHUNKS
		if (cameraPosition.y < -gbufferModelViewInverse[3][1]) return vec3(0.0);
	#endif
	float upDot = dot(pos, upPosNorm) * 2.0;
	float sunDot = dot(sunPosNorm, pos) * 0.5 + 0.5;
	float rainCoefficient = max(rainStrength, wetness);
	vec3 color;
	vec3 skyclr = mix(skyColor, fogColor * 0.65, rainCoefficient);
	vec3 fogclr = fogColor * (1.0 - rainCoefficient * 0.5);

	if (upDot > 0.0) color = skyclr + NIGHT_SKY_COLOR * (1.0 - day) * (1.0 - rainStrength); //avoid pitch black sky at night
	else color = fogclr;

	if (sunset > 0.001 && rainCoefficient < 0.999) {
		vec3 sunsetColor = interpolateSmooth3(clamp(vec3(SUNSET_COEFFICIENT_RED, SUNSET_COEFFICIENT_GREEN, SUNSET_COEFFICIENT_BLUE) - adjustedTime + upDot + sunDot * 0.2 * (1.0 - night), 0.0, 1.0)); //main sunset gradient
		sunsetColor = mix(fogclr, sunsetColor, (sunDot * 0.5 + 0.5) * sunset * (1.0 - rainCoefficient)); //fade in at sunset and out when not looking at the sun
		color = mix(color, sunsetColor, fogify(upDot, 0.25)); //mix with final color based on how close we are to the horizon
	}
	else if (upDot > 0.0) color = mix(color, fogclr, fogify(upDot, 0.25));

	#ifdef RAINBOWS
		float rainbowStrength = (wetness - rainStrength) * day * 0.25;
		float rainbowHue = (sunDot - 0.25) * -24.0;
		if (rainbowStrength > 0.01 && rainbowHue > 0.0 && rainbowHue < 1.0) {
			rainbowHue *= 6.0;
			color.r += clamp(1.5 - abs(rainbowHue - 1.5), 0.0, 1.0) * rainbowStrength;
			color.g += clamp(2.0 - abs(rainbowHue - 3.0), 0.0, 1.0) * rainbowStrength;
			color.b += clamp(1.5 - abs(rainbowHue - 4.5), 0.0, 1.0) * rainbowStrength;
		}
	#endif

	return color;
}

vec3 calcUnderwaterFogColor(vec3 color, float dist, float brightness) {
	dist *= far;

	vec3 absorb = exp2(-dist * mix(vec3(WATER_ABSORB_R, WATER_ABSORB_G, WATER_ABSORB_B), vec3(0.375, 0.3125, 0.25), rainStrength));
	vec3 scatter = mix(vec3(WATER_SCATTER_R, WATER_SCATTER_G, WATER_SCATTER_B), vec3(0.0625), rainStrength) * (1.0 - absorb) * (brightness * day);
	return color * absorb + scatter;
}

#ifdef CLOUDS
	#ifdef OLD_CLOUDS
		//finds random value at location, as well as the slope at that location if needed.
		//happens to generate noise that looks similar to minecraft's native pixellated clouds.
		vec3 cloudNoise(vec2 coord, float size, float heightOffset, bool needNormals) {
			coord /= size;

			vec2 middle = fract(coord);
			vec4 corners = vec4(coord - middle + 0.5, 0.0, 0.0);
			corners.zw = corners.xy + 1.0;
			corners *= invNoiseRes;
			//vec4 corners = (vec4(floor(coord), ceil(coord)) + 0.5) * invNoiseRes;

			float r00 = texture2D(noisetex, corners.xy).r; //random value at the (0, 0) corner
			float r01 = texture2D(noisetex, corners.xw).r; //random value at the (0, 1) corner
			float r10 = texture2D(noisetex, corners.zy).r; //random value at the (1, 0) corner
			float r11 = texture2D(noisetex, corners.zw).r; //random value at the (1, 1) corner

			vec2 mixlvl = interpolateSmooth2(middle); //non-linear interpolation

			float height = mix(mix(r00, r10, mixlvl.x), mix(r01, r11, mixlvl.x), mixlvl.y) * 2.0 - 1.0 + heightOffset; //non-linear interpolation between the 4 corners
			if (needNormals && height > 0.0 && night < 0.999) {
				vec2 dmixlvl = interpolateSmooth2(1.0 - abs(middle * 2.0 - 1.0));

				float dx = mix((r00 - r10) * dmixlvl.x, (r01 - r11) * dmixlvl.x, mixlvl.y); //slope in x direction
				float dy = mix((r00 - r01) * dmixlvl.y, (r10 - r11) * dmixlvl.y, mixlvl.x); //slope in y direction
				return vec3(dx, dy, height);
			}
			else return vec3(0.0, 0.0, height);
		}

		//returns color and opacity of clouds
		vec4 drawClouds(in vec3 pos, in vec3 posNorm, inout float height, in bool vshflag) {
			if ((night > 0.999 && rainStrength > 0.999) || blindness > 0.999) return vec4(0.0); //no point rendering clouds when you can't even see them.

			vec2 skyPos = pos.xz + eyePosition.xz;
			skyPos.x += frameTimeCounter / 1.5;
			float clumpingFactor = 1.5 * (cloudNoise(skyPos, 64.0, 0.0, false).z + wetness); //makes denser and less dense regions of clouds
			if (clumpingFactor > -1.0) {
				vec3 noiseData = cloudNoise(skyPos, 12.0, clumpingFactor, true);
				if (noiseData.z > 0.0) {
					if (height > 0.0) {
						height = 1.0 - height / noiseData.z;
						if (height < 0.0) return vec4(0.0);
					}
					vec3 color;
					//add more rough-ness to clouds. except at night, since they're solid black at night anyway. also less roughness at sunset, since it's more noticeable at sunset.
					if (night < 0.999) {
						vec2 moreNoise = vec2(0.0);
						moreNoise += texture2D(noisetex, skyPos / 3.5 * invNoiseRes).gb;
						moreNoise += texture2D(noisetex, skyPos       * invNoiseRes).gb / 4.0;
						moreNoise = (moreNoise / 2.5 - 0.25) * noiseData.z * (day + 1.0);
						noiseData.xy += moreNoise;

						vec3 normal = vec3(noiseData.x, noiseData.z * sign(eyePosition.y - CLOUD_HEIGHT), noiseData.y);
						if (vshflag) normal.y *= 1.0 - height; //interpolate normal Y value when flying through clouds
						normal = normalize((gbufferModelView * vec4(normal, 0.0)).xyz); //rotate to be in view space, and normalize.

						float lightAmt = dot(normal, sunPosNorm) * 0.5 + 0.5; //sun illumination
						if (eyePosition.y < CLOUD_HEIGHT) {
							lightAmt *= fogify(noiseData.z, 1.25); //decrease light near the centers of the underside of clouds
							lightAmt += square(max(dot(posNorm, sunPosNorm) * 3.0 - 2.0, 0.0)) * fogify(noiseData.z - wetness * 0.5, 0.25); //allow sun to "shine through" clouds where density is low, and apply bonus when raining
						}
						else {
							lightAmt *= lightAmt; //add more contrast to the tops of clouds
						}

						color = mix(cloudColor, cloudIlluminationColor, lightAmt);
					}
					else {
						color = vec3(0.0);
					}

					float alpha = 1.0 - fogify(noiseData.z + clamp(clumpingFactor, 0.0, noiseData.z), 0.25);

					return vec4(color, alpha) * (1.0 - blindness);
				}
			}
			return vec4(0.0);
		}
	#else
		//finds random value at location, as well as the slope at that location if needed.
		vec3 cloudNoise(vec2 coord) {
			vec2 middle = fract(coord);
			vec4 corners = vec4(coord - middle + 0.5, 0.0, 0.0);
			corners.zw = corners.xy + 1.0;
			corners *= invNoiseRes;
			//vec4 corners = (vec4(floor(coord), ceil(coord)) + 0.5) * invNoiseRes;
			//ivec4 corners = ivec4(mod(vec4(floor(coord), ceil(coord)), noiseTextureResolution));

			float r00 = texture2D(noisetex, corners.xy).r; //random value at the (0, 0) corner
			float r01 = texture2D(noisetex, corners.xw).r; //random value at the (0, 1) corner
			float r10 = texture2D(noisetex, corners.zy).r; //random value at the (1, 0) corner
			float r11 = texture2D(noisetex, corners.zw).r; //random value at the (1, 1) corner

			vec2 mixlvl = interpolateSmooth2(middle); //non-linear interpolation

			float height = mix(mix(r00, r10, mixlvl.x), mix(r01, r11, mixlvl.x), mixlvl.y) - 0.5; //non-linear interpolation between the 4 corners
			#ifdef CLOUD_NORMALS
				vec2 dmixlvl = interpolateSmooth2(1.0 - abs(middle * 2.0 - 1.0));

				float dx = mix((r00 - r10) * dmixlvl.x, (r01 - r11) * dmixlvl.x, mixlvl.y); //slope in x direction
				float dy = mix((r00 - r01) * dmixlvl.y, (r10 - r11) * dmixlvl.y, mixlvl.x); //slope in y direction
				return vec3(dx, dy, height);
			#else
				return vec3(0.0, 0.0, height);
			#endif
		}

		//returns color and opacity of clouds
		vec4 drawClouds(in vec3 pos, in vec3 posNorm, inout float height, in bool vshflag) {
			if ((night > 0.999 && rainStrength > 0.999) || blindness > 0.999) return vec4(0.0); //no point rendering clouds when you can't even see them.

			vec2 skyPos = pos.xz + eyePosition.xz;
			skyPos.x += frameTimeCounter; //apply wind

			skyPos *= 0.00390625; //scale
			float time = frameTimeCounter * 0.0078125;
			vec3 noise = vec3(0.0); //x and y = normal data, z = height

			noise += cloudNoise((skyPos + time * goldenOffset0)       ) * 2.0;
			noise += cloudNoise((skyPos + time * goldenOffset1) * 2.0 );
			noise += cloudNoise((skyPos + time * goldenOffset2) * 4.0 ) * 0.5;
			noise += cloudNoise((skyPos + time * goldenOffset3) * 8.0 ) * 0.25;
			noise += cloudNoise((skyPos + time * goldenOffset4) * 16.0) * 0.125;

			//add more detail without calculating interpolation or normals (since both of those are slower than fetching a single random number)
			skyPos *= invNoiseRes;
			time *= invNoiseRes;
			noise.z += texture2D(noisetex, (skyPos + time * goldenOffset5) * 32.0 ).r * 0.0625;
			noise.z += texture2D(noisetex, (skyPos + time * goldenOffset6) * 64.0 ).r * 0.03125;
			noise.z += texture2D(noisetex, (skyPos + time * goldenOffset7) * 128.0).r * 0.015625;
			noise.z += texture2D(noisetex, (skyPos + time * goldenOffset8) * 256.0).r * 0.0078125;
			noise.z += texture2D(noisetex, (skyPos + time * goldenOffset9) * 512.0).r * 0.00390625;

			noise.z += cloudDensityModifier; //random density fluctuations every few minutes
			noise.z /= max(cloudDensityModifier, 0.0) + 1.0; //scale so as not to be solid gray when density is ludicrously high
			noise.z += wetness; //bias when raining

			if (noise.z > 0.0) { //there are clouds here
				if (height > 0.0) { //volumetric effect handling (scale opacityModifier based on density of clouds)
					height = 1.0 - height / (1.0 - fogify(noise.z, 0.125));
					if (height < 0.0) return vec4(0.0); //clouds not dense enough for volumetric effects to apply.
				}
				#ifdef CLOUD_NORMALS
					vec3 normal = vec3(noise.x, noise.z * sign(eyePosition.y - CLOUD_HEIGHT), noise.y);
					if (vshflag) normal.y *= 1.0 - height; //interpolate normal Y value when flying through clouds
					normal = normalize((gbufferModelView * vec4(normal, 0.0)).xyz); //rotate to be in view space, and normalize.

					vec2 lightAmt = vec2(dot(normal, sunPosNorm), dot(normal, -sunPosNorm)) * 0.5 + 0.5; //sun and moon illumination
					if (eyePosition.y < CLOUD_HEIGHT) {
						lightAmt *= fogify(noise.z, 0.5); //decrease light near the centers of the underside of clouds
						lightAmt.x *= 1.0 - rainStrength * 0.75; //less sunlight during rain.
						lightAmt.x += square(max(dot(posNorm, sunPosNorm) * 3.0 - 2.0, 0.0)) * fogify(noise.z, 0.25) * (1.0 - rainStrength * 0.5); //allow sun to "shine through" clouds where density is low, and with slight bonus during rain (compared to everywhere else anyway)_
					}
					else {
						lightAmt *= lightAmt; //add more contrast to the tops of clouds
					}

					vec3 color = mix(cloudColor, cloudIlluminationColor, lightAmt.x); //colorize
					color += mix(vec3(0.01, 0.02, 0.03), vec3(0.1, 0.15, 0.25), lightAmt.y * phase) * night * (1.0 - rainStrength); //add lunar illumination
					float alpha = 1.0 - fogify(noise.z , 0.0625); //more opaque in center, less opaque around edges
					return vec4(color, alpha) * (1.0 - blindness);
				#else
					float lightAmt = fogify(noise.z, 0.25); //more light on edges than center
					if (eyePosition.y > CLOUD_HEIGHT) lightAmt = lightAmt * -0.5 + 1.0; //reverse and scale when above clouds

					vec3 color = mix(cloudColor, cloudIlluminationColor, lightAmt); //colorize
					color += mix(vec3(0.01, 0.02, 0.03), vec3(0.1, 0.15, 0.25), lightAmt) * night * phase * (1.0 - rainStrength); //add lunar illumination
					float alpha = 1.0 - fogify(noise.z, 0.0625); //more opaque in center, less opaque around edges
					return vec4(color, alpha) * (1.0 - blindness);
				#endif
			}
			return vec4(0.0);
		}
	#endif
#endif

void main() {
	if (isEyeInWater == 2) { //under lava
		vec2 coord = floor(vec2(texcoord.x, texcoord.y / aspectRatio) * 24.0 + vec2(0.0, frameTimeCounter)) + 0.5; //24.0 is the resolution of the generated lava texture.
		float noise = 0.0;
		noise += (texture2D(noisetex, (coord * 0.25 + vec2(0.0, frameTimeCounter)) * invNoiseRes).r - 0.5);
		noise += (texture2D(noisetex, (coord * 0.5  + vec2(0.0, frameTimeCounter)) * invNoiseRes).r - 0.5) * 0.5;
		noise += (texture2D(noisetex, (coord        + vec2(0.0, frameTimeCounter)) * invNoiseRes).r - 0.5) * 0.25;
		vec3 color = vec3(1.0, 0.5, 0.0) + noise * vec3(0.375, 0.5, 0.5);
		gl_FragData[0] = vec4(color, 1.0);
		return; //don't need to calculate anything else since the lava overlay covers the entire screen.
	}

	vec2 tc = texcoord;

	vec3 oldaux2 = texture2D(gaux2, texcoord).rgb;
	int id = int(oldaux2.b * 10.0 + 0.1);
	vec3 normal = texture2D(gnormal, texcoord).xyz * 2.0 - 1.0;

	vec3 pos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
	bool nothingInFrontOfSky = pos.z == 1.0;
	vec4 v = gbufferProjectionInverse * vec4(pos * 2.0 - 1.0, 1.0);
	pos = v.xyz / v.w;

	float dist = length(pos);
	vec3 posNorm = pos / dist;

	vec3 worldPos = (gbufferModelViewInverse * vec4(pos, 1.0)).xyz + cameraPosition;

	#ifdef REFLECT
		float reflective = 0.0;
	#endif

	#ifdef CLOUDS
		bool isTCOffset = false; //tracks weather or not cloud positions need to be re-calculated due to water/ice refractions
	#endif

	float blur = 0.0;

	#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
		blur = interpolateSmooth1(min(abs(dist - dofDistance) / dofDistance, 1.0)) * DOF_STRENGTH;
	#endif

	#if defined(BLUR_ENABLED) && WATER_BLUR != 0
		float waterBlur = float(WATER_BLUR); //slightly more dynamic than other types of blur, as high fog density will decrease this value, and being near a reflection of the sun will increase it.
	#endif

	if (id == 1) { //water
		#ifdef REFLECT
			reflective = 0.5;
		#endif

		#ifdef INFINITE_OCEANS
			if (nothingInFrontOfSky) {
				worldPos -= eyePosition; //convert back to eye-space

				float diff = actualSeaLevel - eyePosition.y;
				worldPos = normalize(worldPos);
				worldPos = vec3(worldPos.xz * (diff / worldPos.y), diff).xzy;
				dist = length(worldPos);
				worldPos += eyePosition;
			}
		#endif

		#if defined(WATER_REFRACT) || (defined(WATER_NORMALS) && defined(REFLECT))
			vec3 newPos = worldPos;
			ivec2 swizzles;
			float multiplier = 1.0;
			if (abs(normal.y) > 0.1) { //top/bottom surface
				if (abs(normal.y) < 0.999) newPos.xz -= normalize(normal.xz) * (frameTimeCounter * 3.0);
				else multiplier = (oldaux2.g * (0.75 - night * 0.375) + 0.25) + (oldaux2.g * min(rainStrength, wetness) * 1.5);
				swizzles = ivec2(0, 2);
			}
			else {
				newPos.y += frameTimeCounter * 4.0;
				if (abs(normal.x) < 0.02) swizzles = ivec2(0, 1);
				else swizzles = ivec2(2, 1);
			}

			vec2 offset = waterNoiseLOD(vec2(newPos[swizzles[0]], newPos[swizzles[1]]), dist) * (multiplier * 0.015625); //witchcraft.
			#ifdef WATER_NORMALS
				normal[swizzles[0]] += offset[0] * 4.0;
				normal[swizzles[1]] += offset[1] * 4.0;
				normal = normalize(normal);
			#endif

			#ifdef WATER_REFRACT
				tc += vec2(offset.x, offset.y * aspectRatio) / max(dist * 0.0625, 1.0);

				#ifdef CLOUDS
					isTCOffset = true;
				#endif
			#endif
		#endif
	}
	else if (id == 2) { //stained glass
		#ifdef REFLECT
			reflective = 0.25;
		#endif

		#if defined(BLUR_ENABLED) && GLASS_BLUR != 0
			blur = max(blur, float(GLASS_BLUR));
		#endif
	}
	else if (id == 3 || id == 4) { //ice and held ice
		#ifdef REFLECT
			reflective = 0.25;
		#endif

		#if defined(BLUR_ENABLED) && ICE_BLUR != 0
			blur = max(blur, float(ICE_BLUR));
		#endif

		#if defined(ICE_REFRACT) || (defined(ICE_NORMALS) && defined(REFLECT))
			vec3 offset;
			if (id == 3) {
				vec2 coord = (abs(normal.y) < 0.001 ? vec2(worldPos.x + worldPos.z, worldPos.y) : worldPos.xz);
				offset = iceNoiseLOD(coord * 256.0, dist) * 0.0078125;
			}
			else {
				vec2 coord = gl_FragCoord.xy + 0.5;
				offset = iceNoise(coord * 0.5) * 0.0078125;
			}

			#ifdef ICE_REFRACT
				vec2 newtc = tc + vec2(offset.x, offset.y * aspectRatio);
				vec3 newnormal = texture2D(gnormal, newtc).xyz * 2.0 - 1.0;
				if (dot(normal, newnormal) > 0.9) { //don't offset on the edges of ice
					tc = newtc;

					#ifdef CLOUDS
						isTCOffset = true;
					#endif
				}
			#endif

			#ifdef ICE_NORMALS
				normal = normalize(normal + offset * 8.0);
			#endif
		#endif
	}

	vec3 aux2 = texture2D(gaux2, tc).rgb;
	if (abs(aux2.b - oldaux2.b) > 0.02) {
		tc = texcoord;
		aux2 = texture2D(gaux2, tc).rgb;

		#ifdef CLOUDS
			isTCOffset = false;
		#endif
	}

	vec4 c = texture2D(gcolor, tc);
	vec3 color = c.rgb;
	float transparentAlpha = c.a; //using gcolor to store composite's alpha
	vec4 transparent = texture2D(composite, tc); //transparency of closest object to the camera

	#if defined(BLUR_ENABLED) && UNDERWATER_BLUR != 0
		if (isEyeInWater == 1) blur = float(UNDERWATER_BLUR);
	#endif

	#ifdef CLOUDS
		float cloudDiff = CLOUD_HEIGHT - eyePosition.y;
		vec3 baseCloudPos = worldPos - eyePosition;
		float cloudDist;
		vec4 cloudclr = vec4(0.0);
		//don't render clouds below you if you're below them, and vise versa. also don't render them in the void. (unless you have cubic chunks installed)
		#ifdef CUBIC_CHUNKS
			bool cloudy = sign(cloudDiff) == sign(baseCloudPos.y);
		#else
			bool cloudy = eyePosition.y > 0.0 && sign(cloudDiff) == sign(baseCloudPos.y);
		#endif

		if (cloudy) {
			//calculate base cloud plane position
			baseCloudPos = normalize(baseCloudPos);
			baseCloudPos = vec3(baseCloudPos.xz * (cloudDiff / baseCloudPos.y), cloudDiff).xzy;
			cloudDist = lengthSquared3(baseCloudPos) * 0.999; //avoid z-fighting by making clouds a little bit closer
			float opacityModifier = -1.0;
			//additional logic if there's terrain in front of the clouds (used for fake volumetric effects)
			if (!nothingInFrontOfSky && dist * dist < cloudDist) {
				opacityModifier = abs(worldPos.y - CLOUD_HEIGHT) / 4.0;
				if (opacityModifier < 1.0) { //maximum cloud density
					baseCloudPos = worldPos - eyePosition;
					cloudDist = lengthSquared3(baseCloudPos) * 0.999;
				}
				else { //pos is outside range of fake volumetric effects, check pos1 next.
					opacityModifier = -1.0;
					vec3 pos1 = vec3(tc, texture2D(depthtex1, tc).r);
					if (pos1.z < 1.0) { //opaque object exists here
						vec4 v1 = gbufferProjectionInverse * vec4(pos1 * 2.0 - 1.0, 1.0);
						pos1 = v1.xyz / v1.w;
						vec3 worldpos1 = (gbufferModelViewInverse * vec4(pos1, 1.0)).xyz + cameraPosition;
						opacityModifier = abs(worldpos1.y - CLOUD_HEIGHT) / 4.0;
						if (opacityModifier < 1.0 && lengthSquared3(pos1) < cloudDist) { //within volumetric range
							baseCloudPos = worldpos1 - eyePosition;
							cloudDist = lengthSquared3(baseCloudPos) * 0.999;
						}
						else opacityModifier = -1.0;
						cloudy = lengthSquared3(pos1) > cloudDist; //true if there's clouds between the terrain and the transparent thing
					} //opaque object exists here too
				} //pos is outside range of fake volumetric effects, check pos1 next.
			} //something in front of terrain

			if (cloudy) {
				if (isTCOffset && dist * dist < cloudDist) { //re-calculate position to account for water refraction.
					baseCloudPos = normalize((gbufferModelViewInverse * (gbufferProjectionInverse * vec4(tc * 2.0 - 1.0, 1.0, 1.0))).xyz);
					baseCloudPos = vec3(baseCloudPos.xz / baseCloudPos.y * cloudDiff, cloudDiff).xzy;
					//not re-calculating distance because it's not really all that necessary.
				}
				cloudDist = sqrt(cloudDist) / far;
				cloudclr = drawClouds(baseCloudPos, posNorm, opacityModifier, false);

				cloudclr.a *= 64.0 / (lengthSquared2(baseCloudPos.xz / baseCloudPos.y) + 64.0); //reduce opacity in the distance

				if (cloudclr.a > 0.001) {
					if (opacityModifier > 0.0 && opacityModifier < 1.0) { //in the fadeout range
						//approximated cosine interpolation
						cloudclr.a *= interpolateSmooth1(opacityModifier);
						//if (opacityModifier <= 0.5) cloudclr.a *= 2.0 * opacityModifier * opacityModifier;
						//else cloudclr.a *= -2.0 * opacityModifier * opacityModifier + 4.0 * opacityModifier - 1.0;
					}
				}
				else cloudy = false; //no need to render clouds that don't exist at this location
			}
		}
	#endif

	dist /= far;

	if (transparentAlpha > 0.001) {
		#ifdef CLOUDS
			if (cloudy && dist < cloudDist) color = mix(color, cloudclr.rgb, cloudclr.a);
		#endif

		#ifdef ALT_GLASS
			if (id == 2) {
				vec3 transColor = transparent.rgb / transparentAlpha;
				color *= transColor * (2.0 - transColor); //min(transColor * 2.0, 1.0); //because the default colors are too dark to be used.

				float skylight = aux2.g;
				float blocklight = aux2.r;
				float heldlight = 0.0;

				color += transColor * calcMainLightColor(blocklight, skylight, heldlight, dist) * 0.125 * (1.0 - blindness);
			}
			else
		#endif
				color = mix(color, transparent.rgb / transparentAlpha, transparentAlpha);
	}
	#ifdef CLOUDS
		else if (cloudy && (/* dist < cloudDist || */ id != 1 || isEyeInWater == 1)) color = mix(color, cloudclr.rgb, cloudclr.a);
	#endif

	#ifdef REFLECT
		reflective *= aux2.g * aux2.g * (1.0 - blindness);
		vec3 reflectedPos;
		if (isEyeInWater == 0 && reflective > 0.001) { //sky reflections
			vec3 newnormal = (gbufferModelView * vec4(normal, 0.0)).xyz;
			reflectedPos = reflect(posNorm, newnormal);
			vec3 skyclr = calcSkyColor(reflectedPos);
			float posDot = dot(-posNorm, newnormal);
			color += skyclr * square(square(1.0 - max(posDot, 0.0))) * reflective;
		}
	#endif

	if (id > 0) { //everything that I've currently assigned effects to so far needs fog to be done in this stage.
		if (isEyeInWater == 1) {
			#ifdef UNDERWATER_FOG
				float actualEyeBrightness = eyeBrightnessSmooth.y / 240.0;
				#ifdef BRIGHT_WATER
					actualEyeBrightness = actualEyeBrightness * 0.5 + 0.5;
				#endif
				color = calcUnderwaterFogColor(color, dist, actualEyeBrightness) * (1.0 - blindness);
			#endif
		}
		else {
			#ifdef FOG_ENABLED_OVERWORLD
				float d = dist + wetness * eyeBrightnessSmooth.y * 0.00125 - 0.2; //wetness * 0.3 * eyeBrightness / 240.0 - 0.2
				if (d > 0.0) {
					d = fogify(d * (rainStrength + 1.0) * exp2(1.5 - worldPos.y * 0.015625), FOG_DISTANCE_MULTIPLIER_OVERWORLD);
					vec3 fogclr = calcFogColor(posNorm);
					fogclr += texture2D(noisetex, gl_FragCoord.xy * invNoiseRes).rgb * 0.00390625; //dither to match sky
					color = mix(fogclr * min(max(aux2.g * 2.0, eyeBrightness.y / 120.0), 1.0) * (1.0 - blindness), color, d);
					#if defined(BLUR_ENABLED) && WATER_BLUR != 0
						waterBlur *= d;
					#endif
				}
			#endif
		}
	}

	//sun reflections bypasses fog.
	#ifdef REFLECT
		reflective *= day * day * (1.0 - rainStrength);
		if (isEyeInWater == 0 && reflective > 0.001) {
			vec3 sunColor = mix(vec3(2.0, 1.0, 0.5), vec3(1.0, 0.9, 0.8), day);
			float sunDot = dot(reflectedPos, sunPosNorm);
			float reflectionAmt = 0.00003 / square(1.001 - sunDot);

			color += sunColor * reflectionAmt * reflective;

			#if defined(BLUR_ENABLED) && WATER_BLUR != 0
				waterBlur = clamp((sunDot - 0.75) * 16.0, waterBlur, WATER_BLUR); //no more than WATER_BLUR, and no less than what it was originally.
			#endif
		}
	#endif

	color = min(color, 1.0); //reflections (and possibly other things) can go above maximum brightness

	#ifdef CLOUDS
		if (cloudy && (id == 1 || transparentAlpha > 0.001) && dist > cloudDist) color = mix(color, cloudclr.rgb, cloudclr.a);
		color = mix(color, cloudInsideColor.rgb, cloudInsideColor.a);
	#endif

	#if defined(BLUR_ENABLED) && RAIN_BLUR != 0
		if (wetness > 0.001) {
			float skylight = texture2D(gaux1, tc).g;

			float heightModifier = 1.0;

			#ifdef CLOUDS
				heightModifier = fogify(max(eyePosition.y - CLOUD_HEIGHT, 0.0), 6.25); //less rain blur above cloud height
			#endif

			blur += wetness * heightModifier * float(RAIN_BLUR) * (nothingInFrontOfSky ? 0.5 : min(max(eyeBrightnessSmooth.y / 120.0, skylight * 2.0), 1.0) * dist);
		}
	#endif

	#if defined(BLUR_ENABLED) && WATER_BLUR != 0
		if (id == 1 && isEyeInWater == 0) blur += waterBlur;
	#endif

	#ifdef BLUR_ENABLED
		blur /= 256.0;
	#endif

	color *= mix(vec3(eyeAdjust), vec3(1.0), color);

/* DRAWBUFFERS:6 */
	gl_FragData[0] = vec4(color, 1.0 - blur); //gaux3
}