#include <WiFi.h>
#include "ThingSpeak.h"
#include "DHT.h"
#include <GP2YDustSensor.h>
#include <HTTPClient.h>

const char* ssid = "vivo 1820";            //WiFi name 
const char* password = "bhavishya";        //WiFi Password
WiFiClient  client;
// Domain Name with full URL Path for HTTP POST Request
const char* serverName = "http://api.thingspeak.com/update";
// Service API Key
String apiKey = "UIO08O5RT9LRUP4H";

unsigned long lastTime = 0;
unsigned long timerDelay = 10000;
#define DHTPIN 33                 // Pin used for DHT11 sensor
#define MQ7PIN 32                 // Pin used for MQ7 sensor
#define MQ135Pin 35               // Pin used for MQ135 sensor
#define PMPINVO 34                // Analog Pin used for dust sensor
#define PMPINLED 18               // Digital Pin used for dust sensor
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);         // dht11 sensor function
GP2YDustSensor dustSensor(GP2YDustSensorType::GP2Y1010AU0F, PMPINLED, PMPINVO);       // Dust sensor function
void setup() {
  Serial.begin(9600);
  dht.begin();
  dustSensor.begin();
  WiFi.mode(WIFI_STA);
  ThingSpeak.begin(client);
}

void loop() {
  if ((millis() - lastTime) > timerDelay) {
    // Connect or reconnect to WiFi
    if (WiFi.status() != WL_CONNECTED) {
      Serial.print("Attempting to connect");
      while (WiFi.status() != WL_CONNECTED) {
        WiFi.begin(ssid, password);
        delay(2000);
      }
      Serial.println("\nConnected.");
    }
    // Getting values of Temperature and Humidity using DHT11 Sensor
    float temperatureC = dht.readTemperature();
    Serial.print("Temperature(ºC): ");
    Serial.print(temperatureC);
    Serial.println("°C");
    float Humidity = dht.readHumidity();
    Serial.print("Humidity: ");
    Serial.print(Humidity);
    Serial.println("%");
    
    // Getting Value of Carbon Monoxide(CO) using MQ7 Sensor
    int CO = analogRead(32);
    CO = map(CO, 0, 4095, 0, 1000);
    Serial.print("CO Value: ");
    Serial.print(CO);
    Serial.println(" PPM");

    //Getting Value of Smoke and other gases using MQ135 Sensor
    int smoke = analogRead(33);
    smoke = map(smoke, 0, 4095, 0, 1000);
    Serial.print("Smoke and others: ");
    Serial.print(smoke); // analog data
    Serial.println(" PPM");

    //Getting dust density using dust sensor
    int Dust = dustSensor.getDustDensity();
    int runningAverage = dustSensor.getRunningAverage();
    Serial.print("Dust density: ");
    Serial.print(Dust);
    Serial.println(" ug/m3");
    Serial.print("Running average:");
    Serial.print(runningAverage);
    Serial.println(" ug/m3");
    
    delay(1000);
    HTTPClient http;
    http.begin(client, serverName);
    // Specify content-type header
    http.addHeader("Content-Type", "application/x-www-form-urlencoded");
    // Data to send with HTTP POST
    String httpRequestData = "api_key=" + apiKey + "&field1=" + temperatureC + "&field2=" + Humidity +
                             "&field3=" + CO + "&field4=" + smoke + "&field5=" + Dust;
    // Send HTTP POST request
    int httpResponseCode = http.POST(httpRequestData);

    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);

    http.end();
    lastTime = millis();
  }
}
