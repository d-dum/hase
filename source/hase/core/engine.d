module hase.core.engine;

import hase.core.window_manager : IWindow, HaseWindow;
import hase.core.shader : IShader;
import hase.core.shader_program : IShaderProgram;
import hase.core.renderer : IRenderer, Renderer;

import hase.object.mesh : IMesh;

import bindbc.opengl;
import std.conv : to;

interface IEngine
{
	void engineLoop(void delegate() callback);
	IWindow getWindow();
}

alias Hase = Engine!(HaseWindow, Renderer, 4, 6);

template genGLVersion(int openglMajor, int openglMinor)
{
	const char[] genGLVersion = "GLSupport.gl" ~ to!string(openglMajor) ~ to!string(openglMinor);
}

class Engine(W : IWindow, R:
	IRenderer, int openglMajor, int openglMinor) : IEngine
{
	static assert(openglMajor >= 3 && openglMajor <= 4, "OpenGL major version must be >= 3 and <= 4");
	static assert(openglMinor <= 6 && openglMinor >= 0, "OpenGL minor version must be <= 6 and >= 0");

private:
	W window;
	IShaderProgram mainProgram;
	IShaderProgram[string] programs;
	IRenderer mainRenderer;
public:

	this(int width, int height, string name)
	{
		window = new W(width, height, name);

		GLSupport ret = loadOpenGL();
		if (ret == GLSupport.noLibrary || ret == GLSupport.badLibrary || ret == GLSupport.noContext)
		{
			throw new Exception("Failed to load opengl: " ~ ret.stringof);
		}
		assert(ret == mixin(genGLVersion!(openglMajor, openglMinor)), "Failed to create context of correct version");

		mainRenderer = new R();
	}

	void addProgram(IShaderProgram program, string name, bool main = false)
	{
		programs[name] = program;
		if (main)
		{
			this.mainProgram = program;
		}
	}

	void engineLoop(void delegate() callback)
	{
		while (!window.isCloseRequested())
		{
			window.pollEvents();

			callback();

			window.update();
		}
	}

	void renderObject(IMesh mesh)
	{
		mainRenderer.prepare();
		mainProgram.start();

		mainRenderer.render(mesh);

		mainProgram.stop();
	}

	W getWindow()
	{
		return window;
	}
}
