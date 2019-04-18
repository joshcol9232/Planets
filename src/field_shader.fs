#version 330
#extension GL_ARB_explicit_uniform_location : enable

#define G 0.001

layout(location = 0) uniform int body_num;
layout(location = 1) uniform int screen_height;
layout(location = 2) uniform float largest_rad;

layout(location = 3) uniform vec4 bodies[1020]; // pos.x, pos.y, mass, radius : x, y, z, w respectively

// Output fragment color
out vec4 finalColor;

void main() {
	vec2 force = vec2(0.0, 0.0);

	for (int i = 0; i < body_num; i++) {
		vec2 dist_vec = vec2(bodies[i].x - gl_FragCoord.x, bodies[i].y - (screen_height - gl_FragCoord.y));

		float angle = atan(dist_vec.y, dist_vec.x);
		float dist = sqrt(pow(dist_vec.x, 2) + pow(dist_vec.y, 2));

		if (dist + 2 >= bodies[i].w) {
			float force_mag = G * bodies[i].z/pow(dist, 2);
			force.x += force_mag * sin(angle);
			force.y += force_mag * cos(angle);
		}
	}

	float force_mag = sqrt(pow(force.x, 2) + pow(force.y, 2));
	float norm = force_mag/(largest_rad * 22);

	finalColor = vec4(0.0, norm, 0.0, 1.0);
}
