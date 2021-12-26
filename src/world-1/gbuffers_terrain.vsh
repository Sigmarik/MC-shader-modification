#version 120

#include "/lib/defines.glsl"

attribute vec2 mc_midTexCoord;
attribute vec3 mc_Entity;

uniform float frameTimeCounter;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;

varying float ao;
varying float isLava;
varying vec2 lmcoord;
varying vec2 randCoord;
varying vec2 texcoord;
varying vec4 glcolor;

#include "/lib/noiseres.glsl"

#if LAVA_WAVE_STRENGTH != 0
	float lavaWave(vec2 pos) {
		pos *= invNoiseRes;
		float offset = 0.875;
		offset += cos(texture2D(noisetex, pos / 30.0).r * 25.0 + frameTimeCounter) * 0.5;
		offset += cos(texture2D(noisetex, pos / 20.0).r * 12.5 + frameTimeCounter * 1.5) * 0.375;
		return offset * (float(LAVA_WAVE_STRENGTH) / 100.0 / 1.75);
	}
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec4 pos = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex); //chunk coords -> world coords

	glcolor = gl_Color;

	ao = 1.0;
	isLava = 0.0;

	//Using IDs above 10000 to represent all blocks that I care about
	//if the ID is less than 10000, then I don't need to do extra logic to see if it has special effects.
	if (mc_Entity.x > 10000.0) {
		int id = int(mc_Entity.x) - 10000;
		if (id == 7) {
			lmcoord.x = 0.96875; //hide vanilla lighting glitches

			vec3 worldPos = pos.xyz + cameraPosition;
			#if LAVA_WAVE_STRENGTH != 0
				if (worldPos.y <= 32.01) {
					pos.y -= lavaWave(worldPos.xz + 0.5) * fract(worldPos.y - 0.01); // + 0.5 to avoid sharp edges in lava displacement when the coords are on the edge of a noisetex pixel
				}
			#endif

			#ifdef LAVA_PATCHES
				isLava = 1.0;
				if (abs(gl_Normal.y) > 0.1) randCoord = worldPos.xz * 0.5;
				else randCoord = vec2((worldPos.x + worldPos.z) * 4.0, worldPos.y + frameTimeCounter);
			#endif
		}
		else if (id == 2 || id == 3 || id == 4) { //plants and double plants
			#ifdef GRASS_AO
				ao = float(texcoord.y < mc_midTexCoord.y);
				if (id != 2) ao = (ao + float(id == 4)) * 0.5;
			#endif

			#ifdef REMOVE_Y_OFFSET
				pos.y = floor(pos.y + cameraPosition.y + 0.5) - cameraPosition.y;
			#endif
			#ifdef REMOVE_XZ_OFFSET
				pos.xz = floor(pos.xz + cameraPosition.xz + 0.5) - cameraPosition.xz;
			#endif
		}
		#ifdef GRASS_AO
			else if (id == 5) { //crops
				ao = float(texcoord.y < mc_midTexCoord.y);
			}
		#endif
	}

	gl_Position = gl_ProjectionMatrix * (gbufferModelView * pos);

	float glmult = dot(vec4(abs(gl_Normal.x), abs(gl_Normal.z), max(gl_Normal.y, 0.0), max(-gl_Normal.y, 0.0)), vec4(0.6, 0.8, 1.0, 0.5));
	glmult = mix(glmult, 1.0, lmcoord.x * lmcoord.x); //increase brightness when block light is high
	glcolor.rgb *= glmult;
}