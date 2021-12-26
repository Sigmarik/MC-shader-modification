#version 120

//#define BRIGHT_PORTAL_FIX //Enable this if end portals are 16x brighter than they should be
#define END_PORTAL_BACKGROUND_NETHER 2 //1: Use overworld fog color. 2: Use end background. [1 2]
#define END_PORTAL_CLOUDS_NETHER 2 //0: No clouds. 1: Use overworld clouds. 2: Use void clouds. [0 1 2]
#define END_PORTAL_EFFECTS_NETHER //Enables fancy effects for end portals
#define END_PORTAL_FOREGROUND_NETHER 2 //0: No foreground image. 1: Use overworld screenshot. 2: Use end island screenshot. [0 1 2]
#define ENDER_ARCS //Adds bolts of plasma that arc through the nebulae. Requires ender nebulae to be enabled!
#define ENDER_NEBULAE //Adds animated nebulae to the background of the end dimension
#define ENDER_STARS //Adds blinking stars to the background of the end dimension. Stackable with nebulae/plasma.
//#define OLD_CLOUDS //Uses old cloud rendering method from earlier versions, for people who don't like pretty things.

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

float interpolateSmooth1(float x) { return x * x * (3.0 - 2.0 * x); }
vec2  interpolateSmooth2(vec2 v)  { return v * v * (3.0 - 2.0 * v); }

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
}

