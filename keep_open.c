#include "sl.h"
#include <stdio.h>

bool keep_open()
{
    return !slShouldClose() && !slGetKey(SL_KEY_ESCAPE);
}
#ifdef BUILD_TEST
int main()
{
    keep_open();
    return 0;
}
