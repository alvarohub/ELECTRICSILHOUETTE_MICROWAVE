// cafetiereMan.pde
// (c) Alvaro Cassinelli, using Processing and BlobDetection library 
// Description: program used for Nana Hari performance, on the 22.12.2007 with Stephane Perrin. 
//              Hundreds of "particles" are inside the body of the performer, and they are "heated" by the sound leve. 
//              They may escape the silhouette if their energy is large enough. When the particle is outside the screen, it will 
//              reappear centered on the silhouette glob. 
// VERSIONS -----------------------------------------------------------------------------------------------------------------------------------
// *VER 18.12.2007: Collision with the silouhette is given by a repulsive "electostatic" force to a set of silhouette points. 
//                   It may be long to calculate, so we can reduce this by onl considering neighbouring silhouette. 
//                   Other ways: crossing of a line of a specific color (use m.globPixels), or bounce when the ball is too close to ANY of the silhouette points, 
//                   (the speed should be "reflected" by the closest silhouette segment... too complicated!? 
//                   The radius of each ball will depend on the noise level (directly proportional or inversely proportional), so when the particles 
//                   are "small" they can pass trough the silouhette.
//                   A boolean variable "insideSilhouette" will indicate if the ball in inside or outside the silouhette. 
//                   Also, if I have time I would like to create a "comete tail", in the opposite direction of the glob center. 
// TO DO (next versions): - treat only the largest glob
// *VER 23.12.2007: use opengl (much faster, but artifacts). Also, start thinking about 3D rotations, and perspective transformations of the 
//                  silhouette using openGL library (rotate commands cannot be used with P2D or JAVA2D).
//                  Add perhaps a THIRD COORDINATE for the particles? (and change their z speed when there is collision with the silhouette), and also add SPIN
//
//IMPORTANT COMMENTS:
//  * Problems with the Firewire webcam when using OpenGL library and "IIDC FireWire Video" (throw exception): one "solution" is to open Photo Booth,
//    while the firewire is DISCONNECTED, so that the PhotoBooth program will use the built-in camera; while it is working, 
//    reconnect the Firewire camera, and run the processing sketch (with the line: cam = new Capture(this, 2*xblob, 2*yblob, "IIDC FireWire Video", 15) in the setup). 
//    It should work, and for efficiency, one can close the PhotoBooth program. The operation has to be done each time I run the sketch!! not so practical, but it works. 
// =============================================================================================================================================

boolean wholeKeyboardActive=true; // to avoid touching things by mistake (when true, only the functions are active, from F1 to F8)

String s=  "FaceTime HD Camera"; //"IIDC FireWire Video";//USB Video Class Video"; // Ex: "DV Video", "IIDC FireWire Video", "USB Video Class Video",  "Logitech QuickCam Zoom-WDM"
//String s= "USB Video Class Video";
boolean withCamera=true; // this is to be able to run the program on a computer without camera.
boolean withSound=false;//true;
boolean withHearing=false;//true;

boolean withArduino=false;//true;  // this is to be able to run the program on a computer without the Arduino microcontroller board.

boolean viscosityMode=true;
boolean soundBorder=false;
float lastPlayTime, PlayInterval=0; // in milliseconds, is the minimum interval that has to pass between two notes sent to midi

boolean silhouetteDetection_Mode=true;
boolean detectMask=false; // false for detecting black
float thresh=0.3f; 
float memoryThreshold=thresh;

// Libraries: 
import processing.opengl.*;
import javax.media.opengl.*;

import krister.Ess.*;

import processing.serial.*;

//Using blob detection library instead of JMyron:
import processing.video.*;
import blobDetection.*;
import promidi.*;

MidiIO midiIO;
MidiOut midiOut;
//int[] gamme={67, 69, 72,74,77};
int[] gamme={70, 72, 75,77,79};

// Serial communication (with bluetooth mask) =====================================
Serial port;
int incomingByte = -1;	// for incoming serial data
String inString=""; // to store ASCII codes of decimal representation of values received on the serial port

// The commands from the computer to the microcontroller:
int READ_ALL_RANGE_DATA=97; // code for 'a'
int READ_ACCELEROMETER=98; // code for 'b'
int START_CONTINUOUS_SENDING=99; // code for 'c' - this puts the headband in continuous sending mode (no handshake) and make it to start sending
int STOP_CONTINUOUS_SENDING=100; // code for 'd' (go back to handshake mode)
int DISCONNECT_BT=126; // code for '~' (disconnect bluetooth in the mask)

// The commands from the microcontroller on the mask, to the computer (running processing):
// A,B, C... the separators for data from sensors can be seen as commands composed of data and the order of storing this data in a corresponding variable. 
int STORE_ACCELERATION=91; // this is just like the A, B, C... separators: it's a command telling the computer what to do 
// with the raw data received and stored in the inString array. 
int SET_GRAPHIC_MODE=128; // this basically mean: use the range data stored in the computer to reset the graphic mode.

// Communication protocol:
boolean handshake_flag=true; // without handshake, a delay in the main loop in the headband microcontroller code is mandatory; however, it gives the best performances (almost 20Hz)
boolean canTalk=true; // useful when handshake_flag==true
int TASK_COMPLETED=64; // this means completition of the received command, enabling the other partner to send requests again (=64, the ASCII code for '@')
// REM: separators are: "A", "B"... "Z"
// A packet is as follows: 1A4B...3Z (in fact, we stop at F because there are only 5 sensors). 
// The number correspond to the number of leds to switch on or off, and goes from 0 to 9 (but can be more)

// Bluetooth connectivity:
String remoteAddress = "0711080E3824"; // Address of the remote BT radio on the HAPTIC MASK (rem: bluesmirf headband "000666014B69")
// REM: - the address of the bluetooth module on the MASK:     0711080E3824 
//      - for the bluetooth module on the PC, the address is:  0A02080F2F08 
//boolean connected = false;      // whether you're connected or not (this works and must be tested regardless if this is SLAVE or MASTER)
//boolean neverConnectedBefore=true; // to be reset each time we lost connection

