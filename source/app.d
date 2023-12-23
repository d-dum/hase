import std.stdio;

import hase;


void main()
{
	Hase engine = new Hase(800, 600, "Hase");

	Shader vert = new Shader("res/shaders/vert.glsl", GL_VERTEX_SHADER);
	Shader frag = new Shader("res/shaders/frag.glsl", GL_FRAGMENT_SHADER);

	ShaderProgram program = new ShaderProgram([vert, frag]);

	engine.engineLoop(() {
		program.start();

		program.stop();
	});
}
