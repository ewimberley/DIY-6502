;Memory map
define ^ZP $00		;Zero page
define ^STACK $0100	;Stack
define ^IO $0200	;IO
define ^MAIN $1000	;OS Main
define STATIC $1100	;Static
define ^DEV $1200	;Devices Procedures
define ^INT $1300	;Interrupts
define WMEM $2000	;Working memory
define SPECIAL $FFF0	;Interrupt address page

;char definitions
define ^SP #$20
define ^DOT #$2E
define ^DOLLAR #$24
define ^LF #$12
define ^ZERO #$30
define ^ONE #$31
define ^TWO #$32
define ^THREE #$33
define ^FOUR #$34
define ^FIVE #$35
define ^SIX #$36
define ^SEVEN #$37
define ^EIGHT #$38
define ^NINE #$39
define ^A #$41
define ^B #$42
define ^C #$43
define ^D #$44
define ^E #$45
define ^F #$46
define ^G #$47
define ^H #$48
define ^I #$49
define ^J #$4A
define ^K #$4B
define ^L #$4C
define ^M #$4D
define ^N #$4E
define ^O #$4F
define ^P #$50
define ^Q #$51
define ^R #$52
define ^S #$53
define ^T #$54
define ^U #$55
define ^V #$56
define ^W #$57
define ^X #$58
define ^Y #$59
define ^Z #$5A

.org $1100

;OS boot message
.byte ^E ^R ^I ^C ^SP ^O ^S ^LF 

.org $1110
.byte ^DOLLAR ^SP ;console sentinal

.org $1115
.byte ^LF
