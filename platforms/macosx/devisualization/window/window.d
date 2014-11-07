/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Devisualization (Richard Andrew Cattermole)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
module devisualization.window.window;
import devisualization.window.context;
import devisualization.window.interfaces.window;
import devisualization.window.interfaces.eventable;
public import devisualization.window.interfaces.window : WindowConfig, Windowable;
public import devisualization.window.interfaces.events : MouseButtons, Keys, KeyModifiers;
public import devisualization.window.interfaces.context : WindowContextType, IContext;
import std.conv : to;

class Window : Windowable {
	private {
	    int cocoaId;
        bool hasBeenClosed_;
        IContext context_;
        
        ubyte* iconImageData_;
	}

	this(T...)(T config) { this(WindowConfig(config)); } 

	this(WindowConfig config) {
		synchronized {
		    if (!hasBeenSetup) {
		        cocoaInit();
		        hasBeenSetup = true;
		    }
		    
		    string titleValue = to!string(config.title) ~ "\0";
		    cocoaId = cocoaCreateWindow(CocoaWindowData(config.x, config.y, config.width, config.height, cast(char*)&titleValue[0]));
			dispToInsts[cocoaId] = this;
		}

        if ((config.contextType | WindowContextType.Opengl3Plus) || (config.contextType | WindowContextType.OpenglLegacy)) {
            // create Opengl context!
            context_ = new OpenglContext(this, config, cocoaId);
        } else if (config.contextType == WindowContextType.Direct3D) {
            // create Direct3d context!
            throw new Exception("Cannot create Direct3D context on non Windows targets");
        }
    }
	
	static {
		void messageLoop() {
			import core.thread : Thread;
			import core.time : dur;
			
			while(true) {
                Window.messageLoopIteration();
				Thread.sleep(dur!"msecs"(250));
			}
		}
		
		void messageLoopIteration() {
            cocoaRunLoopIterate();
		}
	}
	
	@property {		
		void title(string value)
        in {
            assert(!hasBeenClosed_);
        } body {
			cocoaSetTitle(cocoaId, cast(char*)(value ~ "\0").ptr);
		}
		
		void title(dstring value)
        in {
            assert(!hasBeenClosed_);
        } body {
			title(to!string(value));
		}
		
		void title(wstring value)
        in {
            assert(!hasBeenClosed_);
        } body {
			title(to!string(value));
		}
		
		void size(uint width, uint height)
        in {
            assert(!hasBeenClosed_);
        } body {
			cocoaSetSize(cocoaId, width, height);
		}
		
		void move(int x, int y)
        in {
            assert(!hasBeenClosed_);
        } body {
			cocoaSetPosition(cocoaId, x, y);
		}
		
        void canResize(bool can = true)
        in {
            assert(!hasBeenClosed_);
        } body {
			cocoaCanResize(cocoaId, cast(uint)can);
		}
		
		void fullscreen(bool isfs = true)
        in {
            assert(!hasBeenClosed_);
        } body {
            cocoaFullScreen(cocoaId, cast(int)isfs);
		}

        void close()
        in {
            assert(!hasBeenClosed_);
        } body {
            synchronized {
                dispToInsts.remove(cocoaId);
            }
            cocoaCloseWindow(cocoaId);
            hasBeenClosed_ = true;
        }

        IContext context()
        in {
            assert(!hasBeenClosed_);
        } body {
            return context_;
        }

        bool hasBeenClosed() { return hasBeenClosed_; }
	}
	
	override {
		void show()
        in {
            assert(!hasBeenClosed_);
        } body {
			cocoaShowWindow(cocoaId);
		}
		
		void hide()
        in {
            assert(!hasBeenClosed_);
        } body {
			cocoaHideWindow(cocoaId);
		}

		void icon(ushort width, ushort height, ubyte[3][] idata, ubyte[3]* transparent = null)
		in {
            assert(!hasBeenClosed_);
			assert(width * height == data.length, "Icon pixels length must be equal to width * height");
		} body {
		    import core.memory;
		
    		GC.free(iconImageData_);
    		iconImageData_ = cast(ubyte*)GC.malloc(width * height * 4);
    		
    		size_t done = 0;
    		
            foreach(datem; idata) {
                iconImageData_[done + 0] = datem[0];
                iconImageData_[done + 1] = datem[1];
                iconImageData_[done + 2] = datem[2];
                          
                if (transparent !is null &&
                    datem[0] == (*transparent)[0] &&
                    datem[1] == (*transparent)[1] &&
                    datem[2] == (*transparent)[2]) {
                    iconImageData_[done + 3] = 0;
                } else {
                    iconImageData_[done + 3] = 255;
                }
                
                done += 4;
            }

            cocoaSetIcon(cocoaId, &iconImageData_, width, height);
		}
	}
	
	mixin Eventing!("onDraw", Windowable);
	mixin Eventing!("onMove", Windowable, int, int);
    mixin Eventing!("onResize", Windowable, uint, uint);
    mixin Eventing!("onClose", Windowable);

    mixin Eventing!("onMouseDown", Windowable, MouseButtons, int, int);
    mixin Eventing!("onMouseMove", Windowable, int, int);
    mixin Eventing!("onMouseUp", Windowable, MouseButtons);
    mixin Eventing!("onKeyDown", Windowable, Keys, KeyModifiers);
    mixin Eventing!("onKeyUp", Windowable, Keys, KeyModifiers);
}

private {
    Window[int] dispToInsts;
    bool hasBeenSetup;
    
    extern(C) {
        struct CocoaWindowData {
            int x;
            int y;
            int width;
            int height;
            char* title;
        }
    
        void cocoaInit();
        int cocoaCreateWindow(CocoaWindowData data);
        int cocoaRunLoopIterate();
        void cocoaSetTitle(int window, char* title);
        void cocoaSetSize(int window, int width, int height);
        void cocoaSetPosition(int window, int x, int y);
        void cocoaCanResize(int window, int can);
        void cocoaFullScreen(int id, int is_);
        void cocoaCloseWindow(int window);
        void cocoaShowWindow(int window);
        void cocoaHideWindow(int window);
        void cocoaSetIcon(int window, ubyte** rgba, int width, int height);
        
        void cocoaEventMouseDown(int window, MouseButtons button, float x, float y) {
            dispToInsts[window].onMouseDown(button, cast(int)x, cast(int)y);
        }
        
        void cocoaEventMouseUp(int window, MouseButtons button, float x, float y) {
            dispToInsts[window].onMouseUp(button);
        }
        
        void cocoaEventMouseMove(int window, float x, float y) {
            dispToInsts[window].onMouseMove(cast(int)x, cast(int)y);
        }
        
        void cocoaEventOnClose(int window) {
            dispToInsts[window].onClose();
        }
        
        void cocoaEventOnResize(int window, int width, int height) {
            dispToInsts[window].onResize(width, height);
        }
        
        void cocoaEventOnMove(int window, int x, int y) {
            dispToInsts[window].onMove(x, y);
        }
        
        void cocoaEventOnKeyDown(int window, ubyte modifiers, Keys key) {
            dispToInsts[window].onKeyDown(key, cast(KeyModifiers)modifiers);
        }
        
        void cocoaEventOnKeyUp(int window, ubyte modifiers, Keys key) {
            dispToInsts[window].onKeyUp(key, cast(KeyModifiers)modifiers);
        }
        
        void cocoaEventForceRedraw(int window) {
            dispToInsts[window].onDraw();
        }
    }
}