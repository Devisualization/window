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
module devisualization.window.context.buffer2d;
import devisualization.window.window;
import devisualization.window.interfaces.context;

private {
    bool loadedDGL;
}

class Buffer2DContext : ContextBuffer2D {
    import devisualization.image.image;

    private {
        int cocoaId;
		
		Image buffer_;
		ubyte[4][] bufferdata;
    }

    this(Window window, WindowConfig config, int cocoaId) {
        this.cocoaId = cocoaId;
        cocoaCreateBuffer2DContext(cocoaId);
        activate();
    }

    @property {
        void activate() {
            cocoaActivateBuffer2DContext(cocoaId);
        }
        
        void destroy() {
            cocoaDestroyBuffer2DContext(cocoaId);
        }
        
        void swapBuffers() {
			if (buffer_ !is null) {
				// will only reallocate raw data buffer IF the Image buffer size has changed
				bufferdata.length = buffer_.rgba.length;
				
				foreach(i, pixel; buffer_.rgba.allPixels) {
					bufferdata[i][0] = pixel.r_ubyte;
					bufferdata[i][1] = pixel.g_ubyte;
					bufferdata[i][2] = pixel.b_ubyte;
					bufferdata[i][3] = pixel.a_ubyte;
				}
			
                                ubyte* data = bufferdata[0].ptr;
				cocoaSwapBuffer2DBuffers(cocoaId, &data, buffer_.width, buffer_.height);
			}
        }

        WindowContextType type() { return WindowContextType.Buffer2D; } 
        string toolkitVersion() { return null; }
        string shadingLanguageVersion() { return null; }
        string[] extensions() { return null; }
		
		ref Image buffer() { return buffer_; }
		void buffer(Image buffer) { buffer_ = buffer; }
    }
}

private {
    extern(C) {
        void cocoaCreateBuffer2DContext(int window);
        void cocoaActivateBuffer2DContext(int window);
        void cocoaDestroyBuffer2DContext(int window);
        void cocoaSwapBuffer2DBuffers(int window, ubyte** buffer, size_t width, size_t height);
    }
}
