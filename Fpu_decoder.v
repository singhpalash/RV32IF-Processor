module fpu_decoder(
    input wire clk,
    input wire rst,
    input wire read_regport_f1,
    input wire read_regport_f2,
    input wire mem_enable_f_out, //the three signals starting from here connected to output as it is
    input wire mem_write_f_out,
    input wire wb_enable_f_out,
    input wire [4:0] rs1_f,
    input wire [4:0] rs2_f,
    input wire [4:0] rd_temp_f, //this will be connected to output stage as it is
    input wire [4:0] rd_temp_f_wb, //coming from wb_stage
    input wire reg_write_f_en, //coming from wb_stage so that you could write to reg_bank
    input wire [31:0] wb_data_f, //coming from wb_stage
    input wire [6:0] opcode_f, //the three inputs starting from here connected to output as it is
    input wire [2:0] func_data_f,
    input wire [6:0] func_7_f,
    input wire flag_done, //this is coming from EX stage.for the instructions like multiply and divide
                          //which take very high cycles all other instructions should be paused
    output reg mem_enable_f_out_ex, //coming from ctrl_unit of id
    output reg mem_write_f_out_ex,
    output reg wb_enable_f_out_ex,
    output reg [4:0] rs1_f_out,
    output reg [4:0] rs2_f_out,
    output reg [4:0] rd_temp_f_out,
    output reg [6:0] opcode_f_out,
    output reg [2:0] func_data_f_out,
    output reg [6:0] func_7_f_out,
    output reg [31:0] rs1_data_f_out,
    output reg [31:0] rs2_data_f_out
);

    wire [31:0] rs1_data_f;
    wire [31:0] rs2_data_f;

    reg_bank_f rbf (
        .clk(clk),
        .rst(rst),
        .rs1_f(rs1_f),
        .rs2_f(rs2_f),
        .rd_temp_f_wb(rd_temp_f_wb),
        .read_regport_f1(read_regport_f1),
        .read_regport_f2(read_regport_f2),
        .wb_data_f(wb_data_f),
        .wb_enable_f(reg_write_f_en),
        .rs1_data_f(rs1_data_f),
        .rs2_data_f(rs2_data_f)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all output registers
            mem_enable_f_out_ex <= 1'b0;
            mem_write_f_out_ex <= 1'b0;
            wb_enable_f_out_ex <= 1'b0;
            rs1_f_out <= 5'd0;
            rs2_f_out <= 5'd0;
            rd_temp_f_out <= 5'd0;
            opcode_f_out <= 7'd0;
            func_data_f_out <= 3'd0;
            func_7_f_out <= 7'd0;
            rs1_data_f_out <= 32'd0;
            rs2_data_f_out <= 32'd0;
        end 
        else begin
            if (flag_done) begin
                // Pass-through all values if the long-latency operation is done
                mem_enable_f_out_ex <= mem_enable_f_out;
                mem_write_f_out_ex <= mem_write_f_out;
                wb_enable_f_out_ex <= wb_enable_f_out;
                rs1_f_out <= rs1_f;
                rs2_f_out <= rs2_f;
                rd_temp_f_out <= rd_temp_f;
                opcode_f_out <= opcode_f;
                func_data_f_out <= func_data_f;
                func_7_f_out <= func_7_f;
                rs1_data_f_out <= rs1_data_f;
                rs2_data_f_out <= rs2_data_f;
            end // else hold the current values (stall condition)
        end
    end

endmodule
