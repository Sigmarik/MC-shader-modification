//finds random value at location, as well as the slope at that location if needed.
//happens to generate noise that looks similar to minecraft's native pixellated clouds.
vec3 cloudNoise(vec2 coord, float size, float heightOffset, bool needNormals) {
	coord /= size;

	vec2 middle = fract(coord);
	vec4 corners = vec4(coord - middle + 0.5, 0.0, 0.0);
	corners.zw = corners.xy + 1.0;
	corners *= invNoiseRes;
	//vec4 corners = (vec4(floor(coord), ceil(coord)) + 0.5) * invNoiseRes;

	float r00 = texture2D(noisetex, corners.xy).r; //random value at the (0, 0) corner
	float r01 = texture2D(noisetex, corners.xw).r; //random value at the (0, 1) corner
	float r10 = texture2D(noisetex, corners.zy).r; //random value at the (1, 0) corner
	float r11 = texture2D(noisetex, corners.zw).r; //random value at the (1, 1) corner

	vec2 mixlvl = interpolateSmooth2(middle); //non-linear interpolation

	float height = mix(mix(r00, r10, mixlvl.x), mix(r01, r11, mixlvl.x), mixlvl.y) * 2.0 - 1.0 + heightOffset; //non-linear interpolation between the 4 corners
	if (needNormals && height > 0.0 && night < 0.999) {
		vec2 dmixlvl = interpolateSmooth2(1.0 - abs(middle * 2.0 - 1.0));

		float dx = mix((r00 - r10) * dmixlvl.x, (r01 - r11) * dmixlvl.x, mixlvl.y); //slope in x direction
		float dy = mix((r00 - r01) * dmixlvl.y, (r10 - r11) * dmixlvl.y, mixlvl.x); //slope in y direction
		return vec3(dx, dy, height);
	}
	else return vec3(0.0, 0.0, height);
}

//returns color and opacity of clouds
vec4 drawClouds(in vec3 pos, in vec3 posNorm, inout float height, in bool vshflag) {
	if ((night > 0.999 && rainStrength > 0.999) || blindness > 0.999) return vec4(0.0); //no point rendering clouds when you can't even see them.

	vec2 skyPos = pos.xz + eyePosition.xz;
	skyPos.x += frameTimeCounter / 1.5;
	float clumpingFactor = 1.5 * (cloudNoise(skyPos, 64.0, 0.0, false).z + wetness); //makes denser and less dense regions of clouds
	if (clumpingFactor > -1.0) {
		vec3 noiseData = cloudNoise(skyPos, 12.0, clumpingFactor, true);
		if (noiseData.z > 0.0) {
			if (height > 0.0) {
				height = 1.0 - height / noiseData.z;
				if (height < 0.0) return vec4(0.0);
			}
			vec3 color;
			//add more rough-ness to clouds. except at night, since they're solid black at night anyway. also less roughness at sunset, since it's more noticeable at sunset.
			if (night < 0.999) {
				vec2 moreNoise = vec2(0.0);
				moreNoise += texture2D(noisetex, skyPos / 3.5 * invNoiseRes).gb;
				moreNoise += texture2D(noisetex, skyPos       * invNoiseRes).gb / 4.0;
				moreNoise = (moreNoise / 2.5 - 0.25) * noiseData.z * (day + 1.0);
				noiseData.xy += moreNoise;

				vec3 normal = vec3(noiseData.x, noiseData.z * sign(eyePosition.y - CLOUD_HEIGHT), noiseData.y);
				if (vshflag) normal.y *= 1.0 - height; //interpolate normal Y value when flying through clouds
				normal = normalize((gbufferModelView * vec4(normal, 0.0)).xyz); //rotate to be in view space, and normalize.

				float lightAmt = dot(normal, sunPosNorm) * 0.5 + 0.5; //sun illumination
				if (eyePosition.y < CLOUD_HEIGHT) {
					lightAmt *= fogify(noiseData.z, 1.25); //decrease light near the centers of the underside of clouds
					lightAmt += square(max(dot(posNorm, sunPosNorm) * 3.0 - 2.0, 0.0)) * fogify(noiseData.z - wetness * 0.5, 0.25); //allow sun to "shine through" clouds where density is low, and apply bonus when raining
				}
				else {
					lightAmt *= lightAmt; //add more contrast to the tops of clouds
				}

				color = mix(cloudColor, cloudIlluminationColor, lightAmt);
			}
			else {
				color = vec3(0.0);
			}

			float alpha = 1.0 - fogify(noiseData.z + clamp(clumpingFactor, 0.0, noiseData.z), 0.25);

			return vec4(color, alpha) * (1.0 - blindness);
		}
	}
	return vec4(0.0);
}