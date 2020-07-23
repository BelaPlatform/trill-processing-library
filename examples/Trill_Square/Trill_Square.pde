import trill.library.*;
import processing.serial.*;

// Communication
Serial gPort;
int gPortNumber = 2; 
int gBaudRate = 115200;

Trill tr;

//Sensor and canvas dimensions
int gSensorWidth=500;
int gSensorHeight=500;
int gMargin = 50;
float [] gPosition = {(gSensorWidth+2*gMargin)/2,(gSensorHeight+2*gMargin)/2};


void settings() {
  size(gSensorWidth + 2*gMargin, gSensorHeight + 2*gMargin);
}

void setup(){
  frameRate(10);
  println("Available ports: ");
  println(Serial.list());
  
  String portName = Serial.list()[gPortNumber];
  
  println("Opening port " + portName);
  gPort = new Serial(this, portName, gBaudRate);
  gPort.bufferUntil('\n');
 tr = new Trill(this,"square", gSensorWidth, gPosition);
 background(255);
}

void draw(){
background(0); 
tr.draw();
tr.drawTouches();
}


void serialEvent(Serial p) {
  String str = p.readString();
  tr.serialParse(str);
}
