#include "sl.h"
#include <stdio.h>

int make_point(int x, int y)
{
    //x = (float)x;
    //y = (float)y;

    slSetForeColor(200.0, 100.0, 0.0, 1.0);
    slPoint(x, y);

    slRender();
    return 0;
}
#ifdef BUILD_TEST
int main()
{
    make_point(100, 25);
    return 0;
}
