/**
    Comp 494 Spring '17 Assignment #1 Text Rain
**/


import processing.video.*;

// Global variables for handling video data and the input selection screen
String[] cameras;
Capture cam;
Movie mov;
PImage inputImage;
boolean inputMethodSelected = false;
int floor(double d) {
  return (int) Math.floor(d);
}

void setup() {
  size(1280, 720);  
  inputImage = createImage(width, height, RGB);
  PFont font = loadFont("ArialMT-24.vlw");
  textFont(font,24);
}

class Manager {
   int threshold = 128;
   int adjustment = 15;
   boolean thresholdView = true;
   Manager() {
     
   }
   void toggleThresholdView() {
     thresholdView = !thresholdView;
   }
   void increment() {
      threshold = min(threshold + adjustment,255);
   }
   void decrement() {
       threshold = max(threshold - adjustment,0);
   }
   void process(PImage img) {
     img.loadPixels();
     if(thresholdView) {
       paintThreshold(img,threshold);
     } else {
       desaturate(img);
     }
      flip(img);
      img.updatePixels();
   }
   void desaturate(PImage img) {
     int dimension = img.width * img.height;
     colorMode(HSB);
      for (int i = 0; i < dimension; i += 1) {
        color c = img.pixels[i];
        img.pixels[i] = color(0, 0, brightness(c)); 
      } 
      colorMode(RGB);
   }
   void flip(PImage img) {
     int x = 0;
     int y = 0;
     for(y = 0; y < height; y++) {
       for(x = 0; x < width/2; x++) {
         color temp = img.pixels[toPixel(x,y)];
         img.pixels[toPixel(x,y)] = img.pixels[toPixel(width - x-1,y)];
         img.pixels[toPixel(width - x-1,y)] = temp;
       }
     }
   }
}

class Clock {
  int currentTick = 0;
  Clock() {}
  int tick() {
    int newTick = millis();
    int result = newTick - currentTick;
    currentTick = newTick;
    return result;
  }
}

class ScreenCoord {
  float x,y;
  ScreenCoord(float x, float y) {
    this.x = x;
    this.y = y;
  }
  boolean isVisible() {
    return x < width && x >= 0
      && y < height && y >= 0;
  }
  int toPixel() {
    return floor(y)*width + floor(x);
  }
}
int toPixel(int x, int y) {
    return y*width + x;
}
class WorldCoord {
  float x,y;
  WorldCoord(float x, float y) {
    this.x = x;
    this.y = y;
  }
  ScreenCoord toScreenCoord() {
    return new ScreenCoord(x * width,y * height);
  }
}




class Character {
   public static final int TEXT_HEIGHT = 20;
   public static final float ESCAPE_VEL = 1; // pixel per jump
   WorldCoord coord;
   float speed = 40; // pixels per second
   char c;
   Character(char c, float x,float y) {
     this.c = c; //<>//
     this.coord = new WorldCoord(x,y);
     println(coord.toScreenCoord().x,coord.toScreenCoord().y);
   }
   void render() {
     fill(128,128,255);
     ScreenCoord sc = coord.toScreenCoord();
      text(c,sc.x,sc.y); 
   }
   void update(int millis,PImage bg, int threshold) {
     while(isHit(bg,threshold)) { //<>//
       coord.y -= ESCAPE_VEL/height;
     }
     coord.y += speed* millis / (1000 * height);
    }
   boolean isHit(PImage bg,int threshold) {
     color[] ps = bg.pixels;
     int charWidth = ceil(textWidth(c));
     boolean result = false;
     ScreenCoord scoord = coord.toScreenCoord();
     scoord.x = floor(scoord.x);
     scoord.y = floor(scoord.y);
     float startX = scoord.x;
     
     for(int y=0; y < TEXT_HEIGHT; y++) {
        for(int x = 0; x < charWidth;x++) {
          if(scoord.isVisible()) {
            int index = scoord.toPixel();
             result = result || brightness(ps[index]) < threshold; 
          }
           scoord.x++;
         }
         scoord.x = startX;
         scoord.y--;
     }


     return result;
   }
}


Manager m = new Manager();
Clock clock = new Clock();


  Character c = new Character('H',0.5,0);

void draw() {
  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y=40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40; 
    for (int i = 0; i < min(9,cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    return;
  }


  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.

  
  // STEP 1.  Load an image, either from a movie file or from a live camera feed. Store the result in the inputImage variable
  
  if ((cam != null) && (cam.available())) {
    cam.read();
    inputImage.copy(cam, 0,0,cam.width,cam.height, 0,0,inputImage.width,inputImage.height);
    m.process(inputImage);

  }
  else if ((mov != null) && (mov.available())) {
    mov.read();
    inputImage.copy(mov, 0,0,mov.width,mov.height, 0,0,inputImage.width,inputImage.height);
    m.process(inputImage);
  }


  // Fill in your code to implement the rest of TextRain here..

  // Tip: This code draws the current input image to the screen
  
  int time = clock.tick();

  
  set(0, 0, inputImage);


  c.update(time,inputImage,m.threshold);
  
  
   
  c.render();



}

void paintThreshold(PImage img,int threshold) {
  int dimension = img.width * img.height;
  for (int i = 0; i < dimension; i += 1) {
    color c = img.pixels[i];
    if(brightness(c) < threshold) {
      img.pixels[i] = color(0, 0, 0); 
    } else {
      img.pixels[i] = color(255, 255, 255); 
    }

  } 
}

void keyPressed() {
  
  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        mov = new Movie(this, "TextRainInput.mov");
        mov.loop();
        inputMethodSelected = true;
      }
      else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");           
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
      clock.tick();
    }
    return;
  }


  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  // Fill in your code to handle keypresses here..
  
  if (key == CODED) {
    if (keyCode == UP) {
      m.increment();
    }
    else if (keyCode == DOWN) {
      m.decrement();
    } 
  }
  else if (key == ' ') {
    m.toggleThresholdView();
  } 
  
}