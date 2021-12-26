#ifdef FOG_ENABLED_NETHER
	vec3 calcFogColor(vec3 pos) {
		float n = square(texture2D(noisetex, frameTimeCounter * vec2(0.21562, 0.19361) * invNoiseRes).r) - 0.1;
		if (n > 0.0) {
			vec3 brightFog = vec3(fogColor.r * (n + 1.0), mix(fogColor.g, fogColor.r, n), fogColor.b);
			return mix(fogColor, brightFog, fogify(pos.y, 0.125));
		}
		else {
			return fogColor;
		}
	}
#endif