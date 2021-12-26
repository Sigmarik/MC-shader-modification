#ifdef CROSS_PROCESS
	vec3 ambientCrossColor = vec3(1.3, 1.0, 0.8);
	vec3 blockCrossColor = mix(vec3(1.3, 1.4, 1.0), vec3(1.2, 1.1, 1.0), eyeBrightnessSmooth.x / 240.0);
	vec3 finalCrossColor = mix(ambientCrossColor, blockCrossColor, lmcoord.x);
	color.rgb = clamp(color.rgb * finalCrossColor - vec3(color.g + color.b, color.r + color.b, color.r + color.g) * 0.1, 0.0, 1.0);
#endif