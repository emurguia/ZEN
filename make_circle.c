#include "sl.h"

void make_circle(float x, float y, float radius, int vertices)
{
        slWindow(500, 500, "circle", false);
        slSetBackColor(1.0, 1.0, 1.0);

        while(!slShouldClose() && !slGetKey(SL_KEY_ESCAPE))
        {
            slSetForeColor(0.0, 0.0, 0.0, 0.0);
            slCircleOutline(x, y, radius, vertices);

            slRender();
        }
        slClose();
}
