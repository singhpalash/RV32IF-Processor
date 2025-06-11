`timescale 1ns / 1ps
module jalr_unit( input wire jalr_en,input wire jal_en,
                  input wire [31:0] rs1_data_temp,
                  input wire [31:0] rs2_data_temp,
                  input wire [31:0] imm_value_temp,input wire [31:0] pc_value_temp,
                  output reg [31:0] rs1data,output reg [31:0] rs2data,
                  output reg [31:0] immvalue,output reg [31:0] pcvalue,
                  output reg [31:0] linkregister );
 //note that improvement could be made here for better branch prediction by making
//assumptions that branch is taken and giving the pc+imm_value to pc from this module 
// itself(for later) 
 
always@(*) begin
  if( jalr_en ) begin
   rs1data=rs1_data_temp;
   rs2data=rs2_data_temp;
   immvalue=imm_value_temp;
   pcvalue=(rs1_data_temp+imm_value_temp) & ~1;//this enables jalr to compute address at runtime rather than jumping using the value of pc like in jal
   linkregister=pcvalue + 4;
  end
  else if(jal_en) begin
   immvalue=imm_value_temp;
   pcvalue=pc_value_temp+ imm_value_temp;
   linkregister=pcvalue + 4;
  end
end
endmodule
