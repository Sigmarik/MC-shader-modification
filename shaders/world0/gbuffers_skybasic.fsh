#version 120

//#define CROSS_PROCESS //Opposite of desaturation, makes everything more vibrant and saturated.
//#define CUBIC_CHUNKS //Disables black fog/sky colors below Y=0
#define EXCLUSION_RADIUS 1.0 //Radius around the moon at which fancy stars/galaxies stop rendering [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define FANCY_STARS //Improved stars in the overworld
#define GALAXIES //Galaxies visible at night in the overworld, with even more stars inside them
#define INFINITE_OCEANS //Simulates water out to the horizon instead of just your render distance.
#define RAINBOWS //If enabled, rainbows will appear when the weather changes from rainy to clear
#define SUN_POSITION_FIX //Enable this if the horizon "splits" at sunset when rapidly rotating your camera.
#define SUNSET_COEFFICIENT_BLUE 6.2 //Blue sunset coefficient. Higher values will result in the blue color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time. [6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 8.0]
#define SUNSET_COEFFICIENT_GREEN 6.7 //Green sunset coefficient. Higher values will result in the green color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time. [6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 8.0]
#define SUNSET_COEFFICIENT_RED 7.2 //Red sunset coefficient. Higher values will result in the red color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time. [6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 8.0]

uniform float adjustedTime;
uniform float day;
uniform float night;
uniform float phase;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float rainStrength;
uniform float sunset;
uniform float wetness;
uniform int worldDay;
uniform int worldTime;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
uniform vec3 fogColor;
uniform vec3 skyColor;
#ifndef SUN_POSITION_FIX
uniform vec3 sunPosition;
        vec3 sunPosNorm = normalize(sunPosition);
#endif

vec3 upPosNorm = gbufferModelView[1].xyz;

#ifdef SUN_POSITION_FIX
	varying vec3 sunPosNorm;
#endif
varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

const float sunPathRotation = 30.0; //Angle that the sun/moon rotate at [-45.0 -40.0 -35.0 -30.0 -25.0 -20.0 -15.0 -10.0 -5.0 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0]

const int noiseTextureResolution = 64;
const float invNoiseRes = 1.0 / float(noiseTextureResolution);

#if defined(FANCY_STARS) || defined(GALAXIES)
	const mat2 starRotation = mat2(
		cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994),
		sin(sunPathRotation * 0.01745329251994),  cos(sunPathRotation * 0.01745329251994)
	);
#endif

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

float interpolateSmooth1(float x) { return x * x * (3.0 - 2.0 * x); }
vec3  interpolateSmooth3(vec3 v)  { return v * v * (3.0 - 2.0 * v); }

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
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

