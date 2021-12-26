#version 120

#define DYNAMIC_LIGHTS //Holding blocks that emit light will light up their surroundings
#define WATER_WAVE_STRENGTH 50 //Makes overworld oceans move up and down [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]

attribute vec3 mc_Entity;

uniform float far;
uniform float frameTimeCounter;
uniform int heldBlockLightValue;
uniform int heldItemId;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying float mcentity; //ID data of block currently being rendered.
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 normal;
varying vec3 pos;
varying vec4 glcolor;
varying vec4 heldLightColor; //Color of held light source. Alpha = brightness.

const int noiseTextureResolution = 64;
const float invNoiseRes = 1.0 / float(noiseTextureResolution);

#ifdef DYNAMIC_LIGHTS
	float flicker() {
		float n = texture2D(noisetex, frameTimeCounter * vec2(16.7825, 15.4192) * invNoiseRes).r - 0.5;
		return n * n * n * 12.0;
	}

	vec4 calcHeldLightColor(float light, int id) { //rgb = color, a = brightness
		if   (light == 0.0) return vec4(0.0); //not holding a light source
		else if (id == 50 ) return vec4(1.0,  0.6,  0.3, light + flicker()); //torches
		else if (id == 89 ) return vec4(1.0,  0.6,  0.1, light            ); //glowstone
		else if (id == 169) return vec4(0.6,  0.8,  0.6, light            ); //sea lanterns
		else if (id == 198) return vec4(0.75, 0.55, 0.8, light            ); //end rods
		else if (id == 76 ) return vec4(1.0,  0.3,  0.1, light + flicker()); //redstone torches
		else if (id == 91 ) return vec4(1.0,  0.6,  0.3, light + flicker()); //jack-o-lanterns
		else if (id == 138) return vec4(0.4,  0.6,  0.8, light            ); //beacons
		else                return vec4(0.8,  0.65, 0.5, light            ); //everything else
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
	pos      = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor  =  gl_Color;
	mcentity = 0.1;

	//Using IDs above 10000 to represent all blocks that I care about
	//if the ID is less than 10000, then I don't need to do extra logic to see if it has special effects.
	if (mc_Entity.x > 10000.0) {
		int id = int(mc_Entity.x) - 10000;
		if (id == 9) {  //water
			mcentity = 1.1;
			#if WATER_WAVE_STRENGTH != 0
				vec3 worldPos = pos + cameraPosition;
				if (worldPos.y <= 31.01 && worldPos.y >= 30.01) {
					pos.y -= waterWave(worldPos.xz + 0.5) * fract(worldPos.y - 0.01); // + 0.5 to avoid sharp edges in lava displacement when the coords are on the edge of a noisetex pixel
				}
			#endif
		}
		else if (id == 10) mcentity = 2.1; //stained glass
		else if (id == 11) mcentity = 3.1; //ice
	}

	#ifdef DYNAMIC_LIGHTS
		heldLightColor = calcHeldLightColor(float(heldBlockLightValue),  heldItemId);
		heldLightDistModifier = far / sqrt(gbufferProjection[1][1]); //held lights get more powerful when zooming in, akin to holding the light out in front of you and pointing it at something.
	#else
		heldLightColor = vec4(0.0);
	#endif

	normal = gl_Normal * 0.5 + 0.5;

	pos = (gbufferModelView * vec4(pos, 1.0)).xyz;
	gl_Position = gl_ProjectionMatrix * vec4(pos, 1.0);
}