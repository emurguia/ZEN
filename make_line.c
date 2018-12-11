#include "sl.h"
#include <stdio.h>

int make_line(int x1, int y1, int x2, int y2)
{
/*    x1 = (float)x1;
    y1 = (float)y1;
    x2 = (float)x2;
    y2 = (float)y2;
*/
    slSetForeColor(0.5, 0.7, 0.0, 0.9);
    slLine(x1, y1, x2, y2);

    slRender();

    return 0;
}
#ifdef BUILD_TEST
int main()
{
    make_line(100.0, 400.0, 400.0, 400.0);
    return 0;
}


