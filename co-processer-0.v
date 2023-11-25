`timescale 1ns / 1ps

`include "CP0_Consts.v"

module CP0(
    input clk,
    input rst,
    input [4:0] A1,  // Read from CP0
    input [4:0] A2,  // Write to CP0
    input [31:0] DIn,  // Write Data to CP0
    input [31:0] PC,   // PC when interruption/exception
    input       ExcInBd,  // whether in branch delay slot
    input [6:2] ExcCode,  // interruption/exception type
    input [7:2] HWInt,  // Device interruption
    input We,          // write enable
    input EXLSet,      // set EXL to 1
    input EXLClr,      // reset EXL to 0
    output IntReq,
    output [31:2] EPCout,
    output [31:0] DOut
    );

    reg [31:0] SR;
    reg [31:0] Cause;
    reg [31:2] EPC, tempEPC;
    reg [31:0] PrID = `RegPrIDInit;
    
    wire [7:2] IM = SR[15:10];
    wire EXL      = SR[1];  // Exception Level
    wire IE       = SR[0];  // Enable
    
    wire IntReq = (|(HWInt & IM)) & IE & !EXL;
    wire ExcReq = (|ExcCode) & !EXL;
    wire [31:2] AcceptPC = ExcInBd ? (PC[31:2] - 1) : PC[31:2];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            SR <= 32'b0;
            Cause <= 32'b0;
            EPC <= 30'b0;
            PrID <= `RegPrIDInit;
        end
        else begin
            if (EXLClr) begin
                SR[1] <= 1'b0;
            end
            else if (IntReq || ExcReq) begin  // interruption or exception occurred
                Cause[6:2] <= IntReq ? 5'b0 : ExcCode;
                SR[1] <= 1'b1;
                EPC <= (IntReq || ExcReq) ? AcceptPC : EPC;
            end
            else if (We) begin  // mtc0
                if (A2 == `RegSR)
                    SR <= DIn;
                else
                    SR <= SR;
                if (A2 == `RegEPC)
                    EPC <= DIn;
                else
                    EPC <= EPC;
            end
            Cause[15:10] <= HWInt;
        end
    end
    
    assign DOut = (A1 == `RegSR)    ? SR    :
                  (A1 == `RegCause) ? Cause :
                  (A1 == `RegEPC)   ? EPC   :
                  (A1 == `RegPrID)  ? PrID  :
                  32'b0;

endmodule
