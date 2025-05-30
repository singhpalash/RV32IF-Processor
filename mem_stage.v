module mem_stage(
    input wire clk, input wire rst, input wire mem_enable,
//    input wire sw_en_out
    input wire wb_enable_mems, input wire [4:0] rd_mems,
    input wire ld_mems, input wire mem_read, input wire mem_write,
    input wire [31:0] write_data,//for storing data sw_instr
    input wire [31:0] alu_out,  // ALU output
    input wire mem_enable_f_out_ex,
    input wire mem_write_f_out_ex,//for knowing that a flw.s instruction has reached ex stage so stall memory access to i class sw instruction
    input wire mem_enable_f_out_mem,
    input wire mem_write_f_out_mem,
    input wire [31:0] address_f,
    input wire [31:0] data_for_writing_sw,
    output reg [31:0] mem_data, output reg [31:0] result_out,
    output reg wb_enable_wb, output reg [4:0] rd_wb, output reg ld_wb,
    output reg wb_enable_fwd,
    output reg [4:0] rd_wb_fwd,
    output reg [31:0] mem_data_out_f_wb,
    output wire mem_stall
    
);

wire [31:0] mem_data_out_f;
wire [31:0] address;
wire [31:0] mem_data_wire;  // Intermediate wire

    
assign address = (mem_enable) ? alu_out : 32'dx;

wire stall_sw_due_to_flw;
assign stall_sw_due_to_flw = mem_write && (!mem_write_f_out_ex && mem_enable_f_out_ex);
 
wire safe_mem_write;
assign safe_mem_write = mem_write && !stall_sw_due_to_flw;


assign mem_stall = stall_sw_due_to_flw;//going to ex stage to stall all results until this store word completes

// Step 2: Modify memory instantiation
data_mem dm(
    .clk(clk),
    .mem_enable(mem_enable), 
    .mem_read(mem_read), 
    .mem_write(safe_mem_write),  // ✅ safe version
    .write_data(write_data), 
    .address(address), 
    .mem_data_out(mem_data_wire),
    .mem_enable_f_out_mem(mem_enable_f_out_mem),
    .mem_write_f_out_mem(mem_write_f_out_mem),
    .address_f(address_f),
    .data_for_writing_sw(data_for_writing_sw),
    .mem_data_out_f(mem_data_out_f)
);

//data_mem dm(
//    .clk(clk),.mem_enable(mem_enable), 
//    .mem_read(mem_read), .mem_write(mem_write), 
//    .write_data(write_data), .address(address), 
//    .mem_data_out(mem_data_wire),
//    .mem_enable_f_out_mem(mem_enable_f_out_mem),
//    .mem_write_f_out_mem(mem_write_f_out_mem),
//    .address_f(address_f),
//    .data_for_writing_sw(data_for_writing_sw),
//    .mem_data_out_f(mem_data_out_f)
//);//if we read on posedge of clk inside data_mem then : at T1 the mem_read request
//comes to this stage at T2 it is passed to dm and mem_data_out becomes equal to mem
//data and at t3 this mem data is given to output mem_data i avoided this one cycle
//delay by making read combinational inside data memory and thus this t2 delay is avoided

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset all outputs to their default values
        mem_data     <= 32'd0;
        result_out   <= 32'd0;
        wb_enable_wb <= 1'b0;
        rd_wb        <= 5'd0;
        ld_wb        <= 1'b0;
        wb_enable_fwd<=1'b0;
        rd_wb_fwd<=5'b0;
        mem_data_out_f_wb<=32'd0;
    end 
    else begin
        if(mem_write && mem_write_f_out_ex) begin
        wb_enable_wb <= wb_enable_mems;
        rd_wb        <= rd_mems;
        ld_wb        <= ld_mems;
        mem_data <= mem_data_wire;
        wb_enable_fwd<=wb_enable_mems;
        rd_wb_fwd<=rd_mems;
        mem_data_out_f_wb<=mem_data_out_f;
        if(!mem_enable)
         result_out<=alu_out;

    end
end
end

endmodule