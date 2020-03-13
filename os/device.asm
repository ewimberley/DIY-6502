define ZP_BUFFER $7F
define ZP_BUFFER_LEN $80 

define CP_TO_ZP_FROM_POINTER $00
define CP_TO_ZP_TO_POINTER $01
define CONSOLE_PRINT_POINTER $02
define CONSOLE_READ_POINTER $03

.org $1200

;x = from
;y = to 
cp_static_to_zp:
STX CP_TO_ZP_FROM_POINTER 
LDX #$00
STX CP_TO_ZP_TO_POINTER
cp_static_to_zp_loop:
LDX CP_TO_ZP_FROM_POINTER
CPY CP_TO_ZP_FROM_POINTER ;if from == to
BEQ cp_static_to_zp_done 
LDA STATIC,X
INX
STX CP_TO_ZP_FROM_POINTER 
LDX CP_TO_ZP_TO_POINTER
STA ZP_BUFFER,X
INX
STX CP_TO_ZP_TO_POINTER
JMP cp_static_to_zp_loop 
cp_static_to_zp_done:
RTS

define CONSOLE_LEN $0210
define CONSOLE_S $0211 ;status 0=empty, 1=buffered 
define CONSOLE_C $0212 ;status 0=not reading, 1=reading
define CONSOLE_BUFF $0213

;x = from
;y = to 
console_print:
STX CONSOLE_PRINT_POINTER
CPY CONSOLE_PRINT_POINTER ;if from == to
BEQ console_print_done
LDA ZP_BUFFER,X
STA CONSOLE_BUFF
INX
JMP console_print
console_print_done:
RTS

;x = to
;y = max_len
;TODO check max_len
console_read:
LDA #$01
STA CONSOLE_C
LDA CONSOLE_S
CMP #$00
BEQ console_read ;wait for input
LDY CONSOLE_LEN
console_read_loop:
CPY #$00 
BEQ console_read_working_done 
LDA CONSOLE_BUFF
STA ZP_BUFFER,X
INX
DEY
JMP console_read_loop
console_read_working_done:
LDA #$00
STA CONSOLE_C
RTS

define DISK_C $0220 ;control
define DISK_S $0221 ;status 0=ready, 1=busy
define DISK_BUFF $0222


