module mul_p3 (
    input              clk,
    input              rst,
    input              sign_in,
    input      [8:0]   exp_sum_in,     // From Stage 2
    input      [47:0]  mant_prod_in,   // From Stage 2
    output reg         sign_out,
    output reg [8:0]   exp_sum_out,
    output wire [22:0]  mantissa_out    // 23-bit fraction
);

    reg [47:0] mant_shifted;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sign_out     <= 0;
            exp_sum_out  <= 0;
            mant_shifted <= 0;
        end else begin
            sign_out <= sign_in;

            if (mant_prod_in[47] == 1'b1) begin
                // Needs normalization: shift right and increment exponent
                mant_shifted <= mant_prod_in >> 1;
                exp_sum_out  <= exp_sum_in + 1'b1;
            end else begin
                // Already normalized
                mant_shifted <= mant_prod_in;
                exp_sum_out  <= exp_sum_in;
            end

            // Take only the fraction bits (discard hidden '1')
              
        end
    end
assign mantissa_out = mant_shifted[45:23];
endmodule
