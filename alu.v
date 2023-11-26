`timescale 1ns / 1ps
`include "Constants.v"

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] AluOp,
    output [31:0] C,
    output Zero,
    input AllowExcOv,
    output ExcOv,
    input AllowExcDm,
    output ExcDm
    );

    wire signed slt = $signed(A) < $signed(B) ? 1'b1 : 1'b0;

    assign C = 
        AluOp == `ALU_ADD ? A + B :
        AluOp == `ALU_SUB ? A - B :
        AluOp == `ALU_OR  ? A | B :
        AluOp == `ALU_LUI ? B << 16 :
        AluOp == `ALU_SLL ? B << A[4:0] :
        AluOp == `ALU_AND ? A & B :
        AluOp == `ALU_SLT ? {31'b0, slt} :
        AluOp == `ALU_SLTU ? A < B :
        0;
    
    assign Zero = ~(|C);
    
    wire [32:0] A32 = {A[31], A}, B32 = {B[31], B};
    wire [32:0] Add32 = A32 + B32, Sub32 = A32 - B32;
    wire AddOv = (AluOp == `ALU_ADD) && (Add32[32] != Add32[31]);
    wire SubOv = (AluOp == `ALU_SUB) && (Sub32[32] != Sub32[31]);
    wire Ov = AddOv | SubOv;

    assign ExcOv = AllowExcOv && Ov;
    assign ExcDm = AllowExcDm && Ov;

endmodule
