/**
 * Declared the majority of the interfaces for Devisualization.Window
 * 
 * Authors:
 * 		Richard Andrew Cattermole
 * 
 * License:
 * 		The MIT License (MIT)
 *
 *		Copyright (c) 2014 Devisualization (Richard Andrew Cattermole)
 *  	
 *		Permission is hereby granted, free of charge, to any person obtaining a copy
 * 		of this software and associated documentation files (the "Software"), to deal
 * 		in the Software without restriction, including without limitation the rights
 * 		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * 		copies of the Software, and to permit persons to whom the Software is
 * 		furnished to do so, subject to the following conditions:
 *  	
 * 		The above copyright notice and this permission notice shall be included in all
 * 		copies or substantial portions of the Software.
 *  	
 * 		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * 		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * 		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * 		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * 		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * 		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * 		SOFTWARE.
 * 
 * Examples:
 * 		To create a window without an OpenGL context:
 * 		---
 * 	 Windowable window = new Window(800, 600, "My window!"w, 100, 100);
 * 	 window.show();
 * 	 Window.messageLoop();
 * 		---
 * 
 * This runs the message loop after showing the window.
 * Does nothing with events. Or show any content.
 */
module devisualization.window.interfaces.window;
import devisualization.window.interfaces.eventable;
public import devisualization.window.interfaces.events;
import devisualization.window.interfaces.context;

/**
 * Arguments to create a window.
 * Some may be optional.
 * 
 * A minimum width and height should be supplied.
 * 
 * See_Also:
 *	  Windowable
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
     *     However if not ASCII will be used. Which is effectively a string.
     *     Assume ASCII values are safe as a value.
     * 
     * Default:
     *		"A DWC window"
     */
    wstring title = "A DWC window";

    /**
     * The x position of the window to be created.
     * It is possible that this is ignored by the implementation.
     * 
     * Default:
     *         0 (px)
     */
    int x;

    /**
     * The y position of the window to be created.
     * It is possible that this is ignored by the implementation.
     * 
     * Default:
     *         0 (px)
     */
    int y;

    /**
     * Specifies the type of context to create. Validated by the window implementation.
     *
     * Default:
     *         None
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

/**
 * A generic window interface.
 * 
 * Should be supportive of majority of windowing toolkits in existance.
 * Is unaware of screens.
 * 
 * Implementation should support two constructors:
 * ---
 *  this(T...)(T config) { this(WindowConfig(config)); }
 *  this(WindowConfig config);
 * ---
 * 
 * Events_Mechanism:
 * 		A window support a set number of events.
 *		From those the event offer set functionality to manipulate them.
 *
 *  Adds a listener on an event
 *	---
 *		void addEventName(void delegate(T));
 *		void addEventName(bool delegate(T));
 *	---
 *
 *	Removes the provided listener
 *	---
 *		void removeEventName(bool delegate(T));
 *		void removeEventName(void delegate(T));
 *	---
 *	
 *	Counts how many listeners for an event
 *	---
 *		size_t countEventName();
 *	---
 *
 *	Runs the event for all listeners with the given arguments
 *	---
 *		void eventName(T);
 *	---
 *
 *	Clears all listeners for an event
 *	---
 *		void clearEventName();
 *	---
 *
 *	Optionally will also support:
 *	---
 *		void eventName(T[1 .. $]);
 *	---
 *	Where T[0] is Windowable.
 *	This will run the event and pass in as first argument this (Windowable).
 *
 * Events:
 *	Upon the message loop drawing period this is called.<br/>
 *  onDraw		=	Windowable
 *
 *  When the message loop is informed the window has moved, this is called.<br/>
 *  onMove		=	Windowable, int x, int y
 * 
 * 	When the message loop is informed the window has resized, this is called.<br/>
 * 	onResize	=	Windowable, uint newWidth, uint newHeight
 * 
 *  When the window has been requested to be closed from the user, this is called.<br/>
 *  On this event Windowable.close must be called manually.<br/>
 *  onClose		=	Windowable
 */
interface Windowable {
    import devisualization.image;

    //this(T...)(T config) { this(WindowConfig(config)); } 
    //this(WindowConfig);
    
    static {
        /**
         * Continues iteration of the message loop.
         * 
         * This is expected functionality provided from the implementation.
         */
        void messageLoop();

        /**
         * A single iteration of the message loop.
         * 
         * This is expected functionality provided from the implementation.
         */
        void messageLoopIteration();
    }
    
	/**
	 * Hides the window.
	 * 
	 * See_Also:
	 * 		hide
	 */
    void show();

	/**
	 * Shows the window.
	 * 
	 * See_Also:
	 * 		close
	 */
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

		/**
		 * Sets the title text.
		 * 
		 * Params:
		 * 		text	=	The text to set the title of the window to
		 */
        void title(string text);

		/**
		 * Sets the title text.
		 * 
		 * Params:
		 * 		text	=	The text to set the title of the window to
		 */
		void title(dstring text);

		/**
		 * Sets the title text.
		 * 
		 * Params:
		 * 		text	=	The text to set the title of the window to
		 */
		void title(wstring text);
        
		/**
		 * Resize the window.
		 * 
		 * Does not animate.
		 * 
		 * Params:
		 * 		width	=	The width to set to
		 * 		height	=	The height to set to
		 */
        void size(uint width, uint height);

		/**
		 * Move the window to coordinate.
		 * 
		 * Coordinate system based upon Top left corner of screen.
		 * Does not support screens (could be moved outside main screen).
		 * Coordinates can be negative, but is dependent upon the OS.
		 * 
		 * Params:
		 * 		x	=	The x coordinate to move to
		 * 		y	=	The y coordinate to move to
		 */
        void move(int x, int y);
        
		/**
		 * Enable / disable resizing of the window.
		 * 
		 * Params:
		 * 		can	=	Is it possible to resize the window (default yes)
		 */
        void canResize(bool can = true);

		/**
		 * Go into/out fullscreen
		 * 
		 * Params:
		 * 		isFullscreen	=	Should be fullscreen (default yes)
		 */
        void fullscreen(bool isFullscreen = true);

        /**
         * Closes the window.
         * The window cannot reopened once closed.
		 *
         * See_Also:
         * 		hide
         */
        void close();

		/**
		 * Has the window been closed?
		 * 
		 * Returns:
		 * 		True if close has been called
		 * 
		 * See_Also:
		 * 		close
		 */
        bool hasBeenClosed();

		/**
		 * Gets the current context that the window has open or null for none.
		 * 
		 * Returns:
		 * 		A context that has a buffer that can be swapped and activated once created
		 */
        IContext context();
    }

	/**
     * Sets the icon for the window.
     * Supports transparency.
     * 
     * Params:
     *		image		=	The image (from Devisualization.Image).
	 */
    void icon(Image image);

    /**
     * Sets the icon for the window.
     * Supports transparency.
     * 
     * Params:
     *		width		=	The width of the icon
     *      height		=	The height of the icon
     *      data 	    =  	rgb data 0 .. 255, 3 bytes per pixel
     *      transparent =	The given pixel (3 bytes like data) color to use as transparency
     * 
     * Deprecated:
     * 		Superseded by using Devisualization.Image's Image, as argument instead.
     */
    deprecated("Use Devisualization.Image method instead")
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