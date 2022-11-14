#version 300 es

#define MAX_LIGHTS 16

// Fragment shaders don't have a default precision so we need
// to pick one. mediump is a good default. It means "medium precision".
precision mediump float;

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

// lights and materials
uniform AmbientLight u_lights_ambient[MAX_LIGHTS];
uniform DirectionalLight u_lights_directional[MAX_LIGHTS];
uniform PointLight u_lights_point[MAX_LIGHTS];

uniform Material u_material;

// camera position
uniform vec3 u_eye;

// received from vertex stage
// TODO: Create any needed `in` variables here
// TODO: These variables correspond to the `out` variables from the vertex stage
in vec3 position;
in vec3 normal;
in mat4x4 m;
in mat4x4 v;
in mat4x4 p;

// with webgl 2, we now have to define an out that will be the color of the fragment
out vec4 o_fragColor;

// Shades an ambient light and returns this light's contribution
vec3 shadeAmbientLight(Material material, AmbientLight light) {
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

    // TODO: PHONG SHADING
    // TODO: Implement the fragment stage
    // TODO: Use the above methods to shade every light in the light arrays
    // TODO: Accumulate their contribution and use this total light contribution to pass to o_fragColor
    
    vec3 world_vertex = vec3(m * vec4(position, 1.0));
    vec3 world_normal = vec3(transpose(inverse(m)) * vec4(normal, 1.0));
    world_normal = normalize(world_normal);

    vec3 total = vec3(0);
    for (int i = 0; i < MAX_LIGHTS; i++) {
        vec3 amb = shadeAmbientLight(u_material, u_lights_ambient[i]);
        vec3 dir = shadeDirectionalLight(u_material, u_lights_directional[i], world_normal, u_eye, world_vertex);
        vec3 pnt = shadePointLight(u_material, u_lights_point[i], world_normal, u_eye, world_vertex);
        total += amb + dir + pnt;
    }

    // TODO: Pass the shaded vertex color to the output
    o_fragColor = vec4(total, 1.0);
}