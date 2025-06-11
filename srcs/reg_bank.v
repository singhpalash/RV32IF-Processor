`timescale 1ns / 1ps
module reg_bank(input wire clk,input wire rst,
            input wire [4:0] rs1,input wire [4:0] rs2,
            input wire [4:0] rd,
             input wire read_reg_port1,input wire read_reg_port2,
             input wire [31:0] wb_data,input wire wb_signal,
             output wire [31:0] rs1_data,output wire [31:0] rs2_data );

integer i;
reg [31:0] registers [31:0];
assign rs1_data=(read_reg_port1==0)?32'd0:registers[rs1];
assign rs2_data=(read_reg_port2==0)?32'd0:registers[rs2];

always@(posedge clk or posedge rst) begin
 if(rst) begin
    for(i=0;i<31;i=i+1) begin
     registers[i]=i;
    end
 end
 else begin
   if(wb_signal & rd!=5'b00000) begin
    registers[rd]=wb_data;
   end
  end
 end
 endmodule
