#version 120

//#define CUBIC_CHUNKS //Disables black fog/sky colors below Y=0

uniform float pixelSizeX;
uniform float pixelSizeY;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 cameraPosition;
uniform vec3 fogColor;
uniform vec3 skyColor;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
}

vec3 calcFogColor(vec3 pos) {
	#ifndef CUBIC_CHUNKS
		if (cameraPosition.y < -gbufferModelViewInverse[3][1]) return vec3(0.0);
	#endif

	return mix(skyColor, fogColor, fogify(max(dot(pos, gbufferModelView[1].xyz), 0.0), 0.0625));
}

void main() {

/* DRAWBUFFERS:0 */
	gl_FragData[0] = starData.a > 0.9 ? starData : vec4(calcFogColor(normalize((gbufferProjectionInverse * vec4(gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY) * 2.0 - 1.0, 1.0, 1.0)).xyz)), 1.0); //gcolor
}