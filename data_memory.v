`timescale 1ns / 1ps

module DM(
    input clk,
    input reset,
    input [31:0] WAddr,
    input [31:0] WData,
    input WrEn,
    output [31:0] RD,
    input [31:0] PC4
    );

    reg  [31:0] DataMemory [3071:0];
    wire [31:0] PC = PC4 - 32'd4;
    integer i;
    
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 3072; i = i + 1) begin
                DataMemory[i] <= 32'b0;
            end
        end
        else begin
            if (WrEn) begin
                DataMemory[WAddr[13:2]] <= WData;
                $display("@%h: *%h <= %h", PC, WAddr, WData);
            end
            else begin
                DataMemory[WAddr[13:2]] <= DataMemory[WAddr[13:2]];
            end
        end
    end
    
    assign RD = DataMemory[WAddr[13:2]];

endmodule
