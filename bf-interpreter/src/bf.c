#include "../include/bf.h"


void interpret(char *input) {
    
    char data[MAX_SIZE];   
    char* ptr_data = data; 
    char current_char;
    size_t loop;
    
    memset(data, 0, sizeof(data)); 

    size_t i = 0;
    while (input[i] != 0) {
        current_char = input[i];
        switch (current_char) { 
            case '>':
                ++ptr_data;
            break;
            case '<':
                --ptr_data;
            break;
            case '+':
                (*ptr_data)++;
            break;
            case '-':
                (*ptr_data)--;
            break;
            case '.':
                putchar(*ptr_data);
            break;
            case ',':
                *ptr_data = getchar();
            break;
            case '[': 
                continue;
                /*if (!*ptr_data) { 
                    loop = 1; 
                    while (loop > 0) { 
                        current_char = input[i--]; 
                        if (current_char == ']') {
                            loop--;
                        } else if (current_char == '[') {
                            loop++;
                        }
                    }
                } */
            break;
            case ']':
                if (*ptr_data) {
                    loop = 1; 
                    while (loop > 0) { 
                        current_char = input[i--]; 
                        if (current_char == '[') {
                            loop--;
                        } else if (current_char == ']') {
                            loop++;
                        }
                    }
                }
            break;
        }   
        i++;
    }
}