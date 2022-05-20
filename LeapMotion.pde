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

double YAW_OFFSET = Math.PI / 5;
double PITCH_OFFSET = Math.PI / 5;

Serial port;
LeapMotion leap;

void setup() {
  size(800, 800);
  background(255);
  
  text("PI: " + Math.PI, 0, 0);
  
  port = new Serial(this, "COM10", 34600);
  leap = new LeapMotion(this);
}

void draw() {
  background(255);
  
  for (Hand hand : leap.getHands()) {
    hand.draw();
    
    boolean isFistClenched = hand.getOutstretchedFingers().size() == 0;
    
    // If fish is clenched, stop the car immediately.
    if (isFistClenched) {
      port.write("STOP");
      
      return;
    }
    
    float handYaw = hand.getYaw();
    float handPitch = hand.getPitch();
    
    // tweak these things..........
    int yawMagnitude = handYaw;
    int pitchMagnitude = handPitch;
    
    // Yaw axis of hand
    if (handYaw > YAW_OFFSET) {
      port.write("D180");
    } else if (handYaw < -YAW_OFFSET) {
      port.write("D0");
    }
    
    // Pitch axis of hand
    if (handPitch > PITCH_OFFSET) {
      port.write("F50");
    } else if (handPitch < -PITCH_OFFSET) {
      port.write("B50");
    }
    
  }
}
