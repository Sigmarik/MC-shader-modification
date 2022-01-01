#version 120

#define BLOOM_ENABLED 1 //GuEsS wHaT ThIs OpTiOn Is DoInG. [1 0]
#define BLOOM_STRENGTH 1.0 //Bloom effect raw multiplier. [0.1 0.3 0.5 0.7 1.0 2.0 3.0 4.0 5.0 6.0]
#define BLOOM_QUALITY 20 //Number of samples algorithm will do. [3 5 10 15 20 25 30]
#define BLOOM_COMP_RADIUS 10 //Bloom computation tile size. [5 10 15 20]
#define BLOOM_SHAPE 1 //Defines what shape bloom rays will take. "Circle" option will make your PC explosive. [0 1 2]
#define BLOOM_DIVCONST 10 //Defines one thing in bloom equation. [1 3 5 10 15 20]
#define BLOOM_DISTMUL 10 //Defines another thing in bloom equation. [1 2 3 5 10 15 20]
#define BLOOM_COLOREXPCONST 0.1 //Defines one more thing in bloom equation. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]
#define BLOOM_COLOR_EXPONENT 4 //Defines semi-contrast of the bloom. [1 2 3 4 5 6]
#define BLOOM_FUNCTION_TYPE 0 //Bloom brightness function. Non-exponent functions will not take in consideration bloom parameters. [0 1 2]
#define BLOOM_GAUSSIAN_DIVISOR 10 //Bloom parameter. Affects only gaussian bloom type. [1 5 10 20 25 36]

uniform float pixelSizeX;
uniform float pixelSizeY;
uniform float viewWidth;
uniform sampler2D gaux2; //output from previous stage
uniform sampler2D gaux1;
uniform sampler2D gcolor;
uniform sampler2D colortex8;
uniform sampler2D composite;

varying vec2 texcoord;

varying vec3 skyLightColor;
varying float skyBrightness;

vec4 get_ll(vec2 pos) {
	return max(texture2D(gaux2, texcoord), texture2D(gaux1, texcoord));
}

float round(float x) {
	if (x - floor(x) < ceil(x) - x) {
		return floor(x);
	}
	return ceil(x);
}

#if BLOOM_FUNCTION_TYPE == 0
float bloom_brightness(float distance) {
	return (1.0 / pow(BLOOM_DIVCONST, distance / BLOOM_DISTMUL));
}
#endif
#if BLOOM_FUNCTION_TYPE == 1
float bloom_brightness(float distance) {
	return max(0, BLOOM_COMP_RADIUS - distance) / BLOOM_COMP_RADIUS;
}
#endif
#if BLOOM_FUNCTION_TYPE == 2
float bloom_brightness(float distance) {
	return (1.0 / pow(BLOOM_DIVCONST, (distance * distance / BLOOM_GAUSSIAN_DIVISOR) / BLOOM_DISTMUL));
}
#endif

