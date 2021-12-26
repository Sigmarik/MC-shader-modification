#version 120

#define DYNAMIC_LIGHTS //Holding blocks that emit light will light up their surroundings
#define IDLE_HANDS //Makes your hands sway back and forth in 1st person, like they do in 3rd person

uniform float far;
uniform float frameTimeCounter;
uniform int heldBlockLightValue;
uniform int heldItemId;
uniform int heldItemId2;
uniform mat4 gbufferProjection;
uniform sampler2D noisetex;

#ifdef DYNAMIC_LIGHTS
	varying float heldLightDistModifier; //Zoom in with optifine to increase range of held lights.
#endif
varying float id; //ID data of block currently being rendered.
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 normal;
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

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

	#ifdef IDLE_HANDS
		vec4 pos = gl_ModelViewMatrix * gl_Vertex;
		if (heldItemId != 359 && heldItemId2 != 359) { //no hand sway when holding a map.
			pos.xy += sin(frameTimeCounter * vec2(1.6, 1.2)) * (sign(gl_ModelViewMatrix[3][0] + 0.3125) * 0.015625);
		}
		gl_Position = gl_ProjectionMatrix * pos;
	#else
		gl_Position = ftransform();
	#endif

	glcolor = gl_Color;
	#ifdef DYNAMIC_LIGHTS
		heldLightColor = calcHeldLightColor(float(heldBlockLightValue),  heldItemId);
		heldLightDistModifier = far / sqrt(gbufferProjection[1][1]); //held lights get more powerful when zooming in, akin to holding the light out in front of you and pointing it at something.
	#else
		heldLightColor = vec4(0.0);
	#endif

	int heldItem = gl_ModelViewMatrix[3][0] > -0.3125 ? heldItemId : heldItemId2;
	if (heldItem == 95 || heldItem == 160) id = 0.2; //stained glass
	else if (heldItem == 79) id = 0.4; //ice
	else id = 0.0;

	//note: gl_Normal is NOT normalized for the hand in world0.
	//it's probably broken here too.
	normal = normalize(gl_Normal) * 0.5 + 0.5;
}