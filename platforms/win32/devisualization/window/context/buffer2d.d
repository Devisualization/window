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

private enum SRCCOPY = 0x00CC0020;

class Buffer2DContext : ContextBuffer2D {
	import windows;
	import devisualization.image.image;
	
	private {
		PAINTSTRUCT 	ps;
		HDC 			hdc;
		HDC 			hdcMem;
		RECT winsize;
		HBITMAP bitmap;

		HWND hwnd;
		Window window;
		
		Image buffer_;
		ubyte[4][] bufferdata;
	}
	
	this(Window window, WindowConfig config) {
		this.window = window;
		hwnd = window.hwnd;
		
		buffer_ = null;
	}
	
	@property {
		void activate() {}
		void destroy() {}
		
		void swapBuffers() {
			hdc = BeginPaint(hwnd, &ps);
			hdcMem = CreateCompatibleDC(hdc);

			if (buffer_ !is null) {
				// will only reallocate raw data buffer IF the Image buffer size has changed
				auto rgba = buffer_.rgba;
				bufferdata.length = rgba.length;
				
				foreach(i, pixel; rgba) {
					bufferdata[i][2] = pixel.r_ubyte;
					bufferdata[i][1] = pixel.g_ubyte;
					bufferdata[i][0] = pixel.b_ubyte;
					bufferdata[i][3] = pixel.a_ubyte;
				}
				
				GetClientRect(hwnd, &winsize);
				
				HBITMAP hBitmap = CreateBitmap(cast(uint)buffer_.width, cast(uint)buffer_.height, 1, 32, bufferdata.ptr);
				HGDIOBJ oldBitmap = SelectObject(hdcMem, hBitmap);

				GetObjectA(hBitmap, HBITMAP.sizeof, &bitmap);
				
				// auto stretch the image buffer to client screen size
				StretchBlt(hdc, 0, 0, cast(uint)buffer_.width, cast(uint)buffer_.height, hdcMem, 0, 0, winsize.right, winsize.bottom, SRCCOPY);

				SelectObject(hdcMem, oldBitmap);
				DeleteObject(hBitmap);
			}

			EndPaint(hwnd, &ps);
			DeleteDC(hdcMem);

			// perform the actual redraw!
			InvalidateRgn(hwnd, null, false);
		}
		
		WindowContextType type() { return WindowContextType.Buffer2D; }
		string toolkitVersion() { return null; }
		string shadingLanguageVersion() { return null; }
		
		ref Image buffer() { return buffer_; }
		void buffer(Image buffer) { buffer_ = buffer; }
	}
}