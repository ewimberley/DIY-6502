import os
import sys
from lark import Lark, Transformer, v_args

grammar = """
    start: line*

    line: (command | label | COMMENT) NEWLINE
    
    command: nop
    
    label: CNAME ":"
    
    nop: "NOP"

    COMMENT: "#" /.*/ 
    %import common.INT 
    %import common.WORD   
    %import common.CNAME
    %import common.WS
    %import common.NEWLINE
    %import common.ESCAPED_STRING
    %ignore WS 
"""

parser = Lark(grammar)

def parse_file(file_name):
    with open(file_name, "r") as file:
        data = file.read()
        return parser.parse(data)

def main(argv):
    rom = bytearray([0x00] * 0xFFFF)
    tree = parse_file(argv[0])
    with open("rom.bin", "wb") as file:
        file.write(rom)

if __name__ == "__main__":
    main(sys.argv[1:])


