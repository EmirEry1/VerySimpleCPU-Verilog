#!/usr/bin/python

# CAUTION: run 'dos2unix projectCPU2022_assembler_iss.py' if you get bad interpreter error 

# notes:
# 1. Supported instructions:
#
#    ISA:
#    ============================================================================================
#    Arithmetic & Logic Instructions  | Data Transfer Instructions | Program Control Instructions
#    ============================================================================================
#                    ADD              |             CP2W           |            BZ
#                    NOR              |             CPfW           |
#                    SRL              |                            |
#                    RRL              |                            |
#                    CMP              |                            |
# 2. -x only generates .v file.
# 3. Default MEM_SIZE is 8192. That is, 8192x16-bit.

import re
import sys, getopt
import linecache
import struct
import platform

def print_blank_line(line_count):
    for i in range(line_count):
        print ""

def print_header(char, count):
    print ""
    for i in range(count):
        print char,
    print ""

def print_footer(char, count):
    for i in range(count):
        print char,
    print ""
        
def print_usage(option=1):
    if option == 0:
        print_blank_line(1)
        print "Invalid syntax. Please run the script as follows:"
    print_blank_line(1)
    print "SYNOPSIS"
    print_blank_line(1)
    print 'projectCPU2022_assembler_iss.py -h -i <input_file> -s <sim_type> -m <mem_size> -x -v'
    print_blank_line(2)
    print "DESCRIPTION"
    print_blank_line(1)
    print "assembler_iss_mem_init_gen.py\n\tname of this script"
    print_blank_line(1)
    print "-h"
    print "\tdisplay this help"
    print_blank_line(1)
    print "-i, --ifile <input_file>"
    print"\tset assembly code that must be processed"
    print_blank_line(1)
    print "-s <sim_type>\n\tsimulate code\n\t0 - simulate all\n\t1 - simulate step-by-step"
    print_blank_line(1)
    print "-m, --mem_size <mem_size>"
    print "\tset memory size"
    print_blank_line(1)
    print "-x\n\textract memory initialization files"
    print_blank_line(1)
    print "-v\n\tverbose"

# used a small trick posted on stackoverflow to find out if a string should be float or integer (see https://stackoverflow.com/questions/15357422)
def is_float(x):
    try:
        a = float(x)
    except ValueError:
        return False
    else:
        return True

def is_int(x):
    try:
        a = float(x)
        b = int(a)
    except ValueError:
        return False
    else:
        return a == b

