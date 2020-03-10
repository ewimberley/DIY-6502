define BUFFER_SIZE $20
define BUFFER $20

define CONSOLE_C $0210 ;control
define CONSOLE_S $0211 ;status 0=ready, 1=busy

define DISK_C $0220 ;control
define DISK_S $0221 ;status 0=ready, 1=busy

.org $1200

;TODO not reentrant safe
;a = from
;x = to
;y = length 
copy:
RTS
