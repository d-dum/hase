import std.stdio;

import hase;

alias Display = Window!(4, 6);

void main()
{
	Display window = new Display(800, 600, "hase");

	while(!window.isCloseRequested())
	{
		window.pollEvents();
		window.update();
	}
}
