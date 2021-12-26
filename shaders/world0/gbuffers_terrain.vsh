#version 120

#define GRASS_AO //Adds ambient occlusion to tallgrass/flowers/etc... Works best with "Remove Y Offset" enabled.
#define GRASS_PATCHES //Makes grass less uniform by making patches of it dryer or lusher. Does not affect leaves.
#define HUMIDITY_OFFSET 1.1 //Higher number = lusher grass. Lower number = dryer grass [0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25]
#define LAVA_PATCHES //Randomizes lava brightness, similar to grass patches
//#define LEGACY_SUGARCANE //Removes biome coloring from sugar cane
//#define REMOVE_XZ_OFFSET //Removes random X/Z offset from tallgrass/flowers/etc...
//#define REMOVE_Y_OFFSET //Removes random Y offset from tallgrass/flowers/etc...
#define SEA_LEVEL 63 //Sea level for infinite oceans. Change this if you use custom worldgen. [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256]
#define SHADE_STRENGTH 0.35 //How dark surfaces that are facing away from the sun are [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50]
#define WATER_WAVE_STRENGTH 50 //Makes overworld oceans move up and down [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]
#define WAVING_GRASS //Adds wind effects to grass
//#define WAVING_LEAVES //Adds wind effects to leaves
#define WET_DIRT //Hydrated hummus. Soggy soil. Drenched dirt. I can't think of a good name for this config option, but it makes dirt darker during rain to simulate being wet.

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

const int noiseTextureResolution = 64;
const float invNoiseRes = 1.0 / float(noiseTextureResolution);

float lengthSquared2(vec2 v) { return dot(v, v); }

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

	float glmult = 0.0;
	if (night < 0.999) glmult += dot( sunPosNorm, normal) * (1.0 - night);
	if (night > 0.001) glmult += dot(-sunPosNorm, normal) * night;
	//glmult = glmult * 0.375 + 0.625; //0.25 - 1.0
	glmult = glmult * SHADE_STRENGTH + (1.0 - SHADE_STRENGTH);
	glmult = mix(glmult, 1.0, rainStrength * 0.5); //less shading during rain
	glmult = mix(1.0, glmult, lmcoord.y * 0.66666666 + 0.33333333); //0.5 - 1.0 in darkness
	glmult = mix(glmult, 1.0, lmcoord.x * lmcoord.x); //increase brightness when block light is high
	glcolor.rgb *= glmult;

	gl_Position = gl_ProjectionMatrix * (gbufferModelView * pos);
}