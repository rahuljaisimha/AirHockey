import TUIO.*;
import java.util.Iterator;

public class TuioHandler implements TuioListener {
  protected PApplet p;
  protected int maxCursors;
  protected TuioClient tuioClient;
  protected ArrayList<TuioCursor> touchObjects = new ArrayList<TuioCursor>();
  protected SynchronizedList<TouchMessage> messageQ = new SynchronizedList<TouchMessage>(); //touches waiting to be heard
  
  public TuioHandler(PApplet p, int maxCursors) {
    this(p, maxCursors, null); 
  }
  
  public TuioHandler(PApplet p, int maxCursors, TuioClient tuioClient) {
    this.p = p;
    this.maxCursors = maxCursors;
    
    // Create or set tuioClient
    if (tuioClient == null) {
     for(int i = 3333; i >= 3330; i--){ 
      this.tuioClient = new TuioClient(i) {
          public synchronized void acceptMessage(java.util.Date date, com.illposed.osc.OSCMessage message) {
              String senderIP = message.getArguments()[0].equals("source") ? splitTokens((String)message.getArguments()[1], "@")[1] : null;
//              println(message.getArguments());
//              println(messageQ.size());
              if(senderIP != null) {
                  //accept touches to calibrate ip addresses
                  if(numPlayers < PLAYERCOUNT){
                      if(!playerMap.containsKey(senderIP)){
                          numPlayers++;
                          playerMap.put(senderIP, numPlayers);
                          println("Player "+numPlayers);
                      }
                  }
              }
              // when calibration has finished
              if(numPlayers == PLAYERCOUNT){
                  if(senderIP != null){//if "source"
                      messageQ.add(new TouchMessage(message));
                  }
                  else{// not a "source" message
                      for(int i = 0; i < messageQ.size(); i++){
                          TouchMessage msg = messageQ.get(i);
                          if(!msg.addMessage(message)) continue;
                          if(msg.isSendable()){
                            //print debugging info to console
//                              println(msg.source.getArguments());
//                              println(msg.alive.getArguments());
//                              if(!msg.isRemove()) println(msg.set.getArguments());
//                              println(msg.fseq.getArguments());
//                              println("PRINTED");
                            
                              super.acceptMessage(date, msg.source);
                              super.acceptMessage(date, msg.alive);
                              if(!msg.isRemove()) super.acceptMessage(date, msg.set);
                              super.acceptMessage(date, msg.fseq);
                              messageQ.remove(0);
                          }
                          break;
                      }
                  }
              }
          }
      };
      this.tuioClient.connect();
      if(this.tuioClient.isConnected())
        break;
      }
    } else {
      this.tuioClient = tuioClient;
    }
    // Add this as listener
    this.tuioClient.addTuioListener(this);

    // To disconnect tuioClient after applet stops
    p.registerDispose(this); 
  }
  
  // called when user presses "Escape" or
  // clicks "X" on sketch window
  public void dispose() {
    println("Diconnecting TUIO Client");
    tuioClient.disconnect();
  }
  
  public synchronized void addTuioCursor(TuioCursor tcur) {
    int id = playerMap.get(messageQ.get(0).getTouchIP());
    if(!messageQ.get(0).isAdd()){
//      return;
    }
    for(int i = 0; i < players.size(); i++){
      Player p = players.get(i);
      if (p.holder == id){
        return;
      }
    }
    println(id + "touch!" + "\n");
    
    if(touchObjects.size() < maxCursors){
      touchObjects.add(tcur);
      float touchX = tcur.getScreenX(p.width);
      float touchY = tcur.getScreenY(p.height);
      
      touchX = map(touchX, 0, p.width, (id-1)*sketchWidth/PLAYERCOUNT, id*sketchWidth/PLAYERCOUNT);
      touchY = map(touchY, 0, p.height, 0, sketchHeight);
      
      if(touchX < sketchWidth/2 + sketchWidth/40 && touchX > sketchWidth/2 - sketchWidth/40 && touchY < Boundary/2)
          resetScores();
      else{
        Player newPlayer = new Player(touchX, touchY, false, false);
        newPlayer.hasSpring = true;
        newPlayer.holder = id;
        players.add(newPlayer);
      }
    }
    
  }
  
  public synchronized void updateTuioCursor(TuioCursor tcur) {
    int id = playerMap.get(messageQ.get(0).getTouchIP());
    if(!messageQ.get(0).isUpdate()){
//      return;
    }
    println(id + "update!" + "\n");
    
    float touchX = tcur.getScreenX(p.width);
    float touchY = tcur.getScreenY(p.height);
    
    touchX = map(touchX, 0, p.width, (id-1)*sketchWidth/PLAYERCOUNT, id*sketchWidth/PLAYERCOUNT);
    touchY = map(touchY, 0, p.height, 0, sketchHeight);
    
    for (int i = 0; i < players.size(); i++) {
        Player bub = players.get(i);
        if(bub.hasSpring && bub.holder == id){
          bub.moveByTouch(touchX, touchY);
          break;
        }
    }
  }
  
  public synchronized void removeTuioCursor(TuioCursor tcur) {
    int id = playerMap.get(messageQ.get(0).getTouchIP());
    if(!messageQ.get(0).isRemove()){
//      return;
    }
    println(id + "remove!" + messageQ.size()+"\n");
    
    for(int i = 0; i < players.size(); i++){
      Player bub = players.get(i);
      if(bub.hasSpring && bub.holder == id){
          players.remove(bub);
          i--;
      }
    }
    for (int k = 0; k < touchObjects.size(); k++) {
      TuioCursor touch = touchObjects.get(k);
      
      if(tcur.getCursorID() == touch.getCursorID()){
        touchObjects.remove(touch);
        k--;
      }
    }
  }
  
   
  public synchronized void debugCursors(){
    Iterator<TuioCursor> i = touchObjects.iterator();
    while (i.hasNext()) {
      TuioCursor touch = i.next();
      p.stroke(50, 100);
      p.fill(230, 150);
      p.ellipse(touch.getScreenX(p.width), touch.getScreenY(p.height), 25, 25);
      p.fill(10);
      p.textSize(12);
      if(touch.getCursorID() < 10) p.text(touch.getCursorID(), touch.getScreenX(p.width) - 3, touch.getScreenY(p.height) + 4);
      else p.text(touch.getCursorID(), touch.getScreenX(p.width) - 9, touch.getScreenY(p.height) + 4);
    }
  }    
    
  public ArrayList<TuioCursor> getTouchObjects() {
    return touchObjects; 
  }
  

  public void refresh(TuioTime arg0) {}
  public void addTuioObject(TuioObject tobj) {}
  public void updateTuioObject(TuioObject tobj) {}  
  public void removeTuioObject(TuioObject tobj) {}
}
