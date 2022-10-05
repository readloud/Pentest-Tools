#ifndef CLIENT_H
#define CLIENT_H

#include <netdb.h>
#include <iostream>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>

class client {
    public:
        // socket attributes to use
        char buff[1024];
	    int serclient, server, n = 0, PORT;
	    struct sockaddr_in servaddr, clientaddr;
        void socket_creation(int serclient);
        void chat(int serclient);
};

#endif 