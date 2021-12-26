float approxScaledCos(float x) { //x from 0 to 1, y from -1 to 1
	x = abs(fract(x) * 2.0 - 1.0);
	return x * x * (6.0 - 4.0 * x) - 1.0;
	//x = fract(x);
	//if (x <= 0.5) return -16.0 * x * x + 8.0 * x;
	//else return 16.0 * x * x - 24.0 * x + 8.0;
}

vec3 random(vec2 coord) {
	return texture2D(noisetex, coord * invNoiseRes).rgb;
}

vec2 primitiveNoise2D(vec2 coord, vec2 scaler) {
	vec3 noise = random(coord);
	noise.xy = noise.xy * 2.0 + frameTimeCounter * scaler;
	return noise.z * vec2(approxScaledCos(noise.x), approxScaledCos(noise.y));
}

vec2 noise2DLOD(vec2 coord, float distance) {
	float lod = log2(distance * 0.0625); //level of detail
	float scale = exp2(floor(lod)); //each time the distance doubles, so will the scale factor
	coord /= scale;
	float middle = mod(lod, 2.0); //where we are between 2 scales
	bool evenOrOdd = middle >= 1.0;
	vec2 speeds = vec2(0.8, 1.3);
	if (evenOrOdd) {
		middle -= 1.0;
		speeds = speeds.yx;
	}
	vec2 noise1 = primitiveNoise2D(coord      , speeds   ) / (middle * -50.0 + 100.0);
	vec2 noise2 = primitiveNoise2D(coord / 2.0, speeds.yx) / (middle *  50.0 + 50.0);

	return mix(noise1, noise2, middle);
}