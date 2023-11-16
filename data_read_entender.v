`timescale 1ns / 1ps
`include "Constants.v"

module DmRDExt(
    input [31:0] data_read_in,
    input [2:0] read_type,
    input [1:0] addr_low,
    output [31:0] data_read_out
    );

    wire [ 7:0] byte_read = data_read_in[7 + 8*addr_low -: 8];
    wire [15:0] half_read = data_read_in[15 + 16*addr_low[1] -: 16];

    assign data_read_out = 
            read_type == `WordRead ? data_read_in :
            read_type == `ByteSigned ? {{24{byte_read[7]}}, byte_read} :
            read_type == `ByteUnsigned ? {24'b0, byte_read} :
            read_type == `HalfSigned ? {{16{half_read[15]}}, half_read} :
            read_type == `HalfUnsigned ? {16'b0, half_read} :
            data_read_in;

endmodule
