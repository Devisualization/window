#import <Cocoa/Cocoa.h>

int cocoaRunLoopIterate() {
    NSEvent* event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantFuture] inMode: NSDefaultRunLoopMode dequeue: YES];
    
    if (event != nil) {
        
        [NSApp sendEvent: event];
        [NSApp updateWindows];
        
        return 1;
    }
    
    return 0;
}