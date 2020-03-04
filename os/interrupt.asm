;RESET interrupt
.org $fffc ;lsb
.byte #$90
.org $fffd ;msb
.byte #$06

;IRQ interrupt
.org $fffe ;lsb
.byte #$20
.org $ffff ;msb
.byte #$06

;NMI interrupt
.org $fffa ;lsb
.byte #$50
.org $fffb ;msb
.byte #$06

.org $0600 
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
.org $0620
JSR pushall 
JSR restoreall
RTI

;nmi
.org $0650
JSR pushall 
JSR restoreall
RTI

;reset
.org $0690
JMP start
