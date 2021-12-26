#version 120

#define BLUR_ENABLED //Is blur enabled at all?
#define BLUR_QUALITY 10 //Number of sample points to use for blurring. Higher quality = higher performance impact! [5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]

uniform float pixelSizeY;
uniform float viewHeight;
uniform sampler2D composite; //output from previous stage

varying vec2 texcoord;

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

	gl_FragColor = color; //screen output
}