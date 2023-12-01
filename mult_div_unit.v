`timescale 1ns / 1ps
`include "Constants.v"

module MDU(
    input clk,
    input reset,
    input start,
    input req,
    input [31:0] RS,
    input [31:0] RT,
    input [3:0] MDType,
    output busy,
    output [31:0] MDOut
    );

    reg [31:0] HI, LO, temp_HI, temp_LO;
    reg [ 3:0] countdown;
    reg        r_busy;
    
    assign MDOut = (MDType == `MDU_MFHI) ? HI :
                   (MDType == `MDU_MFLO) ? LO :
                   32'b0;
    assign busy = r_busy;
    
    always @(posedge clk) begin
        if (reset) begin
            countdown <= 0;
            HI <= 0;
            temp_HI <= 0;
            temp_LO <= 0;
            LO <= 0;
            r_busy <= 0;
        end
        else if (!req) begin
            if (start) begin
                if (MDType == `MDU_MTHI) begin
                    HI <= RS;
                end
                else if (MDType == `MDU_MTLO) begin
                    LO <= RS;
                end
                else if (MDType == `MDU_MULT) begin
                    countdown <= 4'd5;
                    r_busy <= 1'b1;
                    {temp_HI, temp_LO} <= $signed(RS) * $signed(RT);
                end
                else if (MDType == `MDU_MULTU) begin
                    countdown <= 4'd5;
                    r_busy <= 1'b1;
                    {temp_HI, temp_LO} <= RS * RT;
                end
                else if (MDType == `MDU_DIV) begin
                    countdown <= 4'd10;
                    r_busy <= 1'b1;
                    temp_HI <= $signed(RS) % $signed(RT);
                    temp_LO <= $signed(RS) / $signed(RT);
                end
                else if (MDType == `MDU_DIVU) begin
                    countdown <= 4'd10;
                    r_busy <= 1'b1;
                    temp_HI <= RS % RT;
                    temp_LO <= RS / RT;
                end
            end
            else begin
                if (countdown == 4'd1) begin
                    HI <= temp_HI;
                    LO <= temp_LO;
                    r_busy <= 1'b0;
                    countdown <= 4'd0;
                end
                else if (countdown == 4'd0) begin
                    countdown <= 4'd0;
                end
                else begin
                    countdown <= countdown - 1;
                end
            end
        end
    end

endmodule
