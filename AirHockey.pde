
import netP5.*;
import oscP5.*;

// MPE includes
import mpe.Process;
import mpe.Configuration;

/****** Massive Pixel Environment ******/
// MPE Process thread
Process process;

// MPE Configuration object
Configuration tileConfig;

// makes it easy to swap between MPE dimensions and regular sketch dimensions
int sketchWidth, sketchHeight;  

boolean FULLSCREEN = false;
boolean MPE_ON = true;
TuioHandler myTuioHandler;
OscP5 oscP5;
NetAddressList nodes = new NetAddressList();

HashMap<String, Integer> playerMap; //maps IP to player#

PFont digitalFont;

SynchronizedList<Player> players;
int PLAYERCOUNT = 2;
Integer numPlayers = 0; //should always be 0

float Boundary;

int goalSize = PLAYERCOUNT * 2;
float puckSize = 65;
float playerSize = 100;

//Physics
float friction = 0.9;
float wallFriction = 0.4;
float groundFriction = 0.3;//0.7;
float terminalVY = 99999;
float terminalVX = 99999;
float throwEase = 0.4;//Higher the throwEase, the harder to throw

int leftScore = 0;
int rightScore = 0;

void setup() {
  
  if (MPE_ON) {
    FULLSCREEN = false;

    // create a new configuration object and specify the path to the configuration file
    tileConfig = new Configuration("/home/vislab/Processing/MPE/config/configuration_s01.xml", this);
//    tileConfig = new Configuration("/home/vislab/Processing/MPE/config/configuration_quad1.xml", this);
//    tileConfig = new Configuration("/home/vislab/Processing/MPE/config/configuration_quad2.xml", this);
//    tileConfig = new Configuration("/home/vislab/Processing/MPE/config/configuration_quad3.xml", this);
//    tileConfig = new Configuration("/home/vislab/Processing/MPE/config/configuration_quad4.xml", this);
//    tileConfig = new Configuration("/home/vislab/Processing/MPE/config/configuration_leftHalf.xml", this);
//    tileConfig = new Configuration("/home/vislab/Processing/MPE/config/configuration_rightHalf.xml", this);
//    tileConfig = new Configuration("/home/vislab/Processing/MPE/config/configuration_full.xml", this);

    // set the size of the sketch based on the configuration file
    size(tileConfig.getLWidth(), tileConfig.getLHeight(), P3D);

    // create a new process
    process = new Process(tileConfig);

    sketchWidth  = process.getMWidth();
    sketchHeight = process.getMHeight();

    // initialize tuio handler
//    myTuioHandler = new TuioHandler(this, 1, min(sketchWidth,sketchHeight)/80, null);
    myTuioHandler = new TuioHandler(this, 32);
    
    // only setup osc if you're the leader
    // we don't want the render nodes broadcasting anything related to TUIO!!!
    if(tileConfig.isLeader()) {
      oscP5 = new OscP5(this, 3334);
      // use broadcast ip to send any tuio event to all stallion nodes (including head node)
      nodes.add(new NetAddress("129.114.10.255", 3333));
      nodes.add(new NetAddress("129.114.10.255", 3332));
      nodes.add(new NetAddress("129.114.10.255", 3331));
      nodes.add(new NetAddress("129.114.10.255", 3330));
    }

    randomSeed(1);
  } 
  else {
    if(FULLSCREEN) size (displayWidth, displayHeight, P2D); //run from "Sketch->Present" or "Shift+Command+R"
    else size(2560, 500, P2D);
    
    sketchWidth = width;
    sketchHeight = height;
    
    myTuioHandler = new TuioHandler(this, 32);
    oscP5 = new OscP5(this, 3334);
    // only forward tuio events to head node
    nodes.add(new NetAddress("129.114.10.255", 3333));
  }
  
  Boundary = sketchHeight/40;
  puckSize = sketchHeight/25;
  playerSize = sketchHeight/16;
  
  players = new SynchronizedList<Player>();
  playerMap = new HashMap<String, Integer>();
  
  smooth();
  
  digitalFont = createFont("Digital.ttf", 128);
  textFont(digitalFont);
  
//  for(int i = 0; i < PLAYERCOUNT; i++){
//      players.add(new Player(sketchWidth*(2*i + 1)/(PLAYERCOUNT*2), sketchHeight/2, false, false));
//  }
  players.add(new Player(sketchWidth/2, sketchHeight/2, true, false));//puck
  
  //goal corners
  players.add(new Player(0, sketchHeight/(goalSize) - Boundary/2, false, true));
  players.add(new Player(0, sketchHeight*(goalSize - 1)/(goalSize) + Boundary/2, false, true));
  players.add(new Player(sketchWidth, sketchHeight/(goalSize) - Boundary/2, false, true));
  players.add(new Player(sketchWidth, sketchHeight*(goalSize - 1)/(goalSize) + Boundary/2, false, true));
  
  if(MPE_ON) process.start();
}

