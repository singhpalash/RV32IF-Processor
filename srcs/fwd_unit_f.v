// forwarding_unit.v
// 2-bit select: 00 -> regfile, 01 -> EX, 10 -> MEM, 11 -> WB
// Stall asserted when EX has the producing destination but its result is not ready.

module fwd_unit_f (
    input  wire [4:0] rs1_id,
    input  wire [4:0] rs2_id,
    input wire [31:0] result_ex,
    input wire [31:0] result_mem,
    input  wire [4:0] rd_ex,
    input  wire [4:0] rd_mem,
    

    input  wire       reg_write_ex,
    input  wire       reg_write_mem,
    input  wire       reg_write_wb,

    // indicates whether EX-stage result is available for forwarding
    // (for most pipelined ALUs this is 1; for long-latency units like FDIV it might be 0 until done)
    input  wire       ex_result_ready,

    // optionally gate forwarding only for FP instructions in ID
    input  wire       is_fp_id,  

    output reg  [1:0] forward_a_sel, // for operand A (rs1)
    output reg  [1:0] forward_b_sel, // for operand B (rs2)
    output reg        stall,
    output reg [31:0] fwd_a,
    output reg [31:0] fwd_b
);

    // convenience functions
    function is_hazard_ex;
        input [4:0] rs;
        begin
            is_hazard_ex = (rs != 5'd0) && reg_write_ex && (rs == rd_ex);
        end
    endfunction

    function is_hazard_mem;
        input [4:0] rs;
        begin
            is_hazard_mem = (rs != 5'd0) && reg_write_mem && (rs == rd_mem);
        end
    endfunction



    always @(*) begin
        // default: no stall, take regfile
        stall = 1'b0;
        forward_a_sel = 2'b00;
        forward_b_sel = 2'b00;

        if (!is_fp_id) begin
            // If not FP instruction, keep defaults (or you can add integer forwarding similarly)
            stall = 1'b0;
        end else begin
            // ---------- RS1 ----------
            if (is_hazard_ex(rs1_id)) begin
                if (!ex_result_ready) begin
                    // EX produces but not yet ready -> must stall
                    stall = 1'b1;
                    forward_a_sel = 2'b00; // irrelevant while stalling
                end else begin
                    // forward from EX
                    forward_a_sel = 2'b01;
                    fwd_a<=result_ex;
                end
            end else if (is_hazard_mem(rs1_id)) begin
                forward_a_sel = 2'b10;
                fwd_a<=result_mem;
            end else begin
                forward_a_sel = 2'b00;
            end

            // ---------- RS2 ----------
            if (is_hazard_ex(rs2_id)) begin
                if (!ex_result_ready) begin
                    // if already set stall by rs1, keep it; else set stall
                    stall = 1'b1;
                    forward_b_sel = 2'b00;
                end else begin
                    forward_b_sel = 2'b01;
                    fwd_b<=result_ex;
                end
            end else if (is_hazard_mem(rs2_id)) begin
                forward_b_sel = 2'b10;
                fwd_b<=result_mem;
            end else begin
                forward_b_sel = 2'b00;
            end
        end
    end

endmodule
