`timescale 1ns / 1ps
module Id_stage_tb;

reg clk, rst;
reg [31:0] instruction, wb_data, pc;
reg reg_write_en;
wire [31:0] mux_out_pcora, mux_out_borimm;
wire [31:0] rs1_data, rs2_data, imm_value, pc_value;
wire [2:0] func_data_out;
wire [6:0] func_7_out, op_code_out;
wire [31:0] linkreg;
wire [31:0] nextpc;
wire [4:0] rd_register;
wire branch_enable_out, jal_en_out, jalr_en_out,mem_write_out;

Id_stage uut (
    .clk(clk),
    .rst(rst),
    .instruction(instruction),
    .wb_data(wb_data),
    .reg_write_en(reg_write_en),
    .pc(pc),
    .mux_out_pcora(mux_out_pcora),
    .mux_out_borimm(mux_out_borimm),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .imm_value(imm_value),
    .pc_value(pc_value),
    .func_data_out(func_data_out),
    .func_7_out(func_7_out),
    .op_code_out(op_code_out),
    .linkreg(linkreg),
    .nextpc(nextpc),
    .rd_register(rd_register),
    .branch_enable_out(branch_enable_out),
    .jal_en_out(jal_en_out),
    .jalr_en_out(jalr_en_out),
    .mem_write_out(mem_write_out)
);

always #5 clk = ~clk;

initial begin
    
    clk = 0;
    rst = 1;
    instruction = 32'h00000000;
    wb_data = 32'h00000000;
    reg_write_en = 0;
    pc = 32'h00000000;

   
    #10 rst = 0;
    #10 rst = 0;
    $monitor("Time %0t op_code_out %0b func_data_out %0b func_7_out %0b branch_enable_out: %0b jal_en_out: %0b jalr_en_out: %0b", $time,
             op_code_out, func_data_out, func_7_out, branch_enable_out, jal_en_out, jalr_en_out);

    // Test Case 1: R-Type Instruction (ADD x5, x6, x7)
    instruction = 32'b0000000_00111_00110_000_00101_0110011; // ADD x5, x6, x7
    #10;

    // Test Case 2: I-Type Instruction (ADDI x10, x11, 5)
    instruction = 32'b000000000101_01011_000_01010_0010011; // ADDI x10, x11, 5
    #10;

    // Test Case 3: Branch Instruction (BEQ x3, x4, 16)
    instruction = 32'b0000001_00100_00011_000_00010_1100011; // BEQ x3, x4, 16
    $display("branch_en %0b",uut.u_ctrl.branch_en);
    $display("branch_en %0b",uut.branch_en);
    #10;

    // Test Case 4: I-Type Instruction (ANDI x10, x11, 5)
    instruction = 32'b000000000101_01011_111_01010_0010011; // ANDI x10, x11, 5
    #10;

    // Test Case 5: B-Type Instruction (BGE x10, x11, 16)
    instruction = 32'b0000000_01011_01010_101_00110_1100011; // BGE x10, x11, 16
    $display("branch_immvalue %0d branch_pc_value %0d branch_enable_out %0b",
              uut.branch_immvalue,nextpc,
               branch_enable_out);
    #10;
    
    // Test Case 6: LW x5, 25(x4)
    instruction = 32'b00000000011001_00100_010_00101_0000011; // LW x5, 25(x4)
    #10;
    
    // Test Case 7: SW x2,21(x3)
    instruction = 32'b0000000_00010_00011_010_10101_0100011; // SW x2, 21(x3)
    $display("mem_write_out %0b",mem_write_out);
    #10;
    
    // Test Case 8: JAL (Jump and Link) Instruction
    instruction = 32'b00000000000000000001_00000_1101111; // JAL x1, 0x10
    $display("jalr pc value:%0d",nextpc);
    #10;

    // Test Case 9: JALR (Jump and Link Register) Instruction
    instruction = 32'b000000000000_00001_000_00010_1100111; // JALR x2, x1, 0
    #10;

    $finish;
end

endmodule