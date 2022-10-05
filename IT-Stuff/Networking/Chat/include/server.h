#ifndef SERVER_H
#define SERVER_H

#include <netdb.h>
#include <iostream>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>


class server {
    public:
        struct sockaddr_in servaddr, clientaddr;
        socklen_t len = sizeof(clientaddr);
        int server, client, n = 0, PORT, opt = 1;
	    char buff[1024];
        void socket_creation(int server, int client);
        void chat(int client);
};

#endif 