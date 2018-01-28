#include <stdio.h>
#include <stdlib.h>
#include "string.xh"

int fib(int n) <watch>
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

int main(int argc, char *argv[])
{
	if (argc != 2) {
		fprintf(stderr, "Usage: fib <n>\n");
		exit(1);
	}

	printf("Result: %d\n", fib(atoi(argv[1])));
	return 0; 
}

