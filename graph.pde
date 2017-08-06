import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JCheckBox; //add package for checkbox implementation 
import javax.swing.JLabel;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;

JFrame frame;
JPanel panel;
JLabel label;
JCheckBox X, Y, Z, GX, GY, GZ;  
final int tickx = 50; //constant for tick distance in x-axis
final int ticky = 75;  //constant for tick distance in y-axis
final int accWidth = 1500; //Width of screen 
final int accHeight = 1300;  //Height of screen 
int error = 0; //variable that stores error count
int j = 0; // buffer counter
BufferedReader reader; 
String line; 
int a = 600; //define size of array containing serial data 
float [] buffZ = new float[a]; //array to hold serial data 
float [] buffX = new float[a];
float [] buffY = new float[a];
float [] gyroX = new float[a];
float [] gyroY = new float[a]; 
float [] gyroZ = new float[a]; 
float [] hold = new float[a]; 
int tracker = 0; 
float X0, Y0, X1, Y1 = 0; //starting and ending points of line 
int modex, modey, modez, modegx, modegy, modegz; 
int centerX = 0, centerY = 0, offsetX = 0, offsetY = 0; 
float avgz, avgy, avgx, avgz2; 
float x1, z1, y1; 
float [] buffZ2 = new float[a]; // z buffer after z-y rotation 
float [] buffZ3 = new float[a]; //z buffer after z-x rotation 
float [] buffX2 = new float[a]; // x buffer after x-z rotation 
float [] buffY2 = new float[a]; // y buffer after z-y rotation 
float zoom = 2; 

void setup(){
  size (1200, 1000); //define size of window 
  centerX = 0;
  centerY = 0; 
  cursor(HAND); 
  smooth(); 
  rectMode (CENTER);
  label = new JLabel("Graph Options"); 
  frame = new JFrame("Graph");
  panel = new JPanel();
  X = new JCheckBox("AccelerationX"); //create checkboxes for acceleration 
  Y = new JCheckBox("AccelerationY");
  Z = new JCheckBox("AccelerationZ");
  GX = new JCheckBox("GyroscopeX");
  GY = new JCheckBox("GyroscopeY");
  GZ = new JCheckBox("GyroscopeZ"); 
  guilistener listener = new guilistener(); 
  X.addItemListener(listener);
  Y.addItemListener(listener); 
  Z.addItemListener(listener); 
  GX.addItemListener(listener);
  GY.addItemListener(listener);
  GZ.addItemListener(listener); 
  panel.add(label);
  panel.add(X);
  panel.add(Y);
  panel.add(Z); 
  panel.add(GX);
  panel.add(GY);
  panel.add(GZ);
  frame.getContentPane().add(panel);
  frame.pack();
  frame.setVisible(true);
  noStroke();
  background (255);  
  reader = createReader("TEST2.TXT");
  data(); 
}

class guilistener implements ItemListener //class to create button selection 
{
  public void itemStateChanged(ItemEvent event)
  {
    if(X.isSelected()){
      modex = 1; 
    }
    else modex = 0; 
    if(Y.isSelected()){
      modey = 1;
    }
    else modey = 0;
    if (Z.isSelected()){
      modez = 1; 
    }
    else modez = 0;
    if (GX.isSelected()){
      modegx = 1;
    }
    else modegx = 0;
    if (GY.isSelected()){
      modegy = 1;
    }
    else modegy = 0;
    if (GZ.isSelected()){
      modegz = 1;
    }
    else modegz = 0; 
  }
}

