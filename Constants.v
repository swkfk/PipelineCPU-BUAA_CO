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
`define SLL 6'b000000
`define ORI 6'b001101
`define LW  6'b100011
`define SW  6'b101011
`define BEQ 6'b000100
`define LUI 6'b001111
`define JAL 6'b000011
`define JR  6'b001000

`define ALU_ADD 3'b000
`define ALU_SUB 3'b001
`define ALU_OR  3'b010
`define ALU_LUI 3'b011
`define ALU_SLL 3'b100

`endif
