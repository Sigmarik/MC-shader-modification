#ifdef ENDER_NEBULAE
	float random(vec2 coord) {
		vec2 middle = fract(coord);
		vec4 corners = vec4(coord - middle + 0.5, 0.0, 0.0);
		corners.zw = corners.xy + 1.0;
		corners *= invNoiseRes;

		float r00 = texture2D(noisetex, corners.xy).r; //random value at the (0, 0) corner
		float r01 = texture2D(noisetex, corners.xw).r; //random value at the (0, 1) corner
		float r10 = texture2D(noisetex, corners.zy).r; //random value at the (1, 0) corner
		float r11 = texture2D(noisetex, corners.zw).r; //random value at the (1, 1) corner

		vec2 mixlvl = interpolateSmooth2(middle); //non-linear interpolation

		return mix(mix(r00, r10, mixlvl.x), mix(r01, r11, mixlvl.x), mixlvl.y); //linear interpolation between the 4 corners
	}

	//base noise algorithm for the overall cloud pattern.
	float cloudNoise(vec2 pos) {
		float noise = -0.32992;
		noise += random(pos * 2.0  + goldenOffset0 * frameTimeCounter * 0.125  ) * 0.4;
		noise += random(pos * 4.0  + goldenOffset1 * frameTimeCounter * 0.0625 ) * 0.16;
		noise += random(pos * 8.0  + goldenOffset2 * frameTimeCounter * 0.04166) * 0.064;
		noise += random(pos * 16.0 + goldenOffset3 * frameTimeCounter * 0.03125) * 0.0256;
		noise += random(pos * 32.0 + goldenOffset4 * frameTimeCounter * 0.025  ) * 0.01024;
		return noise;
	}

	//noise algorithm for all the different colors
	//doesn't need as many iterations as cloudNoise() because it doesn't need to be as "rough"
	//also has different speed/effect multipliers in order to fit the values I want to get out of hue().
	float colorNoise(vec2 pos) {
		float noise = 0.4;
		noise += random(pos * 2.0 + goldenOffset5 * frameTimeCounter * 0.5 ) * 0.25;
		noise += random(pos * 4.0 + goldenOffset6 * frameTimeCounter * 0.25) * 0.125;
		noise += random(pos * 8.0 + goldenOffset7 * frameTimeCounter * 0.16) * 0.0625;
		return noise;
	}

	//both of these functions are quite similar, just with some slight differences in the math.
	#ifdef ENDER_ARCS
		vec4 drawNebulae(vec2 pos) {
			float noise = abs(cloudNoise(pos)); //density depends on how close cloudNoise() is to 0.0
			if (noise < 0.25) { //alpha calculations work within the range 0 - 0.25
				vec3 baseclr = hue(colorNoise(pos)) * 0.625; //nebulae color at this position
				float arclight = square(max(0.7 - noise * 8.0, 0.0)); //brighten areas that are very close to an arc (when cloudNoise() is close to 0.0)
				return vec4(mix(baseclr, vec3(1.0), arclight), square(1.0 - noise * 4.0) * 0.9); //alpha also depends on how close to an arc we are
			}
			else return vec4(0.0); //was not part of a nebula
		}
	#else
		vec4 drawNebulae(vec2 pos) {
			float noise = cloudNoise(pos); //density depends on how close cloudNoise() is to 1.0
			if (noise > 0.0) {
				vec3 baseclr = hue(colorNoise(pos)) * 0.625; //nebulae color at this position
				baseclr += 1.0 - 0.1 / (noise * noise + 0.1); //brighten areas that are close to the "center" of the nebulae (when cloudNoise() is close to 1.0)
				return vec4(baseclr, 1.0 - 0.02 / (noise * noise + 0.02)); //alpha also depends on how close to the "center" of the nebulae we are
			}
			else return vec4(0.0);
		}
	#endif
#endif

#ifdef ENDER_STARS
	float fade(float speed, float delay) {
		float newTime = mod(frameTimeCounter * speed, delay);
		//newTime / threshold
		if (newTime < 0.1) return newTime * 10.0;
		//1.0 - (newTime / (1.0 - threshold)) + (threshold / (1.0 - threshold));
		else return newTime * -1.1111111111111111 + 1.1111111111111111;
	}

	vec3 drawStars(vec2 pos) {
		pos *= 16.0; //increase density of stars by a factor of 16x.
		vec2 newpos = floor(pos) + 0.5; //position rounded to the nearest "square". you can immagine this imposing a grid pattern onto the sky.

		//r = random chance that this square will be a star, g = fade animation speed, b = delay before re-appearing
		//r is also used to store "brightness" of the star. if the star is above 75% brightness to start with, it gets to be rendered. (this check is ignored for ender portals)
		vec3 starData1 = texture2D(noisetex, newpos * invNoiseRes).rgb;
		float fadeAmt = fade(starData1.g * 0.1 + 0.15, starData1.b * 8.0 + 1.0);

		if (starData1.r > 0.75 && fadeAmt > 0.0) { //25% of all the "squares" in the sky will be stars
			//r = type (star-shaped vs. circular), g = size multiplier, b = color
			vec3 starData2 = texture2D(noisetex, -newpos * invNoiseRes).rgb;

			float dist;
			//star-shaped stars are smaller than circular ones, so making more of them to compensate.
			if (starData2.r < 0.25) dist = length(pos - newpos) * 2.0; //pythagorean distance
			else { //star-shaped distance (distance increases faster diagonally than cardinally)
				vec2 v = sqrt(abs(pos - newpos));
				dist = v.x + v.y;
			}

			dist *= starData2.g + 1.0; //apply random size modifier. increasing the distance has the effect of decreasing the size, since smaller distances get scaled up to the maximum distance
			dist += 1.0 - fadeAmt; //apply fading animation. again, increasing distance decreases size. when fadeAmt = 0, the star will be invisible.

			float amt = square(max(1.0 - dist, 0.0)); //apply distance calculations to brightness of the star. The closer we are to the center, the brighter it should be.

			vec3 clr = hue(starData2.b * 0.6 - 0.35) * 0.625 + 0.375; //calculate color of star based on random number.
			clr = clr * amt + amt * amt * 0.625; //actually colorize star, and make whiter near the center.

			//make some stars brighter than others
			clr *= starData1.r * 2.0 - 1.0;

			return clr;
		}
		return vec3(0.0);
	}
#endif