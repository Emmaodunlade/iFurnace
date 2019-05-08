#include <Arduino.h>
#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include <ESP8266WiFi.h>
#include <LiquidCrystal_I2C.h>
#include <Wire.h>

#include <max6675.h>

LiquidCrystal_I2C lcd(0x27,20,4);

// Replace with your network credentials
//set as desired
const char* ssid     = "";
const char* password = "";

// Set web server port number to 80
ESP8266WebServer server(80);

// Variable to store the HTTP request
//String header;

// Auxiliar variables to store the current output state
uint8_t holdTime;
uint8_t heatingRate;
uint8_t coolingRate;
uint8_t maxHeating;
uint8_t maxCooling;
uint8_t onState; 
uint8_t powerState; 
const int heater = D8;
int ktcSO = D6;
int ktcCS = D7;
int ktcCLK = D5;

MAX6675 ktc(ktcCLK, ktcCS, ktcSO);

void setup() {
  Serial.begin(115200); 
  // Initialize the output variables as outputs
  pinMode(heater, OUTPUT);
  digitalWrite(heater, HIGH);
  lcd.init(); 
  lcd.backlight();
  lcd.setCursor(3,1);
  lcd.print("Ben-FCS (iFurnace)");
  lcd.setCursor(2,2);
  lcd.print("Temp. Control v1.1");
  lcd.setCursor(0,3);
  lcd.print("Henry Benjamin(2019)");
  delay(1000);
  lcd.clear();
  lcd.setCursor(5,0);
  lcd.print("Welcome!");
  lcd.setCursor(1,1);
  lcd.print(" Setting up WiFi..");
    // Connect to Wi-Fi network with SSID and password
  Serial.print("Setting AP (Access Point)…");
  // Remove the password parameter, if you want the AP (Access Point) to be open
  WiFi.softAP(ssid, password);
  IPAddress IP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(IP);
  lcd.setCursor(3,2);
  lcd.print("IP:");
  lcd.setCursor(6,2);
  lcd.print(IP);
  lcd.setCursor(4,3);
  lcd.print("System Ready!");
  server.on("/config", handlesave);
  server.on("/power", handlepower);
  server.begin();
  delay(1000);
}

void loop()
{
  server.handleClient(); //Handling of incoming requests
  Serial.println(holdTime);
  Serial.println(heatingRate);
  Serial.println(coolingRate);
  Serial.println(maxHeating);
  Serial.println(maxCooling);
  Serial.println(powerState);

  int DC = ktc.readCelsius();

  
  while (DC < maxHeating)
  {
    if (powerState == 1)
     {
        digitalWrite(heater, LOW);
        lcd.clear();
        lcd.setCursor(2,1);
        lcd.print("System Running!");
        lcd.setCursor(2,2);
        lcd.print("Temp = ");
        lcd.setCursor(6,2);
        lcd.print (ktc.readCelsius());
  
      }
      else
      {
         digitalWrite(heater,HIGH);
         lcd.clear();
         lcd.print("Cooling!");
         lcd.setCursor(2,2);
         lcd.print("Temp = ");
         lcd.setCursor(6,2);
         lcd.print (ktc.readCelsius());
      }

      if ( powerState == 0)
      {
        break;
      }
  }
}
  

void handlesave()
{
  holdTime = atoi((server.arg("ht")).c_str());
  heatingRate =  atoi((server.arg("hr")).c_str());
  coolingRate = atoi((server.arg("cr")).c_str());
  maxHeating = atoi((server.arg("mh")).c_str());
  maxCooling = atoi((server.arg("mc")).c_str());
  
  server.sendHeader("Connection", "close");
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "text/plain", ""); //Returns the HTTP response
}

void handlepower()
{
  powerState = atoi((server.arg("state")).c_str());
  server.sendHeader("Connection", "close");
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "text/plain", ""); //Returns the HTTP response
}
