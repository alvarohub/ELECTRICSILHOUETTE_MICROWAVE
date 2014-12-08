void displaySoundFloor(float y) {
  // Show wave (and spectrum perhaps):
 
  int interp=(int)max(0,(((millis()-myInput.bufferStartTime)/(float)myInput.duration)*myInput.size));
  // stroke(50,230,50,30); strokeWeight(3);
  
  for (int i=0;i<myInput.size;i++) {
    float left=y; //height-100;
    float right=y;// height-100;

    if (i+interp+1<myInput.buffer2.length) {
      left-=abs(myInput.buffer2[i+interp])*1000.0*soundGain;
      right-=abs(myInput.buffer2[i+1+interp])*1000.0*soundGain;
    }
   
    //using triangles:
    //float translationx=1.0*i*width/myInput.size;
    //fill(random(0,255), random(0,255), random(9,255), 30);
    // triangle(translationx-30,y,translationx,left,translationx+30,y); 
     
      //pushMatrix();
      //translate(1.0*i*width/myInput.size,left)
      //popMatrix();
      
    //Using a line:
     strokeWeight((1.0-strokeNorm)*maxStrokeSize/2); 
  //stroke(0, strokeNorm*200,strokeNorm*255,140);
  stroke(strokeNorm*155+100, (1.0-strokeNorm)*100,(1.0-strokeNorm)*255,(1.0-strokeNorm)*150);//(1.0-strokeNorm)*80+140);
    line(1.0*i*width/myInput.size,left,1.0*(i+1)*width/myInput.size,right);
    
     strokeWeight((1.0-strokeNorm)*2); 
      stroke((1.0-strokeNorm)*255,(1.0-strokeNorm)*255,(1.0-strokeNorm)*255,40+(1.0-strokeNorm)*210);
       line(1.0*i*width/myInput.size,left,1.0*(i+1)*width/myInput.size,right);
  }
}
