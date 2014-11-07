#import "events.h"

@implementation NSWindowDWC
    int lastX_;
    int lastY_;

    -(int) lastX {
        return lastX_;
    }

    -(int) lastY {
        return lastY_;
    }

    -(void) setLastX: (int)value {
        lastX_ = value;
    }

    -(void) setLastY: (int)value {
        lastY_ = value;
    }

    /**
     * Mouse down events (left, middle and right)
     */

    -(void)mouseDown: (NSEvent*)theEvent {
        [super mouseDown:theEvent];
    
        NSPoint location = [self mouseLocationOutsideOfEventStream];
        NSInteger height = self.frame.size.height;
    
        cocoaEventMouseDown((int)[self windowNumber], Left, location.x, height - location.y);
    }

    -(void)rightMouseDown:(NSEvent *)theEvent {
        [super mouseDown:theEvent];
    
        NSPoint location = [self mouseLocationOutsideOfEventStream];
        NSInteger height = self.frame.size.height;
    
        cocoaEventMouseDown((int)[self windowNumber], Right, location.x, height - location.y);
    }

    -(void) otherMouseDown:(NSEvent *)theEvent{
        [super mouseDown:theEvent];
    
        NSPoint location = [self mouseLocationOutsideOfEventStream];
        NSInteger height = self.frame.size.height;
    
        cocoaEventMouseDown((int)[self windowNumber], Middle, location.x, height - location.y);
    }

    /**
     * Mouse up events (left, middle, right)
     */

    -(void)mouseUp:(NSEvent *)theEvent {
        [super mouseDown:theEvent];
    
        NSPoint location = [self mouseLocationOutsideOfEventStream];
        NSInteger height = self.frame.size.height;
    
        cocoaEventMouseUp((int)[self windowNumber], Left, location.x, height - location.y);
    }

    -(void)rightMouseUp:(NSEvent *)theEvent {
        [super mouseDown:theEvent];
    
        NSPoint location = [self mouseLocationOutsideOfEventStream];
        NSInteger height = self.frame.size.height;
    
        cocoaEventMouseUp((int)[self windowNumber], Right, location.x, height - location.y);
    }

    -(void) otherMouseUp:(NSEvent *)theEvent {
        [super mouseDown:theEvent];
    
        NSPoint location = [self mouseLocationOutsideOfEventStream];
        NSInteger height = self.frame.size.height;
    
        cocoaEventMouseUp((int)[self windowNumber], Middle, location.x, height - location.y);
    }

    /**
     * Mouse move events
     */

    -(void) mouseMoved:(NSEvent *)theEvent {
        [super mouseDown:theEvent];
    
        NSRect windowLocation = [self frame];
        NSPoint location = [self mouseLocationOutsideOfEventStream];
        NSInteger height = self.frame.size.height;
    
        if (location.x >= 0 &&
            location.y >= 0 &&
            location.x <= windowLocation.size.width &&
            location.y <= windowLocation.size.height
            ) {
            cocoaEventMouseMove((int)[self windowNumber], location.x, height - location.y);
        }
    }

    -(void)close {
        int id = (int)[self windowNumber];
        [super close];
    
        cocoaEventOnClose(id);
    }

    -(void)windowResized:(NSNotification *)notification {
        NSRect contentRect = [self contentRectForFrameRect: [self frame]];
        cocoaEventOnResize((int)[self windowNumber], contentRect.size.width, contentRect.size.height);
    }

    -(void) windowMoved:(NSNotification *)notification {
        NSRect contentRect = [self frame];
        NSInteger height = [[self screen] frame].size.height;
        
        cocoaEventOnMove((int)[self windowNumber], contentRect.origin.x, height - (contentRect.origin.y + contentRect.size.height));
    }

    -(void) keyDown:(NSEvent *)theEvent {
        uint8 modifiers = [self _getModifierFromCode: [theEvent modifierFlags]];
        enum CocoaKeys key = [self _getKeyFromKeyCode: [theEvent keyCode]];
    
        cocoaEventOnKeyDown((int)[self windowNumber], modifiers, key);
    }

    -(void) keyUp:(NSEvent *)theEvent {
        uint8 modifiers = [self _getModifierFromCode: [theEvent modifierFlags]];
        enum CocoaKeys key = [self _getKeyFromKeyCode: [theEvent keyCode]];
    
        cocoaEventOnKeyUp((int)[self windowNumber], modifiers, key);
    }

    - (uint8) _getModifierFromCode: (NSEventModifierFlags) modifiers {
        uint8 ret = 0;
    
        if (modifiers & NSAlphaShiftKeyMask || modifiers & NSShiftKeyMask) {
            ret |= Shift;
        }
    
        if (modifiers & NSControlKeyMask) {
            ret |= Control;
        }
    
        if (modifiers & NSAlternateKeyMask) {
            ret |= Alt;
        }
    
        if (modifiers & NSCommandKeyMask) {
            ret |= Super;
        }
    
        return ret;
    }

    - (enum CocoaKeys) _getKeyFromKeyCode: (unsigned int) keyCode {
        enum CocoaKeys ret = Unknown;
    
        switch(keyCode) {
                /*
                 * ASFDGHJKL;'
                 */
                 
            case 0:
                ret = A;
                break;
            case 1:
                ret = S;
                break;
            case 2:
                ret = D;
                break;
            case 3:
                ret = F;
                break;
            case 5:
                ret = G;
                break;
            case 4:
                ret = H;
                break;
            case 38:
                ret = J;
                break;
            case 40:
                ret = K;
                break;
            case 37:
                ret = L;
                break;
            case 41:
                ret = Semicolon;
                break;
            case 39:
                ret = Quote;
                break;
            
                /*
                 *ZXCVBNM,./
                 */
                 
            case 6:
                ret = Z;
                break;
            case 7:
                ret = X;
                break;
            case 8:
                ret = C;
                break;
            case 9:
                ret = V;
                break;
            case 11:
                ret = B;
                break;
            case 45:
                ret = N;
                break;
            case 46:
                ret = M;
                break;
            case 43:
                ret = Comma;
                break;
            case 47:
                ret = Period;
                break;
            case 44:
                ret = Slash;
                break;
            
                /*
                 * QWERTYUIOP[]\
                 */
            
            case 12:
                ret = Q;
                break;
            case 13:
                ret = W;
                break;
            case 14:
                ret = E;
                break;
            case 15:
                ret = R;
                break;
            case 17:
                ret = T;
                break;
            case 16:
                ret = Y;
                break;
            case 32:
                ret = U;
                break;
            case 34:
                ret = LetterI;
                break;
            case 31:
                ret = O;
                break;
            case 35:
                ret = P;
                break;
            case 33:
                ret = LeftBracket;
                break;
            case 30:
                ret = RightBracket;
                break;
            case 42:
                ret = Backslash;
                break;
            
                /*
                 * `1234567890-=
                 */
            
            case 50:
                ret = Tilde;
                break;
            case 18:
                ret = Number1;
                break;
            case 19:
                ret = Number2;
                break;
            case 20:
                ret = Number3;
                break;
            case 21:
                ret = Number4;
                break;
            case 23:
                ret = Number5;
                break;
            case 22:
                ret = Number6;
                break;
            case 26:
                ret = Number7;
                break;
            case 28:
                ret = Number8;
                break;
            case 25:
                ret = Number9;
                break;
            case 29:
                ret = Number0;
                break;
            case 27:
                ret = Hyphen;
                break;
            case 24:
                ret = Equals;
                break;
            
                /*
                 * Escape, F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12
                 */
            
            case 53:
                ret = Escape;
                break;
            case 122:
                ret = F1;
                break;
            case 120:
                ret = F2;
                break;
            case 99:
                ret = F3;
                break;
            case 118:
                ret = F4;
                break;
            case 96:
                ret = F5;
                break;
            case 97:
                ret = F6;
                break;
            case 98:
                ret = F7;
                break;
            case 100:
                ret = F8;
                break;
            case 101:
                ret = F9;
                break;
            case 109:
                ret = F10;
                break;
            case 103:
                ret = F11;
                break;
            case 111:
                ret = F12;
                break;
            
                /*
                 * Enter, Tab, BackSpace, Space
                 */
            
            case 36:
                ret = Enter;
                break;
            case 48:
                ret = Tab;
                break;
            case 51:
                ret = Backspace;
                break;
            case 49:
                ret = Space;
                break;
            
                /*
                 * Arrows: left, right, up, down
                 */
            
            case 126:
                ret = LeftArrow;
                break;
            case 123:
                ret = RightArrow;
                break;
            case 124:
                ret = UpArrow;
                break;
            case 125:
                ret = DownArrow;
                break;
        }
    
        return ret;
    }

@end
