#version 460 core

layout(location = 0) in vec3 positions;

uniform mat4 Model;
uniform mat4 Projection;
uniform mat4 View;

void main()
{
    gl_Position = Projection * View * Model * vec4(positions, 1);
}
