# Color Sorting Machine

it's a mini project i made in school, and i reimplemented it in [Fritzing](https://fritzing.org/download/) 


## How it works 

I used some mini marbles as an example in this project, using a color sensor (i used TCS3200 but you can use the TCS230). You can check their datasheets in the links below, and based on the color it detects it moves the servomotor (i used the S590 micro servo) at a specific angle to drop the marble in the right spot as you can see in the picture below 

<p align="center">
  <img src="https://raw.githubusercontent.com/UncleJ4ck/IT-Stuff/main/Arduino/ColorSorting/img/final_project.jpg"/>
</p>

> there are 2 servomotors one that locks the marble until it detects its colors and it opens again a little door to make the marble slides to its right hole and the other to move the whole base 

## Datasheets 

- Color Sensor
[TCS3200/TCS3210](https://s3-sa-east-1.amazonaws.com/robocore-lojavirtual/889/TCS230%20Datasheet.pdf)
[TCS230](https://www.mouser.com/catalog/specsheets/tcs3200-e11.pdf)

- Servomotor
[SG90](http://www.ee.ic.ac.uk/pcheung/teaching/DE1_EE/stores/sg90_datasheet.pdf)

## Connection

```That's the little reimplementation in fritzing```

<p align="center">
  <img src="https://raw.githubusercontent.com/UncleJ4ck/IT-Stuff/main/Arduino/ColorSorting/img/reimplementation.png"/>
</p>

> For the reimplementation you may not found the [Color Sensor](https://github.com/UncleJ4ck/IT-Stuff/blob/main/Arduino/ColorSorting/TCS230%20Color%20Sensor.fzpz?raw=true) in fritzing you can download it and slide in it into fritzing as easy as in this video below:

![demonstration](https://raw.githubusercontent.com/UncleJ4ck/IT-Stuff/main/Arduino/ColorSorting/img/demonstration.gif)

## Installation 

> Some Stupid Instructions that you might forget !

- I recommend using [Arduino IDE](https://www.arduino.cc/en/software) Choose your version depending on your operation system and Download it  
1. Connect your arduino board
2. To verify the connection go to ```Tools > Port  You will see "COM4" in windows or "/dev/tty0/ACM0" in Linux```  
3. Choose Your Board go to ```Tools > Board and choose your board (Arduino UNO or Arduino Mini)```
4. If you wanna test your code and debug it go to ```Sketch > Verify/Compile``` if you wanna send it directly ```Sketch > Upload```

> For this project you will need an external library that's called [Servo.h](https://github.com/arduino-libraries/Servo) 

- For the older version of Arduino 
1. Download it as a zip file from the github page
2. Go to ```Sketch > Include a Library > ADD .ZIP Library```
3. and upload the library


- For the newer versions 
1. Go to ```Sketch > Include a Library > Manage Libraries > Search for "Servo" >  and install it 



## Components 

`Arduino UNO any other compatible board`
`Wires`
`Breadboard`
`2x ServoMotor`
`TCS3200/230/3210`

> For the base it was made using solidworks by a school colleague 