#ifdef END_PORTAL_EFFECTS_NETHER
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

	#if END_PORTAL_BACKGROUND_NETHER == 2
		#ifdef ENDER_NEBULAE
			float random(vec2 coord) {
				vec2 middle = fract(coord);
				vec4 corners = vec4(coord - middle + 0.5, 0.0, 0.0);
				corners.zw = corners.xy + 1.0;
				corners *= invNoiseRes;

				float r00 = texture2D(noisetex, corners.xy).r; //random value at the (0, 0) corner
				float r01 = texture2D(noisetex, corners.xw).r; //random value at the (0, 1) corner
				float r10 = texture2D(noisetex, corners.zy).r; //random value at the (1, 0) corner
				float r11 = texture2D(noisetex, corners.zw).r; //random value at the (1, 1) corner

				vec2 mixlvl = interpolateSmooth2(middle); //non-linear interpolation

				return mix(mix(r00, r10, mixlvl.x), mix(r01, r11, mixlvl.x), mixlvl.y); //linear interpolation between the 4 corners
			}

			//base noise algorithm for the overall cloud pattern.
			float cloudNoise(vec2 pos) {
				float noise = -0.32992;
				noise += random(pos * 2.0  + goldenOffset0 * frameTimeCounter * 0.125  ) * 0.4;
				noise += random(pos * 4.0  + goldenOffset1 * frameTimeCounter * 0.0625 ) * 0.16;
				noise += random(pos * 8.0  + goldenOffset2 * frameTimeCounter * 0.04166) * 0.064;
				noise += random(pos * 16.0 + goldenOffset3 * frameTimeCounter * 0.03125) * 0.0256;
				noise += random(pos * 32.0 + goldenOffset4 * frameTimeCounter * 0.025  ) * 0.01024;
				return noise;
			}

			//noise algorithm for all the different colors
			//doesn't need as many iterations as cloudNoise() because it doesn't need to be as "rough"
			//also has different speed/effect multipliers in order to fit the values I want to get out of hue().
			float colorNoise(vec2 pos) {
				float noise = 0.4;
				noise += random(pos * 2.0 + goldenOffset5 * frameTimeCounter * 0.5 ) * 0.25;
				noise += random(pos * 4.0 + goldenOffset6 * frameTimeCounter * 0.25) * 0.125;
				noise += random(pos * 8.0 + goldenOffset7 * frameTimeCounter * 0.16) * 0.0625;
				return noise;
			}

			//both of these functions are quite similar, just with some slight differences in the math.
			#ifdef ENDER_ARCS
				vec4 drawNebulae(vec2 pos) {
					float noise = abs(cloudNoise(pos)); //density depends on how close cloudNoise() is to 0.0
					if (noise < 0.25) { //alpha calculations work within the range 0 - 0.25
						vec3 baseclr = hue(colorNoise(pos)) * 0.625; //nebulae color at this position
						float arclight = square(max(0.7 - noise * 8.0, 0.0)); //brighten areas that are very close to an arc (when cloudNoise() is close to 0.0)
						return vec4(mix(baseclr, vec3(1.0), arclight), square(1.0 - noise * 4.0) * 0.9); //alpha also depends on how close to an arc we are
					}
					else return vec4(0.0); //was not part of a nebula
				}
			#else
				vec4 drawNebulae(vec2 pos) {
					float noise = cloudNoise(pos); //density depends on how close cloudNoise() is to 1.0
					if (noise > 0.0) {
						vec3 baseclr = hue(colorNoise(pos)) * 0.625; //nebulae color at this position
						baseclr += 1.0 - 0.1 / (noise * noise + 0.1); //brighten areas that are close to the "center" of the nebulae (when cloudNoise() is close to 1.0)
						return vec4(baseclr, 1.0 - 0.02 / (noise * noise + 0.02)); //alpha also depends on how close to the "center" of the nebulae we are
					}
					else return vec4(0.0);
				}
			#endif
		#endif

		#ifdef ENDER_STARS
			float fade(float speed, float delay) {
				float newTime = mod(frameTimeCounter * speed, delay);
				//newTime / threshold
				if (newTime < 0.1) return newTime * 10.0;
				//1.0 - (newTime / (1.0 - threshold)) + (threshold / (1.0 - threshold));
				else return newTime * -1.1111111111111111 + 1.1111111111111111;
			}

			vec3 drawStars(vec2 pos) {
				pos *= 16.0; //increase density of stars by a factor of 16x.
				vec2 newpos = floor(pos) + 0.5; //position rounded to the nearest "square". you can immagine this imposing a grid pattern onto the sky.

				//r = random chance that this square will be a star, g = fade animation speed, b = delay before re-appearing
				//r is also used to store "brightness" of the star. if the star is above 75% brightness to start with, it gets to be rendered. (this check is ignored for ender portals)
				vec3 starData1 = texture2D(noisetex, newpos * invNoiseRes).rgb;
				float fadeAmt = fade(starData1.g * 0.1 + 0.15, starData1.b * 8.0 + 1.0);

				if (starData1.r > 0.75 && fadeAmt > 0.0) { //25% of all the "squares" in the sky will be stars
					//r = type (star-shaped vs. circular), g = size multiplier, b = color
					vec3 starData2 = texture2D(noisetex, -newpos * invNoiseRes).rgb;

					float dist;
					//star-shaped stars are smaller than circular ones, so making more of them to compensate.
					if (starData2.r < 0.25) dist = length(pos - newpos) * 2.0; //pythagorean distance
					else { //star-shaped distance (distance increases faster diagonally than cardinally)
						vec2 v = sqrt(abs(pos - newpos));
						dist = v.x + v.y;
					}

					dist *= starData2.g + 1.0; //apply random size modifier. increasing the distance has the effect of decreasing the size, since smaller distances get scaled up to the maximum distance
					dist += 1.0 - fadeAmt; //apply fading animation. again, increasing distance decreases size. when fadeAmt = 0, the star will be invisible.

					float amt = square(max(1.0 - dist, 0.0)); //apply distance calculations to brightness of the star. The closer we are to the center, the brighter it should be.

					vec3 clr = hue(starData2.b * 0.6 - 0.35) * 0.625 + 0.375; //calculate color of star based on random number.
					clr = clr * amt + amt * amt * 0.625; //actually colorize star, and make whiter near the center.

					//make some stars brighter than others
					clr *= starData1.r * 2.0 - 1.0;

					return clr;
				}
				return vec3(0.0);
			}
		#endif
	#endif

	#if END_PORTAL_CLOUDS_NETHER == 1
		#ifdef OLD_CLOUDS
			float cloudNoise(vec2 coord, float size) {
				coord /= size;
				vec4 corners = (vec4(floor(coord), ceil(coord)) + 0.5) * invNoiseRes;

				float r00 = texture2D(noisetex, corners.xy).r; //random value at the (0, 0) corner
				float r01 = texture2D(noisetex, corners.xw).r; //random value at the (0, 1) corner
				float r10 = texture2D(noisetex, corners.zy).r; //random value at the (1, 0) corner
				float r11 = texture2D(noisetex, corners.zw).r; //random value at the (1, 1) corner

				vec2 mixlvl = interpolateSmooth2(fract(coord));

				return mix(mix(r00, r10, mixlvl.x), mix(r01, r11, mixlvl.x), mixlvl.y) * 2.0 - 1.0; //non-linear interpolation between the 4 corners
			}

			vec4 drawClouds(vec2 pos) {
				pos *= 128.0;
				pos.x += frameTimeCounter; //apply wind

				float noise = 0.0;
				noise += cloudNoise(pos, 64.0) * 1.5;
				noise += cloudNoise(pos, 12.0);

				pos *= invNoiseRes;
				float colorNoise = 0.0;
				colorNoise += texture2D(noisetex, pos * 0.25).r - 0.5;
				colorNoise += texture2D(noisetex, pos       ).r * 0.5 - 0.25;
				colorNoise *= noise;

				if (noise > 0.0) { //there are clouds here
					return vec4(mix(vec3(1.0, 1.0, 1.0), vec3(0.48, 0.5, 0.55), fogify(noise - colorNoise, 0.25)), 1.0 - fogify(noise, 0.0625));
				}
				return vec4(0.0);
			}
		#else
			//returns color and opacity of clouds
			vec4 drawClouds(vec2 pos) {
				float time = frameTimeCounter * invNoiseRes;
				pos.x += time; //apply wind
				pos *= invNoiseRes * 4.0;
				time *= 0.015625;

				float noise = 0.0;
				noise += (texture2D(noisetex, (pos + time * goldenOffset0)        ).r - 0.5) * 2.0;
				noise += (texture2D(noisetex, (pos + time * goldenOffset1) * 2.0  ).r - 0.5);
				noise += (texture2D(noisetex, (pos + time * goldenOffset2) * 4.0  ).r - 0.5) * 0.5;
				noise += (texture2D(noisetex, (pos + time * goldenOffset3) * 8.0  ).r - 0.5) * 0.25;
				noise += (texture2D(noisetex, (pos + time * goldenOffset4) * 16.0 ).r - 0.5) * 0.125;
				noise += (texture2D(noisetex, (pos + time * goldenOffset5) * 32.0 ).r - 0.5) * 0.0625;
				noise += (texture2D(noisetex, (pos + time * goldenOffset6) * 64.0 ).r - 0.5) * 0.03125;
				noise += (texture2D(noisetex, (pos + time * goldenOffset7) * 128.0).r - 0.5) * 0.015625;

				if (noise > 0.0) { //there are clouds here
					return vec4(mix(vec3(1.0, 1.0, 1.0), vec3(0.48, 0.5, 0.55), fogify(noise, 0.25)), 1.0 - fogify(noise, 0.0625));
				}
				return vec4(0.0);
			}
		#endif
	#elif END_PORTAL_CLOUDS_NETHER == 2
		vec4 drawVoidClouds(vec2 pos) {
			vec2 cloudPos = pos * invNoiseRes;
			float time = frameTimeCounter * invNoiseRes * 2.0;

			float noise = -1.0;
			noise += texture2D(noisetex, (cloudPos + goldenOffset0 * time) * 0.00390625).r;
			noise += texture2D(noisetex, (cloudPos + goldenOffset1 * time) * 0.0078125 ).r * 0.6;
			noise += texture2D(noisetex, (cloudPos + goldenOffset2 * time) * 0.015625  ).r * 0.36;
			noise += texture2D(noisetex, (cloudPos + goldenOffset3 * time) * 0.03125   ).r * 0.216;
			noise += texture2D(noisetex, (cloudPos + goldenOffset4 * time) * 0.0625    ).r * 0.1296;
			noise += texture2D(noisetex, (cloudPos + goldenOffset5 * time) * 0.125     ).r * 0.07776;
			noise += texture2D(noisetex, (cloudPos + goldenOffset6 * time) * 0.25      ).r * 0.046656;
			noise += texture2D(noisetex, (cloudPos + goldenOffset7 * time) * 0.5       ).r * 0.0279936;

			if (noise > 0.0) { //there are indeed clouds here
				vec3 color = vec3(noise * 0.125); //base cloud color

				vec3 data = texture2D(noisetex, (floor((pos + vec2(frameTimeCounter, 0.0)) * 2.0) + 0.5) * invNoiseRes).rgb; //r = hue, gb = another random offset
				float amt = texture2D(noisetex, data.gb * time * 0.125).r; //base brightness of square
				amt = max(amt * 8.0 - 8.0 + square(noise * 1.375), 0.0); //add bias so that there are more squares where cloud density is high
				color += hue(data.r * 0.35 + 0.45) * amt; //color of square

				return vec4(color, interpolateSmooth1(min(noise * 1.5, 1.0)));
			}
			else return vec4(0.0);
		}
	#endif
