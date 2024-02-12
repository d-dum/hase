#version 460 core

layout(location = 0) in vec3 positions;
layout(location = 1) in vec2 uv;

uniform mat4 Model;
uniform mat4 Projection;
uniform mat4 View;

out vec2 UV;

void main()
{
    gl_Position = Projection * View * Model * vec4(positions, 1);
	UV = uv;
}
