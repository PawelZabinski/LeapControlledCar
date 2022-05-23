//
// AUTHOR: Pawel Zabinski
// CREST STEM Leap Motion Controlled Car | Project
//

import processing.serial.*;
import de.voidplus.leapmotion.*;
import java.lang.Math;

// if the fist is clenched (0 outstretched fingers),  then send a signal to stop the car.
// if the hand is moved towards the left (negative yaw value), then send a signal to turn the wheels to the left.
// if the hand is moved towards the right (positive yaw value), then send a signal to turn the wheels to the right.
// if the hand is raised upwards (positive pitch value), then send a signal to move the car forwards.
// if the hand is lowred (negative pitch value), then send a signal to move the car backwards.

// Constants
double X_OFFSET = 20;
double Y_OFFSET = 20;

double MIN_X = 120;
double MAX_X = 650;
double CENTRE_X = 385;

double MIN_Y = 300;
double MAX_Y = 600;

double MIN_ANGLE = 0;
double MAX_ANGLE = 180;

double MIN_SPEED = 0;
double MAX_SPEED = 100;

char gear = 'F';

// GUI Values
int speed = 0;
int angle = 0;

String END_CHAR = "\r\n";

Serial port;
LeapMotion leap;

void setup() {
  size(800, 800);
  background(255);
  
  port = new Serial(this, "COM10", 34600);
  leap = new LeapMotion(this);
}

void draw() {
  background(255);
  
  text("Speed: " + speed, 50, 50);
  text("Angle: " + angle, 50, 100);
  text("Gear: " + gearName(gear), 50, 150);
  
  ArrayList<Hand> hands = leap.getHands();
  
  // If no hands are detected, immediately stop the car and reset wheel direction.
  int handCount = hands.size();
  
  if (handCount == 0)
    port.write("STOP" + END_CHAR);
  
  for (Hand hand : hands) {
    // Only validate movements from right hand.
    if (!hand.isRight()) return;
    
    hand.draw();
    
    int outstretchedFingers = hand.getOutstretchedFingers().size();
    boolean isFistClenched = outstretchedFingers == 0;
    
    // If fish is clenched, stop the car immediately.
    if (isFistClenched) {
      port.write("S" + END_CHAR);
      
      speed = 0;
      
      return;
    }
    
    // Change gears
    if (outstretchedFingers == 1)
      gear = 'F';
    else if (outstretchedFingers == 2)
      gear = 'B';
    
    double xPosition = clamp(hand.getPosition().x, MIN_X, MAX_X);
    double yPosition = clamp(hand.getPosition().y, MIN_Y, MAX_Y);
    
    // If position is within a range of the centre of the x axis, treat it as centre (to avoid small movements due to shaky hands)
    if (xPosition > CENTRE_X - X_OFFSET && xPosition < CENTRE_X + X_OFFSET) {
      port.write("s" + END_CHAR);
      
      angle = 90;
    // Map the values into the range (0-180)
    } else {
      int magnitude = (int) map(xPosition, MIN_X, MAX_X, MIN_ANGLE, MAX_ANGLE);
      String data = String.format("D%s", magnitude) + END_CHAR;
    
      angle = magnitude;  
      port.write(data);
    }
      
    // If position is within a range of the centre of the x axis, treat it as centre (to avoid small movements due to shaky hands)
    // Y Position is reversed as the closer the hand is to the leap motion sensor, the greater the value.
    if (yPosition > MAX_Y - Y_OFFSET) {
      port.write("S" + END_CHAR);
      
      // GUI values
      speed = 0;
    // Map the values into the range (0-100)
    } else {
      int magnitude = (int) (MAX_SPEED - map(yPosition, MIN_Y, MAX_Y, MIN_SPEED, MAX_SPEED));
      String data = String.format("%s%s", gear, magnitude) + END_CHAR;
      
      speed = magnitude;
      port.write(data);
    }
    
  }
}

String gearName(char gear) {
  switch (gear) {
  case 'F': return "Forwards";
  case 'B': return "Backwards";
  default: return "None";
  }
}

double clamp(double value, double min, double max) {
  return Math.max(Math.min(max, value), min);
}

double map(double number, double inputMin, double inputMax, double outputMin, double outputMax) {
  return (number - inputMin) / (inputMax - inputMin) * (outputMax - outputMin) + outputMin;
}
