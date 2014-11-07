#import <Foundation/Foundation.h>
#import <AppKit/NSEvent.h>
#import "dwc_cocoa.h"

NSMutableDictionary* windows;
NSMutableDictionary* windowSizes;

int cocoaCreateWindow(struct CocoaWindowData data) {
    if (windows == nil) {
        windows = [[NSMutableDictionary alloc] init];
        windowSizes = [[NSMutableDictionary alloc] init];
    }
    
    // not 100% on x/y/width/height estimates based upon input so not too much of a change visually
    NSWindowDWC* window = [[NSWindowDWC alloc]
                        initWithContentRect: NSMakeRect(data.x, cocoaScreenHeight() - data.y, data.width, data.height)
                        styleMask: NSResizableWindowMask | NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
                        backing: NSBackingStoreBuffered
                        defer: NO];
    [window setAcceptsMouseMovedEvents: YES];
    [window setLastX: data.x];
    [window setLastY: data.y];
    
    NSNumber* windowNumber = [NSNumber numberWithInt: (int)[window windowNumber]];
    [windows setObject: window forKey: windowNumber];
    
    [NSApp beginModalSessionForWindow: window];
    [window makeKeyAndOrderFront: nil];
    [windowSizes setObject: NSStringFromRect([window frame]) forKey: windowNumber];
    
    cocoaSetTitle(windowNumber.intValue, data.title);
    cocoaSetPosition(windowNumber.intValue, data.x, data.y);
    cocoaSetSize(windowNumber.intValue, data.width, data.height);
    
    [[NSNotificationCenter defaultCenter] addObserver: window
                                             selector: @selector(windowResized:) name:NSWindowDidResizeNotification
                                               object: window];
    [[NSNotificationCenter defaultCenter] addObserver: window
                                             selector: @selector(windowMoved:) name:NSWindowDidMoveNotification
                                               object: window];
    
    return windowNumber.intValue;
}

void cocoaShowWindow(int id) {
    NSWindow* window = [NSApp windowWithWindowNumber: id];
    [window makeKeyAndOrderFront: nil];
    
    NSRect previousSize = NSRectFromString([windowSizes objectForKey: [NSNumber numberWithInt: id]]);
    [window setFrameOrigin: previousSize.origin];
}

void cocoaHideWindow(int id) {
    NSWindow* window = [NSApp windowWithWindowNumber: id];
    [window orderOut: window];
}

void cocoaCloseWindow(int id) {
    NSWindow* window = [NSApp windowWithWindowNumber: id];
    [window close];
    
    NSNumber* windowNumber = [NSNumber numberWithInt: id];
    [windows removeObjectForKey: windowNumber];
    [windowSizes removeObjectForKey: windowNumber];
}

int cocoaValidWindow(int id) {
    return [windows objectForKey: [NSNumber numberWithInt: id]] != nil;
}

void cocoaSetTitle(int id, char* title) {
    NSWindow* window = [NSApp windowWithWindowNumber: id];
    
    [window setTitle:
     [[NSString alloc]
      initWithUTF8String: title]];
}

void cocoaSetSize(int id, int width, int height) {
    NSWindowDWC* window = (NSWindowDWC*)[NSApp windowWithWindowNumber: id];
    
    NSRect previousSize = [window contentRectForFrameRect: [window frame]];
    previousSize.size.width = width;
    previousSize.size.height = height;
    [windowSizes setObject: NSStringFromRect(previousSize) forKey: [NSNumber numberWithInt: id]];
    
    [window setContentSize: NSMakeSize(width, height)];
    cocoaSetPosition(id, [window lastX], [window lastY]);
}

void cocoaSetPosition(int id, int x, int y) {
    NSWindowDWC* window = (NSWindowDWC*)[NSApp windowWithWindowNumber: id];
    [window setLastX: x];
    [window setLastY: y];
    
    y += [window frame].size.height;
    y = [[window screen] frame].size.height - y;
    
    NSRect previousSize = [window contentRectForFrameRect: [window frame]];
    previousSize.origin.x = x;
    previousSize.origin.y = y;
    [windowSizes setObject: NSStringFromRect(previousSize) forKey: [NSNumber numberWithInt: id]];
    
    [window setFrame: previousSize display: YES animate: YES];
}

void cocoaCanResize(int id, int can) {
    NSWindow* window = [NSApp windowWithWindowNumber: id];
    
    if (can) {
        [window setStyleMask: NSResizableWindowMask | NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask];
    } else {
        [window setStyleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask];
    }
}

void cocoaFullScreen(int id, int is) {
    NSWindow* window = [NSApp windowWithWindowNumber: id];
    
    if (([window styleMask] & NSFullScreenWindowMask)) {
        if (is) {
            [[window contentView] enterFullScreenMode: [NSScreen mainScreen] withOptions: nil];
        } else {
            [[window contentView] exitFullScreenModeWithOptions: nil];
        }
    }
}

void cocoaSetIcon(int id, unsigned char** rgba, int width, int height) {
    NSWindow* window = [NSApp windowWithWindowNumber: id];
    
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: rgba
                                            pixelsWide: width
                                            pixelsHigh: height
                                         bitsPerSample: 8
                                       samplesPerPixel: 4
                                              hasAlpha: YES
                                              isPlanar: NO
                                        colorSpaceName: NSDeviceRGBColorSpace
                                          bitmapFormat: 0
                                           bytesPerRow: width * 4
                                          bitsPerPixel: 32];

    [imageRep setSize:NSMakeSize(16, 16)];
    NSData *data = [imageRep representationUsingType: NSPNGFileType properties: nil];
    [window setRepresentedURL:[NSURL fileURLWithPath: [window title]]];
    
    NSImage* image = [[NSImage alloc] initWithData: data];
    [image setSize: NSMakeSize(16, 16)];
    [[window standardWindowButton:NSWindowDocumentIconButton] setImage: image];
}