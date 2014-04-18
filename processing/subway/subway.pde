/**
 * Background Subtraction 
 * by Golan Levin. 
 *
 * Detect the presence of people and objects in the frame using a simple
 * background-subtraction technique. To initialize the background, press a key.
 */


import processing.video.*;
import java.awt.Color;
import ddf.minim.*;

int numPixels;
int[] backgroundPixels;
int[] colInt;
Capture video;
Minim minim;
AudioPlayer player;

int width = 1280;
int height = 720;

int clock = 0;

void setup() {
  size(width , height); 
  
  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  //video = new Capture(this, 160, 120);
  video = new Capture(this, width, height);
  
  // Start capturing the images from the camera
  video.start();  
  
  numPixels = video.width * video.height;
  // Create array to store the background image
  backgroundPixels = new int[numPixels];
  // Make the pixels[] array available for direct manipulation
  loadPixels();
  
  //=========== bgm ================
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  
  // loadFile will look in all the same places as loadImage does.
  // this means you can find files that are in the data folder and the 
  // sketch folder. you can also pass an absolute path, or a URL.
  player = minim.loadFile("bgm.mp3");
  
  // play the file
  player.play();
}

void draw() {
  clock ++;
  if (video.available()) {
    video.read(); // Read a new video frame
    
    video.loadPixels(); // Make the pixels of video available
    // get color pixels after dealing with the color difference
    color[] colDiff = colorDiff( video.pixels , width , height );
    arraycopy(colDiff , pixels);
   
    updatePixels(); // Notify that the pixels[] array has changed
    
  }
}

 color getBodyColor() {
   float intense = 0;
   for(int i = 0; i < player.bufferSize() - 1; i++) {
      intense += Math.abs( player.right.get(i) )  + Math.abs( player.left.get(i) );
   }
   intense /= player.bufferSize();
    println( intense );
    return Color.HSBtoRGB( 1.0f * (clock % 300) / 300 ,1.0f
    , Math.max( Math.min( Math.abs( intense + 0.5 ) , 0.90 ) , 0.70 ) );
 }
 color[] colorDiff( color[] input , int width , int height ) {
   color[] res = new color[width*height];
   color backColor = getBodyColor();
   for ( int i = 0 ; i < height ;  ++ i ) {
     for ( int j = 0 ; j < width ; ++ j ) {
       
       double k = Math.exp( -0.04 * Math.max( 0 
       , getMaxDiff( input[ i * width + j ] , backgroundPixels[ i * width + j ] ) - 10 ));
       
       
       res[ i * width + j ] = 
       addColor( timeColor( input[ i * width + j ] , k ) , timeColor( backColor , 1 - k ) );
       
     }
   }
   return res;
 } 
 
 int[] colorDiffInt( color[] input , int width , int height ) {
   int[] res = new color[width*height];
   for ( int i = 0 ; i < height ;  ++ i ) {
     for ( int j = 0 ; j < width ; ++ j ) {
       
       double k = Math.exp( -0.04 * Math.max( 0 
       , getMaxDiff( input[ i * width + j ] , backgroundPixels[ i * width + j ] ) - 10 ));
       
       color backColor = 0x000000;
       
       res[ i * width + j ] = ( k > 0.9) ? 1 : -1;
     }
   }
   return res;
 } 
 
 color timeColor( color col , double k ) {
   
      //Extract the red, green, and blue components of the current pixel's color
      int currR = (col >> 16) & 0xFF;
      int currG = (col >> 8) & 0xFF;
      int currB = col & 0xFF;
      //transform color 
      currR = (int) ( k * currR ) ;
      currG = (int) ( k * currG ) ;
      currB = (int) ( k * currB ) ;
      return  0xFF000000 | ( (currR << 16) & 0xFF0000 )
        | ( (currG << 8) & 0xFF00 ) | ( currB & 0xFF );
 }
 color addColor( color a , color b ) {
     int aR = a & 0xFF0000;
     int aG = a & 0xFF00;
     int aB = a & 0xFF;
     
     int bR = b & 0xFF0000;
     int bG = b & 0xFF00;
     int bB = b & 0xFF;
     
     return 0xFF000000 | ( (aR + bR) & 0xFF0000 ) 
             | ( ( aG + bG ) & 0xFF00 ) | ( aB + bB ) & 0xFF;
     
 }
 
 int getMaxDiff( color currColor , color bkgdColor ) {
   
      //Extract the red, green, and blue components of the current pixel's color
      int currR = (currColor >> 16) & 0xFF;
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract the red, green, and blue components of the background pixel's color
      int bkgdR = (bkgdColor >> 16) & 0xFF;
      int bkgdG = (bkgdColor >> 8) & 0xFF;
      int bkgdB = bkgdColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - bkgdR);
      int diffG = abs(currG - bkgdG);
      int diffB = abs(currB - bkgdB);
      
      return Math.max( Math.max( diffR , diffG ) , diffB );
 }

// When a key is pressed, capture the background image into the backgroundPixels
// buffer, by copying each of the current frame's pixels into it.
void keyPressed() {
  if ( key == 32 ) { // if press space, copy the video to back ground
    video.loadPixels();
    arraycopy(video.pixels, backgroundPixels);
  }
}
