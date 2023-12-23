module hase.core.engine;

import hase.core.window_manager : IWindow, HaseWindow;

import bindbc.opengl;
import std.conv : to;

interface IEngine
{
    void engineLoop(void delegate() callback);
    IWindow getWindow();
}

alias Hase = Engine!(HaseWindow, 4, 6);

template GenGLVersion(int openglMajor, int openglMinor)
{
    const char[] GenGLVersion = "GLSupport.gl" ~ to!string(openglMajor) ~ to!string(openglMinor);
}

class Engine(W : IWindow, int openglMajor, int openglMinor) : IEngine
{
    static assert(openglMajor >= 3 && openglMajor <= 4, "OpenGL major version must be >= 3 and <= 4");
    static assert(openglMinor <= 6 && openglMinor >= 0, "OpenGL minor version must be <= 6 and >= 0");

private:
    W window;


public:

    this(int width, int height, string name)
    {
        window = new W(width, height, name);

        GLSupport ret = loadOpenGL();
        if(ret == GLSupport.noLibrary || ret == GLSupport.badLibrary || ret == GLSupport.noContext)
        {
            throw new Exception("Failed to load opengl: " ~ ret.stringof);
        }
        assert(ret == mixin(GenGLVersion!(openglMajor, openglMinor)), "Failed to create context of correct version");

    }

    void engineLoop(void delegate() callback)
    {
        while(!window.isCloseRequested())
        {
            window.pollEvents();

            callback();

            window.update();
        }
    }

    W getWindow()
    {
        return window;
    }
}
