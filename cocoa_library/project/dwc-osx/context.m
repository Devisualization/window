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
#import "dwc_cocoa.h"

static NSOpenGLPixelFormatAttribute glAttributesLegacy[] = {
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFADepthSize, 32,
    0
};

static NSOpenGLPixelFormatAttribute glAttributes3Plus[] = {
    NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFADepthSize, 32,
    0
};

void cocoaCreateOGLContext(int id, int minVersion) {
    NSWindowDWC* window = (NSWindowDWC*)[NSApp windowWithWindowNumber: id];
    
    NSOpenGLPixelFormat *pixelFormat;
    
    if (minVersion == 3) {
        pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes: glAttributes3Plus];
    } else {
        pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes: glAttributesLegacy];
    }
    
    [window setOpenGLContext: [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil]];
    [[window openGLContext] setView:[window contentView]];
}

void cocoaActivateOGLContext(int id) {
    NSWindowDWC* window = (NSWindowDWC*)[NSApp windowWithWindowNumber: id];
    [[window openGLContext] makeCurrentContext];
}

void cocoaDestroyOGLContext(int id) {
    NSWindowDWC* window = (NSWindowDWC*)[NSApp windowWithWindowNumber: id];
    [[window openGLContext] clearDrawable];
    [window setOpenGLContext: nil];
}

void cocoaSwapOGLBuffers(int id) {
    NSWindowDWC* window = (NSWindowDWC*)[NSApp windowWithWindowNumber: id];
    [[window openGLContext] flushBuffer];
}