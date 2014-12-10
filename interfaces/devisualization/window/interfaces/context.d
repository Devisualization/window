/**
 * Context related interfaces.
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
 */
module devisualization.window.interfaces.context;

/**
 * The type of context available.
 */
enum WindowContextType : ubyte {
	/**
	 * No context to be used.
	 */
    None = 0,

	/**
	 * Both legacy (1.x .. 2.x) and 3+ contexts for OpenGL.
	 * 3+ preferred if only one available.
	 */
    Opengl = OpenglLegacy | Opengl3Plus,

	/**
	 * Direct3D context.
	 * Highly unlikely implemented.
	 */
    Direct3D = 1 << 1,
    
	/**
	 * Legacy OpenGL context (1.x .. 2.x)
	 */
    OpenglLegacy = 1 << 2,

	/**
	 * OpenGL context 3+
	 */
    Opengl3Plus = 1 << 3
}

/**
 * Context definition for a 3d rendering toolkit.
 */
interface IContext {
    @property {
        /**
         * Activates the context for use.
         */
        void activate();

        /**
         * Destroys a context.
         */
        void destroy();

        /**
         * Swap the buffers, to make the output display.
         */
        void swapBuffers();

        /**
         * What type of context is this?
         * 
         * Returns:
         * 		The context type.
         */
        WindowContextType type();

        /**
         * Version of the toolkit being used.
         * 
         * Returns:
         * 		The toolkit version.
         * 		This is implementation defined with no clear structure.
         * 		Is for debugging/logging and should not be relied upon.
         */
        string toolkitVersion();

        /**
         * Version of the shading language available
         * 
         * Returns:
         * 		The shader language version.
         * 		This is implementation defined with no clear structure.
         * 		IS for debugging/logging and should not be relied upon.
         */
        string shadingLanguageVersion();
    }
}