#version 120

#define RAINBOW_XP //Makes experience orbs have rainbow colors instead of just the standard yellow/green

uniform float frameTimeCounter;
uniform int entityId;
uniform sampler2D texture;
uniform vec4 entityColor;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

#ifdef RAINBOW_XP
	vec3 hue(float h) {
		h = fract(h) * 6.0;
		return clamp(
			vec3(
				abs(h - 3.0) - 1.0,
				2.0 - abs(h - 2.0),
				2.0 - abs(h - 4.0)
			),
			0.0,
			1.0
		);
	}
#endif

void main() {
	vec4 multiplier = glcolor;

	if (entityId == 2 && glcolor.g > min(glcolor.r, glcolor.b) + 0.1) {
		#ifdef RAINBOW_XP
			float variant = floor(texcoord.x * 4.0) + floor(texcoord.y * 4.0) * 4.0;
			multiplier = vec4(hue(frameTimeCounter * 0.5 + variant * 0.1), 1.0);
		#else
			multiplier.a = 1.0;
		#endif
	}

	vec4 color = texture2D(texture, texcoord) * multiplier;
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);

	if (color.a < 0.01) discard; //fix phantoms

/* DRAWBUFFERS:04 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(lmcoord, 1.0, color.a); //gaux1
}