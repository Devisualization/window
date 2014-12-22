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
module devisualization.window.window;
import devisualization.window.interfaces.window;
public import devisualization.window.interfaces.window : WindowConfig, Windowable;
public import devisualization.window.interfaces.events : MouseButtons, Keys, KeyModifiers;
public import devisualization.window.interfaces.context : WindowContextType, IContext;
public import devisualization.window.context;
import devisualization.window.interfaces.eventable;
import std.conv : to;

class Window : Windowable {
    private {
        HWND hwnd_;
        HICON previousIcon_;
        wstring lastTitle;
        bool hasBeenClosed_;

        WindowConfig config_;
        IContext context_ = null;
    }

    this(T...)(T config) { this(WindowConfig(config)); } 

    this(WindowConfig config) {
        config_ = config;
        hwnd_ = createWindow(config.x, config.y, config.width, config.height, &windowHandler, &this);
        title = config.title;
    }

    static {
        void messageLoop() {
            import core.thread : Thread;
            import core.time : dur;
            
            while(true) {
				while(Window.messageLoopIteration()) {}
                Thread.sleep(dur!"msecs"(50));
            }
        }

        bool messageLoopIteration()
        out {
            import std.stdio : stdout;
            stdout.flush(); // issue on windows. Will not auto flush if we control the event queue.
        } body {
            MSG* msg;
            int ret = GetMessageW(msg, null, 0, 0);
            
            if (ret == 0 || ret == -1 || msg is null)
                return false;
            
            TranslateMessage(msg);
            DispatchMessageW(msg);

			return true;
        }
    }
    
    @property {
        HWND hwnd()
        in {
            assert(!hasBeenClosed_);
        } body {
            return hwnd_;
        }
        
        void title(string value)
        in {
            assert(!hasBeenClosed_);
        } body {
            title(to!wstring(value));
        }
        
        void title(dstring value)
        in {
            assert(!hasBeenClosed_);
        } body {
            title(to!wstring(value));
        }
        
        void title(wstring value)
        in {
            assert(!hasBeenClosed_);
        } body {
            if (value != ""w && value[$-1] != '\0')
                value ~= '\0';
			else if (value == ""w)
				value = "\0"w;
            lastTitle = value;
            
            SetWindowTextW(hwnd_, cast(ushort*)lastTitle.ptr);
        }
        
        void size(uint width, uint height)
        in {
            assert(!hasBeenClosed_);
        } body {
            // calculates correct width/height size of window
            RECT rect;
            
            rect.top = 0;
            rect.left = 0;
            rect.right = width;
            rect.bottom = height;
            
            auto style = GetWindowLongW(hwnd_, GWL_STYLE);
            if (style == dwFullscreen) {
                SetWindowLongW(hwnd_, GWL_STYLE, dwStyle);
                SetWindowLongW(hwnd_, GWL_EXSTYLE, dwExStyle);
            }
            
            AdjustWindowRectEx(&rect, dwStyle, false, dwExStyle);
            width = rect.right;
            height = rect.bottom;
            // calculates correct width/height size of window
            
            SetWindowPos(hwnd_, null, 0, 0, width, height, SWP_NOMOVE | SWP_NOOWNERZORDER);
        }
        
        void move(int x, int y)
        in {
            assert(!hasBeenClosed_);
        } body {
            SetWindowPos(hwnd_, null, x, y, 0, 0, SWP_NOSIZE | SWP_NOOWNERZORDER);
        }
        
        void canResize(bool can = true)
        in {
            assert(!hasBeenClosed_);
        } body {
            auto style = GetWindowLongW(hwnd_, GWL_STYLE);
            if (can)
                style |= WS_SIZEBOX | WS_MAXIMIZEBOX;
            else
                style &= ~(WS_SIZEBOX | WS_MAXIMIZEBOX);
            SetWindowLongW(hwnd_, GWL_STYLE, style);
        }
        
        void fullscreen(bool isfs = true)
        in {
            assert(!hasBeenClosed_);
        } body {
            if (isfs) {
                SetWindowLongW(hwnd_, GWL_STYLE, dwFullscreen);
                SetWindowLongW(hwnd_, GWL_EXSTYLE, dwExFullscreen);
                
                int cx = GetSystemMetrics(SM_CXSCREEN);
                int cy = GetSystemMetrics(SM_CYSCREEN);
                SetWindowPos(hwnd_, HWND_TOP, 0, 0, cx, cy, SWP_SHOWWINDOW);
            } else {
                canResize = true;
            }
        }

        void close()
        in {
            assert(!hasBeenClosed_);
        } body {
            DestroyWindow(hwnd_);
            CloseWindow(hwnd_);
        }

        IContext context()
        in {
            assert(!hasBeenClosed_);
        } body {
            return context_;
        }
    }
    
