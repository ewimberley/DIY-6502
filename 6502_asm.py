import os
import sys
from lark import Lark, Transformer, v_args
import logging
logger = logging.getLogger("asm")
#logging.basicConfig(level=logging.DEBUG)

grammar = """
    start: line*

    line: (setlabel | command)? COMMENT? NEWLINE
    
    command: WORD (value | address | zerop | indir | label)? ("," register)?
    
    value: "#$" HEXDIGIT HEXDIGIT
    
    address: "$" HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT
    
    indir: "(" (address | zerop) ("," register)? ")" 
    
    zerop: "$" HEXDIGIT HEXDIGIT
    
    register: a | x | y
    
    a: "A"
    
    x: "X" 
    
    y: "Y"
    
    label: CNAME
    
    setlabel: label ":"
    
    COMMENT: ";" /.*/ 
    %import common.INT 
    %import common.HEXDIGIT
    %import common.WORD   
    %import common.CNAME
    %import common.WS_INLINE
    %import common.NEWLINE
    %import common.ESCAPED_STRING
    %ignore WS_INLINE 
"""

parser = Lark(grammar)

debug = True

class OverflowException(Exception):
    pass

def parse_file(file_name):
    with open(file_name, "r") as file:
        data = file.read()
        return parser.parse(data)

def parse_hex_num(tree):
    nums = []
    for child in tree.children:
        if len(nums) > 0 and len(nums[0]) == 1:
            nums[0] += str(child)
        else:
            nums = [str(child)] + nums
    return nums

def short_to_signed_hex_byte(short):
    byte = hex(0)
    if short > 0 and short < 128:
         byte = hex(short)
    elif short < 0 and short >= -128:
        byte = hex(short + 256)
    else:
        raise OverflowException()
    hexcode = byte[2:]
    return "0" + hexcode if len(hexcode) == 1 else hexcode

def codegen(tree, instruction_set):
    labels = {}
    addr_to_label = {}
    rom = ["00"] * 0xFFFF
    address = 0x600
    for line in tree.children:
        command = line.children[0]
        logger.debug(command)
        if line.children[0].data == "setlabel":
            label = str(command.children[0].children[0])
            labels[label] = address
        if line.children[0].data == "command":
            address = assemble_command(addr_to_label, command, address, instruction_set, rom)
    compute_jmp_offsets(addr_to_label, labels, rom)
    logger.debug(rom[0x0600:0x0700])
    switch_endian(rom)
    #print(rom[0x0600:0x0700])
    return bytes.fromhex("".join(rom))

def assemble_command(address_to_label, command, instruction_address, instruction_set, rom):
    parameter = None
    opcode = None
    param_type = "none"
    index_param = "none"
    for index, child in enumerate(command.children):
        if index == 0:
            opcode = str(child)
        elif index == 1:
            param_type = child.data
            if child.data == "value":
                parameter = parse_hex_num(child)
            elif child.data == "address":
                parameter = parse_hex_num(child)
            elif child.data == "label":
                parameter = str(child.children[0])
            elif child.data == "zerop":
                parameter = parse_hex_num(child)
            elif child.data == "indir":
                parameter = parse_hex_num(child.children[0])
    logger.debug(opcode + "\t" + str(parameter))
    possible_ops = instruction_set[opcode]
    op_definition = None
    for op in possible_ops:
        if op['ptype'] == param_type:
            op_definition = op
    logger.debug(opcode + "\t" + str(op_definition))
    rom[instruction_address] = op_definition['hex']
    instruction_address += 1
    if param_type != "none":
        if param_type == "label":
            # rom[instruction_address] = labels[parameter]
            address_to_label[instruction_address] = parameter
            instruction_address += 1
        else:
            for num in parameter:
                rom[instruction_address] = num
                instruction_address += 1
    return instruction_address

def compute_jmp_offsets(address_to_label, labels, rom):
    for address in address_to_label:
        label = address_to_label[address]
        offset = labels[label] - address - 1
        byte = short_to_signed_hex_byte(offset)
        rom[address] = byte

def switch_endian(rom):
    i = 0
    while i + 1 < len(rom):
        tmp = rom[i]
        rom[i] = rom[i + 1]
        rom[i + 1] = tmp
        i += 2

def main(argv):
    instruction_set = {}
    with open("opcodes.txt", "r") as file:
        line = file.readline()
        while line:
            parts = line.rstrip().split("\t")
            opcode = parts[0]
            if opcode not in instruction_set:
                instruction_set[opcode] = []
            instruction_set[opcode].append({'hex':parts[1], 'ptype':parts[2]})
            line = file.readline()
    tree = parse_file(argv[0])
    rom = codegen(tree, instruction_set)
    #print(rom[0x0600:0x0700])
    with open("rom.bin", "wb") as file:
        file.write(rom)

if __name__ == "__main__":
    main(sys.argv[1:])


