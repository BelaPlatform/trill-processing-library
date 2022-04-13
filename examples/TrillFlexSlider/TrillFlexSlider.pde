		import trill.library.*;
import processing.serial.*;

// Serial communication
Serial gPort; // Serial port
int gPortNumber = 2; // Port number
int gBaudRate = 115200; // Baud Rate

// Forward declaration of Trill sensor class object
// (used for parsing serial data and visualization)
Trill trill;

// Sensor and canvas dimensions
// Preserve aspect ratio with real sensor
int gSensorHeight = 150;
int gSensorWidth = int(gSensorHeight * 4.7);
int gMargin = 50;
// Sensor position
float [] gPosition = {(gSensorWidth+2*gMargin)/2,(gSensorHeight+2*gMargin)/2};



void settings() {
	size(int(gSensorWidth + 2*gMargin), int(gSensorHeight + 2*gMargin));
}

void setup() {
	frameRate(20);
	println("Available ports: ");
	println(Serial.list());

	String portName = Serial.list()[gPortNumber];

	println("Opening port " + portName);
	gPort = new Serial(this, portName, gBaudRate);
	gPort.bufferUntil('\n');

	// Create Trill sensor instance of type "bar"
	trill = new Trill(this,"bar", gSensorWidth, gPosition);
	background(255);
}

void draw() {
	background(255);
	// Draw sensor
	trill.draw();
	// Draw touches on sensor
	trill.drawTouches();
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
