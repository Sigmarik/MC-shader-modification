vec3 calcUnderwaterFogColor(vec3 color, float dist, float brightness) {
	dist *= far; //use absolute distance, not relative distance

	vec3 absorb = exp2(-dist * vec3(WATER_ABSORB_R, WATER_ABSORB_G, WATER_ABSORB_B));
	vec3 scatter = vec3(WATER_SCATTER_R, WATER_SCATTER_G, WATER_SCATTER_B) * (1.0 - absorb) * brightness;
	return color * absorb + scatter;
}

vec3 calcUnderwaterFogColorInfinity(float brightness) {
	//simpler algorithm for the special case where distance = infinity (for looking at unobstructed sky while underwater)
	return vec3(WATER_SCATTER_R, WATER_SCATTER_G, WATER_SCATTER_B) * brightness;
}