if (entityId == 2 && glcolor.g > min(glcolor.r, glcolor.b) + 0.1) {
	#ifdef RAINBOW_XP
		float variant = floor(texcoord.x * 4.0) + floor(texcoord.y * 4.0) * 4.0;
		multiplier = vec4(hue(frameTimeCounter * 0.5 + variant * 0.1), 1.0);
	#else
		multiplier.a = 1.0;
	#endif
}