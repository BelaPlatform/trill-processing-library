import trill.library.*;
import processing.serial.*;

// Serial coommunication
Serial gPort; // Serial port
int gPortNumber = 2; // Port number
int gBaudRate = 115200; // Baud Rate

// Forward declaration of Trill sensor class object
// (used for parsing serial data and visualization)
Trill trill;

//Sensor and canvas dimensions
int gSensorWidth=500;
int gSensorHeight=500;
int gMargin = 50;
float [] gPosition = {(gSensorWidth+2*gMargin)/2,(gSensorHeight+2*gMargin)/2};


void settings() {
	size(gSensorWidth + 2*gMargin, gSensorHeight + 2*gMargin);
}

void setup(){
	frameRate(20);
	println("Available ports: ");
	println(Serial.list());

	String portName = Serial.list()[gPortNumber];

	println("Opening port " + portName);
	gPort = new Serial(this, portName, gBaudRate);
	gPort.bufferUntil('\n');

	// Create Trill sensor instance of type "square"
	trill = new Trill(this,"hex", gSensorWidth, gPosition);
	background(255);
}

void draw(){
	background(255);
	// Draw sensor
	trill.draw();
	// Draw a single touch averaging the vertical and horizontal
	// components of the 2D sensor
	trill.drawCompoundTouch();
	// You can alternatively use trill.drawTouches() to draw all
	// the independent touch components
	//trill.drawTouches();
}

// This function is called whenever new serial data is available
void serialEvent(Serial p) {
	// Read data from the serial buffer as string
	String str = p.readString();

	try {
		// Parse string to extract Trill touch information
		trill.serialParse(str);
	}
	catch(RuntimeException e) {
		e.printStackTrace();
	}

}
