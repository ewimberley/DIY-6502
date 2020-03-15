define ZP_BUFFER $7F
define ZP_BUFFER_LEN $80 

define CP_TO_ZP_FROM_POINTER $00
define CP_TO_ZP_TO_POINTER $01
define CONSOLE_PRINT_POINTER $02
define CONSOLE_READ_POINTER $03
define CONSOLE_READ_LEN_TMP $04

.org $1200

;Copy static page to ZP buffer
;x = from
;y = to 
cp_static_to_zp:
STX CP_TO_ZP_FROM_POINTER 
LDX #$00
STX CP_TO_ZP_TO_POINTER
cp_static_to_zp_loop:
CPY CP_TO_ZP_FROM_POINTER ;if from == to
BEQ cp_static_to_zp_done 
;load byte from static
LDX CP_TO_ZP_FROM_POINTER
LDA STATIC,X
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

define CONSOLE_LEN $0210
define CONSOLE_S $0211 ;status 0=empty, 1=buffered 
define CONSOLE_C $0212 ;status 0=not reading, 1=reading
define CONSOLE_BUFF $0213

;Print ZP buffer to console
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

;Read console to ZP buffer
;x = to
;y = max_len
;TODO check max_len
console_read:
LDA #$01
STA CONSOLE_C
length_poll_loop:
LDA CONSOLE_S
CMP #$00
BEQ length_poll_loop ;wait for input
LDY CONSOLE_LEN
STY CONSOLE_READ_LEN_TMP
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
LDY CONSOLE_READ_LEN_TMP ;return string length
RTS

define DISK_POS $0220 
define DISK_LEN $0221
define DISK_S $0222 ;status 0=ready, 1=write, 2=read, 3=busy, 4=failed

;Write ZP buffer to disk (uses direct memory access)
;x = disk position
;y = length
disk_write:
STX DISK_POS
STY DISK_LEN
LDA #$01
STA DISK_S
disk_write_wait_loop:
LDA DISK_S
CMP #$00
BNE disk_write_wait_loop
;TODO support failed status
RTS

;Read disk to ZP buffer (uses direct memory access)
;x = disk position
;y = length
disk_read:
STX DISK_POS
STY DISK_LEN
LDA #$02
STA DISK_S
disk_write_wait_loop:
LDA DISK_S
CMP #$00
BNE disk_write_wait_loop
;TODO support failed status
RTS