    override {
        void show()
        in {
            assert(!hasBeenClosed_);
        } body {
            ShowWindow(hwnd_, SW_SHOW);
        }
        
        void hide()
        in {
            assert(!hasBeenClosed_);
        } body {
            ShowWindow(hwnd_, SW_HIDE);
        }

        void icon(Image image)
        in {
            assert(!hasBeenClosed_);
            assert(image !is null);
        } body {
            ubyte[4][] data;
            foreach(pixel; image.rgba.allPixels) {
                data ~= [pixel.b_ubyte, pixel.g_ubyte, pixel.r_ubyte, pixel.a_ubyte];
            }

            HBITMAP bitmap = CreateBitmap(cast(uint)image.width, cast(uint)image.height, 1, 32, data.ptr);
            HBITMAP hbmMask = CreateCompatibleBitmap(GetDC(hwnd_), cast(uint)image.width, cast(uint)image.height);
            
            ICONINFO ii;
            ii.fIcon = TRUE;
            ii.hbmColor = bitmap;
            ii.hbmMask = hbmMask;
            
            HICON hIcon = CreateIconIndirect(&ii);
            DeleteObject(hbmMask);
            
            if (hIcon) {
                SendMessageW(hwnd_, WM_SETICON, cast(WPARAM)ICON_BIG, cast(LPARAM)hIcon);
                SendMessageW(hwnd_, WM_SETICON, cast(WPARAM)ICON_SMALL, cast(LPARAM)hIcon);
            }
        }

        deprecated("Use Devisualization.Image method instead")
        void icon(ushort width, ushort height, ubyte[3][] idata, ubyte[3]* transparent = null)
        in {
            assert(!hasBeenClosed_);
            assert(width * height == data.length, "Icon pixels length must be equal to width * height");
        } body {
            ubyte[4][] data;
            foreach(v; idata) {
                data ~= [v[2], v[1], v[0], 0];
            }

            HBITMAP bitmap = CreateBitmap(width, height, 1, 32, data.ptr);
            HBITMAP hbmMask;
            if (transparent is null)
                hbmMask = CreateCompatibleBitmap(GetDC(hwnd_), width, height);
            else {
                COLORREF crTransparent = RGB((*transparent)[0], (*transparent)[1], (*transparent)[2]);

                HDC hdcMem, hdcMem2;
                BITMAP bm;

                GetObjectA(bitmap, BITMAP.sizeof, &bm);
                hbmMask = CreateBitmap(width, height, 1, 1, null);

                hdcMem = CreateCompatibleDC(GetDC(hwnd_));
                hdcMem2 = CreateCompatibleDC(GetDC(hwnd_));

                SelectObject(hdcMem, bitmap);
                SelectObject(hdcMem2, hbmMask);

                SetBkColor(hdcMem, crTransparent);
                BitBlt(hdcMem2, 0, 0, width, height, hdcMem, 0, 0, SRCCOPY);
                BitBlt(hdcMem, 0, 0, width, height, hdcMem2, 0, 0, SRCINVERT);

                DeleteDC(hdcMem);
                DeleteDC(hdcMem2);
            }

            ICONINFO ii;
            ii.fIcon = TRUE;
            ii.hbmColor = bitmap;
            ii.hbmMask = hbmMask;

            HICON hIcon = CreateIconIndirect(&ii);
            DeleteObject(hbmMask);

            if (hIcon) {
                SendMessageW(hwnd_, WM_SETICON, cast(WPARAM)ICON_BIG, cast(LPARAM)hIcon);
                SendMessageW(hwnd_, WM_SETICON, cast(WPARAM)ICON_SMALL, cast(LPARAM)hIcon);
            }
        }

        bool hasBeenClosed() { return hasBeenClosed_; }
    }
    
    mixin Eventing!("onDraw", Windowable);
    mixin Eventing!("onMove", Windowable, int, int);
    mixin Eventing!("onResize", Windowable, uint, uint);
    mixin Eventing!("onClose", Windowable);

    mixin Eventing!("onMouseDown", Windowable, MouseButtons, int, int);
    mixin Eventing!("onMouseMove", Windowable, int, int);
    mixin Eventing!("onMouseUp", Windowable, MouseButtons);
    mixin Eventing!("onKeyDown", Windowable, Keys, KeyModifiers);
    mixin Eventing!("onKeyUp", Windowable, Keys, KeyModifiers);
}


