import processing.serial.*;
import controlP5.*;
import java.util.*;

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

ControlP5 cp5;

String command = "";
int textBoxX = (int)(chartLeft+120);
int textBoxY;
int textBoxW;
int textBoxH = 30;
Textfield commandTextField;
ScrollableList commandList;
String commandArray[] = {"prescaler:", "threshold:", "bits:", "mode:", "baseline"};
void setup() {
  println("Available ports: ");
  println(Serial.list());

  String portName = Serial.list()[gPortNumber];

  println("Opening port " + portName);
  gPort = new Serial(this, portName, gBaudRate);
  gPort.bufferUntil('\n');

  // Set dimensions of display window
  size(1100, 700);
  // Compute char dimensions based on window size
  chartBottom = height - chartTop - 200;
  chartRight = width - chartLeft;

  cp5 = new ControlP5(this);
  textBoxW = width/3;
  textBoxY = (int)(chartBottom+80);
  commandTextField = cp5.addTextfield("command")
      .setPosition(textBoxX, textBoxY)
      .setSize(textBoxW, textBoxH)
      .setColorBackground(color(0))
      .setColor(color(255))
      .setFont(createFont("arial", 12))
      .setFocus(true)
      .setAutoClear(false);

  commandList = cp5.addScrollableList("commands")
     .setPosition(textBoxX+textBoxW+20, textBoxY)
     .setSize(150, 60)
     .setBarHeight(20)
     .setItemHeight(20)
     .setColorBackground(color(0))
     .setOpen(false)
     .addItems(commandArray)
     .setType(ScrollableList.LIST);
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

    push();
    textAlign(RIGHT, CENTER);
    translate(x, chartBottom + 40);
    rotate(-HALF_PI);
    text(data, 0, 0);
    pop();

    float textY = textBoxY+0.75*textBoxH;
    float listY = textBoxY+0.5*textBoxH;
    text("COMMAND INPUT:", textBoxX-120, textY);
    text("PREVIOUS INPUT:", textBoxX-120, textY+textBoxH);
    text(command, textBoxX, textY+textBoxH);
    text("OPTIONS:", chartRight-200, listY);
    text("prescalar: 1-8", chartRight-200, listY+15);
    text("threshold: 0-100", chartRight-200, listY+30);
    text("bits: 9-16", chartRight-200, listY+45);
    text("mode: centroid, raw, baseline, differential", chartRight-200, listY+60);
    text("baseline resets the baseline capacitance", chartRight-200, listY+75);
  }
}

// This function is called whenever new serial data is available
void serialEvent(Serial p) {
  // Read data from the serial buffer as string
  String str = p.readString();
  println(str);
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

// Function to be called when command text field is updated
public void command(String text) {
  command = text;
  gPort.write(text);
  commandTextField.clear();
}
// Function to be called when command is selected from scrollable list
void commands(int n) {
  String cmnd = cp5.get(ScrollableList.class, "commands").getItem(n).get("text").toString();
  commandTextField.setText(cmnd+" ");
}
