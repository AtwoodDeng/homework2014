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

//=========basic===============
int width = 640;
int height = 480;
Capture video;
Minim minim;
AudioPlayer player;

int clock = 0;

int numPixels;


//=========graphic==============

int[] staticPixels;
int[] backgroundPixels;
int[] frontPixels;
int[] resultPixels;
double[] kArray;
double[] kArrayServer;
int[] colInt;

//=========color================
int clientColor = 0xFF44CEF6;
int serverColor = 0xFFFFFF1A;
int mergeColor = 0xFF4CDB00;
//======net=======
int ifSend = 0;
Client  c;
String ip = "101.5.185.252";

int bufferLength = width*height/2;
byte[] buffersSend = new byte[bufferLength];
byte[] buffersRecv = new byte[bufferLength];
int recvCount = 0;

//==========particles==============
PImage sprite;
int parState = 0 ; // 0 for OFF ; 1 for ON
float mainParSpeedX = 0;
float mainParSpeedY = 0;
float mainParFloat = 2.5;
float mainParFix = 0.95;
float mainParLimX1 = 50;
float mainParLimX2 = width-50;
float mainParLimY1 = 25;
float mainParLimY2 = height / 2 - 100;
float mainParX = (mainParLimX1+mainParLimX2)/2;
float mainParY = (mainParLimY1+mainParLimY2)/2;

int npartTotal = 10000;
int npartPerFrame = 3;
float speed = 3.0;
float gravity = 0.05;
float partSize = 50;

int partLifetime = 20;
PVector positions[];
PVector velocities[];
int lifetimes[];

int fcount, lastm;
float frate;
int fint = 3;

//============ particle player interact ===========
double coverRate = 0.50;


void setup() {
  size(width , height,P3D);  
  frameRate(120);
  
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
  kArrayServer = new double[width*height];
  
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
  c = new Client(this, ip , 12345);
  
  //============= particles ==========
  sprite = loadImage("sprite.png");
  //partLifetime = npartTotal / npartPerFrame;
  initPositions();
  initVelocities();
  initLifetimes(); 
  hint(DISABLE_DEPTH_MASK);
  
}

void draw() {
  clock ++;
  if ( ( clock % 20 ) == 0 )
    ifSend = 1;
  if (video.available()) {
    video.read(); // Read a new video frame
    //setBackgroundPixels();
    setFrontPixels();
    
    //get buffer from net
    get_buffer();
    
    video.loadPixels(); // Make the pixels of video available
    // get color pixels after dealing with the color difference
    color[] playColor = colorDiff( video.pixels , width , height );
    //arraycopy(resultPixels , pixels);
    arraycopy( playColor , pixels);
    
    updatePixels(); // Notify that the pixels[] array has changed
    
  }
    checkParticle();
    setParticle();
}

//============== particles =============
void checkParticle(){
  int mx = (int)mainParX;
  int my = (int)mainParY;
  double pk = 0;
  double spk = 0;
  if ( my * width + mx >= 0 && my * width + mx < width * height ){
    pk = kArray[ my * width + mx ];
    spk = kArrayServer[ my * width + mx ];
  }
  if ( pk * spk > coverRate )
    changeParticle( 1 );
  else 
    changeParticle( 0 );
    
}
void changeParticle( int changeTo ) {
  if ( changeTo == 0 ) {
      parState = 0;
      npartPerFrame = 3;
      mainParFloat = 2.5;
      mainParFix = 0.95;
      speed = 3.0;
  }else if ( changeTo == 1 ){
      parState = 1;
      npartPerFrame = 30;
      mainParFloat = 0.3 ;
      mainParFix = 0.6;
      speed = 10.0;
  }
}

void setParticle() {
  //set main Particle
  mainParSpeedX *= mainParFix;
  mainParSpeedY *= mainParFix;
  mainParSpeedX += random( -mainParFloat , mainParFloat );
  mainParSpeedY += random( -mainParFloat , mainParFloat );
  if ( mainParX < mainParLimX1  || mainParX > mainParLimX2) 
    mainParSpeedX = - mainParSpeedX;
  if ( mainParY < mainParLimY1  || mainParY > mainParLimY2 )
    mainParSpeedY = - mainParSpeedY;
  mainParX = mainParX + mainParSpeedX;
  mainParY = mainParY + mainParSpeedY;
  
  //set other particles
  int newPar = 0;
  for (int n = 0; n < npartTotal; n++) {
    if ( lifetimes[n] >= 0 ) {
      lifetimes[n]++;
    }
    if (lifetimes[n] >= partLifetime) {
      lifetimes[n] = -1; // if the particle is dead, then set the lifetime to -1
    }   
 
    if ( 0 <= lifetimes[n] ) {
      float opacity = 1.0 - float(lifetimes[n]) / partLifetime;
      
      positions[n].x += velocities[n].x;
      positions[n].y += velocities[n].y;
        
      velocities[n].y += gravity;
        
      drawParticle(positions[n], opacity);
    
    }else if ( newPar < npartPerFrame ) {
        lifetimes[n] = 0;
        positions[n].x = mainParX;
        positions[n].y = mainParY;
        
        float angle = random(0, TWO_PI);
        float s = random(0.35 * speed, 0.55 * speed);
        velocities[n].x = s * cos(angle);
        velocities[n].y = s * sin(angle);
        
        newPar ++;
    }
  }
  fcount += 1;
  int m = millis();
  if (m - lastm > 1000 * fint) {
    frate = float(fcount) / fint;
    fcount = 0;
    lastm = m;
    println("fps: " + frate); 
  } 
}
void drawParticle(PVector center, float opacity) {
  beginShape(QUAD);
  noStroke();
  tint(255, opacity * 255);
  texture(sprite);
  normal(0, 0, 1);
  vertex(center.x - partSize/2, center.y - partSize/2, 0, 0);
  vertex(center.x + partSize/2, center.y - partSize/2, sprite.width, 0);
  vertex(center.x + partSize/2, center.y + partSize/2, sprite.width, sprite.height);
  vertex(center.x - partSize/2, center.y + partSize/2, 0, sprite.height);                
  endShape();  
}

