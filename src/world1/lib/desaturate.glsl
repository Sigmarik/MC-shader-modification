#ifdef DESATURATE
	float desatAmt = max(blocklight, heldlight);
	if (desatAmt < 0.999) {
		vec3 average = vec3((color.r + color.g * 2.0 + color.b) * 0.25);
		color.rgb = mix(average, color.rgb, desatAmt * 0.375 + 0.625);
	}
#endif