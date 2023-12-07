#include "csapp.h"
#include <stdlib.h>
#define NAMELEN 50
#define MAXRECORDS 50

// file to be written to and read from
const char* FILENAME = "studentRecords.txt";

// struct for details
struct Student {
    char firstname[NAMELEN];
    char lastname[NAMELEN];
    int age;
    char major[NAMELEN];
};

// get the client's choice of what to do
int PromptUserChoice(int cfd);
// support functions for PromptUserChoice()
void PrintOptions(int cfd);
void RePrintOptions(int cfd);
int ReadUserChoice(int cfd);

// for option 1: add a student to the records
void AddRecordService(int cfd);
// support functions for AddRecordService()
struct Student GetRecordToAdd(int cfd);
void AcknowledgeAdd(int cfd);

// for option 2
void ReadRecordService(int cfd);
// support functions for ReadRecordService();
void PrintRecord(int cfd, struct Student *stu);
void PrintNoRecord(int cfd);
void GetRecordToFind(int cfd, char first[NAMELEN], char last[NAMELEN]);

// for option 3: say goodbye to the client before closing connection
void PrintGoodbye(int cfd);

int main(int argc, char**argv) {
    int listenfd, connfd;
    int userchoice;
    socklen_t clientlen;
    struct sockaddr_storage clientaddr;
    char client_hostname[MAXLINE];
    char client_port[MAXLINE];
    
    printf("Initializing server...\n");
    listenfd = Open_listenfd(argv[1]);
    printf("Server ready to receive connection.\n");
    
    while (1) {
        clientlen = sizeof(struct sockaddr_storage);
        connfd = Accept(listenfd, (struct sockaddr *) &clientaddr, &clientlen);
        Getnameinfo((struct sockaddr *) &clientaddr, clientlen, client_hostname, MAXLINE, client_port, MAXLINE, 0);
        printf("Connected to (%s, %s).\n", client_hostname, client_port);
        
        // BEGIN SERVICE
        do {
            userchoice = PromptUserChoice(connfd);
            if (userchoice == 1) {      //if the user chooses 1, then we're adding a new record
                AddRecordService(connfd);
            } 
            else if (userchoice == 2) { //if the user chooses 2, then we're reading for a record
                ReadRecordService(connfd);
            }
        } while (userchoice != 3); //if the user chooses 3, then we're closing the connection
        
        // END SERVICE
        printf("Closing the connection.\n");
        PrintGoodbye(connfd);
        close(connfd);
    }
    return 0;
}

/* ================================================================
   PROMPTING THE USER
   ================================================================ */

// Prompts the user for a choice of what to do, and re-prompts them if
// their choice was invalid.
// Returns the (eventually correct) choice.
int PromptUserChoice(int cfd) {
    int user_choice = 0;
    PrintOptions(cfd);  //show the options to the user
    while (1) {
        user_choice = ReadUserChoice(cfd);  //get the user's option choice
        printf("Received choice: %i\n", user_choice);
        if (user_choice != 1 && user_choice != 2 && user_choice != 3) {
                printf("Choice invalid. Re-sending options.\n");
                RePrintOptions(cfd);
        } else {
            break;
        }
    }
    return user_choice;
}

// Called in PromptUserChoice().
// Prints the options for what the server can do, if the user made a bad choice.
void PrintOptions(int cfd) {
    char buf[MAXLINE] = "\0";
    
    //server-side message
    printf("Sending option choices to user...\n");
    
    //message to send to client, all concatenated together
    strcpy(buf, "Welcome to the Student Records server.\nPlease select from the following choices:\n");
    strcat(buf, " 1 : Add a student's information to the records.\n");
    strcat(buf, " 2 : Search for a student's information within the records.\n");
    strcat(buf, " 3 : Close the connection.\n");
    strcat(buf, "Enter selection: \n");
    
    //send the message
    Rio_writen(cfd, buf, strlen(buf));
    
    return;
}

// Called in PromptUserChoice().
// Re-prints the options for what the server can do, if the user made a bad choice.
void RePrintOptions(int cfd) {
    char buf[MAXLINE] = "\0";
    
    //server-side message
    printf("Re-sending option choices to user...\n");
    
    //message to send to client, all concatenated together
    strcpy(buf, "You must chose a number 1, 2, or 3:\n");
    strcat(buf, " 1 : Add a student's information to the records.\n");
    strcat(buf, " 2 : Search for a student's information within the records.\n");
    strcat(buf, " 3 : Close the connection.\n");
    strcat(buf, "Enter selection: \n");
    
    //send the message
    Rio_writen(cfd, buf, strlen(buf));
    Rio_writen(cfd, "", 0);
    return;
}


// Called in PromptUserChoice().
// Reads from the connection and returns the numerical
// form of their input.
int ReadUserChoice(int cfd) {
    int choice_int;
    rio_t rio;
    char buf[MAXLINE] = "\0";
    
    //prepare buffer for reading
    Rio_readinitb(&rio, cfd);
    
    //read from client
    Rio_readlineb(&rio, buf, 2);
    
    
    //interpret input as an integer
    //printf("Interpreting received text: |%s|\n", buf);
    sscanf(buf, "%i", &choice_int);
    
    //sleep(1);
    
    //return that integer
    return choice_int;
}


