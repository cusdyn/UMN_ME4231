// ParityCheck.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <stdio.h>

void main(int argc, char* argv[])
{
	unsigned int val=0;
	int k = 0;
	int parity = 0;  // even=0

	if (argc != 2)
	{
		puts("Enter a ASCII hex char pair in format FF. For example.. ParityCheck AB <enter>");
		return;
	}

	sscanf_s(argv[1], "%x", &val);

	while (k < 7)
	{
		// exclusive or (XOR) down the bit field.
		parity ^= ((1 << k) & val) >> k;

		k++;
	}
	
	printf("val=%x  parity=%d (0=even)\n", val, parity);

	if ( !parity != (val >> 7))
	{
		printf("Parity Error");
	}
	
}