class CPUSim:

    def __init__(self, inputfile="", mem_size=8192, sim_type=0, verbose=False):
        self.inputfile = inputfile
        self.indirection_register_index = 4
        self.wreg = 0
        if mem_size != 0:
            self.MEM_SIZE = mem_size
        else:
            self.MEM_SIZE = 8192
        self.sim_type = sim_type
        self.verbose = verbose
        
        if self.verbose:
            print "Class instance is created with following parameters:"
            print self.inputfile
            print self.MEM_SIZE
            print self.sim_type
            print self.verbose

        # memory arrays
        self.mem_array_sim = [0] * self.MEM_SIZE
        self.mem_array_init = ["garbage"] * self.MEM_SIZE # mark unused memory locations as "garbage"

        # file names
        self.outputfile_init = "instr_data_memory.v"
        self.outputfile_final_asm = "instr_data_memory_final.asm"
        self.outputfile_final = "instr_data_memory_final.v"

        self.program_counter = 0
        self.program_counter_prev = 0
    
        # opcode dictionaries
        self.opcodes = {"ADD" : 0, "NOR" : 1, "SRL" : 2, "RRL" : 3, "CMP" : 4, "BZ" : 5, "CP2W" : 6, "CPfW" : 7}

        self.opcodes_r = {0 : "ADD", 1 : "NOR", 2 : "SRL", 3 : "RRL", 4 : "CMP", 5 : "BZ", 6 : "CP2W",7 : "CPfW"}

    def print_error(self, linenum, *operand_index):
        print_header("!", 25)
        print "Error at line", (linenum + 1), ":",
        if len(operand_index) == 2:
            print "operand", operand_index[0], "and operand", operand_index[1], "must be nonnegative integers"
        else:
            print "operand", operand_index[0], "must be nonnegative integer"
        
        line = linecache.getline(self.inputfile, (linenum + 1)).rstrip()
        print line
        print_footer("!", 25)
        sys.exit(1)
    
    def is_instruction_or_data(self, instruction_or_data):
        if instruction_or_data in self.opcodes:
            return 1
        else:
            return 0

    def extract_memory_files(self):
        fo_init = open(self.outputfile_init, "w")
        fo_final_asm = open(self.outputfile_final_asm, "w")
        fo_final = open(self.outputfile_final, "w")
        for i in range(self.MEM_SIZE):
            if self.mem_array_init[i] != "garbage":
                mem_init_line = "memory"
                mem_init_line += "["
                mem_init_line += str(i)
                mem_init_line += "]"
                mem_init_line += " "
                mem_init_line += "="
                mem_init_line += " "
                mem_init_line += "16'h"
                mem_init_line += self.mem_array_init[i]
                mem_init_line += ";"
                
                fo_init.write(mem_init_line)
                if i != (self.MEM_SIZE-1):
                    fo_init.write("\n")
                
                
                mem_init_line = "memory"
                mem_init_line += "["
                mem_init_line += str(i)
                mem_init_line += "]"
                mem_init_line += " "
                mem_init_line += "="
                mem_init_line += " "
                mem_init_line += "16'h"
                mem_init_line += str(format(self.mem_array_sim[i], "04x"))
                mem_init_line += ";"
                mem_init_line += " //"
                mem_init_line += str(self.mem_array_sim[i])
                
                fo_final.write(mem_init_line)
                if i != (self.MEM_SIZE-1):
                    fo_final.write("\n")
                
                

                mem_final_line = str(i)
                mem_final_line += ": "
                mem_final_line += str(self.mem_array_sim[i])

                fo_final_asm.write(mem_final_line)

                if i != (self.MEM_SIZE-1):
                    fo_final_asm.write("\n")
        
        fo_init.close()
        fo_final_asm.close()
        fo_final.close()

    def parse_and_create_memory_image(self):
        linenum = 0

        lineendregexDarwin = "\r\n"
        lineendregexLinux = "\n"
        lineendregexR = "\r"
    
        with open(self.inputfile) as fi:
            for line in fi:
            
                new_line_removed = re.sub(r"%s" % lineendregexDarwin, "", line)
                new_line_removed = re.sub(r"%s" % lineendregexLinux, "", new_line_removed)
                new_line_removed = re.sub(r"%s" % lineendregexR, "", new_line_removed)
            
                comment_removed = re.sub(r"//.*$", "", new_line_removed)
                
                if comment_removed == "":
                    continue
                                    
                index = (re.search(r"(\d+)", comment_removed)).group(0)
                                
                instruction_or_data = re.sub(r"(\d+):", "", comment_removed)

                #regex = r"(\w+|\d*\.\d+|\d+)(\ +)([\-]?\w+)(\ +)([\-]?\w+)"
                regex = r"(\w+|\d*\.\d+|\d+)(\ +)([\-]?\w+)"
                
                if self.is_instruction_or_data(re.search(r"(\w+|\d*\.\d+|\d+)", instruction_or_data).group(0)):
                    
                    opcode = self.opcodes[re.search(regex, instruction_or_data).group(1)]
                    operand_1 = re.search(regex, instruction_or_data).group(3)
                    if(re.search(r"\b0x[0-9A-F]+\b", operand_1)):
                        operand_1 = int(operand_1, 0)
                                        
                    if int(operand_1) < 0:
                        self.print_error(int(linenum), 1)
                    
                    instruction_dec = (opcode << 13) | (int(operand_1))
                    if instruction_dec == 0:
                        instruction_hex = "0"
                    else:
                        instruction_hex = format(instruction_dec, "04x")
                        instruction_hex = instruction_hex.lstrip("0")
                    self.mem_array_sim[int(index)] = instruction_dec
                    self.mem_array_init[int(index)] = instruction_hex
                else:

                    if(re.search(r"\b0x[0-9A-F]+\b", instruction_or_data)):
                            instruction_or_data = int(instruction_or_data, 0)

                    instruction_or_data = str(instruction_or_data)

                    if is_int(instruction_or_data):
                        
                        if int(instruction_or_data) < 0:
                            self.print_error(int(linenum), 1)

                        data = int(instruction_or_data)
                        
                        # used a small trick posted on stackoverflow to generate hex representation of data in .coe and .mif files (see https://stackoverflow.com/questions/7822956)
                        data_hex = (int(instruction_or_data) + (1 << 32)) % (1 << 32)
                        data_bin = data_hex
                        data_hex = format(data_hex, "08x")
                        if data_hex == "00000000":
                            data_hex  = "0"
                            self.mem_array_init[int(index)] = data_hex
                        else:
                            data_hex = data_hex.lstrip("0")
                            self.mem_array_sim[int(index)] = data
                            self.mem_array_init[int(index)] = data_hex
                    
                    elif is_float(instruction_or_data):
                        self.print_error(int(linenum), 1)

                linenum = linenum + 1

    def print_memory_cell(self, opcode, operand_1):
        if opcode == self.opcodes["ADD"] or \
           opcode == self.opcodes["NOR"] or \
           opcode == self.opcodes["SRL"] or \
           opcode == self.opcodes["RRL"] or \
           opcode == self.opcodes["CMP"] or \
           opcode == self.opcodes["BZ"] or \
           opcode == self.opcodes["CP2W"] or \
           opcode == self.opcodes["CPfW"]:
            print "\tW\t\t\t:", self.wreg
            if operand_1 == 0:
                print "\tmem[", self.indirection_register_index, "]\t\t:", self.mem_array_sim[self.indirection_register_index]
                print "\tmem[", self.mem_array_sim[self.indirection_register_index], "]\t\t:", self.mem_array_sim[self.mem_array_sim[self.indirection_register_index]] 
            else:
                print "\tmem[", operand_1, "]\t\t:", self.mem_array_sim[operand_1]
    
    def run_instruction(self, opcode, operand_1):
        
        #Indirect addressing
        # temp_1 is basically *A or **IndirectAddr
        if operand_1 == 0:
            temp_1 = self.mem_array_sim[self.mem_array_sim[self.indirection_register_index]]
        else:
            temp_1 = self.mem_array_sim[operand_1]
        
        if opcode == self.opcodes["ADD"] or \
           opcode == self.opcodes["NOR"] or \
           opcode == self.opcodes["SRL"] or \
           opcode == self.opcodes["RRL"] or \
           opcode == self.opcodes["CMP"] or \
           opcode == self.opcodes["CP2W"] or \
           opcode == self.opcodes["CPfW"]:
            print "\tMemory content before executing instruction"
            self.print_memory_cell(opcode, operand_1)
            
            if opcode == self.opcodes["ADD"]:
                self.wreg = (temp_1 + self.wreg) & 0xFFFF
            elif opcode == self.opcodes["NOR"]:
                self.wreg = (~(temp_1 | self.wreg)) & 0xFFFF
            elif opcode == self.opcodes["SRL"]: # CAUTION: it does not handle negative shift values
                if temp_1 < 16:
                    # used a method posted on stackoverflow to get logical shift (see https://stackoverflow.com/questions/5832982)
                    self.wreg = self.wreg >> temp_1
                else:
                    temp_1 = temp_1 & 0xF
                    self.wreg = self.wreg << temp_1
                self.wreg = self.wreg & 0xFFFF
            elif opcode == self.opcodes["RRL"]: # CAUTION: it does not handle negative shift values
                if temp_1 < 16:
                    
                    self.wreg = (self.wreg >> temp_1) + ((self.wreg << (16-temp_1)) & 0xFFFF)
                else:
                    temp_1 = temp_1 & 0xF
                    self.wreg = ((self.wreg << temp_1) & 0xFFFF) + (self.wreg >> (16 - temp_1))
                self.wreg = self.wreg & 0xFFFF
            elif opcode == self.opcodes["CMP"]:
                if self.wreg < temp_1:
                    self.wreg = 0xFFFF
                elif self.wreg == temp_1:
                    self.wreg = 0
                else:
                    self.wreg = 1
            elif opcode == self.opcodes["CP2W"]:
                self.wreg = temp_1
            elif opcode == self.opcodes["CPfW"]:
                if operand_1 == 0:
                    temp_1 = self.mem_array_sim[self.indirection_register_index]
                else:
                    temp_1 = operand_1
                self.mem_array_sim[temp_1] = self.wreg
            
            self.program_counter = self.program_counter + 1
            
            print "\tMemory content after executing instruction"
            self.print_memory_cell(opcode, operand_1)
        elif opcode == self.opcodes["BZ"]:
            if temp_1 == 0:
                self.program_counter = self.wreg
            else:
                self.program_counter = self.program_counter + 1

            print "\tnext program counter\t:", self.program_counter 
            print "\tMemory content before executing instruction"
            self.print_memory_cell(opcode, operand_1)
            
            print "\tMemory content after executing instruction"
            self.print_memory_cell(opcode, operand_1)
        else:
            print "UNDEFINED INSTRUCTION"
            sys.exit(1)

    def run_simulation(self):

        print_blank_line(1)
        print "Starting simulation"
        print_blank_line(1)
        
        if self.sim_type == 0:
            print "run all mode selected"
        else:
            print "step-by-step mode selected"

        print_blank_line(1)      

        # CAUTION: it is assumed that instructions are always placed starting from very beginning of memory, i.e., address zero
        # parsing bits [15-13] to catch an instruction

        sim_finished = False
        
        while(sim_finished == False):

            if self.sim_type == 1:
                raw_input("\nPress any key to continue ")

            instruction_or_data = self.mem_array_sim[self.program_counter]
            
            # if (instruction_or_data & 0xFFFF) > 0: # CAUTION: it is assumed that instructions such as 'ADD 0' is not generated by compiler

            opcode = instruction_or_data >> 13
            operand_1 = (instruction_or_data) & 0x1FFF
   
            print_header("*", 25)
            print "\tcurrent_instruction\t:", self.opcodes_r[opcode], operand_1
            print "\tcurrent program counter\t:", self.program_counter
            self.program_counter_prev = self.program_counter
            self.run_instruction(opcode, operand_1)
            print_footer("*", 25)
                
            if self.program_counter_prev == self.program_counter:
                print "Finishing simulation. Instruction called itself."
                sim_finished = True
        
    
