vec3 calcSkyColor(vec3 pos) {
	#ifndef CUBIC_CHUNKS
		if (cameraPosition.y < -gbufferModelViewInverse[3][1]) return vec3(0.0);
	#endif
	float space = square(max(cameraPosition.y, 256.0) / 256.0 + 1.0);
	float upDot = dot(pos, upPosNorm) * space * 0.5; //not much, what's up with you?
	space = 4.0 / space;
	bool top = upDot > 0.0;
	float sunDot = dot(pos, sunPosNorm) * 0.5 + 0.5;
	float rainCoefficient = max(rainStrength, wetness);
	vec3 color;
	vec3 skyclr = mix(skyColor, fogColor * 0.65, rainCoefficient) * space;
	vec3 fogclr = fogColor * (1.0 - rainCoefficient * 0.5);

	#ifdef RAINBOWS
		float rainbowStrength = (wetness - rainStrength) * day * 0.25;
		float rainbowHue = (sunDot - 0.25) * -24.0;
		if (rainbowStrength > 0.0 && rainbowHue > 0.0 && rainbowHue < 1.0) {
			rainbowHue *= 6.0;
			vec3 rainbowColor = clamp(vec3(1.5, 2.0, 1.5) - abs(rainbowHue - vec3(1.5, 3.0, 4.5)), 0.0, 1.0) * rainbowStrength;
			skyclr += rainbowColor * space * space;
			fogclr += rainbowColor;
		}
	#endif

	if (top) {
		color = skyclr + NIGHT_SKY_COLOR * (1.0 - day) * (1.0 - rainStrength) * space; //avoid pitch black sky at night
		if (day > 0.001) color = mix(color, SUN_GLOW_COLOR,  0.75 / ((1.0 - sunDot) * 16.0 + 1.0) * day   * (1.0 - rainStrength * 0.75) * space); //make the sun illuminate the sky around it
		else             color = mix(color, MOON_GLOW_COLOR, 0.75 / (       sunDot  * 16.0 + 1.0) * night * (1.0 - rainStrength       ) * space * phase); //make the moon illuminate the sky around it
	}
	else color = fogclr;

	if (sunset > 0.001 && rainCoefficient < 0.999) {
		vec3 sunsetColor = interpolateSmooth3(clamp(vec3(SUNSET_COEFFICIENT_RED, SUNSET_COEFFICIENT_GREEN, SUNSET_COEFFICIENT_BLUE) - adjustedTime + upDot + sunDot * 0.2 * (1.0 - night), 0.0, 1.0)); //main sunset gradient
		sunsetColor = mix(fogclr, sunsetColor, (sunDot * 0.5 + 0.5) * sunset * (1.0 - rainCoefficient)); //fade in at sunset and out when not looking at the sun
		color = mix(color, sunsetColor, fogify(upDot, 0.25)); //mix with final color based on how close we are to the horizon
	}
	else if (top) color = mix(color, fogclr, fogify(upDot, 0.25));

	#if defined(FANCY_STARS) || defined(GALAXIES)
		color += drawStars(pos, space);
	#endif

	color += texture2D(noisetex, gl_FragCoord.xy * invNoiseRes).rgb * 0.00390625; //dither

	return color;
}