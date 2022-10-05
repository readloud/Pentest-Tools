#include "../include/client.h"

void client::socket_creation(int serclient) {

    std::cout << "Which Port Number do you want to listen on?: ";
    std::cin >> PORT;
    
    // socket create and varification
	serclient = socket(AF_INET, SOCK_STREAM, 0);
	if (serclient == -1) {
		perror("Socket creation failed");
		exit(EXIT_FAILURE);
	} else {
		std::cout << "Socket successfully created" << std::endl;
    }

    memset(&servaddr, 0, sizeof(servaddr));
    // assign IP, PORT
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port = htons(PORT);

    // connect the cl.client socket to server socket
    if (connect(serclient, (struct sockaddr *)&servaddr, sizeof(servaddr)) != 0) {
        perror("connection with the server failed...");
        exit(EXIT_FAILURE);
    } else {
        std::cout << "Connected to the server on " << inet_ntoa(servaddr.sin_addr) << ":" << PORT << std::endl;
    }
}     

// chat function there are a lot of bugs in this one 
void client::chat(int serclient) {
    while (1) {
        memset(buff, 0, sizeof(buff));
        std::cout << "Server: ";
        while ((buff[n++] = getchar()) != '\n') {
            write(serclient, buff, sizeof(buff));
            memset(buff, 0, sizeof(buff));
            read(serclient, buff, sizeof(buff));
            std::cout << "Server: " << buff;
            if ((strncmp(buff, "exit", 4)) == 0) {
                std::cout << "Client Exit..." << std::endl;
                break;
            }
        }
    }
}

int main() {
    // object creation
    client cl;

	// function for chat
    cl.socket_creation(cl.serclient);
	cl.chat(cl.serclient);

	// close the socket
	close(cl.serclient);
}
