`timescale 1ns / 1ps
module miniRV(
    input   wire        clk,
    input   wire        rst,
    input   wire[31:0]  mem_rD_i,       // mem读数据输入
    output  wire[31:0]  mem_addr_o,     // mem读写地址
    output  wire[31:0]  mem_wD_o,       // mem写数据输出
    output  wire        mem_we_o,       // mem写使能信号
    output  wire[2:0]   mem_data_sel_o, // mem选择信号
    output  wire        suspend_o,
    output  wire        flush_o
    );
    
    // 当前pc值 用于B型指令，将当前pc值送入ALU
    wire[31:0]  pc_if;
    wire[31:0]  pc_id;
    wire[31:0]  pc_ex;
    wire[31:0]  pc_mem;
    wire[31:0]  pc_wb;
    // pc+4，用于jal,jalr存储pc+4至寄存器
    wire[31:0]  pc4_if;
    wire[31:0]  pc4_id;
    wire[31:0]  pc4_ex;
    wire[31:0]  pc4_mem;
    wire[31:0]  pc4_wb;
    // 下一条指令地址
    wire[31:0]  npc;
    // 从imem读出的指令
    wire[31:0]  inst_if;
    wire[31:0]  inst_id;
    // 经过拓展处理的立即数
    wire[31:0]  sext_id;
    wire[31:0]  sext_ex;
    // 寄存器读出的数据1
    wire[31:0]  rf_rD1_id;
    wire[31:0]  rf_rD1_ex;
    // 寄存器读出的数据2
    wire[31:0]  rf_rD2_id;
    wire[31:0]  rf_rD2_ex;
    // alu运算结果
    wire[31:0]  alu_res_ex;
    wire[31:0]  alu_res_mem;
    wire[31:0]  alu_res_wb;
    // 存储器读写地址
    wire[31:0]  mem_addr_mem;
    // 存储器写数据
    wire[31:0]  mem_wD_mem;
    // 存储器读数据
    wire[31:0]  mem_rD_mem;
    wire[31:0]  mem_rD_wb;
    
    // 来自CTRL的跳转控制信号
    wire        branch_ctrl_id;     
    wire        branch_ctrl_ex;
    // 来自alu的跳转控制信号
    wire        branch_ex;
    // 跳转控制信号
    wire        branch;
    // pc选择信号
    wire[1:0]   pc_sel_id;
    wire[1:0]   pc_sel_ex;
    // 立即数符号拓展选择信号
    wire[2:0]   sext_sel;
    // 寄存器写数据选择信号
    wire[1:0]   rf_wD_sel_id;
    wire[1:0]   rf_wD_sel_ex;
    wire[1:0]   rf_wD_sel_mem;
    wire[1:0]   rf_wD_sel_wb;
    // 寄存器写使能控制
    wire        rf_we_id;
    wire        rf_we_ex;
    wire        rf_we_mem;
    wire        rf_we_wb;
    // 写寄存器号
    wire[4:0]   rf_wR_ex;
    wire[4:0]   rf_wR_mem;
    wire[4:0]   rf_wR_wb;
    // 读寄存器号
    wire[4:0]   rf_rR1_id;
    wire[4:0]   rf_rR1_ex;
    wire[4:0]   rf_rR2_id;
    wire[4:0]   rf_rR2_ex;
    // ALU操作码
    wire[4:0]   alu_op_id;
    wire[4:0]   alu_op_ex;
    // ALU输入1选择信号
    wire        A_sel_id;
    wire        A_sel_ex;
    // ALU输入2选择信号
    wire        B_sel_id;
    wire        B_sel_ex;
    // dmem数据选择信号
    wire[2:0]   mem_data_sel_id;
    wire[2:0]   mem_data_sel_ex;
    wire[2:0]   mem_data_sel_mem;
    // dmem写使能控制信号
    wire        mem_we_id;
    wire        mem_we_ex;
    wire        mem_we_mem;
    
    wire        suspend_sig;
    wire        flush;
    // 数据冒险检测控制信号
    wire        data_hazard_detect_ctrl_r1;
    wire        data_hazard_detect_ctrl_r2;
    
    assign rf_rR1_id = inst_id[19:15];
    assign rf_rR2_id = inst_id[24:20];
    assign mem_addr_o = alu_res_mem;
    assign mem_wD_o = mem_wD_mem;
    assign mem_we_o = mem_we_mem;
    assign mem_data_sel_o = mem_data_sel_mem;
    assign suspend_o = suspend_sig;
    assign flush_o = flush;
    
    // 控制单元
    CTRL u_CTRL(
        .rst            (rst),
        .op_i           (inst_id[6:0]),
        .func7_i        (inst_id[31:25]),
        .func3_i        (inst_id[14:12]),
        .pc_sel_o       (pc_sel_id),
        .branch_ctrl_o  (branch_ctrl_id),
        .sext_sel_o     (sext_sel),
        .rf_wD_sel_o    (rf_wD_sel_id),
        .rf_we_o        (rf_we_id),
        .alu_op_o       (alu_op_id),
        .A_sel_o        (A_sel_id),
        .B_sel_o        (B_sel_id),
        .mem_data_sel_o (mem_data_sel_id),
        .mem_we_o       (mem_we_id),
        .data_hazard_detect_ctrl_r1_o   (data_hazard_detect_ctrl_r1),
        .data_hazard_detect_ctrl_r2_o   (data_hazard_detect_ctrl_r2)
    );

    // 取值单元
    IF u_IF(
        .rst            (rst),
        .clk            (clk),
        .npc_i          (npc),
        .branch_i       (branch),
        .data_suspend_i (suspend_sig),
        .flush_i        (flush),
        .inst_o         (inst_if),
        .pc4_o          (pc4_if),
        .pc_o           (pc_if)
    );
    
    // IF_ID寄存器
    IF_ID u_IF_ID(
        .clk            (clk),
        .rst            (rst),
        .suspend_i      (suspend_sig),
        .flush_i        (flush),
        .inst_i         (inst_if),
        .inst_o         (inst_id),
        .pc_i           (pc_if),
        .pc_o           (pc_id),
        .pc4_i          (pc4_if),
        .pc4_o          (pc4_id)
    );
    
    // 译码单元
    ID u_ID(
        .rst            (rst),
        .clk            (clk),
        .sext_sel_i     (sext_sel),
        .rf_wD_sel_i    (rf_wD_sel_wb),
        .rf_we_i        (rf_we_wb),
        .inst_i         (inst_id),
        .pc4_i          (pc4_wb),
        .alu_res_i      (alu_res_wb),
        .mem_rD_i       (mem_rD_wb),        
        .rf_wR_i        (rf_wR_wb),
        .rf_rD1_o       (rf_rD1_id),
        .rf_rD2_o       (rf_rD2_id),
        .sext_o         (sext_id)
    );
    
    // ID_EX寄存器
    ID_EX u_ID_EX(
        .clk                (clk),
        .rst                (rst),
        .suspend_i          (suspend_sig),
        .flush_i            (flush),
        .branch_ctrl_i      (branch_ctrl_id),   
        .branch_ctrl_o      (branch_ctrl_ex),   
        .pc_i               (pc_id),
        .pc_o               (pc_ex),
        .pc4_i              (pc4_id),
        .pc4_o              (pc4_ex),
        .pc_sel_i           (pc_sel_id),    
        .pc_sel_o           (pc_sel_ex),    
        .sext_i             (sext_id),
        .sext_o             (sext_ex), 
        .rf_rD1_i           (rf_rD1_id),
        .rf_rD1_o           (rf_rD1_ex),
        .rf_rD2_i           (rf_rD2_id),
        .rf_rD2_o           (rf_rD2_ex),
        .rf_rR1_i           (rf_rR1_id),
        .rf_rR1_o           (rf_rR1_ex),
        .rf_rR2_i           (rf_rR2_id),
        .rf_rR2_o           (rf_rR2_ex),
        .rf_wR_i            (inst_id[11:7]),
        .rf_wR_o            (rf_wR_ex),
        .rf_wD_sel_i        (rf_wD_sel_id),
        .rf_wD_sel_o        (rf_wD_sel_ex),
        .rf_we_i            (rf_we_id),
        .rf_we_o            (rf_we_ex),
        .A_sel_i            (A_sel_id),  
        .A_sel_o            (A_sel_ex),   
        .B_sel_i            (B_sel_id),
        .B_sel_o            (B_sel_ex),
        .alu_op_i           (alu_op_id),
        .alu_op_o           (alu_op_ex),
        .mem_we_i           (mem_we_id),
        .mem_we_o           (mem_we_ex),
        .mem_data_sel_i     (mem_data_sel_id),
        .mem_data_sel_o     (mem_data_sel_ex)
    );
    
    // 运算单元
    EX u_EX(
        .rst            (rst),
        .pc_i           (pc_ex),
        .rf_rD1_i       (rf_rD1_ex),
        .rf_rD2_i       (rf_rD2_ex),
        .sext_i         (sext_ex),
        .pc_sel_i       (pc_sel_ex),
        .branch_ctrl_i  (branch_ctrl_ex),
        .A_sel_i        (A_sel_ex),
        .B_sel_i        (B_sel_ex),
        .alu_op_i       (alu_op_ex),
        .alu_res_o      (alu_res_ex),
        .npc_o          (npc)
    );
    
    //EX_MEM寄存器
    EX_MEM u_EX_MEM(
        .clk            (clk),
        .rst            (rst),
        .pc_i           (pc_ex),
        .pc_o           (pc_mem),
        .pc4_i          (pc4_ex),
        .pc4_o          (pc4_mem),
        .rf_wR_i        (rf_wR_ex),
        .rf_wR_o        (rf_wR_mem), 
        .rf_wD_sel_i    (rf_wD_sel_ex),
        .rf_wD_sel_o    (rf_wD_sel_mem),
        .rf_we_i        (rf_we_ex),
        .rf_we_o        (rf_we_mem),
        .alu_res_i      (alu_res_ex),
        .alu_res_o      (alu_res_mem),
        .mem_wD_i       (rf_rD2_ex),
        .mem_wD_o       (mem_wD_mem),
        .mem_we_i       (mem_we_ex),
        .mem_we_o       (mem_we_mem),
        .mem_data_sel_i (mem_data_sel_ex),
        .mem_data_sel_o (mem_data_sel_mem)
    );
    
    assign mem_rD_mem = mem_rD_i;
    
    //MEM_WB寄存器
    MEM_WB u_MEM_WB(
        .clk            (clk),
        .rst            (rst),
        .pc_i           (pc_mem),
        .pc_o           (pc_wb),
        .pc4_i          (pc4_mem),
        .pc4_o          (pc4_wb),
        .rf_wR_i        (rf_wR_mem),
        .rf_wR_o        (rf_wR_wb),
        .rf_wD_sel_i    (rf_wD_sel_mem),
        .rf_wD_sel_o    (rf_wD_sel_wb),
        .rf_we_i        (rf_we_mem),
        .rf_we_o        (rf_we_wb),
        .alu_res_i      (alu_res_mem),
        .alu_res_o      (alu_res_wb),
        .mem_rD_i       (mem_rD_mem),
        .mem_rD_o       (mem_rD_wb)
    );
    
    // 数据冒险检测单元
    data_hazard_detect u_data_hazard_detect(
        .clk                (clk),
        .rst                (rst),
        .rf_rR1_id_ex_i     (inst_id[19:15]),
        .rf_rR2_id_ex_i     (inst_id[24:20]),
        .rf_wR_ex_mem_i     (rf_wR_ex),
        .rf_wR_mem_wb_i     (rf_wR_mem),
        .rf_wR_wb_i         (rf_wR_wb),
        .suspend_o          (suspend_sig),
        .ctrl_detect_r1     (data_hazard_detect_ctrl_r1),
        .ctrl_detect_r2     (data_hazard_detect_ctrl_r2)
    );
    
    assign flush = (npc != pc_ex + 4); 
    
endmodule
