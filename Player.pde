// This code was based off of:
// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2011
// Box2DProcessing example

float BOUNDRY_SIZE = Boundary/2 + 1;


class Player {

    int holder;
    
    float x, y;
    float offsetX, offsetY;
    float radius;
    float bubbleColorInt;
    String rightName;
    
    float vx;
    float vy;
    
    float vx1, vx2;
    float vy1, vy2;
    
    float terminalVx;
    float terminalVy;
    
    boolean hasSpring;
    
    boolean destroying;
    
    float flagSize;
    
    boolean puck;
    boolean goal;
    
    float leftBound;
    float rightBound;
    
    // Constructor
    Player(float x, float y, boolean puck, boolean goal) {
        this.x = x;
        this.y = y;
        this.puck = puck;
        this.goal = goal;
        bubbleColorInt = random(1, 360);
        vx = 0;
        vy = 0;//random initial velocity
        
        vx1 = 0;
        vx2 = 0;
        vy1 = 0;
        vy2 = 0;
        
        this.terminalVx = terminalVX;
        this.terminalVy = terminalVY;
        
        this.radius = getRadius();
        
        destroying = false;
        
        flagSize = 400;
        
        holder = 999;
        
        if(PLAYERCOUNT == 4){
        
                if(puck || goal){
                  leftBound = BOUNDRY_SIZE;
                  rightBound = sketchWidth - BOUNDRY_SIZE;
                }
                else if(x < sketchWidth/4){
                  leftBound = BOUNDRY_SIZE;
                  rightBound = sketchWidth/4;
                }
                else if(x < sketchWidth/2){
                  leftBound = sketchWidth/4;
                  rightBound = sketchWidth/2;
                }
                else if(x < sketchWidth*3/4){
                  leftBound = sketchWidth/2;
                  rightBound = sketchWidth*3/4;
                }
                else{
                  leftBound = sketchWidth*3/4;
                  rightBound = sketchWidth - BOUNDRY_SIZE;
                }
        }
        else if(PLAYERCOUNT == 2){
                if(puck || goal){
                  leftBound = BOUNDRY_SIZE;
                  rightBound = sketchWidth - BOUNDRY_SIZE;
                }
                else if(x < sketchWidth/2){
                  leftBound = BOUNDRY_SIZE;
                  rightBound = sketchWidth/2;
                }
                else{
                  leftBound = sketchWidth/2;
                  rightBound = sketchWidth - BOUNDRY_SIZE;
                }
        }
    }
    
    void destroy(){
        destroying = true;
    }
    
    void goalCheck(){
      if(!puck)  return;
      if (x + radius < 0){//in left goal
        rightScore++;
        x = sketchWidth/2 - sketchHeight/4;
        y = sketchHeight/2;
        vx = 0;
        vy = 0;
        holder = 999;
        hasSpring = false;
      }
      if(x - radius > sketchWidth){//in right goal
        leftScore++;
        x = sketchWidth/2 + sketchHeight/4;
        y = sketchHeight/2;
        vx = 0;
        vy = 0;
        holder = 999;
        hasSpring = false;
      }
    }
    
    void collide() {
        if(this.x < leftBound || this.x > rightBound)  return;
        for (int i = 0; i < players.size(); i++) {
          Player bub = players.get(i); 
            if(bub.x < bub.leftBound || bub.x > bub.rightBound) continue;
            if((this.puck && bub != this) || (!this.puck && bub.puck)){ 
                float dx = bub.x - x;
                float dy = bub.y - y;
                float distance = sqrt(dx*dx + dy*dy);
                float minDist = bub.radius + radius;
                if (distance < minDist) { 
                    println("COLLIDE");

                    float angle = atan2(dy, dx);
                    float targetX = x + cos(angle) * minDist;
                    float targetY = y + sin(angle) * minDist;
                    float ax = (targetX - bub.x);
                    float ay = (targetY - bub.y);
                    vx -= ax;
                    vy -= ay;
                    bub.vx += ax;
                    bub.vy += ay;
                    vx *= friction;
                    vy *= friction;
                    bub.vx *= friction;
                    bub.vy *= friction;
                    //        if(vx < 1 && vx > -1)  vx = 0;   
                    //        if(vy < 1 && vy > -1)  vy = 0;   
                }
            }
        }   
    }
    
