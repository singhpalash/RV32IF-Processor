`timescale 1ns / 1ps

module srt_divider #(
    parameter MANTISSA_WIDTH = 24,   // Width of the mantissa (e.g., 24 for single-precision)
    parameter PIPELINE_STAGES = 24   // Number of pipeline stages (one per quotient bit)
) (
    input clk,                                // Clock signal
    input rst_n,                              // Active-low reset
    input [MANTISSA_WIDTH-1:0] dividend,      // Mantissa of the dividend (normalized)
    input [MANTISSA_WIDTH-1:0] divisor,       // Mantissa of the divisor (normalized)
    output reg [MANTISSA_WIDTH:0] quotient,   // Quotient (extra bit for normalization)
    output reg valid                          // Output valid flag
);

    // Internal pipeline registers
    reg [MANTISSA_WIDTH-1:0] partial_remainder [0:PIPELINE_STAGES];
    reg [MANTISSA_WIDTH:0] quotient_reg [0:PIPELINE_STAGES];
    reg [MANTISSA_WIDTH:0] shifted_remainder;
    reg quotient_bit;
    integer i;

    // Stage counter
    reg [$clog2(PIPELINE_STAGES+1)-1:0] stage;

    // SRT division logic with pipelined computation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset logic
            for (i = 0; i <= PIPELINE_STAGES; i = i + 1) begin
                partial_remainder[i] <= 0;
                quotient_reg[i] <= 0;
            end
            quotient <= 0;
            valid <= 0;
            stage <= 0;
        end else begin
            if (stage == 0) begin
                // Initialize stage 0
                partial_remainder[0] <= dividend;
                quotient_reg[0] <= 0;
                stage <= stage + 1;
                valid <= 0;
            end else if (stage <= PIPELINE_STAGES) begin
                // Perform one division stage
                shifted_remainder = {partial_remainder[stage - 1], 1'b0};

                if (shifted_remainder >= {divisor, 1'b0}) begin
                    quotient_bit = 1;
                    partial_remainder[stage] = shifted_remainder - {divisor, 1'b0};
                end else begin
                    quotient_bit = 0;
                    partial_remainder[stage] = shifted_remainder;
                end

                quotient_reg[stage] = (quotient_reg[stage - 1] << 1) | quotient_bit;

                // Update output when last stage is reached
                if (stage == PIPELINE_STAGES) begin
                    quotient <= quotient_reg[stage];
                    valid <= 1;
                    stage <= 0; // Reset for next operation
                end else begin
                    stage <= stage + 1;
                end
            end
        end
    end

endmodule
