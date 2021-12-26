vec3 calcMainLightColor(inout float blocklight, inout float heldlight, in float dist) {
	#ifdef VANILLA_LIGHTMAP
		vec3 lightclr = texture2D(lightmap, vec2(blocklight, 0.96875)).rgb; //31/32 is the maximum light level in vanilla
	#endif

	blocklight *= blocklight;

	#ifndef VANILLA_LIGHTMAP
		vec3 lightclr = vec3(0.0);
		lightclr += blockLightColor * blocklight; //blocklight
		lightclr += vec3(AMBIENT_LIGHT_COLOR_END_RED, AMBIENT_LIGHT_COLOR_END_GREEN, AMBIENT_LIGHT_COLOR_END_BLUE); //skylight
		lightclr += clamp(nightVision, 0.0, 1.0) * 0.5 + clamp(screenBrightness, 0.0, 1.0) * 0.1;
	#endif

	#ifdef DYNAMIC_LIGHTS
		float d = dist * heldLightDistModifier;
		if (d < heldLightColor.a * 2.0) {
			heldlight = heldLightColor.a / square(d + 2.0) * 0.75 * (heldLightColor.a * 2.0 - d) / (blocklight * 32.0 + heldLightColor.a);
			#ifdef VIGNETTE
				heldlight *= (1.0 - length(gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY) - 0.5)); //helps reduce the "circle that follows you" effect by making held lights darker towards the edge of your screen
			#endif
			lightclr += heldLightColor.rgb * heldlight;
		}
	#endif

	return lightclr;
}