//TEST (no config bluetooth):
boolean connected = true;      // whether you're connected or not (this works and must be tested regardless if this is SLAVE or MASTER)
boolean neverConnectedBefore=true; // to be reset each time we lost connection


long lastConnectTry;         // milliseconds elapsed since the last connection attempt
long connectTimeout = 5000;  // milliseconds to wait between connection attempts
// In fact, if this is the headband microcontroller code, then we may leave it always as slave, and make no attempt to connect. 
// I will use a boolean variable for this, so we can test both codes very easily:
boolean isThisServer=false;// if this is NOT the server, it is then the client and WILL ATTEMPT THE CONNECTION, otherwise it will be set in server mode each
// time it looses connection. 

// Discrete data from rangefinders in the mask:
int numModules=5; // total number of Modules (sensor/vibrator) distributed on the mask
int[] readSerialValue=new int[numModules]; // storage for the values read from the serial port (sent by the headband)

// Also, data from an accelerometer:
float accelerometerData;
long lastRequestAccelerometerData;
long periodRequestAccelerometerData=60; // in milliseconds, is the period at wich the computer issues a command to acquire accelerometer data from the mask

// continuous data from accelerometers (not used?):
// Related global variables fx and fy to avoid reading the
// accelerometer data for each particle:
float globalFx, globalFy,thirdAxis;
//===================================================================================
   
int deleteCounter=0;
int maxDeleteCounter=5;

// auxiliary (global) variable affecting the size of all the objects:
float plusElong=2;

int indexRadarPoint=0;

float strokeNorm=0;
int currentCollisionNumber;
float averageCollision=0;
int averagingCycles=3; // compute average every averagingCyles frames...
int counterAveraging=0;
int sumCollisions=0;
int pitchCollision;// to produce the pitch of the sound as a function of the number of collisions
int midi_velocity=70;

int framecounter=0;

// refresh screen mode:
boolean refreshScreenCLEAR=true;


// =========  MODES:  ================
// Program modes:

 int drawInteractionMode=1; // rem: 0 is for no display, 1 for straight lines, and 2 for splines
 
 boolean allTailsMode=false;

 boolean particleInteractionMode=true;

 boolean showSilhouette=true;
 
 boolean showImage=true;

 boolean imageTest=true; // for testing without webcam

boolean rotationMode=false;

int codegraphic=5; // codes for changing the graphics

boolean rendering3DMode=false;

// borders mode ('v' to toggle):
int borderMode=0; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface

// gravity:
boolean gravityMode=false;

// sound floor mode:
boolean soundFloorMode=false;

// couronne autour de la silhouette (toggle avec 'B'):
boolean hairCouronneMode=false;

// solar "magnetic outbursts":
boolean solarOutburstMode=true;

// orientation hairstyle
int senseHair=-1;

//orientation particle reflow with respect to the silhouette:
int reflowParticle=1;

boolean discretizeDirections=false;

boolean chargeMode=false; // when true (in the future we can have more than two levels, even "flavours"), the particle's charge will affect their behaviour

float repulsionParticle=113000; // inter-particle replusion force
float rangeInteractionFactor=1.3; // at rangeInteraction*rangeInteractionFactor, the force CHANGES SIGN (see classBall interparticle computation)
float rangeScaling=3.4;
  
//Sound parameters:
boolean harmonicMode=false;
float lineSoundY; // coordinate y of the line representing thne sound buffer
float soundGain=1; // to control the sensibility of the microphone input (actually, the currentSoundIntensity). Controlled by keys : and ]


// Silhouette parameters:
int maxStrokeSize=6; // size of silhouette and light bolts (controlled by h/H)
int boltCounter=0; // for changing the lighting bolt trajectory after boltMaxCount traces.
int boltMaxCount=50;
int indexBoltOrigin;

// The ARRAY of particles:
int maxNumParticles=2000;
int numberBalls=200;
// ===============================

Capture cam; // camera object to grasp images 
 // size of image grasped by camera:
int xcam, ycam;
PImage camtest;

BlobDetection theBlobDetection; //the blob object
Blob currentBlob; // the current treated blob (if any)
PImage imgSmall,imgSmallWhiteBorders; // small image that wil lbe used to detect blobs
boolean newFrame=false;

classHairStyle hairStyle;

int xblob, yblob; // size of the captured and processed image
float ximFactorDisp, yimFactorDisp, xFactorDisp, yFactorDisp; //factor to adjust captured coordinates to displaying coordinates (from image to display and blob to display resp.)
int stepBorder=1; // this is an important parameter: it will give the length of the silhouette segments, and then it will change the
                  // total number of silhouette points!

int[][][] listVertex; // global variable to store the number of vertices. ATTN: we don't know the dimension!!! but this is Java... If there is an 
// error, it is always possible to instantiate the list by: int[][][] listVertex = blob.globEdgePoints(stepBorder), and then using another pointer to handle the data...
int[][] listGlobCenters; // global variable to store the glob centers (same comment than listVertex)

// The ARRAY of particles:
//int maxNumParticles=1000;
//int numberBalls=200;
classBall[] ball=new classBall[maxNumParticles];

PImage imageSpriteParticle; // to load (for rendering particles using "sprites" in 2D mode only..)
PImage imageSpritePoil; // to load the image-based hair

boolean insideSilhouette=true;
float repulsionFactorSilhouette=7000;//19500; // 8000 looks ok for inverse square force
float closeRangeSilhouette=25;//25; //30 for inverse force looks ok (quite readcive) // 80 for linear; 50 for electrostatic; 


