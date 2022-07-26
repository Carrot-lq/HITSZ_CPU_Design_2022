`timescale 1ns / 1ps
module IF(
    input   wire            rst,
    input   wire            clk,
    // 输入信号
    input   wire[31:0]      npc_i,
    // 来自控制模块的信号
    input   wire            data_suspend_i,    
    input   wire            flush_i,
    // 输出信号
    output  wire[31:0]      inst_o,     // 指令
    output  wire[31:0]      pc4_o,      // pc+4
    output  wire[31:0]      pc_o,       // 当前pc
    // for trace test
    input   wire[31:0]      outer_inst_i
    );
    
    wire[31:0]  pc;     // 从PC输出向外部的地址
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
    
    // NPC转移至EX
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
    
//    prgrom IROM (
//        .a      (pc[15:2]),
//        .spo    (inst_o)
//    );
    
    // for trace test
    assign inst_o = outer_inst_i;

endmodule
