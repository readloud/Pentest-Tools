// Pins 
int sensorpin = A0; 
const int led[] = {1, 2, 3, 4, 5};
int sensorvalue = 0;   
 
void setup() {  
  // serial data transmission 
  Serial.begin(9600);
  
  // configure pin to OUTPUT
  pinMode(led[1], OUTPUT);      
  pinMode(led[2], OUTPUT);
  pinMode(led[3], OUTPUT);      
  pinMode(led[4], OUTPUT);
  pinMode(led[5], OUTPUT);
  
}
 
void loop() { 
  // read the value from the analog pin "sensorpin"
  sensorvalue = analogRead(sensorpin);   

  // print the value 
  Serial.println(sensorvalue);  
  
  // if the value is high than a certain number turn on/off the LED on a specific pin
  if (sensorvalue > 250) {
    digitalWrite(led[1], HIGH);  
  } else { 
    digitalWrite(led[1], LOW);  
  }

  if (sensorvalue > 450) {
    digitalWrite(led[2], HIGH); 
  } else { 
    digitalWrite(led[2], LOW);    
  }

  if (sensorvalue > 650) {
    digitalWrite(led[3], HIGH);  
  } else { 
    digitalWrite(led[3], LOW);  
  }
 
  if (sensorvalue > 850) {
    digitalWrite(led[4], HIGH); 
  } else { 
    digitalWrite(led[4], LOW);   
  }

  if (sensorvalue > 1000) {
    digitalWrite(led[5], HIGH); 
  } else {  
    digitalWrite(led[5], LOW);   
  }
}
