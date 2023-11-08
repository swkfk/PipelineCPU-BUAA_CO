`timescale 1ns / 1ps

module EXT(
    input [15:0] imm16,
    input ExtOp,
    output [31:0] ext32
    );

    MUX32_2 u_mux_32_2(
        .Sel(ExtOp),
        .DI_0({ 16'b0, imm16 }),
        .DI_1({ {16{imm16[15]}}, imm16 }),
        .DO(ext32)
    );

endmodule
