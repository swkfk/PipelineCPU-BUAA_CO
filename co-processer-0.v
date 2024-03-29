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
    // input EXLSet,      // set EXL to 1
    input EXLClr,      // reset EXL to 0
    output Req,
    output [31:0] EPCout,
    output [31:0] DOut
    );

    reg [31:0] SR;
    reg [31:0] Cause;
    reg [31:0] EPC, tempEPC;
    reg [31:0] PrID = `RegPrIDInit;
    
    wire [7:2] IM = SR[15:10];
    wire EXL      = SR[1];  // Exception Level
    wire IE       = SR[0];  // Enable
    
    wire IntReq = (|(HWInt & IM)) & IE & !EXL;
    wire ExcReq = (|ExcCode) & !EXL;
    assign Req = IntReq || ExcReq;
    wire [31:0] AcceptPC = ExcInBd ? (PC - 4) : PC;

    always @(posedge clk) begin
        if (rst) begin
            SR <= 32'b0;
            Cause <= 32'b0;
            EPC <= 32'b0;
            PrID <= `RegPrIDInit;
        end
        else begin
            if (EXLClr) begin
                SR[1] <= 1'b0;
            end
            else if (IntReq || ExcReq) begin  // interruption or exception occurred
                Cause[6:2] <= IntReq ? 5'b0 : ExcCode;
                Cause[31]  <= ExcInBd;
                SR[1] <= 1'b1;
                EPC <= (IntReq || ExcReq) ? AcceptPC : EPC;
            end
            else if (We) begin  // mtc0
                if (A2 == `RegSR)
                    SR <= DIn & 32'b0000_0000_0000_0000_1111_1100_0000_0011;
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
    
    assign EPCout = EPC;
    assign DOut = (A1 == `RegSR)    ? SR    :
                  (A1 == `RegCause) ? Cause :
                  (A1 == `RegEPC)   ? EPC :
                  (A1 == `RegPrID)  ? PrID  :
                  32'b0;

endmodule
