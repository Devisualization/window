module test.main;
import devisualization.window.window;
import std.stdio;

void main() {
	Window window = new Window(800, 600, "My DWC window!"w, 100, 100, WindowContextType.OpenglLegacy);
	window.show();
	
	window.size(200, 200);
    window.move(200, 200);

	window.addOnDraw((Windowable window2) {
		//writeln("drawing");

		Window window = cast(Window)window2;
        IContext context = window.context;
        if (context !is null) {
            writeln("has context");
            writeln("type: ", context.type);
            writeln("toolkit version: ", context.toolkitVersion);
            writeln("shading language version: ", context.shadingLanguageVersion);
        } else {
            //writeln("has not got context");
        }
		version(Windows) {
            if (context !is null && context.type == WindowContextType.Opengl) {
                import derelict.opengl3.gl;
                glLoadIdentity();
                glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
                glColor3f(0f, 1f, 0f);

                glBegin(GL_TRIANGLES);
                glVertex2f(-100, -100);
                glVertex2f(100, -100);
                glVertex2f(100, 100);

                glVertex2f(-100, -100);
                glVertex2f(-100, 100);
                glVertex2f(100, 100);
                glEnd();
            } else if (context !is null && context.type == WindowContextType.Direct3D) {
            } else {
            }
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
		} else version(OSX) {
		    if (context !is null && context.type == WindowContextType.Opengl) {
                import derelict.opengl3.gl;
                glLoadIdentity();
                glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
                glColor3f(0f, 1f, 0f);

                glBegin(GL_TRIANGLES);
                glVertex2f(-100, -100);
                glVertex2f(100, -100);
                glVertex2f(100, 100);

                glVertex2f(-100, -100);
                glVertex2f(-100, 100);
                glVertex2f(100, 100);
                glEnd();
            }
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
    
    //window.canResize = false;

	window.icon(2, 2, [[255, 0, 0], [0, 255, 0], [0, 0, 255], [0, 0, 0]], cast(ubyte[3]*)[255, 0, 0].ptr);
   
    window.fullscreen(true);

	//Window.messageLoop();
    while(true) {
        import core.thread : Thread;
        import core.time : dur;
        Window.messageLoopIteration();

        if (window.hasBeenClosed)
            break;
        else {
            window.onDraw();
            if (window.context !is null)
                window.context.swapBuffers();
        }
        Thread.sleep(dur!"msecs"(25));
    }
}