import processing.sound.*;
Amplitude amplitude;
FFT fft;
AudioIn in ;

int audioDeviceId = 7;
color strokeCol = color(30, 255, 255);
int cols, rows;
int w = 400, h = 400;
int space = 25;
float[][] z;
float sound;
float speed = 0.01;
float density = 0.001;
float amp = 100;
float move = 0;
float rotationZspeed = 1;
boolean enableRotationZ = false;
int hue, saturation, brightness;

int bands = 16;
float[] spectrum = new float[bands];
float sum = 0;
float smooth = .6;

void setup() {
 if (audioDeviceId == -1) {
  println("Elige dispositivo desde esta lista y actualiza configuración");
  Sound.list();
  exit();
  return;
 }
 fullScreen(P3D, 2);

 colorMode(HSB, 360, 100, 100);
 //noFill();
 //stroke(250,200,250,40);
 //fill(0,10, 30, 90);
 //fill(100,89,90,70);
 cols = w / space;
 rows = h / space;

 z = new float[cols][rows];

 Sound s = new Sound(this);
 try {
  amplitude = new Amplitude(this);
  s.inputDevice(audioDeviceId); in = new AudioIn(this, 0); in.start();
 } catch (Exception e) {
  println(e);
 }

 fft = new FFT(this, bands);
 fft.input( in );

 amplitude.input( in );
}

void draw() {
 if (audioDeviceId == -1) {
  exit();
 }

 background(0);
 soundCalc();
 //noFill();
 //fill(0, 10, 30, 90);

 depthCalc();

 shapeMode(CENTER);
 if(enableRotationZ){
  translate(width / 2, height / 2, 200*cos(radians(frameCount * rotationZspeed % 360)) );
 }else{
  translate(width / 2, height / 2, mouseY - height/2);
 }
 //fill(100,89,90,70);
 rotateX(PI/4);
 //rotateY(radians(map(mouseX, 0, width, 0, 360)));
 if(enableRotationZ){
  rotateZ(radians(frameCount * rotationZspeed  % 360));
 }
 rotateZ(radians(map(mouseX, 0, width, 0, 360)));
 showPlane();
}

void depthCalc() { //goes through array of points and assigns each a depth according to Perlin Noise function
 float noiseY = move;
 for (int y = 0; y < rows; y++) {
  float noiseX = 0;
  for (int x = 0; x < cols; x++) {
   z[x][y] = map(noise(noiseX, noiseY*spectrum[y]), 0, 1, -amp, amp) * map(amplitude.analyze(), 0, 0.1, 0, 1); //
   noiseX += density*amp;
  }
  noiseY += density*amp;
 }
}

void showPlane() { //places vertices and creates POINTS shaoe with them
 int hue_factor;
 for (int y = 0; y < rows - 1; y++) {
  beginShape(TRIANGLE_STRIP); //CAMBIAR POINTS POR TRIANGLE_STRIP
  for (int x = 0; x < cols; x++) {
   hue_factor = round(map(z[x][y], 0, 10, 0, 241));
   if(hue_factor > 241) hue_factor = 241;
   if(hue_factor < 0 ) hue_factor = 0;
   stroke(241-hue_factor, saturation, brightness);
   vertex(x * space - w/2, y * space - h/2, z[x][y]);

   hue_factor = round(map(z[x][y+1], 0, 10, 0, 241));
   if(hue_factor > 241) hue_factor = 241;
   if(hue_factor < 0 ) hue_factor = 0;
   stroke(241-hue_factor, saturation, brightness);
   //println(amp, z[x][y], hue_factor, 241-hue_factor, saturation, brightness);
   vertex(x * space - w/2, (y + 1) * space - h/2, z[x][y + 1]);
  }
  endShape();
 }
}

// método que hace que el sonido entre a Processing
void soundCalc() {
 fft.analyze(spectrum);
 sound += (spectrum[0] - sound) * smooth; //use spectrum[0] for bass frequencies

 amp = map(sound, 0, 0.05, 0, 100);
 //speed = map(sound, 0, 1, 0.1, .8);
 speed = map(sound, 0, 1, 0.01, 0.08);

 // strokeCol = color(, map(sound, 0, 1, 80, -180), map(sound, 0, 1, 80, -180));
 // println(sound, strokeCol, map(sound, 0, 1, 80, -180));
 //int hue = round(map(sound, 0, 0.3, 0, 255));
 hue = 160 - round(map(amp, 10, 100, 0, 123)); //-255 in order to range from BLUE to RED
 saturation = 150 - Math.max(round( map(amp, 10, 100, 0, 50)), 50 );
 brightness = round(map(amp, 10, 100, 40, 100));
 //println(sound, amp, hue, saturation, brightness);
 stroke(hue, saturation, brightness);
 fill(hue, saturation, brightness, 50);
 strokeWeight(map(sound, 0, 1, 2, 8));
}
