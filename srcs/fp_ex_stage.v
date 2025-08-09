module fp_ex_stage (
    input  wire        clk, rst,
    input  wire [31:0] a_in,
    input  wire [31:0] b_in,
    input wire [31:0] fwd_a,
    input wire [31:0] fwd_b,
    input wire [1:0] fwd_a_sel,
    input wire [1:0] fwd_b_sel,
    input  wire [6:0]  op_code_f,
    input  wire [2:0]  func_f,
    input  wire [6:0]  func_7_f,
    input  wire        mem_enable_f_out_ex, // from ctrl_unit
    input  wire        mem_write_f_out_ex,
    input  wire        wb_enable_f_out_ex,
    input  wire [4:0]  rd_temp_f_out,
    output reg  [4:0]  rd_temp_f_out_mem,
    output reg         mem_enable_f_out_mem,
    output reg         mem_write_f_out_mem,
    output reg         wb_enable_f_out_mem,
    output reg  [31:0] result_f,
    output reg  [31:0] data_for_writing_to_mem,
    output reg         flag_done
);

wire [31:0] add_result;
wire [31:0] mult_result;
wire [31:0] divider_result;
wire sub;
wire [31:0] a_f;
wire [31:0] b_f;

assign a_f=(fwd_a_sel)?(fwd_a):a_in;
assign b_f=(fwd_b_sel)?(fwd_b):b_in;


assign sub = (op_code_f == 7'b1010011 && func_7_f == 7'b0000100);

// FPU Units
div_top fpdo (
    .clk(clk), .rst(rst),
    .a(a_f), .b(b_f),
    .result(divider_result)
);

mul_top fpmo (
    .clk(clk), .rst(rst),
    .a(a_f), .b(b_f),
    .result(mult_result)
);

add_top fpaso (
    .clk(clk), .rst(rst),
    .a(a_f), .b(b_f),
    .sub(sub),
    .result(add_result)
);

// -------------------
// Pipeline registers for control signals
// -------------------
reg mem_en_s1, mem_en_s2, mem_en_s3, mem_en_s4, mem_en_s5;
reg mem_wr_s1, mem_wr_s2, mem_wr_s3, mem_wr_s4, mem_wr_s5;
reg wb_en_s1,  wb_en_s2,  wb_en_s3,  wb_en_s4,  wb_en_s5;
reg [4:0] rd_s1, rd_s2, rd_s3, rd_s4, rd_s5;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        {mem_en_s1, mem_en_s2, mem_en_s3, mem_en_s4, mem_en_s5} <= 0;
        {mem_wr_s1, mem_wr_s2, mem_wr_s3, mem_wr_s4, mem_wr_s5} <= 0;
        {wb_en_s1,  wb_en_s2,  wb_en_s3,  wb_en_s4,  wb_en_s5}  <= 0;
        {rd_s1, rd_s2, rd_s3, rd_s4, rd_s5} <= 0;

        mem_enable_f_out_mem <= 0;
        mem_write_f_out_mem  <= 0;
        wb_enable_f_out_mem  <= 0;
        rd_temp_f_out_mem    <= 0;
        result_f             <= 0;
        data_for_writing_to_mem <= 0;
        flag_done            <= 0;
    end
    else begin
        case (op_code_f)
            7'b1010011: begin
                case (func_7_f)
                    // ADD / SUB - 5-cycle pipelined control
                    7'b0000000,  // ADD
                    7'b0000100:  // SUB
                    begin
                        result_f <= add_result;

                        mem_en_s1 <= mem_enable_f_out_ex;
                        mem_en_s2 <= mem_en_s1;
                        mem_en_s3 <= mem_en_s2;
                        mem_en_s4 <= mem_en_s3;
                        //mem_en_s5 <= mem_en_s4;
                        mem_enable_f_out_mem <= mem_en_s4;

                        mem_wr_s1 <= mem_write_f_out_ex;
                        mem_wr_s2 <= mem_wr_s1;
                        mem_wr_s3 <= mem_wr_s2;
                        mem_wr_s4 <= mem_wr_s3;
                        //mem_wr_s5 <= mem_wr_s4;
                        mem_write_f_out_mem <= mem_wr_s4;

                        wb_en_s1 <= wb_enable_f_out_ex;
                        wb_en_s2 <= wb_en_s1;
                        wb_en_s3 <= wb_en_s2;
                        wb_en_s4 <= wb_en_s3;
                        //wb_en_s5 <= wb_en_s4;
                        wb_enable_f_out_mem <= wb_en_s4;

                        rd_s1 <= rd_temp_f_out;
                        rd_s2 <= rd_s1;
                        rd_s3 <= rd_s2;
                        rd_s4 <= rd_s3;
                        //rd_s5 <= rd_s4;
                        rd_temp_f_out_mem <= rd_s4;
                        flag_done<=1'b1;
                    end

                    // MULTIPLY - 5-cycle pipelined control
                    7'b0001000: begin
                        result_f <= mult_result;

                        mem_en_s1 <= mem_enable_f_out_ex;
                        mem_en_s2 <= mem_en_s1;
                        mem_en_s3 <= mem_en_s2;
                        mem_en_s4 <= mem_en_s3;
