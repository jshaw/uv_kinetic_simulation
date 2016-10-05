// the ration to scale 1:5 in this simulation

import peasy.*;
PeasyCam cam;

// add sliders
import controlP5.*;
ControlP5 cp5;

// import UDP library
import hypermedia.net.*;
UDP udp;  // define the UDP object

// Could be good use for adjusting for tests
// http://codec.trembl.org/614/
// search : help-with-controlp5.html
// https://forum.processing.org/one/topic/help-with-controlp5.html
// https://forum.processing.org/two/discussion/2487/need-help-with-controlp5-and-rotating-objects


// Ball 2d array
Ball[][] balls;

float ratio = 5.0;
String packet = "001000004153432d45312e3137000000726e00000004c8bc8891a9064403a819a3f86f9fa0b27258000000024e415448414e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006400005300000b720b02a1000000010201007373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

boolean debug = true;
float xgrid = 22;
float ygrid = 0;
float zgrid = 22;
float spacing = 16.0 * ratio;
float personPosition = 0.0;
float personPositionMoveValue = 5.0;

// even though we are finding the offset for x we need to figure out why this needs to be flipped 
// something about itterating through the matrix / 2d array
float xoffset = spacing * xgrid;
float yoffset = spacing * ygrid;
float zoffset = spacing * zgrid;

float theta = 0.0;  // Start angle at 0
float amplitude = (120.0 * ratio) / 2;  // Height of wave
float period = 200.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing

void setup() {
  //size(800, 600, P3D);
  size(1280, 1000, P3D);
  rectMode(CENTER);
  stroke(0);
  frameRate(30);
  smooth(8);
  
  cp5 = new ControlP5(this);
  
  // sine wave period
  cp5.addSlider("period")
   .setPosition(100,50)
   .setSize(100, 25)
   .setRange(1,500);
   
  // sine wave spacing
  cp5.addSlider("spacing")
   .setPosition(100, 100)
   .setSize(100, 25)
   .setRange(0,100);
   
  cp5.getController("period").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setColor(0);
  cp5.getController("period").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setColor(0);
  
  cp5.getController("spacing").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setColor(0);
  cp5.getController("spacing").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setColor(0);
   
  cp5.setAutoDraw(false);
  
  // init the balls array
  balls = new Ball[(int)xgrid][(int)zgrid];
  
  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 5568 );
  // <-- printout the connection activity
  udp.log( true );     
  udp.listen( true );
  
  cam = new PeasyCam(this, width/2, height/2 + 200, 0, 4000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(4000);
  
  dx = (TWO_PI / period) * spacing;
  
  float ypos = 0;
  float r = 0, g = 0, b = 0, m = 0, s = 0;
  
  for(int x = 0; x < xgrid; x++){
    float xpos = x * spacing;
    for(int z = 0; z < zgrid; z++){
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
  background(255);   // Clear the screen with a black background
  //translate(width/2,height/2);
  translate(width/2, -height/10);
  rectMode(CORNER);
  
  float floorPos = -(120.0 * ratio * 1.8);
  
  dx = (TWO_PI / period) * spacing;
  
  drawOrigin();
  drawPerson(floorPos);
  
  pushMatrix();
    rotateX(radians(90));
    translate(0, 0, 8);
    rect(-xoffset/2 - 75, -75, zoffset + 75, zoffset + 75);
    translate(0, 0, floorPos);
    rect(-xoffset/2 - 75, -75, zoffset + 75, zoffset + 75);
  popMatrix();
  
  theta += 0.02;
  float x = theta;
  float y = theta;
  
  // Switched to a 2d array for easy universe access
  for(int i = 0; i < xgrid; i++){
    for(int j = 0; j < zgrid; j++){
      Ball p = balls[i][j];
      p.run(personPosition, i);
      p.setDebug(debug);
      float ypos = sin(x) * amplitude;
      //float ypos = ( sin( x ) + cos( y ) ) * amplitude;
      p.setYPos(ypos);
      x += dx;
      y += dx;
      
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
  
  gui();
}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void keyPressed(){
  println("---");
  if (key == CODED) {
    if (keyCode == LEFT) {
      // Do up up stuff here
      personPosition -= personPositionMoveValue;
      println("LEFT");
    } else if (keyCode == RIGHT) {
      // Do down stuff here
      println("RIGHT");
      personPosition += personPositionMoveValue;
    }
  }
  
  String message  = str( key );  // the message to send
  String ip       = "localhost";  // the remote IP address
  int port        = 5568;    // the destination port
  
  // formats the message for Pd
  message = message+";\n";
  
  // this message takes the test packet data from the c++ OF program and sends it via UDP
  //message = packet + ";\n";
  // send the message
  udp.send( message, ip, port );
}

void mousePressed() {
  debug = !debug;
}

void drawOrigin() {
  pushMatrix();
    translate(0,0, -75);
    sphereDetail(6);
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