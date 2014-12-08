void keyPressed() 
{
  // println("key Code: "+keyCode);
  // println("key number: "+key);
   
   // keyboard "security":
    if ((wholeKeyboardActive==false)&&(key!=CODED)) return;
    
  switch(key) {
     //special keys (rem: ENTER is not a coded key???)
    case CODED:
    
      // META MODES: (function keys from F1 to F8):
  if (keyCode==112) {// F1
  silhouetteDetection_Mode=false;
     viscosityMode=false;
    rangeInteractionFactor=1.3;
  rangeScaling=1;
    plusElong=2;
    soundGain=1;
      harmonicMode=false;
    drawInteractionMode=1;
    numberBalls=5;  
   codegraphic=4;  
 showImage=false;
 imageTest=false; // for testing without webcam
 borderMode=0; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
 gravityMode=false;
showSilhouette=false;
hairCouronneMode=false;
solarOutburstMode=false;
senseHair=-1;
reflowParticle=1;
chargeMode=false; 
soundFloorMode=false;
  //
 /* old:
     viscosityMode=false;
    rangeInteractionFactor=1.3;
  rangeScaling=1;
    plusElong=2;
    soundGain=1;
      harmonicMode=false;
    drawInteractionMode=0;
    numberBalls=250;  
   codegraphic=0;  
 showImage=false;
 imageTest=false; // for testing without webcam
 borderMode=0; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
 gravityMode=false;
showSilhouette=false;
hairCouronneMode=false;
solarOutburstMode=false;
senseHair=-1;
reflowParticle=1;
chargeMode=false; 
soundFloorMode=false;
*/
    
    } 
      if (keyCode==113) {// F2
          viscosityMode=false;
    rangeInteractionFactor=1.3;
  rangeScaling=1;
    plusElong=2;
    soundGain=1;
      harmonicMode=false;
    drawInteractionMode=0;
    numberBalls=250;  
   codegraphic=0;  
 showImage=false;
 imageTest=false; // for testing without webcam
 borderMode=0; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
 gravityMode=false;
showSilhouette=false;
hairCouronneMode=false;
solarOutburstMode=false;
senseHair=-1;
reflowParticle=1;
chargeMode=false; 
soundFloorMode=false;
// old :
/*
       viscosityMode=true;
       plusElong=1;
  rangeInteractionFactor=1.3;
  rangeScaling=1;
    soundGain=1;
     harmonicMode=false;
    drawInteractionMode=0;
   numberBalls=230;  
   codegraphic=0;  
 showImage=false;
imageTest=false; // for testing without webcam
borderMode=2; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
gravityMode=false;
showSilhouette=true;
hairCouronneMode=true;
solarOutburstMode=true;
senseHair=-1;
reflowParticle=-1;
chargeMode=false; 
soundFloorMode=false;
    */
    } 
    else if (keyCode==114) {// F3 - "concentric" lines spreading from center
     viscosityMode=false;
     rangeInteractionFactor=1.3;
  rangeScaling=1;
    soundGain=1;
    plusElong=5;
    harmonicMode=true;
    drawInteractionMode=0;
   repulsionParticle=113000;//113000;
   numberBalls=300;  
   codegraphic=3;  
   showImage=false;
   imageTest=false; // for testing without webcam
   borderMode=0; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
   gravityMode=false;
   showSilhouette=false;
   hairCouronneMode=false;
   solarOutburstMode=false;
   senseHair=1; //+1 means inside
   reflowParticle=1;
   chargeMode=false; 
   soundFloorMode=false;
    
    }
    else if (keyCode==115) {// F4 (blue lines)
     viscosityMode=false;
     rangeScaling=1.3;
     rangeInteractionFactor=1.3;
    
    plusElong=5;
    soundGain=2;
     repulsionParticle=113000;//113000;
    harmonicMode=true;
    drawInteractionMode=1; // 1= blue lines
     //Current number of particles:
     numberBalls=200;  
    codegraphic=9; //9 for NO balls  
    showImage=false;
   imageTest=false; // for testing without webcam 
   borderMode=0; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
   gravityMode=true;
   showSilhouette=false;
   hairCouronneMode=false;
   solarOutburstMode=false;
   senseHair=1;
   reflowParticle=1;
   chargeMode=false; 
  soundFloorMode=false;
  
    } 
   else if (keyCode==116) {// F5 (comet-like connections, without gravity nor floor, and no border)
    viscosityMode=false;
   rangeInteractionFactor=1.3;
  rangeScaling=1;
      plusElong=5;
    soundGain=2;
     repulsionParticle=113000;//113000;
    harmonicMode=true;
    drawInteractionMode=2; // 1= blue lines
     //Current number of particles:
     numberBalls=100;  
    codegraphic=9; //9 for NO balls  
   showImage=false;
   imageTest=false; // for testing without webcam 
   borderMode=0; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
   gravityMode=false;
   showSilhouette=false;
   hairCouronneMode=false;
   solarOutburstMode=false;
   senseHair=1;
   reflowParticle=1;
   chargeMode=false; 
  soundFloorMode=false;
    
    } 
    else if (keyCode==117) {// F6 : funcky psychadelic (squres + spikes + solar outburst + charges) 
     viscosityMode=false;
     rangeInteractionFactor=1.3;
  rangeScaling=1;
       plusElong=0;
    soundGain=2;
     repulsionParticle=150000;//113000;
    harmonicMode=true;
    drawInteractionMode=0; // 1= blue lines
     //Current number of particles:
     numberBalls=300;  
    codegraphic=0; //9 for NO balls  
    showImage=false;
   imageTest=false; // for testing without webcam 
   borderMode=0; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
   gravityMode=false;
   showSilhouette=true;
   hairCouronneMode=true;
   solarOutburstMode=true;
   senseHair=-1;
   reflowParticle=-1;
   chargeMode=true; 
  soundFloorMode=false;
    }
    
     else if (keyCode==118) {// F7 : 
      viscosityMode=true;
     rangeInteractionFactor=1;
     rangeScaling=7;
      repulsionParticle=113000;//113000;
      
     plusElong=13;
    soundGain=2;
    
    harmonicMode=false;
    drawInteractionMode=0; // 1= blue lines
     //Current number of particles:
     numberBalls=200;  
    codegraphic=6; //6 means sprites with alpha; 9 for NO balls  
    showImage=false;
   imageTest=false; // for testing without webcam 
   borderMode=1; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
   gravityMode=false;
   showSilhouette=false;
   hairCouronneMode=false;
   solarOutburstMode=false;
   senseHair=1;
   reflowParticle=1;
   chargeMode=false; 
  soundFloorMode=false;
     }
     else if (keyCode==119) { // F8
      viscosityMode=false;
       rangeScaling=6.4;
 rangeInteractionFactor=0.5;
   repulsionParticle=113000;//113000;
   
numberBalls=100;  
drawInteractionMode=2;
 codegraphic=0;  
 showImage=false;
imageTest=false; // for testing without webcam
borderMode=0; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
gravityMode=false;
showSilhouette=true;
hairCouronneMode=false;
solarOutburstMode=false;
senseHair=1;
reflowParticle=1;
chargeMode=false; 
soundFloorMode=false;
lineSoundY=height-60;
indexBoltOrigin=0; //start on edge 0 
rotationMode=false;
rendering3DMode=false;
refreshScreenCLEAR=false;
harmonicMode=false;
soundGain=2; // to control the sensibility of the microphone input (actually, the currentSoundIntensity). Controlled by keys : and ]
 plusElong=0;
    } 
    else if (keyCode==LEFT) {
      thresh=constrain(thresh-0.007f,0,1);
       memoryThreshold=thresh; // backup of current threshold
   theBlobDetection.setThreshold(thresh);//float thresh=0.18f; 
   println(thresh);
     }
    else if (keyCode==RIGHT) {
     thresh=constrain(thresh+0.007f,0,1);
      memoryThreshold=thresh; // backup of current threshold
   theBlobDetection.setThreshold(thresh);//float thresh=0.18f; 
    println(thresh);
      }
     else if (keyCode==UP) { // ACTIVATE silhouette detection
     silhouetteDetection_Mode=true;
   // (old): back to current threshold:
   //  thresh=memoryThreshold;//1.0f;
   //  theBlobDetection.setThreshold(thresh);//float thresh=0.18f; 
    println(thresh);
      }
     else if (keyCode==DOWN) { //deactivate sihluette detection:
      silhouetteDetection_Mode=false;
    // (Old): set threshold to 0 (silhouette, when black, just dissapears):
     // memoryThreshold=thresh; // backup of current threshold
    // thresh=0.0f;
    //theBlobDetection.setThreshold(thresh);//float thresh=0.18f; 
   // println(thresh);
      }  
     else if (keyCode==CONTROL) { // new: change detectMask
        detectMask=!detectMask;//rem: false for detecting black
        theBlobDetection.setPosDiscrimination(detectMask); // true for bright. false for dark
    }
    break;
    
    // ----- non coded keys -----------------
      
    // SNAPSHOT:
    case 'p':
      saveFrame();
    break;
    
    
    case 'c':
    // toggle chargeMode:
       chargeMode=!chargeMode; // INACTIVE for the time being (at least for LOOPLINE performance)
       println("toggled chargeMode");  
    break;
    
    case '=': // cycle between the different interaction modes (rem: 0 means NO drawing anything)
    drawInteractionMode=(drawInteractionMode+1)%3;
    break;
   
    
    case '@':
       refreshScreenCLEAR=!refreshScreenCLEAR; 
   break;
    
    // toggle solar crown arcs:
      case 'n':
    solarOutburstMode=!solarOutburstMode;
   break;
   
   case 'm':
   particleInteractionMode=!particleInteractionMode;
   break;
   
   case 't':
   allTailsMode=!allTailsMode;
   for (int i=0; i<numberBalls; i++) ball[i].tailMode=allTailsMode;
   break;

case 'z': // discretize direction:
discretizeDirections=!discretizeDirections;
break;

case 'x': // viscosity on/off
viscosityMode=!viscosityMode;
break;
   
   case 'g': //toggle gravity and activates bouncing on border:
     gravityMode=!gravityMode;
    // bouncingBorder=true;
   break;
   
   case 'f': // sound floor mode (display sound wave on floor, and give energy to particles when they bounce on the floor):
     soundFloorMode=!soundFloorMode;
    // if soundFloorMode
   break;
     
    // toggle image test / camera:
    case ENTER:
    case RETURN:// windows & Mac!! 
     // OLD: rendering3DMode=!rendering3DMode;
       imageTest=!imageTest;
    break;
    
    // "normal" keys:
    case '0':
   codegraphic=0;
   break;
   
   case '1':
   codegraphic=1;
   break;
   case '!':
   codegraphic=-1;
   break;
   
      case '2':
   codegraphic=2;
   break;
   
      case '3':
   codegraphic=3;
   break;
   
   case '4': // red squares
   codegraphic=4;
   break;
   
    case '5':
   codegraphic=5;
   break;
  
    case '6':
   codegraphic=6;
   break;
    case '7':
   codegraphic=7;
   break;
   
    case '8':
   codegraphic=8;
   break;
   
    case '9':
   codegraphic=9;
   break;
   
   case 'v': //toggle border modes:
   //bouncingBorder=!bouncingBorder;
   borderMode=(borderMode+1)%3; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
   println(borderMode);
   break;
   
    case 's':
    plusElong=constrain(plusElong+1,0,200);
   break;
      case 'S':
     plusElong=constrain(plusElong-1,0,200);
   break;
   
   case 'a': //change type of sound.
     harmonicMode=!harmonicMode;
   break;
   
     case 'l':
     numberBalls=constrain( numberBalls+5,0,maxNumParticles);
   break;
      case 'k':
      numberBalls=constrain( numberBalls-5,0,maxNumParticles);
   break;
   
   // display image from camera:
   case ' ': // toggle image from camera
   showImage=!showImage;
   break;
   
   //silhouette:
    case 'b': // toggle silouhette from camera
   showSilhouette=!showSilhouette;
   break;
   
   case 'B':
   hairCouronneMode=!hairCouronneMode;
   break;
   
   case 'h':
   maxStrokeSize=constrain(maxStrokeSize-1,1,200);
   break;
      
   case 'H':
   maxStrokeSize=constrain(maxStrokeSize+1,1,200);
   break;
   
   
   // RESET BUTTON in case there is some problem:
   case 'r':
   // reinitialize balls, hairstyle:
   for (int i=0; i<ball.length; i++) ball[i].reset();
   hairStyle.reset();
   background(0);
   break;
   
   case 'y': //change sense hair:
   senseHair=-senseHair;
   break;
   
   case 'u': // change reflow particle sense:
   reflowParticle=-reflowParticle;
   break;
   
 
    // control of input sound gain:
    case ':':
     soundGain=constrain(soundGain+.05, 0,5);
    break;
    case ';':
     soundGain=constrain(soundGain-.05, 0,5);
    break;
   
   default:
    
   break;
  
}
}
