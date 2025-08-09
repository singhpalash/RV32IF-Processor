`timescale 1ns / 1ps

module tb_testing_core_top;

    
    reg clk;
    reg rst;
    

    
    testing_core_top uut (
        .clk(clk),
        .rst(rst)
    );
    
    
    always #5 clk = ~clk;  

   
    initial begin
        
        clk = 0;
        rst = 1;

        
        #10 rst = 0;
        
        $display("Reset Deasserted");

        
        $monitor("Time=%0t | PC=%h | Instr=%h | Branch_Enable=%b jal_en=%b jalr_en %0b op_code_out %0d rs1_data %0d rs2_data %0d imm_value %0d mem_enable_out %0b mem_read_out %0b wb_enable_out %0b result %0d flush_out %0b result_out_mem %0d wb_enable_wb %0b ld_wb %0b mem_data_out %0d mem_data inside %0d sw_en %0b mem_write signal %0b mem_write_out %0b linkreg %0d ex_link_register %0b | fwd_a %0b | fwd_b %0b rs1_fwd %0d rs2_fwd %0d rd_fwd %0d rd_wb_fwd %0d rd_mem %0d alu_b %0d wb_rd_out=%0d wb_data_out=%0d wb_reg_write_enable=%0b floating_wb_data:%0d  result_f:%0d", 
                 $time, uut.pc_out, uut.instr_out, uut.branch_enable,uut.jal_en,
                  uut.jalr_en,uut.op_code_out,uut.rs1_data,uut.rs2_data,uut.imm_value,
                  uut.mem_enable_out,uut.mem_read_out,uut.wb_enable_out,uut.ex_result,
                  uut.flush_out,uut.result_out_mem,uut.wb_enable_wb,uut.ld_wb,
                  uut.mem_data_out,uut.mem_stage.dm.memory[6],uut.id_stage.sw_en,
                  uut.ex_mem_write_mem,uut.mem_write_out,uut.linkreg,uut.ex_link_register,uut.forward_a,uut.forward_b,
                  uut.rs1_fwd,uut.rs2_fwd,uut.rd_fwd,uut.rd_wb_fwd,uut.ex_rd_mem,
                  uut.ex_stage.alu_b,uut.rd_out, uut.wb_data_out, uut.reg_write_enable,uut.wb_data_f,uut.result_f);

        
        
        #1000;


        $finish;
    end

endmodule
