class classBall {
  //  Intrinsic variables of the ball: (as public)
  // Again, in Processing, their default value can be set here (at declaration):
  // there is no need to create a "default setting" overloaded contructor
  int particleIndex; // this will be a number to identify the particle (in particular, for calculation of inter-particle interaction forces) 
  float x=width/2, y=height/2; // current position (start the ball in the middle of the screen)
  float x1, y1, futureX, futureY;
  float vx=100, vy=0, vx0=100, vy0=0;
  float ax, ay, normAcc;
  
  // The force fields:
  float forceInteractionX, forceInteractionY; // the force produced by interaction with other particles
  float forceHairX,forceHairY; // this is the FIELD force on the particle (produced by the silhouette interaction for instance...)
  // last, the global force (globalForceX, globalForceY), that will be updated by the microcontroller
 
 float rangeInteraction; // the interaction range (interaction with particles too far away are not computed)
 //float repulsionParticle=113000;
 
  float m=0.01; 
  float dt=0.0002;//0.0003 is GOOD // this is a CRITIC PARAMETER, dynamics change a lot... change with discretion 
  float springFactor=1.0;
  float ballRadius=15;
  float visFactor=0.005;
  boolean collision=false;
  float timeLastCollision=0;
  float timeFreeFall=0; // this is just millis()-timeLastCollision
  float timeFreeFloor=0;
  float timeLastFloorCollision=0;
  float charge=1;
  
  PImage spriteParticle;//=PImage; // must be created in the constructor function, or once and for all OUTSIDE the class and passed it to the object at 
  // intialization (I prefer that, so I can load whatever I want)
  
  int maxTailLength=500; // to record the trajectry and draw it
  int currentTailLength=1; // the actual length of the tail
  boolean tailMode=false;
  float[][] tail; // to record the tail positions ([0...currentTailLength-1][0/1], secod index is for x/y). tail[0][..] is the LATEST postition

  //Sound for the particle:
   boolean silentMode=false;
   Note note;

  // Methods: (as public). These are just the functions in the previsou SimulBall2.pde program,
  // plus a new method, called a CONSTRUCTOR that helps initializing the object:

  // Overloaded constructor with input parameters for initial position, mass (and perhaps speed)
  //REM1 the overloaded contructor is MANDATORY in processing, even if it does not take any parameter
  classBall(int partIndex, float initX, float initY, float mass) {
    particleIndex=partIndex;
    x=initX; 
    y=initY;
     m=mass;
     ballRadius=100000*mass; //we will make the radius is proportional to the mass (same "density" for the balls? no! ;)
     rangeInteraction=ballRadius*10;//10; // in pixels!
    charge= 2*floor(random(0,2))-1;
   //vx=1000; vy=0; vx0=1000; vy0=0;
   
   silentMode=false;
   note = new Note(0,0,0);
   timeLastCollision=0;
   timeFreeFall=millis(); // this is just millis()-timeLastCollision
   timeFreeFloor=0;
   timeLastFloorCollision=millis();
   
    tail=new float[maxTailLength][2];
   currentTailLength=100; // the actual length of the tail
   for (int i=0; i<currentTailLength; i++) {tail[i][0]=x;tail[i][1]=y;}
   tailMode=false;
  }
  
