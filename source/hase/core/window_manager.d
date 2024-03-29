module hase.core.window_manager;

import bindbc.sdl;
private import loader = bindbc.loader.sharedlib;

interface IWindow
{
	SDL_Window* getWindow();
	int[2] getDimensions();
	void pollEvents();
	bool isCloseRequested();
	void update();
}

alias HaseWindow = Window!(4, 6);

class Window(int openglMajor, int openglMinor) : IWindow
{
	static assert(openglMajor >= 3 && openglMajor <= 4, "OpenGL major version must be >= 3 and <= 4");
	static assert(openglMinor <= 6 && openglMinor >= 0, "OpenGL minor version must be <= 6 and >= 0");

private:
	int width, height;
	SDL_Window* window;
	SDL_GLContext context;
	bool closeRequested = false;

public:
	this(int width, int height, string name)
	{
		import std.stdio : writeln;

		immutable SDLSupport ret = loadSDL();
		loadSDLImage();

		if (ret != sdlSupport)
		{
			if (ret == SDLSupport.noLibrary)
			{
				throw new Exception("Failed to load SDL");
			}
			else if (ret == SDLSupport.badLibrary)
			{
				throw new Exception("Wrong sdl version");
			}
		}
		SDL_Init(SDL_INIT_EVERYTHING);
		this.width = width;
		this.height = height;

		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, openglMajor);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, openglMinor);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

		window = SDL_CreateWindow(name.ptr, cast(int) SDL_WINDOWPOS_CENTERED, cast(int) SDL_WINDOWPOS_CENTERED, width,
			height, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);

		if (window == null)
		{
			throw new Exception("Failed to create window");
		}

		context = SDL_GL_CreateContext(window);
		if (context == null)
		{
			throw new Exception("Failed to create opengl context");
		}

	}

	int[2] getDimensions()
	{
		return [width, height];
	}

	SDL_Window* getWindow()
	{
		return window;
	}

	void pollEvents()
	{
		SDL_Event e;
		while (SDL_PollEvent(&e) != 0)
		{
			if (e.type == SDL_QUIT)
			{
				closeRequested = true;
			}
		}
	}

	void update()
	{
		SDL_GL_SwapWindow(window);
	}

	bool isCloseRequested()
	{
		return closeRequested;
	}

	~this()
	{
		IMG_Quit();
		SDL_GL_DeleteContext(context);
		SDL_DestroyWindow(window);
		SDL_Quit();
	}
}
