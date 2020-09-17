.org $1000
LDA #$11
STA %CP_TO_ZP_OFFSET_HB 
LDA #$00
STA %CP_TO_ZP_OFFSET_LB

;print bootup message
LDA #ZP_BUFFER
LDX #$00
LDY #$08 
JSR cp_static_to_zp
LDX #$00
LDY #$08 
JSR console_print

start:
;JSR terminal_loop ;TODO finish terminal
LDA #ZP_BUFFER
LDX #$70
LDY #$80
JSR cp_static_to_zp
LDX #$00
LDY #$10
JSR console_print
BRK
