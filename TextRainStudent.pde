/**
    Comp 494 Spring '17 Assignment #1 Text Rain
**/


import processing.video.*;
import java.util.ArrayList;
import java.util.Random;
import java.util.Collections;
import java.util.*;

// Global variables for handling video data and the input selection screen
String[] cameras;
Capture cam;
Movie mov;
PImage inputImage;
boolean inputMethodSelected = false;
int floor(double d) {
  return (int) Math.floor(d);
}


int g = 0;

Manager m;
Clock clock;
int time;

int x;
String text1;


void setup() {
  size(1280, 720);  
  inputImage = createImage(width, height, RGB);
  PFont font = loadFont("ArialMT-24.vlw");
  textFont(font,24);
  
  m = new Manager();
  clock = new Clock();
  time = clock.tick();
  
  x = 0;
  text1 = "";
  
}

class ViewManager {
   int threshold = 128;
   int adjustment = 15;
   boolean thresholdView = false;
   
   ViewManager(){}
   
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
class Manager {
  
   ViewManager vm = new ViewManager();
   ScreenCharManager scm = new ScreenCharManager();
   
   boolean firstRender = true;
  
   Manager() {
     
   }
   public void onKeyUp() {
     vm.increment();
   }
   public void onKeyDown() {
     vm.decrement();
   }
   public void onKeySpace() {
     vm.toggleThresholdView();
   }
   public void process(PImage img) {
     vm.process(img);
   }
   public void onRender() {
     if(firstRender) {
       firstRender = false;
       onFirstRender();
     }
   }
   protected void onFirstRender() {
     
   }
   public int getThreshold() {
     return vm.threshold;
   }
    void update(int millis,PImage bg) {
      scm.update(millis,bg,vm.threshold);
    }
    void render() {
      scm.render();
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
  WorldCoord toWorldCoord() {
    return new WorldCoord(x/width,y/height);
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




class ScreenCharacter {
   public static final int TEXT_HEIGHT = 20;
   public static final float ESCAPE_VEL = 1; // pixel per jump
   public final color COLOR = color(85,0,255);
   
   color charColor;
   char c;
   float speed; // pixels per second
   ScreenCoord coord;
   public int lifetime; // milliseconds;

   int life = 0;

   ScreenCharacter(char c, WorldCoord coord,float speed, int lifetime,color _charColor) { //<>//
     this(c, coord.toScreenCoord(),speed,lifetime,_charColor);
   }
   ScreenCharacter(char c, ScreenCoord coord,float speed, int lifetime,color _charColor) {
     this.c = c;
     this.coord = coord;
     this.speed = speed;
     this.lifetime = lifetime;
     this.charColor = _charColor;
   }
   void update(int millis,PImage bg, int threshold) {
     life += millis;
     while(isHit(bg,threshold)) { //<>//
       coord.y -= ESCAPE_VEL;
     }
     coord.y += speed* millis / 1000;
    }
    void renderCharacter() {
     float alpha = 255 * (1 - ((float)life)/lifetime);
     fill(charColor,alpha);
      text(c,coord.x,coord.y); 
    }
   boolean isHit(PImage bg,int threshold) {
     color[] ps = bg.pixels;
     int charWidth = ceil(textWidth(c));
     boolean result = false;
     ScreenCoord scoord = new ScreenCoord(coord.x,coord.y);
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
   boolean isDead() {
     return (life > lifetime) || (coord.x > width || coord.y > height);
   }
}



//void charGenerator(char h, float x, float y) {
//  charList.add(new ScreenCharacter(h,x,y));
//}
  
ArrayList<String> genWords() {
    ArrayList<String> generatedWords = new ArrayList<String>();
      //EXTRACTING WORDS FROM A TEXT FILE
  String lines[] = loadStrings("text.txt");
  for (int x = 0; x < lines.length - 1; x ++) {
    text1 += lines[x];
  }
  //String st = text1.replaceAll("\\s+",""); 
  String result = text1.replaceAll("[^\\p{L}\\p{Z}]","");
  //split using space
  String[] splited = result.split("\\s+");
  //add to generatedWords list
  for (String words : splited) {
    generatedWords.add(words);
    
  }
  return generatedWords;
}
class ScreenCharManager {
  public final int CAPACITY = 1000;
  ArrayList<ScreenCharacter> screenChars = new ArrayList(CAPACITY);
  ScreenCharGenerator scg = new ScreenCharGenerator();
  ScreenCharManager() {
    
  }
   void update(int millis,PImage bg, int threshold) {
    for(ScreenCharacter sc: screenChars) {
      sc.update(millis,bg,threshold);
    }
    screenChars = cleanDead(screenChars);
    while(screenChars.size() < CAPACITY) {
       screenChars.addAll(scg.generate());
     }
  }
  void render() {
    for(ScreenCharacter sc: screenChars) {
      sc.renderCharacter();
    }
  }
}
class ScreenCharGenerator {
  protected ArrayList<String> generatedWords = genWords();
  public final char[] alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".toCharArray();
  
  protected Random randomGenerator = new Random();
  
  public static final float WORD_CHANCE = 0.2;
  
  public static final float Y_VARIANCE = 10; // pixels
  public static final float X_VARIANCE = 0; // pixels
  
  public static final float BASE_SPEED = 10;
  public static final float SPEED_VARIANCE = 20; // pixels per second
  
  public static final int BASE_LIFETIME = 40000;
  public static final float LIFETIME_VARIANCE = 40000; // millis
  
  public final color COLOR_A = color(0,0,128);
  public final color COLOR_B = color(0,0,255);
  
  public ScreenCharGenerator() {
    
  }
  public ArrayList<ScreenCharacter> generate() {
    if(Math.random() < WORD_CHANCE) {
      return genWord();
    } else {
      ArrayList<ScreenCharacter> result = new ArrayList();
      result.add(genChar());
      return result;
    }
  }
  protected color pickColor() {
    return lerpColor(COLOR_A,COLOR_B,randomGenerator.nextFloat());
  }
  protected float yRange() {
    return -2 * height;
  }
  protected ArrayList<ScreenCharacter> genWord() {
    String word = generatedWords.get(randomGenerator.nextInt(generatedWords.size()));
    ArrayList<ScreenCharacter> out = new ArrayList(word.length());
    
    float x = randomGenerator.nextFloat() * width;
    float y = yRange() * randomGenerator.nextFloat();
    float speed = 10 + randomGenerator.nextFloat() * SPEED_VARIANCE;
    int lifetime = ceil(10000 + randomGenerator.nextFloat() * LIFETIME_VARIANCE);
    color charColor = pickColor();

    
    for(char c : word.toCharArray()) {
      float xx = randomGenerator.nextFloat() * X_VARIANCE + x;
      float yy = randomGenerator.nextFloat() * Y_VARIANCE + y;
      out.add(new ScreenCharacter(c,new ScreenCoord(xx,yy),speed,lifetime,charColor));
      x += textWidth(c);
    }
    
    return out;
  }
  protected ScreenCharacter genChar() {
    char c = alphabet[randomGenerator.nextInt(alphabet.length)];
    float x = randomGenerator.nextFloat() * width;
    float y = yRange()* randomGenerator.nextFloat();
    float xx = randomGenerator.nextFloat() * X_VARIANCE + x;
    float yy = randomGenerator.nextFloat() * Y_VARIANCE + y;
    float speed = BASE_SPEED + randomGenerator.nextFloat() * SPEED_VARIANCE;
    int lifetime = ceil(BASE_LIFETIME + randomGenerator.nextFloat() * LIFETIME_VARIANCE);
    color charColor = pickColor();
    return new ScreenCharacter(c,new ScreenCoord(xx,yy),speed,lifetime,charColor); 
  }

}
  

  
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
  
  m.update(time,inputImage);
  
  set(0, 0, inputImage);
  m.render();

  //charGenerate(charactersList.get(g));
  

}

ArrayList<ScreenCharacter> cleanDead(ArrayList<ScreenCharacter> chars) {
  ArrayList<ScreenCharacter> out = new ArrayList(chars.size());
  for(ScreenCharacter c : chars) {
    if(!c.isDead()) {
      out.add(c);
    }
  }
  return out;
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
      m.onKeyUp();
    }
    else if (keyCode == DOWN) {
      m.onKeyDown();
    } 
  }
  else if (key == ' ') {
    m.onKeySpace();
  } 
  
}