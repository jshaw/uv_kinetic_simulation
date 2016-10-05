import peasy.*;
PeasyCam cam;

ArrayList<Ball> balls;

boolean debug = true;
//float x = 22;
//float y = 22;
//float z = 0;
float xgrid = 22;
float ygrid = 0;
float zgrid = 22;
int spacing = 80;
float personPosition = 0.0;
float personPositionMoveValue = 5.0;

// even though we are finding the offset for x we need to figure out why this needs to be flipped 
// something about itterating through the matrix / 2d array
//float xoffset = spacing * y;
//float yoffset = spacing * x;
//float zoffset = spacing * z;

float xoffset = spacing * xgrid;
float yoffset = spacing * ygrid;
float zoffset = spacing * zgrid;

// it might be useful to look into the Shapes 3d library with the Picking example (S3D4P)
// I might need to re-wrtie what boxes get created
// but could be helpful for making examples
// Here are some docs: http://lagers.org.uk/s3d4p/ref/classshapes3d_1_1_shape3_d.html#ad036b3944ac848ce4cb716395e980092

// For the time being create a 3d shape and move it around with the arrow keys... for now rather then mouse movement

void setup() {
  //size(800, 600, P3D);
  size(1280, 1000, P3D);
  rectMode(CENTER);
  stroke(0);
  frameRate(30);
  smooth(8);
  //translate((spacing * y) / 2, (spacing * x) / 2);
  //translate(-width/2, height/2);
  
  cam = new PeasyCam(this, width/2, height/2 + 200, 0, 4000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(4000);
  
  //camera();
  //camera(70.0, 35.0, 120.0, 50.0, 50.0, 0.0, 0.0, 1.0, 0.0);
 
  balls = new ArrayList<Ball>();
  
  //float zpos = 0;
  float ypos = 0;
  float r = 0, g = 0, b = 0, m = 0, s = 0;
  
  for(int x = 0; x < xgrid; x++){
    //translate(-width/2, height/2);
    float xpos = x * spacing;
    for(int z = 0; z < zgrid; z++){
      float zpos = z * spacing;
      println("xpos: " + xpos);
      println("ypos: " + ypos);
      println("zpos: " + zpos);
      println("xoffset: " + xoffset);
      println("yoffset: " + yoffset);
      println("zoffset: " + zoffset);
      println("=============");
      balls.add(new Ball(xpos, ypos, zpos, xoffset, yoffset, zoffset, r, g, b, m, s));
    }
  }
  
}

void draw() {
  background(255);   // Clear the screen with a black background
  translate(width/2,height/2);
  rectMode(CORNER);
  
  drawPerson();
  
  pushMatrix();
    //translate(0, 0, 0);
    //rect(-yoffset/2 -75, -xoffset/2 - 200, yoffset + 75, xoffset + 200);
    rotateX(radians(90));
    translate(0, 0, 8);
    rect(-xoffset/2 - 75, -75, zoffset + 75, zoffset + 75);
    translate(0, 0, -658);
    rect(-xoffset/2 - 75, -75, zoffset + 75, zoffset + 75);
  popMatrix();

  // testing line
  //y = y - 1; 
  //if (y < 0) { 
  //  y = height; 
  //} 
  
  //line(0, y, width, y); 
  
  //pushMatrix();
  //rotateX(frameCount*radians(90) / 20);
  //translate(0, -60);
  //triangle(-30, 30, 0, -30, 30, 30);
  //popMatrix();
  
  for (int i = balls.size()-1; i >= 0; i--) {
    Ball p = balls.get(i);
    p.run(personPosition, i);
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
}

void mousePressed() {
  debug = !debug;
}


// This might be helpful for testing interactions later
void drawPerson() {
  pushMatrix();
  translate(personPosition, 500, 600); 
  fill(220, 20);
  box(100, 300, 20);
  popMatrix();
  fill(255);
}