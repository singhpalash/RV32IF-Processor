module fpu_mem_stage(input clk,rst,
                     input wire [31:0] data_for_writing_to_mem,
                     input wire [31:0] result_f,
                     input wire [4:0] rd_temp_f_out_mem,
                     input wire mem_enable_f_out_mem, //coming from decoder stage of id
                     input wire mem_write_f_out_mem,
                     input wire wb_enable_f_out_mem,
                     output reg [4:0] rd_temp_f_out_wb,
                     output reg wb_enable_f_out_wb,
                     output reg [31:0] result_f_wb,
                     output wire [31:0] address,
                     output wire [31:0] data_for_writing_sw,
                     output reg lw_en );

assign address =(mem_enable_f_out_mem)?result_f:32'd0;
assign data_for_writing_sw=(mem_enable_f_out_mem && mem_write_f_out_mem)?data_for_writing_to_mem:32'd0;

always@(posedge clk or posedge rst) begin
 if(rst) begin
  rd_temp_f_out_wb<=5'd0;
  wb_enable_f_out_wb<=1'b0;
  result_f_wb<=32'd0;
  lw_en<=1'b0;
 end
 
 else begin
  if(!mem_enable_f_out_mem) begin
   wb_enable_f_out_wb<=wb_enable_f_out_mem;
   rd_temp_f_out_wb<=rd_temp_f_out_mem;
   result_f_wb<=result_f;
  
  end
  else if(mem_enable_f_out_mem && !mem_write_f_out_mem) begin
   wb_enable_f_out_wb<=wb_enable_f_out_mem;
   rd_temp_f_out_wb<=rd_temp_f_out_mem;
   result_f_wb<=32'd0;
   lw_en<=1'b1;
  end
  else begin
   wb_enable_f_out_wb<=wb_enable_f_out_mem;
   rd_temp_f_out_wb<=5'd0;
   result_f_wb<=32'd0;
  end
 
 
 end


end                    
                     
                     
                     
                     
endmodule
