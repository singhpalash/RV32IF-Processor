module add_p5( input clk,rst,
               input [7:0] exp_final,
               input [22:0] mant_final,
               input sign_out_final,
               output reg [31:0] result);



always@(posedge clk or posedge rst) begin
 if(rst) begin
  result<=32'd0;
 
 end
 else begin
  result<={sign_out_final,exp_final,mant_final};
 
 end
 



end               
               
               
endmodule