vec3 calcUnderwaterFogColor(vec3 color, float dist, float brightness) {
	dist *= far;

	vec3 absorb = exp2(-dist * mix(vec3(WATER_ABSORB_R, WATER_ABSORB_G, WATER_ABSORB_B), vec3(0.375, 0.3125, 0.25), rainStrength));
	vec3 scatter = mix(vec3(WATER_SCATTER_R, WATER_SCATTER_G, WATER_SCATTER_B), vec3(0.0625), rainStrength) * (1.0 - absorb) * (brightness * day);
	return color * absorb + scatter;
}

vec3 calcUnderwaterFogColorInfinity(float brightness) {
	//simpler algorithm for the special case where distance = infinity (for infinite oceans)
	return mix(vec3(WATER_SCATTER_R, WATER_SCATTER_G, WATER_SCATTER_B), vec3(0.0625), rainStrength) * (brightness * day);
}