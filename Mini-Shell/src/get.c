#include "../include/shell.h"


void get_cmd(){
	// showing the time and date
	time_t t = time(NULL);
	struct tm tm = *localtime(&t); 

	char directory[FILENAME_MAX];
	char hostname[_SC_HOST_NAME_MAX];
	char* username = getenv("USER");				// showing the username

	getcwd(directory, sizeof(directory)); 	// getting the current directory 
	gethostname(hostname, sizeof(hostname));		// showing the hostname
	
	fprintf(stdout,RED"┌["CYN"%s"RED"]─["YEL"%d/%02d/%02d-%02d:%02d:%02d"RED"]─["PUR"%s"RED"]\n"RESET, hostname, tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec, directory);
    fprintf(stdout, RED"└╼"GRN"%s"YEL"$> "RESET, username);
    // remove trailing newline
    if (fgets(cmd, _SC_ARG_MAX, stdin) == NULL) {
		if (*cmd == '\n') // if newline is inputted show the prompt again
			get_cmd();
        if (feof(stdin)) { // if EOF is inputted (Ctrl+D)
			fprintf(stdout, "\nBye.\n");
			exit(0);
		} else {
			perror("Failed to read the input stream");
		}
    } else {
        cmd[strlen(cmd) - 1] = '\0';
		convert_cmd();
    };
}
