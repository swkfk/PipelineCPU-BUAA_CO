`timescale 1ns / 1ps
`include "Constants.v"

module BE(
    input [31:0] data_w_in,
    input [1:0] addr_low,
    input [2:0] write_type,
    output [31:0] data_w_out,
    output [3:0] data_w_byteen
    );
    
    reg [31:0] r_data_w_out;
    reg [3 :0] r_data_w_byteen;

    always @(*) begin
        if (write_type == `Word) begin
            r_data_w_byteen <= 4'b1111;
            r_data_w_out <= data_w_in;
        end
        else if (write_type == `Half) begin
            if (addr_low[1] == 1'b1) begin
                r_data_w_byteen <= 4'b1100;
                r_data_w_out <= {data_w_in[15:0], 16'b0};
            end
            else begin
                r_data_w_byteen <= 4'b0011;
                r_data_w_out <= {16'b0, data_w_in[15:0]};
            end
        end
        else if (write_type == `Byte) begin
            if (addr_low == 2'b00) begin
                r_data_w_byteen <= 4'b0001;
                r_data_w_out <= {24'b0, data_w_in[7:0]};
            end
            else if (addr_low == 2'b01) begin
                r_data_w_byteen <= 4'b0010;
                r_data_w_out <= {16'b0, data_w_in[7:0], 8'b0};
            end
            else if (addr_low == 2'b10) begin
                r_data_w_byteen <= 4'b0100;
                r_data_w_out <= {8'b0, data_w_in[7:0], 16'b0};
            end
            else if (addr_low == 2'b11) begin
                r_data_w_byteen <= 4'b1000;
                r_data_w_out <= {data_w_in[7:0], 24'b0};
            end
        end
        else begin
            r_data_w_byteen <= 4'b0000;
            r_data_w_out <= data_w_in;
        end
    end
    
    assign data_w_byteen = r_data_w_byteen;
    assign data_w_out = r_data_w_out;

endmodule
