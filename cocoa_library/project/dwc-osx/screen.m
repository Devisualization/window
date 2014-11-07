#import <Cocoa/Cocoa.h>

int cocoaScreenHeight() {
    return [[NSScreen mainScreen] frame].size.height;
}

int cocoaScreenWidth() {
    return [[NSScreen mainScreen] frame].size.width;
}