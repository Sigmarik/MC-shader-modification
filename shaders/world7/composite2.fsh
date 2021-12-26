#version 120

#define BLUR_ENABLED //Is blur enabled at all?
#define BLUR_QUALITY 10 //Number of sample points to use for blurring. Higher quality = higher performance impact! [5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]

uniform float pixelSizeX;
uniform float viewWidth;
uniform sampler2D gaux3; //output from previous stage

varying vec2 texcoord;

float fogify(float x, float width) {
	//fast, vaguely bell curve-shaped function with variable width
	return width / (x * x + width);
}

void main() {
	vec4 color = texture2D(gaux3, texcoord);

	#ifdef BLUR_ENABLED
		float blurRadius = 1.0 - color.a;
		if (blurRadius > 0.0) {
			float invBlurRadius1 = 1.0 / blurRadius;
			blurRadius *= 256.0; //actual radius in pixels
			float invBlurRadius2 = 1.0 / blurRadius;

			vec4 average = vec4(0.0);
			float start  = max(texcoord.x - blurRadius * pixelSizeX,       pixelSizeX * 0.5);
			float finish = min(texcoord.x + blurRadius * pixelSizeX, 1.0 - pixelSizeX * 0.5);
			float step   = max(pixelSizeX * 0.5, blurRadius * pixelSizeX / float(BLUR_QUALITY));

			for (float x = start; x <= finish; x += step) {
				float weight = fogify(((texcoord.x - x) * viewWidth) * invBlurRadius2, 0.35);
				vec4 newColor = texture2D(gaux3, vec2(x, texcoord.y));
				weight *= (1.0 - newColor.a) * invBlurRadius1;
				average.rgb += newColor.rgb * newColor.rgb * weight;
				average.a += weight;
			}
			color.rgb = sqrt(average.rgb / average.a);
		}
	#endif

/* DRAWBUFFERS:3 */
	gl_FragData[0] = color; //gcolor
}