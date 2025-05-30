`timescale 1ns/1ps
module pc_incr_block(input wire [31:0] b,output wire [31:0] inc_pc);
assign inc_pc= b + 32'd4;
endmodule
