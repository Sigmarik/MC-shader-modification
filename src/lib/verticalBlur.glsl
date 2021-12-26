vec4 color = texture2D(inputSampler, texcoord);

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
			vec4 newColor = texture2D(inputSampler, vec2(texcoord.x, y));
			weight *= (1.0 - newColor.a) * invBlurRadius1;
			average.rgb += newColor.rgb * newColor.rgb * weight;
			average.a += weight;
		}
		color.rgb = sqrt(average.rgb / average.a);
	}
#endif