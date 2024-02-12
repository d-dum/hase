#version 460 core

in vec2 UV;

uniform sampler2D haseSampler;

out vec4 color;

void main()
{
    color = texture(haseSampler, UV).rgba;
}
