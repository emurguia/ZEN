#include "sl.h"
#include <stdio.h>

int close_window()
{
    slClose();
    return 0;
}
#ifdef BUILD_TEST
int main()
{
    close_window();
    return 0;
}
#endif
