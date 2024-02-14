module hase.core.engine;

import hase.core.window_manager : IWindow, HaseWindow;
import hase.core.shader : IShader;
import hase.core.shader_program : IShaderProgram, Uniform;
import hase.core.renderer : IRenderer, Renderer;

import hase.object.camera : ICamera;
import hase.object.movable : IMovable;
import hase.object.mesh : IMesh;
import hase.object.textured : ITextured;
import hase.object.general_object : IGeneralObject;

import bindbc.opengl;

import std.conv : to;
import std.typecons : Nullable;

interface IEngine
{
	void engineLoop(void delegate() callback);
	IWindow getWindow();
	IShaderProgram prepareRenderer(Nullable!string program_name = Nullable!string(),
		Nullable!IShaderProgram shaderProgram = Nullable!IShaderProgram());
	void render(O)(IMovable!O movable, Nullable!IShaderProgram shaderProgram = Nullable!IShaderProgram(),
		Nullable!string programName = Nullable!string());
	void render(IMesh mesh, Nullable!IShaderProgram shaderProgram = Nullable!IShaderProgram(),
		Nullable!string programName = Nullable!string());
	void render(O)(ITextured!O textured, Nullable!IShaderProgram shaderProgram = Nullable!IShaderProgram(),
		Nullable!string programName = Nullable!string());
	void addCamera(ICamera camera, string name, bool main = false);
	void addProgram(IShaderProgram program, string name, bool main = false);
}

alias Hase = Engine!(HaseWindow, Renderer, 4, 6);

GLenum[] textureIndex = [GL_TEXTURE0];

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

	IShaderProgram mainProgram = null;
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

	void render(IMesh mesh, Nullable!IShaderProgram shaderProgram = Nullable!IShaderProgram(),
		Nullable!string programName = Nullable!string())
	{
		IShaderProgram program = mainProgram;
		if (!programName.isNull())
		{
			Nullable!IShaderProgram prg = getProgram(programName);
			if (!prg.isNull())
			{
				program = prg.get();
			}
		}
		else if (!shaderProgram.isNull())
		{
			program = shaderProgram.get();
		}

		mainRenderer.prepare();
		program.start();

		mainRenderer.render(mesh);

		program.stop();
	}

	IShaderProgram prepareRenderer(Nullable!string program_name = Nullable!string(),
		Nullable!IShaderProgram shaderProgram = Nullable!IShaderProgram())
	{
		IShaderProgram program;
		if (!shaderProgram.isNull())
		{
			program = shaderProgram.get();
		}
		else if (program_name.isNull())
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

	void render(O)(IMovable!O movable, Nullable!IShaderProgram shaderProgram = Nullable!IShaderProgram(),
		Nullable!string programName = Nullable!string())
	{

		IShaderProgram program = prepareRenderer(programName, shaderProgram);

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

		render(movable.getObject(), Nullable!IShaderProgram(program));
	}

	Nullable!IShaderProgram getProgram(Nullable!string programName = Nullable!string())
	{
		if (programName.isNull())
		{
			if (mainProgram is null)
			{
				return Nullable!IShaderProgram();
			}
			return Nullable!IShaderProgram(mainProgram);
		}

		string name = programName.get();
		if ((name in programs) is null)
		{
			return Nullable!IShaderProgram();
		}

		return Nullable!IShaderProgram(programs[name]);
	}

  Nullable!IMesh getRenderableObject(O)(O obj)
	{
		if (cast(IMesh) obj.getObject())
		{
			return Nullable!IMesh(obj.getObject());
		}
		else if (obj.getObject)
		{
			return getRenderableObject(obj);
		}

		return Nullable!IMesh();

	}

	void render(O)(ITextured!O textured, Nullable!IShaderProgram shaderProgram = Nullable!IShaderProgram(),
		Nullable!string programName = Nullable!string(),
	)
	{
		Nullable!IShaderProgram program = shaderProgram.isNull() ? getProgram(programName)
			: shaderProgram;
		if (program.isNull())
		{
			debug
			{
				throw new Exception("program not found");
			}
			return;
		}

		if (!textured.getTexture().isLoaded())
		{
			debug
			{
				throw new Exception("texture failed to load");
			}
			return;
		}

		Nullable!IMesh renderableObject = getRenderableObject(textured.getObject());
		
		if (renderableObject.isNull())
		{
			debug
			{
				throw new Exception("nothing to render");
			}
			return;
		}

		IMesh mesh = renderableObject.get();
		glBindVertexArray(mesh.getVao());

		program.get().start();

		
		glBindVertexArray(mesh.getVao());

		
		Nullable!Uniform textureSampler = program.get()
			.getUniformLocation(textured.getTexture().getUniformName());

		if (textureSampler.isNull())
		{
			debug
			{
			  throw new Exception("Failed to get texture sampler location: " ~ textured.getTexture().getUniformName());
			}
			return;
		}

		glActiveTexture(textureIndex[textured.getTexture().getTextureIndex()]);
		glBindTexture(GL_TEXTURE_2D, textured.getTexture().getTextureID());
		textureSampler.get().load(textured.getTexture().getTextureIndex());
		program.get().stop();

		render(textured.getObject(),
			program);
	}

	W getWindow()
	{
		return window;
	}
}
