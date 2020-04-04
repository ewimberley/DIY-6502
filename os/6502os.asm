.org $1000
LDA #$11
STA %CP_TO_ZP_OFFSET_HB 
LDA #$00
STA %CP_TO_ZP_OFFSET_LB

LDX #$00
LDY #$08 
JSR cp_static_to_zp
LDX #$00
LDY #$08 
JSR console_print

start:
;print console sentinal
LDX #$10
LDY #$12 
JSR cp_static_to_zp
LDX #$00
LDY #$02 
JSR console_print
;read 30 bytes max
LDX #$00
LDY #$30
JSR console_read
JSR parse_command 
;print nl
LDX #$15
LDY #$16 
JSR cp_static_to_zp
LDX #$00
LDY #$01
JSR console_print
BRK
JMP start ;OS loop
