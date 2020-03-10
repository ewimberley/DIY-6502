.org $1300 
pushall:
PHA ;push a
TXA 
PHA ;push X
TYA
PHA ;push y
PHP ;push status
RTS

restoreall:
PLP
PLA
TAY ;restore y
PLA
TAX ;restore x
PLA ;restore a
RTS

;irq
.org $1320
JSR pushall 
JSR restoreall
RTI

;nmi
.org $1350
JSR pushall 
JSR restoreall
RTI

;reset
.org $1390
JMP start
