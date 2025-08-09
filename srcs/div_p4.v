module div_p4 (
    input         clk,
    input         rst,
    input         sign_in,
    input  [8:0]  exp_in,
    input  [23:0] mant_in,
    output reg    sign_out,
    output reg [8:0]  exp_out,
    output reg [23:0] mant_out
);

    reg [24:0] mant_extended;
    reg [8:0] exp_adj;

    always @(posedge clk) begin
        if (rst) begin
            sign_out <= 1'b0;
            exp_out  <= 9'd0;
            mant_out <= 24'd0;
        end else begin
            sign_out <= sign_in;

            mant_extended = {1'b0, mant_in}; // 25 bits for normalization

            // Normalization logic:
            if (mant_in[23] == 1'b1) begin
                // Already normalized or might be >1.0?
                if (mant_in[23]) begin
                    // Check if mantissa >= 2.0 (bit 24)
                    if (mant_extended[24] == 1'b1) begin
                        // Mantissa >= 2, shift right by 1, increment exponent
                        mant_out <= mant_in >> 1;
                        exp_out <= exp_in + 9'd1;
                    end else begin
                        // Mantissa normalized, no shift
                        mant_out <= mant_in;
                        exp_out <= exp_in;
                    end
                end
            end else begin
                // Leading bit is zero, shift left until bit 23 is 1
                if (mant_in == 24'd0) begin
                    // Zero case
                    mant_out <= 24'd0;
                    exp_out <= 9'd0;
                end else begin
                    // Shift left by 1, decrement exponent
                    mant_out <= mant_in << 1;
                    exp_out <= exp_in - 9'd1;
                end
            end
        end
    end
endmodule
