import ddf.minim.analysis.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;
FFT fft;
MySystem system = new MySystem();

Sequencer sq;

float[] notes={16.35,17.32,18.35,19.45,20.60,21.83,23.12,24.50,25.96,27.30,29.14,30.87,32.70,34.65,36.71,38.89,41.20,43.65,46.25,49.00,51.91,55.00,58.27,61.74,65.41,69.30,73.42,77.78,82.41,87.31,92.50,98.00,103.83,110.00,116.54,123.47,130.81,138.59,146.83,155.56,164.81,174.61,185.00,196.00,207.65,220.00,233.08,246.94,261.63,277.18,293.66,311.13,329.63,349.23,369.99,392.00,415.30,440.00,466.16,493.88,523.25,554.37,587.33,622.25,659.25,698.46,739.99,783.99,850.61,880.00,932.33,987.77,1046.50,1108.73,1174.66,1244.51,1318.51,1396.91,1479.98,1567.98,1661.22,1760.00,1864.66,1975.53,2093.00,2217.46,2349.32,2489.02,2637.02,2793.83,2959.96,3135.96,3322.44,3520.00,3729.31,3951.07,4186.01,4434.92,4698.63,4978.03,5274.04,5587.65,5919.91,6271.93,6644.88,7040.00,7458.62,7902.13};

Waveform[] waves={Waves.SINE,Waves.SAW,Waves.SQUARE,Waves.TRIANGLE,Waves.QUARTERPULSE,Waves.PHASOR};
String[] _adsr={"A","D","S","R","Max","Before","After"};
float[] _adsrInit={0.03,0.1,1,0.1,1,0.1,0.7};
float[] _adsrMax={0.7,2.0,1.0,4.0,0.7,0.7,0.7};

Oscil[] oscil=new Oscil[3];
Oscil LFO;
Buttons[][] buttons=new Buttons[3][6];
Buttons[] buttonLFO=new Buttons[5];
Handles[] handleCoarse=new Handles[3];
Handles[] handleFine=new Handles[3];
Handles[] handleMix=new Handles[2];
Handles[] handleADSR=new Handles[7];
Handles[] handlePhase=new Handles[3];
Handles[] handleLFO=new Handles[2];
Summer sum;
ADSR adsr;
Wavetable wt;

boolean[][] on=new boolean[3][6];
boolean[] onLFO=new boolean[5];

int bands=2048;
float smoothingFactor=0.70;         // for your eyes^^

String songs[]={"A Moment Apart","Alone","Anahera","Back Again","Divinity","Fellow Feeling","Sad Machine","Goodbye to a World","Hold Fast","Day 1","Chlorine","Clarity","Cut My Lip (Brooklyn)","Tear In My Heart","Heavydirtysoul","All My Friends","Dream Dream Dream","Icarus","Finale","Shelter","Particle Arts","Ghost Voices","EON BREAK","Sea of Voices","The Scientist","Everglow","Firestone","She Heals Everything","Cinema","Another Angel","First Of The Year","Scary Monsters And Nice Sprites","Hysteria","Promises","Into the Night","Phantom Pt II","Language","Lonely Together","Loyal","Bubble Tea","Melt","Miss You","Mistaken","Moving On","Natural","Neon Gravestones","Never Be Like You","Ode To Sleep","Overtime","Raise Your Weapon","Reverie","Ride","Runaway","Midnight Hour","Say It(Illenium Remix)","Addicted To A Memory","Good Things Fall Apart","In Your Arms","Strobe","Summer","Tell Your World","The Ghost Of You","You & Me (Flume Remix)","Thief","How To Love","Used To Love","Waiting For Love","Without You","Hold The Line","Heart Upon My Sleeve","Heaven"};

void setup(){
  size(1600,1000,P3D);
  minim=new Minim(this);
  out=minim.getLineOut();

  sq=new Sequencer();
  for(int i=0;i<3;i++)for(int j=1;j<6;j++)on[i][j]=false;
  on[0][0]=on[1][0]=on[2][0]=true;
  
  fft=new FFT(out.bufferSize(),out.sampleRate());
  fft.window(FFT.HAMMING);
}

