#version 300 es

// an attribute will receive data from a buffer
in vec3 a_position;
in vec3 a_normal;

// transformation matrices
uniform mat4x4 u_m;
uniform mat4x4 u_v;
uniform mat4x4 u_p;

// output to fragment stage
// TODO: Create any needed `out` variables here
out vec3 position;
out vec3 normal;
out mat4x4 m;
out mat4x4 v;
out mat4x4 p;

void main() {

    // TODO: PHONG SHADING
    // TODO: Implement the vertex stage
    // TODO: Transform positions and normals
    // NOTE: Normals are transformed differently from positions. Check the book and resources.
    // TODO: Create new `out` variables above outside of main() to store any results
    gl_PointSize = 2.0f;
    position = a_position;
    normal = a_normal;
    m = u_m;
    v = u_v;
    p = u_p;
    gl_Position = u_p * u_v * u_m * vec4(a_position, 1.0);
}