def main(argv):
   
    try:
        opts, args = getopt.getopt(argv,"hi:s:m:vx",["ifile=", "extract_memory_files", "sim=", "memory_size="])
    except getopt.GetoptError:
        print_usage()
        sys.exit(1)

    inputfile = ""
    extract = False
    verbose = False
    simulate = False
    sim_type = 0
    mem_size = 0
    
    if not opts:
        print_usage()
        sys.exit(1)
        
    for opt, arg in opts:
        if opt == '-h':
            print_usage(1)
            sys.exit(1)
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-s", "--sim"):
            simulate = True
            sim_type = int(arg)
        elif opt in ("-m", "--mem_size"):
            mem_size = int(arg)
        elif opt in ("-x", "--extract_memory_files"):
            extract = True
        elif opt in ("-v"):
            verbose = True
            print "Verbosing output"

    if inputfile == "" or mem_size < 0 or mem_size > 8192:
        print_usage(0)
        sys.exit(1)

    MyCPUSim = CPUSim(inputfile=inputfile, mem_size=mem_size, sim_type=sim_type, verbose=verbose)
    
    MyCPUSim.parse_and_create_memory_image()

    if simulate == True:
        MyCPUSim.run_simulation()

    if extract == True:
        print "Extracting memory initialization files"
        MyCPUSim.extract_memory_files()

if __name__ == "__main__":
    main(sys.argv[1:])
