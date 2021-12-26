#version 120

#define FANCY_BEACONS //Builderb0y's better beacon beams bring big bright beautiful beacon beams to all biomes, bro

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

float lengthSquared2(vec2 v) { return dot(v, v); }

void main() {
	#ifdef FANCY_BEACONS
		vec4 p = gl_ModelViewMatrix * gl_Vertex;
		p = gbufferModelViewInverse * vec4(p.xyz, 0.0);
		beaconPos = floor(p.xz + eyePosition.xz) - eyePosition.xz + 0.5;
		vec2 relativePos = p.xz - beaconPos;

		if (lengthSquared2(relativePos) > 0.0625) { //transparent layer. testing position instead of gl_Color.a because gl_Color.a is the same on both layers in 1.7
			gl_Position = vec4(100.0);
			return;
		}

		p.xz += relativePos * 1.5; //make the beam a little bit wider, so that we have more fragments to work with.
		pos = p.xyz;
		p = gbufferModelView * vec4(p.xyz, 0.0);
		gl_Position = gl_ProjectionMatrix * vec4(p.xyz, 1.0);
	#else
		texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
		gl_Position = ftransform();
	#endif

	glcolor = gl_Color;
}