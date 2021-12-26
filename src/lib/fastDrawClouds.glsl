//returns color and opacity of clouds
vec4 drawClouds(vec2 pos) {
	float time = frameTimeCounter * invNoiseRes;
	pos.x += time; //apply wind
	pos *= invNoiseRes * 4.0;
	time *= 0.015625;

	float noise = 0.0;
	noise += (texture2D(noisetex, (pos + time * goldenOffset0)        ).r - 0.5) * 2.0;
	noise += (texture2D(noisetex, (pos + time * goldenOffset1) * 2.0  ).r - 0.5);
	noise += (texture2D(noisetex, (pos + time * goldenOffset2) * 4.0  ).r - 0.5) * 0.5;
	noise += (texture2D(noisetex, (pos + time * goldenOffset3) * 8.0  ).r - 0.5) * 0.25;
	noise += (texture2D(noisetex, (pos + time * goldenOffset4) * 16.0 ).r - 0.5) * 0.125;
	noise += (texture2D(noisetex, (pos + time * goldenOffset5) * 32.0 ).r - 0.5) * 0.0625;
	noise += (texture2D(noisetex, (pos + time * goldenOffset6) * 64.0 ).r - 0.5) * 0.03125;
	noise += (texture2D(noisetex, (pos + time * goldenOffset7) * 128.0).r - 0.5) * 0.015625;

	if (noise > 0.0) { //there are clouds here
		return vec4(mix(vec3(1.0, 1.0, 1.0), vec3(0.48, 0.5, 0.55), fogify(noise, 0.25)), 1.0 - fogify(noise, 0.0625));
	}
	return vec4(0.0);
}