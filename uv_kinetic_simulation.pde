// the ration to scale 1:5 in this simulation

import peasy.*;
PeasyCam cam;

// import UDP library
import hypermedia.net.*;
UDP udp;  // define the UDP object

ArrayList<Ball> balls;

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

// it might be useful to look into the Shapes 3d library with the Picking example (S3D4P)
// I might need to re-wrtie what boxes get created
// but could be helpful for making examples
// Here are some docs: http://lagers.org.uk/s3d4p/ref/classshapes3d_1_1_shape3_d.html#ad036b3944ac848ce4cb716395e980092

// For the time being create a 3d shape and move it around with the arrow keys... for now rather then mouse movement

float theta = 0.0;  // Start angle at 0
float amplitude = (120.0 * ratio) / 2;  // Height of wave
float period = 500.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing

void setup() {
  //size(800, 600, P3D);
  size(1280, 1000, P3D);
  rectMode(CENTER);
  stroke(0);
  frameRate(30);
  smooth(8);
  
  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 5568 );
  // <-- printout the connection activity
  udp.log( true );     
  udp.listen( true );
  
  cam = new PeasyCam(this, width/2, height/2 + 200, 0, 4000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(4000);
 
  balls = new ArrayList<Ball>();
  
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
      
      // NOTE: IMPORTANT: It might make sense to put this into a 2d array for easy access and updates down below
      // the reason being is that we are going to use 22 different universes so it would make it really easy
      // to target the correct row or column with the sent packet.
      balls.add(new Ball(xpos, ypos, zpos, xoffset, yoffset, zoffset, r, g, b, m, s));
    }
  }
  
}

void draw() {
  background(255);   // Clear the screen with a black background
  translate(width/2,height/2);
  rectMode(CORNER);
  
  float floorPos = -(120.0 * ratio * 1.8);
  
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
  // As mentioned above, would be good to pull from a 2d array here
  for (int i = balls.size()-1; i >= 0; i--) {
    Ball p = balls.get(i);
    p.run(personPosition, i);
    p.setDebug(debug);
    float ypos = sin(x)*amplitude;
    p.setYPos(ypos);
    x+=dx;
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