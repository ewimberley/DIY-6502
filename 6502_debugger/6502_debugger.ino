//const char ADDR[] = {23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 39, 38, 37, 36, 35};
const char ADDR[] = {35, 36, 37, 38, 39, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23};
const char DATA[] = {25, 26, 27, 28, 29, 30, 31, 32};
#define READ_WRITE 34
#define CLOCK 33
#define RESET 24
#define NOP 0xEA
#define DELAY 100
char MEM[65535];

void setup() {
  for(int i = 0; i < 0xFFFF; i+=1){
    MEM[i] = NOP;
  }
  for(int i = 0; i < 16; i+=1){
    pinMode(ADDR[i], INPUT);
  }
  setDataMode(INPUT);
  pinMode(READ_WRITE, INPUT);
  pinMode(CLOCK, OUTPUT);
  pinMode(RESET, OUTPUT);
  Serial.begin(57600);
  digitalWrite(RESET, HIGH);
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
    Serial.print(bit);
  }
}

void loop() {
  char output[15];
  unsigned int address = 0;
  unsigned int data = 0;
  digitalWrite(CLOCK, HIGH);
  int readPin = digitalRead(READ_WRITE);
  for(int i = 0; i < 16; i+= 1){
    int bit = digitalRead(ADDR[i]) ? 1: 0;
    address = (address << 1) + bit;
    Serial.print(bit);
  }
  Serial.print("   ");
  if(readPin){
    setDataMode(OUTPUT);
    data = MEM[address];
    setData(data);
  } else{
    setDataMode(INPUT);
    for(int i = 0; i < 8; i+= 1){
      int bit = digitalRead(DATA[i]) ? 1: 0;
      data = (data << 1) + bit;
      Serial.print(bit);
    }
    MEM[address] = data;
  }
  sprintf(output, "   %04x  %c  %02x", address, readPin ? 'R' : 'W', data);
  Serial.println(output);
  delay(DELAY);
  digitalWrite(CLOCK, LOW);
  delay(DELAY);
}
