#include "sl.h"
#include <stdio.h>

int make_triangle(int x, int y, int height, int width)
{
        //slWindow(500, 500, "triangle", 0);
        //slSetBackColor(0.0, 0.0, 0.0);
        //while(!slShouldClose() && !slGetKey(SL_KEY_ESCAPE))
       // {
        //    printf("%f", x);
            slSetForeColor(0.5, 0.0, 0.0, 0.5);
            slTriangleFill(x, y, height, width);
            slSetForeColor(0.8, 0.0, 0.0, 0.8);
            slTriangleOutline(x,y,height,width);



    //    }
    //    slClose();
}

#ifdef BUILD_TEST
int main()
{
        make_triangle(100, 450, 50, 50);

}
#endif

