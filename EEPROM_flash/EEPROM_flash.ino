#include <EEPROM.h>

const char data[] = {0xEA, 0xEA, 0xEA, 0xEA, 0xEA, 0xEA, 0xEA, 0xEA,
                     0xEA, 0xEA, 0xEA, 0xEA, 0xEA, 0xEA, 0xEA, 0xEA,
                     0xEA, 0xEA, 0xEA, 0xEA, 0xEA, 0xEA, 0xEA, 0xEA,
                     0xEA, 0xEA, 0xEA, 0xEA, 0xEA, 0x4C, 0x00, 0x10,};
const int data_len = 32;

void setup() {
  Serial.begin(57600);
  delay(200);
  Serial.print("Flashing EEPROM...\n");
  for(int i = 0; i < data_len; i++){
    EEPROM.update(i, data[i]);
  }
}

void loop() {}
