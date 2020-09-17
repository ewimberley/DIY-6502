;Memory map
define ^ZP $00			;Zero page
;$000X				Device memory variables
;$001X				Terminal memory variables
;$002X				Common memory variables
;$0060-007E			Mini ZP Buffer
define ^MINI_BUFF $60
;$007F-00FF			ZP buffer
define ZP_BUFFER $7F
define ^ZP_BUFFER_LEN $80 

define ^STACK $0100		;Stack
;$1000				OS Main
define STATIC $1100		;Static
;$1200				Devices Procedures
;$1300				Interrupts
;$1400				Common
;$1500				Terminal
define WMEM $2000		;Working memory
define SPECIAL $FFF0		;Interrupt address page

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

.org $1120
.byte ^E ^R ^R ^O ^R ^SP

.org $1130
.byte ^C ^A ^T ^SP

.org $1140
.byte ^S ^A ^V ^E ^SP

.org $1150
.byte ^R ^M ^SP

.org $1160
.byte ^E ^X ^E ^C ^SP


.org $1170
.byte ^H ^E ^L ^L ^O ^SP ^W ^O ^R ^L ^D
