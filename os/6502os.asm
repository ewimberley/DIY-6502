.org $1000
LDX #$00
LDY #$07 
JSR console_print_static
start:
NOP
JMP start ;OS loop
