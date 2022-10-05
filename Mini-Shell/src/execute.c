#include "../include/shell.h"

pid_t pid; // definition of global variables 

void execute_cmd() {
		if (!(check_builtins() == 1)) { // if it's not a builtin execute the binary/script associated with the command
			// fork and execute the command;
			pid = fork();
			if (pid == -1) {
				perror("Failed to create a child\n");
			} else if (pid == 0) {
				// execute a command
					if (execvp(argv[0], argv) == -1) {
						fprintf(stderr, "%s: %s\n", argv[0], strerror(errno)); // explains the type of error
					}
			} else {
				// wait for the command to finish if "&" is not present
				if (argv[i] == NULL) {
		            waitpid(pid, NULL, 0);
				}
		    }
		}
		get_cmd();
}

