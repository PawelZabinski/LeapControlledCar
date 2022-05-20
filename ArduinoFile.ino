//
// AUTHOR: Pawel Zabinski
// CREST STEM Leap Motion Controlled Car | Project
//

#include <PWMServo.h>
#include <SoftwareSerial.h>

#define RX 11
#define TX 4

// Bluetooth Serial Port
SoftwareSerial BLTSerial(RX, TX);

// Values for F and B should be within 0-100 and will be mapped to the range (155-255)
#define MINIMUM_SPEED 155
#define MAXIMUM_SPEED 255

// Values for D should be within 0-180 and will be mapped to the range (55-125)
#define FRONT 90 // Car's wheels at their resting position
#define LEFT 55
#define RIGHT 125

// PINS REQUIRED FOR MOTORS
#define IN1 7
#define IN2 8
#define ENA 5 //  ENA pin

#define SERVO_PIN 9  // Servo connect to D9
 
PWMServo head;

String data;
char command;
int magnitude;
  
void setup() {
  pinMode(ENA, OUTPUT); 
  pinMode(IN1, OUTPUT); 
  pinMode(IN2, OUTPUT); 
  
  head.attach(SERVO_PIN);
  BLTSerial.begin(9600);
}

void loop() {
  if (!BLTSerial.available()) return;

  data = BLTSerial.readStringUntil('\n');

  // "STOP" will reset direction of the car's wheels and its velocity
  if (data == "STOP") {
    turn();
    stop();

    return;
  }
  
  command = data[0];

  // Lowercase s for the reset in direction of the car's wheels
  // Uppercase S for the decrease in the velocity of the car (causing it to stop)
  if (command == 's') {
    turn();
    
    return;
  } else if (command == 'S') {
    stop();
    
    return;
  }

  //
  // MARK: Map the values of magnitude to the correct values for the car functions
  // If values are within a fixed range of the normal value, mark those values as redundant to remove random small movements i.e shaky hands
  //
  
  magnitude = data.substring(1).toInt();

  if ((command == 'F' || command == 'B') && magnitude != 0)
    magnitude = map(magnitude, 1, 100, MINIMUM_SPEED, MAXIMUM_SPEED);
  
    
  if (command == 'D')
    magnitude = map(magnitude, 0, 180, LEFT, RIGHT);
    
  
  //
  // MARK: Perform the physical movement of motors
  //

  // D (direction) command describes the direction of the car's wheels
  if (command == 'D') 
    turn(magnitude);

  // F (forwards) and B (backwards) commands describe the velocity of the car
  if (command == 'F')
    forwards(magnitude);
  else if (command == 'B')
    backwards(magnitude);
}

void forwards(int speed) {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH); 
  
  analogWrite(ENA, speed);
}
 
void backwards(int speed) {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW); 
  
  analogWrite(ENA, speed);
}

// An angle which turns the front wheels of the car, using the head module connected.
void turn(int angle) {
  head.write(angle);
}

// Functional overload for the default value of FRONT
void turn() {
  head.write(FRONT);
}

// Causing the car to decelerate, causing it to stop.
void stop() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  analogWrite(ENA, 0);
}
