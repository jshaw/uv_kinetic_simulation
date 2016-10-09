
// "Light Ball" class for the object installation

class Ball {
  float xpos, ypos, zpos, xoffset, yoffset, zoffset;
  float currentY = 0;
  float previousY = 0;
  boolean usePacket = true;
  
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

  void run(int i) {
    update(i);
    display();
  }

  // Method to update location
  void update(int i) {
  
  }
  
  // Method to update location
  void updateUsePacket(boolean usePack) {
    usePacket = usePack;
  }
  
  // Method to display
  void display() {
      float offsetMovement = (120 * 5 / 2) + (8 * 5) / 2;
      
      if(usePacket == true){
        pushMatrix();
          translate(-(xoffset/2) + xpos, 100 + ypos*1.5, -(xoffset/2) + zpos);
          fill(red, green, blue);
          noStroke();
          sphere(25);
          fill(255, 255, 255);
          stroke(0);
        popMatrix();
      } else {
        
        pushMatrix();
          fill(100);
          noStroke();
          translate(-(xoffset/2) + xpos, 0, zpos);
          box(60, 10, 60);
          stroke(1);
          //The line height will be representative to the ball height
          line(0, 0, 0, 0, offsetMovement + ypos, 0);
        popMatrix();
        
        pushMatrix();
          //translate(-(xoffset/2) + xpos, 100 + ypos*1.5, -(xoffset/2) + zpos);
          translate(-(xoffset/2) + xpos, offsetMovement + ypos, zpos);
          fill(red, green, blue);
          noStroke();
          sphere(25);
          fill(255, 255, 255);
          stroke(0);
        popMatrix(); 
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
    red = r;
    green = g;
    blue = b;
  }
  
  void updateRandomColor() {
    red = map(ypos, -239, 242, 73, 222);
    green = map(ypos, -239, 242, 160, 73);
    blue = map(ypos, -239, 242, 222, 148);
  }
  
  void setDebug(boolean debug) {
    
  }
  

  void setSpeed(float speedUpdate) {
    speed = speedUpdate;
  }
  
  void setYPos(float yUpdate) {
    
    if(usePacket == true){
      
      speedMod = (255-speed)/speedAdjust;
  
      println(speedMod);
      
      if (yUpdate < ypos ){
        if (ypos - yUpdate > speedMod){
          ypos = ypos - speedMod;
        }
        else {
          ypos = yUpdate;
        }
      }
      
      
      if (yUpdate > ypos){
        if (yUpdate - ypos > speedMod){
          ypos = ypos + speedMod;
        }
        else {
          ypos = yUpdate;
        }
      }
    } else {
      ypos = yUpdate;    
    }

  }
}