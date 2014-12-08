
// fills the silhouette:
void silhouetteFill(Blob b) {
  EdgeVertex A,B,C;
  BlobTriangle bTri;
  
  stroke(0,200,0); strokeWeight(1); fill(0,120,0,20);
   // use openGL to render the triangulated mesh:
  beginShape(TRIANGLES);
 for (int i=0; i<b.getTriangleNb();i++) {
   //retrieve the vertex of the ith triangle:
   bTri=b.getTriangle(i);
  A=b.getTriangleVertexA(bTri); //getTriangle(n) retrieves an object of type BlobTriangle
  B=b.getTriangleVertexB(bTri);
  C=b.getTriangleVertexC(bTri);
  
  vertex(A.x*xFactorDisp,A.y*yFactorDisp); //curveVertex(eA.x*xFactorDisp,eA.y*yFactorDisp);
  vertex(B.x*xFactorDisp,B.y*yFactorDisp); //curveVertex(eA.x*xFactorDisp,eA.y*yFactorDisp);
  vertex(C.x*xFactorDisp,C.y*yFactorDisp); //curveVertex(eA.x*xFactorDisp,eA.y*yFactorDisp);
  
 }
  endShape();
}
