//yelle-project1.c
//AUTHOR: Brent Yelle
//DATE: February 9, 2023
//ASSIGNMENT: MTSU CSCI 3240 Project 1
//PURPOSE: Implement our own version of the xxd command in C. This command takes a single argument (from the command line) and produces the hexadecimal code for all printable characters.

#include <stdio.h>
#include <string.h>
#include <ctype.h>

//argc : number of arguments passed
//argv : array of pointers to input strings
//argv[0] is a C-string of the executable's name;
//therefore, desired filename is at argv[1].

int BadInputXXC(int numberOfArguments);

int main(int argc, char *argv[]) {
	if (BadInputXXC(argc)==1) //if too many arguments
		return 1; //exit with error code
	
	//otherwise, start allocating memory and stuff
	int nextCharInt; //next character, as an integer
	char nextChar='^';  //next character, as a char
	char thisLine[] ="                "; // 16 spaces
	int filePosition=0; //where we are in the file

	FILE *myfile;
	myfile = fopen(argv[1], "r");

	while ((nextCharInt = getc(myfile)) != EOF) {
		// print left column when needed
		if (filePosition % 16 == 0) {
			if (filePosition != 0) //for all new lines except the first
				printf("\n"); //add a necessary newline character
			printf("%08x:", filePosition);
		}

		if (filePosition % 2 == 0) //before every other byte
			printf(" "); //print a space
		printf("%02x",nextCharInt); //then print the hexadecimal ASCII code of the character

		//next, print each character to the screen
		nextChar='.'; //by default, all characters are periods
		if (isprint(nextCharInt) != 0) //but if it's a printable character
			nextChar = (char)nextCharInt; //then use the printable form instead
		thisLine[filePosition % 16] = nextChar; //finally, store the char to be printed in the line buffer

		if ((filePosition % 16) == 15) { //if we've come to the end of a line for printing
			printf("  %s",thisLine); //first, print the line buffer
			for (int i=0; i<16; i++) { //then clear the line buffer for the next line
				thisLine[i] = ' '; //by replacing all characters with spaces again
			}
		}
		filePosition++;
	}

	//lastly, print the remaining buffer, if there is anything:
	filePosition = filePosition % 16; //we only need relative position on the last line anymore
	if (filePosition != 15) { //if we didn't just finish a line
		for (int j=1; j<= 15-filePosition; j++)
			printf("   ");
		printf("%s\n",thisLine);
	} else {
		printf("\n");
	}


	return 0;
}

//returns 1 if number of text arguments after the
//executable file is not equal to 1. Since the first
//argument in argv is the filename, this means we want
//numberOfArguments == 2.
int BadInputXXC(int numberOfArguments) {
	//too many args
	if (numberOfArguments > 2) {
		printf("You entered %i arguments. Please enter only a single argument.", numberOfArguments-1);
		return 1;
	}
	//too few args
	if (numberOfArguments == 1) {
		printf("You entered %i arguments. Please enter only a single argument.", numberOfArguments-1);
		return 1;
	}
	//otherwise
	return 0;
}
