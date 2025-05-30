`timescale 1ns / 1ps

module ex_stage (
    input wire clk,
    input wire rst,
    input wire [31:0] a,  // ALU operand 1
    input wire [31:0] b,  // ALU operand 2
    input wire [31:0] fwd_a,//coming from hazard unit
    input wire [31:0] fwd_b,//coming from hazard unit
    input wire [1:0] forward_a,forward_b,
    input wire [4:0] rd,  // Destination register
    input wire [31:0] linkreg,
    input wire ld,
    input wire mem_enable,
    input wire mem_read,
    input wire mem_write,
    input wire wb_enable,
    input wire [31:0] imm_value,
    input wire [6:0] op_code,
    input wire [31:0] pc,
    input wire [2:0] func,
    input wire [6:0] funct7,

    


    output reg [31:0] result,  // ALU result
    output reg flag,
    output reg jump_taken,
    output reg branch_taken,
    output reg [31:0] branch_addr,
    output reg [31:0] jump_address,
    output reg [31:0] link_register,
    output reg [31:0] data_for_writing_for_sw,
    output reg mem_enable_mem,
    output reg mem_read_mem,
    output reg mem_write_mem,
    output reg wb_enable_mem,
    output reg [4:0] rd_mem,
    output reg ld_mem,flush_out,
    output reg mem_wben_fwd,
    output reg [4:0] rd_fwd
);

    // Internal signals for ALU
    wire [31:0] alu_result;
    wire alu_flag;
    wire alu_jump_taken;
    wire alu_branch_taken;
    wire [31:0] alu_branch_addr;
    wire [31:0] alu_jump_address;
    wire [31:0] alu_link_register;
    wire [31:0] alu_data_for_sw;
    wire alu_mem_enable;
    wire alu_mem_read;
    wire alu_mem_write;
    wire alu_wb_enable;
    wire [4:0] alu_rd_mem;
    wire alu_ld_mem;
    wire flush_int;
    // MUX for Forwarding Operand A
    reg [31:0] alu_a;
    always @(*) begin
        case (forward_a)
            2'b00: alu_a = a;              // No forwarding
            2'b01: alu_a = fwd_a;  // Forward from EX/MEM
            2'b10: alu_a = fwd_a;  // Forward from MEM/WB
            default: alu_a = a;            // Default case (no change)
        endcase
    end

    // MUX for Forwarding Operand B
    reg [31:0] alu_b;
    always @(*) begin
        case (forward_b)
            2'b00: alu_b = b;              // No forwarding
            2'b01: alu_b = fwd_b;  // Forward from EX/MEM
            2'b10: alu_b = fwd_b;  // Forward from MEM/WB
            default: alu_b = b;            // Default case 
        endcase
    end

    // Instantiate ALU
    alu alu_inst (
        .a(alu_a),  // Use forwarded value
        .b(alu_b),  // Use forwarded value
        .rd(rd),
        .linkreg(linkreg),
        .ld(ld),
        .mem_enable(mem_enable),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .wb_enable(wb_enable),
        .imm_value(imm_value),
        .op_code(op_code),
        .pc(pc),
        .func(func),
        .funct7(funct7),
        .result(alu_result),
        .flag(alu_flag),
        .jump_taken(alu_jump_taken),
        .branch_taken(alu_branch_taken),
        .branch_addr(alu_branch_addr),
        .jump_address(alu_jump_address),
        .link_register(alu_link_register),
        .data_for_writing_for_sw(alu_data_for_sw),
        .mem_enable_mem(alu_mem_enable),
        .mem_read_mem(alu_mem_read),
        .mem_write_mem(alu_mem_write),
        .wb_enable_mem(alu_wb_enable),
        .rd_mem(alu_rd_mem),
        .ld_mem(alu_ld_mem),
        .flush(flush_int)
    );

    // Pipeline Registers for EX/MEM Stage
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 32'b0;
            flag <= 1'b0;
            jump_taken <= 1'b0;
            branch_taken <= 1'b0;
            branch_addr <= 32'b0;
            jump_address <= 32'b0;
            link_register <= 32'b0;
            data_for_writing_for_sw <= 32'b0;
            mem_enable_mem <= 1'b0;
            mem_read_mem <= 1'b0;
            mem_write_mem <= 1'b0;
            wb_enable_mem <= 1'b0;
            rd_mem <= 5'b0;
            ld_mem <= 1'b0;
            flush_out<=1'b0;
            mem_wben_fwd<=1'b0;
            rd_fwd<=5'b0;
        end else begin
            result <= alu_result;  
            flag <= alu_flag;
            jump_taken <= alu_jump_taken;
            flush_out<=flush_int;
            branch_taken <= alu_branch_taken;
            
            branch_addr <= alu_branch_addr;
            jump_address <= alu_jump_address;
            link_register <= alu_link_register;
            data_for_writing_for_sw <= alu_data_for_sw;
            mem_enable_mem <= alu_mem_enable;
            mem_read_mem <= alu_mem_read;
            mem_write_mem <= alu_mem_write;
            wb_enable_mem <= alu_wb_enable;
            rd_mem <= alu_rd_mem;
            ld_mem <= alu_ld_mem;
            mem_wben_fwd<=alu_wb_enable;
            rd_fwd<=alu_rd_mem;
        end
    end

endmodule

