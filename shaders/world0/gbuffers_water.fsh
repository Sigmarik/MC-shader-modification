#version 120

#define ALT_GLASS //Uses alternate blending method for stained glass which looks more like real stained glass
#define BRIGHT_WATER //Overrides light levels under water to be higher
#define CLEAR_WATER //Overwrites water texture to be completely transparent
//#define CROSS_PROCESS //Opposite of desaturation, makes everything more vibrant and saturated.
//#define CUBIC_CHUNKS //Disables black fog/sky colors below Y=0
#define DESATURATE //De-saturates the world at night, during rain, and in the end
#define DYNAMIC_LIGHTS //Holding blocks that emit light will light up their surroundings
#define FOG_DISTANCE_MULTIPLIER_OVERWORLD 0.25 //How far away fog starts to appear in the overworld. [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.2 2.4 2.6 2.8 3.0 3.5 4.0 4.5 5.0 6.0 7.0 8.0 9.0 10.0]
#define FOG_ENABLED_OVERWORLD //Enables fog in the overworld. It is recommended to have this enabled if you also have infinite oceans enabled!
#define RAINBOWS //If enabled, rainbows will appear when the weather changes from rainy to clear
#define SUNSET_COEFFICIENT_BLUE 6.2 //Blue sunset coefficient. Higher values will result in the blue color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time. [6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 8.0]
#define SUNSET_COEFFICIENT_GREEN 6.7 //Green sunset coefficient. Higher values will result in the green color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time. [6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 8.0]
#define SUNSET_COEFFICIENT_RED 7.2 //Red sunset coefficient. Higher values will result in the red color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time. [6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 8.0]
#define THRESHOLD_ALPHA 0.6 //Anything above this opacity counts as part of the border of stained glass, and will not apply blur/reflection effects [0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95]
//#define VANILLA_LIGHTMAP //Uses vanilla light colors instead of custom ones. Requires optifine 1.12.2 HD_U_D1 or later!
#define VIGNETTE //Reduces the brightness of dynamic light around edges the of your screen

uniform float adjustedTime;
uniform float blindness;
uniform float day;
uniform float far;
uniform float night;
uniform float nightVision;
uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float rainStrength;
uniform float screenBrightness;
uniform float sunset;
uniform float wetness;
uniform int isEyeInWater;
uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelViewInverse;
uniform sampler2D lightmap;
uniform sampler2D texture;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + gbufferModelViewInverse[3].xyz; //because cameraPosition isn't actually the position of the camera -_-
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition;
        vec3 sunPosNorm = normalize(sunPosition);
uniform vec3 upPosition;
        vec3 upPosNorm = normalize(upPosition);

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying float mcentity; //ID data of block currently being rendered.
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
varying vec3 normal;
varying vec3 pos;
varying vec3 shadowColor; //Color of shadows. Sky-colored, to simulate indirect lighting.
varying vec3 skyLightColor; //Color of sky light. Is usually white during the day, and very dark blue at night.
varying vec4 glcolor;
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

#ifdef CROSS_PROCESS
	const vec3 NIGHT_SKY_COLOR = vec3(0.02,  0.025, 0.05); //Added to sky color at night to avoid it being completely black
#else
	const vec3 NIGHT_SKY_COLOR = vec3(0.025, 0.025, 0.05); //Added to sky color at night to avoid it being completely black
#endif

float square(float x)        { return x * x; } //faster than pow().

float interpolateSmooth1(float x) { return x * x * (3.0 - 2.0 * x); }
vec3  interpolateSmooth3(vec3 v)  { return v * v * (3.0 - 2.0 * v); }

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
}

