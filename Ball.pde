
// "Sensor" class for the observer

class Ball {
  int xpos, ypos, xoffset, yoffset;
  float rdeg = 1;
  int rotationDirection = 0;
  float rotateIncrease = 0.05;
  boolean inFrontOf = false;

  Ball(int x, int y, int xoff, int yoff) {
    rectMode(CENTER);
    xpos = x;
    ypos = y;
    
    xoffset = xoff;
    yoffset = yoff;
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
      println("PERSON IS IN FRONT OF SENSOR: " + i);
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
      translate(-(yoffset/2) + ypos, -(xoffset/2) + xpos);
      
      // This does a constant 360 rotation
      //rotateX(frameCount*radians(90) / 20);
      rotateX(rdeg);
      //translate(0, -60);
      //triangle(-30, 30, 0, -30, 30, 30);
      box(60, 40, 10);
      sphereDetail(6);
      translate(-10, 0, 5);
      sphere(8);
      translate(20, 0, 0);
      sphere(8);
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
}