void PrintGoodbye(int cfd) {
    char buf[MAXLINE] = "\0";
    
    //server-side message
    printf("Saying goodbye to the client...\n");
    
    // send the message to client
    strcpy(buf, "Closing connection. Goodbye!\n");
    Rio_writen(cfd, buf, strlen(buf));
    return;
}

/* ================================================================
   OPTION 1
   ================================================================ */

void AddRecordService(int cfd) {
    FILE *fileptr = fopen(FILENAME, "a");                // open in append mode
    struct Student studentToAdd = GetRecordToAdd(cfd);  // holds the info to add to records
    char ageToWrite[NAMELEN];                           // age of the student, in string form
    char lineToWrite[MAXLINE];                           // the line to be written to the file
    
    //convert age to a string in base-10
    // itoa(studentToAdd.age, ageToWrite, 10);
    sprintf(ageToWrite, "%d", studentToAdd.age);
    
    // assemble the string to write to the file
    strcpy(lineToWrite, "\n");                    // (newline)
    strcat(lineToWrite, studentToAdd.firstname);  // first name
    strcat(lineToWrite, ",");                     // ,
    strcat(lineToWrite, studentToAdd.lastname);   // last name
    strcat(lineToWrite, ",");                     // ,
    strcat(lineToWrite, ageToWrite);              // age
    strcat(lineToWrite, ",");                     // ,
    strcat(lineToWrite, studentToAdd.major);      // major
    
    //write the line
    fwrite(lineToWrite, sizeof(char), strlen(lineToWrite), fileptr);
    
    //now we're done with the file
    fclose(fileptr);
    
    //send acknowledgement
    AcknowledgeAdd(cfd);
    return;
}


struct Student GetRecordToAdd(int cfd) {
    rio_t rio;
    char buf[MAXLINE]  = "\0";
    Rio_readinitb(&rio, cfd);
    struct Student newStudent = {.firstname="", .lastname="", .age=0, .major=""};
    
    printf("Prompting user for student record to add...\n");
    
    // prompt user
    strcpy(buf, "You have selected to enter a student's data.\n");
//    Rio_writen(cfd, buf, strlen(buf));
    
    // get the first name
    printf("Prompting for first name...\n");
    strcat(buf, " Enter the student's first name: \n");
    Rio_writen(cfd, buf, strlen(buf));
    Rio_readinitb(&rio, cfd);
    Rio_readlineb(&rio, buf, NAMELEN-1);
    sscanf(buf, "%[^\n]", newStudent.firstname); //store in the struct
    printf("Received \"%s\".\n", newStudent.firstname);
    
    // get the last name
    printf("Prompting for last name...\n");
    strcpy(buf, "  Enter the student's last name: \n");
    Rio_writen(cfd, buf, strlen(buf));
    Rio_readinitb(&rio, cfd);
    Rio_readlineb(&rio, buf, NAMELEN-1);
    sscanf(buf, "%[^\n]", newStudent.lastname); //store in the struct
    printf("Received \"%s\".\n", newStudent.lastname);
    
    // get the age
    printf("Prompting for age...\n");
    strcpy(buf, "        Enter the student's age: \n");
    Rio_writen(cfd, buf, strlen(buf));
    Rio_readinitb(&rio, cfd);
    Rio_readlineb(&rio, buf, NAMELEN-1);
    sscanf(buf, "%i", &(newStudent.age)); //store in the struct
    printf("Received \"%i\".\n", newStudent.age);
    
    // get the major
    printf("Prompting for major...\n");
    strcpy(buf, "      Enter the student's major: \n");
    Rio_writen(cfd, buf, strlen(buf));
    Rio_readinitb(&rio, cfd);
    Rio_readlineb(&rio, buf, NAMELEN-1);
    sscanf(buf, "%[^\n]", newStudent.major); //store in the struct
    printf("Received \"%s\".\n", newStudent.major);
    
    return newStudent;
}

void AcknowledgeAdd(int cfd) {
    char buf[MAXLINE]  = "\0";
    
    //send acknowledgement to client
    strcpy(buf, "The new student has been added.\n\n");
    Rio_writen(cfd, buf, strlen(buf));
    return;
}

/* ================================================================
   OPTION 2
   ================================================================ */