//sound:
int bufferSize;
int steps;
float limitDiff;
int numAverages=32;
//float myDamp=.1f;
float maxLimit,minLimit;
//FFT myFFT;
//float percent;
float instantSoundLevel;
AudioInput myInput;

// timer for sending sound data to arduino:
long lastSentSoundLevel;
long periodSendSoundLevel=150; // in milliseconds, period to send sound level data to arduino in mask

// =======================================================================================================================================
//                                                    setup()
// =======================================================================================================================================
/*
public void init() {
 frame.dispose();
 frame.setUndecorated(true);
super.init(); 
}
*/



void setup(){
  
println(Capture.list()); // if I put this AFTER size(...), things freeze!!!

  //size(640,480);
 // size(screen.width*4/5,screen.height*4/5);
   //size(screen.width,screen.height);
   // JAVA2D: the default. All cameras seems to work too... only pb: slow and cannot do 3D.
   
    //size(screen.width,screen.height,OPENGL);//OPENGL); P3D
   
   // Make the window equal to the size of projector:
   // size(1024, 768,OPENGL);
   // If using non-mirrored screens, make a shift:
   //frame.setLocation(1440,0); // decaler de la width the l'ordinateur (rem: ECRANS NON MIRRORED).
   // frame.setLocation(320,0); // decaler de la width the l'ordinateur (rem: ECRANS NON MIRRORED).
   
   // ... or on the screen:
  size(displayWidth, displayHeight); //screen.width,screen.height,OPENGL);
  //size(640, 480, OPENGL);
  
   //size(640,480,OPENGL); 
   // size(1024,768,OPENGL); 
    // REM: using OPENGL everything is way faster (if accelerating graphic card), but sometimes there are artifacts, and some things does not work, for instance strokeCap and strokeJoin)
    // Also, only the powerbook camera works, not my firewire camera!!!
    //REM: is it possible (but not recommended) to directly issue opengl commands (must first get a JOGL opengl object, then do for instace antialising: glHint(GL_LINE_SMOOTH_HINT, GL_NICEST))
    // REM: when using P3D, smooth function seems inaccesible; also, the program freezes at the start, when prompting to accept terms of Mandolane (for midi output)
    
 //GL gl = ((PGraphicsOpenGL)g).gl;
 //gl.glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
  // smoothing when using opengl:
     //hint(DISABLE_OPENGL_2X_SMOOTH);
     noSmooth();
 
 // Sound input, for analysis:
  Ess.start(this); // Start Ess
  // Load "test.aif" into a new AudioChannel, file must be in the "data" folder
  // myChannel = new AudioChannel("test.aif");
  // myChannel.play(Ess.FOREVER);
  // set up our AudioInput
  bufferSize=512;
  myInput=new AudioInput(bufferSize);
 // set up our FFT
  //myFFT=new FFT(bufferSize*2);
  //myFFT.equalizer(true);
  // set up our FFT normalization/dampening
  //minLimit=.005;
  //maxLimit=.05;
  //myFFT.limits(minLimit,maxLimit);
  //myFFT.damp(myDamp);
  //myFFT.averages(numAverages);
  // get the number of bins per average 
  steps=bufferSize/numAverages;
  // get the distance of travel between minimum and maximum limits
  limitDiff=maxLimit-minLimit;
  if (withHearing==true) myInput.start();
  
  lineSoundY=height-60;
 
 // WEBCAM: ------------------------------------------------ 
 // size of image grasped by camera:
 xcam=640;//320;//160; //80 
 ycam=480;//int(1.0*xcam/width*height); //120; //60;
  // Capture image object:
  if (withCamera==true) {
   //println(Capture.list());
  //String s= "USB Video Class Video"; // Ex: "DV Video", "IIDC FireWire Video", "USB Video Class Video",  "Logitech QuickCam Zoom-WDM"
 cam = new Capture(this, xcam, ycam, s, 15);
 //cam.settings();
  }
 // for test:
 camtest = loadImage("contourtest.jpg");//"skullH.jpg");//"contourtest.jpg");//"Shadow.jpg"); // for tests
 //camtest = loadImage("IMG_2497b.jpg");
 
 // Microcontroller board: 
 if (withArduino==true) {
  // Check the serial port available on this computer:
  println("List of serial ports: "); 
  port.list();
 // Open the (convenient) serial port:
// port = new Serial(this, "COM3", 9600); // on my PC
 //port = new Serial(this, "/dev/tty.ARDUINOBT-BluetoothSeri-1", 115200); // on my MAC (rem: Arduino Bluetooth is set to 115200 baud
 port = new Serial(this, "/dev/tty.usbserial-A6005u3P", 57600); 
 port.clear();

 // clear storage arrays: 
   for (int i=0; i<5; i++) {
    readSerialValue[i]=0;
  }
   inString=""; // reset the string counter so we can start another number

  // set the trigger for the serialEvent function: callback to this function when the buffer receives a carriage return:
  //serialPort.bufferUntil(10); // 10 is the ASCII code of the carriage return.
  
  // ATTEMPT CONNECTION to the mask (if this is the client):
  //  if (isThisServer==true) BTSetSERVER(); else BTConnectCLIENT();  
 }
 
//Size of imgSmall which will be sent to detection (equal or in general SMALLER copy of the cam frame!!!):
 xblob=320 ;//160; //80 
 yblob=240;//int(1.0*xblob/width*height); //120; //60;
imgSmall = new PImage(xblob,yblob); // smaller image where the blob detection will be performed:
imgSmallWhiteBorders=new PImage(xblob,yblob);;
theBlobDetection = new BlobDetection(imgSmallWhiteBorders.width, imgSmallWhiteBorders.height);
BlobDetection.setConstants(10,4000,15000); // (max number of blobs detected, max number of edges/blob, max number of triangles/blob)
                                            // REM: the max number of blobs detected should be large enough to enables detection of the largest one, which is not necessarily the first one detected!!
theBlobDetection.setPosDiscrimination(detectMask); // true for bright. false for dark
theBlobDetection.setThreshold(thresh);//float thresh=0.18f; 
//theBlobDetection.computeTriangles();//Compute and store triangle information. REM: ackward implementation: triangles that are iside the bounding box of a blob are considered those belonging to that blob...
theBlobDetection.activeCustomFilter(this); // a call to this will activate event generation each time a new blob is detected, and call to custom function boolean newBlobDetectedEvent(Blob b)
                                             // REM: this can be used for discarding small blobs, but also for TRACKING a detected blob...

// the array of hair stems, with its methods to create the hairs from the silhouette, and drawing, etc. 
hairStyle=new classHairStyle(4000); // this number must be equal to the max number of edges/blob, even if not all the edges will have hairs...

// factor for displaying: 
//from image to display:
ximFactorDisp=1.0*width/imgSmall.width; yimFactorDisp=1.0*height/imgSmall.height; 
//from blob to display:
xFactorDisp=width;  yFactorDisp=height; // with blobDetection library (normalized coordinates)
  
  colorMode(RGB,255);
  rectMode(CENTER);
  ellipseMode(CENTER);
  smooth();
  noStroke();
  
  //Midi related:
  //get an instance of MidiIO
  midiIO = MidiIO.getInstance(this);
  //print a list with all available devices
  midiIO.printDevices();
  //open an midiout using the first device and the first channel
  midiOut = midiIO.getMidiOut(0,0); // garage band semble ne pas pouvoir gerer plus d'un channel a la fois
  
  // Ball SPRITE instantiation: 
  imageSpriteParticle=new PImage(64,64,ARGB);
  // (a) load it:
  imageSpriteParticle=loadImage("sirius.jpg");//bolablanca.jpg");//p2.jpg");//sirius.jpg");
  // with brightness to alpha conversion?:
  brightToAlpha(imageSpriteParticle);
  // (b) or generate it:
  /*
   imageSpriteParticle.loadPixels();
  for (int x=0; x<imageSpriteParticle.width;x++) {
     for (int y=0; y<imageSpriteParticle.height;y++) {
       float dis=(x-1.0*imageSpriteParticle.width/2)*(x-1.0*imageSpriteParticle.width/2)+(y-1.0*imageSpriteParticle.height/2)*(y-1.0*imageSpriteParticle.height/2);
       float bri=255*exp(-dis/100);
       imageSpriteParticle.pixels[x+y*imageSpriteParticle.width]=color(bri,bri,bri,bri);
     }
  }
  imageSpriteParticle.updatePixels();
  */
 
 imageSpritePoil=loadImage("poilinvrot.jpg");//"poilinv.jpg");
  brightToAlpha(imageSpritePoil);
    
  
  //instantiate ALL the particles, one by one, with different positions, radius and masses 
  // instantiation of the balls: NEEDS TO RUN the blob detection once, and find the largest blob!!
  // ... too complicated for the time being. Let's start randomly on the screen:
     for (int i=0; i<maxNumParticles; i++) { // create the particles for the MAX number of particles
     //REM:  constructor classBall(int particleIndex,float initX, float initY, float initVX, float initVY, float initMass, float initRadius, float charge, PImage spriteParticle)
   //   ball[i]=new classBall(i, width/2,height/2, random(-6000,6000), random(-6000,6000),  random(0.00002, 0.00001), random(5, 30),  2*floor(random(0,2))-1,imageSpriteParticle); 
   ball[i]=new classBall(i, random(1,width-1),random(1,width-1), random(-6000,6000), random(-6000,6000),  random(0.00002, 0.00001), random(5, 30),  2*floor(random(0,2))-1,imageSpriteParticle); 
   //ball[i]=new classBall(i, width/2,height/2, random(-6000,6000), random(-6000,6000),  0.000015, 6, 1,imageSpriteParticle); 
    ball[i].silentMode=!withSound; // 
 }
     
     // Initialization of program modes:
     InitModes();
     
     frameRate(60);

    // initialization period for sending sound level (to control leds on wisker)
      lastSentSoundLevel=millis();
      
    // initialization timer for requesting accelerometer data from arduino:
     lastRequestAccelerometerData=millis();
}


