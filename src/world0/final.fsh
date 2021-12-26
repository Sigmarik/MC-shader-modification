#version 120

#include "/lib/defines.glsl"

uniform float pixelSizeY;
uniform float viewHeight;
uniform sampler2D composite; //output from previous stage
#define inputSampler composite

varying vec2 texcoord;

#include "/lib/math.glsl"

void main() {
	//#include "/lib/verticalBlur.glsl"
	vec4 color = texture2D(inputSampler, texcoord).rgb;
	vec4 bloom_addition = vec4(0.0);
	float bloom_radius = 5;
	float bloom_step = (bloom_radius * 2 / 5);
	for (float x = texcoord.x - bloom_radius; x < texcoord.x + bloom_radius; x += bloom_step) {
		for (float y = texcoord.y - bloom_radius; y < texcoord.y + bloom_radius; y += bloom_step) {
			vec2 pos = vec2(x, y);
			float dx = x - texcoord.x;
			float dy = y - texcoord.y;
			vec3 pix_col = texture2D(inputSampler, pos).rgb;
			float dist = sqrt(dx * dx + dy * dy);
			if (pix_col.r + pix_col.g + pix_col.b > 0) {
				bloom_addition += pix_col * (1.0 / pow(3.0, dist));
			}
		}
	}
	gl_FragColor = vec3(0.0); //screen output
}