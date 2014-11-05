#import "events.h"

#ifndef dwc_osx_dwc_cocoa_h
#define dwc_osx_dwc_cocoa_h

/**
 * Initiates the cocoa runtime for the application
 */
void cocoaInit();

struct CocoaWindowData {
    int x;
    int y;
    int width;
    int height;
    char* title;
};

/**
 * Creates a Cocoa window
 *
 * Returns
 *      pointer to the NSWindow object
 */
int cocoaCreateWindow(struct CocoaWindowData data);

/**
 * Runs an iteration of the runloop
 *
 * Returns:
 *      1 on event handled
 *      0 on no event handled
 */
int cocoaRunLoopIterate();

/**
 * Gets the height of the main screen
 *
 * Returns
 *      0 on failure
 *      Otherwise the height of screen
 */
int cocoaScreenHeight();

/**
 * Gets the width of the main screen
 *
 * Returns
 *      0 on failure
 *      Otherwise the width of screen
 */
int cocoaScreenWidth();

/**
 * Shows a given NSWindow*
 */
void cocoaShowWindow(int window);

/**
 * Hides an NSWindow*
 */
void cocoaHideWindow(int window);

/**
 * Closes a window
 */
void cocoaCloseWindow(int window);

/**
 * Is a window id valid?
 *
 * Returns
 *      1 if valid
 *      0 if not valid
 */
int cocoaValidWindow(int window);

//icon
// need to be able to save the icon to file
// as a file it can be used as an icon
void cocoaSetIcon(int window, unsigned char** rgba, int width, int height);

/**
 * Sets the windows title
 */
void cocoaSetTitle(int window, char* title);

/**
 * Sets the content areas size
 */
void cocoaSetSize(int window, int width, int height);

/**
 * Moves a window
 */
void cocoaSetPosition(int window, int x, int y);

/**
 * Sets if the window can be resized
 */
void cocoaCanResize(int window, int can);

/**
 * Makes the window fullscreen (or not)
 */
void cocoaFullScreen(int id, int is);

    #if 1
        void test() {
            unsigned char* icon = malloc(4*4);
            
            icon[0] = 255;
            icon[1] = 0;
            icon[2] = 0;
            icon[3] = 255;
            
            icon[5] = 255;
            icon[7] = 255;
            
            icon[10] = 255;
            icon[11] = 255;
            
            icon[15] = 255;
            
            cocoaInit();
            
            struct CocoaWindowData cArgs = {0, 0, 200, 200, "test"};
            int window = cocoaCreateWindow(cArgs);
            cocoaSetIcon(window, &icon, 2, 2);
            //cocoaHideWindow(window);
            //cocoaShowWindow(window);
            
            while(true) {
                if (cocoaRunLoopIterate()) {
                    // do something
                    
                } else {
                    // thread sleep
                }
            }
        }
    #endif

#endif