   // Overloaded constructor with input parameters for initial position, SPEED, MASS and RADIUS
  //REM1 the overloaded contructor is MANDATORY in processing, even if it does not take any parameter
  classBall(int partIndex, float initX, float initY, float initVX, float initVY, float initMass, float initRadius, float chargeball, PImage spriteimage) {
    particleIndex=partIndex;
    x=initX; 
    y=initY;
    vx=initVX; vy=initVY; vx0=initVX; vy0=initVY;
    ballRadius=initRadius; //we will make the radius is proportional to the mass (same "density" for the balls? no! ;)
    m=initMass;
     rangeInteraction=90*(0.6+ballRadius/50); // REM: 90 is OK!! ( in pixels )
    charge=chargeball;
    
    silentMode=false;
     note = new Note(0,0,0);
     
       timeLastCollision=0;
   timeFreeFall=millis();
   timeFreeFloor=0;
   timeLastFloorCollision=millis();
   spriteParticle=spriteimage; 
   // convert brightness of the image into pure alpha channel (we can also add color, etc):
   //brightToAlpha(spriteParticle);
   
    tail=new float[maxTailLength][2];
   currentTailLength=200; // the actual length of the tail
   for (int i=0; i<currentTailLength; i++) {tail[i][0]=x;tail[i][1]=y;}
   tailMode=false;
  }

// reset ball data (in case of some problem):
void reset() {
 // viscosityMode=false;
  
   // start the ball in the middle of the screen :
  // x=width/2; y=height/2;
  //x1=x; y1=y;
  //futureX=x; futureY=y;
  // ...or random position: 
  x=random(1,width-1); y=random(1,height-1);
  x1=x; y1=y;
  futureX=x; futureY=y;
  vx= random(-6000,6000); vy= random(-6000,6000); vx0=vx; vy0=vy;
  ax=0; ay=0; normAcc=0;
  forceHairX=0; forceHairY=0;
  m=random(0.00002, 0.00001); 
  //dt=0.0003;
  springFactor=1.0;
  ballRadius=random(5, 30);
  collision=false;
   charge= 2*floor(random(0,2))-1;
   silentMode=false;
  note = new Note(0,0,0);
    timeLastCollision=0;
   timeFreeFall=millis();
  // rangeInteractionFactor=1.3;
  // rangeScaling=1;
}

void resetInteractionField() {
forceInteractionX=0;
forceInteractionY=0;
}

void computeField(int currentNumParticles, classBall[] particleArray) {//compute field with respect to the OTHER particles...
// this will copute the value for forceInteractionX and forceInteractionY
//(rem: by being more smart, the whole computation could take half of the time - using an internal array for storing distances)

// new (11.11.2009): field is reset outside this function, to be able to compute in a more optimal way:
//forceInteractionX=0;
//forceInteractionY=0;

float sign=-1;
float ux, uy, distance;
for (int i=particleIndex+1; i< currentNumParticles; i++) { // NOT particleArray.length, unless ALL the particles are "on"
  
    // compute vector pointing from particleIndex particle to particle i, with norm depending on the space-topology:
     ux=particleArray[i].x-x;
     uy=particleArray[i].y-y;
    if (borderMode==2) { // 2 is for toroidal topology 
        if (ux>1.0*width/2) ux=(ux-1.0*width); else if (ux<-1.0*width/2) ux=(ux+1.0*width);
        if (uy>1.0*height/2) uy=(uy-1.0*height); else if (uy<-1.0*height/2) uy=(uy+1.0*height);
    }
    
    distance=max(sqrt(ux*ux+uy*uy),ballRadius);// this is to avoid singularities
    if (distance<rangeInteraction*rangeScaling) { // otherwise do nothing (interesting: could be the opposite! test that)
    // INTERESTING: make a force that is repulsive at short distance, but attractive at long distances! this will 
    // simulate gravitation+electrical force
    if (distance<rangeInteraction*rangeInteractionFactor) sign=-1.2; else sign=0.4;
    float coulombForce;
    if (chargeMode==true) coulombForce=sign*charge*particleArray[i].charge/(distance*distance)*repulsionParticle; //113000;
    else coulombForce=sign/(distance*distance)*repulsionParticle; //113000;
    // Sound interaction?:
    coulombForce=coulombForce*(.08+400*instantSoundLevel);
     //coulombForce=coulombForce*(10+1-600*instantSoundLevel);
    // then, add components to the interaction force:
    forceInteractionX+=coulombForce*ux/distance;
    forceInteractionY+=coulombForce*uy/distance;
    
    // Also, add force to the particle i:
    particleArray[i].forceInteractionX+=-coulombForce*ux/distance;
    particleArray[i].forceInteractionY+=-coulombForce*uy/distance;
    }
  }
}

void computeFieldOld(int currentNumParticles, classBall[] particleArray) {//compute field with respect to the OTHER particles...
// this will copute the value for forceInteractionX and forceInteractionY
//(rem: by being more smart, the whole computation could take half of the time - using an internal array for storing distances)

forceInteractionX=0;
forceInteractionY=0;

float sign=-1;
float ux, uy, distance;
for (int i=0; i< currentNumParticles; i++) { // NOT particleArray.length, unless ALL the particles are "on"
  if (i!=particleIndex) {
    // compute vector pointing from particleIndex particle to particle i, with norm depending on the space-topology:
     ux=particleArray[i].x-x;
     uy=particleArray[i].y-y;
    if (borderMode==2) { // 2 is for toroidal topolog
        if (ux>1.0*width/2) ux=(ux-1.0*width); else if (ux<-1.0*width/2) ux=(ux+1.0*width);
        if (uy>1.0*height/2) uy=(uy-1.0*height); else if (uy<-1.0*height/2) uy=(uy+1.0*height);
    }
    distance=max(sqrt(ux*ux+uy*uy),ballRadius);// this is to avoid singularities
    if (distance<rangeInteraction*rangeScaling) { // otherwise do nothing (interesting: could be the opposite! test that)
    // INTERESTING: make a force that is repulsive at short distance, but attractive at long distances! this will 
    // simulate gravitation+electrical force
    if (distance<rangeInteraction*rangeInteractionFactor) sign=-1.2; else sign=0.4;
    float coulombForce;
    if (chargeMode==true) coulombForce=sign*charge*particleArray[i].charge/(distance*distance)*repulsionParticle; //113000;
    else coulombForce=sign/(distance*distance)*repulsionParticle; //113000;
    // Sound interaction?:
    coulombForce=coulombForce*(.08+400*instantSoundLevel);
     //coulombForce=coulombForce*(10+1-600*instantSoundLevel);
    // then, add components to the interaction force:
    forceInteractionX+=coulombForce*ux/distance;
    forceInteractionY+=coulombForce*uy/distance;
    }
  }
}
}


void drawInteraction(int mode, int currentNumParticles, classBall[] particleArray){
   float ux, uy;
  for (int i=particleIndex+1; i< currentNumParticles; i++) { // NOT particleArray.length, unless ALL the particles are "on"
 // if (i>particleIndex) { // if possible, put >particleIndex to avoid drawing the lines twice (not possible in "toroidal topology" mode)
   // compute vector pointing from particleIndex particle to particle i:
    ux=particleArray[i].x-x;
    uy=particleArray[i].y-y;
    if (borderMode==2) { // 2 is for toroidal topology
         if (ux>1.0*width/2) ux=(ux-1.0*width); else if (ux<-1.0*width/2) ux=(ux+1.0*width);
        if (uy>1.0*height/2) uy=(uy-1.0*height); else if (uy<-1.0*height/2) uy=(uy+1.0*height);
    }
    float distance=max(sqrt(ux*ux+uy*uy),ballRadius);// this is to avoid singularities
    if (distance<rangeInteraction*1.5) { 
    switch(mode) {
      case 1:// a simple line: 
        noFill();
    stroke(20,20,255*(1-distance/rangeInteraction/10),90); 
    strokeWeight(5*(1-distance/rangeInteraction/2));
    //line(x,y,x+ux, y+uy);
   beginShape(); 
   vertex(x, y);
   vertex(x+ux, y+uy);
   endShape();
    break;
    case 2:
    // or a spline connecting the dots:
   //  stroke(255*(1-distance/rangeInteraction/2),255,255,20); 
      stroke(255,255,255*(1-distance/rangeInteraction/2),60); 
    strokeWeight(4*(1-distance/rangeInteraction/2));
    noFill();
    beginShape(); 
   vertex(x, y);
   bezierVertex(x-vx/300, y-vy/300, x+ux-particleArray[i].vx/300, y+uy-particleArray[i].vy/300,  x+ux, y+uy);
   endShape();
   break;
   default:
   break;
    }
    // Sound?
    // playNote(50,127,1500);
//    }
  }
}
}
       
//==============================
void computeHairForceField(classHairStyle hairstyle) {//compute field generated by the hairstyle (!) ;)    
 // reset the "hairstlye field force":
 forceHairX=0; forceHairY=0; 
 // reset collision state for current particle
 collision=false;
  float vectorNormalx, vectorNormaly;
  vectorNormalx=0; vectorNormaly=0;
     int step=1;
     //update forces from silhouette:
     for(int i=0;i<hairstyle.currentNumberHairs-step; i=i+step) {  //vertex(hairstyle.hairStem[i].x, hairstyle.hairStem[i].y);
     
      //compute distance from ball to silhouette point:
      float deltax,deltay, auxdist; 
      deltax=futureX-hairstyle.hairStem[i].x;
      deltay=futureY-hairstyle.hairStem[i].y;
       //println(deltax);
      auxdist=max(sqrt(deltax*deltax+deltay*deltay),1);//+ball[i].ballRadius;
     
      // Electrostatic force: time consuming (need to compute 3/2 root). Perhaps simplifying with a force which is inversely propotional to distance?
      // IMPORTANT REMARK: if we use ALL the silhouette points, then the overall force will be ZERO!!! this is GAUSS THEOREM!!
      // So, we will ONLY sum when the particles are CLOSE to the silhouette, by a closeRangeSilhouette:
       
       if (auxdist<closeRangeSilhouette) { // otherwise the force is 0
         collision=true; 
         hairstyle.hairStem[i].shock=true;
         //println("collision silhouette");
       timeLastCollision=millis();
       //* electrostatic force:
     // float auxConst= 1.0*repulsionFactorSilhouette/pow(auxdist, 3);
      //* simplified force (easy to calculate, and perhaps also better to avoid "sudden infinitudes?") 
   // float auxConst= max(3.0*repulsionFactorSilhouette/pow(auxdist, 2),500*instantSoundLevel);
    float auxConst=3.0*repulsionFactorSilhouette/pow(auxdist, 2);
     // * simplified linear force:
     //float auxConst= 1.0*repulsionFactorSilhouette*(closeRangeSilhouette-auxdist);
     forceHairX+=deltax*auxConst;
     forceHairY+=deltay*auxConst;
     
     // for "reflecting force":
      //vectorNormalx+=deltax;
      //vectorNormaly+=deltay;
      
     // also, damp the speed.. (this is a hack!):
     vx0=0.3*vx;  vy0=0.3*vy; 
    
    // Also, change position of silhouette??? (would need to mantain a separate array for the silhouette, that is NOT the one from the capture!):
    // .. to do  (interesting! the silhouette will "inflate"!!!)
    
     }  
  }
 // if (collision==true) charge=-charge;
}
       
       
void drawSinuCard(float x0, float y0, int elong) {
  float distance;
color pink = color(255, 102, 204);
loadPixels();
for (int i = 0; i < (width*height); i++) {
  float yc=floor(i/width);
  float xc=i-yc*width;
  distance=sqrt((xc-x0)*(xc-x0)+(yc-y0)*(yc-y0));
  pixels[i] = color((int)distance, 102, 204);
}
updatePixels();
} 

void drawgrill(float x0, float y0, int elong) {
  float distance;
 color col;

for (int xc = 0; xc < width-50; xc=xc+50) {
for (int yc = 0; yc < height-50; yc=yc+50) {
  distance=sqrt((xc-x0)*(xc-x0)+(yc-y0)*(yc-y0));
 col=get(xc,yc);
 //col=pixels[yc*width+xc];//get(xc,yc);
 col=blendColor(col, color((int)distance, 102, 204), ADD);
fill(col);
// fill((int)distance, 102, 204);
 rect(xc,yc,20,20);
}
}
}


