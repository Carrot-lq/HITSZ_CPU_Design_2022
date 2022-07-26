`timescale 1ns / 1ps
module IF(
    input   wire        rst,
    input   wire        clk,
    // 输入信号
    input   wire[31:0]  sext_i,     // 符号扩展立即数，用于跳转
    input   wire[31:0]  rf_rD_i,       // jalr中寄存器值rs1
    // 来自控制模块的信号
    input   wire[1:0]   pc_sel_i,   // pc选择信号
    input   wire        branch_i,   // 跳转
    // 输出信号
    output  wire[31:0]  inst_o,     // 指令
    output  wire[31:0]  pc4_o,      // pc+4
    output  wire[31:0]  pc_o,       // 当前pc
    // for trace test
    input   wire[31:0]  outer_inst_i
    );
    
    wire[31:0]  npc;    // 从NPC输出，输入PC的地址，即下一条指令地址
    wire[31:0]  pc;     // 从PC输出向外部（或回到NPC以+4）的地址
    assign pc_o = pc;
    
    // 指令地址输出
    PC u_PC(
        .clk    (clk),
        .rst    (rst),
        .pc_i   (npc),
        .pc_o   (pc)
    );
    
    // 下一条指令地址
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
