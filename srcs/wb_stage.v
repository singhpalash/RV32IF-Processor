`timescale 1ns / 1ps
module wb_stage(input wire clk,input wire rst,input wire wb_enable,
                input wire [4:0] rd,input wire [31:0] wb_data,
                  input wire[31:0] mem_data,input wire ld_instr,
                   output wire [4:0] rd_out,
                   output wire [31:0] wb_data_out,
                   output wire reg_write_enable
                   );
 reg [31:0] wb_data_temp;
 reg [4:0] rd_temp;
 reg reg_write_enable_temp;
always@(posedge clk or posedge rst) begin
  if(rst) begin 
    wb_data_temp=32'd0;
    rd_temp=5'b0;
    reg_write_enable_temp=1'b0;
  end
  else begin
   if (wb_enable) begin
    case(ld_instr) 
     1'b0: begin
      rd_temp=rd;
      wb_data_temp=wb_data;
      reg_write_enable_temp=1'b1;
     end
     1'b1: begin
      rd_temp=rd;
      wb_data_temp=mem_data;
      reg_write_enable_temp=1'b1;
     end
    endcase
    end
   else begin
    reg_write_enable_temp = 1'b0;
   end
 end
end
assign wb_data_out=wb_data_temp;
assign rd_out=rd_temp;
assign reg_write_enable=reg_write_enable_temp;
endmodule
