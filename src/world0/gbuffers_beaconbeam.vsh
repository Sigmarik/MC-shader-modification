#version 120

#include "/lib/defines.glsl"

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
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

#include "/lib/math.glsl"

void main() {
	#include "/lib/beacon.vsh"
}