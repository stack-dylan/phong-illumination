#version 300 es

#define MAX_LIGHTS 16

// struct definitions
struct AmbientLight {
    vec3 color;
    float intensity;
};

struct DirectionalLight {
    vec3 direction;
    vec3 color;
    float intensity;
};

struct PointLight {
    vec3 position;
    vec3 color;
    float intensity;
};

struct Material {
    vec3 kA;
    vec3 kD;
    vec3 kS;
    float shininess;
};


// an attribute will receive data from a buffer
in vec3 a_position;
in vec3 a_normal;

// camera position
uniform vec3 u_eye;

// transformation matrices
uniform mat4x4 u_m;
uniform mat4x4 u_v;
uniform mat4x4 u_p;

// lights and materials
uniform AmbientLight u_lights_ambient[MAX_LIGHTS];
uniform DirectionalLight u_lights_directional[MAX_LIGHTS];
uniform PointLight u_lights_point[MAX_LIGHTS];

uniform Material u_material;

// shading output
out vec4 o_color;

// Shades an ambient light and returns this light's contribution
vec3 shadeAmbientLight(Material material, AmbientLight light) {
    // scale color by intensity
    return light.color * light.intensity * material.kA;
}

// Shades a directional light and returns its contribution
vec3 shadeDirectionalLight(Material material, DirectionalLight light, vec3 normal, vec3 eye, vec3 vertex_position) {
    vec3 light_direction = -normalize(light.direction);
    float lambertian = max(dot(normal, light_direction), 0.0);
    vec3 Id = vec3(material.kD * (light.color * light.intensity) * lambertian);

    vec3 light_reflection = reflect(-light_direction, normal);
    vec3 view = normalize(eye - vertex_position);
    float specularCoef = pow(max(dot(light_reflection, view), 0.0), material.shininess);
    vec3 Is = (light.color * light.intensity) * material.kS * specularCoef;
    return (Id + Is);
}

// Shades a point light and returns its contribution
vec3 shadePointLight(Material material, PointLight light, vec3 normal, vec3 eye, vec3 vertex_position) {

    // TODO: Implement this method
    // Point = I_diffuse + I_specular
    // normal = normalize(normal);
    // tweak intensity according to inverse square law
    float light_distance = distance(vertex_position, light.position);
    float light_intensity = 1.0 / pow(light_distance, 2.0) * light.intensity;
    vec3 light_direction = normalize(light.position - vertex_position);
    float lambertian = max(dot(normal, light_direction), 0.0);
    vec3 Id = vec3(material.kD * (light.color * light_intensity) * lambertian);

    vec3 light_reflection = reflect(-light_direction, normal);
    vec3 view = normalize(eye - vertex_position);
    float specularCoef = pow(max(dot(light_reflection, view), 0.0), material.shininess);
    vec3 Is = (light.color * light_intensity) * material.kS * specularCoef;
    return Id + Is;
}

void main() {

    // TODO: GORAUD SHADING
    // TODO: Implement the vertex stage
    // TODO: Transform positions and normals [into eye space]
    // NOTE: Normals are transformed differently from positions. Check the book and resources.
    gl_PointSize = 2.0f;
    vec3 world_vertex = vec3(u_m * vec4(a_position, 1.0)); // transform vertex
    vec3 world_normal = normalize(vec3(transpose(inverse(u_m)) * vec4(a_normal, 1.0))); // transform normal

    // TODO: Use the above methods to shade every light in the light arrays
    vec3 total = vec3(0, 0, 0);
    for (int i = 0; i < MAX_LIGHTS; i++) {
        vec3 amb = shadeAmbientLight(u_material, u_lights_ambient[i]);
        vec3 dir = shadeDirectionalLight(u_material, u_lights_directional[i], world_normal, u_eye, world_vertex);
        vec3 pnt = shadePointLight(u_material, u_lights_point[i], world_normal, u_eye,world_vertex);
        total += amb + dir + pnt;
    }
    // TODO: Accumulate their contribution and use this total light contribution to pass to o_color

    gl_Position = u_p * u_v * u_m * vec4(a_position, 1.0);
    // TODO: Pass the shaded vertex color to the fragment stage
    o_color = vec4(total, 1.0);
}