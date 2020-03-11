import sys

def main(argv):
    with open("EEPROM_flash_template.ino", "r") as file:
        template = file.read()
    #print(template)
    with open("rom.bin", "rb") as file:
        hex = ["0x{:02x}".format(c) for c in file.read()]
    hex_str = ", ".join(hex)
    with open("flash.ino", "w+") as file:
        file.write(template.replace('!', hex_str))

if __name__ == "__main__":
    main(sys.argv[1:])

