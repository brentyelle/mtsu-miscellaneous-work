all: server client

server: server.c csapp.c
	gcc -o server server.c csapp.c
client: client.c csapp.c
	gcc -o client client.c csapp.c
clean:
	rm ./server
	rm ./client
