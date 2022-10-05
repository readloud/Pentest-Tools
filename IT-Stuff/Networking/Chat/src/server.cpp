#include "../include/server.h"

void server::socket_creation(int server, int client) {
        
    std::cout << "Which Port Number do you want to listen on?: ";
    std::cin >> PORT;
    // socket create and verification
	server = socket(AF_INET, SOCK_STREAM, 0);
	if (server == -1) {
		perror("Socket creation failed...");
		exit(EXIT_FAILURE);
	} 
	std::cout << "Socket successfully created.." << std::endl;
    memset(&servaddr, 0, sizeof(servaddr));

	// forcfully attaching the socket to the port 
	if (setsockopt(server, SOL_SOCKET, SO_REUSEADDR |SO_REUSEPORT, &opt, sizeof(opt))) {
        perror("Setsocket");
        exit(EXIT_FAILURE);
    }

	// assign IP, PORT
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port = htons(PORT);

	// Binding newly created socket to given IP and verification
	if ((bind(server, (struct sockaddr *)&servaddr, sizeof(servaddr))) != 0) {
		perror("Socket bind failed");
		exit(EXIT_FAILURE);
	}
	std::cout << "Socket successfully binded" << std::endl;
	
	// Now server is ready to listen and verification
	if ((listen(server, 5)) != 0) {
		perror("Listen failed");
		exit(EXIT_FAILURE);
	}
	std::cout << "Server listening" << std::endl;
	
	// Accept the data packet from client and verification
	client = accept(server, (struct sockaddr *)&clientaddr, &len);
	if (client < 0) {
		perror("Accept failed");
		exit(EXIT_FAILURE);
	} else {
		std::cout << "Connected to the client on " << inet_ntoa(servaddr.sin_addr) << ":" << PORT << std::endl;
    }
}

// there are a lot of bugs in this one 
void server::chat(int client) {
	while (1) {
		memset(buff, 0, sizeof(buff));
		read(client, buff, sizeof(buff));
		std::cout << "Client: " << buff << std::endl;
        std::cout << "Server: ";
		memset(buff, 0, sizeof(buff));
		while ((buff[n++] = getchar()) != '\n') {
		    write(client, buff, sizeof(buff));
		    if (strncmp("exit", buff, 4) == 0) {
                std::cout << "Connection has terminated" << std::endl; 
			    break;
    		}
	    }
    }
}

// Driver function
int main() {
    // object creation
    server sv;

    // socket creation 
    sv.socket_creation(sv.server, sv.client);
    
    // chat function 
	sv.chat(sv.client);

	// close the socket
	close(sv.server);
    
    return 0;
    
}