void mouseReleased(){
  loop();
  if(isIn(buttonLFO[0].posx,buttonLFO[0].posy,buttonLFO[0].w,buttonLFO[0].h,width/2,height/2)){
    if(onLFO[0]){
      onLFO[0]=false;
      for(int i=0;i<3;i++)LFO.unpatch(oscil[i]);
      LFO.unpatch(sum);
      LFO.unpatch(out);
    }
    else {
      onLFO[0]=true;
    }
  }
  else if(onLFO[0])for(int i=1;i<5;i++){
    if(isIn(buttonLFO[i].posx,buttonLFO[i].posy,buttonLFO[i].w,buttonLFO[i].h,width/2,height/2)){
      LFO.setWaveform(waves[i-1]);
      for(int k=1;k<5;k++)onLFO[k]=false;
      onLFO[i]=true;
    }
  }
  for(int i=0;i<3;i++)for(int j=0;j<6;j++){
    if(isIn(buttons[i][j].posx,buttons[i][j].posy,buttons[i][j].w,buttons[i][j].h,width/2,height/2)){
      oscil[i].setWaveform(waves[j]);
      for(int k=0;k<6;k++)on[i][k]=false;
      on[i][j]=true;
    }
  }
  handleLFO[0].releaseEvent();
  handleLFO[1].releaseEvent();
  for(int i=0;i<handleCoarse.length;i++)handleCoarse[i].releaseEvent();
  for(int i=0;i<handleFine.length;i++)handleFine[i].releaseEvent();
  for(int i=0;i<handleMix.length;i++)handleMix[i].releaseEvent();
  for(int i=0;i<handleADSR.length;i++)handleADSR[i].releaseEvent();
  for(int i=0;i<handlePhase.length;i++)handlePhase[i].releaseEvent();
}

void keyReleased(){
  system.keyboardManager.onKeyRelease(key,keyCode);
  loop();
  if(key=='a'||key=='w'||key=='s'||key=='e'||key=='d'||key=='f'||key=='t'||key=='g'||key=='y'||key=='h'||key=='u'||key=='j'||key=='k'||key=='o'||key=='l'||key=='p'||key==';'){
    for(int i=0;i<3;i++)oscil[i].unpatch(sum);
    if(onLFO[0]){
      LFO.unpatch(sum);
      LFO.unpatch(out);
    }
    adsr.unpatchAfterRelease(sum);
    adsr.unpatchAfterRelease(out);
    sum.unpatch(out);
  }
}

void keyPressed(){
  system.keyboardManager.onKeyPress(key,keyCode);
  loop();
  if(system.keyboardManager.isPressed('a'))sq.setNote(0);
  if(system.keyboardManager.isPressed('w'))sq.setNote(1);
  if(system.keyboardManager.isPressed('s'))sq.setNote(2);
  if(system.keyboardManager.isPressed('e'))sq.setNote(3);
  if(system.keyboardManager.isPressed('d'))sq.setNote(4);
  if(system.keyboardManager.isPressed('f'))sq.setNote(5);
  if(system.keyboardManager.isPressed('t'))sq.setNote(6);
  if(system.keyboardManager.isPressed('g'))sq.setNote(7);
  if(system.keyboardManager.isPressed('y'))sq.setNote(8);
  if(system.keyboardManager.isPressed('h'))sq.setNote(9);
  if(system.keyboardManager.isPressed('u'))sq.setNote(10);
  if(system.keyboardManager.isPressed('j'))sq.setNote(11);
  if(system.keyboardManager.isPressed('k'))sq.setNote(12);
  if(system.keyboardManager.isPressed('o'))sq.setNote(13);
  if(system.keyboardManager.isPressed('l'))sq.setNote(14);
  if(system.keyboardManager.isPressed('p'))sq.setNote(15);
  if(system.keyboardManager.isPressed(';'))sq.setNote(16);
}

void draw(){
  background(240,30,160);
  fill(139,163,221);
  rect(width/64,height/32,width/64+width/128,height/32);
  fill(0);
  textSize(20);
  text("P",width/64+width/128,height/16);
  pushMatrix();
  translate(width/2,height/2);
  fill(255);
  stroke(0);
  textSize(30);
  text("LFO",-700,-400);
  for(int i=0;i<5;i++)buttonLFO[i].show(onLFO[i]);
  for(int i=0;i<2;i++){
    handleLFO[i].update();
    handleLFO[i].display();
  }
  sq.ampLFO=handleLFO[0].stretch/handleLFO[0].maxlen;
  sq.speedLFO=50*handleLFO[1].stretch/handleLFO[1].maxlen;
  fill(255);
  textSize(30);
  text("Oscillators",-700,-220);
  for(int i=0;i<3;i++){
    for(int j=0;j<6;j++){
      buttons[i][j].show(on[i][j]);
    }
  }
  for(int i=0;i<3;i++){
    handleCoarse[i].update();
    sq.coarse[i]=48*(int)(handleCoarse[i].stretch/handleCoarse[i].maxlen);
    handleCoarse[i].display();
    handleFine[i].update();
    sq.fine[i]=handleFine[i].stretch/handleFine[i].maxlen;
    handleFine[i].display();
    if(i>0){
      handleMix[i-1].update();
      oscil[i].setAmplitude(handleMix[i-1].stretch/handleMix[i-1].maxlen);
      handleMix[i-1].display();
    }
    handlePhase[i].update();
    oscil[i].setPhase(handlePhase[i].stretch/handlePhase[i].maxlen);
    handlePhase[i].display();
  }
  textSize(30);
  text("Envelope",-700,300);
  for(int i=0;i<7;i++){
    handleADSR[i].update();
    handleADSR[i].display();
  }
  fft.forward(out.mix);
  translate(width/4+width/32,height/32);
  popMatrix();
}

