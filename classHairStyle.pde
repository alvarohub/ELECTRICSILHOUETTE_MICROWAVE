// The "hair style" class define an array of hairs around the silhouette

class classHairStyle {
// Array of hair stems (to be set around the silhouette):
int maxNumberHairs;
int currentNumberHairs;
classHairStem[] hairStem;  
  
  // elementary constructor:
  classHairStyle(int maxnumHairs) {
  maxNumberHairs=maxnumHairs; //number of hairs in the "scalp"
  hairStem =new classHairStem[maxNumberHairs]; 
  //currentNumberHairs not defined yet, let's fix it to the maximum possible:
  currentNumberHairs=maxNumberHairs;
   for(int i=0;i<currentNumberHairs; i++) {
     hairStem[i]=new classHairStem(0,0,0,1);
   }
  }
  
  // reset in case of problem: make number of hairs equal to 0!
   void reset() {
      currentNumberHairs=2; //pb with =0!! (crash)
   }
  
  //"implanting" the hairs from the current silhouette:
  void makeHairStyle(Blob b, int edgeSampling) {
  // edgeSampling=2; // for a reason I don't know, edgeSampling MUST be > 2...
    //rem: this function is not called with a null blob
    EdgeVertex eA, eB;
   currentNumberHairs=floor(1.0*(b.getEdgeNb()-1)/edgeSampling);

      for(int i=0;i<currentNumberHairs; i++) {
       eA = b.getEdgeVertexA(i*edgeSampling);  
       eB = b.getEdgeVertexA((i+1)*edgeSampling); // ATTN: eB is also taken from Vertex
       if ((eA !=null) && (eB !=null)) {
         // then set the hair stem (base and normalized direction!):
         hairStem[i].setHairStem(eA.x*xFactorDisp,eA.y*yFactorDisp,eB.x*xFactorDisp,eB.y*yFactorDisp); //rem: NOT normalized coordinates
       // line(eA.x*xFactorDisp,eA.y*yFactorDisp,eB.x*xFactorDisp,eB.y*yFactorDisp);
      // eA=eB;// b.getEdgeVertexA((i+1)*edgeSampling); 
      hairStem[i].shock=false;
    } else println("ajco");
    
      }
  // the last hair is discarded...    
  }
  
  // draw the hairstyle:
  void display(float lengthhair) { // parameter can be the drawing mode:
       for(int i=0;i<currentNumberHairs; i++) {
          hairStem[i].display(lengthhair);
       }
       //println(currentNumberHairs);
  }
  
   // draw the hairstyle with triangles
  void displayTriangle(float soundlevel, color colorhair) { // parameter can be the drawing mode:
       if (soundlevel>.004)
       for(int i=0;i<currentNumberHairs; i++) {
          hairStem[i].displayTriangle(soundlevel, colorhair);
       }
       //println(currentNumberHairs);
  }
  
  void displaySplineExternal() {
     for(int i=0;i<currentNumberHairs; i++) {
          hairStem[i].displaySplineExternal();
       }
  }
  
