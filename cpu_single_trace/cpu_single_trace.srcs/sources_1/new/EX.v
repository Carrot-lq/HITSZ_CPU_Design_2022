`timescale 1ns / 1ps
module EX#(
    parameter PC    = 1'b0,
    parameter RD1   = 1'b1,
    parameter EXT   = 1'b0,
    parameter RD2   = 1'b1
)(
    // 输入信号
    input   wire[31:0]  pc_i,
    input   wire[31:0]  rf_rD1_i,
    input   wire[31:0]  rf_rD2_i,
    input   wire[31:0]  sext_i,
    // 控制信号
    input   wire        A_sel_i,
    input   wire        B_sel_i,
    input   wire[4:0]   alu_op_i,
    // 输出信号
    output  wire[31:0]  alu_res_o,
    output  wire        alu_branch_o
    );
    reg [31:0] alu_a;
    reg [31:0] alu_b;
    // alu_a选择（pc/rD1）
    always @(*) begin
        case(A_sel_i)
            PC:     alu_a = pc_i;
            RD1:    alu_a = rf_rD1_i;
            default:alu_a = 32'h0;
        endcase
    end
    // alu_b选择（imm/rD1）
    always @(*) begin
        case(B_sel_i)
            EXT:    alu_b = sext_i;
            RD2:    alu_b = rf_rD2_i;
            default:alu_b = 32'h0;
        endcase
    end
    
    ALU u_ALU(
        .alu_op_i   (alu_op_i),
        .alu_a_i    (alu_a),
        .alu_b_i    (alu_b),
        .alu_res_o  (alu_res_o),
        .branch_o   (alu_branch_o)
    );
endmodule
