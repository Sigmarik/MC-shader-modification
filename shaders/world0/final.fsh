#version 120

#define BLUR_ENABLED //Is blur enabled at all?
#define BLUR_QUALITY 10 //Number of sample points to use for blurring. Higher quality = higher performance impact! [5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
#define BLOOM_ENABLED 1 //GuEsS wHaT ThIs OpTiOn Is DoInG. [1 0]
#define BLOOM_STRENGTH 1.0 //Bloom effect raw multiplier. [0.1 0.3 0.5 0.7 1.0 2.0 3.0 4.0 5.0 6.0]
#define BLOOM_QUALITY 20 //Number of samples algorithm will do. [3 5 10 15 20 25 30]
#define BLOOM_COMP_RADIUS 10 //Bloom computation tile size. [5 10 15 20]
#define BLOOM_SHAPE 1 //Defines what shape bloom rays will take. "Circle" option will make your PC explosive. [0 1 2]
#define BLOOM_DIVCONST 10 //Defines one thing in bloom equation. [1 3 5 10 15 20]
#define BLOOM_DISTMUL 10 //Defines another thing in bloom equation. [1 2 3 5 10 15 20]
#define BLOOM_COLOREXPCONST 0.1 //Defines one more thing in bloom equation. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]
#define BLOOM_COLOR_EXPONENT 4 //Defines semi-contrast of the bloom. [1 2 3 4 5 6]

uniform float pixelSizeY;
uniform float pixelSizeX;
uniform float viewHeight;
uniform sampler2D lightmap;
uniform sampler2D gaux4;
uniform sampler2D colortex5;
uniform sampler2D colortex8;
//const mat4 TEXTURE_MATRIX_2;
uniform sampler2D composite; //output from previous stage
uniform vec3 fogColor;

varying vec2 texcoord;
varying vec3 skyLightColor;
varying float skyBrightness;

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
}

void main() {
	vec4 color = texture2D(composite, texcoord);

	#ifdef BLUR_ENABLED
		float blurRadius = 1.0 - color.a;
		if (blurRadius > 0.0) {
			float invBlurRadius1 = 1.0 / blurRadius;
			blurRadius *= 256.0; //actual radius in pixels
			float invBlurRadius2 = 1.0 / blurRadius;

			vec4 average = vec4(0.0);
			float start  = max(texcoord.y - blurRadius * pixelSizeY,       pixelSizeY * 0.5);
			float finish = min(texcoord.y + blurRadius * pixelSizeY, 1.0 - pixelSizeY * 0.5);
			float step   = max(pixelSizeY * 0.5, blurRadius * pixelSizeY / float(BLUR_QUALITY));

			for (float y = start; y <= finish; y += step) {
				float weight = fogify(((texcoord.y - y) * viewHeight) * invBlurRadius2, 0.35);
				vec4 newColor = texture2D(composite, vec2(texcoord.x, y));
				weight *= (1.0 - newColor.a) * invBlurRadius1;
				average.rgb += newColor.rgb * newColor.rgb * weight;
				average.a += weight;
			}
			color.rgb = sqrt(average.rgb / average.a);
		}
	#endif

	vec4 raw_fog_data = texture2D(colortex8, texcoord);

	color = color + texture2D(gaux4, texcoord);

	color = color * (1 - clamp(raw_fog_data.w, 0.0, 1.0)) + vec4(fogColor, 1.0) * clamp(raw_fog_data.w, 0.0, 1.0);

	gl_FragColor = color;//color + texture2D(gaux4, texcoord);
}