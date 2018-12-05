#include "sl.h"
#include <stdio.h>

void make_circle(float x, float y, float radius, int vertices)
{
        slWindow(500, 500, "circle", 0);
        slSetBackColor(0.0, 0.0, 0.0);
        while(!slShouldClose() && !slGetKey(SL_KEY_ESCAPE))
        {
            slSetForeColor(0.0, 0.0, 0.5, 0.5);
	    slCircleFill(x, y, radius, vertices);
	    printf("%f", x);
	    slSetForeColor(0.0, 0.0, 0.8, 0.8);
            slCircleOutline(x, y, radius, vertices);
	    slSetForeColor(0.5, 0.0, 0.0, 0.5);
            slTriangleFill(x, y, radius, radius);
            slSetForeColor(0.8, 0.0, 0.0, 0.8);
            slTriangleOutline(100.0, 450.0, 50.0, 50.0);



            slRender();
        }
        slClose();
}

#ifdef BUILD_TEST
int main()
{
	make_circle(325.0, 450.0, 25.0, 16);
	
}
#endif
