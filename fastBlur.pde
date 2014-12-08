// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann 
// <http://incubator.quasimondo.com>
// ==================================================
void fastblur(PImage img,int radius, PImage imageBlurred)
{
 if (radius<1){
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum,gsum,bsum,x,y,i,p,p1,p2,yp,yi,yw;
  int vmin[] = new int[max(w,h)];
  int vmax[] = new int[max(w,h)];
  int[] pix=img.pixels;
  int[] pix2=imageBlurred.pixels;
  int dv[]=new int[256*div];
  for (i=0;i<256*div;i++){
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0;y<h;y++){
    rsum=gsum=bsum=0;
    for(i=-radius;i<=radius;i++){
      p=pix[yi+min(wm,max(i,0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0;x<w;x++){

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if(y==0){
        vmin[x]=min(x+radius+1,wm);
        vmax[x]=max(x-radius,0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0;x<w;x++){
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for(i=-radius;i<=radius;i++){
      yi=max(0,yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0;y<h;y++){
      pix2[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if(x==0){
        vmin[y]=min(y+radius+1,hm)*w;
        vmax[y]=max(y-radius,0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }
  
  imageBlurred.updatePixels();

}

void blurTwo(int tt) {
  loadPixels();
  for(int ttt = 0; ttt <= tt; ttt++)
  {
    int R,G,B,left,right,top,bottom;
    int c,cl,cr,ct,cb;
    int w1=width-1;
    int h1=height-1;
    int index=0;
    for(int y=0;y<height; y++) 
    {
      top=(y>0) ? -width : h1*width;
      bottom=(y==h1) ? -h1*width : width;
      for(int x=0; x<width; x++) 
      {
        // Wraparound offsets
        left=(x>0) ? -1 : w1;
        right=(x<w1) ? 1 : -w1;

        c=pixels[index];
        cl=pixels[left+index];
        cr=pixels[right+index];
        ct=pixels[top+index];
        cb=pixels[bottom+index];
        if(c+cl+cr+ct+cb!=0)
        {
          // Calculate the sum of all neighbors
          R=((cl>>16 & 255) + (cr>>16 & 255) + (c>>16 & 255) + (ct>>16 & 255) + (cb>>16 & 255)) / 5;
          G=((cl>>8 & 255) + (cr>>8 & 255) + (c>>8 & 255) + (ct>>8 & 255) + (cb>>8 & 255)) / 5;
          B=((cl & 255) + (cr & 255) + (c & 255) + (ct & 255) + (cb & 255)) / 5;
          pixels[index++]=(R<<16)+(G<<8)+B;
        }
        else
        {
          index++;
        }
      }
    }
  }
  updatePixels();
}
