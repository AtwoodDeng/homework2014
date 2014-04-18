/**
 * Background Subtraction 
 * by Golan Levin. 
 *
 * Detect the presence of people and objects in the frame using a simple
 * background-subtraction technique. To initialize the background, press a key.
 */


import processing.video.*;

int numPixels;
int[] backgroundPixels;
Capture video;
Boolean ifStart=false;

void setup() {
  size(640, 480); 
  
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
  //if not start game
  ifStart=false;
}

void draw() {
  if (video.available()) {
    video.read(); // Read a new video frame
    video.loadPixels(); // Make the pixels of video available
    // Difference between the current frame and the stored background
    int presenceSum = 0;
    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      // Fetch the current color in that location, and also the color
      // of the background in that spot
      color currColor = video.pixels[i];
      color bkgdColor = backgroundPixels[i];
      /*  // Extract the red, green, and blue components of the current pixel's color
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
      
      // Add these differences to the running tally
      presenceSum += diffR + diffG + diffB; */
      
      // Render the difference image to the screen
      //if ( getSpaceAngle(currColor, bkgdColor) >= 1e-7 )
         //println( "space angle " + getSpaceAngle(currColor, bkgdColor) );
      if ( getSpaceAngle(currColor, bkgdColor) >= 0.10 && ifStart ) {
        pixels[i] = 0x00000000;
      } else {
        //pixels[i] = 0xFF000000 | (currR << 16) | (currG << 8) | currB;
        pixels[i] = currColor;
      }
      // The following line does the same thing much faster, but is more technical
      //pixels[i] = 0xFF000000 | (diffR << 16) | (diffG << 8) | diffB;
    }
    updatePixels(); // Notify that the pixels[] array has changed
    // println(presenceSum); // Print out the total amount of movement
  }
}

double getSpaceAngle( color currColor , color bkgdColor ) {
      // Extract the red, green, and blue components of the current pixel's color
      int currR = (currColor >> 16) & 0xFF;
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF; 
      // normalize
      double currSum = Math.sqrt( 1.0 * currR * currR
                          + 1.0 * currG * currG
                          + 1.0 * currB * currB ) +1;
      double dcurrR = 1.0 * currR / currSum;
      double dcurrG = 1.0 * currG / currSum;
      double dcurrB = 1.0 * currB / currSum;
      // Extract the red, green, and blue components of the background pixel's color
      int bkgdR = (bkgdColor >> 16) & 0xFF;
      int bkgdG = (bkgdColor >> 8) & 0xFF;
      int bkgdB = bkgdColor & 0xFF; 
      // normalize
      double bkgdSum = Math.sqrt( 1.0 * bkgdR * bkgdR
                           + 1.0 * bkgdG * bkgdG
                           + 1.0 * bkgdB * bkgdB)+1;
      
      double dbkgdR = 1.0 * bkgdR / bkgdSum;
      double dbkgdG = 1.0 * bkgdG / bkgdSum;
      double dbkgdB = 1.0 * bkgdB / bkgdSum;  
      
      double diffR = dcurrR - dbkgdR;
      double diffG = dcurrG - dbkgdG;
      double diffB = dcurrB - dbkgdB;
        
      return Math.sqrt( 1.0 * diffR * diffR
                        + 1.0 * diffG * diffG 
                        + 1.0 * diffB * diffB );
}

// When a key is pressed, capture the background image into the backgroundPixels
// buffer, by copying each of the current frame's pixels into it.
void keyPressed() {
  video.loadPixels();
  arraycopy(video.pixels, backgroundPixels);
  ifStart = true;
}
