
// !!! Setup things !!!

import java.io.File;

import java.awt.*;

Toolkit toolkit=Toolkit.getDefaultToolkit();

PImage noiseMap;
PGraphics buffer1;
PGraphics buffer2;

PImage palette;

PImage temp;

PImage temp2;

boolean saveFiles = false;

boolean reversed = false;

boolean blank = false;

int w;
int h;

int uw;
int uh;

int pmx;
int pmy;

int buffer;

int frame;

String f;

String fp;

float increment = 0.03;

float yoff = 0.0;

int[] colorstInitBlank = {}; 

int[] colorsInit = {0, 0, 0};

int[] colors; // Colors[] stores the RGB values of every pixel in the selected palette in the order { color1 Red, color1 Green, color1 Blue }


// !!! Variables you want to set !!!


int scale = 10; // How large the pixels display on your screen, does not effect actual .png size, but does effect how the flames render. I recommend having larger scales for smaller render dimensions, and vice versa.

int pixelw = 48; // Image width in pixels (actual window width is this number * scale)
int pixelh = 48; // Image height in pixels (actual window height is this number * scale)

// Some good values for these numbers are scale: 1 pixelw & pixel h: 600, scale: 10 pixelw & pixelh: 48

void setup() {
  
  increment = sqrt(scale)/20; // Increment controls the detail of the noise map, larger values mean more detail. Bound to scale by default.
  
  
  // !!! Don't touch these unless you know what you're doing !!!
  
  
  size(600,600);
  
  buffer = scale*2;
  
  uw = (pixelw * scale) + (buffer*2);
  uh = (pixelh * scale) + (buffer*2);
  
  w = uw / max(scale,1);
  h = uh / max(scale,1);
  
  println("True canvas width: " + w + " | " + "True canvas height: " + h);
  
  surface.setLocation((toolkit.getScreenSize().width/2)-((pixelw * scale)/2), (toolkit.getScreenSize().height/2)-((pixelh * scale)/2));
  surface.setSize((pixelw * scale),(pixelh * scale));
  surface.setTitle("Fire Generator");
  
  // Quick script to delete any image files created by previous runs of the program.
  
  boolean fail = false;
  int count = 0;
  while (!fail) {
    String fileName = dataPath("images/" + "Fire" + nf(count, 5) + ".png");
    File f2 = new File(fileName);
    if (f2.exists()) {
      f2.delete();
      count++;
    } else {
      fail = true;
    }
  }
  
  selectInput("Select a file to process:", "fileSelected"); // First time selection of palette.
  
  buffer1 = createGraphics(w, h);
  buffer2 = createGraphics(w, h);
  noiseMap = createImage(w, h, RGB);
  
  // Initialize the noise map.
  
  noiseMap.loadPixels();
  for (int y = 0; y < h; y++) {
    yoff += increment;

    drawNoiseMapRow(y);
  }
  noiseMap.updatePixels();
}

void draw() {
  
  if (f != null) { // Run only when there is a palette file selected.
    
    //fire(round(10/sqrt(scale))); // Draws a row of fire at the bottom of the window. Comment out if you don't want it.
    
    // Mouse controls.
    
    buffer1.beginDraw();
    if (mousePressed) {
      buffer1.stroke(255);
      buffer1.strokeWeight(50/scale);
      buffer1.line((mouseX+(buffer))/(scale), (mouseY+(buffer))/(scale), (pmx+(buffer))/(scale), (pmy+(buffer))/(scale));
    }
    
    
    // !!! Add shapes here !!!
    
    // If you want specific shapes to generate flames with, add them here using the 2D Primatives supplied in Processing.
    
    // You could even create a .png with the same dimensions as buffer1 and use grayscale colorvalues to create specific flame intensities. The following is an example of how to do that for a scale: 10 pixelw & pixelh: 48 canvas.
    
    /* // Remove
    if(!saveFiles) frame = frameCount;
    
    String fileName = dataPath("masks/" + "Mask" + nf(frameCount-frame, 5) + ".png");
    File f3 = new File(fileName);
    if (f3.exists()) {
      temp = loadImage(dataPath("masks/" + "Mask" + nf(frameCount-frame, 5) + ".png"));
      temp2 = temp;
      buffer1.image(temp, 0, 0);
    } else {
      buffer1.image(temp2, 0, 0);
    }
    */ // Remove
    
    // Make sure to use buffer1. before any commands.
    
    
    buffer1.endDraw(); // Place mask shapes before this line.
    
    // Next two lines control #1 the dissipation speed of the flames, and #2 the vertical speed of the flames.
    
    stepfire(1+round(14/(scale*1.54)));
    
    flame(1+round(7/(scale*1.405)));
    
    // Script to change the flame colors to match the palette provided.
    
    buffer2.beginDraw();
    buffer2.loadPixels();
    for (int x = 0; x < w; x++) {
      for (int j = 0; j < h; j++) {
        int y = h - (j + 1);
        int index = (x + y * w);
        
        float calc = 260 / max(1,(colors.length-3)/3);
        
        int calc2 = round(brightness(buffer2.pixels[index]) / calc) * 3;
        
        buffer2.pixels[index] = color(colors[calc2], colors[calc2+1], colors[calc2+2]);
      }
    }
    buffer2.updatePixels();
    buffer2.endDraw();
    
    // Upscale.
    
    PGraphics temp2 = createGraphics(uw, uh);
    temp2.noSmooth();
    temp2.beginDraw();
    temp2.image(buffer2, buffer/-2, buffer/-2, uw, uh);
    temp2.endDraw();
    
    // Display image
    
    image(temp2, buffer/-2, buffer/-2);
  }
  
  pmx = mouseX;
  pmy = mouseY;
  
  if (saveFiles) saveTransparentCanvas(color(0), "Fire"); // Change "Fire" to change the saved file name.
}

