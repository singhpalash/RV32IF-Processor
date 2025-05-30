`timescale 1ns / 1ps
module fp_add_sub (
    input clk,              // Clock signal
    input reset,            // Synchronous reset
    input [31:0] a,         // First operand (IEEE 754 single precision)
    input [31:0] b,         // Second operand (IEEE 754 single precision)
    input sub,              // 0 for addition, 1 for subtraction
    output reg flag_done,
    output reg [31:0] result // Result (IEEE 754 single precision)
);

// Stage 1: Unpack operands, determine larger operand, swap if needed, compute effective operation
wire sign_A = a[31];
wire [7:0] exp_A = a[30:23];
wire [22:0] mant_A = a[22:0];
reg [2:0] count;

wire sign_B = b[31];
wire [7:0] exp_B = b[30:23];
wire [22:0] mant_B = b[22:0];

// Determine which operand is larger (based on exponent, then mantissa if equal)
wire is_larger_A = (exp_A > exp_B) | ((exp_A == exp_B) & (mant_A > mant_B));

// Swap operands so op1 is the larger, op2 is the smaller
wire sign_op1 = is_larger_A ? sign_A : sign_B;
wire [7:0] exp_op1 = is_larger_A ? exp_A : exp_B;
wire [22:0] mant_op1 = is_larger_A ? mant_A : mant_B;
wire sign_op2 = is_larger_A ? sign_B : sign_A;
wire [7:0] exp_op2 = is_larger_A ? exp_B : exp_A;
wire [22:0] mant_op2 = is_larger_A ? mant_B : mant_A;

// Include hidden bit (1 for normalized numbers)
wire [23:0] full_mant_op1 = {1'b1, mant_op1};
wire [23:0] full_mant_op2 = {1'b1, mant_op2};

// Compute exponent difference (always positive since op1 >= op2)
wire [7:0] exp_diff = exp_op1 - exp_op2;

// Compute effective operation: add if signs align after operation, subtract if they differ
wire effective_sign_op2 = sign_op2 ^ sub;
wire effective_operation = sign_op1 ^ effective_sign_op2;

// Stage 1 registers
reg [7:0] stage2_exp_op1;
reg [23:0] stage2_full_mant_op1;
reg sign_op1_reg;
reg [23:0] stage2_full_mant_op2;
reg [7:0] stage2_exp_diff;
reg stage2_effective_operation;

always @(posedge clk) begin
    if (reset) begin
        stage2_exp_op1 <= 0;
        stage2_full_mant_op1 <= 0;
        sign_op1_reg <= 0;
        stage2_full_mant_op2 <= 0;
        stage2_exp_diff <= 0;
        stage2_effective_operation <= 0;
    end else begin
        stage2_exp_op1 <= exp_op1;
        stage2_full_mant_op1 <= full_mant_op1;
        sign_op1_reg <= sign_op1;
        stage2_full_mant_op2 <= full_mant_op2;
        stage2_exp_diff <= exp_diff;
        stage2_effective_operation <= effective_operation;
    end
end

// Stage 2: Align the smaller mantissa
wire [47:0] temp_shift = {stage2_full_mant_op2, 24'b0} >> stage2_exp_diff;
wire [23:0] aligned_mant_op2 = temp_shift[47:24];
wire guard = temp_shift[23];
wire round_bit = temp_shift[22];
wire sticky = |temp_shift[21:0];

// Stage 2 registers
reg [23:0] stage3_aligned_mant_op2;
reg [23:0] stage3_full_mant_op1;
reg [7:0] stage3_exp_op1;
reg sign_op1_reg2;
reg stage3_effective_operation;
reg stage3_guard;
reg stage3_round_bit;
reg stage3_sticky;

always @(posedge clk) begin
    if (reset) begin
        stage3_aligned_mant_op2 <= 0;
        stage3_full_mant_op1 <= 0;
        stage3_exp_op1 <= 0;
        sign_op1_reg2 <= 0;
        stage3_effective_operation <= 0;
        stage3_guard <= 0;
        stage3_round_bit <= 0;
        stage3_sticky <= 0;
    end else begin
        stage3_aligned_mant_op2 <= aligned_mant_op2;
        stage3_full_mant_op1 <= stage2_full_mant_op1;
        stage3_exp_op1 <= stage2_exp_op1;
        sign_op1_reg2 <= sign_op1_reg;
        stage3_effective_operation <= stage2_effective_operation;
        stage3_guard <= guard;
        stage3_round_bit <= round_bit;
        stage3_sticky <= sticky;
    end
end

// Stage 3: Add or subtract mantissas
// Use 25 bits to handle carry in addition
wire [24:0] mant_sum = stage3_effective_operation ?
                       (stage3_full_mant_op1 - stage3_aligned_mant_op2) :
                       (stage3_full_mant_op1 + stage3_aligned_mant_op2);

// Stage 3 registers
reg [24:0] stage4_mant_sum;
reg [7:0] stage4_exp;
reg stage4_sign;
reg stage4_effective_operation;
reg stage4_guard;
reg stage4_round_bit;
reg stage4_sticky;

always @(posedge clk) begin
    if (reset) begin
        stage4_mant_sum <= 0;
        stage4_exp <= 0;
        stage4_sign <= 0;
        stage4_effective_operation <= 0;
        stage4_guard <= 0;
        stage4_round_bit <= 0;
        stage4_sticky <= 0;
    end else begin
        stage4_mant_sum <= mant_sum;
        stage4_exp <= stage3_exp_op1;
        stage4_sign <= sign_op1_reg2;
        stage4_effective_operation <= stage3_effective_operation;
        stage4_guard <= stage3_guard;
        stage4_round_bit <= stage3_round_bit;
        stage4_sticky <= stage3_sticky;
    end
end

// Stage 4: Normalize the result using a priority encoder
reg [4:0] lz; // Leading zero count (0 to 24)
always @(*) begin
    lz = 0;
    if (stage4_mant_sum == 0) begin
        lz = 25; // Special case: all zeros
    end else begin
        casex (stage4_mant_sum)
            25'b1xxxxxxxxxxxxxxxxxxxxxxxx: lz = 0;
            25'b01xxxxxxxxxxxxxxxxxxxxxxx: lz = 1;
            25'b001xxxxxxxxxxxxxxxxxxxxxx: lz = 2;
            25'b0001xxxxxxxxxxxxxxxxxxxxx: lz = 3;
            25'b00001xxxxxxxxxxxxxxxxxxxx: lz = 4;
            25'b000001xxxxxxxxxxxxxxxxxxx: lz = 5;
            25'b0000001xxxxxxxxxxxxxxxxxx: lz = 6;
            25'b00000001xxxxxxxxxxxxxxxxx: lz = 7;
            25'b000000001xxxxxxxxxxxxxxxx: lz = 8;
            25'b0000000001xxxxxxxxxxxxxxx: lz = 9;
            25'b00000000001xxxxxxxxxxxxxx: lz = 10;
            25'b000000000001xxxxxxxxxxxxx: lz = 11;
            25'b0000000000001xxxxxxxxxxxx: lz = 12;
            25'b00000000000001xxxxxxxxxxx: lz = 13;
            25'b000000000000001xxxxxxxxxx: lz = 14;
            25'b0000000000000001xxxxxxxxx: lz = 15;
            25'b00000000000000001xxxxxxxx: lz = 16;
            25'b000000000000000001xxxxxxx: lz = 17;
            25'b0000000000000000001xxxxxx: lz = 18;
            25'b00000000000000000001xxxxx: lz = 19;
            25'b000000000000000000001xxxx: lz = 20;
            25'b0000000000000000000001xxx: lz = 21;
            25'b00000000000000000000001xx: lz = 22;
            25'b000000000000000000000001x: lz = 23;
            25'b0000000000000000000000001: lz = 24;
            default: lz = 25; // Fallback (all zeros)
        endcase
    end
end

// Normalization logic
reg [23:0] normalized_mant;
reg [7:0] new_exp;
always @(*) begin
    if (stage4_effective_operation == 0) begin // Addition
        if (stage4_mant_sum[24]) begin
            normalized_mant = stage4_mant_sum[24:1]; // Shift right by 1
            new_exp = stage4_exp + 1;
        end else begin
            normalized_mant = stage4_mant_sum[23:0]; // No shift
            new_exp = stage4_exp;
        end
    end else begin // Subtraction
        if (stage4_mant_sum == 0) begin
            normalized_mant = 0;
            new_exp = 0;
        end else begin
            normalized_mant = stage4_mant_sum << lz; // Shift left by lz
            new_exp = stage4_exp - lz;
        end
    end
end

// Stage 4 registers
reg [23:0] stage5_mant;
reg [7:0] stage5_exp;
reg stage5_sign;

always @(posedge clk) begin
    if (reset) begin
        stage5_mant <= 0;
        stage5_exp <= 0;
        stage5_sign <= 0;
    end 
    else begin
        stage5_mant <= normalized_mant;
        stage5_exp <= new_exp;
        stage5_sign <= stage4_sign;
    end
end

// Stage 5: Pack the result
always @(posedge clk) begin
    if (reset) begin
        result <= 0;
        flag_done<=0;
    end 
    else begin
        if (stage5_mant == 0) begin
            result <= 32'b0; // Output zero if mantissa is zero
//            flag_done<=1;
        end 
        else begin
            result <= {stage5_sign, stage5_exp, stage5_mant[22:0]};
            
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
  if(count==3'd5) begin
   flag_done<=1'b1;
   count<=3'd0;
  end
 end

end

endmodule