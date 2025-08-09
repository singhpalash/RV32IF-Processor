module mul_p4 (
    input  wire        clk,
    input  wire        rst,
    input  wire        sign_in,
    input  wire [8:0]  exp_in,    // 9 bits from stage 3
    input  wire [22:0] mant_in,   // normalized mantissa
    output reg  [31:0] result
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 32'b0;
        end else begin
            // Handle exponent overflow/underflow if needed here
            // For now, assume no overflow/underflow from normalization
            result <= { sign_in, exp_in[7:0], mant_in }; 
        end
    end
endmodule
