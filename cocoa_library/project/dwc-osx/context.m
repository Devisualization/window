//
//  context.m
//  dwc-osx
//
//  Created by Rikki Cattermole on 7/11/14.
//  Copyright (c) 2014 Rikki Cattermole. All rights reserved.
//

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
        printf("creating nonLegacy\n");
        pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes: glAttributes3Plus];
    } else {
        printf("creating legacy\n");
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