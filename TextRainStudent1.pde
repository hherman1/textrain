/**
    Comp 494 Spring '17 Assignment #1 Text Rain
**/


import processing.video.*;
import java.util.ArrayList;
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

ArrayList<ScreenCharacter> list123;

void setup() {
  size(1280, 720);  
  inputImage = createImage(width, height, RGB);
  PFont font = loadFont("ArialMT-24.vlw");
  textFont(font,24);

  list123 = listMaker();
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




class ScreenCharacter {
   public static final int TEXT_HEIGHT = 20;
   public static final float ESCAPE_VEL = 1; // pixel per jump
   WorldCoord coord;
   float speed = 590; // pixels per second
   char c;
   ScreenCharacter(char c, float x,float y) {
     this.c = c; //<>//
     this.coord = new WorldCoord(x,y);
     //println(coord.toScreenCoord().x,coord.toScreenCoord().y);
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
int time = clock.tick();

int x = 0;
String text1 = "";

ArrayList<ScreenCharacter> charList = new ArrayList<ScreenCharacter>();

void charGenerator(char h, float x, float y) {
  charList.add(new ScreenCharacter(h,x,y));
}
  
ArrayList<ScreenCharacter> listMaker() {

  
    String text1 = "";
  
  
  
  
  
  //list of all words extracted from a file
  ArrayList<String> generatedWords = new ArrayList<String>();
  
  //jumbled versions of all words
  ArrayList<String> jumbledWords = new ArrayList<String>();
  
  //a list of words, some jumbled, others not jumbled.
  ArrayList<String> wordsList = new ArrayList<String>();
  
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
  
  //println(generatedWordsList);
  
  //SHUFFLING WORDS TO MAKE JUMBLED WORDS
  //http://stackoverflow.com/questions/4247810/scramble-a-word-using-java
  for (int w = 0; w < generatedWords.size(); w++) {
    String word = generatedWords.get(w);
  ArrayList<Character> chars = new ArrayList<Character>(word.length());
  
   for ( char c : word.toCharArray() ) {
   chars.add(new Character(c));
  }
  Collections.shuffle(chars);
  char[] shuffled = new char[chars.size()];
  for ( int i = 0; i < shuffled.length; i++ ) {
   shuffled[i] = chars.get(i);
  }
  String shuffledWord = new String(shuffled);
  jumbledWords.add(shuffledWord);
  }
  
  //println(jumbledWords);
  
  
  //combining generatedWords and jumbledWords to make our wordsList. At every index number that is divisible by 3 or 4, we don't shuffle the word.
  for (int i = 0; i < generatedWords.size(); i++){
    if (i%3==0 || i%4==0){
      wordsList.add(generatedWords.get(i));
    } 
    else {
      wordsList.add(jumbledWords.get(i));
    }
  }
  
  //println(wordsList);
   
    
    float xCoordinate = 0.00;
    float yCoordinate = 0.00;

    float widthTracker = 0.00;
    
    //char wyd = samplelist.get(0).charAt(1);
    //println(textWidth(wyd));
    
    //println(width);
    
    List<Float> list = new ArrayList<Float>();
    list.add(0.00);
    list.add(-0.02);
    list.add(-0.04);
    list.add(-0.05);
    Float random = list.get(new Random().nextInt(list.size()));
    
   
   //println("PRINT VALUE IS " + random);
   //println("PRINT VALUE IS " + random);
   //println("PRINT VALUE IS " + random);
   //println("PRINT VALUE IS " + random);
    

    
    for(String s : wordsList){
    for(int i = 0; i < s.length(); i++){
      if(widthTracker < 700){
        
        //println(widthTracker);
        widthTracker = widthTracker + (textWidth(s.charAt(i)) + 0.02);
        random = list.get(new Random().nextInt(list.size()));
        //println("PRINT VALUE IS " + random);
        charList.add(new ScreenCharacter(s.charAt(i),xCoordinate,random));
        xCoordinate+=0.02;
      }
      
      else if(widthTracker >= 700) {
        widthTracker = 0;
        xCoordinate = 0.00;
        println("PRINT VALUE IS " + random);
        random -= 0.09;
      }
     

    }
    }
    
    return charList;
    
    
  
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
  
  set(0, 0, inputImage);
  
    
  //charGenerate(charactersList.get(g));
  
  
  for(ScreenCharacter c : list123) {
    charGenerate(c);
  }

}

void charGenerate(ScreenCharacter characterObj) {
   characterObj.update(time,inputImage,m.threshold);
   characterObj.render();
   return;
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