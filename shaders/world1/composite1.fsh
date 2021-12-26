#version 120

#define ALT_GLASS //Uses alternate blending method for stained glass which looks more like real stained glass
#define AMBIENT_LIGHT_COLOR_END_BLUE 0.10 //Blue component of the ambient light color in the end [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define AMBIENT_LIGHT_COLOR_END_GREEN 0.10 //Green component of the ambient light color in the end [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define AMBIENT_LIGHT_COLOR_END_RED 0.10 //Red component of the ambient light color in the end [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define BLUR_ENABLED //Is blur enabled at all?
#define DOF_STRENGTH 0 //Blurs things that are at a different distance than whatever's in the center of your screen [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define DYNAMIC_LIGHTS //Holding blocks that emit light will light up their surroundings
#define FOG_DISTANCE_MULTIPLIER_END 0.25 //How far away fog starts to appear in the end [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.2 2.4 2.6 2.8 3.0 3.5 4.0 4.5 5.0 6.0 7.0 8.0 9.0 10.0]
//#define FOG_ENABLED_END //Enables fog in the end
#define GLASS_BLUR 8 //Blurs things behind stained glass [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define ICE_BLUR 4 //Blurs things behind ice [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define ICE_REFRACT //Distorts things behind ice
#define UNDERWATER_BLUR 8 //Blurs the world while underwater [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
//#define VANILLA_LIGHTMAP //Uses vanilla light colors instead of custom ones. Requires optifine 1.12.2 HD_U_D1 or later!
#define VIGNETTE //Reduces the brightness of dynamic light around edges the of your screen
#define VOID_CLOUD_HEIGHT 128.0 //Y level of void clouds [-64.0 -48.0 -32.0 -16.0 0.0 16.0 32.0 48.0 64.0 80.0 96.0 112.0 128.0 144.0 160.0 176.0 192.0 208.0 224.0 240.0 256.0 272.0 288.0 304.0 320.0 336.0 352.0 368.0 384.0 400.0 416.0 432.0 448.0 464.0 480.0 496.0 512.0]
#define VOID_CLOUDS //Dark ominous clouds in the end
#define WATER_BLUR 4 //Blurs things behind water [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define WATER_REFRACT //Distorts things behind water

uniform float aspectRatio;
uniform float blindness;
uniform float far;
uniform float frameTimeCounter;
uniform float nightVision;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float screenBrightness;
uniform int isEyeInWater;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D composite;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D gaux2;
uniform sampler2D gaux4;
uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + gbufferModelViewInverse[3].xyz; //because cameraPosition isn't actually the position of the camera -_-
uniform vec3 fogColor;

#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
	varying float dofDistance; //Un-projected centerDepthSmooth
#endif
#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.
#ifdef VOID_CLOUDS
	varying vec4 voidCloudInsideColor; //Color to render over your entire screen when inside a void cloud.
#endif

/*
//required on older versions of optifine for its option-parsing logic:
#ifdef BLUR_ENABLED
#endif
*/

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

float square(float x)        { return x * x; } //faster than pow().
float lengthSquared2(vec2 v) { return dot(v, v); }
float lengthSquared3(vec3 v) { return dot(v, v); }

float interpolateSmooth1(float x) { return x * x * (3.0 - 2.0 * x); }
vec2  interpolateSmooth2(vec2 v)  { return v * v * (3.0 - 2.0 * v); }

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
}

