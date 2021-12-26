#version 120

#include "/lib/defines.glsl"

uniform float frameTimeCounter;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform sampler2D texture;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + gbufferModelViewInverse[3].xyz; //because cameraPosition isn't actually the position of the camera -_-

#ifdef FANCY_BEACONS
	varying vec2 beaconPos;
#endif
#ifndef FANCY_BEACONS
	varying vec2 texcoord;
#endif
#ifdef FANCY_BEACONS
	varying vec3 pos;
#endif
varying vec4 glcolor;

#include "/lib/goldenOffsets.glsl"

#include "/lib/math.glsl"

#include "/lib/beaconMethods.glsl"

void main() {
	#include "/lib/beacon.fsh"

/* DRAWBUFFERS:04 */
	//2356
	//gl_FragData[0] = vec4(normalize(midTest.xz - beaconPos) * 0.5 + 0.5, 0.0, 1.0).xzyw; //normal
	//gl_FragData[1] = color; //composite
	//gl_FragData[2] = vec4(1.0, 1.0, 0.0, 1.0); //gaux2
	//gl_FragData[3] = vec4(1.0, 0.0, 0.0, color.a); //gaux3
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(0.96875, 0.96875, 1.0, 1.0); //gaux1
}