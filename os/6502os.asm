.org $1000
LDX #$00
LDY #$08 
JSR cp_static_to_zp
LDX #$00
LDY #$08 
JSR console_print
start:
NOP
JMP start ;OS loop
