#include "csapp.h"

int SendChoiceRIO(int fd);
void SendMessageRIO(int fd);
void ReadLinesRIO(rio_t *r, int num_lines);
void GetDirections(rio_t *r);
void ReGetDirections(rio_t *r);
void GetGoodbye(rio_t *r);
void GetStudentDetails(rio_t *r);


int main(int argc, char **argv) {
    int charCt = 0;           //number of characters read from network
    int currChoice = 0;       //current choice that we've input
    int clientfd;             //own file descriptor
    char *host;               //server hostname
    char *port;               //server port name
    char write_buf[MAXLINE] = {'\0'};  //buffer for communication to network
    char read_buf[MAXLINE]  = {'\0'}; //buffer for communication from network
    rio_t rio;                //internal buffer for reading from network
    
    //get host and port name from execution
    host = argv[1];
    port = argv[2];
    
    //establish connection
    clientfd = Open_clientfd(host, port);
    
    //prepare the internal buffer
    Rio_readinitb(&rio, clientfd);
    
    while (1) { // keep going forever
        //read directions from the server
        GetDirections(&rio);
        
        //select choice (1,2,3) and then send it to server
        // (can't use SendMessageRIO() here because we want the choice)
        currChoice = SendChoiceRIO(clientfd);
        
        switch (currChoice) {
            case 1: //if we choose to add a person to the files
                ReadLinesRIO(&rio, 2); // "you've chosen to add" + "enter first name"
                SendMessageRIO(clientfd); //send first name
                ReadLinesRIO(&rio, 1);    // "enter last name"
                SendMessageRIO(clientfd); //send last name
                ReadLinesRIO(&rio, 1);    // "enter age"
                SendMessageRIO(clientfd); //send age
                ReadLinesRIO(&rio, 1);    // "enter major"
                SendMessageRIO(clientfd); //send major
                ReadLinesRIO(&rio, 2);    // "person added"
                break;
            case 2:
                ReadLinesRIO(&rio, 2); // "you've chosen to lookup" + "enter first name"
                SendMessageRIO(clientfd); //send first name
                ReadLinesRIO(&rio, 1);    // "enter last name"
                SendMessageRIO(clientfd); //send last name
                GetStudentDetails(&rio);
                break;
            case 3:
                GetGoodbye(&rio);
                break;
            default:
                ReGetDirections(&rio);
        }
        
        if (currChoice == 3) { // if we chose 3 (quit)
            break;             // then break the loop and quit
        }
    }
    Close(clientfd);
    return 0;
}

// ===================================================
// HELPER FUNCTIONS
// ===================================================

int SendChoiceRIO(int fd) {
    char write_buf[MAXLINE]; //buffer for communication to network
    bzero(write_buf, sizeof(write_buf));
    int choice;
    
    // take text from Std Input
    Fgets(write_buf, MAXLINE, stdin);
    // send that text to the server
    Rio_writen(fd, write_buf, strlen(write_buf));
    //also convert it into an integer for our side's controls
    sscanf(write_buf, "%i", &choice);
    return choice;
}

void SendMessageRIO(int fd) {
    char write_buf[MAXLINE]; //buffer for communication to network
    bzero(write_buf, sizeof(write_buf));
    
    // take text from Std Input
    Fgets(write_buf, MAXLINE, stdin);
    // send that text to the server
    Rio_writen(fd, write_buf, strlen(write_buf));
    return;
}
    

void ReadLinesRIO(rio_t *r, int num_lines) {
    char read_buf[MAXLINE]  = {'\0'}; //buffer for communication from network
    bzero(read_buf, sizeof(read_buf));
    
    for (int i=0; i< num_lines; i++) {
        Rio_readlineb(r, read_buf, MAXLINE); // actual prompt
        Fputs(read_buf, stdout);
    }
    return;
}

void GetDirections(rio_t *r) {
    /*
    six lines for:
       - "welcome!"
       - "you must select one of these"
       - three lines for the three options
       - "make your choice:"
    */
    ReadLinesRIO(r, 6);
    return;
}

void ReGetDirections(rio_t *r) {
    /*
    five lines for:
       - "you must select one of these"
       - three lines for the three options
       - "make your choice:"
    */
    ReadLinesRIO(r, 5);
    return;
}

void GetGoodbye(rio_t *r) {
    /*
    one line for:
       - goodbye message
    */
    ReadLinesRIO(r, 1);
    return;
}

void GetStudentDetails(rio_t *r) {
    /*
    six lines for:
       - "here are the details"
       - first name
       - last name
       - age
       - major
       - spacing newline
    the failure message has also been formatted to use 6 lines
    */
    ReadLinesRIO(r, 6);
    return;
}