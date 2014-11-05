#import <Cocoa/Cocoa.h>

int cocoaScreenHeight() {
    NSArray* screens = [NSScreen screens];
    if ([screens count] == 0)
        return 0;
    
    return [[screens objectAtIndex: 0] visibleFrame].size.height;
}

int cocoaScreenWidth() {
    NSArray* screens = [NSScreen screens];
    if ([screens count] == 0)
        return 0;
    
    return [[screens objectAtIndex: 0] visibleFrame].size.width;
}