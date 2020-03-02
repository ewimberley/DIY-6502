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

define CONSOLE_C $0200
define CONSOLE_I $0201
define CONSOLE_O $0202

;start
NOP

irq:
PHA
PHP
PLP
PLA
RTI

nmi:
PHA
PHP
PLP
PLA
RTI

read_console:
NOP
RTS

write_console:
NOP
RTS
