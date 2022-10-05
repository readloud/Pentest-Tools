#include "../include/shell.h"

unsigned char i; 

void convert_cmd() {
    // split strings into argv
    char *ptr;
    i = 0;
    ptr = strtok(cmd, " ");
    while (ptr != NULL) {
        argv[i] = ptr;
        i++;
        ptr = strtok(NULL, " ");
    }
    argv[i] = NULL;
	execute_cmd();
}