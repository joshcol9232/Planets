#version 330

#define G 0.001

uniform vec3 bodies[512]; // pos.x, pos.y, mass : x, y, z respectively
uniform int body_num;
uniform int screen_height;

// Output fragment color
out vec4 finalColor;

void main() {
	vec2 force = vec2(0.0, 0.0);

	for (int i = 0; i < body_num; i++) {
		vec2 dist_vec = vec2(bodies[i].x - gl_FragCoord.x, bodies[i].y - (screen_height - gl_FragCoord.y));

		float angle = atan(dist_vec.y, dist_vec.x);
		float dist = sqrt(pow(dist_vec.x, 2) + pow(dist_vec.y, 2));

		float force_mag = G * bodies[i].z/pow(dist, 2);
		force.x += force_mag * sin(angle);
		force.y += force_mag * cos(angle);
	}

	float force_mag = sqrt(pow(force.r, 2) + pow(force.g, 2));

	finalColor = vec4(0.0, force_mag/1000, 0.0, 1.0);
}