void ReadRecordService(int cfd) {
    FILE *fileptr = fopen(FILENAME, "r");        // open in read-only mode
    struct Student records[MAXRECORDS] = {};    // the database of students (initialized?)
    char thisLine[MAXLINE];                      // the line currently being read
    char searchFirst[NAMELEN];               // first name of student we're looking for
    char searchLast[NAMELEN];                // last name of student we're looking for
    int recCt = 0;                              // total number of records
    int recordFound = 0;                        // will become 1 (TRUE) if a record is found
    int firstnameCheck = 1;   // will be 0 if first name match found
    int lastnameCheck = 1;    // will be 0 if last name match found
    
    printf("Reading from data file %s...\n", FILENAME);
    while ( fgets(thisLine, MAXLINE, fileptr) != NULL) { //keep reading records until we reach the end of the list
        sscanf(thisLine, "%[^,],%[^,],%i,%[^\n]",
               records[recCt].firstname,
               records[recCt].lastname,
               &(records[recCt].age),
               records[recCt].major);
        //printf("Imported student: [%s %s].\n",
        //       records[recCt].firstname,
        //       records[recCt].lastname);
        recCt++;
    }
    // now we don't need the file open anymore
    fclose(fileptr);
    
    // prompt the user for the file they're searching for
    GetRecordToFind(cfd, searchFirst, searchLast);
    //printf("Searching for student: [%s %s].\n", searchFirst, searchLast);
    
    // look for matches
    for (int i = 0; i < recCt; i++) {
        //printf("Comparing against [%s %s].\n", records[i].firstname, records[i].lastname);
        firstnameCheck = strcmp(searchFirst, records[i].firstname);
        lastnameCheck  = strcmp(searchLast,  records[i].lastname);
        
        //printf("First name check: %i.\n", firstnameCheck);
        //printf("Last name check: %i.\n", lastnameCheck);
        if ( (firstnameCheck == 0) && (lastnameCheck == 0) ) {
            recordFound = 1;                 // hooray, we found a record!
            PrintRecord(cfd, &records[i]);   // so print its details to the client
            break;                           // and we can stop searching
        }
    }
    
    // if we never found a matching record, tell the client as much
    if (recordFound == 0) {
        PrintNoRecord(cfd);
    }
    
    //now we're done
    return;
}

// prompt the user for details of the student we're trying to find
void GetRecordToFind(int cfd, char first[NAMELEN], char last[NAMELEN]) {
    rio_t rio;
    char write_buf[MAXLINE] = "\0";
    bzero(write_buf, sizeof(write_buf));
    char readbuf[MAXLINE] = "\0";
    bzero(readbuf, sizeof(readbuf));
    
    Rio_readinitb(&rio, cfd);

    printf("Prompting user for student record to find...\n");
    // prompt user
    strcpy(write_buf, "You have selected to enter a student's data.\n");
    Rio_writen(cfd, write_buf, strlen(write_buf));
    
    // get the first name
    printf("Prompting for student's first name...\n");
    strcpy(write_buf, " Enter the student's first name: \n");
    Rio_writen(cfd, write_buf, strlen(write_buf));
    Rio_readinitb(&rio, cfd);
    Rio_readlineb(&rio, readbuf, NAMELEN-1);
    sscanf(readbuf, "%[^\n]", first);
    printf("Received [%s].\n", first);
    
    // get the last name
    printf("Prompting for student's last name...\n");
    strcpy(write_buf, "  Enter the student's last name: \n");
    Rio_writen(cfd, write_buf, strlen(write_buf));
    Rio_readinitb(&rio, cfd);
    Rio_readlineb(&rio, readbuf, NAMELEN-1);
    sscanf(readbuf, "%[^\n]", last);
    printf("Received [%s].\n", last);
    
    // and now we've read all we need to
    return;
}


// send the details of the matched student to the client
void PrintRecord(int cfd, struct Student *stu) {
    rio_t rio;
    char buf[MAXLINE] = "\0";
    char ageToWrite[NAMELEN];  //holds string form of age
    
    Rio_readinitb(&rio, cfd);
    
    // convert student's age into a proper age (base-10)
    // itoa(stu->age, ageToWrite, 10);
    sprintf(ageToWrite, "%d", stu->age);
    
    //server-side message
    printf("Sending the student's record...\n");
    
    //create message to send
    strcpy(buf, "Here are the details for that student:\n");
//    Rio_writen(cfd, buf, strlen(buf));
    
    strcat(buf, " First Name: ");
    strcat(buf, stu->firstname);
    
    strcat(buf, "\n");
    strcat(buf, "  Last Name: ");
    strcat(buf, stu->lastname);
    
    strcat(buf, "\n");
    strcat(buf, "        Age: ");
    strcat(buf, ageToWrite);
    
    strcat(buf, "\n");
    strcat(buf, "      Major: ");
    strcat(buf, stu->major);
    strcat(buf, "\n\n");
    
    // send the message
    // printf("Sending this record:\n %s", buf);
    Rio_writen(cfd, buf, strlen(buf));
    // printf("Student record sent.\n");
    
    return;
}

// tell the client that we didn't find any matching student
void PrintNoRecord(int cfd) {
    char buf[MAXLINE] = "\0";
    
    //server-side message
    printf("Telling client that we found nothing...\n");
    
    // send the message to client
    strcpy(buf, "Sorry, no such student was found in the database!\n\n\n\n\n\n");
    Rio_writen(cfd, buf, strlen(buf));
    
    return;
}