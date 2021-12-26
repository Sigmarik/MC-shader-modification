blockLightColor = mix(vec3(1.0, 0.5, 0.15), vec3(1.0, 0.85, 0.7), eyeBrightnessSmooth.x / 240.0);
#if HARDCORE_DARKNESS == 0
	skyLightColor = day > 0.001 ? vec3(1.0) : vec3(0.04, 0.08, 0.12);
#elif HARDCORE_DARKNESS == 1
	skyLightColor = day > 0.001 ? vec3(1.0) : vec3(0.0);
#else
	skyLightColor = day > 0.001 ? vec3(1.0) : vec3(0.04, 0.08, 0.12) * phase;
#endif
shadowColor = mix(skyColor, fogColor, rainStrength);

if (sunset > 0.01) {
	vec4 sunsetColor = vec4(clamp(vec3(SUNSET_COEFFICIENT_RED + 0.2, SUNSET_COEFFICIENT_GREEN + 0.2, SUNSET_COEFFICIENT_BLUE + 0.2) - adjustedTime, 0.0, 1.0), sunset); //color of sunset gradient at the horizon, and mix level
	if (rainStrength > 0.001) sunsetColor.rgb = mix(sunsetColor.rgb, fogColor * (1.0 - rainStrength * 0.5), rainStrength * 0.625); //reduce redness intensity when raining
	skyLightColor  = mix(skyLightColor, sunsetColor.rgb, sunsetColor.a);
	shadowColor    = mix(shadowColor,   sunsetColor.rgb, sunsetColor.a);
}