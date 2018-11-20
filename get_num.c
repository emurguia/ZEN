//simple built in function to try it out
#include <stdio.h>
void get_num(int a)
{
    printf("%d", a);
}
#ifdef BUILD_TEST
int main()
{
    get_num(10);
}
#endif
