`timescale 1ns / 1ps
module add_p1( input clk,rst,sub,
                input [31:0] a,b,
                output reg [23:0] mant_out_a,mant_out_b,
                output reg [7:0] exp_large,
                output reg sign_out
    );
    
    wire [31:0] b_int=(sub)?((~b)+1):(b);
    wire signA   = a[31];
    wire [7:0] expA  = a[30:23];
    wire [22:0] fracA= a[22:0];
    wire [23:0] mantA= {1'b1, fracA};  // add hidden 1

    // -------- Unpack B --------
    wire signB       = b_int[31];
    wire [7:0] expB  = b_int[30:23];
    wire [22:0] fracB= b_int[22:0];
    wire NAN_b = (e2==8'b11111111 && m2==23'd0)?1'b1:1'b0;
    wire NAN_a = (e1==8'b11111111 && m1==23'd0)?1'b1:1'b0;
    wire [23:0] mantB= {1'b1, fracB};
    
    wire [7:0] exp_out=(expA-expB>=0)?(expA):(expB);
    wire [7:0] exp_diff = (expA > expB) ? (expA - expB) : (expB - expA);
    wire exp_sig_gt=(expA>expB)?(1'b1):(1'b0);
    wire exp_sig_eq=(expA==expB)?(1'b1):(1'b0);
    
    always@(posedge clk or posedge rst) begin
      if(rst || NAN_b || NAN_a) begin
        mant_out_a<=24'b0;
        mant_out_b<=24'b0;
        exp_large<=8'b0;
        sign_out<=1'b0;
      end
      
      else begin
       exp_large<=exp_out;
       sign_out<=signA ^ signB;
       if(exp_sig_gt) begin
        mant_out_a<=mantA>>exp_diff;
        mant_out_b<=mantB;
       end 
       else if(!exp_sig_gt && !exp_sig_eq) begin
         mant_out_a<=mantA;
         mant_out_b<=mantB>>exp_diff;
       
       end
      
      
      
      end
    
    
    
    
    end

endmodule
