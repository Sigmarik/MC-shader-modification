float thresholdSample(vec2 coord, vec2 threshold) {
	vec2 middle = fract(coord);
	vec4 corners = vec4(coord - middle + 0.5, 0.0, 0.0);
	corners.zw = corners.xy + 1.0;
	corners *= invNoiseRes;
	//vec4 corners = (vec4(floor(coord), ceil(coord)) + 0.5) * invNoiseRes;

	vec4 cornerSample = vec4(
		texture2D(noisetex, corners.xy).r, //random value at the (0, 0) corner
		texture2D(noisetex, corners.xw).r, //random value at the (0, 1) corner
		texture2D(noisetex, corners.zy).r, //random value at the (1, 0) corner
		texture2D(noisetex, corners.zw).r  //random value at the (1, 1) corner
	);

	/*
	ivec4 corners = ivec4(mod(vec4(floor(coord), ceil(coord)), noiseTextureResolution));

	vec4 cornerSample = vec4(
		texelFetch2D(noisetex, corners.xy, 0).r, //random value at the (0, 0) corner
		texelFetch2D(noisetex, corners.xw, 0).r, //random value at the (0, 1) corner
		texelFetch2D(noisetex, corners.zy, 0).r, //random value at the (1, 0) corner
		texelFetch2D(noisetex, corners.zw, 0).r  //random value at the (1, 1) corner
	);
	*/
	vec4 high = vec4(greaterThan(cornerSample, threshold.xxxx));
	vec4 low = vec4(lessThan(cornerSample, threshold.yyyy));

	vec2 mixlvl = interpolateSmooth2(middle); //non-linear interpolation

	return mix(mix(high.x, high.y, mixlvl.y), mix(high.z, high.w, mixlvl.y), mixlvl.x) -
		   mix(mix(low.x,  low.y,  mixlvl.y), mix(low.z,  low.w,  mixlvl.y), mixlvl.x);
}

vec4 drawVoidClouds(in vec3 pos, inout float volumetric) {
	if (blindness > 0.999) return vec4(0.0);
	float noise = 512.0 / (lengthSquared2(pos.xz / pos.y) + 256.0) - 3.0; //reduce cloud density in the distance
	float noiseTime = frameTimeCounter * invNoiseRes;

	pos += eyePosition;
	vec2 clumpPos = (pos.xz + vec2(frameTimeCounter * 2.0, 0.0)) / 256.0; //divide into 256-block-long cells
	float clumpingFactor = thresholdSample(clumpPos, vec2(0.75, 0.25)); //pick a random value for each cell. if it's above 0.75, it gets +1 density. if it's below 0.25, it gets -1 density.
	noise += clumpingFactor;

	//now to add some randomness so they look roughly cloud-shaped
	float speed = noiseTime * 2.0;
	vec2 cloudPos = pos.xz * invNoiseRes;
	cloudPos.x += noiseTime * 0.5; //multiplying by 0.5 instead of 2 so that clouds look like they're "spreading" as well as being blown around
	noise += texture2D(noisetex, (cloudPos + goldenOffset0 * speed) * 0.015625).r;
	noise += texture2D(noisetex, (cloudPos + goldenOffset1 * speed) * 0.03125 ).r * 0.6;
	noise += texture2D(noisetex, (cloudPos + goldenOffset2 * speed) * 0.0625  ).r * 0.36;
	noise += texture2D(noisetex, (cloudPos + goldenOffset3 * speed) * 0.125   ).r * 0.216;
	noise += texture2D(noisetex, (cloudPos + goldenOffset4 * speed) * 0.25    ).r * 0.1296;
	noise += texture2D(noisetex, (cloudPos + goldenOffset5 * speed) * 0.5     ).r * 0.07776;
	noise += texture2D(noisetex, (cloudPos + goldenOffset6 * speed)           ).r * 0.046656;
	noise += texture2D(noisetex, (cloudPos + goldenOffset7 * speed) * 2.0     ).r * 0.0279936;

	if (noise > 0.0) { //there are indeed clouds here
		vec3 color = vec3(noise * 0.0625); //base cloud color
		bool speckles = volumetric < 0.0;
		if (volumetric > 0.0) {
			volumetric = 1.0 - volumetric / (1.0 - fogify(noise, 0.125));
			if (volumetric < 0.0) return vec4(0.0);
		}

		//lightning effects:
		if (clumpingFactor > 0.0) { //only apply lightning to high-density cloud areas
			float lightningMultiplier = interpolateSmooth1(max(1.0 - length(fract(clumpPos + 0.5) * 2.0 - 1.0), 0.0)); //1.0 at the centers of cells (cells referring to the sample points collected by clumpingFactor), and 0.0 at the edges.
			vec2 lightningOffset = (texture2D(noisetex, (floor(clumpPos + 0.5) + 0.5) * invNoiseRes).gb * 0.5 + 0.5) * noiseTime; //random position to sample from
			float lightningAmt = max(texture2D(noisetex, lightningOffset).r * 8.0 - 7.0, 0.0); //do sample on that position to get lightning amount
			lightningAmt *= texture2D(noisetex, lightningOffset.yx * 32.0).r; //multiply by another value that changes more rapidly, this makes the lightning flicker instead of just fading in/out
			color += lightningAmt * lightningMultiplier * clumpingFactor * noise; //add final value.
		}

		//sparkly square confetti things:
		if (speckles) {
			vec3 data = texture2D(noisetex, (floor((pos.xz + vec2(frameTimeCounter, 0.0)) * 2.0) + 0.5) * invNoiseRes).rgb; //r = hue, gb = another random offset
			float amt = texture2D(noisetex, data.gb * noiseTime * 0.25).r; //base brightness of square
			amt = max(amt * 8.0 - 8.0 + noise, 0.0); //add bias so that there are more squares where cloud density is high
			color += hue(data.r * 0.35 + 0.45) * amt; //color of square
		}

		noise = min(noise * 1.5, 1.0); //add bias to noise so that clouds reach 100% opacity in highly dense regions
		return vec4(color, interpolateSmooth1(noise)) * (1.0 - blindness);
	}
	else return vec4(0.0);
}