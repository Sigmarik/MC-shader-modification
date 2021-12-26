#version 120

#define GRASS_AO //Adds ambient occlusion to tallgrass/flowers/etc... Works best with "Remove Y Offset" enabled.
#define LAVA_PATCHES //Randomizes lava brightness, similar to grass patches

uniform float frameTimeCounter;
uniform sampler2D noisetex;
uniform sampler2D texture;

varying float ao;
varying float isLava;
varying vec2 lmcoord;
varying vec2 randCoord;
varying vec2 texcoord;
varying vec4 glcolor;

const int noiseTextureResolution = 64;
const float invNoiseRes = 1.0 / float(noiseTextureResolution);

#ifdef LAVA_PATCHES
	float approxScaledCos(float x) { //x from 0 to 1, y from -0.5 to +0.5
		x = abs(fract(x) * 2.0 - 1.0);
		return x * x * (3.0 - 2.0 * x) - 0.5;
	}

	float noiseMap(vec2 coord) {
		coord *= invNoiseRes;
		float noise = 0.0;
		noise += texture2D(noisetex, coord * 0.03125).r;
		noise += texture2D(noisetex, coord * 0.09375).r * 0.5;
		noise += texture2D(noisetex, coord * 0.375  ).r * 0.25;
		return noise;
	}
#endif

void main() {
	vec4 color = texture2D(texture, texcoord);

	#ifdef GRASS_AO
		if (ao < 0.999) color.rgb *= sqrt(ao) * 0.5 + 0.5;
	#endif

	#ifdef LAVA_PATCHES
		if (isLava > 0.9) {
			color.rgb += approxScaledCos(noiseMap(randCoord) * 2.0 + frameTimeCounter * 0.0625) * 0.25;
		}
	#endif

	color *= glcolor;

/* DRAWBUFFERS:04 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(lmcoord, 1.0, 1.0); //gaux1
}