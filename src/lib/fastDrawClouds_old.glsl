float cloudNoise(vec2 coord, float size) {
	coord /= size;
	vec4 corners = (vec4(floor(coord), ceil(coord)) + 0.5) * invNoiseRes;

	float r00 = texture2D(noisetex, corners.xy).r; //random value at the (0, 0) corner
	float r01 = texture2D(noisetex, corners.xw).r; //random value at the (0, 1) corner
	float r10 = texture2D(noisetex, corners.zy).r; //random value at the (1, 0) corner
	float r11 = texture2D(noisetex, corners.zw).r; //random value at the (1, 1) corner

	vec2 mixlvl = interpolateSmooth2(fract(coord));

	return mix(mix(r00, r10, mixlvl.x), mix(r01, r11, mixlvl.x), mixlvl.y) * 2.0 - 1.0; //non-linear interpolation between the 4 corners
}

vec4 drawClouds(vec2 pos) {
	pos *= 128.0;
	pos.x += frameTimeCounter; //apply wind

	float noise = 0.0;
	noise += cloudNoise(pos, 64.0) * 1.5;
	noise += cloudNoise(pos, 12.0);

	pos *= invNoiseRes;
	float colorNoise = 0.0;
	colorNoise += texture2D(noisetex, pos * 0.25).r - 0.5;
	colorNoise += texture2D(noisetex, pos       ).r * 0.5 - 0.25;
	colorNoise *= noise;

	if (noise > 0.0) { //there are clouds here
		return vec4(mix(vec3(1.0, 1.0, 1.0), vec3(0.48, 0.5, 0.55), fogify(noise - colorNoise, 0.25)), 1.0 - fogify(noise, 0.0625));
	}
	return vec4(0.0);
}