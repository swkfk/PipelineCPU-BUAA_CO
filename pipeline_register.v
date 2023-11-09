`timescale 1ns / 1ps

module PReg
#(parameter Width = 32)
(
    input clk,
    input stall,
    input reset,
    input [Width - 1 : 0] Din,
    output [Width - 1 : 0] Dout
    );
    
    always @(posedge clk) begin
        if (reset)
            Dout <= 32'b0;
        else if (~stall)
            Dout <= Din;
        else
            Dout <= Dout;
    end


endmodule