#endif

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

	#ifdef END_PORTAL_EFFECTS_NETHER
		if (blockEntityId == 119) {
			vec3 worldPos = (gbufferModelViewInverse * vec4(pos, 1.0)).xyz;

			vec3 correctedPos = worldPos - gbufferModelViewInverse[3].xyz;
			vec2 backgroundPos = correctedPos.xz / correctedPos.y;

			#if END_PORTAL_BACKGROUND_NETHER == 1 //overworld fog color
				color = vec4(0.75, 0.875, 1.0, 1.0);
			#elif END_PORTAL_BACKGROUND_NETHER == 2 //end background
				//draw background noise, matching vanilla end sky texture as closely as possible
				float n = texture2D(noisetex, (floor(backgroundPos * 256.0) + 0.5) * invNoiseRes).r * 2.0 - 1.0; //get random noise value between -1.0 and 1.0
				float n4 = square(square(n)); //bias towards 0 by raising to the 4'th power. also always positive because 4 is even, so don't need to take absolute value.
				color.rgb = vec3(0.46, 0.34, 0.65); //base color
				if (n > 0.0) color.rgb = mix(color.rgb, vec3(1.0), n4 * 0.55); //bright areas
				else         color.rgb = mix(color.rgb, vec3(0.0), n4 * 0.7); //dark areas
				color.rgb *= 0.16; //match vanilla brightness (40/255 ~= 0.16)
				
				vec3 worldPosNorm = normalize(correctedPos);
				vec2 endProjectionPos = worldPosNorm.xz / (worldPosNorm.y + 1.0);
				float multiplier = 8.0 / (lengthSquared2(endProjectionPos) + 8.0); //wrapping behavior produces a mathematical singularity below you, so this hides that.

				#ifdef ENDER_NEBULAE
					vec4 cloudclr = drawNebulae(endProjectionPos);
					color.rgb = mix(color.rgb, cloudclr.rgb, cloudclr.a * multiplier);
				#endif

				#ifdef ENDER_STARS
					vec3 starclr = drawStars(endProjectionPos);
					color.rgb += starclr * multiplier;
				#endif
			#endif

			#if END_PORTAL_FOREGROUND_NETHER == 1 //overworld screenshot
				vec4 islandImage = texture2D(gaux1, backgroundPos * 0.25 + 0.5);
				color.rgb = mix(color.rgb, islandImage.rgb, islandImage.a);
			#elif END_PORTAL_FOREGROUND_NETHER == 2 //end screenshot
				vec4 islandImage = texture2D(gaux2, backgroundPos + 0.5);
				color.rgb = mix(color.rgb, islandImage.rgb, islandImage.a);
			#endif

			#if END_PORTAL_CLOUDS_NETHER == 1 //overworld clouds
				vec2 projectedPos = (worldPos.xz / (worldPos.y - gbufferModelViewInverse[3][1])) * 0.25 + 0.5;
				vec4 cloudColor = drawClouds(projectedPos);
				color.rgb = mix(color.rgb, cloudColor.rgb, cloudColor.a);
			#elif END_PORTAL_CLOUDS_NETHER == 2 //void clouds
				vec4 cloudColor = drawVoidClouds(backgroundPos * 64.0);
				color.rgb = mix(color.rgb, cloudColor.rgb, cloudColor.a);
			#endif

			#ifdef BRIGHT_PORTAL_FIX
				color.rgb *= 0.0625;
			#endif
		}
	#endif

/* DRAWBUFFERS:04 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(lmcoord, 1.0, 1.0); //gaux1
}