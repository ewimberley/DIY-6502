#include <EEPROM.h>

#define READ_WRITE 34
#define CLOCK_OUT 9
#define CLOCK_IN 8
#define RESET 33
#define IRQB 24
#define NMI 7
#define NOP 0xEA
#define BOOT_ADDR 0x1000

#define CONSOLE_LEN_ADDR 0x0210
#define CONSOLE_S_ADDR 0x0211
#define CONSOLE_C_ADDR 0x0212
#define CONSOLE_BUFF_ADDR 0x0213

#define DISK_C_ADDR 0x0220
#define DISK_S_ADDR 0x0221
#define DISK_BUFF_ADDR 0x0222

//#define FREQ 1000000
#define DEBUG 0
#define FREQ 5000

const char ADDR[] = {35, 36, 37, 38, 39, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23};
const char DATA[] = {25, 26, 27, 28, 29, 30, 31, 32};
//const char DATA[] = {32, 31, 30, 29, 28, 27, 26, 25};
char MEM[65536];

int get_console_input = 0;
#define INPUT_LEN 0x7F
char input[INPUT_LEN];
int console_in_pointer = 0;

void clock_rising() {
  char output[15];
  char console_write;
  int console_write_status = 0;
  unsigned int address = 0;
  unsigned int data = 0;
  int readPin = digitalRead(READ_WRITE);
  for (int i = 0; i < 16; i += 1) {
    int bit = digitalRead(ADDR[i]) ? 1 : 0;
    address = (address << 1) + bit;
    if (DEBUG) {
      Serial.print(bit);
    }
  }
  if (DEBUG) {
    Serial.print("   ");
  }
  if (readPin) {
    setDataMode(OUTPUT);
    if (address == CONSOLE_BUFF_ADDR) {
      data = input[console_in_pointer];
      console_in_pointer++;
      if (data == 0x00) {
        MEM[CONSOLE_S_ADDR] = 0;
      }
    } else {
      data = MEM[address];
    }
    setData(data);
  } else {
    setDataMode(INPUT);
    //for(int i = 0; i < 8; i+= 1){
    for (int i = 7; i >= 0; i -= 1) {
      int bit = digitalRead(DATA[i]) ? 1 : 0;
      data = (data << 1) + bit;
      if (DEBUG) {
        Serial.print(bit);
      }
    }
    if (address == CONSOLE_BUFF_ADDR) {
      console_write = (char)data;
      console_write_status = 1;
    } else if (address == CONSOLE_C_ADDR) {
      if (data == 1) {
        get_console_input = 1;
      }
    } else if (address == DISK_BUFF_ADDR) {
      //EEPROM.write(i+0xC00, data);
    } else {
      MEM[address] = data;
    }
  }
  if (DEBUG) {
    sprintf(output, "   %04x  %c  %02x", address, readPin ? 'R' : 'W', data);
    Serial.println(output);
  }
  if (console_write_status) {
    if (DEBUG) {
      Serial.print("Console: ");
    }
    Serial.print(console_write);
    if (DEBUG) {
      Serial.println();
    }
  }
}

void init_mem() {
  int addr = 0x1000;
  for (int i = 0; i < 3072; i++) {
    MEM[addr] = EEPROM.read(i);
    addr++;
  }
}

void setup() {
  for (int i = 0; i < 0xFFFF; i += 1) {
    MEM[i] = 0X0;
  }
  init_mem();
  //reset
  MEM[0xFFFC] = 0x00;
  MEM[0xFFFD] = 0x10;
  //irq
  MEM[0xFFFE] = 0x20;
  MEM[0xFFFF] = 0x13;
  //nmi
  MEM[0xFFFA] = 0x50;
  MEM[0xFFFB] = 0x13;
  for (int i = 0; i < 16; i += 1) {
    pinMode(ADDR[i], INPUT);
  }
  setDataMode(INPUT);
  pinMode(READ_WRITE, INPUT);
  pinMode(CLOCK_IN, INPUT);
  pinMode(CLOCK_OUT, OUTPUT);
  pinMode(RESET, OUTPUT);
  pinMode(NMI, OUTPUT);
  pinMode(IRQB, OUTPUT);
  digitalWrite(NMI, HIGH);
  digitalWrite(IRQB, HIGH);
  attachInterrupt(digitalPinToInterrupt(CLOCK_IN), clock_rising, RISING);
  digitalWrite(RESET, HIGH);
  Serial.begin(9600);
  while (!Serial.available()) {
    delay(200);
  }
  Serial.read();
  delay(200);
  Serial.println("DIWHY 6502");
  Serial.println("Eric Wimberley");
  char output[40];
  sprintf(output, "Boot Address: %04x\tClock %dHz", BOOT_ADDR, FREQ);
  Serial.println(output);
  delay(200);
  tone(CLOCK_OUT, FREQ);
}

void setDataMode(int mode) {
  for (int i = 0; i < 8; i += 1) {
    pinMode(DATA[i], mode);
  }
}

void setData(int data) {
  for (int i = 0; i < 8; i += 1) {
    int bit = bitRead(data, i);
    digitalWrite(DATA[i], bit);
    if (DEBUG) {
      Serial.print(bit);
    }
  }
}

void loop() {
  if(get_console_input){
    console_in_pointer = 0;
    char c = Serial.read();
    while (c != '\n' && console_in_pointer < (INPUT_LEN-1)) {
      if(int(c) != 255){
        input[console_in_pointer++] = c;
      }
      c = Serial.read();
    }
    input[console_in_pointer] = 0;
    console_in_pointer = 0;
    MEM[CONSOLE_LEN_ADDR] = console_in_pointer;
    MEM[CONSOLE_S_ADDR] = 1;
    get_console_input = 0;
  }
}
