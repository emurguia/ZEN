#include "sl.h"
#include <stdio.h>

int render(){
    slRender();
    return 0; 
}

#ifdef BUILD_TEST
int main()
{
    render();
    return 0;
}
#endif