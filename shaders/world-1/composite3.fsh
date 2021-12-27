#version 120

#define BLUR_ENABLED //Is blur enabled at all?
#define BLUR_QUALITY 10 //Number of sample points to use for blurring. Higher quality = higher performance impact! [5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]

uniform float pixelSizeX;
uniform float viewWidth;
uniform sampler2D gaux2; //output from previous stage
uniform sampler2D gaux1;
uniform sampler2D gcolor;

varying vec2 texcoord;

void main() {
	vec4 color = max(texture2D(gaux2, texcoord), texture2D(gaux1, texcoord));
/* DRAWBUFFERS:7 */
	gl_FragData[0] = color; //gaux4
}