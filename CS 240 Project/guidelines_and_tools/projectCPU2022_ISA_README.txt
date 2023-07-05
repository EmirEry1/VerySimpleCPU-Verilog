(ISA means Instruction Set Architecture)

16-bit Instruction Word (IW) of ProjectCPU:

                                IW
               |----------------------------------
  bit position |15    13| 12                    0|
               |----------------------------------
    field name | opcode |           A            |
               |----------------------------------
     bit width |   3b   |          13b           |
               |----------------------------------
			   
(Every memory location and W are 16 bits)

Instruction Set of ProjectCPU:

ADD  -> Unsigned Add
         opcode = 0
         W = W + (*A)
         write(readFromAddress(A) +W) to W
         *A = value (content of) address A = mem[A] (mem means memory)
         = means write (assign)

NOR  -> Bitwise NOR
         opcode = 1
         W = ~(W | (*A))

SRL  -> Shift Right or Left
         opcode = 2
         if((*A) is less than 16) W = W >> (*A)
		 else W = W << lower4bits(*A)

RRL  -> Rotate Right or Left
         opcode = 3
         if((*A) is less than 16) W = RotateRight W by (*A)
		 else W = RotateLeft W by lower4bits(*A)

CMP  -> Unsigned Compare
         opcode = 4
         if (W < (*A)) W = 0xFFFF
         else if (W == (*A)) W = 0x0000
         else W = 0x0001

BZ    -> Branch on Zero
         opcode = 5
         PC = ((*A) == 0) ? (W) : (PC+1)
		 
CP2W  -> Copy to W
         opcode = 6
         W = *A

CPfW  -> Copy from W
         opcode = 7
         *A = W
		 
INDIRECT ADRESSING

There are no special instructions for indirect addressing. Instead, every instruction
can operate in indirect addressing mode.

That is, if A==0, replace *A above with **4.

Every program starts like this:

0: CP2W 3
1: BZ 2
2: 0
3: 5
4: // indirection register
5: // program actually starts here
