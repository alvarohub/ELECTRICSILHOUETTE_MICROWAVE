void whiteBorders(PImage img,int thickness, boolean maskType) {
 // this may be useful to create (dark) blobs that are completely inside the screen (may be helful to mantain the silhouette orientation)  
/*PImage auxImage=new PImage(1,1); auxImage.loadPixels();
if (maskType==false) auxImage.pixels[0]=color(255,255,255); else auxImage.pixels[0]=color(0,0,0);auxImage.updatePixels();
img.loadPixels();
img.copy(auxImage,0,0,1,1, 0,0,thickness, img.height);
img.copy(auxImage,0,0,1,1, img.width-thickness,0,thickness, img.height);
img.copy(auxImage,0,0,1,1, thickness,0, img.width-2*thickness,thickness);
img.copy(auxImage,0,0,1,1, thickness, img.height-thickness, img.width-2*thickness,thickness);
*/
color bordercolor;
if (maskType==false) bordercolor=color(255,255,255); else bordercolor=color(0,0,0);
img.loadPixels();
for (int i=0; i<img.width*thickness; i++) {
img.pixels[i]=bordercolor;
}
for (int i=(img.width*(img.height-thickness)); i<img.width*img.height; i++) {
img.pixels[i]=bordercolor;
}
for (int i=0; i<img.height; i++) {
  for (int j=0; j<thickness; j++) {
img.pixels[i*img.width+j]=bordercolor;
img.pixels[(i+1)*img.width+j-thickness]=bordercolor;
  }
}
img.updatePixels();
}
