module div_p3 (
    input         clk,
    input         rst,
    input         sign_in,           // sign from div_p2
    input  [8:0]  exp_in,            // exponent from div_p2
    input  [23:0] mant_a_in,         // numerator mantissa (normalized)
    input  [23:0] mant_b_in,         // denominator mantissa
    output reg    sign_out,          // sign output (registered)
    output reg [8:0]  exp_out,       // exponent output (registered)
    output wire [23:0] mant_res       // quotient mantissa (registered)
);

div_gen_0 div_op (
  .aclk(clk),                                      // input wire aclk
  .aresetn(~rst),                                // input wire aresetn
  //.s_axis_divisor_tvalid(s_axis_divisor_tvalid),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(mant_a_in),      // input wire [23 : 0] s_axis_divisor_tdata
  //.s_axis_dividend_tvalid(s_axis_dividend_tvalid),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(mant_b_in),    // input wire [23 : 0] s_axis_dividend_tdata
  //.m_axis_dout_tvalid(m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(mant_res)            // output wire [47 : 0] m_axis_dout_tdata
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sign_out <= 1'b0;
            exp_out  <= 9'd0;
        end else begin
            sign_out <= sign_in;
            exp_out  <= exp_in;
        end
    end

endmodule
