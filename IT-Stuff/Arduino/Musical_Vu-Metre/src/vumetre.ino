int LEDs[11] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}; // Assign the pins for the leds
int Audio = A0; // 

int sound; // to store the signal level 
int i; // iterator

void setup() {
    Serial.begin(9600); 
    i = 0;
    while (i <= sizeof(LEDs)) {
        pinMode(LEDs[i], OUTPUT); 
        i++;
    }
}

void loop() {

    sound = analogRead(Audio);
    Serial.println(sound);
    sound /= 35; // Sound Sensitivity 

    if (sound == 0) {
        i = 0;
        while (i <= sizeof(LEDs)) {
            digitalWrite(LEDs[i], LOW); 
            i++;
        }   
    } else {
        while (i < sound) {
            digitalWrite(LEDs[i], HIGH);
            delay(40);
            i++;
        }
        while (i < sizeof(LEDs)) {
            digitalWrite(LEDs[i], LOW);
        }
    }
}