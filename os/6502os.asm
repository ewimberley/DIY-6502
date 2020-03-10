;00XX	Zero page
;01XX	Stack
;02XX	IO
;10XX	OS Main
;11XX	Static
;12xx	Devices Procedures
;13XX	Interrupts
;2XXX	Working memory
;FFFX	Interrupt address page

.org $1000
LD
JSR copy
start:
NOP
JMP start ;OS loop
