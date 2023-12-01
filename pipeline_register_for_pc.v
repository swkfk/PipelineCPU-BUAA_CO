`timescale 1ns / 1ps

module PRegPC
#(parameter Width = 32)
(
    input clk,
    input stall,
    input reset,
    input req,
    input  [Width - 1 : 0] Din,
    output [Width - 1 : 0] Dout
    );
    
    reg [Width-1 : 0] R;
    
    always @(posedge clk) begin
        if (reset)
            R <= req ? 32'h0000_4180 : 32'b0;
        else if (~stall)
            R <= Din;
        else
            R <= R;
    end

    assign Dout = R;

endmodule
