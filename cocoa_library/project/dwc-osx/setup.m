#import <Cocoa/Cocoa.h>

void cocoaInit() {
    [NSApplication sharedApplication];
    [NSApp setActivationPolicy: NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps: YES];
}