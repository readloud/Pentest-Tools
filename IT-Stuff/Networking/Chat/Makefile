all: server client 

server : obj/server.o
	g++ -Wall obj/server.o -o server

client : obj/client.o
	g++ -Wall obj/client.o -o client

obj/client.o : src/client.cpp
	g++ -Wall -c src/client.cpp -o obj/client.o

obj/server.o : src/server.cpp
	g++ -Wall -c src/server.cpp -o obj/server.o

clean:
	rm -f obj/*.o
	rm -f server client

fclean: clenn

re: fclean all


