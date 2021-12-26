#version 120

#include "/lib/defines.glsl"

attribute vec2 mc_midTexCoord;
attribute vec3 mc_Entity;

uniform float frameTimeCounter;
uniform float night;
uniform float rainStrength;
uniform float wetness;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;
uniform vec3 sunPosition;
        vec3 sunPosNorm = normalize(sunPosition);

varying float ao;
varying float isDirt;
varying float isLava;
varying vec2 lmcoord;
varying vec2 randCoord;
varying vec2 texcoord;
varying vec4 glcolor;

#include "/lib/noiseres.glsl"

#include "/lib/math.glsl"

vec3 windOffset(vec3 pos, float multiplier, float speed) {
	float baseWindAmt = min(rainStrength, wetness) * 1.5 + (pos.y / 192.0 + 0.66666666) * (1.0 - night * 0.5); //1.0x at y=64, 2.0x at y=256, and rain increases this to 2.5x at y=64 and 3.5x at y=256. Rain also increases it by 1.5x, and night decreases it to 0.5x.
	vec3 waveStart = texture2D(noisetex, vec2(pos.x + frameTimeCounter, pos.z) * 0.375 * invNoiseRes).rgb; //oscillation direction and phase offset
	float waveMultiplier = texture2D(noisetex, vec2(pos.x * 0.125 + frameTimeCounter * 0.5, pos.z * 0.125) * invNoiseRes).r * 0.5 + 0.5; //multiplier to add variety
	vec2 offset = vec2(waveStart.y * 0.4 - 0.2, waveStart.z * 0.2 - 0.1) * cos(waveStart.x * 6.283185307 + frameTimeCounter * speed) * waveMultiplier; //combine to get position offset
	offset.x -= baseWindAmt * 0.01 + 0.02; //biased towards east wind
	offset *= multiplier * baseWindAmt; //scale offset
	return vec3(offset.x, 0.5 / (lengthSquared2(offset) + 0.5) - 1.0, offset.y); //move vertexes down some based on how much they were offset
}

#ifdef GRASS_PATCHES
	float noiseMap(vec2 coord) {
		coord *= invNoiseRes;
		float noise = 0.0;
		noise += texture2D(noisetex, coord * 0.03125).r;
		noise += texture2D(noisetex, coord * 0.09375).r * 0.5;
		noise += texture2D(noisetex, coord * 0.375  ).r * 0.25;
		return noise;
	}
#endif

#if WATER_WAVE_STRENGTH != 0
	float waterWave(vec2 pos) {
		pos *= invNoiseRes;
		float offset = 0.875;
		offset += cos(texture2D(noisetex, pos / 20.0).r * 25.0 + frameTimeCounter * 2.0) * 0.5;
		offset += cos(texture2D(noisetex, pos / 15.0).r * 12.5 + frameTimeCounter * 3.0) * 0.375;
		return offset * (float(WATER_WAVE_STRENGTH) / 100.0 / 1.75);
	}
#endif

