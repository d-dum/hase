import std.stdio;

import hase;

void main()
{
	Hase engine = new Hase(800, 600, "Hase");

	Shader vert = new Shader("res/shaders/vert.glsl", GL_VERTEX_SHADER);
	Shader frag = new Shader("res/shaders/frag.glsl", GL_FRAGMENT_SHADER);

	ShaderProgram program = new ShaderProgram([vert, frag]);

	engine.addProgram(program, "mainProgram", true);

	Mesh quad = new Mesh(new Quad);

	Movable!IMesh movableQuad = new Movable!IMesh(quad);
	engine.addCamera(new Camera(vec3(0, 0, -4), vec3(0, 0, 0)), "mainCamera", true);
	
	
	engine.engineLoop(() { engine.renderMovable(movableQuad); });
}
