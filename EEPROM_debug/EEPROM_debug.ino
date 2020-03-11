#include <EEPROM.h>

const int data_len = 0xC00;
byte value;

void setup() {
  Serial.begin(57600);
  delay(200);
  Serial.print("EEPROM contents:\n");
  for(int i = 0; i < data_len; i++){
    value = EEPROM.read(i);
    Serial.print(value, HEX);
    Serial.print("\t");
    if(((i+1)%4) == 0){
      Serial.print("\t");
    }
    if(((i+1)%8) == 0){
      Serial.print("\n");
    }
  }
}

void loop() {}
