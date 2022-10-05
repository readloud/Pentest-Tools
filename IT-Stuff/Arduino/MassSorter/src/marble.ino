#include "rgb_lcd.h"
#include <Wire.h>

// pins for the two sensors
int C_Heavy = 7;
int C_Light = 6;

// one to store the value of the heavy marble and the other of the light one
int Heavy_Marble = 0;
int Light_Marble = 0;

int Counter_Heavy = 0;
int Counter_Light = 0;

rgb_lcd lcd;

const int Color_Red = 255;
const int Color_Green = 255;
const int Color_Blue = 255;
 
void setup() {
  Serial.begin(9600); // Serial Data Transmission speed
  pinMode(C_Heavy, INPUT); 
  pinMode(C_Light, INPUT);
  lcd.begin(16, 2); // LCD's number of columns and rows
  lcd.setRGB(color_Red, Color_Green, Color_Blue); 
}
 
void loop() {
  Heavy_Marble = digitalRead(C_Heavy);
  Light_Marble = digitalRead(C_Light);
  if (Heavy_Marble == LOW) {
    Counter_Heavy += 1;
    lcd.setCursor(0, 0);
    lcd.print("Heavy Marble = ");
    lcd.print(Counter_Heavy);
    lcd.print("\n");
  } else {
    Counter_Heavy = 0;
    lcd.setCursor(0, 0);
    lcd.print("Heavy Marble = ");
    lcd.println(Counter_Heavy);
    lcd.print("\n"); 
  }
  if (Light_Marble == LOW) {
     Counter_Light += 1;
     lcd.setCursor(0, 1);
     lcd.print("Light Marble = ");
     lcd.println(Counter_Light);
  } else {
    Counter_Light = 0;
    lcd.setCursor(0, 1);
    lcd.print("Light Marble = ");
    lcd.println(Counter_Light);
  }
}
