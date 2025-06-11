`timescale 1ns / 1ps
module imm_gen(
    input wire imm_selector,imm_selector_f,        
    input wire [31:0] instruction,  
    output wire [31:0] imm_data,
    output wire [31:0] imm_data_f     
);

// Extract instruction fields
wire [6:0] op_code = instruction[6:0];
wire [2:0] func = instruction[14:12];
wire [6:0] func_7 = instruction[31:25];

reg [31:0] imm_data_inter;

always @(*) begin
    case(op_code)
        7'b1100011: begin // B-Type (Branches)
            imm_data_inter <= {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        end
        7'b1101111: begin // J-Type (JAL)
            imm_data_inter <= {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
        end
        7'b1100111, // JALR 
        7'b0010011, // I-Type Instructions
        7'b0000011: begin // Load Instructions (e.g., LW)
            imm_data_inter <= {{20{instruction[31]}}, instruction[31:20]};
        end
        7'b0100011: begin // S-Type (Store Instructions, e.g., SW)
            imm_data_inter <= {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
        end
        7'b0010111: begin // AUIPC (Upper Immediate with PC)
            imm_data_inter <= {instruction[31:12], 12'b0}; // Shift by 12
        end
        7'b0110111: begin // LUI (Load Upper Immediate)
            imm_data_inter <= {instruction[31:12], 12'b0}; // Shift by 12
        end
        default: begin
            imm_data_inter <= 32'd0; // Default case to avoid latches
        end
    endcase
end

// Output immediate value based on imm_selector
assign imm_data = (imm_selector == 1'b1) ? imm_data_inter : 32'd0;
assign imm_data_f=(imm_selector_f==1'b1)?imm_data_inter:32'd0;
endmodule
