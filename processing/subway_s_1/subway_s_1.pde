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
import processing.net.*;

int numPixels;
int[] staticPixels;
int[] backgroundPixels;
int[] frontPixels;
int[] resultPixels;
double[] kArray;
int[] colInt;
Capture video;
Minim minim;
AudioPlayer player;

int width = 640;
int height = 480;

int clock = 0;
int ifSend = 0;

//=========color================
int serverColor = 0xFF7FECAD;;

//======net=======
Server s;
Client  c;
int sendTime = 2;

int bufferLength = width*height/2;
byte[] buffersSend = new byte[bufferLength];
byte[] buffersRecv = new byte[bufferLength];

int recvCount = 0;

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
  staticPixels = new int[numPixels];
  // Make the pixels[] array available for direct manipulation
  loadPixels();
  //set background pixels
  backgroundPixels = new int[width*height];
  frontPixels = new int[width*height];
  resultPixels = new int[width*height];
  kArray = new double[width*height];
  
  //=========== bgm ================
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  
  // loadFile will look in all the same places as loadImage does.
  // this means you can find files that are in the data folder and the 
  // sketch folder. you can also pass an absolute path, or a URL.
  player = minim.loadFile("bgm.mp3");
  
  // play the file
  player.play();
  
  //============= net ================
  s = new Server(this, 12345);
  
}

void draw() {
  clock ++;
  if ( ( clock % sendTime ) == 0 )
    ifSend = 1;
  if (video.available()) {
    video.read(); // Read a new video frame
    //setBackgroundPixels();
    setFrontPixels();
    
    //get_buffer();
    
    video.loadPixels(); // Make the pixels of video available
    // get color pixels after dealing with the color difference
    colorDiff( video.pixels , width , height );
    arraycopy(resultPixels , pixels);
    
    //println("clock = " + clock + " % = " + ( clock % 1000 ) );
    if( ifSend == 1 ) {
      //println("before send buffer");
      send_buffer();
      //println("after send buffer");
      ifSend = 0 ;
    }
   
    updatePixels(); // Notify that the pixels[] array has changed
    
  }
}


//==============


void send_buffer() {
  for(int i = 0; i < width * height / 2; i++){
    //buffersSend[ i * 4 + 3 ] = (byte)(( resultPixels[i] >>> 24 ) & 0xFF);
    //buffersSend[ i * 4 + 2 ] = (byte)(( resultPixels[i] >>> 16 ) & 0xFF);
    //buffersSend[ i * 4 + 1 ] = (byte)(( resultPixels[i] >>> 8 ) & 0xFF);
    //buffersSend[ i * 4 + 0 ] = (byte)( resultPixels[i] & 0xFF);
    byte h = (byte)(kArray[i*2] * 16);
    byte l = (byte)(kArray[i*2+1] * 16);
    buffersSend[i] = (byte)((h << 4) & 0xF0 | ( l & 0x0F ));
    //println( "res " + resultPixels[i] + " bufsend " + buffersSend[ i * 4 + 3 ] + " " 
    // + buffersSend[ i * 4 + 2 ] + " " + buffersSend[ i * 4 + 1 ]
    //+ " " + buffersSend[ i * 4 + 0 ] );
    
  }
  s.write(buffersSend);
}

void get_buffer() {
  c = s.available();
  if (c != null) 
  {
    int tempLength = bufferLength - recvCount ;
    byte[] tempBuf = new byte[tempLength];
    int count = c.readBytes(tempBuf);
    for(int i = 0; i < count; i++) {
      buffersRecv[recvCount + i] = tempBuf[i];
    }
    recvCount += count;
    if(recvCount < bufferLength )
    {
      println("count: " + count);
    }
    else
    {
      recvCount = 0;
      for(int i = 0; i < width * height; i++) {
        backgroundPixels[i] = (int)(buffersRecv[i * 4 + 0]);
        backgroundPixels[i] |= (int)(buffersRecv[i * 4 + 1] << 8);
        backgroundPixels[i] |= (int)(buffersRecv[i * 4 + 2] << 16);
        backgroundPixels[i] |= (int)(buffersRecv[i * 4 + 3] << 24);
      }
    }
  }
}
//=============

