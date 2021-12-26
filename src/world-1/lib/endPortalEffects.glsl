vec3 correctedPos = worldPos - gbufferModelViewInverse[3].xyz;
vec2 backgroundPos = correctedPos.xz / correctedPos.y;

#if END_PORTAL_BACKGROUND_NETHER == 1 //overworld fog color
	color = vec4(0.75, 0.875, 1.0, 1.0);
#elif END_PORTAL_BACKGROUND_NETHER == 2 //end background
	//draw background noise, matching vanilla end sky texture as closely as possible
	float n = texture2D(noisetex, (floor(backgroundPos * 256.0) + 0.5) * invNoiseRes).r * 2.0 - 1.0; //get random noise value between -1.0 and 1.0
	float n4 = square(square(n)); //bias towards 0 by raising to the 4'th power. also always positive because 4 is even, so don't need to take absolute value.
	color.rgb = vec3(0.46, 0.34, 0.65); //base color
	if (n > 0.0) color.rgb = mix(color.rgb, vec3(1.0), n4 * 0.55); //bright areas
	else         color.rgb = mix(color.rgb, vec3(0.0), n4 * 0.7); //dark areas
	color.rgb *= 0.16; //match vanilla brightness (40/255 ~= 0.16)
	
	vec3 worldPosNorm = normalize(correctedPos);
	vec2 endProjectionPos = worldPosNorm.xz / (worldPosNorm.y + 1.0);
	float multiplier = 8.0 / (lengthSquared2(endProjectionPos) + 8.0); //wrapping behavior produces a mathematical singularity below you, so this hides that.

	#ifdef ENDER_NEBULAE
		vec4 cloudclr = drawNebulae(endProjectionPos);
		color.rgb = mix(color.rgb, cloudclr.rgb, cloudclr.a * multiplier);
	#endif

	#ifdef ENDER_STARS
		vec3 starclr = drawStars(endProjectionPos);
		color.rgb += starclr * multiplier;
	#endif
#endif

#if END_PORTAL_FOREGROUND_NETHER == 1 //overworld screenshot
	vec4 islandImage = texture2D(gaux1, backgroundPos * 0.25 + 0.5);
	color.rgb = mix(color.rgb, islandImage.rgb, islandImage.a);
#elif END_PORTAL_FOREGROUND_NETHER == 2 //end screenshot
	vec4 islandImage = texture2D(gaux2, backgroundPos + 0.5);
	color.rgb = mix(color.rgb, islandImage.rgb, islandImage.a);
#endif

#if END_PORTAL_CLOUDS_NETHER == 1 //overworld clouds
	vec2 projectedPos = (worldPos.xz / (worldPos.y - gbufferModelViewInverse[3][1])) * 0.25 + 0.5;
	vec4 cloudColor = drawClouds(projectedPos);
	color.rgb = mix(color.rgb, cloudColor.rgb, cloudColor.a);
#elif END_PORTAL_CLOUDS_NETHER == 2 //void clouds
	vec4 cloudColor = drawVoidClouds(backgroundPos * 64.0);
	color.rgb = mix(color.rgb, cloudColor.rgb, cloudColor.a);
#endif

#ifdef BRIGHT_PORTAL_FIX
	color.rgb *= 0.0625;
#endif