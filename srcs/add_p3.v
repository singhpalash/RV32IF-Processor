module add_p3(input clk,rst,
              input [23:0] sum_mant,
              input [7:0] exp_large_out,
              input sign_out_s3,
              output reg [7:0] exp_large_out_s4,//pass this exp_large_out as it is to stage 4
              output reg [7:0] leading_zero_ctr,
              output reg [23:0] left_shifted_mant,
              output reg sign_out_s4 );


integer i;
reg [7:0] ctr;

always@(*) begin
 
 casex (sum_mant)
            24'b1xxxxxxxxxxxxxxxxxxxxxxx: ctr = 0;
            24'b01xxxxxxxxxxxxxxxxxxxxxx: ctr = 1;
            24'b001xxxxxxxxxxxxxxxxxxxxx: ctr = 2;
            24'b0001xxxxxxxxxxxxxxxxxxxx: ctr = 3;
            24'b00001xxxxxxxxxxxxxxxxxxx: ctr = 4;
            24'b000001xxxxxxxxxxxxxxxxxx: ctr = 5;
            24'b0000001xxxxxxxxxxxxxxxxx: ctr = 6;
            24'b00000001xxxxxxxxxxxxxxxx: ctr = 7;
            24'b000000001xxxxxxxxxxxxxxx: ctr = 8;
            24'b0000000001xxxxxxxxxxxxxx: ctr = 9;
            24'b00000000001xxxxxxxxxxxxx: ctr = 10;
            24'b000000000001xxxxxxxxxxxx: ctr = 11;
            24'b0000000000001xxxxxxxxxxx: ctr = 12;
            24'b00000000000001xxxxxxxxxx: ctr = 13;
            24'b000000000000001xxxxxxxxx: ctr = 14;
            24'b0000000000000001xxxxxxxx: ctr = 15;
            24'b00000000000000001xxxxxxx: ctr = 16;
            24'b000000000000000001xxxxxx: ctr = 17;
            24'b0000000000000000001xxxxx: ctr = 18;
            24'b00000000000000000001xxxx: ctr = 19;
            24'b000000000000000000001xxx: ctr = 20;
            24'b0000000000000000000001xx: ctr = 21;
            24'b00000000000000000000001x: ctr = 22;
            24'b000000000000000000000001: ctr = 23;
            
            default: ctr <= 24; // Fallback (all zeros)
        endcase

end
always@(posedge clk or posedge rst) begin
 if(rst) begin
 
  exp_large_out_s4<=8'd0;
  leading_zero_ctr<=7'd0;
  left_shifted_mant<=24'd0;
  sign_out_s4<=1'b0;


end

else begin
 sign_out_s4<=sign_out_s3;
 
 
 left_shifted_mant<=sum_mant<<ctr;
 leading_zero_ctr<=ctr;
 exp_large_out_s4<=exp_large_out;
 



end

end


          
endmodule