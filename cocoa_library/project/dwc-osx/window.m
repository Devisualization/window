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
    
    NSWindowDWC* window = [[NSWindowDWC alloc]
                        initWithContentRect: NSMakeRect(data.x, cocoaScreenHeight() - data.y, data.width, data.height)
                        styleMask: NSResizableWindowMask | NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
                        backing: NSBackingStoreBuffered
                        defer: NO];
    [window setAcceptsMouseMovedEvents: YES];
    
    NSNumber* windowNumber = [NSNumber numberWithInt: (int)[window windowNumber]];
    [windows setObject: window forKey: windowNumber];
    
    [NSApp beginModalSessionForWindow: window];
    [window makeKeyAndOrderFront: nil];
    [windowSizes setObject: NSStringFromRect([window frame]) forKey: windowNumber];
    
    cocoaSetTitle(windowNumber.intValue, data.title);
    cocoaSetSize(windowNumber.intValue, data.width, data.height);
    cocoaSetPosition(windowNumber.intValue, data.x, data.y);
    
    [[NSNotificationCenter defaultCenter] addObserver: window
                                             selector: @selector(windowResized:) name:NSWindowDidResizeNotification
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
    NSWindow* window = [NSApp windowWithWindowNumber: id];
    
    NSRect previousSize = NSRectFromString([windowSizes objectForKey: [NSNumber numberWithInt: id]]);
    previousSize.size.width = width;
    previousSize.size.height = height;
    [windowSizes setObject: NSStringFromRect(previousSize) forKey: [NSNumber numberWithInt: id]];
    
    [window setContentSize: NSMakeSize(width, height)];
}

void cocoaSetPosition(int id, int x, int y) {
    NSWindow* window = [NSApp windowWithWindowNumber: id];
    y = cocoaScreenHeight() - y;
    
    NSRect previousSize = NSRectFromString([windowSizes objectForKey: [NSNumber numberWithInt: id]]);
    previousSize.origin.x = x;
    previousSize.origin.y = y;
    [windowSizes setObject: NSStringFromRect(previousSize) forKey: [NSNumber numberWithInt: id]];
    
    [window setFrame: previousSize display: YES animate: YES];
}

void cocoaCanResize(int id, int can) {
    NSWindow* window = [NSApp windowWithWindowNumber: id];
    
    if (can) {
        [window setStyleMask: NSResizableWindowMask | NSTitledWindowMask | NSClosableWindowMask];
    } else {
        [window setStyleMask: NSTitledWindowMask | NSClosableWindowMask];
    }
}

void cocoaFullScreen(int id, int is) {
    NSWindow* window = [NSApp windowWithWindowNumber: id];
    
    if (is == ([window styleMask] & NSFullScreenWindowMask)) {
    } else {
        [window toggleFullScreen: window];
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