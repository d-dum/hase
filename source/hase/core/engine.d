module hase.core.engine;

import hase.core.window_manager : IWindow, HaseWindow;
import hase.core.shader : IShader;
import hase.core.shader_program : IShaderProgram, Uniform;
import hase.core.renderer : IRenderer, Renderer;

import hase.object.camera : ICamera;
import hase.object.movable : IMovable;
import hase.object.mesh : IMesh;

import bindbc.opengl;

import std.conv : to;
import std.typecons : Nullable;

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

	ICamera[string] cameras;
	ICamera mainCamera;

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

		mainRenderer = new R(45.0, height, width, 0.1, 100.0);
	}

	void addProgram(IShaderProgram program, string name, bool main = false)
	{
		programs[name] = program;
		if (main)
		{
			this.mainProgram = program;
		}
	}

	void addCamera(ICamera camera, string name, bool main = false)
	{
		cameras[name] = camera;

		if (main)
		{
			mainCamera = camera;
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

	IShaderProgram prepareRenderer(Nullable!string program_name = Nullable!string())
	{
		IShaderProgram program;
		if (program_name.isNull())
		{
			program = mainProgram;
		}
		else
		{
			debug
			{
				if ((program_name.get() in programs) is null)
				{
					throw new Exception("Program not found");
				}
			}

			program = programs[program_name.get()];
		}

		program.start();

		Nullable!Uniform projectionLocation = program.getUniformLocation("Projection");
		debug
		{
			if (projectionLocation.isNull())
			{
				throw new Exception("Failed to get Projection location");
			}
		}

		Nullable!Uniform viewLocation = program.getUniformLocation("View");
		debug
		{
			if (viewLocation.isNull())
			{
				throw new Exception("Failed to get View location");
			}
		}

		projectionLocation.get().load(mainRenderer.getProjection());
		viewLocation.get().load(mainCamera.getView());

		program.stop();

		return program;
	}

	void renderMovable(IMovable!IMesh movable, Nullable!string programName = Nullable!string())
	{
		IShaderProgram program = prepareRenderer(programName);

		program.start();

		Nullable!Uniform mvpLocation = program.getUniformLocation("Model");
		debug
		{
			if (mvpLocation.isNull())
			{
				throw new Exception("Failed to get Model uniform location");
			}
		}

		mvpLocation.get().load(movable.getModel());

		program.stop();

		renderObject(movable.getObject());
	}

	W getWindow()
	{
		return window;
	}
}
