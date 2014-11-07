module dwc.window;
import dwc.context;
import dwc.interfaces.window;
import dwc.interfaces.eventable;
public import dwc.interfaces.window : WindowConfig, Windowable;
public import dwc.interfaces.events : MouseButtons, Keys, KeyModifiers;
public import dwc.interfaces.context : WindowContextType, IContext;
import std.conv : to;

private {
    import xlib = x11.Xlib;
    import xx11 = x11.X;
    import xutil = x11.Xutil;
    import xrandr = x11.extensions.Xrandr;
}

class Window : Windowable {
	private {
		xlib.Window wind_;
		int screen_;
		
		string lastTitle;
		
		int lastX, lastY, lastWidth, lastHeight;
        xrandr.SizeID oldVideoMode;

        bool hasBeenClosed_;
        xlib.Atom closeAtom_;

        IContext context_;
	}

	this(T...)(T config) { this(WindowConfig(config)); } 

	this(WindowConfig config) {
		lastX = config.x;
		lastY = config.y;
		lastWidth = config.width;
		lastHeight = config.height;
        wind_ = createWindow(config.x, config.y, config.width, config.height, screen_, closeAtom_);
		synchronized {
			dispToInsts[wind_] = this;
		}
		
		title = config.title;

        if ((config.contextType | WindowContextType.Opengl3Plus) || (config.contextType | WindowContextType.OpenglLegacy)) {
            // create Opengl context!
            context_ = new OpenglContext(this, config);
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
			xlib.XEvent e;
			
			xlib.XNextEvent(display_, &e);
			if (e.type == xx11.Expose) {
				if (e.xexpose.window in dispToInsts) {
					Window window = dispToInsts[e.xexpose.window];
                    if (!window.hasBeenClosed_)
					    window.onDraw();
				}
			} else if (e.type == xx11.ConfigureNotify) {
				if (e.xconfigure.window in dispToInsts) {
					Window window = dispToInsts[e.xconfigure.window];

                    if (!window.hasBeenClosed_) {
    					if (window.lastX != e.xconfigure.x || window.lastY != e.xconfigure.y) {
    						window.onMove(e.xconfigure.x, e.xconfigure.y);
    						window.lastX = e.xconfigure.x;
    						window.lastY = e.xconfigure.y;
    					}
    					
    					if (window.lastWidth != e.xconfigure.width || window.lastHeight != e.xconfigure.height) {
                            uint w = e.xconfigure.width;
                            uint h = e.xconfigure.height;
                            window.onResize(w, h);
    						window.lastWidth = e.xconfigure.width;
    						window.lastHeight = e.xconfigure.height;
    					}
                    }
				}
            } else if (e.type == xx11.ClientMessage) {
                if (e.xclient.window in dispToInsts) {
                    Window window = dispToInsts[e.xclient.window];
                    if (!window.hasBeenClosed_) {
                        if (e.xclient.format == 32 && e.xclient.data.l[0] == window.closeAtom_) {
                            window.onClose();
                            if (window.countOnClose() == 0)
                                window.close();
                        }
                    }
                }
            } else if (e.type == xx11.MotionNotify) {
                if (e.xmotion.window in dispToInsts) {
                    Window window = dispToInsts[e.xmotion.window];
                    if (!window.hasBeenClosed_) {
                        window.onMouseMove(e.xmotion.x, e.xmotion.y);
                    }
                }
            } else if (e.type == xx11.ButtonPress) {
                if (e.xbutton.window in dispToInsts) {
                    Window window = dispToInsts[e.xbutton.window];
                    if (!window.hasBeenClosed_) {
                        MouseButtons button;

                        switch(e.xbutton.button) {
                            case xx11.Button2:
                                button = MouseButtons.Middle;
                                break;

                            case xx11.Button3:
                                button = MouseButtons.Right;
                                break;

                            case xx11.Button1:
                            default:
                                button = MouseButtons.Left;
                                break;
                        }

                        window.onMouseDown(button, e.xbutton.x, e.xbutton.y);
                    }
                }
            } else if (e.type == xx11.ButtonRelease) {
                if (e.xbutton.window in dispToInsts) {
                    Window window = dispToInsts[e.xbutton.window];
                    if (!window.hasBeenClosed_) {
                        MouseButtons button;
                        
                        switch(e.xbutton.button) {
                            case xx11.Button2:
                                button = MouseButtons.Middle;
                                break;
                                
                            case xx11.Button3:
                                button = MouseButtons.Right;
                                break;
                                
                            case xx11.Button1:
                            default:
                                button = MouseButtons.Left;
                                break;
                        }
                        
                        window.onMouseUp(button);
                    }
                }
            } else if (e.type == xx11.KeyPress) {
                if (e.xkey.window in dispToInsts) {
                    Window window = dispToInsts[e.xkey.window];
                    if (!window.hasBeenClosed_) {
                        xlib.KeySym symbol;
                        xutil.XLookupString(cast(xlib.XKeyEvent*)(&e.xkey), null, 0, &symbol, null);
                        window.onKeyDown(convertKeyFromXlibEvent(cast(uint)symbol), convertKeyFromXlibEventModifiers(e.xkey.state));
                    }
                }
            } else if (e.type == xx11.KeyRelease) {
                if (e.xkey.window in dispToInsts) {
                    Window window = dispToInsts[e.xkey.window];
                    if (!window.hasBeenClosed_) {
                        xlib.KeySym symbol;
                        xutil.XLookupString(cast(xlib.XKeyEvent*)(&e.xkey), null, 0, &symbol, null);
                        window.onKeyUp(convertKeyFromXlibEvent(cast(uint)symbol), convertKeyFromXlibEventModifiers(e.xkey.state));
                    }
                }
            }
		}
	}
	
