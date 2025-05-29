`timescale 1ns / 1ps

module reg_bank_f(
    input  wire        clk,
    input  wire        rst,
    input  wire [4:0]  rs1_f,
    input  wire [4:0]  rs2_f,
    input  wire [4:0]  rd_temp_f_wb,
    input  wire        read_regport_f1,
    input  wire        read_regport_f2,
    input  wire [31:0] wb_data_f,
    input  wire        wb_enable_f,
    output wire [31:0] rs1_data_f,
    output wire [31:0] rs2_data_f
);

    integer i;
    reg [31:0] registers_f [0:31];

    // Read ports: x0 always reads zero
    assign rs1_data_f = (read_regport_f1 == 1'b0) ? 32'd0 : registers_f[rs1_f];
    assign rs2_data_f = (read_regport_f2 == 1'b0) ? 32'd0 : registers_f[rs2_f];

    // Asynchronous reset and writeback
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize all 32 registers to zero
            for (i = 0; i < 32; i = i + 1) begin
                registers_f[i] <= i;
            end
        end else begin
            // Writeback: if enabled and destination != x0
            if (wb_enable_f && rd_temp_f_wb != 5'b00000) begin
                registers_f[rd_temp_f_wb] <= wb_data_f;
            end
            // Ensure x0 stays zero
            registers_f[0] <= 32'd0;
        end
    end

endmodule