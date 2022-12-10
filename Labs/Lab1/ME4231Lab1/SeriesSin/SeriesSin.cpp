// SeriesSin.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "stdio.h"
#include "math.h"

#define MAX_DIFFERENCE_ALLOWED (0.000001)

// long long (64 bit integer) to hold large factorial result.
// not needed for the two lab test values.
unsigned long long factorial(unsigned long long n)
{
	if (n == 0)
		return 1;
	return n * factorial(n - 1);
}


int main(int argc, char* argv[])
{
	double libsin;
	float  x;
	double approx = 0;
	int i = 3;
	int sign = -1;

	if (argc != 2)
	{
		puts("please enter an argument for sin calculation.");
		return 0;
	}

	sscanf_s(argv[1], "%f", &x);
	
	libsin = sin(x);

	approx = x;
	while (fabs(libsin - approx) > MAX_DIFFERENCE_ALLOWED)
	{
		unsigned long long fact = factorial(i);
		printf("factorial(%d)=%d\n", i, fact);
		approx += sign*pow(x,i) / fact;
		sign *= -1;
		i += 2;
	}

	printf("library sin(%0.3f) result=%0.7f\n", x, libsin);
	printf("Approx  sin(%0.3f) result=%0.7f after %d terms",x, approx, (i-1)/2);
}