void draw() {
 drawBackground(); // comment out if you want to draw line

    for (int i = 0; i < players.size(); i++) {
          Player bub = players.get(i);
          bub.collide();
          if(!bub.goal){
//            if(bub.hasSpring){
//              bub.vx = 0;
//              bub.vy = 0;
//            }
//            else
              bub.move();
          }
          bub.display();
          if(bub.puck){
            bub.goalCheck();
          }
    }
//
//  myTuioHandler.debugCursors();
}

void drawBackground(){
  background(0);
  pushStyle();
  pushMatrix();
  strokeWeight(0);
  fill(255);
  float rectWidth = Boundary;
  rectMode(CENTER);
  rect(sketchWidth/2, 0, sketchWidth, rectWidth);//top
  rect(sketchWidth/2, sketchHeight, sketchWidth, rectWidth);//bottom
  
  rect(0, sketchHeight/(2*goalSize), rectWidth, sketchHeight/goalSize, rectWidth/2);//top-left
  rect(0, sketchHeight*(2*goalSize - 1)/(2*goalSize), rectWidth, sketchHeight/goalSize, rectWidth/2);//bottom-left
  
  rect(sketchWidth, sketchHeight/(2*goalSize), rectWidth, sketchHeight/goalSize, rectWidth/2);//top-right
  rect(sketchWidth, sketchHeight*(2*goalSize - 1)/(2*goalSize), rectWidth, sketchHeight/goalSize, rectWidth/2);//bottom-right
  
  pushStyle();
  noFill();
  strokeWeight(rectWidth/2);
  stroke(255);
  ellipse(sketchWidth/2, sketchHeight/2, sketchHeight/2, sketchHeight/2);//middle circle
//  ellipse(0, sketchHeight/2, sketchHeight/3, sketchHeight/3+10);//left semicircle
//  ellipse(sketchWidth, sketchHeight/2, sketchHeight/3, sketchHeight/3+10);//right semicircle
  popStyle();
  
  rect(sketchWidth/2, sketchHeight/2, rectWidth/2, sketchHeight);//middle line
  
  if(PLAYERCOUNT == 4){
      strokeWeight(rectWidth/4);
      stroke(255);
      for(int i = 0; i < sketchHeight; i += 30){
        line(sketchWidth/4, i, sketchWidth/4, i+10);//divider line left
        line(sketchWidth*3/4, i, sketchWidth*3/4, i+10);//divider line right
      }
  }
  
  fill(255, 255, 255);
  textSize(sketchWidth/40);
  textAlign(CENTER);
  
  text(leftScore+"", sketchWidth/2 - textWidth(str(leftScore)), rectWidth + sketchWidth/40);
  text(rightScore+"", sketchWidth/2 + textWidth(str(rightScore)), rectWidth + sketchWidth/40);
  
  fill(#FF0000, 140);
  noStroke();
  rect(sketchWidth/2, 0, sketchWidth/20, rectWidth);
  fill(#FFFFFF);
  textSize(rectWidth/2);
  text("blah", sketchWidth/2, rectWidth/4, sketchWidth/20, rectWidth/2);
  
  popMatrix();
  popStyle();
} 

void resetScores(){
  leftScore = 0;
  rightScore = 0;
}



//------------------------------------------------------------------------------------------------------------------
void oscEvent(OscMessage message){
//  if(message.addrPattern().equals("/tuio/2Dcur")){
////    println(message.typetag());
//    if (message.typetag().equals("sifffff") && (numPlayers < PLAYERCOUNT)){ //numPlayers starts at 0
//        println("numPlayers: " + numPlayers);
//        if (true) {
//          numPlayers++; //the fact that we received a touch event && logPlayers is true means we are accepting a player 
//          //add the player number to the game and put player's IP into the hashmap
//          playerMap.put(message.address().substring(1), numPlayers); //removes '/' from the beginning of the IP address string
//        }
//    }
//    else if(numPlayers == PLAYERCOUNT){
//      //println("Touch: " + message.address().substring(1));
//      //println(playerMap.get(message.address().substring(1)));
////      if (message.typetag().equals("ss")){
////        playerQ.add(playerMap.get(message.address().substring(1)));
////        
////        println("size: " + playerQ.size());
////      }
//      oscP5.send(message, nodes);
//    }
    if(MPE_ON && tileConfig.isLeader()) oscP5.send(message, nodes); 

    if(!MPE_ON) oscP5.send(message, nodes);
}

             
