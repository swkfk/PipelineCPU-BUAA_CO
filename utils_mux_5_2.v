`timescale 1ns / 1ps

module MUX5_2(
    input Sel,
    input [4:0] DI_0,
    input [4:0] DI_1,
    output [4:0] DO
    );

    assign DO = (Sel == 1'b0 ? DI_0 : DI_1);

endmodule
