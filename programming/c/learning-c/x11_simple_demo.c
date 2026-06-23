/*
* Creates a simple X11 window directly. 
* Compilation: clang x11_simple_demo.c -o x11_simple_demo -lX11 
*/

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
  // 1. Open connection to X server
  Display *display = XOpenDisplay(NULL);
  if (!display) {
    fprintf(stderr, "Cannot open display\n");
    return 1;
  }

  // 2. Get default screen and create window
  int screen = DefaultScreen(display);
  Window window = XCreateSimpleWindow(
      display, RootWindow(display, screen), 100, 100, // x, y
      800, 600,                                       // width, height
      1,                                              // border width
      BlackPixel(display, screen), WhitePixel(display, screen));

  // 3. Set window title
  XStoreName(display, window, "Minimal X11 Window");

  // 4. Handle window close event
  Atom WM_DELETE_WINDOW = XInternAtom(display, "WM_DELETE_WINDOW", False);
  XSetWMProtocols(display, window, &WM_DELETE_WINDOW, 1);

  // 5. Show the window
  XMapWindow(display, window);

  // 6. Create a graphics context for drawing
  GC gc = XCreateGC(display, window, 0, NULL);
  XSetForeground(display, gc, BlackPixel(display, screen));

  // 7. Event loop
  XEvent event;
  int running = 1;
  while (running) {
    XNextEvent(display, &event);

    switch (event.type) {
    case Expose:
      // Draw a rectangle when window needs redraw
      XDrawRectangle(display, window, gc, 50, 50, 200, 150);
      XFillRectangle(display, window, gc, 300, 200, 100, 75);
      break;
    case ClientMessage:
      if ((Atom)event.xclient.data.l[0] == WM_DELETE_WINDOW) {
        running = 0;
      }
      break;
    }
  }

  // 8. Cleanup
  XFreeGC(display, gc);
  XDestroyWindow(display, window);
  XCloseDisplay(display);

  return 0;
}