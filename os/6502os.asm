;00XX	Zero page
;01XX	Stack
;02XX	IO
;03xx	Devices Procedures
;04XX	Static
;06XX	Interrupts
;07XX	OS Main
;1XXX	Working memory
;FFFX	Interrupt address page

.org $0700

start:
NOP
JMP start ;OS loop
