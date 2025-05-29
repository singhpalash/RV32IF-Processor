`timescale 1ns / 1ps
module ctrl_unit(input wire [6:0] opcode,input wire [2:0] func,input wire [6:0] func_7,
                 output reg read_regport1,
                 output reg read_regport2,
                 output reg imm_selector,
                 output reg mux_selector,output reg mux_selector_sec,
                  output reg branch_en,output reg jalr_en,
                  output reg mem_enable,
                  output reg mem_read,
                  output reg mem_write,
                  output reg wb_enable,
                  output reg ld_enable,output reg jal_en,
                  output reg fpu_en,
                  output reg sw_inst,
                  output reg read_regport_f1,
                  output reg read_regport_f2,
                  output reg wb_enable_f,
                  output reg imm_selector_f,
                  output reg mem_enable_f,
                  output reg mem_write_f
                  );


always@(*) 
 begin
    read_regport_f1=0;
    read_regport_f2=0;
    imm_selector_f=0;
    mem_enable_f=0;
    mem_write_f=0;
    read_regport1 = 0;
    read_regport2 = 0;
    imm_selector = 0;
    mux_selector = 0;
    mux_selector_sec = 0;
    branch_en = 0;
    jal_en=0;
    jalr_en = 0;
    mem_enable = 0;
    mem_read = 0;
    mem_write = 0;
    wb_enable = 0;
    ld_enable=0;
    fpu_en=0;
    sw_inst=1'b0;
  case(opcode)
   7'b0110011: begin//for r-type
    branch_en=0;
    read_regport1=1'b1;//for selecting a
    read_regport2=1'b1;//for selecting b
    mux_selector=1'b1;//for selecting a between pc and a_value
    mux_selector_sec=1'b1;//for selecting b between b and imm_value
    mem_enable=1'b0;
    wb_enable=1'b1;
   end
   7'b0010011: begin//(for i-type)
    branch_en=0;
    read_regport1=1'b1;//for selecting a
    read_regport2=1'b0;
    imm_selector=1'b1;//for selecting imm value
    mux_selector=1'b1;//a should be selected
    mux_selector_sec=1'b0;//imm_value should be selected
    mem_enable=1'b0;
    wb_enable=1'b1;
   end
   7'b1100011: begin//for branch instructions
    read_regport1=1'b1;//for selecting rs1
    read_regport2=1'b1;//for selecting rs2
    imm_selector=1'b1;//for selecting imm-value
    branch_en=1'b1;
    mem_enable=1'b0;
    wb_enable=1'b0;
   end 
   7'b1101111: begin//for jal instruction we need only imm_value and pc_value
    branch_en=0;
    read_regport1=1'b0;
    read_regport2=1'b0;
    imm_selector=1'b1;
    mux_selector=1'b0;//for selecting pc_value
    mux_selector_sec=1'b0;//for selecting imm_value
    mem_enable=1'b0;
    wb_enable=1'b1;
    jal_en=1'b1;//for selecting the next address generator block for jal
   end
   7'b1100111: begin //for jalr instruction we also need rs1 register
     branch_en=0;
     read_regport1=1'b1;
     read_regport2=1'b0;
     imm_selector=1'b1;
     jalr_en=1;
     mem_enable=1'b0;
     wb_enable=1'b1;
   end
   7'b0110111,7'b0010111: begin//for lui and auipc
    branch_en=0;
    read_regport1=1'b0;
    read_regport2=1'b0;
    imm_selector=1'b1;
    mem_enable=1'b0;
    wb_enable=1'b1;
   end
   7'b0000011: begin //lw we need rs1 and imm_data
    branch_en=0;
    read_regport1=1'b1;
    read_regport2=1'b0;
    imm_selector=1'b1;
    mem_enable=1'b1;
    mem_read=1'b1;
    wb_enable=1'b1;
    ld_enable=1'b1;
   end
   7'b0100011: begin //sw we need rs1,rs2,imm_data
    branch_en=0;
    read_regport1=1'b1;
    read_regport2=1'b1;
    imm_selector=1'b1;
    mem_enable=1'b1;
    mem_write=1'b1;
    wb_enable=1'b0;
    sw_inst=1'b1;
   end
   7'b1010011: begin //for floating point arithmetic
    fpu_en=1'b1;
    read_regport_f1=1'b1;
    read_regport_f2=1'b1;
    imm_selector_f=1'b0;
    mem_enable_f=1'b0;
    mem_write_f=1'b0;
    wb_enable_f=1'b1;
   end
 
   
    
  endcase
 end

endmodule
