.org $1000
LDA #$11
STA %CP_TO_ZP_OFFSET_HB 
LDA #$00
STA %CP_TO_ZP_OFFSET_LB

;print bootup message
LDX #$00
LDY #$08 
JSR cp_static_to_zp
LDX #$00
LDY #$08 
JSR console_print

start:
JSR terminal_loop
BRK
