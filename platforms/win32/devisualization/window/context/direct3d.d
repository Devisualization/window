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
module devisualization.window.context.direct3d;

version(Have_directx_d) {
	import devisualization.window.window;
	import devisualization.window.interfaces.context;

	class Direct3dContext : IContext {
		import devisualization.image.image;
		import winapi = windows;
		import directx.d3d11;

		private {
			winapi.HWND hWnd;
			Window window;

			ID3D11Device dev;
			ID3D11DeviceContext devcon;
			IDXGISwapChain swapchain;
			ID3D11RenderTargetView backbuffer;
		}
		
		this(Window window, WindowConfig config) {
			this.window = window;
			hWnd = window.hwnd;

			init();
		}
		
		@property {
			void activate() {}

			void destroy() {
				swapchain.Release();
				backbuffer.Release();
				dev.Release();
				devcon.Release();
			}

			void swapBuffers() {
				swapchain.Present(0, 0);
			}
			
			WindowContextType type() { return WindowContextType.Direct3D; }

			string toolkitVersion() {
				import std.conv : text;
				return text(devcon.GetType) ~ " " ~ text(dev.GetFeatureLevel());
			}

			string shadingLanguageVersion() {
				switch(dev.GetFeatureLevel()) {
					case D3D_FEATURE_LEVEL_9_1:
					case D3D_FEATURE_LEVEL_9_2:
						return "2";
					case D3D_FEATURE_LEVEL_9_3:
						return "2.0b";
					case D3D_FEATURE_LEVEL_10_0:
					case D3D_FEATURE_LEVEL_10_1:
						return "4";
					case D3D_FEATURE_LEVEL_11_0:
						return "5";
					//case D3D_FEATURE_LEVEL_11_1:
					//	return "5 with logical blend operations";

					default:
						return null;
				}
			}

			ID3D11Device device() { return dev; }
			ID3D11DeviceContext deviceContext() { return devcon; }
			IDXGISwapChain swapChain() { return swapchain; }
			ID3D11RenderTargetView backBuffer() { return backbuffer; }
		}

		private {
			void init() {
				import std.c.string : memset;

				// create a struct to hold information about the swap chain
				DXGI_SWAP_CHAIN_DESC scd;
				
				// clear out the struct for use
				memset(&scd, 0, DXGI_SWAP_CHAIN_DESC.sizeof );
				
				// fill the swap chain description struct
				scd.BufferCount = 1;                                    // one back buffer
				scd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;     // use 32-bit color
				scd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;      // how swap chain is to be used
				scd.OutputWindow = hWnd;                                // the window to be used
				scd.SampleDesc.Count = 4;                               // how many multisamples
				scd.Windowed = true;                                    // windowed/full-screen mode
				
				// create a device, device context and swap chain using the information in the scd struct
				D3D11CreateDeviceAndSwapChain(null,
					D3D_DRIVER_TYPE_HARDWARE,
					null,
					0,
					null,
					0,
					D3D11_SDK_VERSION,
					&scd,
					&swapchain,
					&dev,
					null,
					&devcon);
				
				// get the address of the back buffer
				ID3D11Texture2D pBackBuffer;
				swapchain.GetBuffer(0, &IID_ID3D11Texture2D, cast(void**)&pBackBuffer);
				
				// use the back buffer address to create the render target
				dev.CreateRenderTargetView(pBackBuffer, null, &backbuffer);
				pBackBuffer.Release();
				
				// set the render target as the back buffer
				devcon.OMSetRenderTargets(1, &backbuffer, null);

				winapi.RECT winsize;
				winapi.GetClientRect(hWnd, &winsize);

				// Set the viewport
				D3D11_VIEWPORT viewport;
				memset(&viewport, 0, D3D11_VIEWPORT.sizeof);
				
				viewport.TopLeftX = 0;
				viewport.TopLeftY = 0;
				viewport.Width = winsize.right;
				viewport.Height = winsize.bottom;
				
				devcon.RSSetViewports(1, &viewport);
			}
		}
	}
}