// Simple key controls.

void keyReleased() {
  
  if (f != null) {
    
    if (key == 'n' || key == 'N') {
      fp = f;
      f = null;
      selectInput("Select a file to process:", "fileSelected");
    }
    
    if (key == 'b' || key == 'B') {
      blank = !blank;
      palette(f);
    }
    
    if (key == 's' || key == 'S') {
      frame = frameCount+1;
      saveFiles = !saveFiles;
    }
  }
  if (key == 'q' || key == 'Q') {
    exit();
  }
}

void drawNoiseMapRow(int y) {
  float xoff = 0.0;
  for (int x = 0; x < w; x++) {
    xoff += increment;
    float n = noise(xoff, yoff);
    int bright = round(pow(n, 3) * 255);
    int index = (x + y * w);
    noiseMap.pixels[index] = color(bright);
  }
}

void fire(int rows) {
  buffer1.beginDraw();
  buffer1.loadPixels();
  for (int x = 0; x < w; x++) {
    for (int j = 0; j < rows; j++) {
      int y = h - (j + 1);
      int index = (x + y * w);
      buffer1.pixels[index] = color(255);
    }
  }
  buffer1.updatePixels();
  buffer1.endDraw();
}

// Fire calculations.

void flame(int steps) {
  
  buffer1.beginDraw();
  buffer1.loadPixels();
  buffer2.beginDraw();
  buffer2.loadPixels();
  
  for (int x = 1; x < w - 1; x++) {
    for (int y = steps; y < h - 1; y++) {
      int index0 = (x + y * w);
      int index1 = (x + 1 + y * w);
      int index2 = (x - 1 + y * w);
      int index3 = (x + (y + 1) * w);
      int index4 = (x + (y - 1) * w);
      
      int index5 = (x + (y - steps) * w);
      
      float c1 = brightness(buffer1.pixels[index1]);
      float c2 = brightness(buffer1.pixels[index2]);
      float c3 = brightness(buffer1.pixels[index3]);
      float c4 = brightness(buffer1.pixels[index4]);
      
      float c5 = brightness(noiseMap.pixels[index0]);
      
      float newC = c1 + c2 + c3 + c4;
      newC = newC * 0.25 - c5;
      
      buffer2.pixels[index5] = color(newC);
    }
  }
  
  buffer2.updatePixels();
  buffer2.endDraw();
  buffer1.endDraw();

  PGraphics temp = buffer1;
  buffer1 = buffer2;
  buffer2 = temp;
  
}

void stepfire(int steps) {
  
  noiseMap.copy(0, steps, w, h - steps, 0, 0, w, h - steps);

  noiseMap.loadPixels();
  
  for (int i = h - steps; i < h; i++) {
    yoff += increment;
    
    drawNoiseMapRow(i);
  }
  noiseMap.updatePixels();
}

// File selection window.

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    f = fp;
  } else {
    println("User selected " + selection.getAbsolutePath());
    String file = selection.getAbsolutePath();
    
    palette(file);
  }
}

// Converts the palette provided into the colors[] array. Contains a simple scrip to intuitively match the color ramp direction of the provided palette. (Checks both ends of the palette to see which is darker)

void palette(String file) {
  colors = colorsInit;
  if (blank) colors = colorstInitBlank; 
  
  palette = loadImage(file);
  
  palette.loadPixels();
  
  for (int i = 0; i < palette.width; i++) {
    if (brightness(palette.pixels[palette.width-1]) < brightness(palette.pixels[0])) {
      colors = append(colors, palette.pixels[palette.width-(i+1)] >> 16 & 0xFF);
      colors = append(colors, palette.pixels[palette.width-(i+1)] >> 8 & 0xFF);
      colors = append(colors, palette.pixels[palette.width-(i+1)] & 0xFF);
    } else {
      colors = append(colors, palette.pixels[i] >> 16 & 0xFF);
      colors = append(colors, palette.pixels[i] >> 8 & 0xFF);
      colors = append(colors, palette.pixels[i] & 0xFF);
    }
  }
  palette.updatePixels();
  
  f = file;
}

// Transparent .png saving script. (knocks out pure black only)

void saveTransparentCanvas(color bg, String name) {
  PImage canvas = buffer2.get();
  canvas.format = ARGB;
 
  color p[] = canvas.pixels, bgt = bg & ~#000000;
  for (int i = 0; i != p.length; ++i)  if (p[i] == bg)  p[i] = bgt;
 
  canvas.updatePixels();
  canvas.save(dataPath("images/" + name + nf(frameCount-frame, 5) + ".png"));
}
