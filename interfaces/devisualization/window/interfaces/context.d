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
module devisualization.window.interfaces.context;

enum WindowContextType : ubyte {
    None = 0,
    Opengl = OpenglLegacy | Opengl3Plus,
    Direct3D = 1 << 1,
    
    OpenglLegacy = 1 << 2,
    Opengl3Plus = 1 << 3
}

/**
 * Context definition for a 3d rendering toolkit
 */
interface IContext {
    @property {
        /**
         * Activates the context for use
         */
        void activate();

        /**
         * Destroys a context
         */
        void destroy();

        /**
         * Swap the buffers, to make the output display
         */
        void swapBuffers();

        /**
         * What type of context is this?
         */
        WindowContextType type();

        /**
         * Version of the toolkit being used
         */
        string toolkitVersion();

        /**
         * Version of the shading language available
         */
        string shadingLanguageVersion();
    }
}