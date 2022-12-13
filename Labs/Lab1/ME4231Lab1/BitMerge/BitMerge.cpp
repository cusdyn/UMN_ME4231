#include <stdio.h>

int bit_merge(unsigned short ms, unsigned short ls);

void main()
{
	unsigned short hn1 = 0x1234;
	unsigned short hn2 = 0xabcd;
	int result;

	result = bit_merge(hn2, hn1);

	printf("0x%x merges with 0x%x  resulting in 0x%x\n", hn2, hn1, result);
}

// here ms and ls denot most-significant and least significant for the merge.
// "most significant is pushed to left (endian-ness dependent but here this is the case)
int bit_merge(unsigned short ms, unsigned short ls)
{
	return(ms << 16 | ls); // note you could ADD after shift or OR as here.
}

