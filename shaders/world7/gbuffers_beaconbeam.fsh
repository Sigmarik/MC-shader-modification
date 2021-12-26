#version 120

#define FANCY_BEACONS //Builderb0y's better beacon beams bring big bright beautiful beacon beams to all biomes, bro

uniform float frameTimeCounter;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform sampler2D texture;
uniform vec3 cameraPosition;
        vec3 eyePosition = cameraPosition + gbufferModelViewInverse[3].xyz; //because cameraPosition isn't actually the position of the camera -_-

#ifdef FANCY_BEACONS
	varying vec2 beaconPos;
#endif
#ifndef FANCY_BEACONS
	varying vec2 texcoord;
#endif
#ifdef FANCY_BEACONS
	varying vec3 pos;
#endif
varying vec4 glcolor;

//sines and cosines of multiples of the golden angle (~2.4 radians)
const vec2 goldenOffset0 = vec2( 0.675490294261524, -0.73736887807832 ); //2.39996322972865332
const vec2 goldenOffset1 = vec2(-0.996171040864828,  0.087425724716963); //4.79992645945731
const vec2 goldenOffset2 = vec2( 0.793600751291696,  0.608438860978863); //7.19988968918596
const vec2 goldenOffset3 = vec2(-0.174181950379306, -0.98471348531543 ); //9.59985291891461
const vec2 goldenOffset4 = vec2(-0.53672805262632,   0.843755294812399); //11.9998161486433

float square(float x)        { return x * x; } //faster than pow().

vec2  interpolateSmooth2(vec2 v)  { return v * v * (3.0 - 2.0 * v); }

float distanceSq2(vec2 p1, vec2 p2) {
	return square(p2.x - p1.x) + square(p2.y - p1.y);
}

float calcBeaconWidth(float y) {
	float width = 4.0;
	width += sin(y * 2.0 - frameTimeCounter *  4.0) * sin(frameTimeCounter);
	width += sin(y * 8.0 + frameTimeCounter * 12.0) * sin(frameTimeCounter * 1.61803398875 /* golden ratio */) * 0.25;
	return width * 0.0625;
}

float hash12(vec2 p) { //thanks jodie!
	vec3 p3 = fract(p.xyx * 4.438975);
	p3 += dot(p3, p3.yzx + 19.19);
	return fract((p3.x + p3.y) * p3.z);
}

//calculating noise manually instead of using noisetex for better control over looping and for backwards compatibility with version of optifine which do not bind noisetex correctly in gbuffers_beaconbeam.
float random(vec2 coord, float repeat) {
	vec2 frac = fract(coord);
	vec4 floorCeil = vec4(coord - frac, 0.0, 0.0);
	floorCeil.zw = floorCeil.xy + 1.0;
	floorCeil.xz = mod(floorCeil.xz, repeat);

	vec4 corners = vec4(hash12(floorCeil.xy), hash12(floorCeil.xw), hash12(floorCeil.zy), hash12(floorCeil.zw));
	frac = interpolateSmooth2(frac);
	return mix(mix(corners.x, corners.z, frac.x), mix(corners.y, corners.w, frac.x), frac.y);
}

void main() {
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

/* DRAWBUFFERS:04 */
	//2356
	//gl_FragData[0] = vec4(normalize(midTest.xz - beaconPos) * 0.5 + 0.5, 0.0, 1.0).xzyw; //normal
	//gl_FragData[1] = color; //composite
	//gl_FragData[2] = vec4(1.0, 1.0, 0.0, 1.0); //gaux2
	//gl_FragData[3] = vec4(1.0, 0.0, 0.0, color.a); //gaux3
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(0.96875, 0.96875, 1.0, 1.0); //gaux1
}