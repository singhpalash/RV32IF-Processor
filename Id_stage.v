`timescale 1ns / 1ps
module Id_stage(
    input wire clk,
    input wire rst,
    input wire [31:0] instruction,
    input wire [31:0] wb_data,
    input wire reg_write_en, // Coming from WB stage
    input wire [31:0] pc,
    input wire [4:0] rd_in, // From WB stage
    input wire flush_out, // Coming from ALU stage after branch check
    input wire flag_done,//coming just for imm_data of f class from fp alu to stall for high latecy alu operations like multi
    output wire [31:0] mux_out_pcora,
    output wire [31:0] mux_out_borimm,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data,
    output reg [31:0] imm_value,
    output reg [31:0] pc_value, // For EX stage
    output reg [31:0] nextpc, // For IF stage when branch or jump occurs
    output reg [4:0] rd_register, // Propagated till WB stage
    output reg [2:0] func_data_out,
    output reg [6:0] func_7_out,
    output reg [6:0] op_code_out,
    output reg [31:0] linkreg, // Link register, written back in WB stage
    output reg [31:0] instr_out, // Going to FP unit
    output reg branch_enable_out,
    output reg jal_en_out,
    output reg jalr_en_out,
    output reg mem_enable_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg wb_enable_out,
    output reg ld_enable_out,
    output reg [4:0] rs1_fwd,//these two are going to forwarding units remember
    output reg [4:0] rs2_fwd,
    output wire [4:0] rs1_f,//going to f class. for f class if we need the 
    output wire [4:0] rs2_f,
    output wire [4:0] rd_temp_f,
    output wire [6:0] opcode_f,
    output wire [2:0] func_data_f,
    output wire [6:0] func_7_f,
    output wire read_regport_f1_out,//just assign all these the values coming from control unit 
    output wire read_regport_f2_out,
    output wire mem_enable_f_out,
    output wire mem_write_f_out,
    output wire wb_enable_f_out,
    output reg [31:0]imm_data_f_out//right now the imm_gen is still not updated with the information that which opcodes to generate_imm_data
    //connect this imm_data_f_out to ex stage input of f-class
 );

// Decoded Instruction Fields
wire mem_enable_temp,mem_read_temp,mem_write_temp,wb_enable_temp,ld_enable_temp;
wire [4:0] rs1, rs2, rd_temp;
wire [2:0] func_data;
wire [6:0] func_7;
wire [6:0] op_code;
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd_temp  = instruction[11:7];
assign op_code = instruction[6:0];
assign func_data = instruction[14:12];
assign func_7 = instruction[31:25];

wire fpu_en;
wire imm_selector_f;//will go to imm_selector which already has entire instruction field just waiting for this signal to become 1
wire [31:0] imm_data_f;


// Control Signals
wire  sw_en;
wire [31:0] lr;
wire read_reg_port1, read_reg_port2;
wire mux_selector, mux_selector_sec;
wire branch_en, jalr_en, jal_en;
wire  imm_selector;
wire [31:0] rs1data, rs2data, immdata;
wire [31:0] branch_rs1data, branch_rs2data, branch_immvalue, branch_pcvalue;
wire [31:0] jalr_rs1data, jalr_immvalue, jalr_pcvalue;

// Control Unit
ctrl_unit u_ctrl (
    .opcode(op_code),
    .func(func_data),
    .func_7(func_7),
    .read_regport1(read_reg_port1),
    .read_regport2(read_reg_port2),
    .imm_selector(imm_selector),
    .mux_selector(mux_selector),
    .mux_selector_sec(mux_selector_sec),
    .branch_en(branch_en),
    .jalr_en(jalr_en),
    .jal_en(jal_en),
    
    .sw_inst(sw_en),
    .mem_enable(mem_enable_temp),
    .mem_read(mem_read_temp),
    .mem_write(mem_write_temp),
    .wb_enable(wb_enable_temp),
    .ld_enable(ld_enable_temp),
    .fpu_en(fpu_en),
    .read_regport_f1(read_regport_f1_out),
    .read_regport_f2(read_regport_f2_out),
    .mem_enable_f(mem_enable_f_out),
    .mem_write_f(mem_write_f_out),
    .wb_enable_f(wb_enable_f_out),
    .imm_selector_f(imm_selector_f)
    
);

assign rs1_f=(fpu_en)?rs1:5'd0;
assign rs2_f=(fpu_en)?rs2:5'd0;
assign rd_temp_f=(fpu_en)?rd_temp:5'd0;
assign opcode_f=(fpu_en)?op_code:7'd0;
assign func_data_f=(fpu_en)?func_data:3'd0;
assign func_7_f=(fpu_en)?func_7:7'd0;


// Register File
reg_bank u_regfile (
    .clk(clk),
    .rst(rst),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd_in),
    .read_reg_port1(read_reg_port1),
    .read_reg_port2(read_reg_port2),
    .wb_data(wb_data),
    .wb_signal(reg_write_en),
    .rs1_data(rs1data),
    .rs2_data(rs2data)
);

// Immediate Generator
imm_gen u_imm_gen (
    .instruction(instruction),
    .imm_selector(imm_selector),
    .imm_data(immdata),
    .imm_data_f(imm_data_f)
    
);

// MUX for Selecting A (PC or rs1data)
mux_1c2 u_mux1(
    .a(rs1data),
    .b(pc),
    .sel(mux_selector),
    .out(mux_out_pcora)  
);

// MUX for Selecting B (rs2data or imm_value)
mux_1c2 u_mux2(
    .a(rs2data),
    .b(immdata),
    .sel(mux_selector_sec),
    .out(mux_out_borimm)
);

// Branch Unit
branch_unit u_branch (
    .branch_en(branch_en),
    .rs1_data_temp(rs1data),
    .rs2_data_temp(rs2data),
    .imm_value_temp(immdata),
    .pc_value_temp(pc),
    .rs1data(branch_rs1data),
    .rs2data(branch_rs2data),
    .immvalue(branch_immvalue),
    .pcvalue(branch_pcvalue)
);

// JALR Unit
jalr_unit u_jalr (
    .jalr_en(jalr_en),
    .jal_en(jal_en),
    .rs1_data_temp(rs1data),
    .rs2_data_temp(rs2data),
    .imm_value_temp(immdata),
    .pc_value_temp(pc),
    .rs1data(jalr_rs1data),
    .immvalue(jalr_immvalue),
    .pcvalue(jalr_pcvalue),
    .linkregister(lr)
);

// Sequential Block with Reset Handling
always @(posedge clk or posedge rst) begin
    if (rst) begin
        rs1_data <= 0;
        rs2_data <= 0;
        imm_value <= 0;
        pc_value <= 0;
        nextpc <= 0;
        instr_out <= 0;
        rd_register <= 0;
        linkreg <= 0;
        op_code_out <= 0;
        func_data_out <= 0;
        func_7_out <= 0;
        branch_enable_out <= 0;
        jal_en_out<=0;
        jalr_en_out <= 0;
        mem_enable_out<=0;
        mem_read_out<=0;
        mem_write_out<=0;
        wb_enable_out<=0;
        ld_enable_out<=0;
        rs1_fwd<=5'b0;
        rs2_fwd<=5'b0;
        imm_data_f_out<=32'd0;
    end 
    else begin
        op_code_out <= op_code;
        func_data_out <= func_data;
        func_7_out <= func_7;
        branch_enable_out <= branch_en;
        jal_en_out <= jal_en;
        jalr_en_out <= jalr_en;
        mem_enable_out<=mem_enable_temp;
        mem_read_out<=mem_read_temp;
        mem_write_out<=mem_write_temp;
        wb_enable_out<=wb_enable_temp;
        ld_enable_out<=ld_enable_temp;
        rs1_fwd<=rs1;
        rs2_fwd<=rs2;
        if (flush_out) begin
            rs1_data <= 0;
            rs2_data <= 0;
            imm_value <= 0;
            nextpc <= 0;
            instr_out <= 0;
            rd_register <= 0;
            pc_value <= 0;
            linkreg <= 0;
        end 
        else if (branch_en) begin
            rs1_data <= branch_rs1data;
            rs2_data <= branch_rs2data;
            imm_value <= branch_immvalue;
            nextpc <= branch_pcvalue;
        end 
        else if (jalr_en) begin
            nextpc <= jalr_pcvalue;
            linkreg <= lr;
            rd_register <= rd_temp;
        end 
        else if (jal_en) begin
            nextpc <= jalr_pcvalue;
            linkreg <= lr;
            rd_register <= 5'bx;
        end 
        else if (fpu_en) begin
//            instr_out <= instruction;
             if(flag_done)
              imm_data_f_out<=imm_data_f;
        end 
        else begin
            if (sw_en) begin
                rd_register <= 5'bx;
            end 
            else begin
                rd_register <= rd_temp;
            end
            rs1_data <= rs1data;
            rs2_data <= rs2data;
            imm_value <= immdata;
            pc_value <= pc;
        end
    end
end


endmodule 