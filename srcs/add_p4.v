module add_p4(input clk,rst,
             input [7:0] exp_large_out_s4,
             input [7:0] leading_zero_ctr,
             input [23:0] left_shifted_mant,
             input sign_out_s4,
             output reg [7:0] exp_final,
             output reg [22:0] mant_final,
             output reg sign_out_final);


always@(posedge clk or posedge rst) begin
 if(rst) begin
  exp_final<=8'd0;
  mant_final <=24'd0;
  sign_out_final<=1'b0;
 end
 
 else begin
  exp_final<=exp_large_out_s4 + (~(leading_zero_ctr) + 1 );
  mant_final<=left_shifted_mant[22:0];
  sign_out_final<=sign_out_s4;
 end


end             
             
             
             
             
             
endmodule