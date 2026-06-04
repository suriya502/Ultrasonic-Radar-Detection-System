#include <Servo.h>

Servo myServo;

long duration;
int distance;
int angle = 0;

// ===== setup =====
void setup() {

  Serial.begin(9600);

  myServo.attach(3);   // Servo on D3

  pinMode(6, OUTPUT);   // LED
  pinMode(7, OUTPUT);   // Buzzer
  pinMode(9, OUTPUT);   // TRIG
  pinMode(10, INPUT);   // ECHO
}

// ===== loop =====
void loop() {

  for (angle = 0; angle <= 180; angle++) {

    myServo.write(angle);
    delay(20);

    distance = getDistance();

    // alert system
    if (distance > 0 && distance <= 10) {
      digitalWrite(6, HIGH);  // LED ON
      digitalWrite(7, HIGH);  // Buzzer ON
    } else {
      digitalWrite(6, LOW);
      digitalWrite(7, LOW);
    }

    sendData(angle, distance);
  }

  for (angle = 180; angle >= 0; angle--) {

    myServo.write(angle);
    delay(20);

    distance = getDistance();

    if (distance > 0 && distance <= 10) {
      digitalWrite(6, HIGH);
      digitalWrite(7, HIGH);
    } else {
      digitalWrite(6, LOW);
      digitalWrite(7, LOW);
    }

    sendData(angle, distance);
  }
}

// ===== ultrasonic function =====
int getDistance() {

  digitalWrite(9, LOW);
  delayMicroseconds(2);

  digitalWrite(9, HIGH);
  delayMicroseconds(10);
  digitalWrite(9, LOW);

  duration = pulseIn(10, HIGH);

  distance = duration * 0.034 / 2;

  return distance;
}

// ===== serial send =====
void sendData(int angle, int distance) {

  Serial.print(angle);
  Serial.print(",");
  Serial.print(distance);
  Serial.print(".");
}