class Sequencer{
  int oct;
  int octMax=6;
  int octMin=2;
  int[] coarse={24,12,0};
  float[] fine={0,0,0};
  float[] mix={0.5,0};
  float ampLFO;
  float speedLFO;
  float ampMax=0.7;
  float speedMax=80;
  
  Sequencer(){
    sum=new Summer();
    adsr=new ADSR(1,0.03,0.1,1,0.1,0.1,0.7);
    LFO=new Oscil(0,0,Waves.SINE);
    oscil[0]=new Oscil(440,0.5,Waves.SINE);
    oscil[1]=new Oscil(440,0.5,Waves.SINE);
    oscil[2]=new Oscil(440,0.5,Waves.SINE);
    handleLFO[0]=new Handles(-420,-350,400,20,0,handleLFO,"Amp",20);
    handleLFO[1]=new Handles(-420,-320,400,20,0,handleLFO,"Speed",20);
    buttonLFO[0]=new Buttons(-640,-430,50,50,"",20);
    buttonLFO[1]=new Buttons(-700,-350,50,50,"SIN",20);
    buttonLFO[2]=new Buttons(-630,-350,50,50,"SAW",20);
    buttonLFO[3]=new Buttons(-560,-350,50,50,"SQU",20);
    buttonLFO[4]=new Buttons(-490,-350,50,50,"TRI",20);
    onLFO[0]=false;
    onLFO[1]=false;
    onLFO[2]=false;
    onLFO[3]=false;
    onLFO[4]=false;
    for(int i=0;i<3;i++){
      buttons[i][0]=new Buttons(-700,-170+150*i,50,50,"SIN",20);
      buttons[i][1]=new Buttons(-630,-170+150*i,50,50,"SAW",20);
      buttons[i][2]=new Buttons(-560,-170+150*i,50,50,"SQU",20);
      buttons[i][3]=new Buttons(-490,-170+150*i,50,50,"TRI",20);
      buttons[i][4]=new Buttons(-420,-170+150*i,50,50,"QUA",20);
      buttons[i][5]=new Buttons(-350,-170+150*i,50,50,"PHA",20);
      handleCoarse[i]=new Handles(-280,-170+150*i,250,20,coarse[i]*250/48,handleCoarse,"Coarse",20);
      handleFine[i]=new Handles(-280,-140+150*i,250,20,(fine[i]+0.5)*250,handleFine,"Fine",20);
      if(i>0)handleMix[i-1]=new Handles(-280,-110+150*i,250,20,250*mix[i-1],handleMix,"Mix",20);
      handlePhase[i]=new Handles(-700,-80+150*i,300,20,0,handlePhase,"Phase",20);
    }
    for(int i=0;i<4;i++)handleADSR[i]=new Handles(-700,350+30*i,300,20,_adsrInit[i]*300*_adsrMax[i],handleADSR,_adsr[i],20);
    for(int i=0;i<3;i++)handleADSR[i+4]=new Handles(-250,365+30*i,200,20,_adsrInit[i+4]*200*_adsrMax[i+4],handleADSR,_adsr[i+4],20);
    oct=4;
  }
  void setNote(int noteVal){
    for(int i=0;i<3;i++){
      int index=12*(sq.oct-1)+sq.coarse[i]+noteVal;
      oscil[i].setFrequency(notes[index]+2*(sq.fine[i]-0.5)*(sq.fine[i]>0.5?(notes[index+1]-notes[index]):(notes[index]-notes[index-1])));
      oscil[i].patch(sum);
    }
    adsr.setParameters(handleADSR[4].stretch/handleADSR[4].maxlen*_adsrMax[4],handleADSR[0].stretch/handleADSR[0].maxlen*_adsrMax[0],handleADSR[1].stretch/handleADSR[1].maxlen*_adsrMax[1],handleADSR[2].stretch/handleADSR[2].maxlen*_adsrMax[2],handleADSR[3].stretch/handleADSR[3].maxlen*_adsrMax[3],handleADSR[5].stretch/handleADSR[5].maxlen*_adsrMax[5],handleADSR[6].stretch/handleADSR[6].maxlen*_adsrMax[6]);
    if(onLFO[0]){
      LFO.setFrequency(speedLFO);
      LFO.setAmplitude(ampLFO);
      for(int i=0;i<3;i++)LFO.patch(oscil[i].amplitude);
      LFO.patch(sum);
    }
    adsr.patch(sum);
    adsr.patch(out);
    sum.patch(out);
  }
  void display(){
    fill(255);
    stroke(0);
    textSize(30);
    text("LFO",-700,-400);
    for(int i=0;i<5;i++)buttonLFO[i].show(onLFO[i]);
    for(int i=0;i<2;i++){
      handleLFO[i].update();
      handleLFO[i].display();
    }
    ampLFO=handleLFO[0].stretch/handleLFO[0].maxlen*ampMax;
    speedLFO=handleLFO[1].stretch/handleLFO[1].maxlen*speedMax;
    fill(255);
    textSize(30);
    text("Oscillators",-700,-220);
    for(int i=0;i<3;i++){
      for(int j=0;j<6;j++){
        buttons[i][j].show(on[i][j]);
      }
    }
    for(int i=0;i<3;i++){
      handleCoarse[i].update();
      coarse[i]=48*(int)(handleCoarse[i].stretch/handleCoarse[i].maxlen);
      handleCoarse[i].display();
      handleFine[i].update();
      fine[i]=handleFine[i].stretch/handleFine[i].maxlen;
      handleFine[i].display();
      if(i>0){
        handleMix[i-1].update();
        oscil[i].setAmplitude(handleMix[i-1].stretch/handleMix[i-1].maxlen);
        handleMix[i-1].display();
      }
      handlePhase[i].update();
      oscil[i].setPhase(handlePhase[i].stretch/handlePhase[i].maxlen);
      handlePhase[i].display();
    }
    textSize(30);
    text("Envelope",-700,300);
    for(int i=0;i<7;i++){
      handleADSR[i].update();
      handleADSR[i].display();
    }
  }
}
class Buttons{
  float posx,posy,w,h,size;
  String e;
  Buttons(float x,float y,float wid,float hei,String exp,float s){
    posx=x;
    posy=y;
    w=wid;
    h=hei;
    e=exp;
    size=s;
  }
  void show(boolean o){
    fill(o?0:255);
    rect(posx,posy,w,h);
    fill(o?255:0);
    textSize(size);
    text(e,posx+3,posy+h/2);
  }
}

