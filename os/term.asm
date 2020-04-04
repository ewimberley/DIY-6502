.org $1500

.byte #$20 #$30 #$40 #$50 #$60 ;offsets to command strings

define COMMAND $10  
define COMMAND_SP_INDEX $11

parse_command:
LDX #$00
STX COMMAND
command_parse_loop:
LDA $1500,X
TAX
ADC #$0F
TAY
LDA ^MINI_BUFF 
JSR cp_static_to_zp
LDX #$00
LDY ^SP
JSR index_of
LDA ^MINI_BUFF
STX COMMAND_SP_INDEX
ADC COMMAND_SP_INDEX
TAY
LDA ^MINI_BUFF
JSR compare


cat:
