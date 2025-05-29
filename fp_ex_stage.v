module fp_ex_stage(input wire clk,rst,
                   input wire [31:0] a_f,
                   input wire [31:0] b_f,
                   input wire [6:0] op_code_f,
                   input wire [2:0] func_f,
                   input wire [6:0] func_7_f,
                   input wire mem_enable_f_out_ex, //coming from ctrl_unit of id
                   input wire mem_write_f_out_ex,
                   input wire wb_enable_f_out_ex,
                   input wire [4:0] rd_temp_f_out,
                   output reg [4:0] rd_temp_f_out_mem,
                   output reg mem_enable_f_out_mem, //coming from ctrl_unit of id
                   output reg mem_write_f_out_mem,
                   output reg wb_enable_f_out_mem,
                   output reg [31:0] result_f,
                   output reg [31:0] data_for_writing_to_mem,
                   output reg flag_done);

wire [31:0]add_result;
wire [31:0] mult_result;
wire [31:0] divider_result;
wire sub;
assign sub=(op_code_f==7'b1010011 && func_7_f== 7'b0000100)?1'b1:1'b0;

fp_divider_optimized fpdo(.clk(clk),.rst_n(rst),
                          .a(a_f),
                          .b(b_f),
                          .result(divider_result));

fp_multiplier fpmo(.clk(clk),.reset(rst),
                   .a(a_f),
                   .b(b_f),
                   .result(mult_result));
                  
 fp_add_sub fpaso(.clk(clk),.reset(rst),
                   .a(a_f),
                   .b(b_f),
                   .sub(sub),
                   .result(add_result));


always@(posedge clk or posedge rst) begin
 if(rst) begin
  result_f<=32'd0;
  data_for_writing_to_mem<=32'd0;
  flag_done<=1'b0;
  mem_enable_f_out_mem<=1'b0;
  mem_write_f_out_mem<=1'b0;
  wb_enable_f_out_mem<=1'b0;
  rd_temp_f_out_mem<=5'd0;
 end
 else begin
  mem_enable_f_out_mem<=mem_enable_f_out_ex;
  mem_write_f_out_mem<=mem_write_f_out_ex;
  wb_enable_f_out_mem<=wb_enable_f_out_ex;
  rd_temp_f_out_mem<=rd_temp_f_out;
  case(op_code_f)
   7'b1010011: begin
    case(func_7_f) 
     7'b0000000: begin
      result_f <= add_result ;   
     end
     7'b0000100: begin
      result_f <=add_result;
     end
     7'b0001000: begin
      result_f<=mult_result;
     end  
     7'b0001100: begin
      result_f<=divider_result;
     end
    
    endcase
   
   end
   
  
  endcase
 
 end


end
     
         
                   
                   
                   
endmodule