`timescale 1ns / 1ps
`include "Constants.v"

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [2:0] AluOp,
    output [31:0] C,
    output Zero
    );

    assign C = 
        AluOp == `ALU_ADD ? A + B :
        AluOp == `ALU_SUB ? A - B :
        AluOp == `ALU_OR  ? A | B :
        AluOp == `ALU_LUI ? B << 16 :
        AluOp == `ALU_SLL ? B << A[4:0] :
        0;
    
    assign Zero = ~(|C);

endmodule
