//C++ Arduino Library

// for the ultrasound sensor
int Trig = 13, Echo = 12, Buzzer = 3, Duration, Distance;

void setup() {
  // serial data transmission 
  Serial.begin(9600);

// configure pin to OUTPUT/INPUT
  pinMode(Buzzer, OUTPUT);
  pinMode(Trig, OUTPUT);
  pinMode(Echo, INPUT);
}

void loop() {
    /* Calculate the duration and distance of the ultrasound sensor by
       generating the ultra sound wave and using pulseIn() to read the 
       travel time (duration)
    */
    digitalWrite(Trig, HIGH);
    delayMicroseconds(10);
    digitalWrite(Trig, LOW);
    Duration = pulseIn(Echo, HIGH); 
    Distance = Duration / 59; // distance in cm

    // print the distance value 
    Serial.print("The distance is ");
    Serial.println(Distance);
    delay(500);

    // if the distance is higher or lower than a certain number turn on the buzzer on a specific Hz
    if (Distance <= 5) {
      tone(Buzzer, 50);
    } else if (Distance > 5 || Distance >= 10) {
      tone (Buzzer, 25);
    } else if (Distance > 10 || Distance >= 20) {
      tone(Buzzer, 5);
    } else if (Distance > 20 && Distance >= 30) {
      tone(Buzzer, 1);
    } else {
      noTone(Buzzer);
    }
}
