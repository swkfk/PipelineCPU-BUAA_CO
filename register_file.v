`timescale 1ns / 1ps

module GRF(
    input clk,
    input reset,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
    input WrEn,
    output [31:0] RD1,
    output [31:0] RD2
    );

    reg  [31:0] REG[31:0];
    
    integer i;
    
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                REG[i] <= 32'b0;
            end
        end
        else begin
            if (WrEn && A3 != 5'b0) begin
                REG[A3] <= WD;
            end
            else begin
                REG[A3] <= REG[A3];
            end
        end
    end
    
    assign RD1 = (A1 == A3 && A3 && WrEn) ? WD : REG[A1];
    assign RD2 = (A2 == A3 && A3 && WrEn) ? WD : REG[A2];

endmodule
