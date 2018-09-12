#include <stdio.h>
#include <stdlib.h>

int fib(int n)
{
     if (n < 2) {
	  return n;
     } else {
	  watch int x, y;
	  x = fib(n - 1);
	  y = fib(n - 2);
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
