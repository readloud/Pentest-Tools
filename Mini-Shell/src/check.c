#include "../include/shell.h"

char cmd[_SC_ARG_MAX]; // definition of global variables
char *argv[ARG_MAX];

// handling builtin commmands
int check_builtins() {
	int stat; // keep track of builtin execution status
	if (!strcmp(cmd, "cd")) {
		if (argv[1] == NULL) {
			stat = chdir(getenv("HOME")); // default cd without arg behaviour
		} else {
			stat = chdir(argv[1]);
		}
		if (stat != 0)
			fprintf(stderr, "%s: %s\n", argv[0], strerror(errno));
		return 1;
	}
	if (!strcmp(cmd, "exit")) {
		exit(0);
 	}

	return 0; // not a builtin
}
