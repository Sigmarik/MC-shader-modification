#version 120

#include "/lib/defines.glsl"

uniform float frameTimeCounter;
uniform int entityId;
uniform sampler2D texture;
uniform vec4 entityColor;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

#ifdef RAINBOW_XP
	#include "/lib/hue.glsl"
#endif

void main() {
	vec4 multiplier = glcolor;

	#include "/lib/rainbowXP.glsl"

	vec4 color = texture2D(texture, texcoord) * multiplier;
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);

	if (color.a < 0.01) discard; //fix phantoms

/* DRAWBUFFERS:04 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(lmcoord, 1.0, color.a);
}