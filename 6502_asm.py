import os
import sys
from lark import Lark, Transformer, v_args
import logging
logger = logging.getLogger("asm")
#logging.basicConfig(level=logging.DEBUG)

syntax_tree_to_type = {'none': 'n', 'label': 'l', 'value': 'v', 'indir': 'i', 'zerop': 'zp', 'address': 'a'}

#TODO: handle negative numbers?
grammar = """
    start: line*

    line: (setlabel | command | pragma)? COMMENT? NEWLINE
    
    command: WORD (value | address | zerop | indir | label)? ("," register)?
    setlabel: label ":"
    pragma: "." (org | byteprag | wordprag)
    
    value: "#$" HEXDIGIT HEXDIGIT
    address: "$" HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT
    word: "#$" HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT
    indir: "(" (address | zerop) ("," register)? ")" 
    zerop: "$" HEXDIGIT HEXDIGIT
    
    register: a | x | y
    a: "A"
    x: "X" 
    y: "Y"
    
    org: "org" address
    byteprag: "byte" value
    wordprag: "word" word
    
    label: CNAME
    
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

def preprocess(code):
    definitions = {}
    processed_code = ""
    for line in code.split("\n"):
        if line.rstrip().lstrip().startswith("define"):
            parts = line.split()
            definitions[parts[1]] = parts[2]
        else:
            processed_line = [part.lstrip().rstrip() for part in line.split()]
            for definition in definitions:
                for i, part in enumerate(processed_line):
                    if definition == part:
                        processed_line[i] = definitions[definition]
            processed_code += " ".join(processed_line) + "\n"
    processed_code = "".join([s for s in processed_code.splitlines(True) if s.strip("\r\n")])
    logger.debug(processed_code)
    return processed_code.lstrip()


def parse_file(file_name):
    with open(file_name, "r") as file:
        data = file.read()
        data = preprocess(data)
        return parser.parse(data)

def parse_hex_num(tree):
    nums = []
    for child in tree.children:
        if len(nums) > 0 and len(nums[0]) == 1:
            nums[0] += str(child)
        else:
            nums = [str(child)] + nums
    return nums

def int_to_signed_hex(i):
    hexcode = hex(i)[2:]
    byte_str = "0" + hexcode if len(hexcode) == 3 else hexcode
    bytes = [byte_str[2:], byte_str[0:2]]
    return bytes

def short_to_signed_hex_byte(short):
    byte = hex(0)
    if short >= 0 and short < 128:
         byte = hex(short)
    elif short < 0 and short >= -128:
        byte = hex(short + 256)
    else:
        raise OverflowException()
    hexcode = byte[2:]
    return "0" + hexcode if len(hexcode) == 1 else hexcode

def codegen(rom, tree, instruction_set):
    labels = {}
    addr_to_label = {}
    addr_to_addr_mode = {}
    address = 0x0600 #default start address
    for line in tree.children:
        command = line.children[0]
        logger.debug(command)
        if not hasattr(command, 'data'):
            pass #this is a comment
        elif command.data == "pragma":
            pragma = command.children[0]
            if pragma.data == "org":
                address = int("0x" + "".join(parse_hex_num(pragma.children[0])[::-1]),16)
            elif pragma.data == "byteprag":
                num = int("0x" + parse_hex_num(pragma.children[0])[0], 16)
                hex = short_to_signed_hex_byte(num)
                rom[address] = hex
        elif command.data == "setlabel":
            label = str(command.children[0].children[0])
            labels[label] = address
        elif command.data == "command":
            address = assemble_command(addr_to_label, addr_to_addr_mode, command, address, instruction_set, rom)
    compute_jmp_offsets(addr_to_label, labels, addr_to_addr_mode, rom)

def assemble_command(address_to_label, addr_to_addr_mode, command, instruction_address, instruction_set, rom):
    opcode = None
    param_type = syntax_tree_to_type["none"]
    parameter = None
    for index, child in enumerate(command.children):
        if index == 0:
            opcode = str(child)
        elif index == 1:
            cdata = child.data
            param_type = syntax_tree_to_type[cdata]
            if cdata == "value" or cdata == "address" or cdata == "zerop":
                parameter = parse_hex_num(child)
            elif child.data == "label":
                parameter = str(child.children[0])
            elif child.data == "indir":
                parameter = parse_hex_num(child.children[0])
                if len(child.children) > 1 and child.children[1].data == "register":
                    param_type += "+" + child.children[1].children[0].data
        elif index == 2:
            if child.data == "register":
                param_type += "," + child.children[0].data
    logger.debug(opcode + "\t" + str(parameter))
    possible_ops = instruction_set[opcode]
    op_definition = None
    for op in possible_ops:
        if op["ptype"] == param_type:
            op_definition = op
    logger.debug(opcode + "\t" + str(op_definition))
    rom[instruction_address] = op_definition['hex']
    instruction_address += 1
    if param_type != syntax_tree_to_type["none"]:
        if param_type == syntax_tree_to_type["label"]:
            address_to_label[instruction_address] = parameter
            addr_mode = op_definition['addr_mode']
            addr_to_addr_mode[instruction_address] = addr_mode
            if addr_mode == 'a':
                instruction_address += 2
            else:
                instruction_address += 1
        else:
            for num in parameter:
                rom[instruction_address] = num
                instruction_address += 1
    return instruction_address

def compute_jmp_offsets(address_to_label, labels, addr_to_label_mode, rom):
    for address in address_to_label:
        label = address_to_label[address]
        if addr_to_label_mode[address] == "r":
            offset = labels[label] - address - 1
            bytes = [short_to_signed_hex_byte(offset)]
        else:
            bytes = int_to_signed_hex(labels[label])
        for byte in bytes:
            rom[address] = byte
            address += 1

def switch_endian(rom):
    i = 0
    while i + 1 < len(rom):
        tmp = rom[i]
        rom[i] = rom[i + 1]
        rom[i + 1] = tmp
        i += 2

def main(argv):
    rom = ["00"] * (0xFFFF + 1)
    instruction_set = {}
    with open("opcodes.txt", "r") as file:
        line = file.readline()
        line = file.readline()
        while line:
            if len(line) > 1 and (not line.startswith(";")):
                parts = line.rstrip().split("\t")
                opcode = parts[0]
                if opcode not in instruction_set:
                    instruction_set[opcode] = []
                instruction_set[opcode].append({'hex':parts[1], 'ptype':parts[2], 'addr_mode':parts[3]})
            line = file.readline()
    for file in argv:
        tree = parse_file(file)
        codegen(rom, tree, instruction_set)
    switch_endian(rom)
    rom = bytes.fromhex("".join(rom))
    with open("rom.bin", "wb") as file:
        file.write(rom)

if __name__ == "__main__":
    main(sys.argv[1:])


