// Apocalyptic "Fire And Rainbows" art piece by Andrew Parker, Sept 2015
// For CCNTH Computer Science "Art Night" project, example code
// This code is all about for loops, arrays, and the random() function!

int n_small = 7;
int n_medium = 2;
int n_ash = 100;
int n_laser = 0;
Meteor[] smalls = new Meteor[n_small];
Meteor[] mediums = new Meteor[n_medium];
ParticleGen[] generators = new ParticleGen[n_small+3*n_medium+1];
float[] ashx = new float[n_ash];
float[] ashy = new float[n_ash];
int[] lasertopx = new int[n_laser];
int[] laserbotx = new int[n_laser];

PGraphics bb; //blur buffer
PGraphics pb; //particle buffer
PGraphics bg; //background buffer

void setup(){
  size(640,360);
  bb = createGraphics(width,height); //blur buffer
  pb = createGraphics(width,height); //particle buffer
  bg = createGraphics(width,height); //background buffer
  bb.beginDraw();
  bb.endDraw();
  pb.beginDraw();
  pb.endDraw();
  colorMode(HSB,100);
  for (int i=0; i<n_small; i++){
    smalls[i] = new Meteor(random(750), random(300),0.8,1.3,115,3,15,30);
  }
  for (int i=0; i<n_medium; i++){
    mediums[i] = new Meteor(random(750), random(300),2,3,115,6,40,75);
  }
  for (int i=0; i<n_ash; i++){
    ashx[i] = random(width);
    ashy[i] = random(height);
  }
  for (int i=0; i<n_laser; i++){
    lasertopx[i] = (int)random(width);
    laserbotx[i] = (int)random(width);
  }
  
  //////BACKGROUND////////////////////////
  bg.beginDraw();
  bg.colorMode(HSB,100);
  
  //sky
  bg.noStroke();  
  for (int y=0; y<360; y+=1){
    float h = 60+y/8;
    float s = 100-y/6.0;
    if (h > 100) {h-=100;}
    bg.fill(h, s, y/8);
    bg.rect(0,y,640,1);
  }
  
  //Rainbow
  bg.strokeWeight(2);
  bg.noFill();
  for (int i=0; i<=100; i+=2){
   bg.stroke(i,60,75,(100-i)>>3);
   bg.ellipse(width/4, height, height*2.3-i, height*2.3-i);
  }
  bg.endDraw();
}

