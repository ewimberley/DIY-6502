define BUFFER_SIZE $20
define BUFFER $20

define CONSOLE_C $0210 ;control
define CONSOLE_S $0211 ;status 0=ready, 1=busy
define CONSOLE_BUFF $0212

define DISK_C $0220 ;control
define DISK_S $0221 ;status 0=ready, 1=busy
define DISK_BUFF $0222

define POINTER $00

.org $1200

;TODO not reentrant safe
;x = from
;y = to 
console_print_static:
STX POINTER
CPY POINTER
BEQ console_print_static_done
LDA STATIC,X
STA CONSOLE_BUFF
INX
console_print_static_done:
RTS