void setBackgroundPixels(){
  
   for ( int i = 0 ; i < height ;  ++ i ) {
     for ( int j = 0 ; j < width ; ++ j ) {
       backgroundPixels[ i * width + j ] = 0xFF000000;
     }
   }
}

color getBackgroundPixel( int i , int j ){
  return backgroundPixels[ i * width + j ];
}

void setFrontPixels(){
  color bodyColor = getBodyColor();
  for ( int i = 0 ; i < height ;  ++ i ) {
     for ( int j = 0 ; j < width ; ++ j ) {
       frontPixels[ i * width + j ] = serverColor;
       //frontPixels[ i * width + j ] = 0xFF0000FF;
     }
   }
}

color getFrontPixel( int i , int j ) {
  return frontPixels[ i * width + j ];
}

 color getBodyColor() {
   float intense = 0;
   for(int i = 0; i < player.bufferSize() - 1; i++) {
      intense += Math.abs( player.right.get(i) )  + Math.abs( player.left.get(i) );
   }
   intense /= player.bufferSize();
    //println( intense );
    return Color.HSBtoRGB( 1.0f * (clock % 300) / 300 ,1.0f
    , Math.max( Math.min( Math.abs( intense + 0.5 ) , 0.90 ) , 0.70 ) );
 }
 
 color[] colorDiff( color[] input , int width , int height ) {
   color[] res = new color[width*height];
   //color bodyColor = getBodyColor();
   for ( int i = 0 ; i < height ;  ++ i ) {
     for ( int j = 0 ; j < width ; ++ j ) {
       
       color front = getFrontPixel( i , j );
       color back = getBackgroundPixel( i , j );
       
       double k = Math.exp( -0.04 * Math.max( 0 
       , getMaxDiff( input[ i * width + ( width - j -1) ] , staticPixels[ i * width + ( width - j -1) ] ) - 10 ));
       
       kArray[ i * width + j ] = 1 - k;
       
       resultPixels[ i * width + j ] = 
       addColor( timeColor( back , k ) , timeColor( front , 1 - k ) );
       
     }
   }
   return resultPixels;
 } 

 int[] colorDiffInt( color[] input , int width , int height ) {
   int[] res = new color[width*height];
   for ( int i = 0 ; i < height ;  ++ i ) {
     for ( int j = 0 ; j < width ; ++ j ) {
       
       double k = Math.exp( -0.04 * Math.max( 0 
       , getMaxDiff( input[ i * width + j ] , staticPixels[ i * width + j ] ) - 10 ));
       
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

double getH( color col ) {
  // get the RGB of the color
  int r = (col >> 16) & 0xFF;
  int g = (col >> 8) & 0xFF;
  int b = col & 0xFF;
  //get the max and min of the R G B
  int max = Math.max( Math.max( r , g ) , b );
  int min = Math.min( Math.min( r , g ) , b );
  //judge and return the value of h
  double H = 0;
  if ( max == min ) 
    H = 0;
  if ( max == r && g >= b )
    H = 60.0 * ( g - b  ) /  ( max - min );
  if ( max == r && g < b )
    H = 60.0 * ( g - b ) + 360;
  if ( max == g )
    H = 60.0 * ( b - r ) / ( max - min ) + 120.0;
  if ( max == b )
    H = 60.0 * ( r - g ) / ( max - min ) + 240.0;
  return H;
}

void getAngel( color a , color b) {
  double aR = (double)((a >> 16) & 0xFF);
  double aG = (double)((a >> 8) & 0xFF);
  double aB = (double)((a >> 0) & 0xFF);
  
  double bR = (double)((b >> 16) & 0xFF);
  double bG = (double)((b >> 8) & 0xFF);
  double bB = (double)((b >> 0) & 0xFF);
  
}

// When a key is pressed, capture the background image into the staticPixels
// buffer, by copying each of the current frame's pixels into it.
void keyPressed() {
  if ( key == 32 ) { // if press space, copy the video to back ground
    video.loadPixels();
    arraycopy(video.pixels, staticPixels);
  }
}
