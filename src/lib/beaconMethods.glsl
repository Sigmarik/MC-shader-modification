float distanceSq2(vec2 p1, vec2 p2) {
	return square(p2.x - p1.x) + square(p2.y - p1.y);
}

float calcBeaconWidth(float y) {
	float width = 4.0;
	width += sin(y * 2.0 - frameTimeCounter *  4.0) * sin(frameTimeCounter);
	width += sin(y * 8.0 + frameTimeCounter * 12.0) * sin(frameTimeCounter * 1.61803398875 /* golden ratio */) * 0.25;
	return width * 0.0625;
}

float hash12(vec2 p) { //thanks jodie!
	vec3 p3 = fract(p.xyx * 4.438975);
	p3 += dot(p3, p3.yzx + 19.19);
	return fract((p3.x + p3.y) * p3.z);
}

//calculating noise manually instead of using noisetex for better control over looping and for backwards compatibility with version of optifine which do not bind noisetex correctly in gbuffers_beaconbeam.
float random(vec2 coord, float repeat) {
	vec2 frac = fract(coord);
	vec4 floorCeil = vec4(coord - frac, 0.0, 0.0);
	floorCeil.zw = floorCeil.xy + 1.0;
	floorCeil.xz = mod(floorCeil.xz, repeat);

	vec4 corners = vec4(hash12(floorCeil.xy), hash12(floorCeil.xw), hash12(floorCeil.zy), hash12(floorCeil.zw));
	frac = interpolateSmooth2(frac);
	return mix(mix(corners.x, corners.z, frac.x), mix(corners.y, corners.w, frac.x), frac.y);
}