    void moveByTouch(float touchX, float touchY){
        terminalVx = 100;
        terminalVy = 100;        
    
        vx = (touchX - offsetX - x)/throwEase;
        vy = (touchY - offsetY - y)/throwEase;
        x = touchX-offsetX;
        y = touchY-offsetY;
    }
    void move(){
        vy2 = vy1;
        vx2 = vx1;
        vy1 = vy;
        vx1 = vx;
        if(!hasSpring){
            if(this.terminalVx > terminalVX){
                if(vx < terminalVx && vx > 0 - terminalVx){
                    terminalVx = terminalVx;
                }
            }
            if(this.terminalVy > terminalVY){
                if(vy < terminalVy && vy > 0 - terminalVy){
                    terminalVy = terminalVy;
                }
            }
            
            if(vy > terminalVy){
                vy = terminalVy;
            }
            if(vy < 0 - terminalVy){
                vy = 0 - terminalVy;
            }
            
            if(vx > terminalVx){
                vx = terminalVx;
            }
            if(vx < 0 - terminalVx){
                vx = 0 - terminalVx;
            }
        
            x += vx;
            y += vy;
        }
        
        //float boundary_size = 0;
        
        //Collision detection against boundaries 
        if ((!puck || (puck && (y > sketchHeight*(goalSize-1)/goalSize + BOUNDRY_SIZE)
                            || (y < sketchHeight/goalSize - BOUNDRY_SIZE)))
          && (x + radius > rightBound)) {//RIGHT
            x = rightBound - radius;
            vx *= 0 - wallFriction; 
        }
        else if ((!puck || (puck && (y > sketchHeight*(goalSize-1)/goalSize + BOUNDRY_SIZE)
                            || (y < sketchHeight/goalSize - BOUNDRY_SIZE)))
          && (x - radius < leftBound)) {//LEFT
            x = leftBound + radius;
            vx *= 0 - wallFriction;
        }
        if (y + radius + BOUNDRY_SIZE > sketchHeight) {//BOTTOM
            y = sketchHeight - radius - BOUNDRY_SIZE;
            vy *= 0 - groundFriction; 
        } 
        else if (y - radius - BOUNDRY_SIZE < 0) {//TOP
            y = radius + BOUNDRY_SIZE;
            vy *= 0 - wallFriction;
        }
        
        
        
//        if(vy2<0 && vy1>0 && vy<0){ vy = 0; print("HEY");}
//        if(vy2>0 && vy1<0 && vy>0){ vy = 0; print("HEY");}
//        if(vx2<0 && vx1>0 && vx<0){ vx = 0; print("YOU");}
//        if(vx2>0 && vx1<0 && vx>0){ vx = 0; print("YOU");}
//        print("I DONT LIKE YOUR BOYFRIEND");
    }
    
    // This function calculates radius size
    float getRadius(){
      if(puck)  return puckSize;
      if(goal)  return Boundary/2;
      else      return playerSize;
    }
    
    void display() {
        pushMatrix();
        pushStyle();
        
        
        //set drawing modes
        //    colorMode(RGB, 100);
        ellipseMode(PConstants.CENTER);
        rectMode(CENTER);
        textAlign(CENTER, BOTTOM);
        
        stroke(255, random(200, 255)); //white circumference
        
        strokeWeight(2);
        
        if(x < sketchWidth/2){
          fill(120, 200, 255);
        }
        else{
          fill(200, 50, 50);
        }
        
        if(puck){
          fill(220, 220, 220, 0);
          strokeWeight(sketchHeight*5/1600);
          stroke(255, 100, 0, random(100, 255));
          println(this.x + ", " + this.y);
        }
        
        if(goal){
          noFill();
          strokeWeight(0);
        }
                
        translate(x, y);
        
        textSize(sketchWidth/160);
        //draw bubble
        ellipse(0, 0, (radius)*2, (radius)*2);
        if(puck){
          fill(120, 170, 255, 0);
          ellipse(0, 0, radius*1.5, radius*1.5);
        }
        
        
        
        //debugging text: displays x and y velocities
        fill(255);
//            text(holder+"",  0, (0-radius/3)+10, radius*1.8, 4*sketchWidth/80);
//            text(vy+"",  0, (0-radius/3)+25, radius*1.8, 4*fontSize);
        
        popStyle();
        popMatrix();
    }
        
    boolean contains(float x, float y) {
        boolean inside = false;
        if(sqrt((x-this.x)*(x-this.x) + (y-this.y)*(y-this.y)) <= this.radius){
            inside = true;
        }
        return inside;
    }
     
}
