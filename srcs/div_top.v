module div_top (
    input         clk,
    input         rst,
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] result
);

    // Wires between stages
    wire        sign_p1;
    wire [8:0]  exp_p1;
    wire [23:0] mant_a_p1;
    wire [23:0] mant_b_p1;

    wire        sign_p2;
    wire [8:0]  exp_p2;
    wire [23:0] mant_a_p2;
    wire [23:0] mant_b_p2;

    wire        sign_p3;
    wire [8:0]  exp_p3;
    wire [23:0] mant_res_p3;

    wire        sign_p4;
    wire [8:0]  exp_p4;
    wire [23:0] mant_norm_p4;

    wire [31:0] result_p5;

    // Instantiate div_p1: unpack inputs and initial sign/exp calc
    div_p1 u_div_p1 (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .sign(sign_p1),
        .exp_diff(exp_p1),
        .mant_a(mant_a_p1),
        .mant_b(mant_b_p1)
    );

    // Instantiate div_p2: normalize numerator mantissa
    div_p2 u_div_p2 (
        .clk(clk),
        .rst(rst),
        .sign_in(sign_p1),
        .exp_in(exp_p1),
        .mant_a_in(mant_a_p1),
        .mant_b_in(mant_b_p1),
        .sign_out(sign_p2),
        .exp_out(exp_p2),
        .mant_a_out(mant_a_p2),
        .mant_b_out(mant_b_p2)
    );

    // Instantiate div_p3: mantissa division (combinational division in 1 cycle)
    div_p3 u_div_p3 (
        .clk(clk),
        .rst(rst),
        .sign_in(sign_p2),
        .exp_in(exp_p2),
        .mant_a_in(mant_a_p2),
        .mant_b_in(mant_b_p2),
        .sign_out(sign_p3),
        .exp_out(exp_p3),
        .mant_res(mant_res_p3)
    );

    // Instantiate div_p4: normalization & rounding
    div_p4 u_div_p4 (
        .clk(clk),
        .rst(rst),
        .sign_in(sign_p3),
        .exp_in(exp_p3),
        .mant_in(mant_res_p3),
        .sign_out(sign_p4),
        .exp_out(exp_p4),
        .mant_out(mant_norm_p4)
    );

    // Instantiate div_p5: final packing
    div_p5 u_div_p5 (
        .clk(clk),
        .rst(rst),
        .sign_in(sign_p4),
        .exp_in(exp_p4),
        .mant_in(mant_norm_p4),
        .result_out(result_p5)
    );

    assign result = result_p5;

endmodule
