`timescale 1ns / 1ps
module EX#(
    parameter PC    = 1'b0,
    parameter RD1   = 1'b1,
    parameter EXT   = 1'b0,
    parameter RD2   = 1'b1
)(
    input   wire        rst,
    // �����ź�
    input   wire[31:0]  pc_i,
    input   wire[31:0]  rf_rD1_i,
    input   wire[31:0]  rf_rD2_i,
    input   wire[31:0]  sext_i,
    // �����ź�
    input   wire[1:0]   pc_sel_i,
    input   wire        branch_ctrl_i,
    input   wire        A_sel_i,
    input   wire        B_sel_i,
    input   wire[4:0]   alu_op_i,
    // ����ź�
    output  wire[31:0]  alu_res_o,
    output  wire[31:0]  npc_o
    );
    wire        alu_branch;
    wire        branch;
    reg[31:0]   alu_a;
    reg[31:0]   alu_b;
    
    assign branch = branch_ctrl_i & alu_branch;
    
    // alu_aѡ��pc/rD1��
    always @(*) begin
        case(A_sel_i)
            PC:     alu_a = pc_i;
            RD1:    alu_a = rf_rD1_i;
            default:alu_a = 32'h0;
        endcase
    end
    // alu_bѡ��imm/rD2��
    always @(*) begin
        case(B_sel_i)
            EXT:    alu_b = sext_i;
            RD2:    alu_b = rf_rD2_i;
            default:alu_b = 32'h0;
        endcase
    end
    
    ALU u_ALU(
        .alu_op_i       (alu_op_i),
        .alu_a_i        (alu_a),
        .alu_b_i        (alu_b),
        .alu_res_o      (alu_res_o),
        .branch_o       (alu_branch)
    );
    
    NPC u_NPC(
        .rst        (rst),
        .pc_sel_i   (pc_sel_i),
        .pc_i       (pc_i),
        .sext_i     (sext_i),
        .rf_rD_i    (rf_rD1_i),
        .branch_i   (branch),
        .npc_o      (npc_o)
    );
endmodule
