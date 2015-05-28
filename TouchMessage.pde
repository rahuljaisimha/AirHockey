/* Coded by Rahul Jaisimha

USING ILLPOSED OSC MESSAGES

Each touch message consists of 3 or 4 OSC messages

add:
  source <String>                             ss
  alive <i*>                                  si
  set <i*> <float x2> 0.0 0.0 0.0             sifffff
  fseq <j*>                                   si


update:
  source <String>                             ss
  alive <i*>                                  si
  set <i*> <float x5>                         sifffff
  fseq <j*>                                   si


remove:
  source <String>                             ss
  alive                                        s
  fseq <j*>                                   si
  
  
Periodic TUIO updates look like 'remove's. Trying to figure out the difference.


* i is the number of touches that have been made so far from that IP
  j is the number of touch events that have been made so far from that IP

*/

public class TouchMessage {
  com.illposed.osc.OSCMessage source;
  com.illposed.osc.OSCMessage alive;
  com.illposed.osc.OSCMessage set;
  com.illposed.osc.OSCMessage fseq;
  private boolean sendable;
  // if alive.args[1] does not exist, the TUIOEvent is a 'remove' event. This does not have a 'set'
  private boolean isRemove;
  private boolean isAdd;
  private boolean isUpdate;
  
  private String touchIP;
  
  public TouchMessage(){
    sendable = false;
    isRemove = false;
    isAdd = false;
    isUpdate = false;
  }
  public TouchMessage(com.illposed.osc.OSCMessage message){
    sendable = false;
    isRemove = false;
    isAdd = false;
    isUpdate = false;
    addMessage(message);
  }
    
  
  public synchronized boolean addMessage(com.illposed.osc.OSCMessage message){
    if(source == null){
      if(!message.getArguments()[0].equals("source"))
        return false;
      source = new com.illposed.osc.OSCMessage(message.getAddress(), message.getArguments());
      
      // get which player based on the IP Address
      touchIP = splitTokens((String)message.getArguments()[1], "@")[1];
    }
    else if(alive == null){
      if(!message.getArguments()[0].equals("alive"))
        return false;
      alive = new com.illposed.osc.OSCMessage(message.getAddress(), message.getArguments());
      // if alive has a second argument, it is not a 'remove' event
      isRemove = message.getArguments().length > 1 ? false : true;
    }
    else if(set == null && !isRemove){
      if(!message.getArguments()[0].equals("set"))
        return false;
      set = new com.illposed.osc.OSCMessage(message.getAddress(), message.getArguments());
      // check last 3 floats to see if add vs update
      if(Double.parseDouble(message.getArguments()[4].toString()) == 0 &&
         Double.parseDouble(message.getArguments()[5].toString()) == 0 &&
         Double.parseDouble(message.getArguments()[6].toString()) == 0)
           isAdd = true;
      else
           isUpdate = true;
    }
    else if(fseq == null){
      if(!message.getArguments()[0].equals("fseq"))
        return false;
      fseq = new com.illposed.osc.OSCMessage(message.getAddress(), message.getArguments());
      sendable = true;
    }
    return true;
  }
  
  public boolean isSendable(){
    return sendable;
  }
  
  public boolean isRemove(){
    return isRemove;
  }
  
  public boolean isAdd(){
    return isAdd;
  }
  
  public boolean isUpdate(){
    return isUpdate;
  }
  
  public String getTouchIP(){
    return touchIP;
  }
}
