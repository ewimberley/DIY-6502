;char definitions
define A #$10
define B #$11
define C #$12
define D #$13
define E #$14
define F #$15
define G #$16
define H #$17
define I #$18
define J #$19
define K #$20
define L #$21
define M #$22
define N #$23
define O #$24
define P #$25
define Q #$26
define R #$27
define S #$28
define T #$29
define U #$30
define V #$31
define W #$32
define X #$33
define Y #$34
define Z #$35

;RESET interrupt
.org $fffc ;lsb
.byte #$00
.org $fffd ;msb
.byte #$07

;IRQ interrupt
.org $fffe ;lsb
.byte #$00
.org $ffff ;msb
.byte #$06

;NMI interrupt
.org $fffa ;lsb
.byte #$50
.org $fffb ;msb
.byte #$06

.org $0600
irq:
PHA
PHP
PLP
PLA
RTI

.org $0650
nmi:
PHA
PHP
PLP
PLA
RTI

;start
.org $0700
NOP

define CONSOLE_C $0200
define CONSOLE_I $0201
define CONSOLE_O $0202

read_console:
NOP
RTS

write_console:
NOP
RTS