int convertVumeter5(float soundlevel) {
  // rem: typical sound level from 0.001 (silence) to 0.5 (default sensitiveness) when shouting, or more when changing sensitiveness (up to 1.3 or something like that)
 // println(soundlevel);
 // the sound level must be converted ASCII 0 to 5 (num of leds to be activated in the light-wisker):
 int numLeds=constrain(int(100.0*soundlevel),0,5);
 //if (soundLevel<) numLeds=0;
 // .. to calibrate
  return(numLeds);
}


  // ***** change of modes or interaction forces as a function of bluetooth data (TEST!):
void changeGraphicModeFromRangers() {
  for (int i=0; i<5; i++)
    {
      //if (readSerialValue[i]>4) codegraphic=i;
      //println(readSerialValue[i]);
    }
    
    // number particles:
   // println(readSerialValue[3]);
    if (readSerialValue[3]>2)  numberBalls=constrain((readSerialValue[3]-3)*70,3,500);  
    
    // ranger on mouth, right, changes elong:
    
     if (readSerialValue[3]>2) plusElong=constrain(1+readSerialValue[0]*20,0,200);
      
    // if (readSerialValue[1]>5) silhouetteDetection_Mode=!silhouetteDetection_Mode; 
     
     if (readSerialValue[2]>5) {
      solarOutburstMode=!solarOutburstMode;
       showSilhouette=!showSilhouette;
     }
   }
   
