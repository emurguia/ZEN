#include "sl.h"
#include <stdio.h>

int make_circle(int x, int y, int radius, int vertices)
{
        //slWindow(500, 500, "circle", 0);
        //slSetBackColor(0.0, 0.0, 0.0);

/*	printf("%d", vertices);

	printf("%d", x);
	printf("%d", y);
	printf("%d", radius);
	printf("\n");*/
//	x = (float)x;
//	y = (float)y;
	radius = (float)radius;
//	while(!slShouldClose() && !slGetKey(SL_KEY_ESCAPE))
  //      {
            slSetForeColor(0.0, 0.0, 0.5, 0.5);
	    slCircleFill(x, y, radius, vertices);
	    slSetForeColor(0.0, 0.0, 0.8, 0.8);
            slCircleOutline(x, y, radius, vertices);
//	    slSetForeColor(0.5, 0.0, 0.0, 0.5);
//            slTriangleFill(x, y, radius, radius);
//            slSetForeColor(0.8, 0.0, 0.0, 0.8);
//            slTriangleOutline(100.0, 450.0, 50.0, 50.0);



            slRender();
//        }
//        slClose();
	return 0;
}

#ifdef BUILD_TEST
int main()
{
	make_circle(325, 450, 25, 16);
        return 0;
	
}
#endif
