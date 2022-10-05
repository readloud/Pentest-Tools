#include <Servo.h>


#define s0 1        //Module pins wiring
#define s1 2
#define s2 3
#define s3 4
#define out 5
#define sm 8
#define lk 9

int FR = 0, RG = 0, RB = 0;
int Red = 0, Blue = 0, Green = 0;  //RGB values 

Servo Servomotor, Lockmotor; // creating objects for the servomotors


void setup() {
   Servomotor.attach(sm); // initializing the servomotors
   Lockmotor.attach(lk);
   pinMode(s0, OUTPUT);    // pin modes
   pinMode(s1, OUTPUT);
   pinMode(s2, OUTPUT);
   pinMode(s3, OUTPUT);
   pinMode(out, INPUT);

   Serial.begin(9600);   // Serial Transmission speed
   digitalWrite(s0, HIGH);  // Putting S0/S1 on HIGH/HIGH levels means the output frequency scalling is at 100% (recommended)
   digitalWrite(s1, HIGH); // LOW/LOW is off HIGH/LOW is 20% and LOW/HIGH is  2%
   
}

void GetColors()  {    
  digitalWrite(s2, LOW);                                           //S2/S3 levels define which set of photodiodes we are using LOW/LOW is for RED LOW/HIGH is for Blue and HIGH/HIGH is for green 
  digitalWrite(s3, LOW);                                           
  FR = pulseIn(out, digitalRead(out) == HIGH ? LOW : HIGH);  // here we wait until "out" go LOW, we start measuring the duration and stops when "out" is HIGH again, if you have trouble with this expression check the bottom of the code
  Red = map(FR, 11, 30, 255, 0);
  // Red = Red - 1.05;
  Serial.print("R = ");
  Serial.print(FR);
  Serial.print("\t");
  delay(20);  
  
  digitalWrite(s3, HIGH);                                         //Here we select the other color (set of photodiodes) and measure the other colors value using the same techinque
  RB = pulseIn(out, digitalRead(out) == HIGH ? LOW : HIGH);
  // Blue = Blue / 0.84;
  Blue = map(RB, 16, 29, 255, 0);
  Serial.print("B = ");
  Serial.print(RB);
  Serial.print("\t");
  delay(20);  
  
  digitalWrite(s2, HIGH);  
  RG = pulseIn(out, digitalRead(out) == HIGH ? LOW : HIGH);
  Green = map(RG, 20, 40, 255, 0);
  // Green = Green / 0.8; 
  Serial.print("G = ");
  Serial.print(RG);
  Serial.println("\t");
  delay(20);  
}

void lock() {
   Lockmotor.write(90);
   delay(2000);
   Lockmotor.write(0);
   delay(500);
}

void loop() {

GetColors();                                     // Execute the GetColors function to get the value of each RGB color
                                                   // Depending of the RGB values given by the sensor we can define the color and displays it on the monitor
                                                                                        
if (Red > Blue && Red > Green) {      // if Red value is the lowest one it's likely Red
      Serial.println("Red");
      Servomotor.write(180);
      delay(1000);
      lock();
      Servomotor.write(0);
      delay(500);
 } else if (Blue > Green && Blue > Red) {    // Same thing for Blue
      Serial.println("Blue");
      Servomotor.write(135);
      delay(1000);
      lock();
      Servomotor.write(0);
      delay(500);
 } else if (Green > Red && Green > Blue) {           // same thing for green
      Serial.println("Green");                    
      Servomotor.write(50);
      delay(1000);
      lock();
      Servomotor.write(0);
      delay(500);
 } else {
     Serial.println("Unknown");                  // if the color is not recognized
 }
  delay(1000);                                   // 1s delay you can modify if you want 
}

 
 // Informations  
/*
Output frequency scaling 	S0 	S1
Power down 	                L 	L
2% 	                        L 	H
20% 	                    H 	L
100% 	                    H 	H

Photodiode type 	S2 	    S3
Red 	            LOW 	LOW
Blue 	            LOW 	HIGH
No filter (clear) 	HIGH 	LOW
Green           	HIGH 	HIGH
*/
