# Musical Vu-Metre

A mini project that i made, a simple implementation of the big musical vu-metre [Fritzing](https://fritzing.org/download/)


## Explanation

a volume unit (VU) meter is a device that provides a representation by using LEDs of the signal level in the audio equipment, using an OPA344 to take the audio as an input.

## Datasheet 

[OPA344](https://www.ti.com/lit/ds/symlink/opa344.pdf)

## Connection

<p align="center">
  <img src="https://raw.githubusercontent.com/UncleJ4ck/IT-Stuff/main/Arduino/Musical_Vu-Metre/img/comp.png"/>
</p>


## Installation 

> Some Stupid Instructions that you might forget !
I recommend using [Arduino IDE](https://www.arduino.cc/en/software) Choose your version depending on your operation system and Download it 
 
1) Connect your arduino board
2) to verify the connection go to ```Tools > Port  You will see "COM4" in windows or "/dev/tty0/ACM0" in Linux```  
3) Choose Your Board go to ```Tools > Board and choose your board (Arduino UNO or Arduino Mini)```
4) if you wanna test your code and debug it go to ```Sketch > Verify/Compile``` if you wanna send it directly ```Sketch > Upload```

## Components 

`Arduino UNO or any other compatible board`
`Wires`
`Breadboard`
`12x Colored LED`
`OPA344 Electret Microphone Board`
`5x Resistors 220ohm`