define ZP_BUFFER $7F
define ZP_BUFFER_LEN $80 

define CP_TO_ZP_POINTER $00
define CONSOLE_PRINT_POINTER $01
define CONSOLE_READ_POINTER $02

.org $1200

;x = from
;y = to 
cp_static_to_zp:
STX CP_TO_ZP_POINTER 
CPY CP_TO_ZP_POINTER 
BEQ cp_static_to_zp_done 
LDA STATIC,X
STA ZP_BUFFER,X 
INX
JMP cp_static_to_zp 
cp_static_to_zp_done:
RTS

define CONSOLE_LEN $0210
define CONSOLE_S $0211 ;status 0=empty, 1=buffered 
define CONSOLE_BUFF $0212

;x = from
;y = to 
console_print:
STX CONSOLE_PRINT_POINTER
CPY CONSOLE_PRINT_POINTER
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
RTS

define DISK_C $0220 ;control
define DISK_S $0221 ;status 0=ready, 1=busy
define DISK_BUFF $0222


