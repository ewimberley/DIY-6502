import os
import sys
from lark import Lark, Transformer, v_args

grammar = """
    start: line*

    line: (command | label) COMMENT? NEWLINE
    
    command: WORD (value | address)?
    
    value: "#$" HEXDIGIT HEXDIGIT
    
    address: "$" HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT
    
    label: CNAME ":"
    
    COMMENT: ";" /.*/ 
    %import common.INT 
    %import common.HEXDIGIT
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

def parse_hex_num(tree):
    nums = []
    for child in tree.children:
        if len(nums) > 0 and len(nums[0]) == 1:
            nums[0] += str(child)
        else:
            nums = [str(child)] + nums
    return nums

def codegen(tree, instruction_set):
    #rom = bytearray([0x00] * 0xFFFF)
    rom = ["00"] * 0xFFFF
    instruction_address = 0x600
    for line in tree.children:
        if line.children[0].data == "command":
            command = line.children[0]
            print(command)
            parameter = None
            opcode = None
            param_type = None
            for index, child in enumerate(command.children):
                if index == 0:
                    opcode = str(child)
                elif index == 1:
                    if child.data == "value":
                        parameter = parse_hex_num(child)
                        param_type = "value"
                    elif child.data == "address":
                        parameter = parse_hex_num(child)
                        param_type = "address"
            print(opcode + "\t" + str(parameter))
            possible_ops = instruction_set[opcode]
            op_definition = None
            for op in possible_ops:
                if op['ptype'] == param_type:
                    op_definition = op
            print(possible_ops)
            print(op)
            rom[instruction_address] = op_definition['hex']
            instruction_address += 1
            for num in parameter:
                rom[instruction_address] = num
                instruction_address += 1
    print(rom[0x0600:0x0700])
    i = 0
    while i+1 < len(rom):
        tmp = rom[i]
        rom[i] = rom[i+1]
        rom[i+1] = tmp
        i += 2
    print(rom[0x0600:0x0700])
    #bytes = bytearray([0x00] * 0xFFFF)
    #for i, byte in enumerate(rom):
    #    bytes[i] = byte.decode("hex")
    #return bytearray("".join(rom))
    return bytes.fromhex("".join(rom))
    #return bytes

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
    print(rom[0x0600:0x0700])
    with open("rom.bin", "wb") as file:
        file.write(rom)

if __name__ == "__main__":
    main(sys.argv[1:])


