import peasy.*;
PeasyCam cam;

ArrayList<Ball> balls;

boolean debug = true;
int x = 15;
int y = 8;
int spacing = 80;
float personPosition = 0.0;
float personPositionMoveValue = 5.0;

// even though we are finding the offset for x we need to figure out why this needs to be flipped 
// something about itterating through the matrix / 2d array
int xoffset = spacing * y;
int yoffset = spacing * x;

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
  
  cam = new PeasyCam(this, width/2, height/2 + 200, 0, 2000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2000);
 
  balls = new ArrayList<Ball>();
  
  for(int i = 0; i < x; i++){
    //translate(-width/2, height/2);
    int ypos = i * spacing;
    for(int j = 0; j < y; j++){
      int xpos = j * spacing;
      balls.add(new Ball(xpos, ypos, xoffset, yoffset));
    }
  }
  
}

void draw() {
  background(255);   // Clear the screen with a black background
  translate(width/2,height/2);
  rectMode(CORNER);
  
  drawPerson();
  
  pushMatrix();
    translate(0, 0, -100);
    rect(-yoffset/2 -75, -xoffset/2 - 200, yoffset + 75, xoffset + 200);
    rotateX(radians(90));
    translate(0, xoffset/2, -xoffset/2);
    rect(-yoffset/2 - 75, -xoffset/2, yoffset + 75, xoffset);
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
  text("mouseX", -width/2 - 300, -height/2 + 180);
  text(mouseX, -width/2 - 100, -height/2 + 180);
  text("mouseY", -width/2 - 300, -height/2 + 220);
  text(mouseY, -width/2 - 100, -height/2 + 220);
  fill(255);
  popMatrix();
   
}

void drawPerson() {
  pushMatrix();
  translate(personPosition, 0, 300); 
  fill(220, 20);
  box(100, xoffset, 20);
  popMatrix();
  fill(255);
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