// =======================================================================================================================================
//                                                   draw()
// =======================================================================================================================================
void draw(){
  framecounter++;
  
   int i,j,k;
   
   // DATA to and from serial port (bluetooth) =============================================================================================
   if (withArduino==true) {
   
      if (handshake_flag==false) canTalk=true;
       
       //(a) Process data flow from microcontroller to computer (including data from the bluetooth protocol!):
       if (port.available() > 0) {
          handleSerial();
       }
       
       //(b) from computer to microcontroller (commands that can include "data"):
       // Rem: of course, only if connected (but canTalk will be FALSE if not, unless handshale was false, so it's better to double check)
      if (connected) {
       
        // Periodic accelerometer data request:
        if ((millis() - lastRequestAccelerometerData)> periodRequestAccelerometerData) { //read rangefinders data (can be read slowly):
          port.write(READ_ACCELEROMETER); 
          lastRequestAccelerometerData=millis();
        canTalk=false;  
       }
       
       // Periodic updating of light wiskers:
       if (millis() - lastSentSoundLevel> periodSendSoundLevel) {
         //port.write(48+floor(2.5+5.2*cos(1.0*framecounter/10)));
         port.write(48+convertVumeter5(instantSoundLevel));
        lastSentSoundLevel=millis();
       } 
       
       // port.write(READ_ALL_RANGE_DATA);// not used anymore: the microcontroller will send a COMMAND to the computer 
       
       // .. other commands here
       
      } 
     
    //  ======== THIS NEEDS REVISION ========================================
    /*
   // (1) In case of no handshake, send the FIRST time the boards connect a unique command to the headband: start continuous sending.
  // the headband will go in no-handshake mode, and start sending packets. 
  if ((neverConnectedBefore==true)&&(connected==true)&&(handshake_flag==false)) {
    neverConnectedBefore=false;
    port.write(START_CONTINUOUS_SENDING);
    println("Sent 'START CONTINUOUS SENDING' message");
  }
  */
 // =========================================================================
  
  // (4) If the board is not connected and connectTimeout milliseconds have passed in that state,
  // make an attempt to connect to the radio in the headband if this program is running as CLIENT:
  // (rem: when connection fails, bluetooth send a message NO CARRIER or NO ANSWER after a little while <5 sec?)
  if ((isThisServer==false)&&(!connected)&&(millis() - lastConnectTry > connectTimeout)) {
    BTConnectCLIENT();
    lastConnectTry = millis();
  }
  
   } // end with-arduino mode
 //========================================================================================================
 
 
   
   boltCounter++;
   //println(boltCounter);

  //println(percent); // this is the average sound level, with "memory"  

//RANDOM THRESHOLD (lighting bolt effect):
  theBlobDetection.setThreshold(constrain(thresh+random(-.02,+.02),0,1)); //by varying the threshold randomly, we get "zig-zag" lighting effects... 
 //theBlobDetection.setThreshold(constrain(thresh,0,1)); //by varying the threshold randomly, we get "zig-zag" lighting effects... 


  // A) INPUT (get all the interaction data) ---------------------------------------------------------------------------------------- 
  
  // From the Arduino bluetooth:
  // send a request to read sensor data (only if we "can talk" again, because we already diggested the complete answer from the microcontroller!
  // if (can_Talk==true) {
  //  can_Talk=false;
  //  serialPort.write(10); // just send anything (here a carriage return...)
  // }
  
  // From the image: get list of vertices and globs centers, etc:

    // extract a part of the image to do blob detection (faster!):
    if ((imageTest==true)||(withCamera==false)) {
      // IN FACT, in this case the image copy and blob detection could be done only the first time, but by adding it here
      // I will also get a "realistic" (time consuming) cameraless application:
    imgSmall.copy(camtest, 0, 0, camtest.width, camtest.height, 0, 0, imgSmall.width, imgSmall.height);
     // Perform some image processing (blur, threshold...) then do blob detection on the processed image
    
    // Add white borders to avoid dark blobs that touch the border?
    whiteBorders(imgSmall,2, detectMask); // (second parameter is border thickness, third is for black or white - flase means white borders)
    
    fastblur(imgSmall, 2, imgSmallWhiteBorders); //REM: if radius<1, fastBlur does nothing (radius: 0,1,2,...)
    
    theBlobDetection.computeBlobs(imgSmallWhiteBorders.pixels);
   // println("number of blobs:"+theBlobDetection.getBlobNb());
    }  else if (newFrame){
    newFrame=false;// take image from camera 
    
    //imgSmall.copy(cam, 0, 0, cam.width, cam.height, 0, 0, imgSmall.width, imgSmall.height);
    // Perform some image processing (blur, threshold...) then do blob detection on the processed image:
   
    // Add white borders to avoid dark blobs that touch the border?
    //whiteBorders(imgSmall,2, detectMask); // (second parameter is border thickness, third is for black or white - flase means white borders)
    
   // fastblur(imgSmall, 1, imgSmallWhiteBorders); //REM: if radius<1, fastBlur does nothing (radius: 0,1,2,...)
    imgSmallWhiteBorders.copy(cam, 0, 0, cam.width, cam.height, 0, 0, imgSmall.width, imgSmall.height);
     
     // Add white borders to avoid dark blobs that touch the border?
    whiteBorders(imgSmallWhiteBorders,2, detectMask); // (second parameter is border thickness, third is for black or white - flase means white borders)
    
     
    theBlobDetection.computeBlobs(imgSmallWhiteBorders.pixels);
   // println("number of blobs:"+theBlobDetection.getBlobNb());
    }


  
  // detect larger blob, and extract information from it:
  currentBlob=findBiggestBlob();
  
  
  // Capture hairStyle:
  if (currentBlob!=null) {
   if (currentBlob.getEdgeNb()>100) hairStyle.makeHairStyle(currentBlob, 3); // second parameter is the "decimation" of the edges to make the hairtyle (every n edges...)
    //println("blob edges: "+currentBlob.getEdgeNb());
  }
  
  // Capture silhouette:
  //listVertex = blob.globEdgePoints(stepBorder); // the parameter is the length of the segments. 
 //Capture Globs:
 // listGlobCenters = blob.globBoxes();// will use globBoxes instead of globCenters() because its seems that there is a problem with the library...
  //println(listGlobCenters.length);
  
 
  // B) UPDATE (update dynamic of graphic objects) --------------------------------------------------------------------------------- 
  // Update ball forces and kinematic parameters:
  // (1) Update forces for each ball:
 
 // (a) FIELD from silhouette, and interparticle forces (must be calculated for EACH particle): 
for(i=0;i<numberBalls;i++){ // loop on all the balls  
  //(a) FIELD from "hair style" (the silhouette in fact):
 if (currentBlob!=null) ball[i].computeHairForceField(hairStyle);
 // (b) interaction:
 ball[i].resetInteractionField(); // this is to prepare optimized calculation of interaction forces
}

 //(b) inter-particles forces (optimized as for 11.11.2009): 
for(i=0;i<numberBalls-1;i++){ // rem: last particle force is updated through the others...
 ball[i].computeField(numberBalls, ball); // the input parameter is the array of particles that generates the force on the current particle (plus itself of course) 
}
// old method:
//updateForces(); // this also calculates the HITS of particles and surface (collisions)
  
  
  // NEW: (manual control better?):
  if (rotationMode==true) rotateX(1.0*currentCollisionNumber/numberBalls*10*PI/3);//random(0,PI/3));
  
  // (2) Update kinematic parameters, as well as (can be done in the same loop that ball-displaying, to optimize speed):
  // ...
  
  
  // C) DISPLAYING  ---------------------------------------------------------------------------------------------------------------- 
  // Clear image:
 // if (deleteCounter%maxDeleteCounter==0) {
 //   deleteCounter=1;
  //background(255); // ...not required if one draws the camera image
  //blurTwo(1);
  //background(0); 
   //background(0,0,21*strokeNorm);
  //} else deleteCounter++;
   
    if (refreshScreenCLEAR==true) {//in particular for rendering3DMode==true 
    background(0);
    } else {
   // another technique based on fading the backgound:
   // (but it does not work with 3d rotations, unless we draw directly into the framebuffer - i.e., instead of using rect, we just superimpose an image with transparency)
   //fill(0,28);
 // fill(0*strokeNorm,20*strokeNorm,40*strokeNorm,28); //change background color as a function of the number of collisions or sound intensity...
  fill(0,0,0,50); 
  noStroke();
  //pushMatrix();
  //translate(0,0,-10);
  rect(width/2,height/2,width,height);//fade background
  //popMatrix();
    }
  
   //global transformation for 3D rendering:
     //global rotation:
     if (mousePressed) {
       if (rendering3DMode==true) {
    rotateY(map(mouseX, 0, width, -PI, PI));
  rotateX(map(mouseY, 0, height, -PI, PI));
       }
     }
 
//Light?      
/* 
   if (codegraphic>7) {// (lightON==true) {
     
     lights();

        // redish point light on the right
  pointLight(150, 0, 50, // Color
             2*width, 0, 100); // Position
       // yellowish point light on the left
  pointLight(255, 255, 100, // Color
             -width, 0, 50); // Position
  // white light from top:
     pointLight(200, 200, 200, // Color
             0, 0, 50); // Position

  // Blue directional light from the left
  directionalLight(20, 10, 255, // Color
                   1, 0, 0); // The x-, y-, z-axis direction
  // Yellow spotlight from the front
  spotLight(255, 255, 109, // Color
            0, 20, -100, // Position
            0, -0.5, -0.5, // Direction
          }
             PI / 2, 15); // Angle, concentration
 */
  
   // Draw what the camera sees:
   if (showImage==true) drawCameraImage();//draw the camera to the screen
  
  // Display silhoutte: 
  if ((currentBlob!=null)&&(showSilhouette==true)) {
    //either use hairStyle method, or global function (or both):
    displaySilhouette(currentBlob,0);
   // hairStyle.displaySampledScalp();
  }
  
  // Display the particles (and computes the total number of collisions)   
  // display the interaction links:
  if (drawInteractionMode!=0)  for (i=0; i<numberBalls; i++) ball[i].drawInteraction(drawInteractionMode, numberBalls,ball);
   
   // Now, treat the balls sequentially:
  currentCollisionNumber=0;
  for (i=0; i<numberBalls; i++) {
    
     // "comet-like" tail:
    if (allTailsMode==true)  ball[i].drawTail();
     
    // displays the ball with index i in the object array:
    ball[i].displayBall(codegraphic);

    // update kinematic variables here to optimize speed?:
    ball[i].updateNewton();
    
    if (ball[i].collision==true) {
       currentCollisionNumber++; 
             //println(numHits);
      if (withSound==true) {
     if (harmonicMode==true) {
        ball[i].playNote(int(constrain(ball[i].normAcc/1000000+20,60,120)),70,100);
     
      // ball[i].playNote(pitchCollision,70,100); // rem: uses the LAST number of collisions.
     }  else {// more "glitchy" sound, not "modulated" by acceleration:
      //ball[i].playNote(120,midi_velocity,60);
     
    // ball[i].playNote(100,int(constrain(ball[i].normAcc/400000+10,60,120)),100);
     
      ball[i].playNote(int(constrain(ball[i].normAcc/400000+30,60,120)),30,80);
      //   ball[i].playNote(pitchCollision+30,70,100); // rem: uses the LAST number of collisions.
     }
      // ball[i].playNote(120,int(constrain(ball[i].normAcc/800000,50,120)),100);
     // ball[i].playNote(80,50,100);
     ball[i].collision=false; 
    }
    }
  }
  
  // Running average:
  if (counterAveraging<averagingCycles) {
  sumCollisions+=currentCollisionNumber;
  counterAveraging++;
  } else {
    averageCollision=1.0*sumCollisions/averagingCycles;
    counterAveraging=0;
    sumCollisions=0;
  }
  // println("Average number collisions / frame: "+averageCollision);//
  strokeNorm=constrain(1.0*currentCollisionNumber/numberBalls*100,0,1); // use currentCollisionNumber to be really REACTIVE!
  pitchCollision=floor(constrain(1.0*averageCollision/numberBalls*1000,30,100));
  // println(pitchCollision);
 // if (1.0*currentCollisionNumber/numberBalls>.1) ball[0].playNote(30,120,1200);

 ball[0].playNote(constrain(int(1.0*averageCollision/numberBalls*600),10,127),120,15);
// ball[0].playNote(100,constrain(int(1.0*currentCollisionNumber/numberBalls*500),0,127),150);


// if (1.0*currentCollisionNumber/numberBalls>.02) midi_velocity=120; else midi_velocity=30;
  midi_velocity=floor(constrain(1.0*currentCollisionNumber/numberBalls/.1*120,30,127));//; else midi_velocity=30;
  
  // display hairs style:
 if ((currentBlob!=null)&&(solarOutburstMode==true))  hairStyle.displaySolarCrown(strokeNorm/120);//instantSoundLevel);//displaySplineExternal();//display(200);
 // !!!!!! REM: perhaps in next version, the electric arc could be launch at the site of the collision with one particle, and go towards the last collision with a negative one on the silouhette!!! 
 /// ===== nice idea!!! ======
  
  //hairStyle.display(255*instantSoundLevel);
  
  //if (hairCouronneMode==true) hairStyle.displayTriangle(instantSoundLevel, color(255,255,255,70));//
  
  if ((currentBlob!=null)&&(hairCouronneMode==true)) {
   // if (showSilhouette==true) // then blueish, as the silouhette:
   //   hairStyle.displaySilhouetteWave(color((1.0-strokeNorm)*155+100, strokeNorm*100,strokeNorm*255,strokeNorm*150));
   //   else // completely white:
      hairStyle.displaySilhouetteWave(color(250,250,250,80)); 
     // hairStyle.displayConnectedHairsBalls();
  }
  
  // display filled silhouette:
  //silhouetteFill(currentBlob);
  
  // Display glob centers:
  //...
  
 // percent=max(0,(myFFT.max-minLimit)/limitDiff); // seems to work a little weird...
  //if (soundFloorMode==true) displaySoundFloor(lineSoundY);
  
  // compute max instant sound level from last sample:
   if (withHearing==true) {
   //instantSoundLevel=0;
   float auxsound=0;
   for (i=0;i<myInput.size;i++) auxsound+=abs(myInput.buffer2[i]);
   instantSoundLevel=.2*instantSoundLevel+.8*auxsound/myInput.size;
   //println(instantSoundLevel);
  // ATTENUATION:
  instantSoundLevel*=soundGain;
   } else { // without "hearing" mode:
    instantSoundLevel=0;
   }
  
  // Display alphanumeric data (for debugging):
  //...
  
 //  blur everything?
   // extract a part of the image to do blob detection (faster!):
   //imgSmall.copy(cam, 0, 0, cam.width, cam.height, 0, 0, imgSmall.width, imgSmall.height);
    // Perform some image processing (blur, threshold...) then do blob detection on the processed image:
    //fastblur(imgSmall, 1, imageBlurred);
    //filter(BLUR, 2);
  //blurTwo(1);
}


