// RCcircuitResponse.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include<stdio.h>
#include<stdlib.h>

#define VIN (1.0)  // constant input voltage

static void print_usage() 
{
	printf("usage:  RCcircuitResponse T h R C where...\n");
	printf("T = duration    (seconds).\n");
	printf("h = time step   (seconds).\n");
	printf("R = resistance  (ohms).\n");
	printf("C = capacitance (farads).\n");
}

int main(int argc, char* argv[])
{
	float tsim;
	float h;
	float R;
	float C;
	float a;
	int len;
	float *vout;  // we don't know vector size yet 
	int k;
	FILE *ofp;

	if (argc != 5)
	{
		print_usage();
		return 0;
	}

	// it would be wise to bounds-check the input params but for brevity, skip it.
	sscanf_s(argv[1], "%f", &tsim);
	sscanf_s(argv[2], "%f", &h);
	sscanf_s(argv[3], "%f", &R);
	sscanf_s(argv[4], "%f", &C);

	len = tsim / h;   // required vector lengths

	a = -1 / (R * C);

	vout = (float*)malloc(len * sizeof(float));

	fopen_s(&ofp, "RCout.txt", "w");
	fprintf(ofp, "R,%f\n", R);
	fprintf(ofp, "C,%f\n", C);
	fprintf(ofp, "time,volts\n");
	vout[0] = 0.0;  // at switch closure voltage across capacitor is zero
	fprintf(ofp, "%f,%f\n", 0.0,vout[0]);
	printf("%0.3f\n", vout[0]);
	for (k = 1; k < len; k++)
	{
		vout[k] =  (1+a*h)*vout[k-1] - a*h*VIN;
		fprintf(ofp, "%f,%f\n", k*h,vout[k]);
		printf("%0.3f\n", vout[k]);
	}
	fclose(ofp);

	free(vout); // explicit memory clean-up
}

