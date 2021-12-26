if (isEyeInWater == 2) { //under lava
	vec2 coord = floor(vec2(texcoord.x, texcoord.y / aspectRatio) * 24.0 + vec2(0.0, frameTimeCounter)) + 0.5; //24.0 is the resolution of the generated lava texture.
	float noise = 0.0;
	noise += (texture2D(noisetex, (coord * 0.25 + vec2(0.0, frameTimeCounter)) * invNoiseRes).r - 0.5);
	noise += (texture2D(noisetex, (coord * 0.5  + vec2(0.0, frameTimeCounter)) * invNoiseRes).r - 0.5) * 0.5;
	noise += (texture2D(noisetex, (coord        + vec2(0.0, frameTimeCounter)) * invNoiseRes).r - 0.5) * 0.25;
	vec3 color = vec3(1.0, 0.5, 0.0) + noise * vec3(0.375, 0.5, 0.5);
	gl_FragData[0] = vec4(color, 1.0);
	return; //don't need to calculate anything else since the lava overlay covers the entire screen.
}