vec4 drawVoidClouds(vec2 pos) {
	vec2 cloudPos = pos * invNoiseRes;
	float time = frameTimeCounter * invNoiseRes * 2.0;

	float noise = -1.0;
	noise += texture2D(noisetex, (cloudPos + goldenOffset0 * time) * 0.00390625).r;
	noise += texture2D(noisetex, (cloudPos + goldenOffset1 * time) * 0.0078125 ).r * 0.6;
	noise += texture2D(noisetex, (cloudPos + goldenOffset2 * time) * 0.015625  ).r * 0.36;
	noise += texture2D(noisetex, (cloudPos + goldenOffset3 * time) * 0.03125   ).r * 0.216;
	noise += texture2D(noisetex, (cloudPos + goldenOffset4 * time) * 0.0625    ).r * 0.1296;
	noise += texture2D(noisetex, (cloudPos + goldenOffset5 * time) * 0.125     ).r * 0.07776;
	noise += texture2D(noisetex, (cloudPos + goldenOffset6 * time) * 0.25      ).r * 0.046656;
	noise += texture2D(noisetex, (cloudPos + goldenOffset7 * time) * 0.5       ).r * 0.0279936;

	if (noise > 0.0) { //there are indeed clouds here
		vec3 color = vec3(noise * 0.125); //base cloud color

		vec3 data = texture2D(noisetex, (floor((pos + vec2(frameTimeCounter, 0.0)) * 2.0) + 0.5) * invNoiseRes).rgb; //r = hue, gb = another random offset
		float amt = texture2D(noisetex, data.gb * time * 0.125).r; //base brightness of square
		amt = max(amt * 8.0 - 8.0 + square(noise * 1.375), 0.0); //add bias so that there are more squares where cloud density is high
		color += hue(data.r * 0.35 + 0.45) * amt; //color of square

		return vec4(color, interpolateSmooth1(min(noise * 1.5, 1.0)));
	}
	else return vec4(0.0);
}