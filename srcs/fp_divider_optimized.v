`timescale 1ns / 1ps

module fp_divider_optimized (
    input clk,              // Clock input
    input rst_n,            // Active-low reset
    input [31:0] a,         // Dividend (IEEE 754 32-bit)
    input [31:0] b,         // Divisor (IEEE 754 32-bit)
    output reg flag_done,
    output reg [31:0] result // Quotient (IEEE 754 32-bit)
);

// Pipeline stage registers
reg [31:0] a_stage1, b_stage1;
reg sign_stage1;
reg [7:0] exp_a_stage1, exp_b_stage1;
reg [23:0] mantissa_a_stage1, mantissa_b_stage1;
reg is_zero_a_stage1, is_zero_b_stage1;
reg [4:0] count;

reg sign_stage2;
reg [7:0] exp_diff_stage2;
reg [23:0] mantissa_a_stage2, mantissa_b_stage2;
reg is_zero_a_stage2, is_zero_b_stage2;

wire [47:0] mantissa_quotient; // Output from SRT divider
reg [7:0] exp_stage3;
reg sign_stage3;

reg [47:0] quotient_stage4;
reg [7:0] exp_adjusted_stage4;
reg sign_stage4;

reg [22:0] mantissa_out_stage5;
reg [7:0] exp_out_stage5;
reg sign_stage5;

// Stage 1: Unpack inputs and check for zero
always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        a_stage1 <= 0; b_stage1 <= 0; sign_stage1 <= 0;
        exp_a_stage1 <= 0; exp_b_stage1 <= 0;
        mantissa_a_stage1 <= 0; mantissa_b_stage1 <= 0;
        is_zero_a_stage1 <= 0; is_zero_b_stage1 <= 0;
    end 
    else begin
        a_stage1 <= a; b_stage1 <= b;
        sign_stage1 <= a[31] ^ b[31]; // XOR for sign
        exp_a_stage1 <= a[30:23]; exp_b_stage1 <= b[30:23];
        mantissa_a_stage1 <= (a[30:23] == 0) ? 24'b0 : {1'b1, a[22:0]};
        mantissa_b_stage1 <= (b[30:23] == 0) ? 24'b0 : {1'b1, b[22:0]};
        is_zero_a_stage1 <= (a[30:0] == 0); is_zero_b_stage1 <= (b[30:0] == 0);
    end
end

// Stage 2: Handle special cases and prepare for division
always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        sign_stage2 <= 0; exp_diff_stage2 <= 0;
        mantissa_a_stage2 <= 0; mantissa_b_stage2 <= 0;
        is_zero_a_stage2 <= 0; is_zero_b_stage2 <= 0;
    end 
    else begin
        sign_stage2 <= sign_stage1;
        if (is_zero_b_stage1) begin
            exp_diff_stage2 <= 8'd255; // Infinity
            mantissa_a_stage2 <= 0; mantissa_b_stage2 <= 0;
        end 
        else if (is_zero_a_stage1) begin
            exp_diff_stage2 <= 0; // Zero
            mantissa_a_stage2 <= 0; mantissa_b_stage2 <= 0;
        end 
        else begin
            exp_diff_stage2 <= exp_a_stage1 - exp_b_stage1 + 8'd127;
            mantissa_a_stage2 <= mantissa_a_stage1;
            mantissa_b_stage2 <= mantissa_b_stage1;
        end
        is_zero_a_stage2 <= is_zero_a_stage1; is_zero_b_stage2 <= is_zero_b_stage1;
    end
end

// SRT Divider Instantiation
srt_divider #( 
    .MANTISSA_WIDTH(24),
    .PIPELINE_STAGES(24)
) mantissa_div (
    .clk(clk),
    .rst_n(rst_n),
    .dividend(mantissa_a_stage2),
    .divisor(mantissa_b_stage2),
    .quotient(mantissa_quotient)
);

// Stage 3: Capture quotient and exponent
always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        exp_stage3 <= 0; sign_stage3 <= 0;
    end 
    else begin
        sign_stage3 <= sign_stage2; exp_stage3 <= exp_diff_stage2;
    end
end

// Stage 4: Normalize
always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        quotient_stage4 <= 0; exp_adjusted_stage4 <= 0; sign_stage4 <= 0;
    end 
    else begin
        sign_stage4 <= sign_stage3; quotient_stage4 <= mantissa_quotient;
        if (mantissa_quotient[47]) begin
            quotient_stage4 <= mantissa_quotient >> 1;
            exp_adjusted_stage4 <= exp_stage3 + 1;
        end 
        else begin
            exp_adjusted_stage4 <= exp_stage3;
        end
    end
end

// Stage 5: Final normalization and packing
always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        result <= 0; mantissa_out_stage5 <= 0; exp_out_stage5 <= 0; sign_stage5 <= 0;
    end 
    else begin
        sign_stage5 <= sign_stage4;
        if (quotient_stage4 == 0) begin
            mantissa_out_stage5 <= 0; exp_out_stage5 <= 0;
        end 
        else begin
            mantissa_out_stage5 <= quotient_stage4[46:24];
            exp_out_stage5 <= exp_adjusted_stage4;
        end
        result <= {sign_stage5, exp_out_stage5, mantissa_out_stage5};
    end
end

always@(posedge clk or posedge rst_n) begin
 if(rst_n) begin
  flag_done<=1'b0;
  count<=5'b00000;
 end
 else begin
  count<=count+1;
  if(count==5'd20) begin
   flag_done<=1'b1;
   count<=3'd0;
  end
 end

end


endmodule

