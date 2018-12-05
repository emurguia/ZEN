#include "sl.h"
#include <stdio.h>

void make_triangle(float x, float y, float height, float width)
{
        slWindow(500, 500, "triangle", 0);
        slSetBackColor(0.0, 0.0, 0.0);
        while(!slShouldClose() && !slGetKey(SL_KEY_ESCAPE))
        {
            printf("%f", x);
            slSetForeColor(0.5, 0.0, 0.0, 0.5);
            slTriangleFill(x, y, height, width);
            slSetForeColor(0.8, 0.0, 0.0, 0.8);
            slTriangleOutline(x,y,height,width);



            slRender();
        }
        slClose();
}

#ifdef BUILD_TEST
int main()
{
        make_triangle(100.0, 450.0, 50.0, 50.0);

}
#endif

