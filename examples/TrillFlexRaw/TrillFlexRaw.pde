import processing.serial.*;

// Serial communication
Serial gPort; // Serial port
int gPortNumber = 2; // Port number
int gBaudRate = 115200; // Baud Rate

// Chart dimensions
float chartTop = 20;
float chartBottom;
float chartLeft = 100;
float chartRight;

// Width of bar representing sensor values
float barWidth;

// Number of sensors
int gNumSensors = 30;
// Bit resolution
int gNumBits = 12;
// Expected range of received data
int gDataRange[] = {0, (1<<gNumBits)-1};

// Sensor readings
int gSensorReadings[] = new int[gNumSensors];

void setup() {
  println("Available ports: ");
  println(Serial.list());

  String portName = Serial.list()[gPortNumber];

  println("Opening port " + portName);
  gPort = new Serial(this, portName, gBaudRate);
  gPort.bufferUntil('\n');

  // Set dimensions of display window
  size(1000, 500);
  // Compute char dimensions based on window size
  chartBottom = height - chartTop - 80;
  chartRight = width - chartLeft;
}

void draw() {
  background(255);
  fill(255);
  stroke(0);
  strokeWeight(0.4);
  // Draw chart outline
  rect(chartLeft - barWidth, chartTop, chartRight - chartLeft + 2 * barWidth, chartBottom - chartTop);
  textSize(12);

  // Compute bar width
  barWidth = (int)(chartRight-chartLeft) / (int)(gNumSensors*1.5f);

  // Draw sensor bars
  for (int i = 0; i < gNumSensors; i++) {
    float x = map(i, 0, gNumSensors - 1, chartLeft, chartRight);
    int data = gSensorReadings[i];
    float y = map(data, gDataRange[0], gDataRange[1], chartBottom, chartTop);

    strokeWeight(barWidth);
    strokeCap(SQUARE);
    stroke(0);
    line(x, chartBottom, x, y);

    fill(0);
    //textAlign(CENTER);
    text(str(i), x-0.5*textWidth(str(i)), chartBottom+20);

    pushMatrix();
    textAlign(RIGHT, CENTER);
    translate(x, chartBottom + 40);
    rotate(-HALF_PI);
    text(data, 0, 0);
    popMatrix();
  }
}

// This function is called whenever new serial data is available
void serialEvent(Serial p) {
  // Read data from the serial buffer as string
  String str = p.readString();
  try {
    // Parse string to extract  information
    String inString = trim(str); // remove whitespaces from beginning/end
    int[] values = int(split(inString, " ")); // Split string using space as a delimiter and cast to int
    int i;
    for(i = 0; i < values.length; i++) {
      if(i < gNumSensors) {
        gSensorReadings[i] = values[i];
      }
    }
  }
  catch(RuntimeException e) {
    e.printStackTrace();
  }
}