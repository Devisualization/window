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
#import <Cocoa/Cocoa.h>

/**
 * @param minBlocking Will always be handled
 * @param maxNonBlocking Will not always be 100% handled. Return true if the last one completed all.
 */
int cocoaRunLoopIterate(unsigned int minBlocking, unsigned int maxNonBlocking) {
    unsigned int i;
    
    // minBlocking
    while(i < minBlocking) {
        NSEvent* event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantFuture] inMode: NSDefaultRunLoopMode dequeue: YES];
        [NSApp sendEvent: event];
        [NSApp updateWindows];
        i++;
    }
    
    
    // maxNonBlockings
    i = 0;
    Boolean last = true;
    while(last) {
        NSEvent* event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantPast] inMode: NSDefaultRunLoopMode dequeue: YES];
    
        if (event != nil) {
        
            [NSApp sendEvent: event];
            [NSApp updateWindows];
        } else {
            last = false;
        }
        
        i++;
    }
    
    return 0;
}