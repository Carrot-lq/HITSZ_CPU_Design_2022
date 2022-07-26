`timescale 1ns / 1ps
module top(
    input   wire        clk,                // 系统时钟
    input   wire        rst_n,              // 异步重置信号，低电平有效
    // for trace test
    output  wire        debug_wb_have_inst, // WB阶段是否有指令 (对单周期CPU，此flag恒为1)
    output  wire[31:0]  debug_wb_pc,        // WB阶段的PC (若wb_have_inst=0，此项可为任意值)
    output  wire        debug_wb_ena,       // WB阶段的寄存器写使能 (若wb_have_inst=0，此项可为任意值)
    output  wire[4:0]   debug_wb_reg,       // WB阶段写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output  wire[31:0]  debug_wb_value      // WB阶段写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
);

//    wire    cpu_clk;        // 分频后时钟
//    cpu_clk_div u_cpu_clk_div(
//        .rst            (rst_i),
//        .clk_i          (clk_i),
//        .cpu_clk_o      (cpu_clk)
//    );

    // for trace test
    wire        rst = ~rst_n;       // 高电平有效的重置信号
    wire[31:0]  inst;               // 32位指令    从inst_mem输出，送至cpu
    wire[31:0]  pc;                 // 32位pc，仅15:2有效    从cpu输出，送至inst_mem和trace测试
    wire        debug_rf_we;        // regfile寄存器写使能控制信号    从cpu输出，送至trace测试
    wire[4:0]   debug_rf_wR;        // 写入寄存器的5位编号    从cpu输出，送至trace测试
    wire[31:0]  debug_rf_wD;        // 写入寄存器的32位数据    从cpu输出，送至trace测试
    wire        mem_we;             // dmem写使能控制信号    从cpu输出，送至data_mem
    wire[31:0]  mem_addr;           // dmem读写地址          从cpu输出，送至data_mem
    wire[31:0]  mem_input_data;     // 写dmem输入的32位数据    从cpu输出，送至data_mem
    wire[31:0]  mem_output_data;    // 读dmem输出的32位数据    从cpu输出，送至data_mem
    
    assign debug_wb_have_inst = 1'b1;
    assign debug_wb_pc  = pc;
    assign debug_wb_ena = debug_rf_we;
    assign debug_wb_reg = debug_rf_wR;
    assign debug_wb_value = debug_rf_wD;
    
    miniRV u_miniRV (
        .clk                (clk),
        .rst                (rst),
        // for trace test
        .inst_i             (inst),
        .pc_o               (pc),
        .mem_we_o           (mem_we),
        .mem_addr_o         (mem_addr),
        .mem_input_data_o   (mem_input_data),
        .mem_output_data_i  (mem_output_data),
        .debug_rf_we_o      (debug_rf_we),
        .debug_rf_wR_o      (debug_rf_wR),
        .debug_rf_wD_o      (debug_rf_wD)
    );
    // 下面两个模块，只需要实例化并连线，不需要添加文件
    inst_mem imem(
        .a     (pc[15:2]),
        .spo   (inst)
    );
    
    data_mem dmem(
        .clk    (clk),
        .a      (mem_addr[15:2]),
        .spo    (mem_output_data),
        .we     (mem_we),
        .d      (mem_input_data)
    );
endmodule
