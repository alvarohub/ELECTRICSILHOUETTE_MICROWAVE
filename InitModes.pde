void InitModes() {
   
  rangeInteractionFactor=1.3;
  rangeScaling=1;
  
//Current number of particles:
numberBalls=200;  

drawInteractionMode=2;
  
// ball representation mode:
codegraphic=0;  

 showImage=false;

 imageTest=true; // for testing without webcam
  
// borders mode ('v' to toggle):
int borderMode=0; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface

// gravity:
gravityMode=false;

// SILHOUETTE EFFECTS:   ----------

showSilhouette=true;

// couronne autour de la silhouette (toggle avec 'B'):
hairCouronneMode=false;

// solar "magnetic outbursts":
solarOutburstMode=false;

// orientation hairstyle
senseHair=-1;
reflowParticle=1;

// --------------------------------

//Charge effect mode (particle's charge will affect their behaviour)
chargeMode=false; 

// sound floor mode:
soundFloorMode=false;
// position of the sound wave line:
lineSoundY=height-60;
    
// Silhouette parameters:
//boltMaxCount=60;
indexBoltOrigin=0; //start on edge 0 
     
rotationMode=false;
rendering3DMode=false;

// background:
refreshScreenCLEAR=false;

//Sound parameters:
harmonicMode=false;
soundGain=1; // to control the sensibility of the microphone input (actually, the currentSoundIntensity). Controlled by keys : and ]
     
 // INITIAL MODE (copied F1 mode code on keyPressed):
  plusElong=0;
    rangeInteractionFactor=1.3;
  rangeScaling=1;
    soundGain=1;
     harmonicMode=false;
    drawInteractionMode=0;
   numberBalls=30;  
   codegraphic=0;  
 showImage=false;
imageTest=false; // for testing without webcam
borderMode=0; // 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
gravityMode=false;
showSilhouette=true;
hairCouronneMode=true;
solarOutburstMode=true;
senseHair=-1;
reflowParticle=1;
chargeMode=false; 
soundFloorMode=false; 
     
     
}
