#include <EEPROM.h>

const char data[] = {!};
const int data_len = @;

void setup() {
  Serial.begin(57600);
  delay(200);
  Serial.print("Flashing EEPROM...\n");
  for(int i = 0; i < data_len; i++){
    EEPROM.update(i, data[i]);
  }
}

void loop() {}
