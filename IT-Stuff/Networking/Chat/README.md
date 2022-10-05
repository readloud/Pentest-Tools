# Chat 

A simple Client-Server Chat programmed in C++, i used socket to create a chat between a client and server, i also used some linux syscalls for the communicaton part 


## How it works 

This program is a messaging program that communicate over TCP using sockets. The client will connect to the server through a specific port. The server will listen for up to 5 requests at a time, the server will accept the request to connect to the client and the messages will be sent back and forth through a buffer, finally we close the sockets and terminate the program.


## Installation 

```Bash 
    git clone https://github.com/UncleJ4ck/IT-Stuff/tree/main/Networking/Chat
    cd Chat 
    make 
    ./server
    "Open another terminal"
    ./client  
```


## TO-DO 

* Multithreading 
* Bugs fixing 
* Add more features like GUI  