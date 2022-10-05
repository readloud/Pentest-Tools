bf : obj/bf.o obj/main.o 
		  gcc obj/* -o bf

obj/bf.o : src/bf.c
				gcc -D_FORTIFY_SOURCE=2 $(CFLAGS) -c src/bf.c -o obj/bf.o

obj/main.o : src/main.c 
				gcc -D_FORTIFY_SOURCE=2 $(CFLAGS) -c src/main.c -o obj/main.o 

clean:
	rm -f obj/*.o