# HID-Attack 

In this project i used an arduino mini with a usb rubber ducky to try a HID Attack using a keyboard to start a reverse shell in the victime machine for Windows and Linux but wait what's HID and HID Attack ?

## Explanation 

```
- HID

Human Interface Device, simply it's something that takes input and give output from/to humans like a keyboard or mouse or ..., it's simple right ? XD

- HID-ATTACK

It's a scenario where an attacker uses a keyboard or a mouse to physically attack a machine. As in this project i used a keyboard to lunch a reverse shell, You can use a keyboard to type stuff that makes you control the victim machine or extract data.
```


## Preparation

- In your machine (Attack Machine) 
- Setup a netcat listener using this command ```nc -lvnp 4444``` 
- in the code, don't forget to modify the IP and PORT parameters (Attack Machine's IP and PORT)




## Installation 


> Some Stupid Instructions that you might forget !

- I recommend using [Arduino IDE](https://www.arduino.cc/en/software) Choose your version depending on your operation system and Download it  
1. Connect your arduino board
2. To verify the connection go to ```Tools > Port  You will see "COM4" in windows or "/dev/tty0/ACM0" in Linux```  
3. Choose Your Board go to ```Tools > Board and choose your board (Arduino UNO or Arduino Mini)```
4. If you wanna test your code and debug it go to ```Sketch > Verify/Compile``` if you wanna send it directly ```Sketch > Upload```

> For this project you will need an external library that's called [Keyboard.h](https://github.com/arduino-libraries/Keyboard) 

- For the older version of Arduino 
1. Download it as a zip file from the github page 
2. Go to ```Sketch > Include a Library > ADD .ZIP Library```
3. and upload the library


- For the newer versions of Arduino 
1. Go to ```Sketch > Include a Library > Manage Libraries > Search for "Keyboard"``` and install it

## Components 

`Arduino Mini any other compatible board`
`Cable USB A Male To Micro B`
`Mini Breadboard (Optional)`
