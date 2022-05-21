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

double X_OFFSET = 20;
double Y_OFFSET = 20;

double MIN_X = 120;
double MAX_X = 650;
double CENTRE_X = 385;

double MIN_Y = 300;
double MAX_Y = 600;

char gear = 'F';

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
  
  ArrayList<Hand> hands = leap.getHands();
  
  // If no hands are detected, immediately stop the car and reset wheel direction.
  if (hands.size() == 0)
    port.write("STOP");
  
  for (Hand hand : hands) {
    hand.draw();
    
    int outstretchedFingers = hand.getOutstretchedFingers().size();
    boolean isFistClenched = outstretchedFingers == 0;
    
    // If fish is clenched, stop the car immediately.
    if (isFistClenched) {
      port.write('S');
      
      // Extra info
      text("Speed: 0", 50, 50);
      
      return;
    }
    
    // Change gears
    if (outstretchedFingers == 1)
      gear = 'F';
    else if (outstretchedFingers == 2)
      gear = 'B';
    
    double xPosition = clamp(hand.getPosition().x, MIN_X, MAX_X);
    double yPosition = clamp(hand.getPosition().y, MIN_Y, MAX_Y);
    
    text("X-Position: " + xPosition, 50, 400);
    text("Y-Position: " + yPosition, 50, 450);
    
    // If position is within a range of the centre of the x axis, treat it as centre (to avoid small movements due to shaky hands)
    if (xPosition > CENTRE_X - X_OFFSET && xPosition < CENTRE_X + X_OFFSET) {
      port.write('s');
      
      // Extra info
      text("Angle: 90", 50, 50);
    // Map the values into the range (0-180)
    } else {
      int magnitude = (int) map(xPosition, MIN_X, MAX_X, 0, 180);
      String data = String.format("D%s", magnitude);
      
      // Extra info
      text("Angle: " + magnitude, 50, 50);
      
      port.write(data);
    }
      
    // If position is within a range of the centre of the x axis, treat it as centre (to avoid small movements due to shaky hands)
    // Y Position is reversed as the closer the hand is to the leap motion sensor, the greater the value.
    if (yPosition > MAX_Y - Y_OFFSET) {
      port.write('S');
      
       // Extra info
      text("Speed: 0", 50, 100);
    // Map the values into the range (0-100)
    } else {
      int magnitude = (int) map(MAX_Y - yPosition, MIN_Y, MAX_Y, 0, 100);
      String data = String.format("%s%s", gear, magnitude);
      
      // Extra info
      text("Speed: " + magnitude, 50, 100);
      
      port.write(data);
    }
    
  }
}

double clamp(double value, double min, double max) {
  return Math.max(Math.min(max, value), min);
}

double map(double number, double inputMin, double inputMax, double outputMin, double outputMax) {
  return (number - inputMin) / (inputMax - inputMin) * (outputMax - outputMin) + outputMin;
}
