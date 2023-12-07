/* 
 * CSCI3240: Project 2
 * Brent Yelle - bjy2h
 */


// This function uses the fact that a^b = a * a^(b-1) to evaluate
// a^b using a while loop:
long MysteryFunction1(long a, int b)
{
	long product = 1;		// holds product to be returned, 1 by default
	while (b > 0) {			// so long as there's a positive exponent 
		product *= a;		// multiply by another factor of a
		b--;			// count down for the factor of a we just used
	}
	return product;
}


// This function constructs a new number "reversed" that is "num"
// with all of its bits reversed: 0th bit in 31st place, 1st bit in 30th place, etc.
unsigned int MysteryFunction2(unsigned int num)
{
	unsigned int flipper=1;			// holds 31 zeroes and 1 one, for flipping a bit in "reversed"
	unsigned int place=0;			// 0 thru 31, indicates which index we're checking
	unsigned int reversed=0;		// holds final result (to be built)
	while (place < 32) {			// until we go past the 32-byte limit
		flipper = 1;			// 0000...00001 in binary
		flipper = flipper << place;		// shift into position that we're checking
		if (flipper & num) {		// if "num" has a 1 in that position
			flipper = 0x80000000;	// 1000...00000 in binary
			flipper = flipper >> place;	// shift into reversed position
			reversed |= flipper;	// flip the reversed bit in "reversed"
		}
		place++;			// set up for checking the next position
	}
	return reversed; 
}


// This function finds the maximum integer in the array a[], which has length n.
long MysteryFunction3(long *a, int n)
{
	long maximum = a[0];			// a[0] is the default maximum
	for (int i = 1; i < n; i++) {		// for each remaining element of the list
		if (a[i] > maximum)		// if that element is actually bigger
			maximum = a[i];		// note its value as the new maximum
	}					// by here, "maximum" = the true maximum
	return maximum;
}


// This function counts the number of 1s in the binary representation of n.
int MysteryFunction4(unsigned long n)
{
	int ones = 0;				// initialize counter at 0
	while (n != 0) {			// so long as there are more 1s in the number
		ones += (n & 1);		// count any 1 in the 0th position
		n = n >> 1;				// shift right (SHR) by one position to check the next one
	}					// we'll only be able to shift 64 times maximum before n = 0
	return ones;
}


// This function counts the number of 1s in the binary representation of A XOR B.
// There is apparently a bug in that the code is implemented with SAR on A XOR B, meaning
// that unless there's a check such that 0xFFFFFFFF (-1) gets right-shifted to 0x0 (0),
// the while-loop will never exit if A XOR B has a leading 1 in the binary form.
unsigned int MysteryFunction5(unsigned int A, unsigned int B)
{
	int C = A ^ B;				// get the XOR of A and B (signed because we later use SAR on it)
	unsigned int ones = 0;			// initialize counter at 0
	while (C != 0) {			// so long as there are more 1s in the number
		ones += (C & 1);		// count any 1 in the 0th position
		C = C >> 1;				// shift right (SAR--why???) by one position to check the next one
	}
	return ones;
}

