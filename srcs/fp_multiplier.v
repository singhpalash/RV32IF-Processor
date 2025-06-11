`timescale 1ns / 1ps
module fp_multiplier (
    input clk,              // Clock signal
    input reset,            // Synchronous reset
    input [31:0] a,         // First 32-bit floating-point operand
    input [31:0] b,         // Second 32-bit floating-point operand
    output reg flag_done,
    
    output reg [31:0] result // 32-bit floating-point result
);

// Stage 1: Unpack the operands
reg sign_a_stage1, sign_b_stage1;       // Sign bits
reg [7:0] exp_a_stage1, exp_b_stage1;   // 8-bit exponents
reg [23:0] mant_a_stage1, mant_b_stage1; // 24-bit mantissas (with implicit 1)
reg [2:0] count;

always @(posedge clk) begin
    if (reset) begin
        sign_a_stage1 <= 0;
        sign_b_stage1 <= 0;
        exp_a_stage1 <= 0;
        exp_b_stage1 <= 0;
        mant_a_stage1 <= 0;
        mant_b_stage1 <= 0;
    end else begin
        sign_a_stage1 <= a[31];                  // Extract sign of a
        sign_b_stage1 <= b[31];                  // Extract sign of b
        exp_a_stage1 <= a[30:23];                // Extract exponent of a
        exp_b_stage1 <= b[30:23];                // Extract exponent of b
        // Set mantissa to 0 if exponent is 0 (zero case), else prepend implicit 1
        mant_a_stage1 <= (a[30:23] == 0) ? 24'b0 : {1'b1, a[22:0]};
        mant_b_stage1 <= (b[30:23] == 0) ? 24'b0 : {1'b1, b[22:0]};
    end
end

// Stage 2: Multiply mantissas and add exponents
reg sign_stage2;                // Sign bit for stage 2
reg [7:0] exp_sum_stage2;       // Sum of exponents minus bias
reg [47:0] mant_product_stage2; // 48-bit mantissa product

always @(posedge clk) begin
    if (reset) begin
        sign_stage2 <= 0;
        exp_sum_stage2 <= 0;
        mant_product_stage2 <= 0;
    end else begin
        sign_stage2 <= sign_a_stage1 ^ sign_b_stage1;           // Sign is XOR of input signs
        exp_sum_stage2 <= exp_a_stage1 + exp_b_stage1 - 8'd127; // Add exponents, subtract bias
        mant_product_stage2 <= mant_a_stage1 * mant_b_stage1;   // Multiply mantissas
    end
end

// Stage 3: Normalize the result
reg sign_stage3;        // Sign bit for stage 3
reg [7:0] exp_stage3;   // Normalized exponent
reg [23:0] mant_stage3; // Normalized 24-bit mantissa

always @(posedge clk) begin
    if (reset) begin
        sign_stage3 <= 0;
        exp_stage3 <= 0;
        mant_stage3 <= 0;
    end else begin
        sign_stage3 <= sign_stage2;
        if (mant_product_stage2[47]) begin
            // If MSB is 1, shift right by 1 and increment exponent
            mant_stage3 <= mant_product_stage2[47:24];
            exp_stage3 <= exp_sum_stage2 + 1;
        end else begin
            // Otherwise, align mantissa and keep exponent
            mant_stage3 <= {mant_product_stage2[46:23], 1'b0};
            exp_stage3 <= exp_sum_stage2;
        end
    end
end

// Output stage: Pack the result
always @(posedge clk) begin
    if (reset) begin
        result <= 32'b0;
    end else begin
        if (mant_stage3 == 0) begin
            // If mantissa is zero, output zero
            result <= 32'b0;
        end else begin
            // Pack sign, exponent, and mantissa (drop implicit 1)
            result <= {sign_stage3, exp_stage3, mant_stage3[22:0]};
        end
    end
end

always@(posedge clk or posedge reset) begin
 if(reset) begin
  flag_done<=1'b0;
  count<=3'b000;
 end
 else begin
  count<=count+1;
  if(count==3'd6) begin
   flag_done<=1'b1;
   count<=3'd0;
  end
 end

end


endmodule