   void displaySampledScalp() {
     int i;
     int step=1;
     /*
     strokeWeight(strokeNorm*maxStrokeSize); 
     stroke((1.0-strokeNorm)*155+100, strokeNorm*100,strokeNorm*255,strokeNorm*150);//(1.0-strokeNorm)*80+140);
     for(i=0;i<currentNumberHairs-step; i=i+step) {
          line(hairStem[i].x, hairStem[i].y, hairStem[i+step].x, hairStem[i+step].y); 
       }
     // and the last connection:
     line(hairStem[i].x, hairStem[i].y, hairStem[0].x, hairStem[0].y); 
     
      // Secondary line (inside, white):
     strokeWeight(strokeNorm*2); 
      stroke(strokeNorm*255,strokeNorm*255,strokeNorm*255,40+strokeNorm*210);
      for(i=0;i<currentNumberHairs-step; i=i+step) {
          line(hairStem[i].x, hairStem[i].y, hairStem[i+step].x, hairStem[i+step].y); 
       }
     // and the last connection:
     line(hairStem[i].x, hairStem[i].y, hairStem[0].x, hairStem[0].y); 
     */
     
     
      noFill(); // no interior
      step=1;
       for(i=0;i<currentNumberHairs-step; i=i+step) {
       if (hairStem[i].shock==true) { // make a thick and red line
        strokeWeight(5*maxStrokeSize); 
        stroke(255,0,0,100);  
       } else { // 
          strokeWeight(1); 
          stroke(0,0,255,100);//(1.0-strokeNorm)*80+140);  
       }
          beginShape(); 
         vertex(hairStem[i].x, hairStem[i].y);
          vertex(hairStem[i+1].x, hairStem[i+1].y);
          endShape();
       }
     
     
     // REM: using OPENGL vertex (using openGL for the whole line is sometimes problematic because edges are not necessarily orderer in the list...):
     
    /*
     // filled or not filled contour (white):
   // strokeWeight(strokeNorm*maxStrokeSize); 
   //stroke((1.0-strokeNorm)*155+100, strokeNorm*100,strokeNorm*255,strokeNorm*150);//(1.0-strokeNorm)*80+140);  
      // interior (if desired): 
      //fill(strokeNorm*150+50,0,0,100);
      noFill(); // no interior
      step=1;
      beginShape();
     for(i=0;i<currentNumberHairs-step; i=i+step) {
       if (hairStem[i].shock==true) { // make a thick and red line
        strokeWeight(5*maxStrokeSize); 
        stroke(255,0,0,100);  
       } else { // 
          strokeWeight(1); 
          stroke(0,0,255,100);//(1.0-strokeNorm)*80+140);  
       }
          vertex(hairStem[i].x, hairStem[i].y);
       }
       // and last point to close the loop:
       if (hairStem[0].shock==true) { // make a thick and red line
        strokeWeight(maxStrokeSize); 
        stroke(255,0,0,100);
       } else { // 
          strokeWeight(1); 
          stroke(0,0,255,100);//(1.0-strokeNorm)*80+140);  
       }
        vertex(hairStem[0].x, hairStem[0].y);
       endShape();
   */
   
   
   // Secondary outline (no fill):
   /*
     strokeWeight(strokeNorm*2); 
      stroke(strokeNorm*255,strokeNorm*255,strokeNorm*255,40+strokeNorm*210);
   //strokeWeight(strokeNorm*maxStrokeSize); 
  //stroke((1.0-strokeNorm)*155+100, strokeNorm*100,strokeNorm*255,strokeNorm*190);//(1.0-strokeNorm)*80+140);
   noFill();
   step=1;
      beginShape();
     for(i=0;i<currentNumberHairs-step; i=i+step) {
          vertex(hairStem[i].x, hairStem[i].y);
       }
       // and last point to close the loop:
        vertex(hairStem[0].x, hairStem[0].y);
       endShape();
   */
     
  }
  
  
  void displaySilhouetteEqualizer() {
    
    
  }
  
  
  
void displaySilhouetteWave(color colortriangle) {
  stroke(255,100); strokeWeight(3);
  int interp=(int)max(0,(((millis()-myInput.bufferStartTime)/(float)myInput.duration)*myInput.size));

if (currentNumberHairs>1) {
  for(int i=0;i<currentNumberHairs; i++) {
 
  //for (int i=0;i<myInput.size;i++) {
  //float left=160;
  //  float right=160;
  //  if (int(1.0*i/(currentNumberHairs-1)*(myInput.size-1))+interp+1<myInput.buffer2.length) {
  //    left-=myInput.buffer2[i+interp]*150.0;
  //    right-=myInput.buffer2[i+1+interp]*150.0;
  //  }

    float lengthair=1.0*abs(myInput.buffer2[int(1.0*i/(currentNumberHairs-1)*(myInput.size-1))])*soundGain;
     //hairStem[i].display(lengthair);
     
     //hairStem[i].displayTriangle(lengthair, colortriangle);
    
    // hairStem[i].displaySplineExternal();
    //line(10+i,left,11+i,right);
    hairStem[i].displayAlphaImage(lengthair, colortriangle);
    // hairStem[i].displayTangentTriangles(lengthair, colortriangle);
    
  }
 }
}
  
