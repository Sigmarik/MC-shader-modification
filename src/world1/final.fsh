#version 120

#include "/lib/defines.glsl"

uniform float pixelSizeY;
uniform float viewHeight;
uniform sampler2D composite; //output from previous stage
#define inputSampler composite

varying vec2 texcoord;

#include "/lib/math.glsl"

void main() {
	#include "/lib/verticalBlur.glsl"

	//gl_FragColor = color; //screen output
	gl_FragColor = vec3(0.0); //screen output
}