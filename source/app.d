import std.stdio;

import hase;

void main()
{
	Hase engine = new Hase(800, 600, "Hase");

	Shader vert = new Shader("res/shaders/vert.glsl", GL_VERTEX_SHADER);
	Shader frag = new Shader("res/shaders/frag.glsl", GL_FRAGMENT_SHADER);

	ShaderProgram program = new ShaderProgram([vert, frag]);

	Texture texture = new Texture(new Image("res/textures/hampurga.png"));
	
	engine.addProgram(program, "mainProgram", true);

	Mesh quad = new Mesh(new Quad);

	Movable!IMesh movableQuad = new Movable!IMesh(quad);

	Textured!(IMovable!IMesh) texturedQuad = new Textured!(IMovable!IMesh)(movableQuad, texture);
	
	engine.addCamera(new Camera(vec3(0, 0, -4), vec3(0, 0, 0)), "mainCamera", true);
	
	
	engine.engineLoop(() { engine.render(texturedQuad); });
}
