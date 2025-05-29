`timescale 1ns / 1ps
module branch_unit( input wire branch_en,input wire [31:0]  rs1_data_temp,
                   input wire  [31:0]  rs2_data_temp,
                   input wire [31:0] imm_value_temp,
                   input wire [31:0] pc_value_temp,output reg [31:0] rs1data,
                   output reg [31:0]rs2data,
                   output reg [31:0] immvalue,
                   output reg [31:0] pcvalue);
//note that improvement could be made here for better branch prediction by making
//assumptions that branch is taken and giving the pc+imm_value to pc from this module 
// itself(for later) 
 
 always@(*) begin
  if( branch_en ) begin
   rs1data<=rs1_data_temp;
   rs2data<=rs2_data_temp;
   immvalue<=imm_value_temp;
   pcvalue<=pc_value_temp + (imm_value_temp<<2);
  end
 end
endmodule
