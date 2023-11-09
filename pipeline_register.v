`timescale 1ns / 1ps

module PReg
#(parameter Width = 32)
(
    input clk,
    input stall,
    input reset,
    input  [Width - 1 : 0] Din,
    output [Width - 1 : 0] Dout
    );
    
    reg [Width-1 : 0] R;
    
    always @(posedge clk) begin
        if (reset)
            R <= 32'b0;
        else if (~stall)
            R <= Din;
        else
            R <= R;
    end

    assign Dout = R;

endmodule
