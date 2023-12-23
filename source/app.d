import std.stdio;

import hase;


void main()
{
	Hase engine = new Hase(800, 600, "Hase");

	Shader shader = new Shader("res/shaders/vert.glsl", GL_VERTEX_SHADER);

	engine.engineLoop(() {

	});
}
