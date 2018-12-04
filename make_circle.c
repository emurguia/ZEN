#include "sl.h"

void make_circle(float x, float y, float radius, int vertices)
{
        slWindow(500, 500, "circle", 0);
        slSetBackColor(1.0, 1.0, 1.0);

        while(!slShouldClose() && !slGetKey(SL_KEY_ESCAPE))
        {
            slSetForeColor(0.0, 0.0, 0.0, 0.5);
	    slCircleFill(x, y, radius, vertices);
	    slSetForeColor(0.0, 0.0, 0.8, 0.8);
            slCircleOutline(x, y, radius, vertices);


            slRender();
        }
        slClose();
}

int main()
{
	make_circle(325.0, 450.0, 25.0, 16);
	return 1;
}
