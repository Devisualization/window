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
        
        int cocoaId;
    }

    this(Window window, WindowConfig config, int cocoaId) {
        if (!loadedDGL) {
            DerelictGL3.load();
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
            DerelictGL3.reload();
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