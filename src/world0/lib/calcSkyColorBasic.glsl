vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, upPosNorm) * 2.0; //not much, what's up with you?
	bool top = upDot > 0.0;
	float sunDot = dot(pos, sunPosNorm) * 0.5 + 0.5;
	float rainCoefficient = max(rainStrength, wetness);
	vec3 color;
	vec3 skyclr = mix(skyColor, fogColor * 0.65, rainCoefficient);
	vec3 fogclr = fogColor * (1.0 - rainCoefficient * 0.5);

	if (top) {
		color = skyclr + NIGHT_SKY_COLOR * (1.0 - day) * (1.0 - rainStrength); //avoid pitch black sky at night
		if (day > 0.001) color = mix(color, SUN_GLOW_COLOR,  0.75 / ((1.0 - sunDot) * 16.0 + 1.0) * day   * (1.0 - rainStrength * 0.75)); //make the sun illuminate the sky around it
		else             color = mix(color, MOON_GLOW_COLOR, 0.75 / (       sunDot  * 16.0 + 1.0) * night * (1.0 - rainStrength       ) * phase); //make the moon illuminate the sky around it
	}
	else color = fogclr;

	if (sunset > 0.001 && rainCoefficient < 0.999) {
		vec3 sunsetColor = interpolateSmooth3(clamp(vec3(SUNSET_COEFFICIENT_RED, SUNSET_COEFFICIENT_GREEN, SUNSET_COEFFICIENT_BLUE) - adjustedTime + upDot + sunDot * 0.2 * (1.0 - night), 0.0, 1.0)); //main sunset gradient
		sunsetColor = mix(fogclr, sunsetColor, (sunDot * 0.5 + 0.5) * sunset * (1.0 - rainCoefficient)); //fade in at sunset and out when not looking at the sun
		color = mix(color, sunsetColor, fogify(upDot, 0.25)); //mix with final color based on how close we are to the horizon
	}
	else if (top) color = mix(color, fogclr, fogify(upDot, 0.25));

	return color;
}