vec3 calcMainLightColor(inout float blocklight, inout float heldlight, in float dist) {
	#ifdef VANILLA_LIGHTMAP
		vec3 lightclr = texture2D(gaux4, vec2(blocklight, 0.96875)).rgb; //31/32 is the maximum light level in vanilla
	#endif

	blocklight *= blocklight;

	#ifndef VANILLA_LIGHTMAP
		vec3 lightclr = vec3(0.0);
		lightclr += blockLightColor * blocklight; //blocklight
		lightclr += vec3(AMBIENT_LIGHT_COLOR_END_RED, AMBIENT_LIGHT_COLOR_END_GREEN, AMBIENT_LIGHT_COLOR_END_BLUE); //skylight
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

#ifdef VOID_CLOUDS
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

	float thresholdSample(vec2 coord, vec2 threshold) {
		vec2 middle = fract(coord);
		vec4 corners = vec4(coord - middle + 0.5, 0.0, 0.0);
		corners.zw = corners.xy + 1.0;
		corners *= invNoiseRes;
		//vec4 corners = (vec4(floor(coord), ceil(coord)) + 0.5) * invNoiseRes;

		vec4 cornerSample = vec4(
			texture2D(noisetex, corners.xy).r, //random value at the (0, 0) corner
			texture2D(noisetex, corners.xw).r, //random value at the (0, 1) corner
			texture2D(noisetex, corners.zy).r, //random value at the (1, 0) corner
			texture2D(noisetex, corners.zw).r  //random value at the (1, 1) corner
		);

		/*
		ivec4 corners = ivec4(mod(vec4(floor(coord), ceil(coord)), noiseTextureResolution));

		vec4 cornerSample = vec4(
			texelFetch2D(noisetex, corners.xy, 0).r, //random value at the (0, 0) corner
			texelFetch2D(noisetex, corners.xw, 0).r, //random value at the (0, 1) corner
			texelFetch2D(noisetex, corners.zy, 0).r, //random value at the (1, 0) corner
			texelFetch2D(noisetex, corners.zw, 0).r  //random value at the (1, 1) corner
		);
		*/
		vec4 high = vec4(greaterThan(cornerSample, threshold.xxxx));
		vec4 low = vec4(lessThan(cornerSample, threshold.yyyy));

		vec2 mixlvl = interpolateSmooth2(middle); //non-linear interpolation

		return mix(mix(high.x, high.y, mixlvl.y), mix(high.z, high.w, mixlvl.y), mixlvl.x) -
			   mix(mix(low.x,  low.y,  mixlvl.y), mix(low.z,  low.w,  mixlvl.y), mixlvl.x);
	}

	vec4 drawVoidClouds(in vec3 pos, inout float volumetric) {
		if (blindness > 0.999) return vec4(0.0);
		float noise = 512.0 / (lengthSquared2(pos.xz / pos.y) + 256.0) - 3.0; //reduce cloud density in the distance
		float noiseTime = frameTimeCounter * invNoiseRes;

		pos += eyePosition;
		vec2 clumpPos = (pos.xz + vec2(frameTimeCounter * 2.0, 0.0)) / 256.0; //divide into 256-block-long cells
		float clumpingFactor = thresholdSample(clumpPos, vec2(0.75, 0.25)); //pick a random value for each cell. if it's above 0.75, it gets +1 density. if it's below 0.25, it gets -1 density.
		noise += clumpingFactor;

		//now to add some randomness so they look roughly cloud-shaped
		float speed = noiseTime * 2.0;
		vec2 cloudPos = pos.xz * invNoiseRes;
		cloudPos.x += noiseTime * 0.5; //multiplying by 0.5 instead of 2 so that clouds look like they're "spreading" as well as being blown around
		noise += texture2D(noisetex, (cloudPos + goldenOffset0 * speed) * 0.015625).r;
		noise += texture2D(noisetex, (cloudPos + goldenOffset1 * speed) * 0.03125 ).r * 0.6;
		noise += texture2D(noisetex, (cloudPos + goldenOffset2 * speed) * 0.0625  ).r * 0.36;
		noise += texture2D(noisetex, (cloudPos + goldenOffset3 * speed) * 0.125   ).r * 0.216;
		noise += texture2D(noisetex, (cloudPos + goldenOffset4 * speed) * 0.25    ).r * 0.1296;
		noise += texture2D(noisetex, (cloudPos + goldenOffset5 * speed) * 0.5     ).r * 0.07776;
		noise += texture2D(noisetex, (cloudPos + goldenOffset6 * speed)           ).r * 0.046656;
		noise += texture2D(noisetex, (cloudPos + goldenOffset7 * speed) * 2.0     ).r * 0.0279936;

		if (noise > 0.0) { //there are indeed clouds here
			vec3 color = vec3(noise * 0.0625); //base cloud color
			bool speckles = volumetric < 0.0;
			if (volumetric > 0.0) {
				volumetric = 1.0 - volumetric / (1.0 - fogify(noise, 0.125));
				if (volumetric < 0.0) return vec4(0.0);
			}

			//lightning effects:
			if (clumpingFactor > 0.0) { //only apply lightning to high-density cloud areas
				float lightningMultiplier = interpolateSmooth1(max(1.0 - length(fract(clumpPos + 0.5) * 2.0 - 1.0), 0.0)); //1.0 at the centers of cells (cells referring to the sample points collected by clumpingFactor), and 0.0 at the edges.
				vec2 lightningOffset = (texture2D(noisetex, (floor(clumpPos + 0.5) + 0.5) * invNoiseRes).gb * 0.5 + 0.5) * noiseTime; //random position to sample from
				float lightningAmt = max(texture2D(noisetex, lightningOffset).r * 8.0 - 7.0, 0.0); //do sample on that position to get lightning amount
				lightningAmt *= texture2D(noisetex, lightningOffset.yx * 32.0).r; //multiply by another value that changes more rapidly, this makes the lightning flicker instead of just fading in/out
				color += lightningAmt * lightningMultiplier * clumpingFactor * noise; //add final value.
			}

			//sparkly square confetti things:
			if (speckles) {
				vec3 data = texture2D(noisetex, (floor((pos.xz + vec2(frameTimeCounter, 0.0)) * 2.0) + 0.5) * invNoiseRes).rgb; //r = hue, gb = another random offset
				float amt = texture2D(noisetex, data.gb * noiseTime * 0.25).r; //base brightness of square
				amt = max(amt * 8.0 - 8.0 + noise, 0.0); //add bias so that there are more squares where cloud density is high
				color += hue(data.r * 0.35 + 0.45) * amt; //color of square
			}

			noise = min(noise * 1.5, 1.0); //add bias to noise so that clouds reach 100% opacity in highly dense regions
			return vec4(color, interpolateSmooth1(noise)) * (1.0 - blindness);
		}
		else return vec4(0.0);
	}
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

	vec3 normal = texture2D(gnormal, tc).rgb * 2.0 - 1.0;
	int id = int(texture2D(gaux2, tc).b * 10.0 + 0.1);

	vec3 pos = vec3(tc, texture2D(depthtex0, tc).r);
	bool nothingInFrontOfSky = pos.z == 1.0;
	vec4 v = gbufferProjectionInverse * vec4(pos * 2.0 - 1.0, 1.0);
	pos = v.xyz / v.w;
	float dist = length(pos);

	vec3 worldPos = (gbufferModelViewInverse * vec4(pos, 1.0)).xyz + cameraPosition;

	float blur = 0.0;

	#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
		blur = interpolateSmooth1(min(abs(dist - dofDistance) / dofDistance, 1.0)) * float(DOF_STRENGTH);
	#endif

	#ifdef VOID_CLOUDS
		bool isTCOffset = false; //tracks weather or not void cloud positions need to be re-calculated due to water/ice refractions
	#endif

	if (id == 1) { //water
		#if defined(BLUR_ENABLED) && WATER_BLUR != 0
			blur = max(blur, WATER_BLUR);
		#endif

		#ifdef WATER_REFRACT
			vec3 newPos = worldPos;
			ivec2 swizzles;
			if (abs(normal.y) > 0.1) { //top/bottom surface
				if (abs(normal.y) < 0.999) newPos.xz -= normalize(normal.xz) * frameTimeCounter * 3.0;
				swizzles = ivec2(0, 2);
			}
			else {
				newPos.y += frameTimeCounter * 4.0;
				if (abs(normal.x) < 0.02) swizzles = ivec2(0, 1);
				else swizzles = ivec2(2, 1);
			}

			vec2 offset = waterNoiseLOD(vec2(newPos[swizzles[0]], newPos[swizzles[1]]), dist) / 64.0; //witchcraft.
			tc += vec2(offset.x, offset.y * aspectRatio) / max(dist * 0.0625, 1.0);

			#ifdef VOID_CLOUDS
				isTCOffset = true;
			#endif
		#endif
	}
	else if (id == 2) { //stained glass
		#if defined(BLUR_ENABLED) && GLASS_BLUR != 0
			blur = max(blur, float(GLASS_BLUR));
		#endif
	}
	else if (id == 3 || id == 4) { //ice and held ice
		#if defined(BLUR_ENABLED) && ICE_BLUR != 0
			blur = max(blur, float(ICE_BLUR));
		#endif

		#ifdef ICE_REFRACT
			vec3 offset;
			if (id == 3) {
				vec2 coord = (abs(normal.y) < 0.001 ? vec2(worldPos.x + worldPos.z, worldPos.y) : worldPos.xz);
				offset = iceNoiseLOD(coord * 256.0, dist) / 128.0;
			}
			else {
				vec2 coord = gl_FragCoord.xy + 0.5;
				offset = iceNoise(coord * 0.5) / 128.0;
			}

			vec2 newtc = tc + vec2(offset.x, offset.y * aspectRatio);
			vec3 newnormal = texture2D(gnormal, newtc).xyz * 2.0 - 1.0;
			if (dot(normal, newnormal) > 0.9) {
				tc = newtc;

				#ifdef VOID_CLOUDS
					isTCOffset = true;
				#endif
			}
		#endif
	}

	dist /= far;

	if (id != int(texture2D(gaux2, tc).b * 10.0 + 0.1)) {
		tc = texcoord;
		#ifdef VOID_CLOUDS
			isTCOffset = false;
		#endif
	}

	#ifdef VOID_CLOUDS
		float cloudDiff = VOID_CLOUD_HEIGHT - eyePosition.y;
		vec3 baseCloudPos = worldPos - eyePosition;
		float cloudDist;
		vec4 cloudclr = vec4(0.0);
		//don't render clouds below you if you're below them, and vise versa.
		bool cloudy = sign(cloudDiff) == sign(baseCloudPos.y);

		if (cloudy) {
			//calculate base cloud plane position
			baseCloudPos = normalize(baseCloudPos);
			baseCloudPos = vec3(baseCloudPos.xz / baseCloudPos.y * cloudDiff, cloudDiff).xzy;
			cloudDist = lengthSquared3(baseCloudPos) * 0.999; //avoid z-fighting by making clouds a little bit closer
			float opacityModifier = -1.0;
			//additional logic if there's terrain in front of the clouds (used for fake volumetric effects)
			if (!nothingInFrontOfSky && square(dist * far) < cloudDist) {
				opacityModifier = abs(worldPos.y - VOID_CLOUD_HEIGHT) / 4.0;
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
						opacityModifier = abs(worldpos1.y - VOID_CLOUD_HEIGHT) / 4.0;
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
				if (isTCOffset && square(dist * far) < cloudDist) { //re-calculate position to account for water refraction.
					baseCloudPos = normalize((gbufferModelViewInverse * (gbufferProjectionInverse * vec4(tc * 2.0 - 1.0, 1.0, 1.0))).xyz);
					baseCloudPos = vec3(baseCloudPos.xz / baseCloudPos.y * cloudDiff, cloudDiff).xzy;
					//not re-calculating distance because it's not really all that necessary.
				}
				cloudDist = sqrt(cloudDist) / far;
				cloudclr = drawVoidClouds(baseCloudPos, opacityModifier); //opacityModifier is -1.0 when not applying volumetric effects

				if (cloudclr.a > 0.001) {
					if (opacityModifier > 0.001 && opacityModifier < 0.999) { //in the fadeout range
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

	vec3 color = texture2D(gcolor, tc).rgb;
	vec4 transparent = texture2D(composite, tc);
	float transparentAlpha = texture2D(gcolor, tc).a; //using gcolor to store composite's alpha.

	if (transparentAlpha > 0.0) {
		#ifdef VOID_CLOUDS
			if (cloudy && dist < cloudDist) color = mix(color, cloudclr.rgb, cloudclr.a);
		#endif

		#ifdef ALT_GLASS
			if (id == 2) {
				vec3 transColor = transparent.rgb / transparentAlpha;
				color *= transColor * (2.0 - transColor); //min(transColor * 2.0, 1.0); //because the default colors are too dark to be used.

				float blocklight = texture2D(gaux2, tc).r;
				float heldlight = 0.0;

				color = min(color + transColor * calcMainLightColor(blocklight, heldlight, dist) * 0.125 * (1.0 - blindness), 1.0);

				#ifdef FOG_ENABLED_END
					color.rgb = mix(fogColor, color.rgb, fogify(dist, FOG_DISTANCE_MULTIPLIER_END));
				#endif
			}
			else {
		#endif
				color = mix(color, transparent.rgb / transparentAlpha, transparentAlpha);
		#ifdef ALT_GLASS
			}
		#endif
	}
	#ifdef VOID_CLOUDS
		else if (cloudy) {
			if (dist < cloudDist || id != 1) color = mix(color, cloudclr.rgb, cloudclr.a);
		}

		if (cloudy && (id == 1 || transparentAlpha > 0.001) && dist > cloudDist) color = mix(color, cloudclr.rgb, cloudclr.a);
		color = mix(color, voidCloudInsideColor.rgb, voidCloudInsideColor.a);
	#endif

	#if defined(BLUR_ENABLED) && UNDERWATER_BLUR != 0
		if (isEyeInWater == 1) blur = float(UNDERWATER_BLUR);
	#endif

	#ifdef BLUR_ENABLED
		blur /= 256.0;
	#endif

	color *= color * -0.5 + 1.5; //mix(vec3(1.5), vec3(1.0), color);

/* DRAWBUFFERS:6 */
	gl_FragData[0] = vec4(color, 1.0 - blur); //gcolor
}