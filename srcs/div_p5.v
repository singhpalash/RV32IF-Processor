module div_p5 (
    input         clk,
    input         rst,
    input         sign_in,
    input  [8:0]  exp_in,      // normalized exponent (9 bits)
    input  [23:0] mant_in,     // normalized mantissa with implicit leading 1
    output reg [31:0] result_out
);

    always @(posedge clk) begin
        if (rst) begin
            result_out <= 32'd0;
        end else begin
            // Pack IEEE 754 single-precision float
            // sign bit
            result_out[31] <= sign_in;

            // exponent bits [30:23] (take lower 8 bits, assuming exponent fits)
            result_out[30:23] <= exp_in[7:0];

            // mantissa bits [22:0] (drop implicit leading 1)
            result_out[22:0] <= mant_in[22:0];
        end
    end

endmodule
