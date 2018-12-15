#include "sl.h"
#include <stdio.h>

int make_window()
{
    slWindow(500, 500, "ZEN", 0);
    slSetBackColor(0.0, 0.0, 0.0);
    return 0;
}
#ifdef BUILD_TEST
int main()
{
    make_window();
    return 0;
}
#endif
