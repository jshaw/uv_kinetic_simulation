// the ration to scale 1:5 in this simulation

import peasy.*;
PeasyCam cam;

// add sliders
import controlP5.*;
ControlP5 cp5;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

int[][] rawData = new int[11][540];
int[][] dmxData = new int[22][110];

// Could be good use for adjusting for tests
// http://codec.trembl.org/614/
// search : help-with-controlp5.html
// https://forum.processing.org/one/topic/help-with-controlp5.html
// https://forum.processing.org/two/discussion/2487/need-help-with-controlp5-and-rotating-objects

// Ball 2d array
Ball[][] balls;

int[][][] parsedData;

boolean USEPACKET = true;
float speedAdjust = 80.0;
float speedMod;


float ratio = 5.0;

boolean debug = true;
float xgrid = 22;
float ygrid = 0;
float zgrid = 22;
float spacing = 16.0 * ratio;
float personPosition = 0.0;

float speed = 200.0;

// even though we are finding the offset for x we need to figure out why this needs to be flipped 
// something about itterating through the matrix / 2d array
float xoffset = spacing * xgrid;
float yoffset = spacing * ygrid;
float zoffset = spacing * zgrid;

float theta = 0.0;  // Start angle at 0
float amplitude = (120.0 * ratio) / 2;  // Height of wave
// How many pixels before the wave repeats
//float period = 200.0;
//float period = 230;
float period = 320.36;
float dx;  // Value for incrementing X, a function of period and xspacing

void setup() {
  //size(800, 600, P3D);
  size(1280, 1000, P3D);
  rectMode(CENTER);
  stroke(0);
  frameRate(30);
  smooth(8);
  oscP5 = new OscP5(this, 50001);


  cp5 = new ControlP5(this);

  // sine wave period
  cp5.addSlider("period")
    .setPosition(100, 50)
    .setSize(100, 25)
    .setRange(1, 500)
    .setValue(320.36);

  // sine wave spacing
  cp5.addSlider("spacing")
    .setPosition(100, 100)
    .setSize(100, 25)
    .setRange(0, 100);

  cp5.addSlider("speed")
    .setPosition(100, 150)
    .setSize(100, 25)
    .setRange(255, 0)
    .setValue(200.0);

  cp5.getController("period").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setColor(0);
  cp5.getController("period").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setColor(0);

  cp5.getController("spacing").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setColor(0);
  cp5.getController("spacing").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setColor(0);

  cp5.getController("speed").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setColor(0);
  cp5.getController("speed").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setColor(0);

  cp5.setAutoDraw(false);

  // init the balls array
  balls = new Ball[(int)xgrid][(int)zgrid];

  // create a new datagram connection on port 6000
  // and wait for incomming message

  cam = new PeasyCam(this, width/2, height/2 + 200, 0, 4000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(4000);

  dx = (TWO_PI / period) * spacing;

  float ypos = 0;
  float r = 0, g = 0, b = 0, m = 0, s = 0;

  for (int x = 0; x < xgrid; x++) {
    float xpos = x * spacing;
    for (int z = 0; z < zgrid; z++) {
      float zpos = z * spacing;
      //println("xpos: " + xpos);
      //println("ypos: " + ypos);
      //println("zpos: " + zpos);
      //println("xoffset: " + xoffset);
      //println("yoffset: " + yoffset);
      //println("zoffset: " + zoffset);
      //println("=============");

      // I'm storying the ball objects into a 2d array
      // this is done for easy access to each of the the 22 universes.
      // This is done via the universe number from the UDP packet
      // and the row or column can be directly refferences and retreived
      balls[x][z] = new Ball(xpos, ypos, zpos, xoffset, yoffset, zoffset, r, g, b, m, s);
    }
  }
}

void draw() {
  background(40);   // Clear the screen with a black background
  //translate(width/2,height/2);
  translate(width/2, -height/10);
  rectMode(CORNER);

  float floorPos = -(120.0 * ratio * 1.8);

  dx = (TWO_PI / period) * spacing;

  drawOrigin();
  //drawPerson(floorPos);

  //if (USEPACKET == true) {
  //  parsePacket();
  //}

  pushMatrix();
  rotateX(radians(90));
  translate(0, -900, 8);
  fill(0);
  rect(-xoffset/2 - 500, -500, zoffset + 1000, zoffset + 1000);
  //translate(0, 0, floorPos);
  //rect(-xoffset/2 - 75, -75, zoffset + 75, zoffset + 75);
  popMatrix();

  //theta += 0.02;
  theta += map(speed, 255, 0, 0, 0.1);
  float x = theta;

  // Switched to a 2d array for easy universe access
  float numToLoop = 0.0;
  if (USEPACKET == true) {
    numToLoop = xgrid;
  } else {
    numToLoop = xgrid;
  }
  for (int i = 0; i < numToLoop; i++) {
    for (int j = 0; j < zgrid; j++) {
      Ball p = balls[i][j];
      p.run(i);
      p.setDebug(debug);
      float ypos = sin(x) * amplitude;

      p.setSpeed(dmxData[i][1+j*5]); //second DMX address
      p.setYPos(dmxData[i][j*5]);    //first DMX address

      if (USEPACKET == true) {
        // the rpacket, gpacket, bpacket are taken from the DMX universe for the 
        // appropirate row and column
        p.updateColor(dmxData[i][2+j*5], dmxData[i][3+j*5], dmxData[i][4+j*5]);   //Third, fourth and fifth DMX address
      } else {
        p.updateRandomColor();
      }

      x += dx;
    }
  }

  pushMatrix();
  textSize(32);
  fill(0);
  text("mouseX", -width/2 - 800, -height/2 + 280);
  text(mouseX, -width/2 - 600, -height/2 + 280);
  text("mouseY", -width/2 - 800, -height/2 + 320);
  text(mouseY, -width/2 - 600, -height/2 + 320);
  fill(255);
  popMatrix();

  //gui();
}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void keyPressed() {
  println("---");
  if (key == CODED) {
    if (keyCode == LEFT) {
      // Do up up stuff here
      println("LEFT");
    } else if (keyCode == RIGHT) {
      // Do down stuff here
      println("RIGHT");
    }
  }


}

//void mousePressed() {
//  debug = !debug;
//}

void drawOrigin() {
  pushMatrix();
  translate(0, 0, -75);
  sphereDetail(10);
  sphere(50);
  popMatrix();
}

/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
// void receive( byte[] data ) {       // <-- default handler
void receive( byte[] data, String ip, int port ) {  // <-- extended handler

  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-2);
  String message = new String( data );

  // print the result
  println( "receive: \""+message+"\" from "+ip+" on port "+port );
}

