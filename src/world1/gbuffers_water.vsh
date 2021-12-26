#version 120

#include "/lib/defines.glsl"

attribute vec3 mc_Entity;

uniform float far;
uniform float frameTimeCounter;
uniform int heldBlockLightValue;
uniform int heldItemId;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform sampler2D noisetex;

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying float mcentity; //ID data of block currently being rendered.
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 blockLightColor; //Color of block light. Gets yellow-er if you stay away from light-emitting blocks for a while.
varying vec3 normal;
varying vec3 pos;
varying vec4 glcolor;
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

#include "/lib/noiseres.glsl"

#include "/lib/calcHeldLightColor.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor  = gl_Color;
	vec4 p = gl_ModelViewMatrix * gl_Vertex;
	//for whatever reason, we need 0 for w here.
	//this can be verified to be correct by looking at the brightness of better snow embedded in stained glass panes.
	pos = (gbufferModelViewInverse * vec4(p.xyz, 0.0)).xyz;
	gl_Position = gl_ProjectionMatrix * p;
	normal = gl_Normal * 0.5 + 0.5;
	mcentity = 0.1;

	//Using IDs above 10000 to represent all blocks that I care about
	//if the ID is less than 10000, then I don't need to do extra logic to see if it has special effects.
	if (mc_Entity.x > 10000.0) {
		int id = int(mc_Entity.x) - 10000;
		if      (id == 9)  mcentity = 1.1; //water
		else if (id == 10) mcentity = 2.1; //stained glass
		else if (id == 11) mcentity = 3.1; //ice
	}

	#include "/lib/heldlightData.glsl"

	blockLightColor = mix(vec3(1.0, 0.5, 0.15), vec3(1.0, 0.85, 0.7), eyeBrightnessSmooth.x / 240.0);
}