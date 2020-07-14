import trill.library.*;
import processing.serial.*;

// Communication
Serial gPort;
int gPortNumber = 2; 
int gBaudRate = 115200;

Trill tr;
float gWidth=500;
float gHeight=500;
int gMargin = 50;
float [] gPosition = {(gWidth+2*gMargin)/2,(gHeight+2*gMargin)/2};
float gLength = 500;

void settings() {
  size(int(gWidth + 2*gMargin), int(gHeight + 2*gMargin));
}

void setup(){
  frameRate(5);
  println("Available ports: ");
  println(Serial.list());
  
  String portName = Serial.list()[gPortNumber];
  
  println("Opening port " + portName);
  gPort = new Serial(this, portName, gBaudRate);
  gPort.bufferUntil('\n');
 tr = new Trill(this,"square", gLength, gPosition);
 background(255);
}

void draw(){
background(0); 
tr.draw();
}


void serialEvent(Serial p) {
  String str = p.readString();
  //println(str,str);
  tr.serialParse(str);
}
