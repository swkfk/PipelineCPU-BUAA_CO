`ifndef __CONSTANTS_V__
`define __CONSTANTS_V__

`define PC_START 32'h3000

`define NPC_PC4  2'b00
`define NPC_Br   2'b01
`define NPC_J    2'b10
`define NPC_Jr   2'b11

`define EXT_Zero 1'b0
`define EXT_Sign 1'b1

`define REGWr_Alu 2'b00
`define REGWr_Dm  2'b01
`define REGWr_PC4 2'b10

`define REGWrR_Rt  2'b00
`define REGWrR_Rd  2'b01
`define REGWrR_$ra 2'b10

`define ADD 6'b100000
`define SUB 6'b100010
`define AND 6'b100100
`define OR  6'b100101
`define SLT 6'b101010
`define SLTU 6'b101011
`define LUI 6'b001111

`define ADDI 6'b001000
`define ANDI 6'b001100
`define ORI 6'b001101

`define SLL 6'b000000

`define LB  6'b100000
`define LH  6'b100001
`define LW  6'b100011
`define SB  6'b101000
`define SH  6'b101001
`define SW  6'b101011

`define MULT  6'b011000
`define MULTU 6'b011001
`define DIV   6'b011010
`define DIVU  6'b011011
`define MFHI  6'b010000
`define MFLO  6'b010010
`define MTHI  6'b010001
`define MTLO  6'b010011

`define BEQ 6'b000100
`define BNE 6'b000101
`define JAL 6'b000011
`define JR  6'b001000

`define ALU_ADD 4'b0000
`define ALU_SUB 4'b0001
`define ALU_OR  4'b0010
`define ALU_LUI 4'b0011
`define ALU_SLL 4'b0100
`define ALU_AND 4'b0101
`define ALU_SLT 4'b0110
`define ALU_SLTU 4'b0111

`define IR_RD 15:11
`define IR_RT 20:16
`define IR_RS 25:21

`define Br_BEQ  3'b001
`define Br_BNE  3'b010

`define CalcType 2'b01
`define LoadType 2'b10
`define JumpType 2'b00

`endif
