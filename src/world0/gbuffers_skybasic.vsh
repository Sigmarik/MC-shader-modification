#version 120

#include "/lib/defines.glsl"

uniform int worldTime;
uniform mat4 gbufferModelView;

#ifdef SUN_POSITION_FIX
	varying vec3 sunPosNorm;
#endif

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

#ifdef SUN_POSITION_FIX
	const float sunPathRotation = 30.0; //Angle that the sun/moon rotate at [-45.0 -40.0 -35.0 -30.0 -25.0 -20.0 -15.0 -10.0 -5.0 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0]
	const vec2 sunRotationData = vec2(cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994)); //Used for manually calculating the sun's position, since the sunPosition uniform is inaccurate in the skybasic stage.
#endif

void main() {
	gl_Position = ftransform();

	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));

	#ifdef SUN_POSITION_FIX
		//minecraft's native calculateCelestialAngle() function, ported to GLSL.
		float ang = fract(worldTime / 24000.0 - 0.25);
		ang = (ang + (cos(ang * 3.14159265358979) * -0.5 + 0.5 - ang) / 3.0) * 6.28318530717959; //0-2pi, rolls over from 2pi to 0 at noon.

		sunPosNorm = normalize((gbufferModelView * vec4(sin(ang) * -100.0, (cos(ang) * 100.0) * sunRotationData, 1.0)).xyz);
	#endif
}