  void displayConnectedHairsBalls() {
    stroke(255,100); strokeWeight(3);
    if (currentNumberHairs>1) {
        for (int i=0; i<numberBalls; i++) {
          int hairNumber=floor(1.0*currentNumberHairs/numberBalls)*i;
          noFill();
          //fill(120,120,120,50);
          beginShape();
          vertex(hairStem[hairNumber].x,hairStem[hairNumber].y);
            bezierVertex(hairStem[hairNumber].x+hairStem[hairNumber].nx*80, hairStem[hairNumber].y+hairStem[hairNumber].ny*80,  hairStem[hairNumber].x+hairStem[hairNumber].nx*160, hairStem[hairNumber].y,   ball[i].x,  ball[i].y);
      
          endShape();
      } 
    }
  }
  
  
   void displaySolarCrown(float intensity) {
     if (intensity>0.004) { // otherwise do nothing...
     float expellForceX=100+intensity*20000;//*random(600,605);//random(200,1000); // THIS may depend on sound level!
     float expellForceY=100+intensity*20000;//*random(600,605);
  
    //fill(120,120,120,50);
    int halfEdges=floor(1.0*currentNumberHairs/2)-1;
    
    if (boltCounter>boltMaxCount) {
      boltCounter=0;
      //println("now");
      indexBoltOrigin=floor(random(currentNumberHairs-1));//floor(random(halfEdges));
    } else indexBoltOrigin=(indexBoltOrigin+1)%currentNumberHairs; //;floor(random(halfEdges));
    int indexBoltEnd=(indexBoltOrigin+halfEdges/4)%currentNumberHairs;//currentNumberHairs-indexBoltOrigin-1;
   
    //int indexBoltEnd=(abs(2*halfEdges-indexBoltOrigin-1+boltMaxCount/2-boltCounter*10))%(currentNumberHairs);
    
    //for(int i=0;i<halfEdges; i++) {
    float auxXa=hairStem[indexBoltOrigin].x, auxYa=hairStem[indexBoltOrigin].y;
    float auxXb=hairStem[indexBoltEnd].x, auxYb=hairStem[indexBoltEnd].y;  
   
     strokeWeight(strokeNorm*maxStrokeSize/2); 
    //stroke(120,120,0); 
    noFill();
    stroke((1.0-strokeNorm)*155+100, strokeNorm*100,strokeNorm*255,strokeNorm*150);//(1.0-strokeNorm)*80+140); 
  beginShape();
 vertex(auxXa, auxYa);
 bezierVertex(auxXa+expellForceX*hairStem[indexBoltOrigin].nx, auxYa+expellForceY*hairStem[indexBoltOrigin].ny, auxXb+expellForceX*hairStem[indexBoltEnd].nx, auxYb+expellForceY*hairStem[indexBoltEnd].ny,  auxXb, auxYb);
 endShape();
 
 // Again with different color/weight:
   strokeWeight(strokeNorm); 
      stroke(strokeNorm*255,strokeNorm*255,strokeNorm*255,40+strokeNorm*210);
      beginShape();
 vertex(auxXa, auxYa);
 bezierVertex(auxXa+expellForceX*hairStem[indexBoltOrigin].nx, auxYa+expellForceY*hairStem[indexBoltOrigin].ny, auxXb+expellForceX*hairStem[indexBoltEnd].nx, auxYb+expellForceY*hairStem[indexBoltEnd].ny,  auxXb, auxYb);
 endShape();
 
 
 //}
  
}
   }

}
