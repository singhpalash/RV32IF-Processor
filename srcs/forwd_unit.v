`timescale 1ns / 1ps
module forwd_unit (
    input wire [4:0] ex_rs1, ex_rs2,   // Source registers in EX stage
    input wire [4:0] mem_rd, wb_rd,    // Destination registers from MEM/WB stages
    input wire [31:0] ex_result,
    input wire [31:0] mem_result,
    input wire mem_reg_write, wb_reg_write, // Write-back control signals
    output reg [1:0] forward_a, forward_b, // Forwarding select signals
    output reg [31:0] fwd_a_data,
    output reg [31:0] fwd_b_data
    );

always@(*) begin
    
    forward_a = 2'b00;
    forward_b = 2'b00;

    // Forward from MEM stage
    if (mem_reg_write && (mem_rd != 0) && (mem_rd == ex_rs1)) begin
        forward_a = 2'b10;
        fwd_a_data<=ex_result;
    end
    //forward from wb stage
    else if (wb_reg_write && (wb_rd != 0) && (wb_rd == ex_rs1)) begin
        forward_a = 2'b01;
        fwd_a_data<=mem_result;
    end
    if (mem_reg_write && (mem_rd != 0) && (mem_rd == ex_rs2)) begin
        forward_b = 2'b10;
        fwd_b_data<=ex_result;
    end
    else if (wb_reg_write && (wb_rd != 0) && (wb_rd == ex_rs2)) begin
        forward_b = 2'b01;
        fwd_b_data<=ex_result;
    end
end

endmodule

