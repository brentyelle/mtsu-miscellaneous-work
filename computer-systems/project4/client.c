//client.c
#include "csapp.h"
#define QUITCHOICE 2

// send message to server
int SendLineRIO(int fd);
// read message from server
void ReadLineRIO(rio_t *r);


int main(int argc, char **argv) {
    int clientfd;             //own file descriptor
    char *host = argv[1];     //server hostname (grabbed from arguments)
    char *port = argv[2];     //server port name (grabbed from arguments)
    rio_t rio;                //internal buffer for reading from network
    int currChoice = 0;       //current choice that we've input
    
    //establish connection
    clientfd = Open_clientfd(host, port);
    
    //prepare the internal buffer for reading
    Rio_readinitb(&rio, clientfd);
    
    /*  The server has been designed in such a way that it will only ever send
        a newline character when a prompt is desired from the client, meaning
        that the client can simply alternate between reading and writing until
        the signal to close the connection is given.
        When the client should get a newline character when a prompt is NOT
        desired, then the server will actually send a tab character, which the
        ReadLineRIO() function re-interprets as a newline character. */
    
    while (currChoice != QUITCHOICE) { // keep going until we indicate to quit
        // read message and/or instructions from server
        ReadLineRIO(&rio);
        // then send response to the server, grabbing an integer if we
        // typed one in, or 0 if we typed a non-number string.
        currChoice = SendLineRIO(clientfd);
    }
    
    // read the server's goodbye
    ReadLineRIO(&rio);
    
    // close the connection
    Close(clientfd);
    return 0;
}

// ===================================================
// HELPER FUNCTIONS
// ===================================================

/* Sends a line of text (up until a '\n' character from pressing Enter) to
   the server indicated by socket file descriptor "fd".
   
   So that the client can recognize when they're closing their connection
   to the server, this function will also read the beginning of the string
   that's sent to the server, using sscanf() to look for an integer at the
   start of it. If that integer is ever 3, then the client will close the
   connection, instantly killing the server, which I see as an acceptable
   sacrifice for having a very straightforward client program.              */

int SendLineRIO(int fd) {
    char write_buf[MAXLINE]; //buffer for communication to network
    bzero(write_buf, sizeof(write_buf));
    int choice=0;
    
    // take text from Std Input
    Fgets(write_buf, MAXLINE, stdin);
    // send that text to the server
    Rio_writen(fd, write_buf, strlen(write_buf));
    // also convert it into an integer for our side's controls
    // (returns 0 if there's no valid integer at the start)
    sscanf(write_buf, "%i", &choice);
    return choice;
}   

/* Reads a line of text that is sent from the server (up until a '\n' character).
   Because we want to sometimes receive text from the server that contains more
   than one newline character, we've actually set up the server so that it sends
   non-final newlines as '\t', and it is in this function here that we reinterpret
   them as '\n'.
*/

void ReadLineRIO(rio_t *r) {
    char read_buf[MAXLINE]  = {'\0'}; //buffer for communication from network
    int buflen;                       //length of non-junk text in the buffer
    
    // get text line from the server
    Rio_readlineb(r, read_buf, MAXLINE);
    // and measure its length
    buflen = strlen(read_buf);
    
    // change all '\t' in the received string to '\n'
    for (int i=0; i<buflen; i++) {  // for every character
        if (read_buf[i] == '\t') {  // if it is a tab
            read_buf[i] = '\n';     // change it to a newline
        }
    }
    
    // then print the resulting string client-side
    Fputs(read_buf, stdout);
    return;
}