// This might be helpful for testing interactions later
void drawPerson(float floorPos) {
  pushMatrix();
  translate(personPosition, -floorPos - 160, 600); 
  fill(220, 20);
  box(100, 300, 20);
  popMatrix();
  fill(255);
}


void mousePressed(){
  println("speedMod: " + speedMod);

}

void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */

  if (theOscMessage.checkAddrPattern("/dmx/universe/1")==true) {
    rawData[0] =  int(theOscMessage.getBytes()); 
    // remap the DMX data
    dmxData[0] = subset(rawData[0], 24, 110);
    dmxData[1] = subset(rawData[0], 134, 110);
    //for (int i = 0; i < dmx1.length; i ++) {
    //  print(dmx1[i] + ",");
    //}
    //println
    //println("UNIVERSE 1 RECEIVED");
  } 
  if (theOscMessage.checkAddrPattern("/dmx/universe/2")==true) {
    rawData[1] =  int(theOscMessage.getBytes());  
    dmxData[2] = subset(rawData[1], 24, 110);
    dmxData[3] = subset(rawData[1], 134, 110);
    //println("UNIVERSE 2 RECEIVED");
  }
  if (theOscMessage.checkAddrPattern("/dmx/universe/3")==true) {
    rawData[2] =  int(theOscMessage.getBytes());  
    dmxData[4] = subset(rawData[2], 24, 110);
    dmxData[5] = subset(rawData[2], 134, 110);
    //println("UNIVERSE 3 RECEIVED");
  }
  if (theOscMessage.checkAddrPattern("/dmx/universe/4")==true) {
    rawData[3] =  int(theOscMessage.getBytes());  
    dmxData[6] = subset(rawData[3], 24, 110);
    dmxData[7] = subset(rawData[3], 134, 110);
    //println("UNIVERSE 4 RECEIVED");
  }
  if (theOscMessage.checkAddrPattern("/dmx/universe/5")==true) {
    rawData[4] =  int(theOscMessage.getBytes());  
    dmxData[8] = subset(rawData[4], 24, 110);
    dmxData[9] = subset(rawData[4], 134, 110);
    //println("UNIVERSE 5 RECEIVED");
  }
  if (theOscMessage.checkAddrPattern("/dmx/universe/6")==true) {
    rawData[5] =  int(theOscMessage.getBytes());  
    dmxData[10] = subset(rawData[5], 24, 110);
    dmxData[11] = subset(rawData[5], 134, 110);
    //println("UNIVERSE 6 RECEIVED");
  }
  if (theOscMessage.checkAddrPattern("/dmx/universe/7")==true) {
    rawData[6] =  int(theOscMessage.getBytes());  
    dmxData[12] = subset(rawData[6], 24, 110);
    dmxData[13] = subset(rawData[6], 134, 110);
    //println("UNIVERSE 7 RECEIVED");
  }
  if (theOscMessage.checkAddrPattern("/dmx/universe/8")==true) {
    rawData[7] =  int(theOscMessage.getBytes());  
    dmxData[14] = subset(rawData[7], 24, 110);
    dmxData[15] = subset(rawData[7], 134, 110);
    //println("UNIVERSE 8 RECEIVED");
  }
  if (theOscMessage.checkAddrPattern("/dmx/universe/9")==true) {
    rawData[8] =  int(theOscMessage.getBytes());  
    dmxData[16] = subset(rawData[8], 24, 110);
    dmxData[17] = subset(rawData[8], 134, 110);
    //println("UNIVERSE 9 RECEIVED");
  }
  if (theOscMessage.checkAddrPattern("/dmx/universe/10")==true) {
    rawData[9] =  int(theOscMessage.getBytes());  
    dmxData[18] = subset(rawData[9], 28, 110);
    dmxData[19] = subset(rawData[9], 138, 110);
    //println("UNIVERSE 10 RECEIVED");
  }
  if (theOscMessage.checkAddrPattern("/dmx/universe/11")==true) {
    rawData[10] =  int(theOscMessage.getBytes());  
    dmxData[20] = subset(rawData[10], 28, 110);
    dmxData[21] = subset(rawData[10], 138, 110);
    //println("UNIVERSE 11 RECEIVED");
  }


}