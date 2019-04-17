#version 330

#define G 0.001

uniform int body_num;
uniform vec4 bodies[1024]; // pos.x, pos.y, mass, radius

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Output fragment color
out vec4 finalColor;

float get_gfs(float m, float distance) { // Gravitational field strength
	return (G * m)/(distance * distance);
}

void main() {
	vec2 force;
	for (int i = 0; i < body_num; i++) {
		vec2 dist_vec;
		dist_vec.r = bodies[i].r - fragTexCoord.r;
		dist_vec.g = bodies[i].g - fragTexCoord.g;

		float angle = atan(dist_vec.g, dist_vec.r);
		float distance = sqrt(pow(dist_vec.r, 2) + pow(dist_vec.g, 2));

		if (distance > bodies[i].a) {
			float f_mag = get_gfs(bodies[i].b, distance);
			force.r += f_mag * sin(angle);
			force.g += f_mag * cos(angle);
		}
	}

	float force_mag = sqrt(pow(force.r, 2) + pow(force.g, 2));

	finalColor = vec4(1.0, force_mag/2000, 0.0, 1.0);

	/*
	if (force_mag > 100) {
		finalColor = vec4(0.0, 0.0, 1.0, 1.0);
	} else if (force_mag > 500) {
		finalColor = vec4(0.0, 1.0, 0.0, 1.0);
	} else if (force_mag < 10) {
		finalColor = vec4(1.0, 0.0, 0.0, 1.0);
	} else {
		finalColor = vec4(1.0, 1.0, 1.0, 1.0);
	}
	*/
}
