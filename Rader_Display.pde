import processing.serial.*;
Serial myPort;
String data;
String angle;
String distance;
float iAngle = 0;
float iDistance = 0;
float smoothAngle = 0;
int lastTime = 0;
float radarRadius;
float radarX, radarY;
float lineLength;
void setup() {
  fullScreen();
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('.');
  // Scales the radar layout safely for your laptop screen
  radarRadius = height * 0.76; 
  radarX = width / 2;
  radarY = height - 100; 
  lineLength = radarRadius + 15;
  background(0);
}

void draw() {
  // Clears the screen dynamically with a trailing sweep effect
  noStroke();
  fill(0, 25);
  rect(0, 0, width, height - 90);

  drawRadar();
  drawLine();
  drawObject();
  drawText();

  smoothAngle += (iAngle - smoothAngle) * 0.12;

  if (millis() - lastTime > 500) {
    iDistance = 0;
  }
}

// ================= SERIAL DATA INPUT =================

void serialEvent(Serial p) {
  data = p.readStringUntil('.');

  if (data == null) return;

  data = trim(data);
  int comma = data.indexOf(',');

  if (comma < 0) return;

  angle = data.substring(0, comma);
  distance = data.substring(comma + 1);

  iAngle = float(angle);
  iDistance = float(distance);

  lastTime = millis();
}

// ================= RADAR GRID DRAWING =================

void drawRadar() {
  pushMatrix();
  translate(radarX, radarY);

  stroke(0, 255, 0, 140);
  strokeWeight(2);
  noFill();

  arc(0, 0, radarRadius * 2, radarRadius * 2, PI, TWO_PI);
  arc(0, 0, radarRadius * 1.6, radarRadius * 1.6, PI, TWO_PI);
  arc(0, 0, radarRadius * 1.2, radarRadius * 1.2, PI, TWO_PI);
  arc(0, 0, radarRadius * 0.8, radarRadius * 0.8, PI, TWO_PI);
  arc(0, 0, radarRadius * 0.4, radarRadius * 0.4, PI, TWO_PI);

  line(-lineLength, 0, lineLength, 0);

  int a = 0;
  while (a <= 180) {
    float x = -lineLength * cos(radians(a));
    float y = -lineLength * sin(radians(a));

    line(0, 0, x, y);

    float tx = -(lineLength + 22) * cos(radians(a));
    float ty = -(lineLength + 22) * sin(radians(a));

    fill(0, 255, 0);
    textSize(16);
    textAlign(CENTER, CENTER);

    text(a + "°", tx, ty);

    a += 30;
  }

  popMatrix();
}

// ================= RADAR SWEEP LINE =================

void drawLine() {
  pushMatrix();
  translate(radarX, radarY);

  stroke(0, 255, 0);
  strokeWeight(3);

  line(
    0, 0,
    -lineLength * cos(radians(smoothAngle)),
    -lineLength * sin(radians(smoothAngle))
  );

  popMatrix();
}

// ================= OBJECT DETECTION (RED SWEEP) =================

void drawObject() {
  // FIXED: The red sweep lines will trigger ONLY if the distance is 10cm or less
  if (iDistance > 0 && iDistance <= 10) { 
    pushMatrix();
    translate(radarX, radarY);

    // Maps 0-10cm accurately across the radar radius
    float pix = map(iDistance, 0, 10, 0, radarRadius);

    stroke(255, 0, 0);
    strokeWeight(4);

    // Draws a warning sweep line from the obstacle out to the edge
    line(
      -pix * cos(radians(iAngle)),
      -pix * sin(radians(iAngle)),
      -lineLength * cos(radians(iAngle)),
      -lineLength * sin(radians(iAngle))
    );

    popMatrix();
  }
}

// ================= TEXT INFORMATION BOTTOM PANEL =================

void drawText() {
  int panelW = width - 100;
  int panelH = 60;

  int panelX = width / 2 - panelW / 2;
  int panelY = height - 75; 

  fill(0);
  noStroke();
  rect(panelX, panelY, panelW, panelH, 8);

  textAlign(CENTER, CENTER);
  textSize(22);

  fill(0, 255, 0);
  text("Angle: " + int(iAngle) + "°", width / 2 - 300, panelY + panelH / 2);
  text("Distance: " + int(iDistance) + " cm", width / 2, panelY + panelH / 2);

  // FIXED: UI matches the 10cm threshold rule perfectly
  if (iDistance > 0 && iDistance <= 10) {
    fill(255, 0, 0);
    text("OBJECT DETECTED", width / 2 + 300, panelY + panelH / 2);
  } else {
    fill(0, 255, 0);
    text("SCANNING...", width / 2 + 300, panelY + panelH / 2);
  }
}
