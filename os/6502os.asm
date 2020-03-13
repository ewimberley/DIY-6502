.org $1000
LDX #$00
LDY #$08 
JSR cp_static_to_zp
LDX #$00
LDY #$08 
JSR console_print

start:
LDX #$10
LDY #$12 
JSR cp_static_to_zp
LDX #$00
LDY #$02 
JSR console_print
LDX #$00
LDY #$10
JSR console_read
LDX #$00
LDY #$10
JSR console_print
LDX #$15
LDY #$16 
JSR cp_static_to_zp
LDX #$00
LDY #$01
JSR console_print

JMP start ;OS loop
