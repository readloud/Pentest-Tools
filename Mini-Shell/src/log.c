#include "../include/shell.h"

void log_handle(){
	//printf("[LOG] child proccess terminated.\n");
	FILE *pFile;
    pFile = fopen(".log.txt", "a");
    if (pFile == NULL) {
        perror("Error opening file.");
    } else {
        fprintf(pFile, "[LOG] child proccess terminated.\n");
        fclose(pFile);
    }
}