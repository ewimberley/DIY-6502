#include <EEPROM.h>

#define READ_WRITE 34
#define CLOCK_OUT 9
#define CLOCK_IN 8
#define RESET 33
#define IRQB 24
#define NMI 7
#define NOP 0xEA
#define BOOT_ADDR 0x1000
#define FREQ 5
#define DEBUG_PIN 10
const char ADDR[] = {35, 36, 37, 38, 39, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23};
const char DATA[] = {25, 26, 27, 28, 29, 30, 31, 32};
char MEM[65535];
int DEBUG = 0;

void clock_rising(){
  char output[15];
  unsigned int address = 0;
  unsigned int data = 0;
  int readPin = digitalRead(READ_WRITE);
  for(int i = 0; i < 16; i+= 1){
    int bit = digitalRead(ADDR[i]) ? 1: 0;
    address = (address << 1) + bit;
    if(DEBUG) { Serial.print(bit); }
  }
  if(DEBUG) { Serial.print("   "); }
  if(readPin){
    setDataMode(OUTPUT);
    data = MEM[address];
    setData(data);
  } else{
    setDataMode(INPUT);
    for(int i = 0; i < 8; i+= 1){
      int bit = digitalRead(DATA[i]) ? 1: 0;
      data = (data << 1) + bit;
      if(DEBUG) { Serial.print(bit); }
    }
    MEM[address] = data;
  }
  if(DEBUG) {
    sprintf(output, "   %04x  %c  %02x", address, readPin ? 'R' : 'W', data);
    Serial.println(output);
  }
}

void init_mem(){
  int addr = 0x1000;
  for(int i = 0; i < 3072; i++){
    MEM[addr] = EEPROM.read(i);
    addr++;
  }
}

void setup() {
  for(int i = 0; i < 0xFFFF; i+=1){
    MEM[i] = 0X0;
  }
  init_mem();
  MEM[0xFFFC] = 0x00;
  MEM[0xFFFD] = 0x10;
  for(int i = 0; i < 16; i+=1){
    pinMode(ADDR[i], INPUT);
  }
  setDataMode(INPUT);
  pinMode(DEBUG_PIN, INPUT);
  pinMode(READ_WRITE, INPUT);
  pinMode(CLOCK_IN, INPUT);
  pinMode(CLOCK_OUT, OUTPUT);
  pinMode(RESET, OUTPUT);
  pinMode(NMI, OUTPUT);
  pinMode(IRQB, OUTPUT);
  digitalWrite(NMI, HIGH);
  digitalWrite(IRQB, HIGH);
  DEBUG = digitalRead(DEBUG_PIN);
  attachInterrupt(digitalPinToInterrupt(CLOCK_IN), clock_rising, RISING);
  digitalWrite(RESET, HIGH);
  Serial.begin(57600);
  delay(200);
  Serial.println("DIWHY 6502");
  Serial.println("Eric Wimberley");
  char output[40];
  sprintf(output, "Boot Address: %04x\tClock %dHz", BOOT_ADDR, FREQ);
  Serial.println(output);
  tone(CLOCK_OUT, FREQ);
}

void setDataMode(int mode){
  for(int i = 0; i < 8; i+= 1){
    pinMode(DATA[i], mode);
  }
}

void setData(int data){
  for(int i = 0; i < 8; i+= 1){
    int bit = bitRead(data, i);
    digitalWrite(DATA[i], bit);
    if(DEBUG) { Serial.print(bit); }
  }
}

void loop() {
  
}
