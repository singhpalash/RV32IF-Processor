module div_p3 (
    input         clk,
    input         rst,
    input         sign_in,           // sign from div_p2
    input  [8:0]  exp_in,            // exponent from div_p2
    input  [23:0] mant_a_in,         // numerator mantissa (normalized)
    input  [23:0] mant_b_in,         // denominator mantissa
    output reg    sign_out,          // sign output (registered)
    output reg [8:0]  exp_out,       // exponent output (registered)
    output reg [23:0] mant_res       // quotient mantissa (registered)
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sign_out <= 1'b0;
            exp_out  <= 9'd0;
            mant_res <= 24'd0;
        end else begin
            sign_out <= sign_in;
            exp_out  <= exp_in;
            mant_res <= mant_a_in / mant_b_in; // divider operator on mantissas
        end
    end

endmodule
