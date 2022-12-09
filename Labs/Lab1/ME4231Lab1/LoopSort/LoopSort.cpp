#include "stdlib.h"
#include "stdio.h"

/*
This is like a "define" for data types in C.
you don't need to use it, but in this sample app
it permits you to play with changing the type (size)
of data we're sorting.
*/
typedef long long MY_DATA_TYPE;  // you could type define this as signd or unsiged char, short, int long long

int main()
{
	// Most code is best when variables are declared atop each function (or method).
	// compilers will let you in-line declare variables but it's good practice to  do it up-top.
	// Initializing isn't always required. We're being strict in this case.

	MY_DATA_TYPE in[] = { 9,4,5,2,3,0,8,1,7,6 }; // our input array is a constant.

	MY_DATA_TYPE n = 0;
	MY_DATA_TYPE temp;

	printf("Each element of your data array occupies %d bytes of RAM\n", sizeof(MY_DATA_TYPE));

	// for a count of our variable of interest we need to divide
	// bytes occupied by the input array by the size of each element.
	n = sizeof(in) / sizeof(MY_DATA_TYPE);

	// this is called a "bubble sort"
	// You can find many references to it: https://www.cs.princeton.edu/courses/archive/spr09/cos226/demo/ah/BubbleSort.html
	// .. and crticisms on it's efficiency. It's relatively easy to observe how it works though.

	printf("\nInput Array {");
	for (int i = 0; i < n-1; i++) {
		printf("%d,",in[i]);
	}
	printf("%d}  Sorts as...\n\n", in[n-1]);

	for (int i = 0; i < n - 1; i++) {              // only to n-1 because inner loop pushes terminal value to there in the first pass.
		for (int j = 0; j < n - 1 - i; j++)        // inner loop goes no farther than i indicates values have been pushed to the end

			// notice how inner loop will push the highest number to the end on the first trip,
			// and so on for each outer loop iteration.
			if (in[j + 1] < in[j]) {               // if next value less
				// if so we swap them
				temp = in[j];
				in[j] = in[j + 1];  // pull next down in the array
				in[j + 1] = temp;   // push this up to that spot.
		}

		printf("Pass %d: {", i+1);
		for (int i = 0; i < n-1; i++) {
			printf("%d,", in[i]);
		}
		printf("%d}\n", in[n - 1]);
	}

	printf("\n");
}