// =======================================================================================================================================
//     captureEvent()
// =======================================================================================================================================
void captureEvent(Capture cam)
{
	cam.read();
	newFrame = true;
}


// =======================================================================================================================================
//       newBlobDetectedEvent()
//       Filtering blobs here (discard "little" ones)
// =======================================================================================================================================
boolean newBlobDetectedEvent(Blob b)
{
  int w = (int)(b.w * imgSmall.width);
  int h = (int)(b.h * imgSmall.height);
  if (w >= 20 || h >= 20)
    return true;
  return false;
} 
// =======================================================================================================================================
//         findBiggestBlob()
// =======================================================================================================================================
Blob findBiggestBlob()
{
  Blob biggestBlob = null;
  if ( silhouetteDetection_Mode==true) {
  float surface = 0.0f;
  float surfaceMax = 0.0f;
  Blob b=null;
  for (int i=0;i<theBlobDetection.getBlobNb();i++)
  {
    b = theBlobDetection.getBlob(i);
    surface = b.w * b.h;
    if (surface > surfaceMax)
    {
      surfaceMax=surface;
      biggestBlob = b;
    }
  }
} else {// do nothing
} 
  return biggestBlob; 
}


void drawCameraImage(){
  
  // direct method, using the FULL CAMERA image: (can be time consuming):
  noTint();
  //tint(255,255,255,255);
 // image(cam,0,0,width,height); //blend(cam,0,0,width,height);
  
  // direct method, using the small, blurred image:
 //tint(255,255,255,128);
 noTint();
 //image(imgSmallWhiteBorders,0,0,width,height); //blend(cam,0,0,width,height);
 image(cam,0,0,width,height); //blend(cam,0,0,width,height);
  
  
  // using square or dots:
/*
if (rendering3DMode==true) {
 //noStroke(); 
 noStroke();
 //stroke(0,0,0,120); strokeWeight(1); 
 for (int i=0; i<imgSmall.height; i=i+3) 
    for (int j=0; j<imgSmall.width;j =j+3) {
      //using rectangles:
      fill(imgSmall.pixels[i*imgSmall.width+j],240);
      //rect(j*ximFactorDisp,i*yimFactorDisp,ximFactorDisp,yimFactorDisp);
      
      //in 3d rendering mode:
      pushMatrix();
      translate(j*ximFactorDisp,i*yimFactorDisp);
      //box(ximFactorDisp,yimFactorDisp,10);
      ellipse(0,0,ximFactorDisp,ximFactorDisp); // rem: circular!
      popMatrix();
      
      // using points (cannot work in opengl mode)
     //  stroke(imgSmall.pixels[i*imgSmall.width+j]);strokeWeight(12); 
     //  point(j*ximFactorDisp,i*yimFactorDisp);
    }
}else {
  noStroke(); 
 //stroke(0,0,0,120); strokeWeight(1); 
 for (int i=0; i<imgSmall.height; i=i+3) 
    for (int j=0; j<imgSmall.width;j =j+3) {
      //using rectangles:
      fill(imgSmall.pixels[i*imgSmall.width+j],240);
      rect(j*ximFactorDisp,i*yimFactorDisp,ximFactorDisp,yimFactorDisp);

      // or using points (rem: cannot work in opengl mode)
     //  stroke(imgSmall.pixels[i*imgSmall.width+j]);strokeWeight(12); 
     //  point(j*ximFactorDisp,i*yimFactorDisp);
    }
}
   */
  
   /*
 for (int i=0; i<cam.height; i++) 
    for (int j=0; j<cam.width; j++) {
      fill(cam.pixels[i*cam.width+j]);
      rect(j*width/cam.width,i*height/cam.height,width/cam.width,height/cam.height);
    }
     */
 
  
  // REM: can use also OpenGL:
}

