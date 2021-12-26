#ifdef CROSS_PROCESS
	const vec3 MOON_GLOW_COLOR = vec3(0.075, 0.1,   0.2 ); //Mixed with sky color based on distance from moon
	const vec3 NIGHT_SKY_COLOR = vec3(0.02,  0.025, 0.05); //Added to sky color at night to avoid it being completely black
	const vec3 SUN_GLOW_COLOR  = vec3(1.0,   1.0,   1.0 ); //Mixed with sky color based on distance from sun
#else
	const vec3 MOON_GLOW_COLOR = vec3(0.1,   0.1,   0.2 ); //Mixed with sky color based on distance from moon
	const vec3 NIGHT_SKY_COLOR = vec3(0.025, 0.025, 0.05); //Added to sky color at night to avoid it being completely black
	const vec3 SUN_GLOW_COLOR  = vec3(0.8,   0.9,   1.0 ); //Mixed with sky color based on distance from sun
#endif