class Handles{
  float x,y;
  float boxx,boxy;
  float stretch;
  float size;
  float maxlen;
  boolean over;
  boolean press;
  boolean locked=false;
  boolean otherslocked=false;
  Handles[] others;
  String e;
  float tS;
  
  Handles(float ix,float iy,float il,float is,float in,Handles[] o,String exp,float s){
    x=ix;
    y=iy;
    maxlen=il;
    size=is;
    stretch=in;
    boxx=x+in-size/2;
    boxy=y-size/2;
    others=o;
    e=exp;
    tS=s;
  }
  
  void update(){
    boxx=x+stretch;
    boxy=y-size/2;
    for(int i=0;i<others.length;i++){
      if(others[i].locked==true){
        otherslocked=true;
        break;
      }
      else otherslocked=false;
    }
    
    if(otherslocked==false){
      overEvent();
      pressEvent();
    }
    
    if(press){
      stretch=lock(mouseX-size/2-x-width/2,0,maxlen);
    }
  }
  
  void overEvent(){
    over=isIn(boxx,boxy,size,size,width/2,height/2);
  }
  
  void pressEvent(){
    if(over&&mousePressed||locked){
      press=true;
      locked=true;
    }
    else press=false;
  }
  
  void releaseEvent(){
    locked=false;
  }
  
  void display(){
    line(x, y, x+stretch, y);
    if(stretch+size<maxlen)line(x+stretch+size,y,x+maxlen,y);
    fill(255);
    stroke(0);
    rect(boxx, boxy, size, size);
    textSize(tS);
    text(e,x+size+10,y-3);
    if (over||press){
      line(boxx,boxy,boxx+size,boxy+size);
      line(boxx,boxy+size,boxx+size,boxy);
    }
  }
}

boolean isIn(float x,float y,float w,float h,float newX,float newY){
  return mouseX>x+newX&&mouseX<x+w+newX&&mouseY>y+newY&&mouseY<y+h+newY;
}

float lock(float val,float minv,float maxv){
  return min(max(val,minv),maxv); 
}
