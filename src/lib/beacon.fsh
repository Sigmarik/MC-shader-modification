#ifdef FANCY_BEACONS
	if (!gl_FrontFacing) discard; //ignore back faces
	
	//setup some position variables
	vec2 posNorm2 = normalize(pos.xz);
	vec3 posNorm3 = normalize(pos);
	vec3 cylinderProjection = posNorm3 * (posNorm2.x / posNorm3.x);
	
	vec3 farTest = dot(posNorm2, beaconPos) * cylinderProjection; //closest point to the beaconPos which is along our view vector
	if (square(calcBeaconWidth(farTest.y + eyePosition.y)) < distanceSq2(beaconPos, farTest.xz)) discard; //if this closest point is still not inside the beam, then it's unlikely that our view vector intersects with the beam at all.
	vec3 nearTest = (length(beaconPos) - 0.328125) * cylinderProjection; //furthest possible point from beaconPos that calcBeaconWidth can output
	vec3 midTest = (nearTest + farTest) * 0.5;
	
	//binary split search to test for intersections.
	//increasing the number of steps in this loop will increase the precision of the results we get.
	for (int i = 0; i < 8; i++) {
		if (square(calcBeaconWidth(midTest.y + eyePosition.y)) < distanceSq2(beaconPos, midTest.xz)) nearTest = midTest;
		else farTest = midTest;
		midTest = (nearTest + farTest) * 0.5;
	}
	
	vec2 tc = vec2(atan(midTest.z - beaconPos.y, midTest.x - beaconPos.x) * 0.63661977236758134307553505349006 /* 2 / pi */, midTest.y + eyePosition.y);
	vec4 color = texture2D(texture, tc + vec2(frameTimeCounter, frameTimeCounter * -4.0)) * glcolor;
	
	tc.y *= 3.0;
	float noise = -0.3125;
	noise += random(tc * 0.5 + goldenOffset0 * frameTimeCounter * 2.0  /* 2/1 */,  2.0) * 0.4;     //0.4^1
	noise += random(tc       + goldenOffset1 * frameTimeCounter        /* 2/2 */,  4.0) * 0.16;    //0.4^2
	noise += random(tc * 2.0 + goldenOffset2 * frameTimeCounter * 0.66 /* 2/3 */,  8.0) * 0.064;   //0.4^3
	noise += random(tc * 4.0 + goldenOffset3 * frameTimeCounter * 0.25 /* 2/4 */, 16.0) * 0.0256;  //0.4^4
	noise += random(tc * 8.0 + goldenOffset4 * frameTimeCounter * 0.4  /* 2/5 */, 32.0) * 0.01024; //0.4^5
	noise = abs(noise);
	if (noise < 0.125) color.rgb = mix(color.rgb, glcolor.rgb * (2.0 - glcolor.rgb), square(1.0 - noise * 8.0));
	
	//adjust fragDepth to match that of our midTest.
	vec4 fragPos = gbufferModelView * vec4(midTest, 0.0);
	fragPos.w = 1.0;
	fragPos = gbufferProjection * fragPos;
	gl_FragDepth = fragPos.z / fragPos.w * 0.5 + 0.5;
#else
	vec4 color = texture2D(texture, texcoord) * glcolor;
#endif