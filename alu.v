`timescale 1ns / 1ps
//fix the issue of rd_mem still showing high impedance
module alu( 
    input wire [31:0] a,         // First operand (register)
    input wire [31:0] b,         // Second operand (register)
    input wire [4:0] rd,//output of id stage is reg and this is wire so
    //assign this equal to that reg of id stage output in top module and same for
    //every other input here
    input wire [31:0] linkreg,//coming here in case of jal or jalr
    input wire ld, //tell write back stage that it is load instruction 
    input wire mem_enable,
    input wire mem_read,
    input wire mem_write,
    input wire wb_enable,
    input wire [31:0] imm_value, 
    input wire [6:0] op_code,    
    input wire [31:0] pc,       
    input wire [2:0] func,       // Function for getting type of operation
    input wire [6:0] funct7,     // Additional function field for R-type
    output reg [31:0] result,    // ALU result
    output reg flag,             // Carry flag
    output reg jump_taken,       // Jump decision
    output reg branch_taken,     // Branch decision
    output reg [31:0] branch_addr,
    output reg [31:0] jump_address,  // Target jump address
    output reg [31:0] link_register,  // Stores return address for JAL, JALR
    output reg [31:0] data_for_writing_for_sw,//for sw we need to pass b value
    output reg mem_enable_mem,
    output reg mem_read_mem,
    output reg mem_write_mem,
    output reg wb_enable_mem,
    output reg  [4:0] rd_mem,
    output reg ld_mem,flush
);

    reg cout; // Carry-out flag
    
   
    always @(*) begin
    
        result = 32'b0;
        flag = 1'b0;
        jump_taken = 1'b0;
        branch_taken = 1'b0;
        jump_address = 32'b0;
        link_register = 32'b0;
        mem_enable_mem = mem_enable;
        mem_read_mem = mem_read;
        mem_write_mem = mem_write;
        wb_enable_mem = wb_enable;
        rd_mem=rd;
        ld_mem=ld;
        flush<=1'b0;
    
       case(op_code) 
        7'b0110011: begin // R-type instruction
         case(func)
          3'b000: begin
           if (funct7 == 7'b0000000) begin
             {cout, result} = a + b; // ADD if func7 sU\upports it 
           end 
           else if (funct7 == 7'b0100000) begin
             result = a +((~b)+1); // SUB
           end
           flag = cout;
           
          end
        
        3'b001: result = a << b[4:0]; // SLL
        3'b010: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // SLT
        3'b011: result = ($unsigned(a) < $unsigned(b)) ? 32'b1 : 32'b0; // SLTU
        3'b100: result = a ^ b; 
        3'b101: begin
          if (funct7 == 7'b0000000) begin
            result = a >> b[4:0]; // SRL if func7 supports it
          end 
          else if (funct7 == 7'b0100000) begin
            result = $signed(a) >>> b[4:0]; // SRA
          end
        end
        3'b110: result = a | b; 
        3'b111: result = a & b; 
       endcase
      end

     7'b0010011: begin // I-type instruction
       case(func) 
        3'b000: result = a + imm_value; // ADDI
        3'b010: result = ($signed(a) < $signed(imm_value)) ? 32'b1 : 32'b0; // SLTI
        3'b011: result = ($unsigned(a) < $unsigned(imm_value)) ? 32'b1 : 32'b0; // SLTIU
        3'b100: result = a ^ imm_value; 
        3'b110: result = a | imm_value; 
        3'b111: result = a & imm_value; 
        3'b001: result = a << imm_value[4:0]; // SLLI
        3'b101: begin
          if (funct7 == 7'b0000000) begin
            result = a >> imm_value[4:0]; // SRLI
          end 
          else if (funct7 == 7'b0100000) begin
            result = $signed(a) >>> imm_value[4:0]; // SRAI
          end
        end
      endcase
     end

    7'b1101111: begin // JAL
       result= linkreg;
    end
    7'b1100111: begin // JALR
      result = linkreg;
    end
    7'b0000011: begin//lw
     result= a + imm_value;
     
    end
    7'b0100011: begin//sw
     result=a+imm_value;
     data_for_writing_for_sw=b;
     
    end
    
    7'b0110111: begin//lui
     result=imm_value;
     end
    7'b0010111: begin //auipc
     result=pc+(imm_value);//in auipc the imm_value to be added is placed in bits 31:12 and 12:0 is kept 0 even if it had previously some values and we have already taken care of that in imm_gen module
    end
    
     
    
    7'b1100011: begin // Branch Instructions
     
     case(func)
      3'b000: branch_taken = (a == b); // BEQ
      3'b001: branch_taken = (a != b); // BNE
      3'b100: branch_taken = ($signed(a) < $signed(b)); // BLT
      3'b101: branch_taken = ($signed(a) >= $signed(b)); // BGE
      3'b110: branch_taken = ($unsigned(a) < $unsigned(b)); // BLTU
      3'b111: branch_taken = ($unsigned(a) >= $unsigned(b)); // BGEU
     endcase
     if(!branch_taken) begin
       flush<=1'b1;
    end
    else begin
       flush<=1'b0;
    end
    end
   endcase
   
  end
endmodule

 