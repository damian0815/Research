
float scl = 30;

void setup()
{
  size (400,400,P3D);
}

void keyPressed()
{
  if (key==CODED) {
    if ( keyCode==UP ) {
      scl *= 1.1f;
    } else if ( keyCode==DOWN) {
      scl /= 1.1f;
    }
  }
}

void draw()
{
  
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), 
            cameraZ/10.0, cameraZ*10.0);
            
  translate( width/2, height/2, 1 );
 // translate(width/2+30, height/2, 0);
  //rotateX(-PI/6);
  rotateY(-PI/2 + mouseX/float(width) * PI);
  rotateX(-PI/2 + mouseY/float(height) * PI);
  scale(scl,-scl,scl);
  
  background(192);
  
  
  pushMatrix();
  stroke(0);
  fill(255,255,255,32);  
  translate(0,0,-0.005);
  box(10,10,0.01);
  popMatrix();

  stroke(255,128,0);  
  noFill();
  
  
  beginShape();
  vertex(0.000000,0.000000,0.000000);
  bezierVertex(-1.333333,0.000000,0.333333, -4.614636,0.000000,-0.229273, -4.000000,0.000000,1.000000);
  bezierVertex(-3.239883,0.000000,2.520234, -0.592666,-0.265444,1.469111, 1.000000,0.000000,2.000000);
  bezierVertex(1.541002,0.090167,2.180334, 1.666667,0.666667,2.666667, 2.000000,1.000000,3.000000);
  endShape();
  pushMatrix(); translate(0.000000,0.000000,0.000000); sphere(0.1f); popMatrix();
  pushMatrix(); translate(-4.000000,0.000000,1.000000); sphere(0.1f); popMatrix();
  pushMatrix(); translate(1.000000,0.000000,2.000000); sphere(0.1f); popMatrix();
  pushMatrix(); translate(2.000000,1.000000,3.000000); sphere(0.1f); popMatrix();
}