vec3 calcMainLightColor(inout float blocklight, inout float skylight, inout float heldlight, in float dist) {
	#ifdef VANILLA_LIGHTMAP
		vec3 lightclr = texture2D(lightmap, vec2(blocklight, skylight)).rgb;
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

void main() {
	int id = int(mcentity);
	vec4 color = texture2D(texture, texcoord);

	#ifdef CLEAR_WATER
		if (id == 1) {
			color.a = 0.0;
		}
		else {
	#endif
		float dist = length(pos) / far;

		float skylight = lmcoord.y;
		float blocklight = lmcoord.x;
		float heldlight = 0.0;

		#ifdef BRIGHT_WATER
			if (isEyeInWater == 1) skylight = skylight * 0.5 + 0.5;
		#endif

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
				color *= glcolor;

				color.rgb *= calcMainLightColor(blocklight, skylight, heldlight, dist);

				#ifdef DESATURATE
					if (night > 0.01 || rainStrength > 0.01) {
						float lightModifier = skylight - max(blocklight, heldlight) * 0.5;
						if (lightModifier > 0.001) {
							vec3 average = vec3((color.r + color.g * 2.0 + color.b) * 0.25);
							color.rgb = mix(color.rgb, average, (rainStrength + night) * lightModifier * min(float(240 - eyeBrightnessSmooth.x), float(eyeBrightnessSmooth.y)) / 960.0);
						}
					}
				#endif

				#ifdef CROSS_PROCESS
					vec3 skyCrossColor    = mix(mix(vec3(1.4, 1.2, 1.1), vec3(1.0, 1.1, 1.4), night), vec3(1.0), wetness); //cross processing color from the sun
					vec3 blockCrossColor  = mix(vec3(1.4, 1.0, 0.8), vec3(1.2, 1.1, 1.0), eyeBrightnessSmooth.x / 240.0); //cross processing color from block lights
					vec3 finalCrossColor  = mix(mix(vec3(1.0), skyCrossColor, lmcoord.y), blockCrossColor, lmcoord.x); //final cross-processing color (blockCrossColor takes priority over skyCrossColor)
					color.rgb = clamp(color.rgb * finalCrossColor - vec3(color.g + color.b, color.r + color.b, color.r + color.g) * 0.1, 0.0, 1.0);
				#endif

				if (blindness > 0.0) color.rgb *= interpolateSmooth1(max(1.0 - dist * far * 0.2, 0.0)) * 0.5 * blindness + (1.0 - blindness);

		#ifdef ALT_GLASS
			}
		#endif

		#ifdef FOG_ENABLED_OVERWORLD
			#ifdef ALT_GLASS //don't apply fog to glass when better glass is enabled, since this is done in composite1 instead
				if (id != 2) {
			#endif
				#ifndef CLEAR_WATER //already checked at the beginning if clear water is enabled, only needs to be re-checked if it's not.
					if (id != 1) { //water fog is handled in composite and composite1, to be compatible with infinite oceans
				#endif
						float d = dist + wetness * eyeBrightnessSmooth.y * 0.00125 - 0.2; //wetness * 0.3 * eyeBrightness / 240.0 - 0.2
						if (d > 0.0) {
							float y = (gbufferModelViewInverse * vec4(pos, 1.0)).y + cameraPosition.y;
							d = fogify(d * (rainStrength + 1.0) * exp2(1.5 - y * 0.015625), FOG_DISTANCE_MULTIPLIER_OVERWORLD);
							color.rgb = mix(calcFogColor(pos / (dist * far)) * min(max(lmcoord.y * 2.0, eyeBrightness.y / 120.0), 1.0) * (1.0 - blindness), color.rgb, d); //min(max(aux2.g, eyeBrightness.y), 1.0)
						}
				#ifndef CLEAR_WATER
					}
				#endif
			#ifdef ALT_GLASS
				}
			#endif
		#endif
	#ifdef CLEAR_WATER
		}
	#endif

/* DRAWBUFFERS:2563 */
	gl_FragData[0] = vec4(normal, 1.0); //gnormal, write to here first so that it won't discard other buffers when opacity is low
	gl_FragData[1] = vec4(lmcoord, id * 0.1, 1.0); //gaux2
	gl_FragData[2] = vec4(1.0, 0.0, 0.0, color.a); //gaux3
	gl_FragData[3] = color; //composite
}