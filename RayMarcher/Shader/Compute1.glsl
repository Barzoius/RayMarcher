#version 450 core


layout(binding = 0) buffer Vertices {
    vec3 vertices[8];  // Store 8 vertices of a cube
};

void main() {
    // Define the cube's 8 vertices (positions)
    vertices[0] = vec3(-0.5, -0.5, -0.5);
    vertices[1] = vec3(0.5, -0.5, -0.5);
    vertices[2] = vec3(0.5, 0.5, -0.5);
    vertices[3] = vec3(-0.5, 0.5, -0.5);
    vertices[4] = vec3(-0.5, -0.5, 0.5);
    vertices[5] = vec3(0.5, -0.5, 0.5);
    vertices[6] = vec3(0.5, 0.5, 0.5);
    vertices[7] = vec3(-0.5, 0.5, 0.5);
}