private {    
    import windows;
    
    enum DWORD dwExStyle = 0;
    enum DWORD dwStyle = WS_OVERLAPPEDWINDOW;
    
    enum wstring WindowClassName = "DWC window\0"w;
    
    enum DWORD dwFullscreen = WS_POPUP | WS_CLIPCHILDREN | WS_CLIPSIBLINGS;
    enum DWORD dwExFullscreen = WS_EX_APPWINDOW | WS_EX_TOPMOST;

    // wasn't in windows bindings woops

    enum GCL_HICON = -14;
    enum SRCCOPY = 0xCC0020;
    enum SRCINVERT = 0x660046;

    COLORREF RGB(ubyte r, ubyte g, ubyte b) {
        r = r & 0xFF;
        g = g & 0xFF;
        b = b & 0xFF;
        return cast(COLORREF)((b << 16) | (g << 8) | r);
    }


    // more actual code
    
    HWND createWindow(int x, int y, uint width, uint height, WindowProc wProc, Window* windowPtr) {
        static HINSTANCE hInstance;
        
        if (hInstance is HINSTANCE.init)
            hInstance = GetModuleHandleA(null);
        
        WNDCLASSW wc;
        wc.lpfnWndProc = wProc;
        wc.hInstance = hInstance;
        wc.lpszClassName = cast(ushort*)WindowClassName.ptr;
        wc.hCursor = LoadCursorW(null, cast(ushort*)IDC_ARROW);
        wc.style |= CS_OWNDC | CS_HREDRAW | CS_VREDRAW;
        if (!RegisterClassW(&wc))
            throw new WindowNotCreatable();
        
        // calculates correct width/height size of window
        RECT rect;
        
        rect.top = 0;
        rect.left = 0;
        rect.right = width;
        rect.bottom = height;
        
        AdjustWindowRectEx(&rect, dwStyle, false, dwExStyle);
        width = rect.right;
        height = rect.bottom;
        // calculates correct width/height size of window
        
        HWND hwnd = CreateWindowExW(
            dwExStyle,
            cast(ushort*)WindowClassName.ptr,
            null,
            dwStyle,
            x, y,
            width, height,
            null,
            null,
            hInstance,
            windowPtr);
        
        if (hwnd is null)
            throw new WindowNotCreatable();

        InvalidateRgn(hwnd, null, true);        

        return hwnd;
    }
    
    extern(Windows) {
        alias WindowProc = LRESULT function(HWND hwnd, uint uMsg, WPARAM wParam, LPARAM lParam);
        
        LRESULT windowHandler(HWND hwnd, uint uMsg, WPARAM wParam, LPARAM lParam) {
            /*
             * Handles creational arguments aka the current window 
             */
            Window window;
            switch(uMsg) {
                case WM_CREATE:
                    CREATESTRUCTW pCreate = *cast(CREATESTRUCTW*)lParam;
                    void* pState = pCreate.lpCreateParams;
                    
                    version(X86_64) {
                        SetWindowLongPtrW(hwnd, GWLP_USERDATA, *cast(ulong*)pState);
                    } else {
                        SetWindowLongW(hwnd, GWLP_USERDATA, *cast(uint*)pState);
                    }

                    return cast(LRESULT)0;
                    
                default:
                    version(X86_64) {
                        window = cast(Window)cast(ulong*)GetWindowLongPtrW(hwnd, GWLP_USERDATA);
                    } else {
                        window = cast(Window)cast(uint*)GetWindowLongW(hwnd, GWLP_USERDATA);
                    }
            }
            
            /*
             * Normal flow handling 
             */
            switch(uMsg) {
                case WM_DESTROY:
                    PostQuitMessage(0);
                    return cast(LRESULT)0;
                    
                case WM_PAINT:
                    if (window.context_ is null) {
                        if ((window.config_.contextType | WindowContextType.Opengl3Plus) || (window.config_.contextType | WindowContextType.OpenglLegacy)) {
                            window.context_ = new OpenglContext(window, window.config_);
                        } else if (window.config_.contextType == WindowContextType.Direct3D) {
                            // create Direct3d context!
                        }
                    }
                    window.onDraw();
                    return cast(LRESULT)0;
                    
                case WM_SIZE:
                    window.onResize(LOWORD(lParam), HIWORD(lParam));
                    return cast(LRESULT)0;
                    
                case WM_MOVE:
                    window.onMove(LOWORD(lParam), HIWORD(lParam));
                    return cast(LRESULT)0;
                    
                case WM_LBUTTONDOWN:
                    window.onMouseDown(MouseButtons.Left, LOWORD(lParam), HIWORD(lParam));
                    return cast(LRESULT)0;
                case WM_MBUTTONDOWN:
                    window.onMouseDown(MouseButtons.Middle, LOWORD(lParam), HIWORD(lParam));
                    return cast(LRESULT)0;
                case WM_RBUTTONDOWN:
                    window.onMouseDown(MouseButtons.Right, LOWORD(lParam), HIWORD(lParam));
                    return cast(LRESULT)0;

                case WM_MOUSEMOVE:
                    window.onMouseMove(LOWORD(lParam), HIWORD(lParam));
                    return cast(LRESULT)0;

                case WM_LBUTTONUP:
                    window.onMouseUp(MouseButtons.Left);
                    return cast(LRESULT)0;
                case WM_MBUTTONUP:
                    window.onMouseUp(MouseButtons.Middle);
                    return cast(LRESULT)0;
                case WM_RBUTTONUP:
                    window.onMouseUp(MouseButtons.Right);
                    return cast(LRESULT)0;
                   
                case WM_SYSKEYDOWN:
                case WM_KEYDOWN:
                    window.onKeyDown(convertWinKeys(cast(uint)wParam), convertWinKeyModifiers());
                    return cast(LRESULT)0;

                case WM_SYSKEYUP:
                case WM_KEYUP:
                    window.onKeyUp(convertWinKeys(cast(uint)wParam), convertWinKeyModifiers());
                    return cast(LRESULT)0;
                case WM_CLOSE:
                    window.onClose();
                    if (window.countOnClose() == 0)
                        window.close();
                    return cast(LRESULT)0;

                default:
                    break;
            }
            return DefWindowProcW(hwnd, uMsg, wParam, lParam);
        }
    }

    Keys convertWinKeys(uint code) {
        switch (code)
        {
            case VK_OEM_1: return Keys.Semicolon;
            case VK_OEM_2: return Keys.Slash;
            case VK_OEM_PLUS: return Keys.Equals;
            case VK_OEM_MINUS: return Keys.Hyphen;
            case VK_OEM_4: return Keys.LeftBracket;
            case VK_OEM_6: return Keys.RightBracket;
            case VK_OEM_COMMA: return Keys.Comma;
            case VK_OEM_PERIOD: return Keys.Period;
            case VK_OEM_7: return Keys.Quote;
            case VK_OEM_5: return Keys.Backslash;
            case VK_OEM_3: return Keys.Tilde;
            case VK_ESCAPE: return Keys.Escape;
            case VK_SPACE: return Keys.Space;
            case VK_RETURN: return Keys.Enter;
            case VK_BACK: return Keys.Backspace;
            case VK_TAB: return Keys.Tab;
            case VK_PRIOR: return Keys.PageUp;
            case VK_NEXT: return Keys.PageDown;
            case VK_END: return Keys.End;
            case VK_HOME: return Keys.Home;
            case VK_INSERT: return Keys.Insert;
            case VK_DELETE: return Keys.Delete;
            case VK_ADD: return Keys.Add;
            case VK_SUBTRACT: return Keys.Subtract;
            case VK_MULTIPLY: return Keys.Multiply;
            case VK_DIVIDE: return Keys.Divide;
            case VK_PAUSE: return Keys.Pause;
            case VK_LEFT: return Keys.Left;
            case VK_RIGHT: return Keys.Right;
            case VK_UP: return Keys.Up;
            case VK_DOWN: return Keys.Down;
                
            default:
                if (code >= VK_F1 && code <= VK_F12)
                    return cast(Keys)(Keys.F1 + code - VK_F1);
                else if (code >= VK_NUMPAD0 && code <= VK_NUMPAD9)
                    return cast(Keys)(Keys.Numpad0 + code - VK_NUMPAD0);
                else if (code >= 'A' && code <= 'Z')
                    return cast(Keys)(Keys.A + code - 'A');
                else if (code >= '0' && code <= '9')
                    return cast(Keys)(Keys.Number0 + code - '0');
        }
        
        return Keys.Unknown;
    }

    KeyModifiers convertWinKeyModifiers() {
        KeyModifiers ret;

        if (HIWORD(GetKeyState(VK_MENU)) != 0)
            ret |= KeyModifiers.Alt;
        if (HIWORD(GetKeyState(VK_CONTROL)) != 0)
            ret |= KeyModifiers.Control;
        if (HIWORD(GetKeyState(VK_SHIFT)) != 0 || LOWORD(GetKeyState(VK_CAPITAL)) != 0)
            ret |= KeyModifiers.Shift;

        return ret;
    }
}