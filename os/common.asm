define CP_TO_ZP_FROM_POINTER $20
define CP_TO_ZP_TO_POINTER $21

define %CP_TO_ZP_OFFSET_HB $23
define %CP_TO_ZP_OFFSET_LB $22

define CP_TO_ZP_OFFSET_HB_LOC $141B
define CP_TO_ZP_OFFSET_LB_LOC $141A
define CP_TO_ZP_OFFSET_ZP_LOC $1422

.org $1400

;Copy static page to ZP buffer
;a = zp start
;x = from
;y = to 
cp_static_to_zp:
STA CP_TO_ZP_OFFSET_ZP_LOC
STX CP_TO_ZP_FROM_POINTER 
;polymorphic code: change address of static page within this function
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
STA $FF,X
INX
STX CP_TO_ZP_TO_POINTER
JMP cp_static_to_zp_loop 
cp_static_to_zp_done:
RTS

define CP_FROM_ZP_FROM_POINTER $24
define CP_FROM_ZP_TO_POINTER $25

define CP_FROM_ZP_OFFSET_HB_LOC $144F
define CP_FROM_ZP_OFFSET_LB_LOC $144E
define CP_FROM_ZP_OFFSET_ZP_LOC $1447

.org $1430

;Copy ZP buffer to static page
;a = zp start
;x = from
;y = to 
cp_static_from_zp:
;polymorphic code: change address of static page within this function
STA CP_FROM_ZP_OFFSET_ZP_LOC
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
LDA $FF,X
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

define INDEX_OF_CHAR $26

;Find the first instance of a char in the ZP buffer
;x = start
;y = char
index_of:
STY INDEX_OF_CHAR
index_of_loop:
LDA ZP_BUFFER,X
CMP INDEX_OF_CHAR
BEQ index_of_end
INX
JMP index_of_loop 
index_of_end:
RTS ;x returns index

define COMPARE_OTHER $27
define COMPARE_END $28

;Compare the ZP buffer with another char array in the zp
;a = other
;x = start
;y = end
compare:
STA COMPARE_OTHER
STY COMPARE_END
compare_loop:
LDA ZP_BUFFER,X
CMP COMPARE_OTHER
BNE compare_not_equal
CPX COMPARE_END 
BEQ compare_equal
INX
JMP compare_loop
compare_not_equal:
LDX #$00;
RTS ;x returns false 
compare_equal:
LDX #$01;
RTS ;x returns true 

print_nl:
LDA ^LF
LDX #$00
STA ZP_BUFFER,X
LDX #$00
LDY #$01
JSR console_print
RTS

;x = error number
print_error:
LDX #$20
LDY #$25 
JSR cp_static_to_zp
LDX #$00
LDY #$05
JSR console_print
RTS
