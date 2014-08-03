DWC
===

Window creational toolkit, cross platform. Written in D.

Features
--------
* Create, Destroy, On draw
* Move, Resize
* Key down/up with modifiers
* Mouse left/right/middle down/up
* Prevent close
* Window Icon, Text

Example
-------
Custom event loop
```D
import dwc.window;
import std.stdio;

void main() {
	Window window = new Window(800, 600, "My DWC window!"w);
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
* Make sure icons work on Posix
* Make sure full screen works correctly on Posix (tempermental on XFCE)
* Mac OSX
* Context creation
