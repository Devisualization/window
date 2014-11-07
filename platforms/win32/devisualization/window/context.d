module devisualization.window.context;
import devisualization.window.window;
import devisualization.window.interfaces.context;

import derelict.opengl3.gl3;
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
            DerelictGL3.load();
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
            DerelictGL3.reload();
        }

        void destroy() {
            wglDeleteContext(hglrc_);
        }

        void swapBuffers() {
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