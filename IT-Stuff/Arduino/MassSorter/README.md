# Mass sorter

It's a little project that i made in school to sort the heavy and light mini balls (marbles).

## How it works 

First, we put the marble in a sled if its heavyweight, it will hit the barrier and triggers the limit switch and then we will see that the value of the heavy marbles in the LCD screen is 1 and if its lightweight the barrier will block it and the ball will go in a different direction to hit the other limit switch and we will see in that the value of light marbles is 1 in the LCD screen display as well, and the more you put the marbles the more the value will keep incrementing depanding if its heavyweight or lightweight.

## Connection  

> That's the real project 

<p align="center">
  <img src="https://raw.githubusercontent.com/UncleJ4ck/IT-Stuff/main/Arduino/MassSorter/img/final_project.jpeg">
</p>


## Installation 


> Some Stupid Instructions that you might forget !

- I recommend using [Arduino IDE](https://www.arduino.cc/en/software) Choose your version depending on your operation system and Download it  
1. Connect your arduino board
2. To verify the connection go to ```Tools > Port  You will see "COM4" in windows or "/dev/tty0/ACM0" in Linux```  
3. Choose Your Board go to ```Tools > Board and choose your board (Arduino UNO or Arduino Mini)```
4. If you wanna test your code and debug it go to ```Sketch > Verify/Compile``` if you wanna send it directly ```Sketch > Upload```

> For this project you will need an external library that's called [rgb_lcd.h](https://github.com/Seeed-Studio/Grove_LCD_RGB_Backlight)

- For the older version of Arduino 
1. Download it as a zip file from the github page 
2. Go to ```Sketch > Include a Library > ADD .ZIP Library```
3. and upload the library


- For the newer versions of Arduino 
1. Go to ```Sketch > Include a Library > Manage Libraries > Search for "Grove - LCD RGB Backlight" >  and install it 

## Components 

- Those are the components in fritzing

<p align="center">
  <img src="https://raw.githubusercontent.com/UncleJ4ck/IT-Stuff/main/Arduino/MassSorter/img/components.png">
</p>

`Arduino UNO or any other compatible board`
`Grove - LCD RGB Backlight`
`Mini Breadboard (Optional)`
`Mech Endstop`