//                        mem_en_s5 <= mem_en_s4;
                        mem_enable_f_out_mem <= mem_en_s4;

                        mem_wr_s1 <= mem_write_f_out_ex;
                        mem_wr_s2 <= mem_wr_s1;
                        mem_wr_s3 <= mem_wr_s2;
                        mem_wr_s4 <= mem_wr_s3;
                        
                        mem_write_f_out_mem <= mem_wr_s4;

                        wb_en_s1 <= wb_enable_f_out_ex;
                        wb_en_s2 <= wb_en_s1;
                        wb_en_s3 <= wb_en_s2;
                        wb_en_s4 <= wb_en_s3;
                        //wb_en_s5 <= wb_en_s4;
                        wb_enable_f_out_mem <= wb_en_s4;

                        rd_s1 <= rd_temp_f_out;
                        rd_s2 <= rd_s1;
                        rd_s3 <= rd_s2;
                        rd_s4 <= rd_s3;
                        //rd_s5 <= rd_s4;
                        rd_temp_f_out_mem <= rd_s4;
                        flag_done<=1'b1;
                    end

                    // DIVIDE - keep as is (no extra 5-cycle pipelining here)
                    7'b0001100: begin
                        
                            result_f <= divider_result;

                             mem_en_s1 <= mem_enable_f_out_ex;
                             mem_en_s2 <= mem_en_s1;
                             mem_en_s3 <= mem_en_s2;
                             mem_en_s4 <= mem_en_s3;
                             mem_enable_f_out_mem <= mem_en_s4;

                             mem_wr_s1 <= mem_write_f_out_ex;
                             mem_wr_s2 <= mem_wr_s1;
                             mem_wr_s3 <= mem_wr_s2;
                             mem_wr_s4 <= mem_wr_s3;
                             mem_write_f_out_mem <= mem_wr_s4;

                             wb_en_s1 <= wb_enable_f_out_ex;
                             wb_en_s2 <= wb_en_s1;
                             wb_en_s3 <= wb_en_s2;
                             wb_en_s4 <= wb_en_s3;
                             wb_enable_f_out_mem <= wb_en_s4;

                             rd_s1 <= rd_temp_f_out;
                             rd_s2 <= rd_s1;
                             rd_s3 <= rd_s2;
                             rd_s4 <= rd_s3;
                             rd_temp_f_out_mem <= rd_s4;
                             flag_done<=1'b1;
                           
                    end
                endcase
            end
        endcase
    end
end

always @* begin
    
    case (op_code_f)
        7'b1010011: begin
            case (func_7_f)
                7'b0000000: result_f = add_result;     // ADD
                7'b0000100: result_f = add_result;     // SUB
                7'b0001000: result_f = mult_result;    // MUL
                7'b0001100: result_f = divider_result; // DIV
            endcase
        end
    endcase
end

endmodule
