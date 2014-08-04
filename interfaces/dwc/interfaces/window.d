module dwc.interfaces.window;
import dwc.interfaces.eventable;
import dwc.interfaces.events;
import dwc.interfaces.context;

/**
 * Arguments to create a window.
 * Some may be optional.
 * 
 * At minimum width and height should be supplied.
 * 
 * See_Also:
 * 		Windowable
 */
struct WindowConfig {
	/**
	 * Width of the window to create.
	 * Must be atleast 0 (px).
	 */
	uint width;

	/**
	 * Height of the window to create.
	 * Must be atleast 0 (px).
	 */
	uint height;

	/**
	 * The title of the window to create.
	 * Commonly a UTF-8 support should be available.
	 * 	However if not ASCII will be used. Which is effectively a string.
	 * 	Assume ASCII values are safe as a value.
	 * 
	 * Default:
	 * 		"A DWC window"
	 */
	wstring title = "A DWC window";

	/**
	 * The x position of the window to be created.
	 * It is possible that this is ignored by the implementation.
	 * 
	 * Default:
	 * 		0 (px)
	 */
	int x;

	/**
	 * The y position of the window to be created.
	 * It is possible that this is ignored by the implementation.
	 * 
	 * Default:
	 * 		0 (px)
	 */
	int y;

	/**
	 * Specifies the type of context to create. Validated by the window implementation.
	 *
	 * Default:
	 * 		None
	 */
	WindowContextType contextType;

	/**
	 * Forces width and height to be atleast 0 (px).
	 */
	invariant() {
		assert(width > 0, "Should a window really have a 0px width?");
		assert(height > 0, "Should a window really have a 0px height?");
	}
}

interface Windowable {
	//this(T...)(T config) { this(WindowConfig(config)); } 
	//this(WindowConfig);
	
	static {
        /**
         * Continues iteration of the message loop
         */
		void messageLoop();

        /**
         * A single iteration of the message loop
         */
		void messageLoopIteration();
	}
	
	void show();
	void hide();

    /*
     * Window
     */

	mixin IEventing!("onDraw", Windowable);
	mixin IEventing!("onMove", Windowable, int, int);
    mixin IEventing!("onResize", Windowable, uint, uint);

    mixin IEventing!("onClose", Windowable);

    /*
     * Mouse 
     */

    mixin IEventing!("onMouseDown", Windowable, MouseButtons, int, int);
    mixin IEventing!("onMouseMove", Windowable, int, int);
    mixin IEventing!("onMouseUp", Windowable, MouseButtons);
	
    /*
     * Keyboard
     * KeyModifiers is an or'd mask or modifiers upon the key
     */

    mixin IEventing!("onKeyDown", Windowable, Keys, KeyModifiers);
    mixin IEventing!("onKeyUp", Windowable, Keys, KeyModifiers);

    @property {
		void title(string);
		void title(dstring);
		void title(wstring);
		
		void size(uint, uint);
		void move(int, int);
		
		void canResize(bool = true);
		void fullscreen(bool = true);

        /**
         * Call this, nothing else should work afterwards
         */
        void close();
        bool hasBeenClosed();

        IContext context();
	}

	/**
	 * 
	 * Params:
	 * 		width
	 * 		height
	 * 		data		= rgb data 0 .. 255, 3 bytes per pixel
	 */
	void icon(ushort width, ushort height, ubyte[3][] data, ubyte[3]* transparent = null);
}

class WindowNotCreatable : Exception {
	@safe pure nothrow this(string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
		super("Window failed to be created.", file, line, next);
	}
	
	@safe pure nothrow this(Throwable next, string file = __FILE__, size_t line = __LINE__) {
		super("Window failed to be created.", file, line, next);
	}
}