import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
FFT fft;
int BPM = 130;
int FPS = 52;
float eighthInterval = (FPS*60)/(2*BPM);
float ease = 3;          // Speed of color change
int lastFrame = 0;
int numBands = 32; 
int defaultHue = 30;
int defaultSat = 82;
int defaultBri = 35;
ColorBand[] colorBands;

void setup(){
  size(1920, 1080);
  // size(1280, 720);
  frame.setLocation(220,0);
  frameRate(FPS);
  // Graphics code
  colorMode(HSB, 360, 100, 100); 
  colorBands = new ColorBand[numBands+1];
  for (int i=0; i<colorBands.length; i++){
    colorBands[i] = new ColorBand(i);
  }
  
  // Sound code 
  minim = new Minim(this);
 
  song = minim.loadFile("pancakeSatellites.mp3", 2048); // the default buffer size is 1024, 2048 better
  lastFrame = int((song.length()*FPS)/1000)+8; // Calculate last frame
  
  fft = new FFT(song.bufferSize(), song.sampleRate());
  numBands = 12;
  song.play();
}

void draw(){
  if(frameCount%eighthInterval == int(eighthInterval/2)){
    song.cue((1000*frameCount)/(FPS)); // Sync song to framerate
  }
  if(frameCount%eighthInterval == 0){
    updateEighth();
  }
  background(0);
  for (int i=0; i<colorBands.length; i++){
    colorBands[i].drawMe();
  }
  saveFrame("frames/#######.tga");
  
  if (frameCount > lastFrame){
    stop();
  } 
}

void updateEighth(){
  fft.forward(song.mix); // forward fft on mix, left or right
  float jInc = int((fft.specSize()-300) / numBands);
  float j = 0;
  for(int i = 0; i < numBands+1; i++){
    // Max band is 49 but rarely above 30
    int saturation = int(fft.getBand(int(j)+160)*8);
    float hue = defaultHue;
    if (saturation > 100){
       hue = ((saturation-100)/20)+hue;
    }
    colorBands[i].nextHue = hue;
    colorBands[i].nextSat = saturation;
    j += jInc;
  }
}

void stop(){
  song.close();
  minim.stop();
  super.stop();
  exit(); 
}

public class ColorBand{
  float hue;
  float sat;
  float nextHue;
  float nextSat;
  int index;
  public ColorBand (int index){
    hue = defaultHue;
    sat = defaultSat;
    nextHue = hue;
    this.index = index;
  }
  public void drawMe(){
    // Fade toward next hue+sat
    if (hue != nextHue){
      hue = ((nextHue-hue)/ease)+hue;
    }
    if (sat != nextSat){
      sat = ((nextSat-sat)/ease)+sat;
    }
    stroke(hue, sat, 100-(sat/1.5));  
    int strokeWeight = width/(numBands*2);
    strokeWeight(strokeWeight);
    int center = (width/2); // center
    int offset = (index*strokeWeight); // offset
    line(center+offset, 0, center+offset, height);
    line(center-offset, 0, center-offset, height);
  }
}