#if defined(FANCY_STARS) || defined(GALAXIES)
	//uses additive blending, so no alpha returned.
	vec3 drawStars(vec3 pos, float space) {
		#ifndef CUBIC_CHUNKS
			if (cameraPosition.y < -gbufferModelViewInverse[3][1]) return vec3(0.0);
		#endif
		float upDot = dot(pos, upPosNorm);

		if (upDot > 0.0 && (night > 0.001 || space < 0.999) && rainStrength * space < 0.999) {
			vec2 dailyOffset = texture2D(noisetex, (floor(vec2(worldDay, worldDay * invNoiseRes)) + 0.5) * invNoiseRes).rg;
			//vec2 dailyOffset = texelFetch2D(noisetex, ivec2(worldDay, worldDay * invNoiseRes), 0).rg;

			float exclusion = interpolateSmooth1(clamp(acos(-dot(pos, sunPosNorm)) * 8.0 - EXCLUSION_RADIUS, 0.0, 1.0)); //darken things around the moon

			pos = (gbufferModelViewInverse * vec4(pos, 0.0)).xyz;
			pos.yz *= starRotation; //match sunPathRotation
			vec2 starPos = pos.xz / sqrt(pos.y + 1.0); //divide sky up into cells. each cell will have a star in it, though most stars won't actually render
			starPos *= 64.0; //main scaling factor
			starPos.x += worldTime * 0.015625; //gives the appearance of stars rotating like the sun/moon. Not actual rotation, but follows where the moon goes fairly closely

			vec3 result = vec3(0.0);

			#ifdef GALAXIES
				float noise = 0.0; //noise maps for galaxies
				vec2 noisePos = starPos * 0.03125 * invNoiseRes + dailyOffset; //galaxy scaling factor
				noise += texture2D(noisetex, noisePos        ).r * 0.6;
				noise += texture2D(noisetex, noisePos * 2.0  ).r * 0.36;
				noise += texture2D(noisetex, noisePos * 4.0  ).r * 0.216;
				noise += texture2D(noisetex, noisePos * 8.0  ).r * 0.1296;
				noise += texture2D(noisetex, noisePos * 16.0 ).r * 0.07776;
				noise += texture2D(noisetex, noisePos * 32.0 ).r * 0.046656;
				noise += texture2D(noisetex, noisePos * 64.0 ).r * 0.0279936;
				noise += texture2D(noisetex, noisePos * 128.0).r * 0.01679616;
				noise += texture2D(noisetex, noisePos * 256.0).r * 0.010077696;
				noise *= 0.6780553935455204; //1.0 / (0.6 + 0.36 + ... + 0.010077696)
				float biasedNoise = square(max(noise * 3.0 - 1.5, 0.3));

				float colorNoise = 0.0;
				colorNoise += texture2D(noisetex, -noisePos * 2.0).r * 0.5;
				colorNoise += texture2D(noisetex, -noisePos * 4.0).r * 0.25;
				colorNoise += texture2D(noisetex, -noisePos * 8.0).r * 0.125;

				//colorize galaxies with randomized hue
				//also reduce brightness near the moon, and when it's not quite dark enough yet.
				result += mix(hue(colorNoise) * 0.25, vec3(0.25), min(biasedNoise + 0.2, 1.0)) * (biasedNoise - 0.09) * clamp(max(adjustedTime - 7.8, 1.0 - space * 12.0), 0.0, 1.0) * exclusion;
			#endif

			#ifdef FANCY_STARS
				vec3 random = texture2D(noisetex, (floor(starPos + dailyOffset * noiseTextureResolution) + 0.5) * invNoiseRes).rgb;
				//vec3 random = texelFetch2D(noisetex, ivec2(mod(floor(starPos) + dailyOffset * noiseTextureResolution, noiseTextureResolution)), 0).rgb; //rg = star position within cell, b = color/size data (red stars are smaller/dimmer, blue stars are bigger/brighter)
				random.rg = random.rg * 0.7 + 0.15; //fix stars being chopped in half because their position was on the border of a cell
				float dist = distance(fract(starPos), random.rg) * (2.0 - random.b) * 5.0; //distance from center of star, with scaling factor based on color of star. 5.0 is star scaling factor; bigger values = smaller stars.
				dist *= length(gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY) - 0.5) * 2.0 + 1.0; //compensate for projection effects. 2.0 is scaling factor; increase it if stars on the edge of your screen are bigger than stars in the center
				dist = 1.0 - dist; //positive in center of star, negative outside the star.

				#ifdef GALAXIES
				if (dist > 0.0 && 1.0 - random.b < min(biasedNoise, exclusion)) { //pixel is part of star, and is bright enough for its noise value
					random.b = (random.b + biasedNoise - 1.0) / biasedNoise; //scale value based on threshold (determined by galaxy density)
				#else
				if (dist > 0.0 && 1.0 - random.b < min(0.1, exclusion)) { //pixel is part of star, 1/10'th of the stars generated will actually render.
					random.b = random.b * 10.0 - 9.0; //scale value based on threshold (1/20'th in this case)
				#endif
					vec3 starColor = mix(vec3(0.5), vec3(0.25, 0.5, 1.0), random.b); //blue or white, red dwarfs aren't visible to the naked eye.
					starColor = mix(starColor, vec3(1.0), dist * dist * 0.5 * random.b) * dist * dist; //whitest and brightest in the center
					starColor *= clamp(random.b * random.b * 1.5 + max(adjustedTime - 8.5, 1.0 - space * 16.0), 0.0, 1.0); //fading animation at sunset, blue stars appear sooner and disappear later
					starColor *= random.b * 0.75 + 0.25; //white stars are darker
					#ifdef GALAXIES
						starColor *= (1.0 - noise * 0.75); //stand out less where galaxies are already as bright as the stars
					#endif
					result += starColor;
				}
			#endif

			return result * (1.0 - max(rainStrength, wetness) * space) * (1.0 - fogify(upDot / space, 0.0625)); //reduce brightness when raining and near the horizon
		}
		return vec3(0.0);
	}
