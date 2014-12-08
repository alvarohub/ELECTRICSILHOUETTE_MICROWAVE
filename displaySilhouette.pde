void displaySilhouette(Blob b, float altitude) { // rem: altitude is when using 3d
  int i, ii, step;
 
  EdgeVertex eA, eB;
  
  // Test: using openGL for the whole line is sometimes problematic because edges are not necessarily orderer in the list...
  /*
  //float strokeNorm=random(0,1); // REM: stroke weight can be controlled by the balls hiting the wall: can be quite random!!!!
  strokeWeight(strokeNorm*maxStrokeSize); 
  //stroke(0, strokeNorm*200,strokeNorm*255,140);
  stroke((1.0-strokeNorm)*155+100, strokeNorm*100,strokeNorm*255,strokeNorm*100);//(1.0-strokeNorm)*80+140);
  // stroke(0, int(random(0,150)),int(random(150,255)),int(random(1,230)));
    step=1;//int(random(1,5));
      for(ii=0;ii<b.getEdgeNb();ii=ii+step){ //loop on the vertices
      beginShape();
       eA = b.getEdgeVertexA(ii);
       eB = b.getEdgeVertexB(ii);
       if (eA !=null && eB !=null) {
        vertex(eA.x*xFactorDisp,eA.y*yFactorDisp);
        vertex(eB.x*xFactorDisp,eB.y*yFactorDisp);
         //line(eA.x*xFactorDisp,eA.y*yFactorDisp,eB.x*xFactorDisp,eB.y*yFactorDisp);
        //also, draw a disc in the joint (this is neceseary when in OPENGL rendering.. strokeCap and strokeJoin doesn't work!)
       // ellipse(eA.x*xFactorDisp,eA.y*yFactorDisp,strokeNorm*maxStrokeSize/2,strokeNorm*maxStrokeSize/2);
    }
      }
     endShape();
     */
     
        /*   
    // Using splines and opengl (rem: same problem than drawing a line with opengl beginShape(LINES): edges are not necessarily adjacent!!
   strokeWeight(strokeNorm*maxStrokeSize); 
  stroke((1.0-strokeNorm)*155+100, strokeNorm*100,strokeNorm*255,strokeNorm*150);//(1.0-strokeNorm)*80+140);
   step=5;//
      for(ii=0;ii<b.getEdgeNb();ii=ii+step){ //loop on the vertices
       beginShape();
      for (int j=0;j<step;j++) {
       eA = b.getEdgeVertexA(ii+j);
       if (eA !=null) {
       curveVertex(eA.x*xFactorDisp,eA.y*yFactorDisp);
    }
      }
      endShape(); 
      } 
      */
 
  
  //Without using openGL:
  //float strokeNorm=random(0,1); // REM: stroke weight can be controlled by the balls hiting the wall: can be quite random!!!!
  strokeWeight(strokeNorm*maxStrokeSize); 
  //stroke(0, strokeNorm*200,strokeNorm*255,140);
  stroke((1.0-strokeNorm)*155+100, strokeNorm*100,strokeNorm*255,strokeNorm*150);//(1.0-strokeNorm)*80+140);
  // stroke(0, int(random(0,150)),int(random(150,255)),int(random(1,230)));
   noFill();
   step=1;//int(random(1,5));
      for(ii=0;ii<b.getEdgeNb();ii=ii+step){ //loop on the vertices
       eA = b.getEdgeVertexA(ii);
       eB = b.getEdgeVertexB(ii);
       if (eA !=null && eB !=null) {
        line(eA.x*xFactorDisp,eA.y*yFactorDisp, altitude,eB.x*xFactorDisp,eB.y*yFactorDisp,  altitude);
        
        //orientation (for tests): ATTN: ORIENTATION SEEMS INCONSISTENT WITH THE LOOPING ORIENTATION!!!
        /*
        float edx, edy; //edge vector=(edx, edy)'
        edx=(eB.x-eA.x)*xFactorDisp; edy=(eB.y-eA.y)*yFactorDisp;
        float normedge=sqrt(edx*edx+edy*edy);
        float nx, ny;
        nx=-edy/normedge; ny=edx/normedge;
        // then, set the position of the partcle to eA:
        stroke(255,0,0); strokeWeight(5);
        line(eA.x*xFactorDisp, eA.y*yFactorDisp,eA.x*xFactorDisp+nx*40, eA.y*yFactorDisp+ny*40);
        */
        
        //also, draw a disc in the joint (this is neceseary when in OPENGL rendering.. strokeCap and strokeJoin doesn't work!)
       // ellipse(eA.x*xFactorDisp,eA.y*yFactorDisp,strokeNorm*maxStrokeSize/2,strokeNorm*maxStrokeSize/2);
    }
      } 

      
      //also, draw a disc in the joint (this is neceseary when in OPENGL rendering.. strokeCap and strokeJoin doesn't work!):
      /*
      noStroke();
      fill((1.0-strokeNorm)*155+100, strokeNorm*100,strokeNorm*255,strokeNorm*100);
      step=1;//int(random(1,5));
      for(ii=0;ii<b.getEdgeNb();ii=ii+step){ //loop on the vertices
       eA = b.getEdgeVertexA(ii);
       if (eA !=null) {
        ellipse(eA.x*xFactorDisp,eA.y*yFactorDisp,strokeNorm*maxStrokeSize,strokeNorm*maxStrokeSize);
    }
      }
     noFill(); 
        */
    

     // Secondary line (inside, white):
     strokeWeight(strokeNorm*2); 
      stroke(strokeNorm*255,strokeNorm*255,strokeNorm*255,40+strokeNorm*210);
     // stroke(0, int(random(0,150)),int(random(150,255)),int(random(1,230)));
     step=1;//int(random(1,5));
     noFill();
      for(ii=0;ii<b.getEdgeNb();ii=ii+step){ //loop on the vertices
       eA = b.getEdgeVertexA(ii);
       eB = b.getEdgeVertexB(ii);
       if (eA !=null && eB !=null) {
         float xxA=eA.x*xFactorDisp, yyA=eA.y*yFactorDisp;
         float xxB=eB.x*xFactorDisp, yyB=eB.y*yFactorDisp;
        line(xxA,yyA,altitude,xxB,yyB, altitude);
      } 
      }
      
      
      
      
      
  // ligne pointillee (using only one vertex/edge) 
  /*
  maxStrokeSize=10;
  float strokeNorm=random(0,1); // REM: stroke weight can be controlled by the balls hiting the wall: can be quite random!!!!
  strokeWeight(strokeNorm*maxStrokeSize); 
  stroke((1.0-strokeNorm)*100+100, strokeNorm*100,strokeNorm*255,(1.0-strokeNorm)*80+80);
  // stroke(0, int(random(0,150)),int(random(150,255)),int(random(1,230)));
   step=10;//int(random(1,5));
   eA = b.getEdgeVertexA(0);
      for(ii=step;ii<b.getEdgeNb();ii=ii+step){ //loop on the vertices
       eB = b.getEdgeVertexA(ii); // ATTN: eB is also taken from VertexA
       if (eA !=null && eB !=null) {
        line(eA.x*xFactorDisp,eA.y*yFactorDisp,eB.x*xFactorDisp,eB.y*yFactorDisp);
      eA=eB;
    }
   }
   // and last line:
     eB = b.getEdgeVertexA(0);
      line(eA.x*xFactorDisp,eA.y*yFactorDisp,eB.x*xFactorDisp,eB.y*yFactorDisp);
    */

  // dots only (different step)
  /*
   stroke(200, 0, 0, 150);strokeWeight(7); 
   step=1;
      for(ii=0;ii<b.getEdgeNb();ii=ii+step){ //loop on the vertices
       eA = b.getEdgeVertexA(ii);
       if (eA !=null)
        point(eA.x*xFactorDisp,eA.y*yFactorDisp);
  }
  */
  
  // turning point? (like radar sweeping from the center of the blob)
  
  /*
  indexRadarPoint=((indexRadarPoint+1)%b.getEdgeNb());
   eA = b.getEdgeVertexA(indexRadarPoint);
   fill(0,0,255,160);
   noStroke();
   ellipse(eA.x*xFactorDisp,eA.y*yFactorDisp,20*sin(5*2*PI*indexRadarPoint/b.getEdgeNb())+40,20*cos(5*2*PI*indexRadarPoint/b.getEdgeNb())+40);
   stroke(0, 0, 200,255);strokeWeight(1); 
  float cx=(currentBlob.xMax+currentBlob.xMin)/2*xFactorDisp;
  float cy=(currentBlob.yMax+currentBlob.yMin)/2*yFactorDisp;
  line(cx, cy, eA.x*xFactorDisp,eA.y*yFactorDisp);
  noFill();
  */
  
  
  
}
