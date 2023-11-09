`timescale 1ns / 1ps
`include "Constants.v"

module StallCtrl(
    input [1:0] Type$E,
    input [1:0] Type$M,
    input [4:0] A1$D,
    input [4:0] A2$D,
    input [4:0] A3$E,
    input [4:0] A3$M,
    input WE$E,
    input WE$M,
    input [2:0] TuseRS,
    input [2:0] TuseRT,
    output stall
    );
 
    wire [2:0] Tnew$E = Type$E == `LoadType ? 3'd2 :
                        Type$E == `CalcType ? 3'd1 :
                        3'd0;
    wire [2:0] Tnew$M = Type$M == `LoadType ? 3'd1 : 3'd0;

    wire stall_rs$E = (TuseRS < Tnew$E) && (WE$E) && (A1$D == A3$E);
    wire stall_rs$M = (TuseRS < Tnew$M) && (WE$M) && (A1$D == A3$M);
    
    wire stall_rt$E = (TuseRT < Tnew$E) && (WE$E) && (A2$D == A3$E);
    wire stall_rt$M = (TuseRT < Tnew$M) && (WE$M) && (A2$D == A3$M);
    
    assign stall = stall_rs$E | stall_rs$M | stall_rt$E | stall_rt$M;

endmodule
