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
module devisualization.window.context;
import devisualization.window.window;
import devisualization.window.interfaces.context;

import derelict.opengl3.gl;
import derelict.opengl3.wgl;
import derelict.opengl3.wglext;

private {
    bool loadedDGL;
}

class OpenglContext : IContext {
    private {
        HDC hdc_;
        HGLRC hglrc_;
    }

    this(Window window, WindowConfig config) {
        if (!loadedDGL) {
            DerelictGL.load();
            loadedDGL = true;
        }

        import windows : GetDC;
        hdc_ = GetDC(window.hwnd);

        configurePixelFormat(window, config, hdc_);

        hglrc_ = cast(HGLRC)wglCreateContext(hdc_);
        activate();
    }

    @property {
        void activate() {
            wglMakeCurrent(hdc_, hglrc_);
            DerelictGL.reload();
        }

        void destroy() {
            wglDeleteContext(hglrc_);
        }

        void swapBuffers() {
			glFlush();
			SwapBuffers(hdc_);
        }

        WindowContextType type() { return WindowContextType.Opengl; }

        string toolkitVersion() {
            char[] str;
            const(char*) c = glGetString(GL_VERSION);
            size_t i;

            if (c !is null) {
                while (c[i] != '\0') {
                    str ~= c[i];
                    i++;
                }
            }

            return str.idup;
        }

        string shadingLanguageVersion() {
            char[] str;
            const(char*) c = glGetString(GL_SHADING_LANGUAGE_VERSION);
            size_t i;
            
            if (c !is null) {
                while (c[i] != '\0') {
                    str ~= c[i];
                    i++;
                }
            }
            
            return str.idup;
        }

        string[] extensions() {
            string[] ret;

            char[] str;
            const(char*) c = glGetString(GL_SHADING_LANGUAGE_VERSION);
            size_t i;
            
            if (c !is null) {
                while (c[i] != '\0') {
                    if (c[i] == ' ') {
                        ret ~= str.idup;
                        str.length = 0;
                    } else {
                        str ~= c[i];
                    }
                    i++;
                }
            }
            
            return ret;
        }
    }
}

/*class Direct3DContext : IContext {
    this(Window window, WindowConfig config) {

    }

    WindowContextType type() { return WindowContextType.Direct3D; }
}*/

private {
    import windows : SwapBuffers, HDC, HGLRC;

    void configurePixelFormat(Window window, WindowConfig config, HDC hdc_) {
        import windows : PIXELFORMATDESCRIPTOR, ChoosePixelFormat, SetPixelFormat, PFD_DRAW_TO_WINDOW, PFD_SUPPORT_OPENGL, PFD_DOUBLEBUFFER, PFD_TYPE_RGBA, PFD_MAIN_PLANE;
        PIXELFORMATDESCRIPTOR pfd = PIXELFORMATDESCRIPTOR( 
            PIXELFORMATDESCRIPTOR.sizeof,
                1,                     // version number  
                PFD_DRAW_TO_WINDOW |   // support window  
                PFD_SUPPORT_OPENGL |   // support OpenGL  
                PFD_DOUBLEBUFFER,      // double buffered  
                PFD_TYPE_RGBA,         // RGBA type  
                24,                    // 24-bit color depth  
                0, 0, 0, 0, 0, 0,      // color bits ignored  
                0,                     // no alpha buffer  
                0,                     // shift bit ignored  
                0,                     // no accumulation buffer  
                0, 0, 0, 0,            // accum bits ignored  
                32,                    // 32-bit z-buffer  
                0,                     // no stencil buffer  
                0,                     // no auxiliary buffer  
                PFD_MAIN_PLANE,        // main layer  
                0,                     // reserved  
                0, 0, 0                // layer masks ignored  
          );
                                                          
        int  iPixelFormat; 
        
        // get the best available match of pixel format for the device context   
        iPixelFormat = ChoosePixelFormat(hdc_, &pfd); 
        
        // make that the pixel format of the device context  
        SetPixelFormat(hdc_, iPixelFormat, &pfd);
    }
}