`timescale 1ns / 1ps
module IF(
    input   wire        rst,
    input   wire        clk,
    // �����ź�
    input   wire[31:0]  sext_i,     // ������չ��������������ת
    input   wire[31:0]  rf_rD_i,       // jalr�мĴ���ֵrs1
    // ���Կ���ģ����ź�
    input   wire[1:0]   pc_sel_i,   // pcѡ���ź�
    input   wire        branch_i,   // ��ת
    // ����ź�
    output  wire[31:0]  inst_o,     // ָ��
    output  wire[31:0]  pc4_o,      // pc+4
    output  wire[31:0]  pc_o,       // ��ǰpc
    // for trace test
    input   wire[31:0]  outer_inst_i
    );
    
    wire[31:0]  npc;    // ��NPC���������PC�ĵ�ַ������һ��ָ���ַ
    wire[31:0]  pc;     // ��PC������ⲿ����ص�NPC��+4���ĵ�ַ
    assign pc_o = pc;
    
    // ָ���ַ���
    PC u_PC(
        .clk    (clk),
        .rst    (rst),
        .pc_i   (npc),
        .pc_o   (pc)
    );
    
    // ��һ��ָ���ַ
    NPC u_NPC(
        .pc_sel_i   (pc_sel_i),
        .pc_i       (pc),
        .sext_i     (sext_i),
        .branch_i   (branch_i),
        .rf_rD_i    (rf_rD_i),
        .pc4_o      (pc4_o),
        .npc_o      (npc)
    );
    
//    prgrom IROM (
//        .a      (pc[15:2]),
//        .spo    (inst_o)
//    );
    
    // for trace test
    assign inst_o = outer_inst_i;

endmodule
