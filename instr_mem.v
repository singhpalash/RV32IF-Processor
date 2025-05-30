`timescale 1ns / 1ps


 module instr_memory (
    input wire [31:0] pc,         
    output reg [31:0] instruction 
);
    
    reg [31:0] imem [0:255]; 

    //store the data coming from instructions.hex into imem register
    initial begin
        $readmemh("instructions.hex", imem);
    end
    

    always @(*) begin
        instruction = imem[pc >> 2]; // say i want to fetch from mem add 4 so the pc will give input as 4 but it should be
                                      // fetching from add 1 so it will be done by pc>>2
    end

endmodule
 
 
