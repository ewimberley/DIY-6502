define CP_TO_ZP_FROM_POINTER $20
define CP_TO_ZP_TO_POINTER $21

define %CP_TO_ZP_OFFSET_HB $23
define %CP_TO_ZP_OFFSET_LB $22

define CP_TO_ZP_OFFSET_HB_LOC $1418
define CP_TO_ZP_OFFSET_LB_LOC $1417

.org $1400

;Copy static page to ZP buffer
;x = from
;y = to 
cp_static_to_zp:
STX CP_TO_ZP_FROM_POINTER 
LDX %CP_TO_ZP_OFFSET_HB
STX CP_TO_ZP_OFFSET_HB_LOC
LDX %CP_TO_ZP_OFFSET_LB
STX CP_TO_ZP_OFFSET_LB_LOC
LDX #$00
STX CP_TO_ZP_TO_POINTER
cp_static_to_zp_loop:
CPY CP_TO_ZP_FROM_POINTER ;if from == to
BEQ cp_static_to_zp_done 
;load byte from static
LDX CP_TO_ZP_FROM_POINTER
LDA $FFFF,X
INX
STX CP_TO_ZP_FROM_POINTER 
;store byte to zp
LDX CP_TO_ZP_TO_POINTER
STA ZP_BUFFER,X
INX
STX CP_TO_ZP_TO_POINTER
JMP cp_static_to_zp_loop 
cp_static_to_zp_done:
RTS

define CP_FROM_ZP_FROM_POINTER $24
define CP_FROM_ZP_TO_POINTER $25

define CP_FROM_ZP_OFFSET_HB_LOC $146F
define CP_FROM_ZP_OFFSET_LB_LOC $146E

.org $1450

;Copy ZP buffer to static page
;x = from
;y = to 
cp_static_from_zp:
STX CP_FROM_ZP_FROM_POINTER 
LDX %CP_TO_ZP_OFFSET_HB 
STX CP_FROM_ZP_OFFSET_HB_LOC
LDX %CP_TO_ZP_OFFSET_LB
STX CP_FROM_ZP_OFFSET_LB_LOC
LDX #$00
STX CP_FROM_ZP_TO_POINTER
cp_static_from_zp_loop:
CPY CP_FROM_ZP_FROM_POINTER ;if from == to
BEQ cp_static_from_zp_done 
;load byte from zp
LDX CP_FROM_ZP_FROM_POINTER
LDA ZP_BUFFER,X
INX
STX CP_FROM_ZP_FROM_POINTER
;store byte to static
LDX CP_FROM_ZP_TO_POINTER
STA $FFFF,X
INX
STX CP_FROM_ZP_TO_POINTER 
JMP cp_static_from_zp_loop 
cp_static_from_zp_done:
RTS
