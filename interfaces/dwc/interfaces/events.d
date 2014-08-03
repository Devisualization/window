module dwc.interfaces.events;

enum MouseButtons {
    Left,
    Right,
    Middle
}

enum KeyModifiers : ubyte {
    None = 1 << 0,
    Shift = 1 << 1,
    Control = 1 << 2,
    Alt = 1 << 3
}

enum Keys {
    Unknown,
    F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,
    A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
    Number0, Number1, Number2, Number3, Number4, Number5, Number6, Number7, Number8, Number9,
    LeftBracket, RightBracket, Semicolon, Comma, Period, Quote, Slash, Backslash, Tilde, Equals, Hyphen,
    Escape, Space, Enter, Backspace, Tab, PageUp, PageDown, End, Home, Insert, Delete, Pause,
    Left, Right, Up, Down,
    Numpad0, Numpad1, Numpad2, Numpad3, Numpad4, Numpad5, Numpad6, Numpad7, Numpad8, Numpad9,
    Add, Subtract, Multiply, Divide
}