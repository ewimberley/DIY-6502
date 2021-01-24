# DIY-6502
 
A custom 6502 that utilizes a Teensy 3.5, along with firmware code and an assembler.

<img src="6502circuit.png"  width="60%">

## Assembling 

To assemble your code, use the 6502_asm.py script, and pass in all assembly files as parameters (order dependent).

```bash
python3 6502_asm.py os/consts.asm os/common.asm os/device.asm  os/interrupt.asm os/term.asm os/6502os.asm
```

The output file is called rom.bin.

## Flashing OS to the EEPROM

Next run the generate_arduino_eeprom_flash.py to generate flash.ino, which can be flashed onto the Teensy to store the OS in the EEPROM.

```bash
generate_arduino_eeprom_flash.py rom.bin
```

Load this flash.ino file in the Arduino IDE and flash it to the Teensy. You should get a confirmation message as shown below.

```
Flashing EEPROM...
Done
```

## Flashing the BIOS / Debugging Firmware

Load the file 6502_debugger/6502_debugger.ino in the Arduino IDE and flash it to the Teensy.

You can boot in normal mode by sending a newline over the serial monitor, or in debug mode by sending "D". The commands S, S5, S10, S20, and S50 run that many clock cycles respectively. The Z command prints the zero page. The C command steps indefinitely.

Below is the output from running "D", "S20", and then "Z". The columns in the debug information for each step are:

address (binary), data (binary), address (hex), read/write, data (hex), the instruction associated with the data byte (if applicable)

```
DIWHY 6502
Eric Wimberley
Boot Address: 1000	Clock 500Hz
0001010000001110   00101000   140e  R  14    
0001010000001110   00101000   140e  R  14    
1111111111111111   11001000   ffff  R  13    
0000000000000000   00000000   0000  R  00 BRK
0000000100000000   00000000   0100  R  00 BRK
0000000111111111   00000000   01ff  R  00 BRK
0000000111111110   00000000   01fe  R  00 BRK
1111111111111100   00000000   fffc  R  00 BRK
1111111111111101   00001000   fffd  R  10 BPL
0001000000000000   10010101   1000  R  a9 LDA
0001000000000001   10001000   1001  R  11 ORA
0001000000000010   10100001   1002  R  85 STA
0001000000000011   11000100   1003  R  23    
0000000000100011   00010001   0023  W  11 
0001000000000100   10010101   1004  R  a9 LDA
0001000000000101   00000000   1005  R  00 BRK
0001000000000110   10100001   1006  R  85 STA
0001000000000111   01000100   1007  R  22    
0000000000100010   00000000   0022  W  00 
0001000000001000   10010101   1008  R  a9 LDA
0	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
10	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
20	0 0 0 11 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
30	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
40	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
50	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
60	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
70	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
80	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
90	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
A0	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
B0	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
C0	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
D0	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
E0	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
F0	0 0 0 0 	0 0 0 0 	0 0 0 0 	0 0 0 0 	
100
```
## References

Ben Eater. https://www.youtube.com/user/eaterbc

W65C02S 8–bit Microprocessor. The Western Design Center, Inc. https://www.westerndesigncenter.com/wdc/documentation/w65c02s.pdf
