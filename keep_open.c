#include "sl.h"
#include <stdio.h>

int keep_open()
{
    return !slShouldClose() && !slGetKey(SL_KEY_ESCAPE);
}
#ifdef BUILD_TEST
int main()
{
    keep_open();
    return 0;
}
#endif
