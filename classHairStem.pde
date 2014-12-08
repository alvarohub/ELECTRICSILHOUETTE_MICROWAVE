// Class for each hair over the silhouette

class classHairStem {
  float x, y;
  float nx, ny; // normalized direction of the hair
   boolean shock=false;
   
  // constructor:
   classHairStem() {
  x=0; y=0; nx=0; ny=1;
  shock=false;
 } 
  
 // overloaded:
 classHairStem(float posx, float posy, float dirx, float diry) {
  x=posx; y=posy; nx=dirx; ny=diry;
  shock=false;
 } 
  
 //compute and set hair stem for a given segment (it will be a segment with same origin, but normalized and rotated -90 degrees)
 void setHairStem(float xa, float ya, float xb, float yb) {
        float edx, edy; //edge vector=(edx, edy)'
        edx=(xb-xa); edy=(yb-ya);
        float normedge=sqrt(edx*edx+edy*edy);
        //calculate the rotated normal (direction of hair):
        nx=-1.0*edy/normedge*senseHair; ny=1.0*edx/normedge*senseHair;
        // also set the position of thehair base:
        x=xa; y=ya;
 }
 
 // draw hair (many ways to do that):
 void display(float lengthhair){
    stroke(lengthhair,lengthhair,lengthhair,120); strokeWeight(50);
    line(x, y, x+nx*lengthhair*10, y+ny*lengthhair*10);
 }
 
 // ...with triangles:
 void displayTriangle(float soundlevel, color colorhair){ //rem: soundlevel is normalized 0-1
 float lengthhair=150*soundlevel;
    //stroke(lengthhair,lengthhair,lengthhair,120); 
    noStroke();// strokeWeight(50);
    pushMatrix();
    translate(x,y);
     rotate(atan2(ny,nx)+accelerometerData*PI);
    //fill(150,255*abs(vy)/4000,255*abs(vx)/4000,128); //abs(ax/10000)*255,
    // fill(255,255,255,70); //abs(ax/10000)*255,
    //if (shock==false) fill(colorhair); else fill(255,100,100,200);
    fill(colorhair);
    triangle(0,lengthhair,30*lengthhair, 0,0,-lengthhair); 
    //triangle(0,4,30*lengthhair, 0,0,-4); 
   popMatrix();
 }
 
 //... with images:
 void displayAlphaImage(float soundlevel, color colorhair){ //rem: soundlevel is normalized 0-1
 float lengthhair=150*soundlevel;
    //stroke(lengthhair,lengthhair,lengthhair,120); 
    noStroke();// strokeWeight(50);
    pushMatrix();
    translate(x,y);
    float angleHair=atan2(ny,nx)+accelerometerData*PI;
     rotate(angleHair); // rem: angles in radians
    //fill(150,255*abs(vy)/4000,255*abs(vx)/4000,128); //abs(ax/10000)*255,
    // fill(255,255,255,70); //abs(ax/10000)*255,
    //if (shock==false) fill(colorhair); else fill(255,100,100,200);
   
    //fill(colorhair);
   //triangle(0,lengthhair,30*lengthhair, 0,0,-lengthhair); 
   
   fill(255);
   tint(200,200,255);
   image(imageSpritePoil, 0, 0, lengthhair*40, 8*lengthhair);
    fill(255);
   tint(200,0,0,40);
   image(imageSpritePoil, 0, 0, lengthhair*30, 4*lengthhair);
   popMatrix();
 }
 
 // with tangent lines:
 void displayTangentTriangles(float soundlevel, color colorhair){ //rem: soundlevel is normalized 0-1
 float lengthhair=150*soundlevel;
    //stroke(lengthhair,lengthhair,lengthhair,120); 
    noStroke();// strokeWeight(50);
    pushMatrix();
    translate(x,y);
     rotate(atan2(ny,nx)+accelerometerData*PI); // rem: angles in radians
    //fill(150,255*abs(vy)/4000,255*abs(vx)/4000,128); //abs(ax/10000)*255,
    // fill(255,255,255,70); //abs(ax/10000)*255,
    //if (shock==false) fill(colorhair); else fill(255,100,100,200);
    fill(colorhair);
   triangle(0,0.05*lengthhair,30*lengthhair, 0,0,-0.05*lengthhair); 
   rotate(PI);
   triangle(0,0.05*lengthhair,10*lengthhair, 0,0,-0.05*lengthhair); 
   popMatrix();
 }
 

 
 void displaySplineExternal() {
   strokeWeight(1);
    stroke(0,0,120); 
     stroke((1.0-strokeNorm)*155+100, strokeNorm*100,strokeNorm*255,strokeNorm*150);//(1.0-strokeNorm)*80+140);
    noFill();
    //fill(120,120,120,50);
  beginShape();
 vertex(x,y);
 bezierVertex( x+nx*80, y+ny*80,  x+nx*160, y,   x+nx*320, height);
 endShape();
 }
  
}


