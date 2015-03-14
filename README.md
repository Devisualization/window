Devisualization Window Toolkit
===
Window creational toolkit, cross platform. Written in D.<br/>
Depends on Derelict-GL3 for Opengl support.<br/>
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/Devisualization/window?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/Devisualization/window.svg)](https://travis-ci.org/Devisualization/window)

There is currently issues for running within Cygwin on Windows. The window may seem choppy and will not auto flush standard output.
There is no clear cut fix for this at the present time as it is on Cygwin's side.

Features
--------
* Create, Destroy, On draw
* Move, Resize
* Key down/up with modifiers
* Mouse left/right/middle down/up
* Window Icon, Text
* OpenGL (both legacy and 3+) context creation (Windows, X11, OSX (Cocoa))
* Direct3d context creation on windows (untested)
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
* Direct3d abstraction within interfaces?
* On window redisplay(undo of minimise)/maximise/minimise
* Confirm Buffer2d context works on Posix

X11 based window manager weird behaviours:
* Make sure icons work on Posix
* Make sure full screen works correctly on Posix (tempermental on XFCE)
