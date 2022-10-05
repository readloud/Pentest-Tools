#include "../include/bf.h"


int main(int argc, char *argv[]) {
    struct stat st;
    FILE *file;

    if ((argc != 2) || (file = fopen(argv[1], "r")) == NULL) {
        fprintf(stderr, "Usage %s Filename\n", argv[0]);
        exit(1);
    }


    stat(argv[1], &st);
    long size = st.st_size;

    char *file_buf = (char *) malloc (sizeof(char) + 1 * size);
    fread(file_buf, size, sizeof(char), file);

    interpret(file_buf);

    fclose(file);
    free(file_buf);
    return 0;
}