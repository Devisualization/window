module test.main;
import dwc.window;
import std.stdio;

void main() {
	Window window = new Window(800, 600, "My DWC window!"w);
	window.show();
	
	window.move(200, 200);
	window.size(200, 200);

	window.addOnDraw((Windowable window2) {
		writeln("drawing");
		
		Window window = cast(Window)window2;

		version(Windows) {
			import windows;
			PAINTSTRUCT ps;
			BeginPaint(window.hwnd, &ps);
			FillRect(ps.hdc, &ps.rcPaint, cast(HBRUSH)(COLOR_HOTLIGHT+1));
			EndPaint(window.hwnd, &ps);
		} else version(linux) {
			import xlib = x11.Xlib;
			import xx11 = x11.X;
			
			xlib.Window root;
			int x, y;
			uint width, height, border, depth;
			
			auto x11Window = window.x11Window;
			auto x11Display = window.x11Display;
			auto x11Screen = window.x11Window;
			auto x11ScreenNumber = window.x11ScreenNumber;
			
			xlib.XGetGeometry(x11Display, x11Window, &root, &x, &y, &width, &height, &border, &depth);
			
			xlib.GC gc;
			xlib.XColor color;
			xlib.Colormap colormap;
			
			colormap = xlib.DefaultColormap(x11Display, x11ScreenNumber);
			gc = xlib.XCreateGC(x11Display, x11Window, 0, null);
			
			xlib.XParseColor(x11Display, colormap, cast(char*)"#777777\0".ptr, &color);
			xlib.XAllocColor(x11Display, colormap, &color);
			
			xlib.XSetForeground(x11Display, gc, color.pixel);
			
			xlib.XFillRectangle(window.x11Display, window.x11Window, gc, 0, 0, width, height);
			
			xlib.XFreeGC(x11Display, gc);
		}
	});
	
	window.addOnMove((Windowable window, int x, int y) {
		writeln("move: ", x, ", ", y);
	});
	
	window.addOnResize((Windowable window, uint width, uint height) {
		writeln("resize: ", width, " x ", height);
	});
	
    window.addOnMouseDown((Windowable window, MouseButtons button, int x, int y) {
        writeln("mouse down ", button, " x=", x, ", y=", y);
    });

    window.addOnMouseMove((Windowable window, int x, int y) {
        writeln("mouse move x=", x, ", y=", y);
    });

    window.addOnMouseUp((Windowable window, MouseButtons button) {
        writeln("mouse up ", button);
    });

    window.addOnKeyDown((Windowable window, Keys key, KeyModifiers modifiers) {
        writeln("key down ", key, " modifiers ", modifiers);
    });

    window.addOnKeyUp((Windowable window, Keys key, KeyModifiers modifiers) {
        writeln("key up ", key, " modifiers ", modifiers);
    });

    window.addOnClose((Windowable window) {
        writeln("close");
        window.close();
    });
    
    window.canResize = false;

	window.icon(2, 2, [[255, 0, 0], [0, 255, 0], [0, 0, 255], [0, 0, 0]], cast(ubyte[3]*)[255, 0, 0].ptr);
   
    //window.fullscreen();

	//Window.messageLoop();
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