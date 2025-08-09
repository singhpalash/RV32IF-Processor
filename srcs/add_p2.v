module add_p2(input clk,rst,
              input [23:0] mant_out_a,mant_out_b,
              input [7:0] exp_large,
              input sign_out,
              output reg [23:0] sum_mant,
              output reg [7:0] exp_large_out,
              output reg sign_out_s3);
              
 
 
always@(posedge clk or posedge rst) begin
  if(rst) begin
   sum_mant<=24'd0;
   exp_large_out<=8'd0;
   sign_out_s3<=1'b0;
  end
  
  else begin
   sum_mant<=mant_out_a+mant_out_b;
   exp_large_out<=exp_large;
   sign_out_s3<=sign_out;
  
  end
 
 
 
end    




endmodule          
    