#include <stdio.h>
#include <stdlib.h>
#include "string.xh"

int fib(int n) watch
{
	if (n < 2) {
		return n;
	} else {
		int x, y;
		x = fib(n-1);
		y = fib(n-2);
		return x + y;
	}
}

int main (int argc, char *argv[])
{
    int n, result;
    
    result = fib(10);
    
    printf("Result: %d\n", result);
    return 0; 
}
