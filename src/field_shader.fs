#version 330
#extension GL_ARB_explicit_uniform_location : enable

layout(location = 0) uniform int body_num;
layout(location = 1) uniform int screen_height;
layout(location = 2) uniform float largest_rad;
layout(location = 3) uniform int colour_mode;
/*
	Black and Yellow (looks like lighting) = 0,
	Yellow and Red = 1,
	White and Black = 2,
*/

layout(location = 4) uniform vec4 bodies[1019]; // pos.x, pos.y, mass, radius : x, y, z, w respectively

// Output fragment color
out vec4 finalColor;

void main() {
	vec2 force = vec2(0.0, 0.0);

	for (int i = 0; i < body_num; i++) {
		vec2 dist_vec = vec2(bodies[i].x - gl_FragCoord.x, bodies[i].y - (screen_height - gl_FragCoord.y));

		float angle = atan(dist_vec.y, dist_vec.x);
		float dist = sqrt(pow(dist_vec.x, 2) + pow(dist_vec.y, 2));

		if (dist + 2 >= bodies[i].w) {
			float force_mag = bodies[i].z/pow(dist, 2);
			force.x += force_mag * sin(angle);
			force.y += force_mag * cos(angle);
		}
	}

	float force_mag = sqrt(pow(force.x, 2) + pow(force.y, 2));
	float norm = force_mag/(largest_rad * 22000);   
	/* Largest radius used to normalise the data since the radius is proporitional to the mass of largest,
		and mass proportional to grav force. 22000 is to compensate for not multiplying by G, and gives best normal value below 1.
	*/

	if (colour_mode == 0) {
		finalColor = vec4(norm, norm, norm/1.2, 1.0);
	} else if (colour_mode == 1) {
		finalColor = vec4(1.0, norm, 0.0, 1.0);
	} else if (colour_mode == 2) {
		if (body_num > 0) {
			float antinorm = 1 - norm;
			finalColor = vec4(antinorm, antinorm, antinorm, 1.0);
		} else {
			finalColor = vec4(1.0, 1.0, 1.0, 1.0);
		}
	}
}