  void displayBall(int code) {
    // REM: here "display" is not only graphics, it can be the SOUND it produces. In fact, 
    
    noStroke();    
    float elong;
    //Plusieurs possibilities:
    //acceleration based (will detect shocks with silhouette):
    // direct:
   //  elong=sqrt(ax*ax+ay*ay)/300000+plusElong;
    // inverse: "soap bubble pop effect": 
    // elong=100/sqrt(ax*ax+ay*ay+10)-ballRadius+plusElong;
    
    //elong=sqrt(vx*vx+vy*vy)/3000+plusElong; //+thirdAxis/1000*200.0;
   elong=sqrt(vx*vx+vy*vy)/40000000;// Interesting!
   //elong=800000/(sqrt(vx*vx+vy*vy)+7000)+plusElong;
    
    
     color auxColorCollisionBlue=color( 255-constrain(timeFreeFloor,0,255),255-constrain(timeFreeFall*1.5,0,255),150, 100); // timeFreeFloor
     color auxColorCollisionRed=color(150, 255-constrain(timeFreeFall*1.5,0,255), 255-constrain(timeFreeFloor,0,255),100);
     color auxColorCollisionGreen=color(255-constrain(timeFreeFall*1.5,0,255), 150, 255-constrain(timeFreeFall*1.5,0,255) ,100);
    
    switch(code) { 
      
      case 0:
       if (chargeMode==true) {
     if (charge>0) 
      fill(auxColorCollisionRed); //fill(150,255*abs(ax)/100,255*abs(ax)/200,40);  // REDISH
    else
       fill(auxColorCollisionBlue); //fill(255*abs(ax)/200,255*abs(ax)/100,150,40); // BLUISH!!
    } else fill(auxColorCollisionRed); //fill(150,255*abs(ax)/100,255*abs(ax)/200,40);  // REDISH
     
   pushMatrix();
    translate(x,y);
    rect(0, 0, ballRadius+elong*6, ballRadius+elong*6);
    popMatrix();
   break;
      
      case 1: // rem: the function "point" does not work in OpenGL or P3D
         // draw a FILLED disk, contour color will depend on the speed
         fill(255*abs(vy)/4000,150,255*abs(vx)/4000,50); //abs(ax/10000)*255,
         pushMatrix();
         translate(x,y);
         // a sphere: TOO SLOW!!!
         // sphere(elong*5); //+ballRadius
         // for the time being, a 2d shape:
         ellipse(0, 0,1.0*elong*3+plusElong, 1.0*elong*3+plusElong); // interesting!!!
         popMatrix();
   break;  
   
   case -1:
    // display the ball as NON FILLED disc, color will depend on speed:
     stroke(255*abs(vy)/4000,150,255*abs(vx)/4000,50); //abs(ax/10000)*255,
     strokeWeight(elong*5); //+ballRadius
    //point(x, y);// ballRadius+elong, ballRadius); // ARG! point does NOT work in opengl...
      ellipse(x, y,1.0*elong*3+plusElong, 1.0*elong*3+plusElong); // interesting!!!
     break;
     
     case 2:
    pushMatrix();
    translate(x,y);
  rotate(atan2(vy,vx)+1.0*charge*frameCount/20);
    fill(150,255*abs(vy)/4000,255*abs(vx)/8000,80); //abs(ax/10000)*255,
    //println("vx: "+vx+"vy "+vy+"ax "+ax);
   rect(0, 0, ballRadius+elong, ballRadius+elong); 
   // rect(0, 0, ballRadius*2+elong*28, ballRadius/10); 
    popMatrix();
   break;
      
        case 3:
    pushMatrix();
    translate(x,y);
  rotate(atan2(vy,vx));
  noStroke();
    fill(150,255*abs(vy)/4000,255*abs(ax)/1500000,60); //abs(ax/10000)*255,
    //println("vx: "+vx+"vy "+vy+"ax "+ax);
    rect(0, 0, ballRadius/4, ballRadius*2+elong*100000+plusElong*10); 
    popMatrix();
    break;
      
      
      case 4:
  pushMatrix();
    translate(x,y);
    rotate(atan2(vy,vx)); // rem: atan2 gives values between -PI and PI, it takes TWO parameters: it's NOT the inverse of tan
   if (!discretizeDirections) fill(255*abs(vx)/50000,255*abs(vx)/50000,255*abs(vx*vy)/1000000,90); //255*abs(vx*vy)/10000000
   else fill(255*(abs(vx)+10000)/50000,255*(abs(vx)+10000)/50000,255*(abs(vx)+abs(vy))/50000,90); //255*abs(vx*vy)/10000000
  // println("vx: "+vx+"vy "+vy+"ax "+255*abs(vx*vy)/100000);
    // ellipse(0, 0, ballRadius+elong, ballRadius); // Interesting...
    ellipse(0, 0,1.0*elong/5+plusElong, 20*ballRadius); // interesting!!!
    //rect(0, 0, 1.0*(elong)+plusElong,20*ballRadius); 
    popMatrix();
   break;  

   
   case 5:
       if (chargeMode==false) {
     pushMatrix();
     translate(x,y);
     //rotate(atan2(-vy,-vx));
      rotate(atan2(vy,vx));
    //fill(150,255*abs(vy)/4000,255*abs(vx)/4000,128); //abs(ax/10000)*255,
     fill(255,255,255,70); //abs(ax/10000)*255,
    triangle(0,ballRadius/2,2*ballRadius+elong, 0,0,-ballRadius/2); 
    popMatrix();
    } else {
      // color depends on the charge:
      //fill(150,255*abs(vy)/4000,255*abs(vx)/4000,128); //abs(ax/10000)*255,
     fill(127-charge*128,0,127+charge*128,70); //abs(ax/10000)*255,
      pushMatrix();
     translate(x,y);
     //rotate(atan2(-vy,-vx));
      rotate(atan2(vy,vx));
    triangle(0,ballRadius/2,2*ballRadius+elong, 0,0,-ballRadius/2); 
    popMatrix();
    }
   break;
     
    case 6: // using "sprite" image (can potentially be very fast, but only 2D):
   float spriteSize =3*ballRadius+elong*6;
   //tint(255,255,255,100);
   float normsp=sqrt(vy*vy+vx*vx);
  // tint(255*normsp/3000,240,255*normsp/5500,170);
  // tint(255*normsp/3000,255-constrain(timeFreeFall*1.5,0,255),255*normsp/5500,170);
  fill(255);
   tint(255-constrain(timeFreeFall/2,0,255),255-constrain(timeFreeFall/2,0,255),255-constrain(timeFreeFall/2,0,255),170);
   //tint(255*abs(vy)/4000,150,255*abs(vx)/4000,50);
   //tint(255.0*(charge+1)/2,0,255.0*(1-charge)/2);
   image(spriteParticle, x- spriteSize/2.0, y - spriteSize/2.0, spriteSize, spriteSize);

   break;
     
     
   //3D shapes:
     case 7:
     /*
    // lights();
   pushMatrix();
     translate(x,y,elong*100-50);// rem: we could use a THIRD coordinate for the objects...
     //rotateY(map(mouseX, 0, width, 0, PI));
     //rotateX(map(mouseY, 0, height, 0, PI));
     rotateX(1.0*frameCount*vx/70000);
      rotateY(1.0*frameCount*vy/70000);
      rotateZ(1.0*frameCount/90000);
  //rotate(atan2(vy,vx));
   // fill(150,255*abs(vy)/4000,255*abs(ax)/4000,170); //abs(ax/10000)*255,
   // fill(150,255*abs(ay)/100,255*abs(ax)/200,255); //abs(ax/10000)*255,
     fill(255,100);
    box(ballRadius);// here, size is constant, but Z coordinate depend on elong!!!
    popMatrix();
    */
   break;
   
   

   
   case 8:
    float spriteSiz =ballRadius+elong*6;
   // image(spriteParticle, x- spriteSize/2.0, y - spriteSize/2.0, spriteSize, spriteSize);
    // image(imgSmall, x- spriteSiz/2.0, y - spriteSiz/2.0, spriteSiz, spriteSiz);
     fill(255);
    tint(255,255,255,120);
     image(imgSmallWhiteBorders, x- spriteSiz/2.0, y - spriteSiz/2.0, spriteSiz, spriteSiz);
 break;
   
   //
     case 9: // not showing the balls
     /*
       refreshScreenCLEAR=true;
    // lights();
    //stroke(128);
   pushMatrix();
    translate(x,y,elong*100-50);// rem: we could use a THIRD coordinate for the objects...
    // ROTATION: in the future, can add SPIN and use torque...
     rotateX(x/100);// map(x-currentBlob.x*xFactorDisp, 0, height, -PI, PI));
    // rotateY(map(y-currentBlob.y*yFactorDisp, 0, width, -PI, PI));
  rotateZ(ax);
  //rotate(atan2(vy,vx));
   // fill(150,255*abs(vy)/4000,255*abs(ax)/4000,170); //abs(ax/10000)*255,
   // fill(150,255*abs(ay)/100,255*abs(ax)/200,255); //abs(ax/10000)*255,
     fill(255,100);
    box(ballRadius);// here, size is constant, but Z coordinate depend on elong!!!
    popMatrix();
    */
   break;
   
   
   //drawgrill(x,y,10);
   //drawSinuCard(x,y,10);
   
   default:
   break;
  }
 
  }

