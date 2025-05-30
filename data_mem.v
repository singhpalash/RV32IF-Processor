`timescale 1ns / 1ps

module data_mem(
    input wire clk,

    // I-class memory control
    input wire mem_enable,
    input wire mem_read,
    input wire mem_write,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output reg [31:0] mem_data_out,

    // F-class memory control
    input wire mem_enable_f_out_mem,
    input wire mem_write_f_out_mem,
    input wire [31:0] address_f,
    input wire [31:0] data_for_writing_sw,
    output reg [31:0] mem_data_out_f
);

    reg [31:0] memory [0:255];  // Example: 256-word memory
    integer i;

    // ----------------------
    // Asynchronous Read Block
    // ----------------------
     always @(*) begin
        // I-class read
        if (mem_enable && mem_read)
            mem_data_out = memory[address];
        else begin
            mem_data_out = 32'b0;

        // F-class read: only if enabled and not writing
        if (mem_enable_f_out_mem && !mem_write_f_out_mem)
            mem_data_out_f = memory[address_f];
        else
            mem_data_out_f = 32'b0;
        end
    end

    // ----------------------
    // Synchronous Write Block with Conflict Handling
    // ----------------------
    always @(posedge clk) begin
        // I-class write (has priority in case of conflict)
        if (mem_enable && mem_write && 
            !(mem_enable_f_out_mem && mem_write_f_out_mem && address == address_f)) begin
            memory[address] <= write_data;
        end

        // F-class write
        if (mem_enable_f_out_mem && mem_write_f_out_mem) begin
            if (address == address_f && mem_enable && mem_write) begin
                // Conflict detected: same address write by both ports
                // I-class (port A) has priority, so F-class (port B) is ignored
                // You may raise a warning or flag here if needed
            end else begin
                memory[address_f] <= data_for_writing_sw;
            end
        end
    end

endmodule
