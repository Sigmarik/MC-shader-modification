#version 120

#include "/lib/defines.glsl"

uniform float pixelSizeX;
uniform float pixelSizeY;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 cameraPosition;
uniform vec3 fogColor;
uniform vec3 skyColor;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

#include "/lib/math.glsl"

#include "lib/calcFogColor.glsl"

void main() {

/* DRAWBUFFERS:0 */
	gl_FragData[0] = starData.a > 0.9 ? starData : vec4(calcFogColor(normalize((gbufferProjectionInverse * vec4(gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY) * 2.0 - 1.0, 1.0, 1.0)).xyz)), 1.0); //gcolor
}