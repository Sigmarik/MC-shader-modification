#version 120

#define CLOUDS //3D clouds (partially volumetric too). Mild performance impact!
#define WAVING_RAIN //Makes rain not directly vertical by applying "wind" to it.

uniform float frameTimeCounter;
uniform sampler2D noisetex;
uniform vec3 cameraPosition;

#ifdef CLOUDS
	varying float worldHeight;
#endif
varying vec2 texcoord;
varying vec4 glcolor;

const int noiseTextureResolution = 64;
const float invNoiseRes = 1.0 / float(noiseTextureResolution);

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	vec4 pos = gl_Vertex;

	#ifdef WAVING_RAIN
		vec2 offset = texture2D(noisetex, vec2(0.39162, 0.42636) * frameTimeCounter * invNoiseRes).rg * 4.0 - 2.0;
		offset += texture2D(noisetex, vec2(pos.x + cameraPosition.x + frameTimeCounter * 8.0, pos.z + cameraPosition.z) * 0.5 * invNoiseRes).rg - 0.25;

		pos.xz += pos.y > 1.0 ? offset : offset * 0.25;
	#endif

	#ifdef CLOUDS
		worldHeight = pos.y + cameraPosition.y;
	#endif

	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * pos);
	glcolor = gl_Color;
}