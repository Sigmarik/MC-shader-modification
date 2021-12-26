//finds random value at location, as well as the slope at that location if needed.
vec3 cloudNoise(vec2 coord) {
	vec2 middle = fract(coord);
	vec4 corners = vec4(coord - middle + 0.5, 0.0, 0.0);
	corners.zw = corners.xy + 1.0;
	corners *= invNoiseRes;
	//vec4 corners = (vec4(floor(coord), ceil(coord)) + 0.5) * invNoiseRes;
	//ivec4 corners = ivec4(mod(vec4(floor(coord), ceil(coord)), noiseTextureResolution));

	float r00 = texture2D(noisetex, corners.xy).r; //random value at the (0, 0) corner
	float r01 = texture2D(noisetex, corners.xw).r; //random value at the (0, 1) corner
	float r10 = texture2D(noisetex, corners.zy).r; //random value at the (1, 0) corner
	float r11 = texture2D(noisetex, corners.zw).r; //random value at the (1, 1) corner

	vec2 mixlvl = interpolateSmooth2(middle); //non-linear interpolation

	float height = mix(mix(r00, r10, mixlvl.x), mix(r01, r11, mixlvl.x), mixlvl.y) - 0.5; //non-linear interpolation between the 4 corners
	#ifdef CLOUD_NORMALS
		vec2 dmixlvl = interpolateSmooth2(1.0 - abs(middle * 2.0 - 1.0));

		float dx = mix((r00 - r10) * dmixlvl.x, (r01 - r11) * dmixlvl.x, mixlvl.y); //slope in x direction
		float dy = mix((r00 - r01) * dmixlvl.y, (r10 - r11) * dmixlvl.y, mixlvl.x); //slope in y direction
		return vec3(dx, dy, height);
	#else
		return vec3(0.0, 0.0, height);
	#endif
}

//returns color and opacity of clouds
vec4 drawClouds(in vec3 pos, in vec3 posNorm, inout float height, in bool vshflag) {
	if ((night > 0.999 && rainStrength > 0.999) || blindness > 0.999) return vec4(0.0); //no point rendering clouds when you can't even see them.

	vec2 skyPos = pos.xz + eyePosition.xz;
	skyPos.x += frameTimeCounter; //apply wind

	skyPos *= 0.00390625; //scale
	float time = frameTimeCounter * 0.0078125;
	vec3 noise = vec3(0.0); //x and y = normal data, z = height

	noise += cloudNoise((skyPos + time * goldenOffset0)       ) * 2.0;
	noise += cloudNoise((skyPos + time * goldenOffset1) * 2.0 );
	noise += cloudNoise((skyPos + time * goldenOffset2) * 4.0 ) * 0.5;
	noise += cloudNoise((skyPos + time * goldenOffset3) * 8.0 ) * 0.25;
	noise += cloudNoise((skyPos + time * goldenOffset4) * 16.0) * 0.125;

	//add more detail without calculating interpolation or normals (since both of those are slower than fetching a single random number)
	skyPos *= invNoiseRes;
	time *= invNoiseRes;
	noise.z += texture2D(noisetex, (skyPos + time * goldenOffset5) * 32.0 ).r * 0.0625;
	noise.z += texture2D(noisetex, (skyPos + time * goldenOffset6) * 64.0 ).r * 0.03125;
	noise.z += texture2D(noisetex, (skyPos + time * goldenOffset7) * 128.0).r * 0.015625;
	noise.z += texture2D(noisetex, (skyPos + time * goldenOffset8) * 256.0).r * 0.0078125;
	noise.z += texture2D(noisetex, (skyPos + time * goldenOffset9) * 512.0).r * 0.00390625;

	noise.z += cloudDensityModifier; //random density fluctuations every few minutes
	noise.z /= max(cloudDensityModifier, 0.0) + 1.0; //scale so as not to be solid gray when density is ludicrously high
	noise.z += wetness; //bias when raining

	if (noise.z > 0.0) { //there are clouds here
		if (height > 0.0) { //volumetric effect handling (scale opacityModifier based on density of clouds)
			height = 1.0 - height / (1.0 - fogify(noise.z, 0.125));
			if (height < 0.0) return vec4(0.0); //clouds not dense enough for volumetric effects to apply.
		}
		#ifdef CLOUD_NORMALS
			vec3 normal = vec3(noise.x, noise.z * sign(eyePosition.y - CLOUD_HEIGHT), noise.y);
			if (vshflag) normal.y *= 1.0 - height; //interpolate normal Y value when flying through clouds
			normal = normalize((gbufferModelView * vec4(normal, 0.0)).xyz); //rotate to be in view space, and normalize.

			vec2 lightAmt = vec2(dot(normal, sunPosNorm), dot(normal, -sunPosNorm)) * 0.5 + 0.5; //sun and moon illumination
			if (eyePosition.y < CLOUD_HEIGHT) {
				lightAmt *= fogify(noise.z, 0.5); //decrease light near the centers of the underside of clouds
				lightAmt.x *= 1.0 - rainStrength * 0.75; //less sunlight during rain.
				lightAmt.x += square(max(dot(posNorm, sunPosNorm) * 3.0 - 2.0, 0.0)) * fogify(noise.z, 0.25) * (1.0 - rainStrength * 0.5); //allow sun to "shine through" clouds where density is low, and with slight bonus during rain (compared to everywhere else anyway)_
			}
			else {
				lightAmt *= lightAmt; //add more contrast to the tops of clouds
			}

			vec3 color = mix(cloudColor, cloudIlluminationColor, lightAmt.x); //colorize
			color += mix(vec3(0.01, 0.02, 0.03), vec3(0.1, 0.15, 0.25), lightAmt.y * phase) * night * (1.0 - rainStrength); //add lunar illumination
			float alpha = 1.0 - fogify(noise.z , 0.0625); //more opaque in center, less opaque around edges
			return vec4(color, alpha) * (1.0 - blindness);
		#else
			float lightAmt = fogify(noise.z, 0.25); //more light on edges than center
			if (eyePosition.y > CLOUD_HEIGHT) lightAmt = lightAmt * -0.5 + 1.0; //reverse and scale when above clouds

			vec3 color = mix(cloudColor, cloudIlluminationColor, lightAmt); //colorize
			color += mix(vec3(0.01, 0.02, 0.03), vec3(0.1, 0.15, 0.25), lightAmt) * night * phase * (1.0 - rainStrength); //add lunar illumination
			float alpha = 1.0 - fogify(noise.z, 0.0625); //more opaque in center, less opaque around edges
			return vec4(color, alpha) * (1.0 - blindness);
		#endif
	}
	return vec4(0.0);
}