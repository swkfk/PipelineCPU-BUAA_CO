`timescale 1ns / 1ps

module MUX32_4(
    input [1:0] Sel,
    input [31:0] DI_00,
    input [31:0] DI_01,
    input [31:0] DI_10,
    input [31:0] DI_11,
    output [31:0] DO
    );

    wire [31:0] D_0;
    wire [31:0] D_1;
    
    MUX32_2 u_mux_32_2_0(
        .Sel(Sel[0]),
        .DI_0(DI_00),
        .DI_1(DI_01),
        .DO(D_0)
    );
    
    MUX32_2 u_mux_32_2_1(
        .Sel(Sel[0]),
        .DI_0(DI_10),
        .DI_1(DI_11),
        .DO(D_1)
    );
    
    MUX32_2 u_mux_32_2(
        .Sel(Sel[1]),
        .DI_0(D_0),
        .DI_1(D_1),
        .DO(DO)
    );

endmodule
