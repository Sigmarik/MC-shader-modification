#ifdef DESATURATE
	if (night > 0.01 || rainStrength > 0.01) {
		float lightModifier = skylight - max(blocklight, heldlight) * 0.5;
		if (lightModifier > 0.001) {
			vec3 average = vec3((color.r + color.g * 2.0 + color.b) * 0.25);
			color.rgb = mix(color.rgb, average, (rainStrength + night) * lightModifier * min(float(240 - eyeBrightnessSmooth.x), float(eyeBrightnessSmooth.y)) / 960.0);
		}
	}
#endif