void initPositions() {
  positions = new PVector[npartTotal];
  for (int n = 0; n < positions.length; n++) {
    positions[n] = new PVector();
  }  
}

void initVelocities() {
  velocities = new PVector[npartTotal];
  for (int n = 0; n < velocities.length; n++) {
    velocities[n] = new PVector();
  }
}

void initLifetimes() {
  // Initializing particles with negative lifetimes so they are added
  // progressively into the screen during the first frames of the sketch   
  lifetimes = new int[npartTotal];
  int t = -1;
  for (int n = 0; n < lifetimes.length; n++) {    
    /*if (n % npartPerFrame == 0) {
      t++;
    }*/
    lifetimes[n] = -t;
  }
} 

//============== net ================

void send_buffer() {
  for(int i = 0; i < width * height; i++){
    buffersSend[ i * 4 + 3 ] = (byte)(( resultPixels[i] >> 24 ) & 0xFF);
    buffersSend[ i * 4 + 2 ] = (byte)(( resultPixels[i] >> 16 ) & 0xFF);
    buffersSend[ i * 4 + 1 ] = (byte)(( resultPixels[i] >> 8 ) & 0xFF);
    buffersSend[ i * 4 + 0 ] = (byte)(( resultPixels[i] >> 0 ) & 0xFF);
  }
  c.write(buffersSend);
}

void get_buffer() {
  if(c.available() > 0)
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
      //println("count: " + count);
    }
    else
    {
      recvCount = 0;
      for(int i = 0; i < width * height / 2 ; i++) {
        //backgroundPixels[i] = ( (int)(buffersRecv[i * 4 + 0]) &  0x000000FF);
        //backgroundPixels[i] += ( (int)(buffersRecv[i * 4 + 1] << 8) & 0x0000FF00);
        //backgroundPixels[i] += ((int)(buffersRecv[i * 4 + 2] << 16) & 0x00FF0000);
        //backgroundPixels[i] += ((int)(buffersRecv[i * 4 + 3] << 24) & 0xFF000000);
        float[] hsb = Color.RGBtoHSB( (serverColor >>> 16) & 0x000000FF 
                                    ,  (serverColor >>> 8) & 0x000000FF
                                    ,  serverColor  & 0x000000FF , null);
        int rgbh = Color.HSBtoRGB(hsb[0], hsb[1] , 1.0
                                  * ((int)(buffersRecv[ i ]) & 0x000000F0) / 256.0 );
        int rgbl = Color.HSBtoRGB(hsb[0], hsb[1] , 1.0
                                  * ((int)(buffersRecv[ i ]) & 0x0000000F) / 16.0 );                         
        backgroundPixels[i*2] = rgbh;
        backgroundPixels[i*2+1] = rgbl;
        
        kArrayServer[i*2] = (double) 1.0 * ((int)(buffersRecv[ i ]) & 0x000000F0) / 256.0 ;
        kArrayServer[i*2+1] = (double) 1.0 * ((int)(buffersRecv[ i ]) & 0x0000000F) / 16.0 ;
        
     }
    }
  }
}

//============= set player =============

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
       if ( getMaxDiff( 0 , backgroundPixels[ i * width + j ] ) > 125  )
       {
          frontPixels[ i * width + j ] = mergeColor;
       }
       else
       {
          frontPixels[ i * width + j ] = clientColor;
       }
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
       , getMaxDiff( input[ i * width + ( width - j - 1 ) ] , staticPixels[ i * width + ( width - j - 1 ) ] ) - 10 ));
       
       
       resultPixels[ i * width + j ] = 
       addColor( timeColor( back , k ) , timeColor( front , 1 - k ) );
       
       kArray[ i * width + j ] =  1 - k; 
       
     }
   }
   return resultPixels;
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


