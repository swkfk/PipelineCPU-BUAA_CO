`timescale 1ns / 1ps

module MUX5_4(
    input [1:0] Sel,
    input [4:0] DI_00,
    input [4:0] DI_01,
    input [4:0] DI_10,
    input [4:0] DI_11,
    output [4:0] DO
    );

    wire [4:0] D_0;
    wire [4:0] D_1;
    
    MUX5_2 u_mux_5_2_0(
        .Sel(Sel[0]),
        .DI_0(DI_00),
        .DI_1(DI_01),
        .DO(D_0)
    );
    
    MUX5_2 u_mux_5_2_1(
        .Sel(Sel[0]),
        .DI_0(DI_10),
        .DI_1(DI_11),
        .DO(D_1)
    );
    
    MUX5_2 u_mux_5_2(
        .Sel(Sel[1]),
        .DI_0(D_0),
        .DI_1(D_1),
        .DO(DO)
    );

endmodule
