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
module devisualization.window.context.opengl;
import devisualization.window.window;
import devisualization.window.interfaces.context;

private {
    bool loadedDGL;
}

class OpenglContext : IContext {
    private {
        import derelict.opengl3.gl;
        import dglx = derelict.opengl3.glx;
        import dxtypes = derelict.util.xtypes;

        import xx11 = x11.X;
        import xlib = x11.Xlib;

        dxtypes.XVisualInfo* vi;
        dglx.GLXContext glc;
        xlib.Display* display;
        xlib.Window window;
    }

    this(Window window, WindowConfig config) {
        if (!loadedDGL) {
            DerelictGL.load();
            loadedDGL = true;
        }
        this.window = window.x11Window;
        display = window.x11Display;

        int[] att = [dglx.GLX_RGBA, dglx.GLX_DEPTH_SIZE, 24, dglx.GLX_DOUBLEBUFFER, xx11.None];
        vi = dglx.glXChooseVisual(display, 0, att.ptr);

        glc = dglx.glXCreateContext(display, vi, null, GL_TRUE);

        activate();
    }

    @property {
        void activate() {
            dglx.glXMakeCurrent(display, cast(uint)window, glc);
            DerelictGL.reload();
        }
        
        void destroy() {
            xlib.XFree(vi);
            dglx.glXDestroyContext(display, glc);
        }
        
        void swapBuffers() {
			glFlush();
			dglx.glXSwapBuffers(display, cast(uint)window);
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