void mousePressed(){
    if (mouseButton == LEFT) {
   //
  } else if (mouseButton == RIGHT) {
  // blob.settings();//click the window to get the settings
  // how to do this using blobDetection library???
  } 
  
}


void updateForces() {
  int i,j,k;
  EdgeVertex eA;
  float auxForcex, auxForcey;
  float vectorNormalx, vectorNormaly;
  boolean collision; //collision with silhouette
  for(i=0;i<numberBalls;i++){ // loop on all the balls
  auxForcex=0; auxForcey=0; // initialize force
  vectorNormalx=0; vectorNormaly=0;
  collision=false;
  // update forces from silhouette (IF there is a silhouette!)
  if (currentBlob!=null) {
   int step=2;//int(random(1,5));
      for(k=0;k<currentBlob.getEdgeNb();k=k+step){ //loop on the silhouette points (better to do in the hairstyle later) 
        eA = currentBlob.getEdgeVertexA(k);
      if (eA !=null) {
      //compute distance from ball to silhouette point:
      float deltax,deltay, auxdist; 
      deltax=ball[i].futureX-eA.x*xFactorDisp;
      deltay=ball[i].futureY-eA.y*yFactorDisp;
      auxdist=max(sqrt(deltax*deltax+deltay*deltay),1);//+ball[i].ballRadius;
     
      // Electrostatic force: time consuming (need to compute 3/2 root). Perhaps simplifying with a force which is inversely propotional to distance?
      // IMPORTANT REMARK: if we use ALL the silhouette points, then the overall force will be ZERO!!! this is GAUSS THEOREM!!
      // So, we will ONLY sum when the particles are CLOSE to the silhouette, by a closeRangeSilhouette:
       
       if (auxdist<closeRangeSilhouette) {
         collision=true; // this could be an object variable, ad used by the object to produce a specific sound for instance:
       ball[i].collision=true;
       ball[i].timeLastCollision=millis();
       //* electrostatic force:
     // float auxConst= 1.0*repulsionFactorSilhouette/pow(auxdist, 3);
      //* simplified force (easy to calculate, and perhaps also better to avoid "sudden infinitudes?") 
      float auxConst=1.0*repulsionFactorSilhouette/pow(auxdist, 2);
     //float auxConst= constrain(1.0*repulsionFactorSilhouette/pow(auxdist, 2),0,5+500*instantSoundLevel);
     // * simplified linear force:
     //float auxConst= 1.0*repulsionFactorSilhouette*(closeRangeSilhouette-auxdist);
     auxForcex+=deltax*auxConst;
     auxForcey+=deltay*auxConst;
     
     // for "reflecting force":
      //vectorNormalx+=deltax;
      //vectorNormaly+=deltay;
      
     // also, damp the speed.. (this is a hack!):
     ball[i].vx0=0.3*ball[i].vx;   ball[i].vy0=0.3*ball[i].vy; 
    
    // Also, change position of silhouette??? (would need to mantain a separate array for the silhouette, that is NOT the one from the capture!):
    // .. to do  (interesting! the silhouette will "inflate"!!!)
    
       } // otherwise the force is 0
       
      }
    }
  }
  // Use normal force:
  ball[i].forceHairX=auxForcex;
  ball[i].forceHairY=auxForcey;
  //println(auxForcex);
  // use "impenetrable wall reflecting force" (calculated force will REFLECT speed):
  /*
  float normNormal=sqrt(vectorNormalx*vectorNormalx+vectorNormaly*vectorNormaly);
  if (normNormal>0) {
  //println(normNormal);
  float ux=vectorNormalx/normNormal, uy=vectorNormaly/normNormal;
   float auxc=(ux*ux-uy*uy);
   float fact=2.01;
   ball[i].fx=(-2*ux*uy*ball[i].vy0-(fact+auxc)*ball[i].vx0)*ball[i].m/ball[i].dt/fact;
   ball[i].fy=(-2*ux*uy*ball[i].vx0+(auxc-fact)*ball[i].vy0)*ball[i].m/ball[i].dt/fact;
  // println(ball[i].fy);
  }
  */
  }
  }

/*
public void audioInputData(AudioInput theInput) {
  myFFT.getSpectrum(myInput);
}
*/

void brightToAlpha(PImage b){ // as in flight404, convert brightness into alpha channel
  b.format = ARGB;
  b.loadPixels();
   for(int i=0; i < b.pixels.length; i++) {
     b.pixels[i] = color(red(b.pixels[i] ),green(b.pixels[i] ),blue(b.pixels[i] ),constrain(brightness(b.pixels[i]),0,255));
   }
   b.updatePixels();
 }
