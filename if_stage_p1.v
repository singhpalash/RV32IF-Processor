




module if_stage_p1(
    input wire clk,
    input wire rst,
    // Next PC from PC+4 logic
    input wire flush_out,
    input wire [31:0] nagout, // Next address generator output
    input wire branch_enable,jal_en,jalr_en, // Coming from ALU
    output reg [31:0] pc_out,
    output reg [31:0] instr_out
);

wire [31:0] pc_temp;
wire [31:0] pc_next;//for passing to pcincr block
wire [31:0] instr_temp;
wire [31:0] npc;
wire nag_select;
assign nag_select=(branch_enable || jal_en || jalr_en)?1'b1:1'b0;

pc_incr_block a1(.b(pc_next),.inc_pc(npc));
mux_1c2 uut(.a(nagout), .b(npc), .sel(nag_select), .out(pc_temp));

instr_mem uut1(.pc(pc_temp), .instr(instr_temp)); // Use pc_out instead of pc_temp

always @(posedge clk or posedge rst) begin
  if (rst) begin
    pc_out <= 32'd0;
    instr_out <= 32'd0;
  end 
  else if (flush_out) begin
   pc_out<=32'd0;
   instr_out<=32'd0;
  end
  else begin
    pc_out <= pc_temp;
    instr_out <= instr_temp;
  end
end
assign pc_next=pc_out;
endmodule
