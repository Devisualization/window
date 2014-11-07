Devisualization Window Toolkit
===

Window creational toolkit, cross platform. Written in D.<br/>
Depends on Derelict-GL3 for Opengl support.

Features
--------
* Create, Destroy, On draw
* Move, Resize
* Key down/up with modifiers
* Mouse left/right/middle down/up
* Window Icon, Text
* OpenGL (both legacy and 3+) creation (Windows, X11, OSX (Cocoa))

Example
-------
Custom event loop
```D
import devisualization.window.window;
import std.stdio;

void main() {
	Window window = new Window(800, 600, "My window!"w);
	window.show();

	window.addOnDraw((Windowable window2) {
		writeln("drawing");
  });

  while(true) {
    import core.thread : Thread;
    import core.time : dur;
    Window.messageLoopIteration();

    if (window.hasBeenClosed)
        break;
    else
        window.onDraw();
    //Thread.sleep(dur!"msecs"(25));
  }
}
```
Thread sleep is optional, as messageLoopIteration is blocking.<br/>
However it should be one draw per x time units. For most efficient loop.

TODO
-----
* Confirm prevent close works on Windows and X11
* Make sure icons work on Posix
* Make sure full screen works correctly on Posix (tempermental on XFCE)
* Context creation (Direct3D on Windows)
* On window redisplay(undo of minimise)/maximise/minimise
