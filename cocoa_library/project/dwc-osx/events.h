#import <Cocoa/Cocoa.h>

#ifndef dwc_osx_events_h
#define dwc_osx_events_h

    /**
     * Implementation for on Objective-C side
     */

    @interface NSWindowDWC : NSWindow
        -(int) lastX;
        -(int) lastY;

        -(void) setLastX: (int)value;
        -(void) setLastY: (int)value;
    @end

    /**
     * Interface definitions (for e.g. DWC usage)
     */

    enum CocoaMouseEventButton {
        Left = 0,
        Right = 1,
        Middle = 2
    };

    enum CocoaKeyModifiers : uint8 {
        None = 1 << 0,
        Shift = 1 << 1,
        Control = 1 << 2,
        Alt = 1 << 3,
        Super = 1 << 4
    };

    enum CocoaKeys {
        Unknown,
        F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,
        A, B, C, D, E, F, G, H, LetterI, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
        Number0, Number1, Number2, Number3, Number4, Number5, Number6, Number7, Number8, Number9,
        LeftBracket, RightBracket, Semicolon, Comma, Period, Quote, Slash, Backslash, Tilde, Equals, Hyphen,
        Escape, Space, Enter, Backspace, Tab, PageUp, PageDown, End, Home, Insert, Delete, Pause,
        LeftArrow, RightArrow, UpArrow, DownArrow,
        Numpad0, Numpad1, Numpad2, Numpad3, Numpad4, Numpad5, Numpad6, Numpad7, Numpad8, Numpad9,
        Add, Subtract, Multiply, Divide
    };

    /**
     * To be implemented code on the D side
     */

    void cocoaEventMouseDown(int window, enum CocoaMouseEventButton button, float x, float y);
    void cocoaEventMouseUp(int window, enum CocoaMouseEventButton button, float x, float y);
    void cocoaEventMouseMove(int window, float x, float y);
    void cocoaEventOnClose(int window);
    void cocoaEventOnResize(int window, int width, int height);
    void cocoaEventOnMove(int window, int x, int y);
    void cocoaEventOnKeyDown(int window, uint8 modifiers, enum CocoaKeys key);
    void cocoaEventOnKeyUp(int window, uint8 modifiers, enum CocoaKeys key);
#endif
