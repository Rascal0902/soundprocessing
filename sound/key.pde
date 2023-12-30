



void mouseDragged(){
  system.mouseManager.onMouseMoved(mouseX,mouseY); 
}
class KeyboardManager{
  private static final int keyNum = 60;
  
   private boolean[] keyState = new boolean[keyNum]; 
   //a~z: 0~25, 0~9: 26,35, ' '=36, 'ENTER'= 37, arrow lurd: 38~41, shift,ctrl,alt: 42~44
   KeyboardManager(){
       for(int i=0;i<keyNum;i++){
         keyState[i] = false;
       }
   }
   public void onKeyPress(char k,int kc){
       //println((int)k);
       //println(kc);
       //println(calKey(k,kc));
       if(calKey(k,kc)==-1)return;
       keyState[calKey(k,kc)] = true;
      
   }
   public void onKeyRelease(char k,int kc){
     if(calKey(k,kc)==-1)return;
       keyState[calKey(k,kc)] = false;
   }
   
   public boolean isPressed(int k){
      return keyState[calKey((char)CODED,k)]; 
   }
   
   public boolean isPressed(char k){
      return keyState[calKey(k,0)]; 
   }
   
   public boolean isPressed(){
     boolean t = false;
     for(int i=0;i<keyNum;i++){
       t = t|keyState[i];
     }
      return t; 
   }
   
   private int calKey(char k,int kc){
     if(k-'a'>=0&&k-'z'<=0){
          return k-'a'; 
       }else if(k-'A'>=0&&k-'Z'<=0){
          return k-'A'; 
       }else if(k-'0'>=0&&k-'9'<=0){
          return k-'0'+'z'-'a'+1;        
       }
       else if(k==' '){
        return  36;
       }
       else if(k=='\n'){
        return  37;
       }
       else if(k==CODED){
         if(kc-LEFT>=0&&38+kc-LEFT<=41){
         return 38+kc-LEFT;
         }
         else if(kc-SHIFT>=0&&kc-SHIFT+42<=44){
           return 42+kc-SHIFT;
         }
           
       }
       else if(k==27){//esc
        return  45;
       }
       else{
          switch(k){
            case '-':
            case '_':
            return 46;
            case '=':
            case '+':
            return 47;
            case '{':
            case '[':
            return 48;
            case ']':
            case '}':
            return 49;
            case ';':
            case ':':
            return 50;
           case '\'':
            case '"':
            return 51;
            case ',':
            case '<':
            return 52;
            case '.':
            case '>':
            return 53;
            case '?':
            case '/':
            return 54;
          }
       }
     return -1;
   }
}
class MouseManager{
    private int x;
    private int y;
    private boolean[] button = new boolean[3]; //left = 0, right = 1, center = 2
    MouseManager(){
        button[0] = false;
        button[1] = false;
     x = 0;
     y = 0;
    }
   MouseManager(int tx,int ty){
     x = tx;
     y = ty;
     button[0] = false;
     button[1] = false;
   }
   public void onMousePressed(int tx,int ty,int b1){
    x = tx;
    y = ty;
    if(b1==37){
      button[0] = true;
    }else if(b1==39){
      button[1] = true;
    }
    else if(b1==3){
      button[2] = true;
    }
   }
   
   public void onMouseReleased(int tx,int ty,int b1){
    x = tx;
    y = ty;
    if(b1==37){
      button[0] = false;
    }else if(b1==39){
      button[1] = false;
    }
    else if(b1==3){
      button[2] = false;
    }
   } 
   
   public void onMouseMoved(int tx,int ty){
      x = tx;
      y = ty;
   }
   
   public PVector getMouseLocation(){
      return new PVector(x,y); 
   }
   
   public boolean getButtonPressed(int b){
      return button[b]; 
   }
   
}
class MySystem{
    KeyboardManager keyboardManager = new KeyboardManager();
    MouseManager mouseManager = new MouseManager();
   
     MySystem(){
       
   }
       
}