 void futurePosition() {
    // update position : 
   futureX=x+(vx*dt+ax*dt*dt/2)/2;
   futureY=y+(vy*dt+ay*dt*dt/2)/2;
 }

 // update motion variables using Newton dynamics:
  void updateNewton() { 
    float totalForceX=0, totalForceY=0; //initialize total force to 0 (important)
    
    // update time passed without collision:
     timeFreeFall=millis()-timeLastCollision;
     timeFreeFloor=millis()-timeLastFloorCollision;
     
     // First, compute total force:
    //(1) field produced by the silhouette:
    totalForceX+=forceHairX;
    totalForceY+=forceHairY;

    // (2) particle interaction force:
    if (particleInteractionMode==true) {
       totalForceX+=forceInteractionX;
       totalForceY+=forceInteractionY; // the force produced by interaction with other particles
    }
    
     // (3) Gravity (this correspond to an inclination offset for the accelerometer!!)
    if (gravityMode==true) {
      totalForceX+=40*sin(accelerometerData*PI);//ay+=1400000;
      totalForceY+=40*cos(accelerometerData*PI);
    }
    
    // (4) viscosity...
    if (viscosityMode==true) {
     totalForceX+=-vx*visFactor;
     totalForceY+=-vy*visFactor;
    }

  // Compute current acceleration:
  ax=totalForceX/m;
  ay=totalForceY/m;

 // a PECULIAR behaviour for the bouncing on the bottom: the ball can GAIN energy if there is sound!
     if (soundFloorMode==true)  {// add speed depending on the noise level:
      if (y1>lineSoundY) { 
        // rem: can add to the speed, or to the ACCELERATION
       //vy-=instantSoundLevel*350000;  // to speed..
        ay-=instantSoundLevel*2000000000*4;  // indirect (meaning, in the next round): to acceleration 
       timeLastFloorCollision=millis();
            // .. and also a little on x coordinate (random):
        //vx+=instantSoundLevel*300*random(-1,1);
      }
     }



// Integration:

    //update speed : 
    vx=vx0+ax*dt;
    vy=vy0+ay*dt;
    
    
// angular discretization if needed:
if (discretizeDirections) {
 // let's make speed only horizontal or vertical 
 // example: just choose the largest component:
 if (abs(vx)>abs(vy))  vy=0; else vx=0;
 if (abs(ax)>abs(ay)) ay=0; else ax=0;
}
    
    // update position : 
   x1=x+vx*dt+ax*dt*dt/2;
   y1=y+vy*dt+ay*dt*dt/2;

     //update speed : 
    //vx=vx0+ax*dt;
    //vy=vy0+ay*dt;


    // Test boundary conditions [IN THE FUTURE, this may be done OUTSIDE the class] 
    //old "bouncing":
    /*
    if ((x1<0)||(x1>width))  {
      vx=-0.95*vx0; 
      x1=x;
    };
    if ((y1<0)||(y1>height)) {
      vy=-0.95*vy0; 
      y1=y;
    };
    */
    
    
    // New: bouncing against the silhouette:
    /*
  boolean collision=false;
  float vectorNormalx, vectorNormaly;
  vectorNormalx=0; vectorNormaly=0;
  for(int j=0;j<listVertex.length;j++){ // list on all the globs
    if(listVertex[j]!=null){
      for(int k=0;k<listVertex[j].length;k++){ // list on all the silhouette points:
      //compute distance from ball to silhouette point:
      float deltax,deltay, auxdist; 
      deltax=x1-listVertex[j][k][0]*xFactorDisp;
      deltay=y1-listVertex[j][k][1]*yFactorDisp;
      auxdist=sqrt(deltax*deltax+deltay*deltay);//+ball[i].ballRadius;
      if (auxdist<closeRangeSilhouette) {collision=true; vectorNormalx+=deltax; vectorNormaly+=deltay; } 
      }
    }
  }
  // use "impenetrable wall" (calculated force will REFLECT speed):
  if (collision==true) {
   float normNormal=sqrt(vectorNormalx*vectorNormalx+vectorNormaly*vectorNormaly);
  //println(normNormal);
   float ux=vectorNormalx/normNormal, uy=vectorNormaly/normNormal;
   float auxc=(ux*ux-uy*uy);
   float fact=10;// if this factor is >1, then the speed is damped (energy absorved at the collision)
   vx=(-2*ux*uy*vy0-(fact+auxc)*vx0)/fact;
   vy=(-2*ux*uy*vx0+(auxc-fact)*vy0)/fact;
   x1=x;
   y1=y;
  }
  */
    
    // BORDER CONDITIONS: 
    switch(borderMode) { // borderMode: 0 means no borders (particles will appear in the center of blob), 1 means bouncing, 2 means toroidal surface
       
      case 0:  // no borders: 
        //In this case, if particle is outside the display, it starts again in the center of a glob (random glob), on the border (if codegraphics is 5), 
   // and if there is no blob, in the center of the image
    if ((x1<0)||(x1>width)||(y1<0)||(y1>height))  {
     
      if (soundBorder==true) {
      // specific sound for "outside":
     //if (y1>0) playNote(69,120,1500);
     // if (y1<height)  playNote(30,127,15000); // sound only when it goes outside the window BUT from the bottom of the screen
  // playNote(10,10,1500);
       playNote(30,127,15000); 
      }
       
      // speed attenuation?:
      vx=0.2*vx;   vy=0.2*vy; 
      vx0=0.2*vx0;   vy0=0.2*vy0; 
      
      // recentering:
      if ((currentBlob!=null)&&(hairStyle.currentNumberHairs>0)) {
         // in this case, they will appear perpendicular to the silhouette, in a random position around the silhouette:
        int randHairIndex=floor(random(0,hairStyle.currentNumberHairs)); // particle will be launched from a random hair stem 
      
       
       // even more speed attenuation?
        vx=0.3*vx; vy=0.3*vy; 
        vx0=0.3*vx0; vy0=0.3*vy0;
        float auxSpeedNorm=sqrt(vx*vx+vy*vy);
             
        // speed DIRECTION parallel to the normal vector (nx, ny)':     
        if ((chargeMode==true)) { //&&(codegraphic==5)) {
          x1=hairStyle.hairStem[randHairIndex].x+charge*hairStyle.hairStem[randHairIndex].nx*reflowParticle/senseHair*closeRangeSilhouette;//*10;
          y1=hairStyle.hairStem[randHairIndex].y+charge*hairStyle.hairStem[randHairIndex].ny*reflowParticle/senseHair*closeRangeSilhouette;//*10;
          vx=charge*auxSpeedNorm*reflowParticle/senseHair*hairStyle.hairStem[randHairIndex].nx;
          vy=charge*auxSpeedNorm*reflowParticle/senseHair*hairStyle.hairStem[randHairIndex].ny;
        } else {
           x1=hairStyle.hairStem[randHairIndex].x+hairStyle.hairStem[randHairIndex].nx*reflowParticle/senseHair*closeRangeSilhouette;//*10;
          y1=hairStyle.hairStem[randHairIndex].y+hairStyle.hairStem[randHairIndex].ny*reflowParticle/senseHair*closeRangeSilhouette;//*10;
          vx=auxSpeedNorm*reflowParticle/senseHair*hairStyle.hairStem[randHairIndex].nx;
          vy=auxSpeedNorm*reflowParticle/senseHair*hairStyle.hairStem[randHairIndex].ny;
        }
         //old: 
         //} else { // particle reappears in the center of the blob   
        //int globNum=floor(random(listGlobCenters.length));
          //x1=1.0*listGlobCenters[globNum][0]*xFactorDisp; 
          //y1=1.0*listGlobCenters[globNum][1]*yFactorDisp;
          //x1=(listGlobCenters[0][0]+0.5*listGlobCenters[0][2])*xFactorDisp; 
          //y1=(listGlobCenters[0][1]+0.5*listGlobCenters[0][3])*yFactorDisp;        
          //x1=(currentBlob.xMax+currentBlob.xMin)/2*xFactorDisp;
          //y1=(currentBlob.yMax+currentBlob.yMin)/2*yFactorDisp;
          //x1=currentBlob.x*xFactorDisp;
          //y1=currentBlob.y*yFactorDisp;
         //   println("x: "+x1+"y: "+y1);
         //}
  } 
      else { // in case there is no blob present, the ball appears randomly, or in the center of the screen, or on top, or bottom, etc...
         x1=random(0,width-1);// 1.0*width/2; 
         y1=random(0,height-1);//lineSoundY-10;//height-1;//1;//1.0*height/2; 
      }
    }
      break;

     case 2: // toroidal topology (ATTN! have to consider this topology too when calculating the inter-particle attraction/repulsion)
       x1=x1-width*floor(x1/width);
       y1=y1-height*floor(y1/height);
         if (soundBorder==true)   playNote(30,127,15000); 
       // speed attenuation?:
    // vx=0.7*vx; vy=0.7*vy; 
     //vx0=0.7*vx0; vy0=0.7*vy0;
     break;
   
    case 1:  //bounce on the screen borders and make noise too:
        if ((x1<0)||(x1>width)) {
       if (soundBorder==true)  playNote(30,127,15000); 
      // speed attenuation:
     x1=x;
      vx=-0.7*vx; vx0=-0.7*vx0;   
       } 
       
        if ((y1<0)||(y1>height)) {
         if (soundBorder==true)playNote(30,127,15000); 
      // speed attenuation:
      vy=-0.7*vy; vy0=-0.7*vy0; 
      y1=y;
    }
    break;
    
    default: 
  break;  
  
    }  // end of border mode switch case
   
  
    // Update the current position and past speed:
    x=x1; 
    y=y1;
    vx0=vx; 
    vy0=vy;
    
     normAcc=sqrt(ax*ax+ay*ay);
    /*
     if (normAcc>4000) {
      playNote(int(constrain(normAcc/4000,20,120)),40,100);
       collision=true;
     } */
    
    futurePosition();
    
     // finally, update tail:
    if (tailMode==true) {
      for (int i=currentTailLength-1; i>0; i--) { // rem: by havinf a separate array for x and y, we can use the copy command, much faster!
        tail[i][0]=tail[i-1][0];
        tail[i][1]=tail[i-1][1];
      }
      // finally, add new position:
       tail[0][0]=x; tail[0][1]=y;
    }
    
  }
  
