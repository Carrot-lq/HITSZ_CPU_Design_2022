`timescale 1ns / 1ps
module top(
    input   wire        clk,                // ϵͳʱ��
    input   wire        rst_n,              // �첽�����źţ��͵�ƽ��Ч
    // for trace test
    output  wire        debug_wb_have_inst, // WB�׶��Ƿ���ָ�� (�Ե�����CPU����flag��Ϊ1)
    output  wire[31:0]  debug_wb_pc,        // WB�׶ε�PC (��wb_have_inst=0�������Ϊ����ֵ)
    output  wire        debug_wb_ena,       // WB�׶εļĴ���дʹ�� (��wb_have_inst=0�������Ϊ����ֵ)
    output  wire[4:0]   debug_wb_reg,       // WB�׶�д��ļĴ����� (��wb_ena��wb_have_inst=0�������Ϊ����ֵ)
    output  wire[31:0]  debug_wb_value      // WB�׶�д��Ĵ�����ֵ (��wb_ena��wb_have_inst=0�������Ϊ����ֵ)
);

//    wire    cpu_clk;        // ��Ƶ��ʱ��
//    cpu_clk_div u_cpu_clk_div(
//        .rst            (rst_i),
//        .clk_i          (clk_i),
//        .cpu_clk_o      (cpu_clk)
//    );

    // for trace test
    wire        rst = ~rst_n;       // �ߵ�ƽ��Ч�������ź�
    wire[31:0]  inst;               // 32λָ��    ��inst_mem���������cpu
    wire[31:0]  pc;                 // 32λpc����15:2��Ч    ��cpu���������inst_mem��trace����
    wire        debug_rf_we;        // regfile�Ĵ���дʹ�ܿ����ź�    ��cpu���������trace����
    wire[4:0]   debug_rf_wR;        // д��Ĵ�����5λ���    ��cpu���������trace����
    wire[31:0]  debug_rf_wD;        // д��Ĵ�����32λ����    ��cpu���������trace����
    wire        mem_we;             // dmemдʹ�ܿ����ź�    ��cpu���������data_mem
    wire[31:0]  mem_addr;           // dmem��д��ַ          ��cpu���������data_mem
    wire[31:0]  mem_input_data;     // дdmem�����32λ����    ��cpu���������data_mem
    wire[31:0]  mem_output_data;    // ��dmem�����32λ����    ��cpu���������data_mem
    
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
    // ��������ģ�飬ֻ��Ҫʵ���������ߣ�����Ҫ����ļ�
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
