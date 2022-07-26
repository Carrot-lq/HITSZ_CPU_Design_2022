`timescale 1ns / 1ps
module IF(
    input   wire            rst,
    input   wire            clk,
    // �����ź�
    input   wire[31:0]      npc_i,
    // ���Կ���ģ����ź�
    input   wire            branch_i,
    input   wire            data_suspend_i,    
    input   wire            flush_i,
    // ����ź�
    output  wire[31:0]      inst_o,     // ָ��
    output  wire[31:0]      pc4_o,      // pc+4
    output  wire[31:0]      pc_o        // ��ǰpc
    );
    
    wire[31:0]  pc;     // ��PC������ⲿ�ĵ�ַ
    assign pc_o = pc;
    assign pc4_o = pc + 4;
    
    PC u_PC(
        .clk            (clk),
        .rst            (rst),
        .data_suspend_i (data_suspend_i),
        .flush_i        (flush_i),
        .npc_i          (npc_i),
        .pc_o           (pc)
    );
    
    // NPCת����EX
//    NPC u_NPC(
//        .rst        (rst),
//        .pc_sel_i   (pc_sel_i),
//        .pc_i       (pc),
//        .sext_i     (sext_i),
//        .branch_i   (branch_i),
//        .rD_i       (rD_i),
//        .pc4_o      (pc4_o),
//        .npc_o      (npc)
//    );
    
    prgrom IROM (
        .a      (pc[15:2]),
        .spo    (inst_o)
    );

endmodule
