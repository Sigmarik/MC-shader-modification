#version 120

#include "/lib/defines.glsl"

uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float rainStrength;
uniform float wetness;
uniform sampler2D depthtex0;
uniform sampler2D texture;
uniform vec3 fogColor;

#ifdef CLOUDS
	varying float worldHeight;
#endif
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	#ifdef CLOUDS
		if (worldHeight > CLOUD_HEIGHT) discard; //don't draw rain above clouds.
	#endif

	vec4 color = texture2D(texture, texcoord) * glcolor;

	if (texture2D(depthtex0, gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY)).r == 1.0) {
		color.rgb = fogColor * (1.0 - max(rainStrength, wetness) * 0.5);
	}
	color.a *= 2.0 - color.a;
	
/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}