void main() {
	vec4 light_level = max(texture2D(gaux2, texcoord), texture2D(gaux1, texcoord));
	vec4 bloom_addition = vec4(0.0);
	#if BLOOM_ENABLED
		float bloom_radius = BLOOM_COMP_RADIUS;
		float bloom_step_x = (bloom_radius * pixelSizeX * 2) / BLOOM_QUALITY;
		float bloom_step_y = (bloom_radius * pixelSizeY * 2) / BLOOM_QUALITY;

		#if BLOOM_SHAPE == 0
			for (float x = texcoord.x - bloom_radius * pixelSizeX; x < texcoord.x + bloom_radius * pixelSizeX; x += bloom_step_x) {
				float y = texcoord.y;
				float x_real = round(x / bloom_step_x) * bloom_step_x;
				float y_real = round(y / bloom_step_y) * bloom_step_y;
				vec2 pos = vec2(x_real, y_real);
				float dx = (x_real - round(texcoord.x / bloom_step_x) * bloom_step_x) / pixelSizeX;
				float dy = (y_real - round(texcoord.y / bloom_step_y) * bloom_step_y) / pixelSizeY;
				vec4 pix_col = texture2D(composite, pos);
				
				float dist = sqrt(dx * dx + dy * dy);
				pix_col = vec4(pow(pix_col.r, BLOOM_COLOR_EXPONENT), pow(pix_col.g, BLOOM_COLOR_EXPONENT), pow(pix_col.b, BLOOM_COLOR_EXPONENT), 1.0);
				pix_col *= pow(BLOOM_COLOREXPCONST, (1.0 - get_ll(pos).r + get_ll(pos).g * skyBrightness));
				bloom_addition = max(bloom_addition, pix_col * bloom_brightness(dist));
			}
			for (float y = texcoord.y - bloom_radius * pixelSizeY; y < texcoord.y + bloom_radius * pixelSizeY; y += bloom_step_y) {
				float x = texcoord.x;
				float x_real = round(x / bloom_step_x) * bloom_step_x;
				float y_real = round(y / bloom_step_y) * bloom_step_y;
				vec2 pos = vec2(x_real, y_real);
				float dx = (x_real - round(texcoord.x / bloom_step_x) * bloom_step_x) / pixelSizeX;
				float dy = (y_real - round(texcoord.y / bloom_step_y) * bloom_step_y) / pixelSizeY;
				vec4 pix_col = texture2D(composite, pos);
				
				float dist = sqrt(dx * dx + dy * dy);
				pix_col = vec4(pow(pix_col.r, BLOOM_COLOR_EXPONENT), pow(pix_col.g, BLOOM_COLOR_EXPONENT), pow(pix_col.b, BLOOM_COLOR_EXPONENT), 1.0);
				pix_col *= pow(BLOOM_COLOREXPCONST, (1.0 - get_ll(pos).r + get_ll(pos).g * skyBrightness));
				bloom_addition = max(bloom_addition, pix_col * bloom_brightness(dist));
			}
		#endif

		#if BLOOM_SHAPE == 1
			for (float delta = -0.5 * BLOOM_QUALITY; delta <= BLOOM_QUALITY / 2; delta += 1) {
				float x = texcoord.x + delta * bloom_step_x;
				float y = texcoord.y + delta * bloom_step_y;
				float x_real = round(x / bloom_step_x) * bloom_step_x;
				float y_real = round(y / bloom_step_y) * bloom_step_y;
				vec2 pos = vec2(x_real, y_real);
				float dx = (x_real - round(texcoord.x / bloom_step_x) * bloom_step_x) / pixelSizeX;
				float dy = (y_real - round(texcoord.y / bloom_step_y) * bloom_step_y) / pixelSizeY;
				vec4 pix_col = texture2D(composite, pos);
				
				float dist = sqrt(dx * dx + dy * dy);
				pix_col = vec4(pow(pix_col.r, BLOOM_COLOR_EXPONENT), pow(pix_col.g, BLOOM_COLOR_EXPONENT), pow(pix_col.b, BLOOM_COLOR_EXPONENT), 1.0);
				pix_col *= pow(BLOOM_COLOREXPCONST, (1.0 - get_ll(pos).r + get_ll(pos).g * skyBrightness));
				bloom_addition = max(bloom_addition, pix_col * bloom_brightness(dist));
			}
			for (float delta = -0.5 * BLOOM_QUALITY; delta <= BLOOM_QUALITY / 2; delta += 1) {
				float x = texcoord.x + delta * bloom_step_x;
				float y = texcoord.y - delta * bloom_step_y;
				float x_real = round(x / bloom_step_x) * bloom_step_x;
				float y_real = round(y / bloom_step_y) * bloom_step_y;
				vec2 pos = vec2(x_real, y_real);
				float dx = (x_real - round(texcoord.x / bloom_step_x) * bloom_step_x) / pixelSizeX;
				float dy = (y_real - round(texcoord.y / bloom_step_y) * bloom_step_y) / pixelSizeY;
				vec4 pix_col = texture2D(composite, pos);
				
				float dist = sqrt(dx * dx + dy * dy);
				pix_col = vec4(pow(pix_col.r, BLOOM_COLOR_EXPONENT), pow(pix_col.g, BLOOM_COLOR_EXPONENT), pow(pix_col.b, BLOOM_COLOR_EXPONENT), 1.0);
				pix_col *= pow(BLOOM_COLOREXPCONST, (1.0 - get_ll(pos).r + get_ll(pos).g * skyBrightness));
				bloom_addition = max(bloom_addition, pix_col * bloom_brightness(dist));
			}
		#endif

		#if BLOOM_SHAPE == 2
			for (float x = texcoord.x - bloom_radius * pixelSizeX; x < texcoord.x + bloom_radius * pixelSizeX; x += bloom_step_x) {
				for (float y = texcoord.y - bloom_radius * pixelSizeY; y < texcoord.y + bloom_radius * pixelSizeY; y += bloom_step_y) {
					float x_real = round(x / bloom_step_x) * bloom_step_x;
					float y_real = round(y / bloom_step_y) * bloom_step_y;
					vec2 pos = vec2(x_real, y_real);
					float dx = (x_real - round(texcoord.x / bloom_step_x) * bloom_step_x) / pixelSizeX;
					float dy = (y_real - round(texcoord.y / bloom_step_y) * bloom_step_y) / pixelSizeY;
					vec4 pix_col = texture2D(composite, pos);
					
					float dist = sqrt(dx * dx + dy * dy);
					pix_col = vec4(pow(pix_col.r, BLOOM_COLOR_EXPONENT), pow(pix_col.g, BLOOM_COLOR_EXPONENT), pow(pix_col.b, BLOOM_COLOR_EXPONENT), 1.0);
					pix_col *= pow(BLOOM_COLOREXPCONST, (1.0 - get_ll(pos).r + get_ll(pos).g * skyBrightness));
					bloom_addition = max(bloom_addition, pix_col * bloom_brightness(dist));
				}
			}
		#endif
	#endif
/* DRAWBUFFERS:7 */
	gl_FragData[0] = bloom_addition * BLOOM_STRENGTH; //gaux4
}