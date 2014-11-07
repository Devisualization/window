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