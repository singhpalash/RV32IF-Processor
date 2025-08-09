`timescale 1ns/1ps

module mul_top (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] result
);

    // Internal stage wires

    // Stage 1 outputs
    wire sign_s1;
    wire [8:0] exp_sum_s1;
    wire [23:0] mant_a_s1, mant_b_s1;

    // Stage 2 outputs
    wire sign_s2;
    wire [8:0] exp_sum_s2;
    wire [47:0] mant_prod_s2;

    // Stage 3 outputs
    wire sign_s3;
    wire [8:0] exp_s3;
    wire [22:0] mant_s3;

    // Stage 1
    mul_p1 u1 (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .sign(sign_s1),
        .exp_sum(exp_sum_s1),
        .mant_a(mant_a_s1),
        .mant_b(mant_b_s1)
    );

    // Stage 2
    mul_p2 u2 (
        .clk(clk),
        .rst(rst),
        .sign_in(sign_s1),
        .exp_sum_in(exp_sum_s1),
        .mant_a_in(mant_a_s1),
        .mant_b_in(mant_b_s1),
        .sign_out(sign_s2),
        .exp_sum_out(exp_sum_s2),
        .mant_prod_out(mant_prod_s2)
    );

    // Stage 3 (Normalizer)
    mul_p3 u3 (
        .clk(clk),
        .rst(rst),
        .sign_in(sign_s2),
        .exp_sum_in(exp_sum_s2),
        .mant_prod_in(mant_prod_s2),
        .sign_out(sign_s3),
        .exp_sum_out(exp_s3),
        .mantissa_out(mant_s3)
    );

    // Stage 4 (Pack)
    mul_p4 u4 (
        .clk(clk),
        .rst(rst),
        .sign_in(sign_s3),
        .exp_in(exp_s3),
        .mant_in(mant_s3),
        .result(result)
    );

endmodule
