`timescale 1ns / 1ps
module miniRV(
    input   wire        clk,
    input   wire        rst,
    // for trace test
    input   wire[31:0]  inst_i,             // 外部输入inst，替换IF输出的inst
    output  wire[31:0]  pc_o,               // 将pc输出
    output  wire        mem_we_o,           // 将mem_we输出
    output  wire[31:0]  mem_addr_o,         // S型指令中主存地址 rs1+offset 从ALU计算结果来
    output  wire[31:0]  mem_input_data_o,   // MEM中将存入主存的数据输出
    input   wire[31:0]  mem_output_data_i,  // 外部输入数据，替换MEM中主存读出数据
    output  wire        debug_rf_we_o,      // ID中将写使能rf_we输出
    output  wire[4:0]   debug_rf_wR_o,      // ID中将写寄存器号输出
    output  wire[31:0]  debug_rf_wD_o       // ID中将写数据输出
    );
    
    wire[31:0]  pc;             // 当前pc值 用于B型指令，将当前pc值送入ALU       从IF输出，送至EX
    wire[31:0]  pc4;            // pc+4，用于jal,jalr存储pc+4至寄存器            从IF输出，送至ID
    wire[31:0]  inst;           // 从imem读出的指令                              从IF输出，送至ID和CTRL
    wire[31:0]  sext;           // 经过拓展处理的立即数     从ID输出，送至IF和EX
    wire[31:0]  rf_rD1;         // 寄存器读出的数据1        从ID输出，送至IF和EX
    wire[31:0]  rf_rD2;         // 寄存器读出的数据2        从ID输出，送至IF和EX
    wire[31:0]  alu_res;        // alu运算结果              从EX输出，送至ID和MEM
    wire[31:0]  mem_rD;         // 存储器读数据             从MEM输出，送至ID  
    
    wire        branch_ctrl;    // 来自CTRL的跳转控制信号
    wire        branch_ex;      // 来自alu的跳转控制信号
    wire        branch;         // 跳转控制信号 送至IF
    assign branch = branch_ctrl & branch_ex;
    wire[1:0]   pc_sel;         // pc选择信号   从CTRL输出，送至IF
    wire[2:0]   sext_sel;       // 立即数符号拓展选择信号   从CTRL输出，送至ID
    wire[1:0]   rf_wD_sel;      // 寄存器写数据选择信号     从CTRL输出，送至ID
    wire        rf_we;          // 寄存器写使能控制         从CTRL输出，送至ID
    wire[4:0]   alu_op;         // ALU操作码           从CTRL输出，送至EX
    wire        A_sel;          // ALU输入1选择信号    从CTRL输出，送至EX
    wire        B_sel;          // ALU输入2选择信号    从CTRL输出，送至EX
    wire[2:0]   mem_data_sel;   // dmem数据选择信号    从CTRL输出，送至MEM
    wire        mem_we;         // dmem写使能控制信号  从CTRL输出，送至MEM
    
    // 控制单元
    CTRL u_CTRL(
        .rst            (rst),
        .op_i           (inst[6:0]),
        .func7_i        (inst[31:25]),
        .func3_i        (inst[14:12]),
        .pc_sel_o       (pc_sel),
        .branch_ctrl_o  (branch_ctrl),
        .sext_sel_o     (sext_sel),
        .rf_wD_sel_o    (rf_wD_sel),
        .rf_we_o        (rf_we),
        .alu_op_o       (alu_op),
        .A_sel_o        (A_sel),
        .B_sel_o        (B_sel),
        .mem_data_sel_o (mem_data_sel),
        .mem_we_o       (mem_we)
    );
    
    // 取值单元
    IF u_IF(
        .rst            (rst),
        .clk            (clk),
        .sext_i         (sext),
        .rf_rD_i        (rf_rD1),
        .pc_sel_i       (pc_sel),
        .branch_i       (branch),
        .inst_o         (inst),
        .pc4_o          (pc4),
        .pc_o           (pc),
        // for trace test
        .outer_inst_i   (inst_i)
    );
    
    // 译码单元
    ID u_ID(
        .rst            (rst),
        .clk            (clk),
        .sext_sel_i     (sext_sel),
        .rf_wD_sel_i    (rf_wD_sel),
        .rf_we_i        (rf_we),
        .inst_i         (inst),
        .pc4_i          (pc4),
        .alu_res_i      (alu_res),
        .mem_rD_i       (mem_rD),        
        .sext_o         (sext),
        .rf_rD1_o       (rf_rD1),
        .rf_rD2_o       (rf_rD2),
        // for trace test
        .debug_rf_we_o  (debug_rf_we_o),
        .debug_rf_wR_o  (debug_rf_wR_o),
        .debug_rf_wD_o  (debug_rf_wD_o)
    );
    
    // 运算单元
    EX u_EX(
        .pc_i           (pc),
        .rf_rD1_i       (rf_rD1),
        .rf_rD2_i       (rf_rD2),
        .sext_i         (sext),
        .A_sel_i        (A_sel),
        .B_sel_i        (B_sel),
        .alu_op_i       (alu_op),
        .alu_res_o      (alu_res),
        .alu_branch_o   (branch_ex)
    );
    
    // 数据存储单元
    MEM u_MEM(
        .rst                (rst),
        .clk                (clk),
        .mem_addr_i         (alu_res),
        .mem_wD_i           (rf_rD2),
        .mem_we_i           (mem_we),
        .mem_data_sel_i     (mem_data_sel),
        .mem_rD_o           (mem_rD),
        // for trace test
        .mem_input_data_o   (mem_input_data_o),
        .mem_output_data_i  (mem_output_data_i)
    );
    
    // for trace test
    assign pc_o = pc;               // 当前pc
    assign mem_addr_o = alu_res;    // S型指令中主存地址 rs1+offset 从ALU计算结果来
    assign mem_we_o = mem_we;       // 当前mem_we
    
endmodule
