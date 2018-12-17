#include "sl.h"
#include <stdio.h>

int make_rectangle(int x, int y, int height, int width)
{
    slSetForeColor(0.5, 0.0, 0.5, 0.5);
    slRectangleFill(x, y, height, width);

    slSetForeColor(0.8, 0.8, 0.0, 0.8);
    slRectangleOutline(x, y, height, width);



    return 0;
}

#ifdef BUILD_TEST
int main()
{
    make_rectangle(175, 450, 50, 50);
    slRender();
    return 0;
}
#endif