void draw(){
  image(bg,0,0);
  noStroke();
  color red = color(3,100,100);
  color whellow = color(12,30,100);
  color yellow = color(12,100,100);
  color black = color(0,100,0,100);
  color trans = color(0,100,0,0);
  
  //small meteors
  for (Meteor m : smalls){
     m.update();
     if (m.ypos >= 320 && !m.impact){
       m.impact = true;
       ParticleGen pg = new ParticleGen(m.xpos, m.ypos, 10, 5);
       pg.setColors(0xFFDFAA66, 0x99AF2100, 0x00130000);
       pg.setLaunch(m.speed*0.3,m.speed*2,180,360);
       pg.setSize(0.5,1.5);
       pg.setLifespan(35,60);
       pg.setResistance(0.5);
       addGen(pg, generators);
     }
  }
  
  //medium meteors
  for (Meteor m : mediums){
     m.update();
     if (m.ypos >= 320 && !m.impact){
       m.impact = true;
       
       ParticleGen fr = new ParticleGen(m.xpos, m.ypos, 500, 1);
       fr.setColors(whellow, color(6,90,100,90), trans);
       fr.setLaunch(m.speed*0.2,m.speed*1.5,180,360);
       fr.setSize(4,10);
       fr.setRand(1);
       fr.setLifespan(35,60);
       fr.setResistance(0.5);
       fr.triangle = true;
       addGen(fr, generators);
       
       ParticleGen pg = new ParticleGen(m.xpos, m.ypos, 30, 1);
       pg.setColors(whellow, 0xFFDD9955, trans);
       pg.setLaunch(m.speed*0.5,m.speed*3,190,350);
       pg.setSize(2,4);
       pg.setLifespan(45,85);
       pg.setResistance(0.55);
       pg.setGrav(0.02,90);
       addGen(pg, generators);
       
       ParticleGen smk = new ParticleGen(m.xpos, m.ypos-2,20,15);
       smk.setColors(color(12,12,100,10), color(12,0,0,5), color(12,0,0,1));
       smk.setGrav(0.05,270);
       smk.setResistance(0.6);
       smk.setLaunch(0.03,5,180,360);
       smk.setRand(2);
       smk.setLifespan(120,250);
       smk.setSize(1,15);
       smk.blur();
       addGen(smk, generators);
     }
  }
  
  //lasers
  for (int i=0; i<n_laser; i++){
    lasertopx[i] += (int)random(-5, 5);
    laserbotx[i] += (int)random(-5, 5);
    stroke(0,100,100,100);
    if (random(10)<0.5){
      stroke(0,100,90,90);
      strokeWeight(3);
      line(lasertopx[i], 0, laserbotx[i], 320);
      stroke(0,25,100,50);
      strokeWeight(1);
      line(lasertopx[i], 0, laserbotx[i], 320);
    }
    noStroke();
  }
  
  // particles
  if(bb.pixels != null){
    boolean makenull = true;
    int[] a_buff = new int[width*height];
    int[] r_buff = new int[width*height];
    int[] g_buff = new int[width*height];
    int[] b_buff = new int[width*height];
    for (int i = 0; i<width*height; i++){
      if (bb.pixels[i] != 0){
        a_buff[i] = bb.pixels[i]>>24 & 0xff;
        r_buff[i] = bb.pixels[i]>>16 & 0xff;
        g_buff[i] = bb.pixels[i]>>8 & 0xff;
        b_buff[i] = bb.pixels[i] & 0xff;
        makenull = false;
      }
    }
    fastBigBlur(r_buff, 3);
    fastBigBlur(a_buff, 3);
    fastBigBlur(g_buff, 3);
    fastBigBlur(b_buff, 3);
    for (int i=width*height-1; i>=0; i--){
      bb.pixels[i] = a_buff[i]<<24 | r_buff[i]<<16 | g_buff[i]<<8 | b_buff[i];
    }
    //alphaNoise(bb.pixels, 255);
    if (makenull){
      bb.pixels = null;
    }
  }
  for (int i=0;i<width*height;i++){
    if (pb.pixels[i] != 0){
      int a = pb.pixels[i]>>24 & 0xFF;
      int rest = pb.pixels[i] & 0xFFFFFF;
      a -= 10;
      if (a<=0){
        pb.pixels[i] = 0;
      }
      else {
        pb.pixels[i] = a<<24 | rest;
      }
    }
  }
  image(bb, 0, 0);
  image(pb, 0, 0);
  pb.updatePixels();
  bb.clear();
  //pb.clear();//****************************************************
  
  //ash
  color[] ashcolors = new color[3];
  ashcolors[0] = yellow;
  ashcolors[1] = red;
  ashcolors[2] = black;
  for (int i=0; i<n_ash; i++){
    fill(ashcolors[int(random(3))]);
    ellipse(ashx[i],ashy[i],1,1);
    ashy[i] += random(0.05,0.2);
    ashx[i] += random(-0.5,0.5);
    if (ashy[i]>height-20){
      ashy[i] = -3;
    }
  }
  
  //ground
  fill(6);
  rect(0,320,640,40);
  
/////////////////////////////////////////////////////////////////////////////////////

  for (int i=generators.length-1; i>=0; i--){
    ParticleGen g = generators[i];
    if (g!=null){
      g.step();
      if (g.particles.size()==0){
        removeGen(g, generators);
      }
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

class Meteor {
  float speed, direction, size, xpos, ypos, smin, smax, trail_l, trailint;
  int trail_n;
  PVector vect, tvect;
  float[] trailx, traily;
  boolean impact;
  Meteor(float x, float y, float vmin, float vmax, float d, float s, int t_n, float t_l){
    impact = false;
    size = s;
    direction = d;
    smin = vmin;
    smax = vmax;
    speed = random(smin, smax);
    xpos = x;
    ypos = y;
    trail_n = t_n;
    trail_l = t_l;
    vect = PVector.fromAngle(radians(direction));
    trailx = new float[trail_n];
    traily = new float[trail_n];
    trailint = trail_l/trail_n;
    reset();
  }
  
  void reset(){
    for (int i=0; i<trail_n; i++){
      vect.setMag((i+1)*trailint);
      trailx[i] = vect.x;
      traily[i] = vect.y;
    }
    vect.setMag(speed);
    impact = false;
  }
  
  void update(){
    xpos += vect.x;
    ypos += vect.y;
    if (ypos > 360+size/2){
      xpos = random(750);
      ypos = 0-size/2;
      speed = random(smin,smax);
      direction = random(100,115);
      vect = PVector.fromAngle(radians(direction)).setMag(speed);
      reset();
    }
    for (int i=0; i<trail_n; i++){
      fill(12-i/float(trail_n-1)*12,100,100,100-(i/float(trail_n-1))*80);
      float nsize = size-(size/4)-(i/float(trail_n-1))*(size*0.66);
      ellipse(xpos-trailx[i],ypos-traily[i],nsize,nsize);
    }
    color[] warpcolor = {color(12,50,100), color(0,100,100,50)};
    vect.limit(1);
    fill(warpcolor[int(random(2))]);
    ellipse(xpos+vect.x,ypos+vect.y,size+1,size+1);
    vect.setMag(speed);
    fill(0);
    ellipse(xpos,ypos,size,size);
  }
}

class ParticleGen {
  float x, y, smin, smax, grav, gravdir, res, rand, vmin, vmax, dmin, dmax;
  int num, lifetime, plmin, plmax;
  color c1, c2, c3;
  boolean triangle = false;
  boolean blur = false;
  PGraphics bf = pb;
  ArrayList<Particle> particles = new ArrayList<Particle>();
  
  ParticleGen(float xpos, float ypos, int number, int lt){
    x = xpos;
    y = ypos;
    num = number;
    lifetime = lt;
    plmin = 50;
    plmax = 51;
    smin = 4;
    smax = 6;
    grav = 0;
    gravdir = 0;
    res = 0;
    rand = 0;
    vmin = 0;
    vmax = 0;
    dmin = 0;
    dmax = 0;
  }
  
  void step(){
    if (!isDone()){
      for (int i=0; i<num; i++){
        Particle p = new Particle(x,y,random(smin, smax),int(random(plmin,plmax)), bf);
        p.setColors(c1, c2, c3);
        p.setLaunch(random(vmin, vmax), random(dmin, dmax));
        p.setRandom(rand);
        p.setGravity(grav, gravdir);
        p.setResistance(res);
        p.triangle = triangle;
        particles.add(p);
      }
      if (lifetime != -1) {
        lifetime--;
      }
    }
    if (blur){
      bb.beginDraw();
      for (int i=particles.size()-1; i >= 0; i--){
        Particle p = particles.get(i);
        if (p.isDead()){
          particles.remove(i);
        }
        else {
          p.update();
        }
      }
      bb.endDraw();
    }
    else {
      pb.beginDraw();
      for (int i=particles.size()-1; i >= 0; i--){
        Particle p = particles.get(i);
        if (p.isDead()){
          particles.remove(i);
        }
        else {
          p.update();
        }
      }
      pb.endDraw();
    }
  }
  
  void blur(){
    blur = true;
    bf = bb;
  }
  void setLaunch(float vn, float vx, float dn, float dx){
    vmin = vn;
    vmax = vx;
    dmin = dn;
    dmax = dx;
  }
  void setGrav(float gmag, float gdir){
    grav = gmag;
    gravdir = gdir;
  }
  void setResistance(float r){
    res = r;
  }
  void setRand(float r){
    rand = r;
  }
  void setSize(float min, float max){
    smin = min;
    smax = max;
  }
  void setColors(color a, color b, color c){
   c1 = a;
   c2 = b;
   c3 = c;
  }
  void setLifespan(int min, int max){
    plmin = min;
    plmax = max;
  }
  
  boolean isDone(){
    if (lifetime == 0) {
      return true;
    }
    else {return false;}
  }
}

class Particle {
  float x, y, size, iv, idr, res, grav, grava, rnd;
  color c1, c2, c3, curr;
  int ls, lsi;
  PVector v, g, r, z, f;
  boolean triangle = false;
  PGraphics bf;
  Particle(float xpos, float ypos, float diameter, int lifespan, PGraphics bfr){
    x = xpos;
    y = ypos;
    size = diameter;
    iv = 0;
    idr = 0;
    res = 0;
    grav = 0;
    grava = 0;
    rnd = 0;
    c1 = color(50,100,100,0);
    c2 = c1;
    c3 = c1;
    curr = c1;
    ls = lifespan;
    lsi = ls;
    bf = bfr;
    v = PVector.fromAngle(radians(idr)).setMag(iv);
    g = PVector.fromAngle(grava).setMag(grav);
    f = new PVector(0,0);
  }
  void setColors(color a, color b, color c){
    c1 = a;
    c2 = b;
    c3 = c;
  }
  void setRandom(float n){
    rnd = n;
  }
  void setGravity(float mag, float direc){
    grav = mag;
    grava = radians(direc);
    g = PVector.fromAngle(grava).setMag(grav);
  }
  void setLaunch(float vel, float d){
    iv = vel;
    idr = d;
    v = PVector.fromAngle(radians(idr)).setMag(iv);
  }
  void setResistance(float n){
    res = n;
  }
  void update(){
    x += f.x;
    y += f.y;
    bf.fill(curr);
    bf.noStroke();
    if (triangle){
      PVector tri = new PVector(1,1);
      tri.setMag(size/1.27);
      tri.rotate(random(TWO_PI));
      float tx1 = x+tri.x;
      float ty1 = y+tri.y;
      tri.rotate(random(radians(15),radians(120)));
      float tx2 = x+tri.x;
      float ty2 = y+tri.y;
      tri.rotate(random(radians(15),radians(120)));
      float tx3 = x+tri.x;
      float ty3 = y+tri.y;
      bf.triangle(tx1, ty1, tx2, ty2, tx3, ty3);
    }
    else{
      bf.ellipse(x, y, size, size);
    }
    v.add(g);
    r = PVector.fromAngle(v.heading()).setMag(v.mag()).mult(res*-0.1);
    v.add(r);
    z = PVector.random2D().setMag(random(rnd));
    f = PVector.add(v,z);
    ls -= 1;
    if (ls >= 0.5*lsi){
      curr = lerpColor(c1, c2, (lsi-ls)/(lsi*0.5));
    }
    else {
      curr = lerpColor(c2, c3, (lsi*0.5-ls)/(lsi*0.5));
    }
  }
  
  boolean isDead(){
    if (ls <= 0){
      return true;
    }
    else {
      return false;
    }
      
  }
}

void addGen(ParticleGen pg, ParticleGen[] a){
  boolean success = false;
  for (int i=0; i<a.length; i++){
    if (a[i] == null){
      a[i] = pg;
      success = true;
      break;
    }
  }
  if (!success){println("No room, addGen() failed.");}
}

void removeGen(ParticleGen pg, ParticleGen[] a){
  for (int i=0; i<a.length; i++){
    if (a[i] == pg){
      a[i] = null;
    }
  }
}

void fastBigBlur (int[] buf, int m) {
  int id, k;
  int lim = width*(height-m);
 
  id = m*width+1;
  k=0;
  for (; id<lim; id+=1+k+k) {
    for (int i=1+k; i<width-1; i+=2, id+=2) {
      buf [id] = (buf[id-m]+buf[id+m]+buf[id+m*width]+buf[id-m*width])>>2;
    }
 
    k = 1-k;
  }
 
  id = m*width+2;
  k=1;
  for (; id<lim; id+=1+k+k) {
    for (int i=1+k; i<width-1; i+=2, id+=2) {
      buf [id] = (buf[id-m]+buf[id+m]+buf[id+m*width]+buf[id-m*width])>>2;
    }
    k = 1-k;
  }
}

void alphaNoise(int[] buf, int amt){
  for (int i=0; i<width*height;i++){
    if (buf[i] != 0){
      int a = buf[i]>>24&0xFF;
      a += max(0, min(255, (int)random(-amt, amt/10)));
      buf[i] = a<<24 | (buf[i]&0xFFFFFF);
    }
  }
}