module div_p1 (
    input         clk,
    input         rst,         // synchronous reset
    input  [31:0] a, b,        // IEEE 754 single-precision inputs
    output reg    sign,        // XOR of sign bits (registered)
    output reg [8:0]  exp_diff, // exponent difference + bias (registered)
    output reg [23:0] mant_a, mant_b // mantissas with implicit 1 (registered)
);

    // IEEE-754 bias for single precision
    localparam BIAS = 8'd127;

    // Internal wires for decoded fields
    wire s1 = a[31];
    wire s2 = b[31];
    wire [7:0] e1 = a[30:23];
    wire [7:0] e2 = b[30:23];
    
    wire [22:0] m1 = a[22:0];
    wire [22:0] m2 = b[22:0];
    wire zero=(e2==8'd0 && m2==23'd0)?(1'b1):(1'b0);
    wire NAN_b = (e2==8'b11111111 && m2==23'd0)?1'b1:1'b0;
    wire NAN_a = (e1==8'b11111111 && m1==23'd0)?1'b1:1'b0;

    always @(posedge clk or posedge rst) begin
        if (rst || zero || NAN_b || NAN_a) begin
            sign     <= 1'b0;
            exp_diff <= 9'd0;
            mant_a   <= 24'd0;
            mant_b   <= 24'd0;
        end
        else begin
            // Sign is XOR of input signs
            sign     <= s1 ^ s2;

            // Exponent for division: e1 - e2 + bias
            exp_diff <= {1'b0, e1} - {1'b0, e2} + {1'b0, BIAS};

            // Mantissas with hidden leading 1
            mant_a   <= {1'b1, m1};
            mant_b   <= {1'b1, m2};
        end
    end

endmodule
