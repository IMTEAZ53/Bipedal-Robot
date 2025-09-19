#include <Servo.h>
#include <Arduino.h>

Servo hipRight, kneeRight;
Servo hipLeft, kneeLeft;

const float L1 = 10.1;
const float L2 = 10.1;

int hipOffsetR = 0;
int kneeOffsetR = 0;
int hipOffsetL = -20;
int kneeOffsetL = -10;

float stepLength = 6.0;
float stepHeight = 4.0;
float centerX = 10.0;
float centerY = 0.0;
float hipSway = 1.5;
float speed = 0.03;
float doubleSupportTime = 0.2;

float t = 0;

void setup() {
  hipRight.attach(2);
  kneeRight.attach(3);
  hipLeft.attach(4);
  kneeLeft.attach(5);

  moveFootRight(centerX, centerY);
  moveFootLeft(centerX, centerY);
  delay(2000);
}

void loop() {
  float phase = fmod(t, 1.0);

  float xR, yR, xL, yL;

  if (phase < doubleSupportTime || phase > (1.0 - doubleSupportTime)) {
    xR = centerX; yR = centerY;
    xL = centerX; yL = centerY;
  } else {
    float swingPhaseR = 2 * PI * phase;
    float swingPhaseL = swingPhaseR + PI;

    xR = centerX + (stepLength/2) * sin(swingPhaseR);
    yR = centerY + (sin(swingPhaseR) > 0 ? stepHeight * sin(swingPhaseR) : 0);

    xL = centerX + (stepLength/2) * sin(swingPhaseL);
    yL = centerY + (sin(swingPhaseL) > 0 ? stepHeight * sin(swingPhaseL) : 0);

    xR += hipSway * sin(swingPhaseR + PI/2);
    xL += hipSway * sin(swingPhaseL + PI/2);
  }

  moveFootRight(xR, yR);
  moveFootLeft(xL, yL);

  t = fmod(t + speed, 1.0);
}

void moveFootRight(float x, float y) {
  float dist = sqrt(x * x + y * y);
  if (dist > (L1 + L2)) dist = (L1 + L2 - 0.01);
  if (dist < fabs(L1 - L2)) dist = fabs(L1 - L2) + 0.01;

  float a = atan2(y, x);
  float b = acos((L1*L1 + dist*dist - L2*L2) / (2*L1*dist));
  float thetaHip = (a - b) * 180.0 / PI;
  float thetaKnee = acos((L1*L1 + L2*L2 - dist*dist) / (2*L1*L2)) * 180.0 / PI;

  int hipAngle = constrain((int)(90 + thetaHip + hipOffsetR), 0, 180);
  int kneeAngle = constrain((int)(180 - thetaKnee + kneeOffsetR), 0, 180);

  hipRight.write(hipAngle);
  kneeRight.write(kneeAngle);
}

void moveFootLeft(float x, float y) {
  float dist = sqrt(x * x + y * y);
  if (dist > (L1 + L2)) dist = (L1 + L2 - 0.01);
  if (dist < fabs(L1 - L2)) dist = fabs(L1 - L2) + 0.01;

  float a = atan2(y, x);
  float b = acos((L1*L1 + dist*dist - L2*L2) / (2*L1*dist));
  float thetaHip = (a - b) * 180.0 / PI;
  float thetaKnee = acos((L1*L1 + L2*L2 - dist*dist) / (2*L1*L2)) * 180.0 / PI;

  int hipAngle = constrain((int)(90 - thetaHip + hipOffsetL), 0, 180);
  int kneeAngle = constrain((int)(thetaKnee + kneeOffsetL), 0, 180);

  hipLeft.write(hipAngle);
  kneeLeft.write(kneeAngle);
}
