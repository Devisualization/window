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

private {
    bool loadedDGL;
}

class OpenglContext : IContext {
    private {
        import derelict.opengl3.gl;
        
        int cocoaId;
    }

    this(Window window, WindowConfig config, int cocoaId) {
        if (!loadedDGL) {
            DerelictGL.load();
            loadedDGL = true;
        }
        
        this.cocoaId = cocoaId;

        if ((config.contextType | WindowContextType.Opengl3Plus) == WindowContextType.Opengl3Plus) {
            cocoaCreateOGLContext(cocoaId, 3);
        } else {
            cocoaCreateOGLContext(cocoaId, 1);
        }
        
        activate();
    }

    @property {
        void activate() {
            cocoaActivateOGLContext(cocoaId);
            DerelictGL.reload();
        }
        
        void destroy() {
            cocoaDestroyOGLContext(cocoaId);
        }
        
        void swapBuffers() {
            cocoaSwapOGLBuffers(cocoaId);
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

private {
    extern(C) {
        void cocoaCreateOGLContext(int window, int minVersion);
        void cocoaActivateOGLContext(int window);
        void cocoaDestroyOGLContext(int window);
        void cocoaSwapOGLBuffers(int window);
    }
}