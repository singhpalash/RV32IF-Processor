`timescale 1ns / 1ps

module add_top(
    input clk, rst,sub,
    input [31:0] a, b,
    output [31:0] result
);

    // Stage 1 → Stage 2 wires
    wire [23:0] mant_out_a_s1, mant_out_b_s1;
    wire [7:0]  exp_large_s1;
    wire        sign_out_s1;

    // Stage 2 → Stage 3 wires
    wire [23:0] sum_mant_s2;
    wire [7:0]  exp_large_s2;
    wire        sign_out_s2;

    // Stage 3 → Stage 4 wires
    wire [7:0]  exp_large_s3;
    wire [7:0]  leading_zero_ctr_s3;
    wire [23:0] left_shifted_mant_s3;
    wire        sign_out_s3;

    // Stage 4 → Stage 5 wires
    wire [7:0]  exp_final_s4;
    wire [22:0] mant_final_s4;
    wire        sign_out_s4;

    // Stage 1
    add_p1 u1 (
        .clk(clk), .rst(rst),
        .a(a), .b(b),.sub(sub),
        .mant_out_a(mant_out_a_s1),
        .mant_out_b(mant_out_b_s1),
        .exp_large(exp_large_s1),
        .sign_out(sign_out_s1)
    );

    // Stage 2
    add_p2 u2 (
        .clk(clk), .rst(rst),
        .mant_out_a(mant_out_a_s1),
        .mant_out_b(mant_out_b_s1),
        .exp_large(exp_large_s1),
        .sign_out(sign_out_s1),
        .sum_mant(sum_mant_s2),
        .exp_large_out(exp_large_s2),
        .sign_out_s3(sign_out_s2)
    );

    // Stage 3
    add_p3 u3 (
        .clk(clk), .rst(rst),
        .sum_mant(sum_mant_s2),
        .exp_large_out(exp_large_s2),
        .sign_out_s3(sign_out_s2),
        .exp_large_out_s4(exp_large_s3),
        .leading_zero_ctr(leading_zero_ctr_s3),
        .left_shifted_mant(left_shifted_mant_s3),
        .sign_out_s4(sign_out_s3)
    );

    // Stage 4
    add_p4 u4 (
        .clk(clk), .rst(rst),
        .exp_large_out_s4(exp_large_s3),
        .leading_zero_ctr(leading_zero_ctr_s3),
        .left_shifted_mant(left_shifted_mant_s3),
        .sign_out_s4(sign_out_s3),
        .exp_final(exp_final_s4),
        .mant_final(mant_final_s4),
        .sign_out_final(sign_out_s4)
    );

    // Stage 5
    add_p5 u5 (
        .clk(clk), .rst(rst),
        .exp_final(exp_final_s4),
        .mant_final(mant_final_s4),
        .sign_out_final(sign_out_s4),
        .result(result)
    );

endmodule
