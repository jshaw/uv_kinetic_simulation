
// "Sensor" class for the observer

class Ball {
  float xpos, ypos, zpos, xoffset, yoffset, zoffset;
  float rdeg = 1;
  int rotationDirection = 0;
  float rotateIncrease = 0.05;
  boolean inFrontOf = false;
  
  float currentY = 0;
  float previousY = 0;
  
  float red, green, blue, movement, speed;

  Ball(float x, float y, float z, float xoff, float yoff, float zoff, float r, float g, float b, float m, float s) {
    rectMode(CENTER);
    xpos = x;
    ypos = y;
    zpos = z;
    
    xoffset = xoff;
    yoffset = yoff;
    zoffset = zoff;
    
    red = r;
    green = g;
    blue = b;
    movement = m;
    speed = s;
    
    setColor();
  }

  void run(float personPosition, int i) {
    update(personPosition, i);
    display();
  }

  // Method to update location
  void update(float personPosition, int i) {
  
  }
  
  // Method to display
  void display() {
      float offsetMovement = (120 * 5 / 2) + (8 * 5) / 2;
      pushMatrix();
        translate(-(xoffset/2) + xpos, 0, zpos);
        box(60, 10, 60);
        // The line height will be representative to the ball height
        line(0, 0, 0, 0, offsetMovement + ypos, 0);
      popMatrix();
      
      pushMatrix();
        translate(-(xoffset/2) + xpos, offsetMovement + ypos, zpos);
        fill(red, green, blue);
        noStroke();
        sphere((8 * 5) / 2);
        fill(255, 255, 255);
        stroke(0);
      popMatrix();
      
      if(inFrontOf == false){
        if(rdeg <= -1.2){
          rotationDirection = 0;
        } else if(rdeg >= 1) {
          rotationDirection = 1;
        }
        
        //if(rotationDirection == 1){
        //  rdeg -= rotateIncrease;
        //} else {
        //  rdeg += rotateIncrease;
        //}   
      }
  }
  
  // Sets the default colors randomly
  // only run once from the constructor
  void setColor() {
    red = random(0, 255);
    green = random(0, 255);
    blue = random(0, 255);
  }
  
  void updateColor(float r, float g, float b) {
    red = map(r, -239, 242, 73, 222);
    green = map(g, -239, 242, 160, 73);
    blue = map(b, -239, 242, 222, 148);
  }
  
  void updateRandomColor() {
    red = map(ypos, -239, 242, 73, 222);
    green = map(ypos, -239, 242, 160, 73);
    blue = map(ypos, -239, 242, 222, 148);
  }
  
  void setDebug(boolean debug) {
    
  }
  
  void setYPos(float yUpdate) {
    //currentY = yUpdate;
    //if(previousY == currentY){
    //  // the direction wouldn't have changed
    //  if (currentY == 255){
    //    if(ypos < 254){
    //      ypos += 10;
    //    }
        
    //  } else {
    //    if(ypos > 0){
    //      ypos -= 10;
    //    }
    //  }
      
    //}
    
    //previousY = currentY;
    
    ypos = yUpdate;
  }
  
}