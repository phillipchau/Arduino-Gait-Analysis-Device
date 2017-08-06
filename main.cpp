#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>
#include <SPI.h>
#include <SD.h>
#define SampleRate 10
#define NumSamples 600
#define BNO055_SAMPLERATE_DELAY_MS (100)
Adafruit_BNO055 bno = Adafruit_BNO055();

int inPin = 2;         // the number of the input pin
int outPin = 13;       // the number of the output pin
int state = 0;         // the current state of the output pin
int reading;           // the current reading from the input pin
File DataFile;
unsigned long starttime, delta; 
unsigned long stoptime; 
bool power; // determines current source of power
const long interval = 15; 
void setup(void)
{
  power = true; 
  pinMode(inPin, INPUT_PULLUP);
  pinMode(outPin, OUTPUT);
  Serial.begin(115200); // Open serial communications and wait for port to open:
  delay(100); 
  if (!Serial) {
    power = false; 
  }
  if (!SD.begin(SS1)) {
    if (power = true){
      Serial.println("initialization failed!");
    }
    while(1);
  }
 if(!bno.begin())
  {
   if (power = true){
    Serial.print("Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!");
   }
    while(1);
  }
  delay(1000);
}
void GetToSd(){
  int maximum = 0; 
  int minimum = 1000; 
  unsigned long lasttime, currenttime; 
  if (SD.exists("test2.txt")){
    SD.remove("test2.txt");
  }
  DataFile = SD.open("test2.txt", FILE_WRITE);
  starttime = millis();
  if (DataFile){
    lasttime = starttime; 
    for (int i = 0; i< NumSamples; i++){
      currenttime = millis(); 
      imu::Vector<3> acc = bno.getVector(Adafruit_BNO055::VECTOR_ACCELEROMETER);
      imu::Vector<3> euler = bno.getVector(Adafruit_BNO055::VECTOR_EULER);
      DataFile.print(acc.x());
      DataFile.print(' ');
      DataFile.print(acc.y());
      DataFile.print(' ');
      DataFile.print(acc.z());
      DataFile.print (' ');
      DataFile.print(euler.x());
      DataFile.print(' ');
      DataFile.print(euler.y());
      DataFile.print(' ');
      DataFile.print(euler.z());
      DataFile.println(' '); 
      delta = currenttime - lasttime; 
      while (delta<interval){
        currenttime = millis(); 
        delta = currenttime - lasttime;
      }
      if (delta > maximum){
        maximum = delta;
      }
      if (delta<minimum){
        minimum = delta; 
      }
      lasttime = currenttime; 
    }
   stoptime = millis();
   DataFile.print("This is the total time: ");
   DataFile.println (stoptime-starttime); 
   DataFile.print ("This is our maximum and minimum times: ");
   DataFile.print (maximum); 
   DataFile.print (" "); 
   DataFile.print (minimum); 
   DataFile.close();
  }
}
void SDRead(){
  DataFile = SD.open ("test2.txt");
  if (DataFile){
    while (DataFile.available()){
      Serial.write(DataFile.read());
    }
  }
  DataFile.close();
}

bool CheckButton(){
  state = digitalRead(inPin);
  if (state == LOW){
    return true;
  }
  return false;
  digitalWrite(outPin, HIGH);
}

void loop(void)
{
  while (CheckButton() == false){
  }
  digitalWrite(outPin, HIGH);
  GetToSd(); 
  if (power = true){
    SDRead(); 
  }
  delay(100); 
  digitalWrite (outPin, LOW);
  while (CheckButton() == true){ 
  }
 }
  
 
  




