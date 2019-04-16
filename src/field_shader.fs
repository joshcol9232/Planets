#version 330

#define BODY_NUM_MAX 1000

struct Body {
	vec2 position;
	float mass;
};

uniform Body bodies[BODY_NUM_MAX];
uniform int body_num;

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

uniform int bodyNum;
uniform Body bodies[bodyNum];

// Output fragment color
out vec4 finalColor;

void main() {
	finalColor = vec4(1.0, 1.0, 0.0, 1.0);
	
}