	@property {
		xlib.Window x11Window()
        in {
            assert(!hasBeenClosed_);
        } body {
			return wind_;
		}
		
		xlib.Display* x11Display()
        in {
            assert(!hasBeenClosed_);
        } body {
			return display_;
		}
		
		int x11ScreenNumber()
        in {
            assert(!hasBeenClosed_);
        } body {
			return screen_;
		}
		
		xlib.Screen* x11Screen()
        in {
            assert(!hasBeenClosed_);
        } body {
			return xlib.XScreenOfDisplay(display_, screen_);
		}
		
		void title(string value)
        in {
            assert(!hasBeenClosed_);
        } body {
			lastTitle = value;
			xlib.XStoreName(display_, wind_, cast(char*)lastTitle.ptr);
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
			xlib.XResizeWindow(display_, wind_, width, height);
			xlib.XFlush(display_);
		}
		
		void move(int x, int y)
        in {
            assert(!hasBeenClosed_);
        } body {
			xlib.XMoveWindow(display_, wind_, x, y);
			xlib.XFlush(display_);
		}
		
        void canResize(bool can = true)
        in {
            assert(!hasBeenClosed_);
        } body {
			WMHints hints;
			hints.Flags = MWM_HINTS_FUNCTIONS | MWM_HINTS_DECORATIONS;
			hints.Decorations = MWM_DECOR_TITLE;
			hints.Functions = MWM_FUNC_MOVE | MWM_FUNC_CLOSE | MWM_FUNC_MINIMIZE;
			
			if (can) {
				hints.Decorations |= MWM_DECOR_MAXIMIZE | MWM_DECOR_RESIZEH | MWM_DECOR_BORDER | MWM_DECOR_MINIMIZE;
				hints.Functions |= MWM_FUNC_MAXIMIZE | MWM_FUNC_RESIZE;
			}
			
			xlib.Atom windowHints = xlib.XInternAtom(display_, cast(char*)"_MOTIF_WM_HINTS\0".ptr, false);
			xlib.XChangeProperty(display_, wind_, windowHints, windowHints, 32, xx11.PropModeReplace, cast(ubyte*)&hints, 5);
		}
		
        /**
         * Tempermental inside Virtualbox with XFCE
         */
		void fullscreen(bool isfs = true)
        in {
            assert(!hasBeenClosed_);
        } body {
            if (isfs) {
                xrandr.XRRScreenConfiguration* config = xrandr.XRRGetScreenInfo(display_, xlib.RootWindow(display_, screen_));
                
                xrandr.Rotation currentRotation;
                oldVideoMode = xrandr.XRRConfigCurrentConfiguration(config, &currentRotation);
                
                int nbSizes;
                xrandr.XRRScreenSize* sizes = xrandr.XRRConfigSizes(config, &nbSizes);
                for (int i = 0; i < nbSizes; i++) {
                    if (sizes[i].width == lastWidth && sizes[i].height == lastHeight) {
                        xrandr.XRRSetScreenConfig(display_, config,xlib. RootWindow(display_, screen_), i, currentRotation, xx11.CurrentTime);
                        break;
                    }
                }
                
                xrandr.XRRFreeScreenConfigInfo(config);
            } else {
                xrandr.XRRScreenConfiguration* config = xrandr.XRRGetScreenInfo(display_, xlib.RootWindow(display_, screen_));
                xrandr.Rotation currentRotation;
                xrandr.XRRConfigCurrentConfiguration(config, &currentRotation);
                xrandr.XRRSetScreenConfig(display_, config, xlib.RootWindow(display_, screen_), oldVideoMode, currentRotation, xx11.CurrentTime);
                xrandr.XRRFreeScreenConfigInfo(config);
            }
		}

        void close()
        in {
            assert(!hasBeenClosed_);
        } body {
            hide();
            synchronized {
                dispToInsts.remove(wind_);
            }
            xlib.XDestroyWindow(display_, wind_);
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
			xlib.XMapWindow(display_, wind_);
		}
		
		void hide()
        in {
            assert(!hasBeenClosed_);
        } body {
			xlib.XUnmapWindow(display_, wind_);
		}

        /**
         * Don't think this works. Atleast not in XFCE
         */
		void icon(ushort width, ushort height, ubyte[3][] idata, ubyte[3]* transparent = null)
		in {
            assert(!hasBeenClosed_);
			assert(width * height == data.length, "Icon pixels length must be equal to width * height");
		} body {
            uint[] imageData;
            imageData ~= (height << 16) | width;

            foreach(datem; idata) {
               imageData ~= (datem[0]) | (datem[1] << 8) | (datem[2] << 16) | (0 << 24);
            }

            int length = 2 + (width * height);
            xlib.Atom net_wm_icon = xlib.XInternAtom(display_, cast(char*)"_NET_WM_ICON\0".ptr, cast(int)false);
            xlib.Atom cardinal = xlib.XInternAtom(display_, cast(char*)"CARDINAL\0".ptr, cast(int)false);
            xlib.XChangeProperty(display_, wind_, net_wm_icon, cardinal, 32, xx11.PropModeReplace, cast(ubyte*)imageData.ptr, length);
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
	Window[xlib.Window] dispToInsts;
	xlib.Display* display_;
	
	struct WMHints {
		ulong Flags;
		ulong Functions;
		ulong Decorations;
		long InputMode;
		ulong State;
	}
	
	enum MWM_HINTS_FUNCTIONS = 1 << 0;
	enum MWM_HINTS_DECORATIONS = 1 << 1;
    enum MWM_HINTS_INPUT_MODE  = 1 << 2;

	enum MWM_DECOR_BORDER = 1 << 1;
	enum MWM_DECOR_RESIZEH = 1 << 2;
	enum MWM_DECOR_TITLE = 1 << 3;
	enum MWM_DECOR_MENU = 1 << 4;
	enum MWM_DECOR_MINIMIZE = 1 << 5;
	enum MWM_DECOR_MAXIMIZE = 1 << 6;

	enum MWM_FUNC_RESIZE = 1 << 1;
	enum MWM_FUNC_MOVE = 1 << 2;
	enum MWM_FUNC_MINIMIZE = 1 << 3;
	enum MWM_FUNC_MAXIMIZE = 1 << 4;
	enum MWM_FUNC_CLOSE = 1 << 5;
	
	xlib.Window createWindow(int x, int y, uint width, uint height, out int screen_, out xlib.Atom closeAtom) {
		xlib.Window w;
		
		if (display_ is null) {
			display_ = xlib.XOpenDisplay(null);
			if (display_ is null)
				throw new WindowNotCreatable();
		}
			
		screen_ = xlib.DefaultScreen(display_);
		w = xlib.XCreateSimpleWindow(display_, xlib.RootWindow(display_, screen_), x, y, width, height, 1, xlib.BlackPixel(display_, screen_), xlib.WhitePixel(display_, screen_));

        xlib.XSelectInput(display_, w, xx11.ExposureMask | xx11.StructureNotifyMask | xx11.KeyPressMask | xx11.KeyReleaseMask | xx11.ButtonPressMask | xx11.ButtonReleaseMask | xx11.PointerMotionMask);
		
        closeAtom = xlib.XInternAtom(display_, cast(char*)"WM_DELETE_WINDOW\0".ptr, cast(int)true);
        xlib.XSetWMProtocols(display_, w, &closeAtom, 1);

		return w;
	}

    Keys convertKeyFromXlibEvent(uint code) {
        import x11.keysymdef;

        if (code >= 'a' && code <= 'z') code -= 'a' - 'A';
        switch (code) {
            case XK_semicolon: return Keys.Semicolon;
            case XK_slash: return Keys.Slash;
            case XK_equal: return Keys.Equals;
            case XK_minus: return Keys.Hyphen;
            case XK_bracketleft: return Keys.LeftBracket;
            case XK_bracketright: return Keys.RightBracket;
            case XK_comma: return Keys.Comma;
            case XK_period: return Keys.Period;
            case XK_dead_acute: return Keys.Quote;
            case XK_backslash: return Keys.Backslash;
            case XK_dead_grave: return Keys.Tilde;
            case XK_Escape: return Keys.Escape;
            case XK_space: return Keys.Space;
            case XK_Return: return Keys.Enter;
            case XK_KP_Enter: return Keys.Enter;
            case XK_BackSpace: return Keys.Backspace;
            case XK_Tab: return Keys.Tab;
            case XK_Prior: return Keys.PageUp;
            case XK_Next: return Keys.PageDown;
            case XK_End: return Keys.End;
            case XK_Home: return Keys.Home;
            case XK_Insert: return Keys.Insert;
            case XK_Delete: return Keys.Delete;
            case XK_KP_Add: return Keys.Add;
            case XK_KP_Subtract: return Keys.Subtract;
            case XK_KP_Multiply: return Keys.Multiply;
            case XK_KP_Divide: return Keys.Divide;
            case XK_Pause: return Keys.Pause;
            case XK_Left: return Keys.Left;
            case XK_Right: return Keys.Right;
            case XK_Up: return Keys.Up;
            case XK_Down: return Keys.Down;
            default:
                if (code >= XK_F1 && code <= XK_F12)
                    return cast(Keys)(Keys.F1 + (code - XK_F1));
                else if (code >= XK_KP_0 && code <= XK_KP_9)
                    return cast(Keys)(Keys.Numpad0 + (code - XK_KP_0));
                else if (code >= 'A' && code <= 'Z')
                    return cast(Keys)(Keys.A + (code - 'A'));
                else if (code >= '0' && code <= '9')
                    return cast(Keys)(Keys.Number0 + (code - '0'));
                break;
        }
        return Keys.Unknown;
    }

    KeyModifiers convertKeyFromXlibEventModifiers(uint code) {
        KeyModifiers ret;
        
        if (code & xx11.Mod1Mask)
            ret |= KeyModifiers.Alt;
        if (code & xx11.ControlMask)
            ret |= KeyModifiers.Control;
        if (code & xx11.ShiftMask || code & xx11.LockMask)
            ret |= KeyModifiers.Shift;
        
        return ret;
    }
}