#endif

vec3 calcSkyColor(vec3 pos) {
	#ifndef CUBIC_CHUNKS
		if (cameraPosition.y < -gbufferModelViewInverse[3][1]) return vec3(0.0);
	#endif
	float space = square(max(cameraPosition.y, 256.0) / 256.0 + 1.0);
	float upDot = dot(pos, upPosNorm) * space * 0.5; //not much, what's up with you?
	space = 4.0 / space;
	bool top = upDot > 0.0;
	float sunDot = dot(pos, sunPosNorm) * 0.5 + 0.5;
	float rainCoefficient = max(rainStrength, wetness);
	vec3 color;
	vec3 skyclr = mix(skyColor, fogColor * 0.65, rainCoefficient) * space;
	vec3 fogclr = fogColor * (1.0 - rainCoefficient * 0.5);

	#ifdef RAINBOWS
		float rainbowStrength = (wetness - rainStrength) * day * 0.25;
		float rainbowHue = (sunDot - 0.25) * -24.0;
		if (rainbowStrength > 0.0 && rainbowHue > 0.0 && rainbowHue < 1.0) {
			rainbowHue *= 6.0;
			vec3 rainbowColor = clamp(vec3(1.5, 2.0, 1.5) - abs(rainbowHue - vec3(1.5, 3.0, 4.5)), 0.0, 1.0) * rainbowStrength;
			skyclr += rainbowColor * space * space;
			fogclr += rainbowColor;
		}
	#endif

	if (top) {
		color = skyclr + NIGHT_SKY_COLOR * (1.0 - day) * (1.0 - rainStrength) * space; //avoid pitch black sky at night
		if (day > 0.001) color = mix(color, SUN_GLOW_COLOR,  0.75 / ((1.0 - sunDot) * 16.0 + 1.0) * day   * (1.0 - rainStrength * 0.75) * space); //make the sun illuminate the sky around it
		else             color = mix(color, MOON_GLOW_COLOR, 0.75 / (       sunDot  * 16.0 + 1.0) * night * (1.0 - rainStrength       ) * space * phase); //make the moon illuminate the sky around it
	}
	else color = fogclr;

	if (sunset > 0.001 && rainCoefficient < 0.999) {
		vec3 sunsetColor = interpolateSmooth3(clamp(vec3(SUNSET_COEFFICIENT_RED, SUNSET_COEFFICIENT_GREEN, SUNSET_COEFFICIENT_BLUE) - adjustedTime + upDot + sunDot * 0.2 * (1.0 - night), 0.0, 1.0)); //main sunset gradient
		sunsetColor = mix(fogclr, sunsetColor, (sunDot * 0.5 + 0.5) * sunset * (1.0 - rainCoefficient)); //fade in at sunset and out when not looking at the sun
		color = mix(color, sunsetColor, fogify(upDot, 0.25)); //mix with final color based on how close we are to the horizon
	}
	else if (top) color = mix(color, fogclr, fogify(upDot, 0.25));

	#if defined(FANCY_STARS) || defined(GALAXIES)
		color += drawStars(pos, space);
	#endif

	color += texture2D(noisetex, gl_FragCoord.xy * invNoiseRes).rgb * 0.00390625; //dither

	return color;
}

//checks a few conditions before actually calculating the sky color.
vec4 checkSkyColor(vec3 pos) {
	#ifdef INFINITE_OCEANS
		float upDot = dot(pos, upPosNorm);
		if (upDot < 0.0) return vec4(0.0); //calculated in composite instead.
	#endif

	if (starData.a > 0.9) {
		#ifdef FANCY_STARS
			return vec4(0.0, 0.0, 0.0, 1.0);
		#else
			#ifdef INFINITE_OCEANS
				return vec4(starData.rgb * (1.0 - fogify(upDot * square(max(cameraPosition.y, 256.0) / 256.0 + 1.0), 0.25)), 1.0); //apply fog to stars near the horizon
			#else
				return starData;
			#endif
		#endif
	}

	return vec4(calcSkyColor(pos), 1.0);
}

void main() {
	vec3 pos = normalize((gbufferProjectionInverse * vec4(gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY) * 2.0 - 1.0, 1.0, 1.0)).xyz);
	vec4 color = checkSkyColor(pos);

/* DRAWBUFFERS:04 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(0.0, 0.0, 0.0, color.a * 0.5); //gaux1
}