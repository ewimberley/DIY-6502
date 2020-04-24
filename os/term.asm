.org $1500

.byte #$30 #$40 #$50 #$60 ;offsets to command strings

terminal_loop:
JSR print_sential
;read 30 bytes max
LDX #$00
LDY #$30
JSR console_read
JSR parse_command 
JSR print_nl
JMP terminal_loop
RTS

print_sential:
LDA ^DOLLAR
LDX #$00
STA ZP_BUFFER,X
LDA ^SP
LDX #$01
STA ZP_BUFFER,X
LDX #$00
LDY #$02
JSR console_print
RTS

define COMMAND $10  
define SP_INDEX $11

parse_command:
;find index of first space in command string
LDX #$00
LDY ^SP
JSR index_of
STX SP_INDEX
;loop over command strings until one matches
LDX #$FF
STX COMMAND
command_parse_loop:
;add one to command array index
LDA COMMAND
ADC #$01
STA COMMAND
TAX
;copy string from available commands array to minibuffer
LDA $1500,X
TAX
ADC #$0F
TAY
LDA ^MINI_BUFF 
JSR cp_static_to_zp
;compare minibuffer to buffer up to index of first space
LDA ^MINI_BUFF
ADC SP_INDEX
TAY
LDA ^MINI_BUFF
LDX #$00
JSR compare
;if not match, check next command
TXA
CMP #$01
BNE command_parse_loop
;execute command
JSR cat
;no such command
no_such_command:
JSR print_error
RTS

cat:
LDX #$30
LDY #$34 
JSR cp_static_to_zp
LDX #$00
LDY #$04
JSR console_print
RTS
