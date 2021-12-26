#if defined(FANCY_STARS) || defined(GALAXIES)
	//uses additive blending, so no alpha returned.
	vec3 drawStars(vec3 pos, float space) {
		#ifndef CUBIC_CHUNKS
			if (cameraPosition.y < -gbufferModelViewInverse[3][1]) return vec3(0.0);
		#endif
		float upDot = dot(pos, upPosNorm);

		if (upDot > 0.0 && (night > 0.001 || space < 0.999) && rainStrength * space < 0.999) {
			vec2 dailyOffset = texture2D(noisetex, (floor(vec2(worldDay, worldDay * invNoiseRes)) + 0.5) * invNoiseRes).rg;
			//vec2 dailyOffset = texelFetch2D(noisetex, ivec2(worldDay, worldDay * invNoiseRes), 0).rg;

			float exclusion = interpolateSmooth1(clamp(acos(-dot(pos, sunPosNorm)) * 8.0 - EXCLUSION_RADIUS, 0.0, 1.0)); //darken things around the moon

			pos = (gbufferModelViewInverse * vec4(pos, 0.0)).xyz;
			pos.yz *= starRotation; //match sunPathRotation
			vec2 starPos = pos.xz / sqrt(pos.y + 1.0); //divide sky up into cells. each cell will have a star in it, though most stars won't actually render
			starPos *= 64.0; //main scaling factor
			starPos.x += worldTime * 0.015625; //gives the appearance of stars rotating like the sun/moon. Not actual rotation, but follows where the moon goes fairly closely

			vec3 result = vec3(0.0);

			#ifdef GALAXIES
				float noise = 0.0; //noise maps for galaxies
				vec2 noisePos = starPos * 0.03125 * invNoiseRes + dailyOffset; //galaxy scaling factor
				noise += texture2D(noisetex, noisePos        ).r * 0.6;
				noise += texture2D(noisetex, noisePos * 2.0  ).r * 0.36;
				noise += texture2D(noisetex, noisePos * 4.0  ).r * 0.216;
				noise += texture2D(noisetex, noisePos * 8.0  ).r * 0.1296;
				noise += texture2D(noisetex, noisePos * 16.0 ).r * 0.07776;
				noise += texture2D(noisetex, noisePos * 32.0 ).r * 0.046656;
				noise += texture2D(noisetex, noisePos * 64.0 ).r * 0.0279936;
				noise += texture2D(noisetex, noisePos * 128.0).r * 0.01679616;
				noise += texture2D(noisetex, noisePos * 256.0).r * 0.010077696;
				noise *= 0.6780553935455204; //1.0 / (0.6 + 0.36 + ... + 0.010077696)
				float biasedNoise = square(max(noise * 3.0 - 1.5, 0.3));

				float colorNoise = 0.0;
				colorNoise += texture2D(noisetex, -noisePos * 2.0).r * 0.5;
				colorNoise += texture2D(noisetex, -noisePos * 4.0).r * 0.25;
				colorNoise += texture2D(noisetex, -noisePos * 8.0).r * 0.125;

				//colorize galaxies with randomized hue
				//also reduce brightness near the moon, and when it's not quite dark enough yet.
				result += mix(hue(colorNoise) * 0.25, vec3(0.25), min(biasedNoise + 0.2, 1.0)) * (biasedNoise - 0.09) * clamp(max(adjustedTime - 7.8, 1.0 - space * 12.0), 0.0, 1.0) * exclusion;
			#endif

			#ifdef FANCY_STARS
				vec3 random = texture2D(noisetex, (floor(starPos + dailyOffset * noiseTextureResolution) + 0.5) * invNoiseRes).rgb;
				//vec3 random = texelFetch2D(noisetex, ivec2(mod(floor(starPos) + dailyOffset * noiseTextureResolution, noiseTextureResolution)), 0).rgb; //rg = star position within cell, b = color/size data (red stars are smaller/dimmer, blue stars are bigger/brighter)
				random.rg = random.rg * 0.7 + 0.15; //fix stars being chopped in half because their position was on the border of a cell
				float dist = distance(fract(starPos), random.rg) * (2.0 - random.b) * 5.0; //distance from center of star, with scaling factor based on color of star. 5.0 is star scaling factor; bigger values = smaller stars.
				dist *= length(gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY) - 0.5) * 2.0 + 1.0; //compensate for projection effects. 2.0 is scaling factor; increase it if stars on the edge of your screen are bigger than stars in the center
				dist = 1.0 - dist; //positive in center of star, negative outside the star.

				#ifdef GALAXIES
				if (dist > 0.0 && 1.0 - random.b < min(biasedNoise, exclusion)) { //pixel is part of star, and is bright enough for its noise value
					random.b = (random.b + biasedNoise - 1.0) / biasedNoise; //scale value based on threshold (determined by galaxy density)
				#else
				if (dist > 0.0 && 1.0 - random.b < min(0.1, exclusion)) { //pixel is part of star, 1/10'th of the stars generated will actually render.
					random.b = random.b * 10.0 - 9.0; //scale value based on threshold (1/20'th in this case)
				#endif
					vec3 starColor = mix(vec3(0.5), vec3(0.25, 0.5, 1.0), random.b); //blue or white, red dwarfs aren't visible to the naked eye.
					starColor = mix(starColor, vec3(1.0), dist * dist * 0.5 * random.b) * dist * dist; //whitest and brightest in the center
					starColor *= clamp(random.b * random.b * 1.5 + max(adjustedTime - 8.5, 1.0 - space * 16.0), 0.0, 1.0); //fading animation at sunset, blue stars appear sooner and disappear later
					starColor *= random.b * 0.75 + 0.25; //white stars are darker
					#ifdef GALAXIES
						starColor *= (1.0 - noise * 0.75); //stand out less where galaxies are already as bright as the stars
					#endif
					result += starColor;
				}
			#endif

			return result * (1.0 - max(rainStrength, wetness) * space) * (1.0 - fogify(upDot / space, 0.0625)); //reduce brightness when raining and near the horizon
		}
		return vec3(0.0);
	}
#endif