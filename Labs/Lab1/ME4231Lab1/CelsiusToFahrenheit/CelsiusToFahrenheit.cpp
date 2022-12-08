// CelciusToFarenheit.cpp : This file contains the 'main' function. Program execution begins and ends there.
#include "stdio.h"    // old-school C "standard input-output" for old-school printf, scanf

/*
Best practice is to avoid what some call, "magic numbers" within code.
Think of them as constants relevant to an algorithm.
For this program we need a scale factor and an offset to convert from Celsius to Farenheit.
It is better to define them as here.
Then if you use them more than once and need to change it you will not have a mess to deal with.

The parentheses are decent practice to prevent order-of-operation oddities.
They are optional, and not needed in this case, but they don't hurt.

If you use them as force of habit then you will avoid a problem with something defined like

#define TROUBLE  4+5

What would you expect to happen in code somewhere if you want to compute...

x = TROUBLE*10;   // will this generate the result you want?

*/

#define C2F_SCALE  (9.0/5.0)  // The compiler replaces C2F_SCALE everywhere with  (9.0/5.0)  
#define C2F_OFFSET (32.0)     // same


int main()
{
	float tCel;
	float tFar;
	printf("Enter Degrees Celsius:.\n");  // \n is newline control character

	// Read user input into a float
	scanf_s("%f", &tCel);                   // scanf_s resolves compile-time  error: 'scanf': This function or variable may be unsafe

	// This is our conversion
	tFar = tCel * C2F_SCALE + C2F_OFFSET;

	//limit the precision displayed to 1 decimal point.
	printf("%0.1f degrees celsius converts to  %0.1f degrees Farenheit.\n", tCel, tFar);

}
