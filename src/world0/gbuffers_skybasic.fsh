#version 120

#include "/lib/defines.glsl"

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

#include "/lib/noiseres.glsl"

#if defined(FANCY_STARS) || defined(GALAXIES)
	const mat2 starRotation = mat2(
		cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994),
		sin(sunPathRotation * 0.01745329251994),  cos(sunPathRotation * 0.01745329251994)
	);
#endif

#include "lib/colorConstants.glsl"

#include "/lib/math.glsl"

#include "/lib/hue.glsl"

#include "lib/drawStars.glsl"

#include "lib/calcSkyColorFull.glsl"

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