
// "Sensor" class for the observer

class Ball {
  float xpos, ypos, zpos, xoffset, yoffset, zoffset;
  float rdeg = 1;
  int rotationDirection = 0;
  float rotateIncrease = 0.05;
  boolean inFrontOf = false;
  
  float red, green, blue, movement, speed;

  Ball(float x, float y, float z, float xoff, float yoff, float zoff, float r, float g, float b, float m, float s) {
    rectMode(CENTER);
    xpos = x;
    ypos = y;
    zpos = z;
    
    red = r;
    green = g;
    blue = b;
    movement = m;
    speed = s;
    
    xoffset = xoff;
    yoffset = yoff;
    zoffset = zoff;
    
    setColor();
  }

  void run(float personPosition, int i) {
    update(personPosition, i);
    display();
  }

  // Method to update location
  void update(float personPosition, int i) {
    float s = personPosition - 50;
    float e = personPosition + 50;
    if( -(yoffset/2) + ypos > s && -(yoffset/2) + ypos < e ){
      //println("PERSON IS IN FRONT OF SENSOR: " + i);
      inFrontOf = true;
      rdeg = 1;
    } else {
      inFrontOf = false;
    }
  }
  
  // Method to display
  void display() {
      
      pushMatrix();
      //translate(-(5 * 80)/2 + xpos, (1 * 80)/2 + ypos);
      //translate(-(yoffset/2) + ypos, 0 ,-(xoffset/2) + xpos);
      //translate(-(yoffset/2) + ypos, 10, xpos);
      
      translate(-(xoffset/2) + xpos, ypos, zpos);
      
      // This does a constant 360 rotation
      //rotateX(frameCount*radians(90) / 20);
      //rotateX(rdeg);
      //translate(0, -60);
      //triangle(-30, 30, 0, -30, 30, 30);
      box(60, 10, 40);
      sphereDetail(6);
      translate(0, 5, 0);
      // The line height will be representative to the ball height
      line(0, 0, 0, 0, 25, 0);
      fill(red, green, blue);
      noStroke();
      sphere(10);
      fill(255, 255, 255);
      stroke(0);
      //translate(20, 0, 0);
      //sphere(8);
      popMatrix();
      
      if(inFrontOf == false){
        if(rdeg <= -1.2){
          rotationDirection = 0;
        } else if(rdeg >= 1) {
          rotationDirection = 1;
        }
        
        if(rotationDirection == 1){
          rdeg -= rotateIncrease;
        } else {
          rdeg += rotateIncrease;
        }   
      }
  }
  
  void setColor() {
    red = random(0, 255);
    green = random(0, 255);
    blue = random(0, 255);
  }
}