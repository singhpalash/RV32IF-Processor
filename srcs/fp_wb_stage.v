`timescale 1ns / 1ps
module fp_wb_stage(
    input wire clk,
    input wire rst,
    input wire [31:0] mem_data_out_f_wb,
    input wire [31:0] result_f_wb,
    input wire lw_en,
    input wire [4:0] rd_temp_f_out_wb,
    input wire wb_enable_f_out_wb,
    output wire [4:0] rd_temp_f_wb,
    output wire [31:0] wb_data_f,
    output wire reg_write_f_en
);

    reg [31:0] wb_data_temp_f;
    reg [4:0] rd_temp_f;
    reg reg_write_enable_f;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_data_temp_f <= 32'd0;
            rd_temp_f <= 5'd0;
            reg_write_enable_f <= 1'b0;
        end else begin
            if (wb_enable_f_out_wb) begin
                case (lw_en)
                    1'b0: begin // Write result from FPU
                        wb_data_temp_f <= result_f_wb;
                        rd_temp_f <= rd_temp_f_out_wb;
                        reg_write_enable_f <= 1'b1;
                    end
                    1'b1: begin // Load from memory
                        wb_data_temp_f <= mem_data_out_f_wb;
                        rd_temp_f <= rd_temp_f_out_wb;
                        reg_write_enable_f <= 1'b1;
                    end
                endcase
            end else begin
                reg_write_enable_f <= 1'b0;
            end
        end
    end

    assign wb_data_f = wb_data_temp_f;
    assign rd_temp_f_wb = rd_temp_f;
    assign reg_write_f_en = reg_write_enable_f;

endmodule
