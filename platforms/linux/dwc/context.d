module dwc.context;
import dwc.window;
import dwc.interfaces.context;

private {
    bool loadedDGL;
}

class OpenglContext : IContext {
    private {
        import derelict.opengl3.gl3;
        import derelict.opengl3.gl;
        import dglx = derelict.opengl3.glx;
        //import derelict.opengl3.glxext;
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
            //DerelictGL3.load();
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
            DerelictGL3.reload();
        }
        
        void destroy() {
            xlib.XFree(vi);
            dglx.glXDestroyContext(display, glc);
        }
        
        void swapBuffers() {
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