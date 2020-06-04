#include <EEPROM.h>

#define READ_WRITE 34
#define CLOCK_OUT 9
#define CLOCK_IN 8
#define READY 12
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
#define DEBUG 1
#define STEP 1
#define FREQ 200

const char ADDR[] = {35, 36, 37, 38, 39, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23};
const char DATA[] = {25, 26, 27, 28, 29, 30, 31, 32};
//const char DATA[] = {32, 31, 30, 29, 28, 27, 26, 25};
char MEM[65536];

int step = STEP;

int get_console_input = 0;
#define INPUT_LEN 0x7F
char input[INPUT_LEN];
int console_in_pointer = 0;

void clock_rising() {
  char output[19];
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
      data = input[console_in_pointer++];
      if (console_in_pointer == MEM[CONSOLE_LEN_ADDR]) {
        //debug_mem_range(0x7f, 0x8f);
        MEM[CONSOLE_LEN_ADDR] = 0;
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
      get_console_input = data;
    } else if (address == DISK_BUFF_ADDR) {
      //EEPROM.write(i+0xC00, data);
    } else {
      MEM[address] = data;
    }
  }
  if (DEBUG) {
    char cmd_buff[4];
    String cmd = disassemble(data);
    cmd.toCharArray(cmd_buff, 4);
    sprintf(output, "   %04x  %c  %02x %s", address, readPin ? 'R' : 'W', data, cmd_buff);
    Serial.println(output);
  }
  if (console_write_status) {
    if (DEBUG) {
      Serial.print("Console: ");
    }
    //debug_mem_range(0x7f, 0x8f);
    Serial.print(console_write);
    if (DEBUG) {
      Serial.println();
    }
  }
}

void debug_mem_range(int start, int stop){
  Serial.print("Debug mem range: ");
  for(int i = start; i < stop; i+=1){
    Serial.print(MEM[i]);
  }
  Serial.println();
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
  pinMode(READY, OUTPUT);
  digitalWrite(READY, HIGH);
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
  if(!STEP) {
    tone(CLOCK_OUT, FREQ);
  }
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

void stepClocks(int n){
  for(int i = 0; i < n; i++){
    digitalWrite(CLOCK_OUT, HIGH);
    delay(10);
    digitalWrite(CLOCK_OUT, LOW);
  } 
}

void printZP(int hex){
  Serial.print("0\t");
  for(int i = 0; i < 0x100; i++){
    if(hex == 1){
      Serial.print((int)MEM[i], HEX);
    } else {
      Serial.print(MEM[i]);
    }
    Serial.print(" ");
    if(((i+1)%4) == 0){
      Serial.print("\t");
    }
    if(((i+1)%16) == 0){
      Serial.print("\n");
      Serial.print(i+1, HEX);
      Serial.print("\t");
    }
  }
}

void loop() {
  if(step){
    String c = Serial.readString();
    if(c.equals("S\n")) { //step
      stepClocks(1);
    } else if(c.equals("S5\n")) { //step
      stepClocks(5);
    } else if(c.equals("S10\n")) { //step
      stepClocks(10);
    } else if(c.equals("S20\n")) { //step
      stepClocks(20);
    } else if(c.equals("S50\n")) { //step
      stepClocks(50);
    } else if(c[0] == 'C'){
      step = 0;
      tone(CLOCK_OUT, FREQ);
    } else if(c.equals("ZH\n")){
      printZP(1);
    } else if(c.equals("Z\n")){
      printZP(1);
    } else {
      //do nothing
    }
  }
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
    MEM[CONSOLE_LEN_ADDR] = console_in_pointer;
    MEM[CONSOLE_S_ADDR] = 1;
    console_in_pointer = 0;
    get_console_input = 0;
  }
}

String disassemble(byte x){
  switch(x){
    case 0x61:
    case 0x65:
    case 0x69:
    case 0x71:
      return "ADC";
    case 0xE5:
    case 0xE9:
    case 0xED:
    case 0xF1:
      return "SBC";
    case 0x21:
    case 0x25:
    case 0x29:
    case 0x2D:
    case 0x31:
      return "AND";
    case 0x01:
    case 0x05:
    case 0x09:
    case 0x0D:
    case 0x11:
      return "ORA";
    case 0x45:
    case 0x49:
    case 0x4D:
    case 0x55:
    case 0x59:
    case 0x5D:
    case 0x51:
      return "EOR";
    case 0x26:
    case 0x2A:
    case 0x2E:
      return "ROL";
    case 0x66:
    case 0x6A:
    case 0x6E:
      return "ROR";
    case 0x0A:
      return "ASL";
    case 0x4A:
    case 0x46:
    case 0x4E:
      return "LSR";
    case 0xE6:
    case 0xEE:
    case 0xF6:
    case 0xFE:
      return "INC";
    case 0xC6:
    case 0xCE:
    case 0xD6:
    case 0xDE:
      return "DEC";
    case 0x24:
    case 0x2C:
      return "BIT";
    case 0x10:
      return "BPL";
    case 0x30:
      return "BMI";
    case 0x50:
      return "BVC";
    case 0x70:
      return "BCC";
    case 0x90:
      return "BCS";
    case 0xD0:
      return "BNE";
    case 0xF0:
      return "BEQ";
    case 0xC5:
    case 0xC9:
    case 0xCD:
      return "CMP";
    case 0xE0:
    case 0xE4:
    case 0xEC:
      return "CPX";
    case 0xC0:
    case 0xC4:
    case 0xCC:
      return "CPY";
    case 0xA1:
    case 0xA5:
    case 0xA9:
    case 0xAD:
    case 0xB1:
    case 0xB5:
    case 0xB9:
    case 0xBD:
      return "LDA";
    case 0xA2:
    case 0xA6:
    case 0xAE:
    case 0xB6:
    case 0xBE:
      return "LDX";
    case 0xA0:
    case 0xA4:
    case 0xAC:
    case 0xB4:
    case 0xBC:
      return "LDY";
    case 0x88:
      return "DEY";
    case 0x8A:
      return "TXA";
    case 0x98:
      return "TYA";
    case 0xA8:
      return "TAY";
    case 0xAA:
      return "TAX";
    case 0xC8:
      return "INY";
    case 0xCA:
      return "DEX";
    case 0xE8:
      return "INX";
    case 0x4C:
    case 0x6C:
      return "JMP";
    case 0x20:
      return "JSR";
    case 0x40:
      return "RTI";
    case 0x60:
      return "RTS";
    case 0x48:
      return "PHA";
    case 0x08:
      return "PHP";
    case 0x28:
      return "PLP";
    case 0x68:
      return "PLA";
    case 0x18:
      return "CLC";
    case 0x38:
      return "SEC";
    case 0x58:
      return "CLI";
    case 0x78:
      return "SEI";
    case 0xB8:
      return "CLV";
    case 0xD8:
      return "CLD";
    case 0xF8:
      return "SED";
    case 0x85:
    case 0x8D:
    case 0x95:
    case 0x99:
    case 0x9D:
      return "STA";
    case 0x86:
    case 0x8E:
    case 0x96:
      return "STX";
    case 0x84:
    case 0x8C:
    case 0x94:
      return "STY";
    case 0x00:
      return "BRK";
    case 0xEA:
      return "NOP";
    default:
      return "XXX";
  }
}
