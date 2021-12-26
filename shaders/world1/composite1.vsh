#version 120

#define BLUR_ENABLED //Is blur enabled at all?
#define DOF_STRENGTH 0 //Blurs things that are at a different distance than whatever's in the center of your screen [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define DYNAMIC_LIGHTS //Holding blocks that emit light will light up their surroundings
#define VOID_CLOUD_HEIGHT 128.0 //Y level of void clouds [-64.0 -48.0 -32.0 -16.0 0.0 16.0 32.0 48.0 64.0 80.0 96.0 112.0 128.0 144.0 160.0 176.0 192.0 208.0 224.0 240.0 256.0 272.0 288.0 304.0 320.0 336.0 352.0 368.0 384.0 400.0 416.0 432.0 448.0 464.0 480.0 496.0 512.0]
#define VOID_CLOUDS //Dark ominous clouds in the end

uniform float blindness;
uniform float centerDepthSmooth;
uniform float far;
uniform float frameTimeCounter;
uniform int heldBlockLightValue;
uniform int heldItemId;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + vec3(0.0, gbufferModelViewInverse[3][1], 0.0);

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

float lengthSquared2(vec2 v) { return dot(v, v); }

float interpolateSmooth1(float x) { return x * x * (3.0 - 2.0 * x); }
vec2  interpolateSmooth2(vec2 v)  { return v * v * (3.0 - 2.0 * v); }

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
}

#ifdef DYNAMIC_LIGHTS
	float flicker() {
		float n = texture2D(noisetex, frameTimeCounter * vec2(16.7825, 15.4192) * invNoiseRes).r - 0.5;
		return n * n * n * 12.0;
	}

	vec4 calcHeldLightColor(float light, int id) { //rgb = color, a = brightness
		if   (light == 0.0) return vec4(0.0); //not holding a light source
		else if (id == 50 ) return vec4(1.0,  0.6,  0.3, light + flicker()); //torches
		else if (id == 89 ) return vec4(1.0,  0.6,  0.1, light            ); //glowstone
		else if (id == 169) return vec4(0.6,  0.8,  0.6, light            ); //sea lanterns
		else if (id == 198) return vec4(0.75, 0.55, 0.8, light            ); //end rods
		else if (id == 76 ) return vec4(1.0,  0.3,  0.1, light + flicker()); //redstone torches
		else if (id == 91 ) return vec4(1.0,  0.6,  0.3, light + flicker()); //jack-o-lanterns
		else if (id == 138) return vec4(0.4,  0.6,  0.8, light            ); //beacons
		else                return vec4(0.8,  0.65, 0.5, light            ); //everything else
	}
#endif

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
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	blockLightColor = mix(vec3(1.0, 0.5, 0.15), vec3(1.0, 0.85, 0.7), eyeBrightnessSmooth.x / 240.0);

	#ifdef DYNAMIC_LIGHTS
		heldLightColor = calcHeldLightColor(float(heldBlockLightValue),  heldItemId);
		heldLightDistModifier = far / sqrt(gbufferProjection[1][1]); //held lights get more powerful when zooming in, akin to holding the light out in front of you and pointing it at something.
	#else
		heldLightColor = vec4(0.0);
	#endif

	#if defined(BLUR_ENABLED) && DOF_STRENGTH != 0
		vec4 v = gbufferProjectionInverse * vec4(0.0, 0.0, centerDepthSmooth * 2.0 - 1.0, 1.0);
		dofDistance = -v.z / v.w;
	#endif

	#ifdef VOID_CLOUDS
		float d = abs(eyePosition.y - VOID_CLOUD_HEIGHT) / 4.0;
		if (d < 1.0) {
			voidCloudInsideColor = drawVoidClouds(vec3(0.0, 1.0, 0.0), d);
			if (voidCloudInsideColor.a > 0.001) {
				if (d > 0.001 && d < 0.999) { //in the fadeout range
					//approximated cosine interpolation
					voidCloudInsideColor.a *= interpolateSmooth1(d);
					//if (d <= 0.5) voidCloudInsideColor.a *= 2.0 * d * d;
					//else voidCloudInsideColor.a *= -2.0 * d * d + 4.0 * d - 1.0;
					voidCloudInsideColor *= 0.9; //why am I doing this again?
				}
			}
		}
		else voidCloudInsideColor = vec4(0.0);
	#endif
}