  void drawTail() { // in the future, can take a "graphic code" parameter
     // simplest tail:
     for (int i=0;i<currentTailLength-5; i=i+5) { // rem: by havinf a separate array for x and y, we can use the copy command, much faster!
        stroke(128,128,128,100); strokeWeight(ballRadius*(1-1.0*i/(currentTailLength-1)));
        line(tail[i][0], tail[i][1], tail[i+5][0], tail[i+5][1]);
      }
    
  }
  
  
   void playNote(int pitch, int vel, int len){
   // note = new Note(gamme[myNumber%5]-24+12*(myNumber%4),127,1500);//int(xPos/5f),100,1000);//int(yPos/10f)+60,1000));//int(random(1000)));
  if ((millis()-lastPlayTime)>PlayInterval) {
    lastPlayTime=millis();
  note=new Note(pitch, vel, len);//(63,120,1500);
  // println("pitch: "+pitch+" vel: "+ vel+" len: "+len);
    if (silentMode==false) midiOut.sendNote(note);
  }
  }
  
  void brightToAlpha(PImage b){ // as in flight404, convert brightness into alpha channel
  // b.format = RGBA;
   for(int i=0; i < b.pixels.length; i++) {
     b.pixels[i] = color(0,0,0,255 - brightness(b.pixels[i]));
   }
 }
}