void draw (){ 
   background(255);  
   scale (0.75); 
   if (mousePressed == true){
     centerX = mouseX-offsetX;
     centerY = mouseY-offsetY; 
   }
   translate(centerX, centerY); 
   DrawGraph();   
   calibrate(); 
   if (modex == 1){
     Plot (buffX2, #008000, ticky);
   }
   if (modey == 1){
     Plot (buffY2, #ff0000, ticky); 
   }
   if (modez == 1){
     Plot (buffZ3, #0000ff, ticky); 
   }
   translate (0, -700); 
   GyroGraph();
   if (modegx == 1){
     PlotGyro (gyroX, #008000, 0.85);
   }
   if (modegy == 1){
     PlotGyro (gyroY, #ff0000, 0.85);
   }
   if (modegz == 1){
     PlotGyro (gyroZ, #0000ff, 0.85); 
   }
 }  
void mousePressed(){
  offsetX = mouseX - centerX;
  offsetY = mouseY - centerY; 
}
void keyPressed(){
  if (keyCode == UP) zoom += 2;
  if (keyCode == DOWN) zoom -= 2; 
}

void DrawGraph (){ //draws the axis of the graph 
  pushMatrix(); 
  stroke (0); //black line
  translate (50, 10); //translate graph 
  line (0, 600, accWidth+2000, 600); //plot x axis
  line (0, 0, 0, 600); //plot y axis
  for (int i = tickx; i< accWidth+2000; i+= tickx){ //plot x axis ticks
    line (i, 605, i, 595); //draw ticker line 
    float xtext = map(i, 0, 500, 0, 100); // rescale graph 
    textSize(16); 
    fill(50); //make text black
    text (String.format("%.1f",(xtext/zoom)), i-6, 635); //draw axis numbers 
  }
  for (int i = 0; i<=600; i+=ticky){//plot y axis ticks
    line (-5, i, 5, i);
    stroke(1);
    line (0, i, accWidth+2000, i); 
    textSize (20);
    fill(50); //make text black
    float ytext = map(i, 600, 0, -4, 4);
    text(round(ytext), -45, i+10); 
    text("G", -20, i+10); 
  }
  popMatrix();
}

void GyroGraph(){
  pushMatrix(); 
  stroke (0); //black line
  translate (50, 10); //translate graph 
  line (0, 600, accWidth+2000, 600); //plot x axis
  line (0, 0, 0, 600); //plot y axis
  for (int i = tickx; i< accWidth+2000; i+= tickx){ //plot x axis ticks
    line (i, 590, i, 610); //draw ticker line 
    float xtext = map(i, 0, 500, 0, 100); // rescale graph 
    textSize(16); 
    fill(50); //make text black
    text (String.format("%.1f",(xtext/zoom)), i-6, 635); //draw axis numbers 
  }
  for (int i = 0; i<=600; i+=ticky){//plot y axis ticks
    line (-5, i, 5, i);
    textSize (20);
     line (0, i, accWidth+2000, i);
    fill(50); //make text black
    float ytext = map(i, 0, 600, 360, -360);
    text(round(ytext), -70, i); 
  }
  popMatrix();
}

void data() {
 for (int i = 0; i<a; i++){
  try {
    line = reader.readLine();
  } catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  if (line == null) {
    // Stop reading because of an error or file is empty
    println("We got a null"); 
    noLoop();  
  } else {
    String[] pieces = split(line, ' ');
    print ("The length of pieces is "); 
    println (pieces.length); 
    buffX[i] = float(pieces[0])/9.8;
    buffY[i] = float(pieces[1])/9.8;
    buffZ[i] = (float (pieces[2]))/9.8;
    println(line); 
    calibrate ();  
    gyroX[i] = (float (pieces[3]));
    gyroY[i] = (float (pieces[4]));
    gyroZ[i] = (float (pieces[5]));  
    }
  }
}

void Plot (float hold[], int Color, float scale){
  pushMatrix();
  stroke (Color); 
  strokeWeight(2);
  translate (50,315); 
  X1 = 0;
  Y1 = hold[0];
  for (int i =0; i<a; i++){ //graphs data from array 
    Y0 = Y1; //makes new starting Y value previous value 
    X0 = X1; // makes new starting X value previous value 
    Y1 = hold[i]; //updates Y axis from serial data 
    if (Y1 < -4){
      Y1 = -4;
    }
    if (Y1 > 4){
      Y1 = 4;
    }
    X1 = i; //updates x value  
    line (X0*zoom, -Y0*scale, X1*zoom, -Y1*scale); 
    }
    popMatrix();
}
void PlotGyro (float hold[], int Color, float scale){
  pushMatrix();
  stroke (Color); 
  strokeWeight(2);
  translate (50,315); 
  X1 = 0;
  Y1 = hold[0];
  for (int i =0; i<a; i++){ //graphs data from array 
    Y0 = Y1; //makes new starting Y value previous value 
    X0 = X1; // makes new starting X value previous value 
    Y1 = hold[i]; //updates Y axis from serial data 
    if (Y1>360){
      Y1 = 360;
    }
    if (Y1<-360){
      Y1 = -360; 
    }
    X1 = i; //updates x value  
    line (X0*zoom, -Y0*scale, X1*zoom, -Y1*scale); 
    }
    popMatrix();
}

void calibrate (){
  for (int i = 0; i<10; i++){
    avgx = avgx + buffX[i]; 
    avgy = avgy + buffY[i];
    avgz = avgz + buffZ[i]; 
  }
  avgx = avgx/10; 
  avgy = avgy/10;
  avgz = avgz/10; 
  float ytheta = atan2(avgy,avgz);
  for (int i = 0; i<a; i++){
    buffY2[i] = buffY[i]*cos(ytheta) - buffZ[i]*sin(ytheta); 
    buffZ2[i] = buffY[i]*sin(ytheta) + buffZ[i]*cos(ytheta); 
  }
  for (int i = 0; i<10; i++){
    avgz2 = avgz2 +buffZ2[i]; 
  }
  avgz2 = avgz2/10; 
  float xtheta = atan2(avgx, avgz2); 
  for (int i = 0; i<a; i++){
    buffX2[i] = buffX[i]*cos(xtheta) - buffZ2[i]*sin(xtheta); 
    buffZ3[i] = buffX[i]*sin(xtheta) + buffZ2[i]*cos(xtheta); 
  }
}
  
  
  
  


  
