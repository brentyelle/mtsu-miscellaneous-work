#include <stdio.h>
#define ARRAYMAX 25

int main() {
	int myarray[ARRAYMAX];
	int arrayavg;
	int arraymax;
	int arraymin;
	int arraysize = 0;
	char buf[200] = {'\0'};
	int inputNo;
	
	while (1) {
		printf("Enter a number or 0 to quit: ");
		scanf("%i", &inputNo);
		if (inputNo == 0)
			break;
		myarray[arraysize] = inputNo;
		arraysize++;
	}

	arraymax = myarray[0];
	arraymin = myarray[0];
	arrayavg = 0;
	for (int i=0; i< arraysize; i++) {
		arrayavg += myarray[i];
		if (myarray[i] > arraymax)
			arraymax = myarray[i];
		if (myarray[i] < arraymin)
			arraymin = myarray[i];
	}

	arrayavg = arrayavg / arraysize;

	printf("Array size:    %i\n", arraysize);
	printf("Average        %i\n", arrayavg);
	printf("Maximum value: %i\n", arraymax);
	printf("Minimum value: %i\n", arraymin);

	return 0;
}

