Devisualization Window Toolkit
===
Window creational toolkit, cross platform. Written in D.<br/>
Depends on Derelict-GL3 for Opengl support.<br/>
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/Devisualization/window?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/Devisualization/window.svg)](https://travis-ci.org/Devisualization/window)

Features
--------
* Create, Destroy, On draw
* Move, Resize
* Key down/up with modifiers
* Mouse left/right/middle down/up
* Window Icon, Text
* OpenGL (both legacy and 3+) creation (Windows, X11, OSX (Cocoa))
* 2D image buffer drawing context

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
Thread sleep is optional, as messageLoopIteration is blocking but may not wait for a message.<br/>
However it should be one draw per x time units. For most efficient loop.
During the drawing, check if you have a valid context. OnDraw may occur while there is no valid context.

TODO
-----
* Confirm prevent close works on Windows and X11
* Context creation (Direct3D on Windows)
* On window redisplay(undo of minimise)/maximise/minimise
* Confirm Buffer2d context works on Posix
* Implement Buffer2d context on OSX

X11 based window manager weird behaviours:
* Make sure icons work on Posix
* Make sure full screen works correctly on Posix (tempermental on XFCE)