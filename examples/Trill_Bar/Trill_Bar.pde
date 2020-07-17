import trill.library.*;
import processing.serial.*;


// Communication
Serial gPort;
int gPortNumber = 2; 
int gBaudRate = 115200;

Trill tr;

//Sensor and canvas dimensions
// Preserve aspect ratio with real sensor
int gSensorHeight = 150;
int gSensorWidth = int(gSensorHeight * 4.7);
int gMargin = 50;
float [] gPosition = {(gSensorWidth+2*gMargin)/2,(gSensorHeight+2*gMargin)/2};



void settings() {
  size(int(gSensorWidth + 2*gMargin), int(gSensorHeight + 2*gMargin));
}

void setup() {
  frameRate(10);
  println("Available ports: ");
  println(Serial.list());
  
  String portName = Serial.list()[gPortNumber];
  
  println("Opening port " + portName);
  gPort = new Serial(this, portName, gBaudRate);
  gPort.bufferUntil('\n');
  
  tr = new Trill(this,"bar", gSensorWidth, gPosition);
  background(255);
}

void draw() {
  background(0);
  tr.draw();
}

void serialEvent(Serial p) {
  String str = p.readString();
  tr.serialParse(str);
}
