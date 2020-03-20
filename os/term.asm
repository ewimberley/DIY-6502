.org $1500

.byte #$20 #$30 #$40 ;offsets to command strings

define COMMAND $10  

parse_command:
LDA ^MINI_BUFF 
LDX #$20 ;TODO replace with command string offset from above
LDY #$23
JSR cp_static_to_zp
LDX #$00
LDY ^SP
JSR index_of
LDA ^MINI_BUFF
;LDY ^MINI_BUFF+X
;JSR compare
