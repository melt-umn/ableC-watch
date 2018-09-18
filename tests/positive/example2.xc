#include <stdio.h>
#include <stdlib.h>
#include "string.xh"

int main(int argc, char *argv[])
{
    watch int sum = 0;
    for (int i=0; i < 5; ++i) {
        sum = sum + (rand() % 5);
    }
    printf("sum: %d\n", sum);
    
    return 0; 
}

