module mul_p2 (
    input         clk,
    input         rst,
    input         sign_in,          // from Stage 1
    input  [8:0]  exp_sum_in,        // from Stage 1
    input  [23:0] mant_a_in, mant_b_in, // from Stage 1
    output reg    sign_out,          // to Stage 3
    output reg [8:0]  exp_sum_out,    // to Stage 3
    output reg [47:0] mant_prod_out   // 48-bit product to Stage 3
);
    localparam BIAS=127;
    reg [47:0] mant_prod; // combinational product

    always @(*) begin
        mant_prod = mant_a_in * mant_b_in; // multiply mantissas
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sign_out      <= 1'b0;
            exp_sum_out   <= 9'd0;
            mant_prod_out <= 48'd0;
        end
        else begin
            sign_out      <= sign_in;       // pass sign through
            exp_sum_out   <= exp_sum_in + BIAS;    // pass exponent sum through
            mant_prod_out <= mant_prod;     // store product in pipeline reg
        end
    end

endmodule
