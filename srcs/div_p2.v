module div_p2 (
    input         clk,
    input         rst,          // synchronous reset
    input         sign_in,      // sign from div_p1
    input  [8:0]  exp_in,       // exponent difference + bias from div_p1
    input  [23:0] mant_a_in,    // numerator mantissa from div_p1
    input  [23:0] mant_b_in,    // denominator mantissa from div_p1
    output reg    sign_out,     // propagated sign
    output reg [8:0]  exp_out,  // exponent after normalization adjustment
    output reg [23:0] mant_a_out, // numerator mantissa adjusted for division
    output reg [23:0] mant_b_out  // denominator mantissa unchanged
);

    reg [24:0] mant_a_norm; // 25 bits to hold possible shifted mantissa during normalization
    reg [8:0]  exp_adj;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sign_out    <= 1'b0;
            exp_out     <= 9'd0;
            mant_a_out  <= 24'd0;
            mant_b_out  <= 24'd0;
        end else begin
            // Propagate sign directly
            sign_out <= sign_in;

            // Normalize numerator mantissa if leading bit is 0
            // (division mantissa could be less than 1.0 after subtraction)
            if (mant_a_in[23] == 1'b1) begin
                mant_a_norm = {1'b0, mant_a_in}; // no shift needed
                exp_adj = exp_in;
            end else begin
                // If MSB is zero, shift mantissa left by 1 and decrement exponent
                mant_a_norm = {mant_a_in, 1'b0};
                exp_adj = exp_in - 9'd1;
            end

            // Assign normalized mantissa and adjusted exponent
            mant_a_out <= mant_a_norm[23:0];
            mant_b_out <= mant_b_in;    // denominator mantissa unchanged
            exp_out   <= exp_adj;
        end
    end

endmodule