void main() {
	ao = 1.0;
	isLava = 0.0;
	isDirt = 0.0;

	bool isGrass = false;

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec4 pos = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex); //chunk coords -> world coords

	glcolor = gl_Color;

	vec3 normal;
	//Using IDs above 10000 to represent all blocks that I care about
	//if the ID is less than 10000, then I don't need to do extra logic to see if it has special effects.
	if (mc_Entity.x > 10000.0) {
		int id = int(mc_Entity.x) - 10000;
		if (id == 1) { //grass blocks and dirt
			normal = gl_NormalMatrix * gl_Normal;

			#ifdef GRASS_PATCHES
				isGrass = gl_Color.g > gl_Color.b;
			#endif

			#ifdef WET_DIRT
				if (abs(gl_Color.g - gl_Color.b) < 0.02) isDirt = 1.0;
			#endif
		}
		else if (id == 2) { //tallgrass and other plants
			normal = gl_NormalMatrix[1];

			#ifdef REMOVE_Y_OFFSET
				pos.y = floor(pos.y + cameraPosition.y + 0.5) - cameraPosition.y;
			#endif
			#ifdef REMOVE_XZ_OFFSET
				pos.xz = floor(pos.xz + cameraPosition.xz + 0.5) - cameraPosition.xz;
			#endif

			#if defined(GRASS_AO) || defined(WAVING_GRASS)
				float amt = float(texcoord.y < mc_midTexCoord.y);
				#ifdef GRASS_AO
					ao = amt;
				#endif

				#ifdef WAVING_GRASS
					if (amt > 0.1) { //will always either be 0.0 or 1.0
						pos.xyz += windOffset(pos.xyz + cameraPosition, amt * lmcoord.y * lmcoord.y, 0.75 * 6.283185307);
					}
				#endif
			#endif

			#ifdef GRASS_PATCHES
				isGrass = gl_Color.g > gl_Color.b; //some double plants are colored by texture, and others are colored by biome.
			#endif
		}
		else if (id == 3 || id == 4) { //double plants
			normal = gl_NormalMatrix[1];

			#ifdef REMOVE_Y_OFFSET
				pos.y = floor(pos.y + cameraPosition.y + 0.5) - cameraPosition.y;
			#endif
			#ifdef REMOVE_XZ_OFFSET
				pos.xz = floor(pos.xz + cameraPosition.xz + 0.5) - cameraPosition.xz;
			#endif

			#if defined(GRASS_AO) || defined(WAVING_GRASS)
				float amt = (float(texcoord.y < mc_midTexCoord.y) + float(id == 4)) * 0.5;
				#ifdef GRASS_AO
					ao = amt;
				#endif

				#ifdef WAVING_GRASS
					amt *= 1.5;
				#endif

				#ifdef WAVING_GRASS
					if (amt > 0.1) { //will always either be 0.0, 0.5 or 1.0
						pos.xyz += windOffset(pos.xyz + cameraPosition, amt * lmcoord.y * lmcoord.y, 3.14159265359);
					}
				#endif
			#endif

			#ifdef GRASS_PATCHES
				isGrass = gl_Color.g > gl_Color.b; //some double plants are colored by texture, and others are colored by biome.
			#endif
		}
		else if (id == 13) { //leaves
			normal = gl_NormalMatrix * gl_Normal;
			
			#ifdef WAVING_LEAVES
				pos.xyz += windOffset(pos.xyz + cameraPosition, lmcoord.y * lmcoord.y, 3.14159265359);
			#endif
		}
		else if (id == 5) { //crops
			normal = gl_NormalMatrix[1];

			#ifdef GRASS_AO
				ao = float(texcoord.y < mc_midTexCoord.y);
			#endif

			#ifdef WAVING_GRASS
				if (texcoord.y < mc_midTexCoord.y) {
					pos.xyz += windOffset(pos.xyz + cameraPosition, lmcoord.y * lmcoord.y, 0.75 * 6.283185307);
				}
			#endif
		}
		else if (id == 6) { //sugar cane and other arbitrarily-tall plants
			normal = gl_NormalMatrix[1];

			#ifdef LEGACY_SUGARCANE
				glcolor = vec4(1.0);
			#endif

			#ifdef GRASS_PATCHES
				isGrass = true;
			#endif
		}

		#ifdef LAVA_PATCHES
			else if (id == 7) { //lava
				normal = gl_NormalMatrix * gl_Normal;
				vec3 worldPos = pos.xyz + cameraPosition;
				isLava = 1.0;
				if (abs(gl_Normal.y) > 0.1) randCoord = worldPos.xz * 2.0;
				else randCoord = vec2((worldPos.x + worldPos.z) * 4.0, worldPos.y + frameTimeCounter);
			}
		#endif

		else if (id == 8) { //cobwebs and other stuff that shouldn't have shadows
			normal = gl_NormalMatrix[1];
		}

		#if WATER_WAVE_STRENGTH != 0
			else if (id == 12) { //lily pads
				vec3 worldPos = pos.xyz + cameraPosition;
				if (worldPos.y <= SEA_LEVEL + 0.99 && worldPos.y >= SEA_LEVEL - 0.01) {
					pos.y -= waterWave(worldPos.xz + 0.5); // + 0.5 to avoid sharp edges in lava displacement when the coords are on the edge of a noisetex pixel
				}
				normal = gl_Normal;
			}
		#endif

		else {
			normal = gl_NormalMatrix * gl_Normal;
		}
	}
	else {
		normal = gl_NormalMatrix * gl_Normal;
	}

	#ifdef GRASS_PATCHES
		if (isGrass) {
			float noise = noiseMap(pos.xz + cameraPosition.xz) - HUMIDITY_OFFSET;
			noise = (noise - wetness * 0.125) * (wetness * -0.5 + 1.0); //more lush with less variation during rain
			if (noise > 0.0) glcolor.rg += vec2(noise * 0.33333333, noise * -0.125);
			else glcolor.rb += noise * 0.25;
			glcolor.g = max(glcolor.g, glcolor.r * 0.85);
		}
	#endif

	#include "lib/glmult.glsl"

	gl_Position = gl_ProjectionMatrix * (gbufferModelView * pos);
}