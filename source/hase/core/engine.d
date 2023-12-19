module hase.core.engine;

import hase.core.window_manager : IWindow, HaseWindow;

interface IEngine
{
    void engineLoop(void function() callback);
    IWindow getWindow();
}

alias Hase = Engine!(HaseWindow);

class Engine(W : IWindow) : IEngine
{
private:
    W window;


public:

    this(int width, int height, string name)
    {
        window = new W(width, height, name);
    }

    void engineLoop(void function() callback)
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
