#ifndef SHELL_H
#define SHELL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <linux/limits.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h> // for handling excevp errors
#include <time.h>


#define RED   "\x1B[31m" // ANSI colors for terminal
#define GRN   "\x1B[32m"
#define YEL   "\x1B[33m"
#define BLU   "\x1B[34m"
#define PUR	  "\x1B[35m"
#define CYN   "\x1B[36m"
#define WHT   "\x1B[37m"	
#define RESET "\x1B[0m"

extern char cmd[_SC_ARG_MAX];				// string holder for the command
extern char *argv[ARG_MAX];			// an array for command and arguments
extern unsigned char i;					// global variable for the child process ID
extern pid_t pid; 							// needed for exit builtin


int check_builtins(); 
void execute_cmd();
void log_handle();
void convert_cmd();
void get_cmd();

#endif
