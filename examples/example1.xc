#include <stdio.h>
#include <stdlib.h>
#include <string.xh>

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
    
    if (argc != 2) {
         fprintf(stderr, "Usage: fib <n>\n");
         exit(1);
    }
    n = atoi(argv[1]);
    result = fib(n);
    
    printf("Result: %d\n", result);
    return 0; 
}
