#include "../include/shell.h"

int main() {
    // tie the handler to the SGNCHLD signal
    signal(SIGCHLD, log_handle);
 
    // start the shell
	while(1){
		get_cmd();
	}
    return 0;
}


